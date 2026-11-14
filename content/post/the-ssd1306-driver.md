---
title: "Phase 6: The SSD1306 Driver — Follow the Method Calls"
date: 2026-11-14T00:00:00-08:00
draft: false
description: "Read the real OLED driver, follow inherited methods and initialization, and build a recorder to investigate commands and image transfers."
summary: "Find where drawing methods come from, trace show() through the driver, and test its behavior with a recording I²C stand-in."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "classes"]
reading_time: 90
toc_depth: 3
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/pico-oled-project/">Pico OLED project: guide and lesson roadmap</a>. Previously: <a href="/post/drawing-graphics/">Phase 5: Drawing Graphics</a>.</aside>

Open `ssd1306.py` and search for `def text`. Nothing! Yet `oled.text("Hi Yush", 0, 0)` has worked all along. **Where did that method come from?** Today we'll follow the calls behind familiar commands. By the end, you'll be able to explain how the driver shares its work—and write a small recorder that lets you investigate it yourself.

## What You Will Be Able to Do

- Explain a class, an instance, `self`, and inherited methods using code you can trace.
- Follow the driver's setup and explain why its order matters.
- Separate drawing, OLED commands, and image transfers by finding their definitions.
- Record transfers and extend a method while preserving the work it already does.

## Get Ready

