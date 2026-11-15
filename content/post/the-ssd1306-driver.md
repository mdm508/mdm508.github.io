---
title: "Phase 6: The SSD1306 Driver — Follow the Method Calls"
date: 2026-11-14T00:00:00-08:00
draft: false
description: "Read the real OLED driver, follow inherited methods and initialization, and use a recording connection to investigate commands and image transfers."
summary: "Find where drawing methods come from, trace show() through the driver, and test its behavior with a recording I²C stand-in."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "classes"]
reading_time: 90
toc_depth: 3
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/pico-oled-project/">Pico OLED project: guide and lesson roadmap</a>. Previously: <a href="/post/drawing-graphics/">Phase 5: Drawing Graphics</a>.</aside>

Open `ssd1306.py` and search for `def text`. Nothing! Yet `oled.text("Hi Yush", 0, 0)` has worked all along. **Where did that method come from?** Today we'll follow the calls behind familiar commands. By the end, you'll be able to follow those calls on one display object and explain when it uses a separate connection object. We'll use a recorder to check our reasoning.

## What You Will Be Able to Do

- Explain a class, an instance, `self`, and inherited methods using code you can trace.
- Follow the driver's setup and explain why its order matters.
- Separate drawing, OLED commands, and image transfers by finding their definitions.
- Use recorded transfers to check a prediction and explain which code can be reused with another connection.

## Get Ready