{{< download "/downloads/pico/phase-6-driver-lab.py" "Download the Phase 6 driver lab" >}}. Only imports, dimensions, and a readiness message run. Keep the [Phase 1 kit's `ssd1306.py`](/downloads/pico/phase-1-kit/ssd1306.py) in the **same folder on the Pico**. Open that file beside the lab so you can search its definitions. Keep the borrowed driver unchanged; write experiments in your lab file.

Run the whole lab file through Thonny or MicroPico in VS Code. Keep any class a later question uses, and replace earlier experiment code. No `input()` pauses or preserved Python session are needed.

**An OLED connection is optional today.** Our final experiments replace the physical connection with a recorder. They still need MicroPython, such as on your Pico, because `framebuf` is built into that runtime. Ordinary desktop Python can run the small `Label` example below in a separate file; importing this driver there usually fails because `framebuf` is missing. Without a Pico, use the browser trace and work through the source on paper.

We'll read the exact driver supplied in the kit. Other versions may arrange their code differently. The detailed meaning of controller settings and I²C control bytes comes in the next phases; today's job is to follow who calls whom.

## A Small Class You Can Follow

A **class** defines a kind of object: the data it keeps and the methods it offers. An **instance** is one object made from that class. Calling the class creates an instance; its `__init__()` method sets up the starting state.

Here is a small example before we tackle the driver:

```python
class Label:
    def __init__(self, text):
        self.text = text

    def rename(self, text):
        self.text = text

label = Label("Hi Yush")
label.rename("PICO")
print(label.text)  # PICO
```

`self.text` is an **attribute**: data belonging to that object. The parameter `text` is the new value arriving in a call. `self.text = text` stores that value on the object so it remains available after the method returns.

In `label.rename("PICO")`, Python supplies `label` as the method's first argument, `self`. We supply only the new text. **`self` means the instance receiving this call.** A method can therefore work with an object without knowing the variable name we chose for it.

{{< lesson-exercise number="1" title="Which label changes?" id="q1-which-label-changes" >}}

Keep the `Label` class definition, replacing the earlier example calls with this code. Predict both printed lines, then run it:

```python
first = Label("Hi Yush")
second = Label("PICO")
first.rename("READY")
print(first.text)
print(second.text)
```

Explain which object `self` refers to inside `rename()`. Would renaming the variable `first` to `greeting` require changing the class?

{{< hints >}}
- Calling `Label(...)` twice creates two instances.
- Read `first.rename(...)` as a request to change the object named `first`.
{{< /hints >}}
{{< answer >}}
The lines are `READY` and `PICO`. Each instance has its own `text` attribute. During this call, `self` refers to the object named `first`; the other instance is untouched.

Renaming the outside variable doesn't require changing the class.

**A method's code can be shared while each instance keeps its own state.** In the driver, `self.buffer` belongs to the particular display object receiving a call.
{{< /answer >}}
{{< /lesson-exercise >}}

## One Object, Methods from Three Classes

Look for these two class headers in the driver:

```python
class SSD1306(framebuf.FrameBuffer):
    ...

class SSD1306_I2C(SSD1306):
    ...
```

The name in parentheses is the **base class**. The new class is a **subclass**. Through **inheritance**, a subclass can use methods supplied by its base class. In this single-inheritance chain, Python looks for a method in the instance's class, then continues through its base classes if needed:

| Start here, then look down | Main responsibility |
| --- | --- |
| `SSD1306_I2C` | Send commands and image data through an I²C connection. |
| `SSD1306` | Allocate the image buffer, configure the SSD1306, and prepare transfers. |
| `framebuf.FrameBuffer` | Draw text, pixels, lines, and rectangles into that buffer. |

So an `SSD1306_I2C` instance can use `FrameBuffer.text()` even though neither Python class defines it. `framebuf` is a MicroPython module; its drawing implementation isn't another Python file in our kit.

**These are three sources of behavior for one display object.** They are not three display objects, each keeping a separate picture. The base initializer connects the drawing tools to the same `self.buffer` that `show()` later sends.

There is a different relationship in `self.i2c = i2c`: the display object **holds a reference to a separate connection object**. It uses that object's methods to communicate. The display isn't a subclass of `machine.I2C`.

{{< lesson-exercise number="2" title="Find the definition, then the destination" id="q2-find-the-definition-then-the-destination" >}}

For each call, identify the class that defines the method and decide whether the call changes the prepared image, requests a transfer, or performs a transport operation:

- `oled.text("Hi Yush", 0, 0)`
- `oled.show()`
- `oled.write_data(oled.buffer)`

Use the class headers and search for the definitions. Which call belongs in our normal drawing code when we want to display a finished frame? Why isn't `write_data()` a complete replacement for it?

{{< hints >}}
- An absent definition means continue into the base class, not that the method is unavailable.
- `show()` does work before it calls `write_data()`.
{{< /hints >}}
{{< answer >}}
| Call | Definition | Work |
| --- | --- | --- |
| `text(...)` | `framebuf.FrameBuffer` | Draw glyphs into the prepared image. |
| `show()` | `SSD1306` | Select the display's destination range, then request an image transfer. |
| `write_data(...)` | `SSD1306_I2C` | Pass the supplied image bytes to the I²C connection. |

Use `show()` in our drawing programs. Calling `write_data()` directly skips the address-range commands that this driver's `show()` sends first; we cannot assume the controller is already positioned correctly.

**An inherited method is still part of the object's interface.** Finding its definition tells us which layer owns its work.
{{< /answer >}}
{{< /lesson-exercise >}}

## Follow Setup on the Same Instance

A **module** is a unit of Python code, such as `ssd1306.py`. The lab uses `import ssd1306`, so we reach the class as `ssd1306.SSD1306_I2C`. Earlier lessons imported the class name directly; both forms reach the same class.

Our familiar construction call is:

```python
oled = ssd1306.SSD1306_I2C(128, 64, i2c)
```

Here `i2c` must already refer to a connection object. Inside the I²C class's initializer, the driver stores that connection, the device address, and temporary transfer storage. Then it calls:

```python
super().__init__(width, height, external_vcc)
```

**`super()` continues to the next class in the inheritance chain, using the same instance.** Here that next initializer is `SSD1306.__init__()`. It does not create another display object.

Read that base initializer in the file. Its key steps are:

1. Store the dimensions and calculate `self.pages = self.height // 8`.
2. Allocate `self.buffer = bytearray(self.pages * self.width)`.
3. Call the `FrameBuffer` initializer with that buffer, the dimensions, and `MONO_VLSB`.
4. Call `self.init_display()`.

For 128 × 64, that is eight pages and a 1,024-byte buffer—the layout from Phase 3. The `FrameBuffer` initializer gives its drawing methods access to that storage.

Now inspect `init_display()`. It sends setup command values, then ends with:

```python
self.fill(0)
self.show()
```

**Constructing this driver already sends a blank frame.** That explains why rerunning a whole file can clear a previous picture before your drawing code begins.

There is another useful surprise: `init_display()` is defined in `SSD1306`, but its `self.write_cmd(...)` calls reach the implementation in `SSD1306_I2C`. A subclass can provide a method that base-class code calls. We call that **overriding** when it replaces a method supplied by a base class; here the transport subclass supplies writers that `SSD1306` expects but does not define.

{{< lesson-exercise number="3" title="Why prepare the connection first?" id="q3-why-prepare-the-connection-first" >}}

In `SSD1306_I2C.__init__()`, find `self.temp = bytearray(2)`. Imagine moving only that assignment below the call to `super().__init__(...)`.

Without editing your working driver, follow the calls and predict the first failure. Which method tries to use `self.temp` before the delayed assignment can run? Would this be an I²C `EIO` error or a missing-attribute error?

{{< hints >}}
- The base initializer calls `init_display()` before returning.
- The first setup command calls `self.write_cmd(cmd)`.
- Look at the first statement in the I²C class's `write_cmd()`.
{{< /hints >}}
{{< answer >}}
The path is:

```text
SSD1306_I2C.__init__()
  → SSD1306.__init__()
    → init_display()
      → SSD1306_I2C.write_cmd(...)
        → self.temp[0] = 0x80
```

`self.temp` does not exist yet, so this fails with `AttributeError`, before that writer reaches `self.i2c.writeto(...)`. It is different from an `EIO` raised during a bus operation.

In a fresh session, a failed `oled = ...` also leaves no `oled` name: the construction call never returned a result to assign.

**Setup order follows dependencies, not just the order of class definitions in the file.** A base initializer can call a subclass's method, so the state that method needs must already be ready.
{{< /answer >}}
{{< /lesson-exercise >}}

## Trace a Call Through the Driver

Choose a call below and predict which definition runs first. Reveal one step at a time, explaining each handoff before continuing. For construction, repeated setup writes are grouped together; the model is a reading aid, not a Python interpreter or a physical bus simulation.

{{< driver-call-trace >}}

## Read show() as a Recipe

For our 128-column display, `SSD1306.show()` selects a column range and a page range, then sends `self.buffer`. The range ends are **inclusive**, just like the endpoints you counted in Phase 5.

The six command values for 128 × 64 are:

| Purpose | Values passed to `write_cmd()` |
| --- | --- |
| Select columns 0–127 | `0x21`, `0`, `127` |
| Select pages 0–7 | `0x22`, `0`, `7` |

These are six separate calls to `write_cmd()`, followed by **one** `write_data(self.buffer)` call. A command and its parameter bytes share that writer; not every value in the table is a new instruction.

The I²C writer adds control information to those values. For an image transfer it combines `b"\x40"` with the buffer. That prefix is one byte with value `0x40`; it is separate from our 1,024 image bytes. Phase 7 will unpack these transport bytes and the device address.

The file also includes `SSD1306_SPI`, which supplies writers for another serial connection, SPI. It reuses the same `SSD1306` base behavior. We use its existence to see the design: shared display work, different transport implementations. We don't need to wire SPI for this lesson.

{{< lesson-exercise number="4" title="Same width, half the height" id="q4-same-width-half-the-height" >}}

Imagine constructing this driver for a **128 × 32** display. Work out its page count, buffer length, and the six values passed to `write_cmd()` by `show()`. Keep the column count at 128, so the narrow-display offset branch does not apply.

If the program draws ten pixels and then calls `show()` twice, how many image bytes do those two calls send? Count only those explicit calls, excluding construction and transport control information.

{{< hints >}}
- Each page covers eight pixel rows.
- Four pages have numbers 0–3.
- This driver's `show()` sends the whole buffer even when the picture hasn't changed.
{{< /hints >}}
{{< answer >}}
There are `32 // 8 = 4` pages and `4 * 128 = 512` image bytes.

```text
write_cmd values: 0x21, 0, 127, 0x22, 0, 3
then: write_data(buffer), with 512 image bytes
```

The two explicit `show()` calls send `2 * 512 = 1024` image bytes. Drawing ten pixels doesn't reduce this driver's transfer size. The last page value is 3, not 4, because endpoints are inclusive.

**Dimensions determine the ranges and transfer size; the number of changed pixels doesn't.** Reading the implementation lets us predict a cost that the method name alone doesn't reveal.
{{< /answer >}}
{{< /lesson-exercise >}}

## Other Methods: Change Settings or Change Pixels?

The rest of `SSD1306` is short enough to survey by the calls each method makes. You don't need to memorize command numbers.

At the top of the file, names such as `SET_NORM_INV = const(0xA6)` give command values readable names. `const()` declares a MicroPython constant; it doesn't send anything. The writer calls are where those values become communication requests.

| Method | What its code does |
| --- | --- |
| `init_display()` | Send the controller's setup sequence, clear the prepared image, and call `show()`. |
| `poweroff()` / `poweron()` | Send a display-off or display-on command; leave the Python buffer alone. |
| `contrast(value)` | Send a contrast command and its parameter, using two `write_cmd()` calls. |
| `invert(value)` | Send one command to select normal or inverted display output; leave the stored image bytes alone. |
| `rotate(value)` | Send two commands to change the controller's orientation settings; do not rearrange the Python buffer. |

A setting can change the visible output without changing `self.buffer`. This extends Phase 4's distinction between the prepared image and the display: the controller also has settings that affect how it presents image data.

## Build an Observation Point

How could we check our traces without relying on a quick flash on the screen? The I²C subclass uses only two connection methods here: `writeto(address, data)` and `writevto(address, parts)`. We can give it a different object with those methods—one that records the requests instead of sending them.

That object is a **test double**: a stand-in with the interface our driver needs. It can tell us which operations the driver requested. It cannot prove that a cable, a real bus, or an OLED controller works.

Our recorder will store events as tuples:

```text
(method name, destination address, snapshot of the bytes)
```

The snapshot matters. This driver reuses `self.temp`, a mutable two-byte array, for command writes. `bytes(data)` makes an immutable copy of its current contents, like the snapshots in Phase 4. Storing the original array would let later writes change our earlier records.

For `writevto()`, `parts` is a list of byte sequences. `b"".join(parts)` joins their contents into one new `bytes` value. For example, joining `b"\x40"` and `bytearray([0x20, 0x00])` gives the three-byte sequence `40 20 00`. The `\x` notation writes a byte using two hex digits; these are byte values, not the characters in a hex number.

To extend a display method later, we can define that method in a subclass, do our extra work, then call `super()` to preserve the next implementation. For example, an override of `write_data(self, buf)` can count the image bytes and then call `super().write_data(buf)` to keep the transfer. We will try that in the final problem.

<hr class="lesson-review-divider">

## Homework

### Explain yourself

Explain each term before opening it. Trace `oled.text(...)` and `oled.show()` aloud: which instance is `self`, where does Python find each method, and when does a separate connection object get involved? Use one example where the buffer changes and another where a display setting changes. Draw your own small call map if it helps.

<span id="glossary"></span>

{{< reveal-controls scope="glossary" >}}
{{< recall-glossary data="phase6_glossary" >}}

### Exercises

Write your solution before opening the hints. Keep the recorder class for the last two problems. ★ Challenging · ★★ Very challenging.

{{< lesson-exercise number="5" level="4" title="Record the bytes before they change" id="q5-record-the-bytes-before-they-change" >}}

Complete this class. Each method should append one event to `self.events` and return the number of bytes recorded. Use method names `"writeto"` and `"writevto"` in the tuples. Keep the supplied `__init__()`:

```python
class RecordingI2C:
    def __init__(self):
        self.events = []

    def writeto(self, address, data):
        # Append (method name, address, an immutable byte snapshot).
        pass

    def writevto(self, address, parts):
        # Join the parts, then append an event with those bytes.
        pass
```

These checks should both print `True`. Why would storing `data` directly fail the first check?

```python
bus = RecordingI2C()
scratch = bytearray([0x80, 0xA6])
bus.writeto(0x3C, scratch)
scratch[1] = 0xA7
print(bus.events[0][2] == b"\x80\xa6")
bus.writevto(0x3C, [b"\x40", bytearray([0x20, 0x00])])
print(bus.events[1][2] == b"\x40\x20\x00")
```

Then clear the old event list with `bus.events.clear()` and construct `oled = ssd1306.SSD1306_I2C(WIDTH, HEIGHT, bus)`. Inspect the final event's method name and byte count. Why do events appear before you explicitly call `show()`?

{{< hints >}}
- A list's `append(...)` adds one event; `bytes(data)` captures the contents at that moment.
- Use `payload = b"".join(parts)` for the second method, then record and count that payload.
- Construction ends by sending a blank frame. The image-transfer prefix is not part of the image buffer.
{{< /hints >}}
{{< answer >}}
```python
class RecordingI2C:
    def __init__(self):
        self.events = []

    def writeto(self, address, data):
        self.events.append(("writeto", address, bytes(data)))
        return len(data)

    def writevto(self, address, parts):
        payload = b"".join(parts)
        self.events.append(("writevto", address, payload))
        return len(payload)
```

Run the two checks with this class: both are `True`. Keeping `scratch` itself would record a shared reference, so changing it to `80 A7` would also change the apparent earlier event.

```python
bus.events.clear()
oled = ssd1306.SSD1306_I2C(WIDTH, HEIGHT, bus)
print(len(oled.buffer))                   # 1024
print(bus.events[-1][0])                  # writevto
print(len(bus.events[-1][2]))             # 1025
```

Setup commands and one blank frame are sent during initialization. The final event contains one prefix byte plus 1,024 image bytes. Clearing `bus.events` only removes recorded history; it doesn't clear a display buffer.

**An observation is useful only if it preserves what happened at that moment.** The recorder also shows that the display's shared code can work with a different connection object, provided it offers the required methods.
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="6" level="4" title="Does inversion rewrite the picture?" difficulty="1" id="q6-does-inversion-rewrite-the-picture" >}}