{{< download "/downloads/pico/phase-6-driver-lab.py?v=2" "Download the Phase 6 driver lab" >}}. Only imports, dimensions, and a readiness message run; Q5 will create `oled` using the recorder. Keep the [Phase 1 kit's `ssd1306.py`](/downloads/pico/phase-1-kit/ssd1306.py) in the **same folder on the Pico**. Open that file beside the lab so you can search its definitions. Keep the borrowed driver unchanged; write experiments in your lab file.

Run the whole lab file through Thonny or MicroPico in VS Code. Keep any class a later question uses, and replace earlier experiment code. No `input()` pauses or preserved Python session are needed.

**An OLED connection is optional today.** Our final experiments replace the physical connection with a recorder. They still need MicroPython, such as on your Pico, because `framebuf` is built into that runtime. Ordinary desktop Python can run the small `TinyDisplay` example below in a separate file; importing this driver there usually fails because `framebuf` is missing. Without a Pico, use the browser trace and work through the source on paper.

We'll read the exact driver supplied in the kit. Other versions may arrange their code differently. The detailed meaning of controller settings and I²C control bytes comes in the next phases; today's job is to follow who calls whom. The final subclass-writing challenge is an optional extension.

<span id="a-small-class-you-can-follow"></span>

## Put a Buffer and a Method Together

In Phase 3, we stored a picture in a `bytearray`. Let's give a tiny picture its own storage and an operation for changing it. Our toy is **8 columns × 8 rows**: one page, with eight vertical pixels in each column byte.

A **class** defines a kind of object and its methods. An **instance** is one object made from that class. Calling the class creates an instance; its `__init__()` method sets up its starting state:

```python
class TinyDisplay:
    def __init__(self):
        self.buffer = bytearray(8)

    def set_column(self, x, value):
        self.buffer[x] = value

toy = TinyDisplay()
toy.set_column(2, 0b01000000)
print(toy.buffer[2])  # 64
```

This little class only changes memory; it doesn't communicate with hardware. `set_column()` replaces one column's eight pixel states, just like sending a byte to the Phase 3 toy. Here it lights bit 6 in column 2, which represents pixel `(2, 6)` in our one-page picture.

`self.buffer` is an **attribute**: data belonging to that particular object. In `toy.set_column(2, 64)`, Python supplies `toy` as the first argument, `self`. We supply `x` and `value`. **`self` means the instance receiving the call.** Its buffer remains available after the method returns.

<span id="q1-which-label-changes"></span>

{{< lesson-exercise number="1" title="Which picture changes?" id="q1-which-picture-changes" >}}

Keep the `TinyDisplay` class definition, replacing the earlier example calls with this code. Predict the two numbers, then run it:

```python
first = TinyDisplay()
second = TinyDisplay()
first.set_column(2, 0b01000000)
print(first.buffer[2], second.buffer[2])
```

Which object is `self` inside this call to `set_column()`? If we rename the variable `first` to `picture`, must we change the class too?

{{< hints >}}
- Each call to `TinyDisplay()` runs the initializer and allocates a new buffer.
- The object before `.set_column(...)` becomes that call's `self`.
{{< /hints >}}
{{< answer >}}
The output is `64 0`. The first picture has bit 6 lit in column 2; the second picture is still blank. During `first.set_column(...)`, `self` refers to the first display object.

Renaming the outside variable doesn't require changing the class. The method uses its `self` parameter, rather than a particular outside variable name.

**Methods can share code while instances keep separate pictures.** In the real driver, `self.buffer` belongs to the particular display object receiving the call.
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

We will keep two questions separate:

- **Which object receives the call?** Follow the expression before the dot.
- **Which class defines the method?** Follow the class headers to find the code.

A method defined in `SSD1306` can still run on an `SSD1306_I2C` instance. Its `self` is that same display object.

<span id="trace-a-call-through-the-driver"></span>

## Trace Drawing, Then Showing

Start with `text()` in the guided trace. Make a prediction before revealing each explanation. Then trace `show()`, paying attention to the moment the call reaches the separate connection object. Other calls become available afterward; return to them after reading setup and settings below. This is a source-reading model; Q5 will test our predictions against the actual driver.

{{< driver-call-trace >}}

The important handoff in `show()` looks like this:

```text
oled.show()                      receiver: oled; definition: SSD1306
  → self.write_data(self.buffer)  same oled; definition: SSD1306_I2C
    → self.i2c.writevto(...)      receiver: the separate connection object
```

**Changing the class where we find the code does not change `self`.** Only the final line selects another object, through `self.i2c`.

## Read show() as a Recipe

Now open `SSD1306.show()` in the source. For our 128-column display, it selects a column range and a page range, then calls `self.write_data(self.buffer)`. The range ends are **inclusive**, just like the endpoints you counted in Phase 5.

| Purpose for 128 × 64 | Values passed to `write_cmd()` |
| --- | --- |
| Select columns 0–127 | `0x21`, `0`, `127` |
| Select pages 0–7 | `0x22`, `0`, `7` |

These are six separate calls to `write_cmd()`, followed by **one** `write_data(self.buffer)` call. A command and its parameter bytes share that writer; not every value in the table is a new instruction.

<span id="q4-same-width-half-the-height"></span>

For a **128 × 32** display, the same code gives `32 // 8 = 4` pages, numbered 0–3, and `4 * 128 = 512` image bytes. The final page value becomes 3. Two explicit `show()` calls would send `2 * 512 = 1024` image bytes, even if only ten pixels changed. Dimensions determine the ranges and full-buffer transfer size.

The I²C image writer combines `b"\x40"` with the buffer. That prefix is one byte with value `0x40`, separate from the image bytes. Phase 7 will unpack this control information and the device address.

{{< lesson-exercise number="2" title="Can write_data() replace show()?" id="q2-find-the-definition-then-the-destination" >}}

A friend says that these calls do the same job because both send `oled.buffer`:

```python
oled.write_data(oled.buffer)
oled.show()
```

Use the source to explain what the first call skips. Which class defines each method? Is `self` a different object when execution moves between those definitions?

{{< hints >}}
- Read the statements before `self.write_data(self.buffer)` inside `show()`.
- Finding inherited code does not construct another object.
{{< /hints >}}
{{< answer >}}
`write_data()` is defined in `SSD1306_I2C`; it passes the supplied image bytes to the connection. `show()` is defined in `SSD1306`; it first sends the destination-range values, then calls that same `write_data()` method.

Use `show()` in our normal drawing programs. Calling `write_data()` alone skips the range setup, so we cannot assume the controller is positioned correctly.

Both methods run on the **same `oled` instance**. The separate connection object receives the later `self.i2c.writevto(...)` call.

**A method's responsibility includes its preparation, not just its last operation.** Following the complete call explains why our application uses `show()`.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="follow-setup-on-the-same-instance"></span>

## Follow a Successful Setup First

The lab uses `import ssd1306`, so we reach the class as `ssd1306.SSD1306_I2C`. Earlier lessons imported the class name directly; both forms reach the same class in `ssd1306.py`.

Our familiar construction call is:

```python
oled = ssd1306.SSD1306_I2C(128, 64, i2c)
```

Here `i2c` must already refer to a connection object. A new display instance is initialized before the result is assigned to `oled`. Follow that same instance through setup:

1. **`SSD1306_I2C.__init__()`** stores the connection, address, and temporary transfer storage, including `self.temp = bytearray(2)`.
2. It calls **`super().__init__(...)`**. In this chain, that continues into `SSD1306.__init__()` on the same new instance.
3. **`SSD1306.__init__()`** stores dimensions, calculates eight pages, and allocates one 1,024-byte buffer. Its next `super().__init__(...)` reaches `FrameBuffer`, connecting drawing operations to that storage.
4. Back in **`SSD1306.__init__()`**, `self.init_display()` sends the controller's setup values. It finishes with `self.fill(0)` and `self.show()`, sending a blank frame.
5. The initialization calls return, and the construction result is assigned to **`oled`**.

**`super()` continues to the next class in the chain; it does not create another display object.** There is one instance throughout those steps.

Look more closely at the first setup command inside step 4:

```text
init_display() is defined in SSD1306
  → self.write_cmd(cmd)
    → find write_cmd in SSD1306_I2C
      → use self.temp, then self.i2c.writeto(...)
```

Method lookup still starts with the actual instance's class, even while base-class code is running. That is how `SSD1306` can use the transport writer supplied by `SSD1306_I2C`.

You can now return to the trace and choose **construction**. Explain why the temporary transfer storage is already ready before that first command runs.

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

## Why Split the Driver This Way?

The file also contains `SSD1306_SPI`, for another serial connection called SPI. Compare its class header and writer method names with those in `SSD1306_I2C`. Both classes build on `SSD1306`, which builds on `FrameBuffer`.

{{< lesson-exercise number="4" title="Change the connection, keep the picture" id="q4-change-the-connection-keep-the-picture" >}}

Suppose we use a compatible SSD1306 display with an SPI connection. You don't need to know SPI's wiring rules for this question.

Which parts can we reuse: drawing methods, buffer layout, the `show()` recipe, or the two transport writers? Explain which code is shared and which needs a connection-specific implementation. After changing how we construct `oled`, could our existing `text()`, `rect()`, and `show()` application calls stay the same?

{{< hints >}}
- Compare the base-class names in the two transport class headers.
- Find `write_cmd()` and `write_data()` inside each transport class.
- `show()` asks those writers to do the sending; it doesn't operate the connection directly.
{{< /hints >}}
{{< answer >}}
Both transport classes reuse the drawing methods from `FrameBuffer` and the buffer allocation, initialization recipe, and `show()` from `SSD1306`.

The transport-specific `write_cmd()` and `write_data()` implementations change. The SPI version also sets up its own connection and control pins. The method names provide the common interface the base code uses.

Once `oled` is constructed appropriately for that hardware, our existing drawing and `show()` calls can stay the same. This driver's pixel layout belongs to its shared frame-buffer setup; it isn't a consequence of choosing I²C.

**Separating responsibilities lets us change how a picture travels without rewriting how we draw it.** This is the reason for the class structure, beyond knowing the names of its parts.
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

<span id="build-an-observation-point"></span>

## Observe the Calls with a Recorder

How can we test our predictions without relying on a quick flash on the screen? The I²C subclass only needs its connection object to provide `writeto(address, data)` and `writevto(address, parts)`. We'll use a small **recording connection** that logs those requests instead of sending them to hardware.

The class is supplied in Q5. Your task is to repair one recording line, not invent all of its connection code. It stores each event as:

```text
(method name, destination address, snapshot of the bytes)
```

This is a **test double**: a stand-in with the operations our driver needs. Its log tells us what the driver requested. It doesn't test the physical cable, bus, or OLED.

Two byte operations will help you read it:

- `bytes(data)` captures the current contents of a mutable array as an immutable snapshot, like the frame copies in Phase 4.
- `b"".join(parts)` joins a list of byte sequences into one new `bytes` value. The recorder's `writevto()` implementation already does this for you.

For example, joining the prefix `b"\x40"` and `bytearray([0x20, 0x00])` gives three bytes: `40 20 00` in hex. The `\x` notation writes one byte with two hex digits; it doesn't store the printed characters of that number.

<hr class="lesson-review-divider">

## Homework

### Explain yourself

Explain each term before opening it. Trace `oled.text(...)` and `oled.show()` aloud: which instance is `self`, where does Python find each method, and when does a separate connection object get involved? Use one example where the buffer changes and another where a display setting changes. Draw your own small call map if it helps. The overriding term is for the optional final challenge.

<span id="glossary"></span>

{{< reveal-controls scope="glossary" >}}
{{< recall-glossary data="phase6_glossary" >}}

### Exercises

Keep your repaired recorder for Q6. Q7 is an optional extension for students who want to write a subclass. ★ Challenging · ★★ Very challenging.

{{< lesson-exercise number="5" level="4" title="Repair the recorder's memory" id="q5-record-the-bytes-before-they-change" >}}

This recording connection is almost ready. **One line stores a shared reference where the log needs a snapshot.** Predict what the checks will print before changing it, then repair that line so both checks print `True`:

```python
class RecordingI2C:
    def __init__(self):
        self.events = []

    def writeto(self, address, data):
        self.events.append(("writeto", address, data))  # Repair this record.
        return len(data)

    def writevto(self, address, parts):
        payload = b"".join(parts)
        self.events.append(("writevto", address, payload))
        return len(payload)
```

```python
bus = RecordingI2C()
scratch = bytearray([0x80, 0xA6])
bus.writeto(0x3C, scratch)
scratch[1] = 0xA7
print(bus.events[0][2] == b"\x80\xa6")
bus.writevto(0x3C, [b"\x40", bytearray([0x20, 0x00])])
print(bus.events[1][2] == b"\x40\x20\x00")
```

Why does the bug matter for this driver? Look at how its `write_cmd()` method reuses `self.temp`.

After the repair, clear the old log with `bus.events.clear()` and construct `oled = ssd1306.SSD1306_I2C(WIDTH, HEIGHT, bus)`. Inspect the final event's method name and byte count. Explain why the log already includes an image transfer.

{{< hints >}}
- Before the repair, the first event refers to the same mutable array as `scratch`.
- Capture the contents when the write happens, using `bytes(data)`.
- Construction sends a blank frame. Its transport prefix is separate from the image bytes.
{{< /hints >}}
{{< answer >}}
Before repair the checks print `False`, then `True`. The second method already creates an immutable byte value with `join()`.

Replace the recording line in `writeto()` with:

```python
self.events.append(("writeto", address, bytes(data)))
```

The complete repaired class is:

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

Now both checks print `True`. Keeping `scratch` itself lets a later change alter the apparent earlier event. The real driver reuses `self.temp` for successive command writes, so that bug would make the command history unreliable.

```python
bus.events.clear()
oled = ssd1306.SSD1306_I2C(WIDTH, HEIGHT, bus)
print(len(oled.buffer))                   # 1024
print(bus.events[-1][0])                  # writevto
print(len(bus.events[-1][2]))             # 1025
```

Initialization sends a blank frame: one prefix byte plus 1,024 image bytes. Clearing the log removes recorded history, not the display buffer.

**A useful record preserves what happened at that moment.** A shared reference to changing data cannot do that job.
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

Before the optional challenge: an **override** is a subclass's replacement for a method supplied by its base class. It can add work and then delegate the existing work with `super()`. For example, inside an override of `write_data(self, buf)`, `super().write_data(buf)` continues to the inherited transfer implementation on the same instance.

{{< lesson-exercise number="7" level="4" title="Optional: count transfers without replacing them" difficulty="2" id="q7-count-transfers-without-replacing-them" >}}

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