Use your recorder to construct a fresh display object. Clear its buffer, light `(37, 29)`, and call `show()`. Save `before = bytes(oled.buffer)`, then clear the event history.

Predict what `oled.invert(1)` does to that snapshot comparison and the event log. Check the driver's definition: does inversion call `fill()` or `write_data()`? Then call `show()` again. Are its image bytes inverted, or identical to `before`? Which call returns the controller to normal output?

{{< hints >}}
- `SET_NORM_INV` is `0xA6`; the method ORs it with the argument's lowest bit.
- Separate a controller setting from the image bytes it interprets.
- In a recorded image transfer, the first byte is the prefix; the remaining bytes are the image.
{{< /hints >}}
{{< answer >}}
```python
bus = RecordingI2C()
oled = ssd1306.SSD1306_I2C(WIDTH, HEIGHT, bus)
oled.fill(0)
oled.pixel(37, 29, 1)
oled.show()
before = bytes(oled.buffer)
bus.events.clear()

oled.invert(1)
print(bytes(oled.buffer) == before)       # True
print(len(bus.events), bus.events[0][2])  # 1 b'\x80\xa7'

oled.show()
print(bus.events[-1][2][1:] == before)    # True
oled.invert(0)                           # Select normal output again.
```

Inversion requests one command write and no image transfer. The prepared bytes stay unchanged, including byte 421's bit 5. A later `show()` sends those same image bytes; it doesn't undo the inversion setting. `invert(0)` sends the normal-output command.

**Not every visible change is a change to pixel memory.** Our log tests the driver's requests; observing the real controller's output would be a separate hardware test.
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="7" level="4" title="Count transfers without replacing them" difficulty="2" id="q7-count-transfers-without-replacing-them" >}}

Write `CountingOLED`, a subclass of `ssd1306.SSD1306_I2C`. Keep `frames` and `image_bytes` as instance attributes. Count each call to `write_data()` and the length of its image buffer, then preserve the inherited transfer behavior.

Start here. Decide where to initialize the counters and where to use `super()`:

```python
class CountingOLED(ssd1306.SSD1306_I2C):
    def __init__(self, width, height, bus):
        # Set up the counters and initialize the display.
        pass

    def write_data(self, buf):
        # Update the counters and keep the real transfer behavior.
        pass
```

Predict both lines before running these checks. Include any work performed during construction:

```python
bus = RecordingI2C()
screen = CountingOLED(128, 64, bus)
print(screen.frames, screen.image_bytes)
for x in (0, 8, 16):
    screen.fill(0)
    screen.pixel(x, 0, 1)
    screen.show()
print(screen.frames, screen.image_bytes)
```

Check the recorder too: it should contain four `"writevto"` events. Why would correct counters alone be insufficient evidence? Finally, predict the totals if only the height changed to 32.

{{< hints >}}
- Initialization calls `show()`, which reaches your overridden `write_data()`.
- Set both counters before calling `super().__init__(...)`.
- Call `super().write_data(buf)` after counting. Count image bytes, excluding the transport prefix.
{{< /hints >}}
{{< answer >}}
```python
class CountingOLED(ssd1306.SSD1306_I2C):
    def __init__(self, width, height, bus):
        self.frames = 0
        self.image_bytes = 0
        super().__init__(width, height, bus)

    def write_data(self, buf):
        self.frames += 1
        self.image_bytes += len(buf)
        super().write_data(buf)
```

The checks print `1 1024`, then `4 4096`. One blank frame is sent during setup, followed by the three explicit frames. At height 32, they instead print `1 512`, then `4 2048`.

Each of those four transfers must also reach the recorder. Forgetting `super().write_data(buf)` could make the counters look right while silently removing the transport operation. The inherited `show()` still works: its `self.write_data(...)` now reaches our counting method first, on the same instance.

**An override can add behavior and delegate the existing work.** We can investigate a working driver without copying or rewriting its entire implementation.
{{< /answer >}}
{{< /lesson-exercise >}}

## What's next {#next-ic-communication}

You can now trace a drawing call into memory, a `show()` call into a transfer, and a setting change into command writes. We still owe those transport bytes an explanation: **what are the address and prefix bytes for, and how do SDA and SCL carry them?** That's the next phase, I²C Communication. Later we'll use the controller's datasheet to explain the initialization values, then build our own small driver.

Phase 7 is planned. Until then, use your recorder to compare `contrast()`, `poweroff()`, and `poweron()`: predict the number of command and image transfers, then inspect the code and log.

[Back to Phase 5 ←](/post/drawing-graphics/) · [Project roadmap](/post/pico-oled-project/)

Source notes: excerpts and experiments use the [driver supplied in our kit](/downloads/pico/phase-1-kit/ssd1306.py), distributed with its [MIT license](/downloads/pico/phase-1-kit/LICENSE.txt). For more detail, see [MicroPython's FrameBuffer reference](https://docs.micropython.org/en/v1.26.0/library/framebuf.html), the [upstream SSD1306 driver](https://github.com/micropython/micropython-lib/blob/master/micropython/drivers/display/ssd1306/ssd1306.py), and Python's explanations of [classes and inheritance](https://docs.python.org/3/tutorial/classes.html#inheritance) and [`super()`](https://docs.python.org/3/library/functions.html#super).
