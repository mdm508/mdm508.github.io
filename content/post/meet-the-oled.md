---
title: "Phase 1: Meet the OLED — Pixels, Coordinates, and show()"
date: 2026-08-16T13:00:00-07:00
draft: false
description: "Get your own words onto a Pico OLED, meet the objects that make it work, explore coordinates, and discover why drawing and showing are separate steps."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics"]
summary: "Put your own message on an OLED, explore a magnified pixel grid, and learn the roles of the display object, I2C connection, driver, and show()."
reading_time: 120
toc_depth: 3
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/pico-oled-project/">Pico OLED project: guide and lesson roadmap</a>. New to the board? Meet the <a href="/post/raspberry-pi-pico-wh/">Raspberry Pi Pico WH</a> first.</aside>

Today, we're going to put **your words on a real screen**. By the end, you'll have a small display you can clear, draw on, and arrange deliberately. You'll finish with three challenges that put the ideas together.

We're borrowing a driver written by other programmers to get started. You can use it before understanding every detail inside it. Over the coming phases, we'll investigate those details until we can build a small driver ourselves. Today's job is to get something working and understand the main players.

## What You Will Be Able to Do

By the end of this lesson, you should be able to:

- Get a short message onto the OLED and change it yourself.
- Explain the jobs of `oled`, `i2c`, the driver, and the physical display.
- Use `(x, y)` coordinates to place pixels and text inside a 128 × 64 screen.
- Explain why drawing a picture and sending it with `show()` are separate steps.

**Take your time and try each problem before opening its answer.** Predict, try it, and compare the result with your prediction. If you need a solution, return later and try the problem again with the answer closed.

## Get Ready

Connect the display using either the [labelled UPS board or breadboard route in the project guide](/post/pico-oled-project/#wire-the-pico-and-oled). Both use these connections:

| OLED | Pico | Job |
| --- | --- | --- |
| VCC | 3V3(OUT) | Power for the display. |
| GND | GND | Shared electrical reference and return path. |
| SDA | GP0 | Data exchanged between the devices. |
| SCL | GP1 | Clock signal that times the exchange. |

Unplug USB and disconnect any battery power before changing wires. Match the printed labels on your boards; their left-to-right order can vary.

{{< download "/downloads/pico/phase-1-kit.zip" "Download the Phase 1 kit (ZIP)" >}}. Extract it on your computer. It contains `main.py`, the official MicroPython `ssd1306.py` driver, a README, and the driver's license. Keep **both Python files together on the Pico**. The driver being on your laptop alone is not enough.

Use [Thonny or VS Code with MicroPico](/post/raspberry-pi-pico-wh/#choose-an-editor-thonny-or-vs-code) to run code **on the Pico**. Only connection setup runs in the starter; you'll add the drawing code as you follow the lesson. Edit the file and rerun the whole file for each experiment.

## First, Make Contact {#establish-ic-communication}

The Pico and OLED need a way to exchange information. **I²C**, pronounced “eye-squared-see,” is the communication method we use. SDA carries data; SCL supplies timing. Power makes the display able to work; these signals tell it what to do.

Our variable `i2c` will refer to a Python object that controls that connection. The starter contains:

```python
from machine import Pin, I2C
from ssd1306 import SSD1306_I2C

i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=200_000)
print("I2C devices:", i2c.scan())
```

The first import gets MicroPython's pin and communication tools. The second imports the display type supplied by our driver. The `I2C(...)` line chooses communication controller **I2C0**, puts SCL on **GP1** and SDA on **GP0**, and requests a 200,000 Hz clock. Keep those settings for our wiring.

Run the starter. With our OLED connected, the output should usually include:

```text
I2C devices: [60]
```

`scan()` asks which device addresses answer. Here, `60` is the display's address—the number used to identify it during communication. It is also written `0x3C`; we'll learn that number notation in Phase 2. An empty list, `[]`, means no device answered. Check the power, connections, and pin settings before continuing if you get an empty list or a communication error.

The OLED can still be blank at this point. **Finding a device and drawing a message are different jobs.**

## Your First Text

Now create a display object and give it the name `oled`. Give it the screen's width and height, and the connection it should use:

```python
oled = SSD1306_I2C(128, 64, i2c)
```

Add that line below the connection setup in `main.py`, followed by:

```python
oled.fill(0)
oled.text("Hi Yush", 0, 0)
oled.text("Pico WH", 0, 16)
oled.show()
```

`fill(0)` clears the picture we are preparing. Each `text()` adds a message at a position. Finally, `show()` sends the prepared picture to the OLED.

Run the whole file. You should see Hi Yush near the top and Pico WH below it. That small message is our first working connection from Python to a physical screen.

For later experiments, **replace the previous drawing commands** unless a problem asks you to append code. Keep the imports, connection setup, and `oled = SSD1306_I2C(...)` line above them.

{{< lesson-exercise number="1" title="Make it yours" id="q1-can-you-make-it-your-screen" >}}

Change Yush to your own name or a short nickname in the greeting. Keep the other message and both positions unchanged. Run the whole file and check that only the part you intended changed.

{{< hints >}}
- Change the string in the first `text()` call.
- Keep the quotation marks and the final `show()`.
{{< /hints >}}

{{< answer >}}
For example, replace the first `text()` call with:

```python
oled.text("Hi Ada", 0, 0)
```

The top message changes; Pico WH stays in the same place. The connection setup stays the same too.

**You control the content by changing the data passed to a drawing call.**
{{< /answer >}}

{{< /lesson-exercise >}}

## Who Does What?

**The OLED is the physical screen; `oled` names a Python object we use to control it.** That object lives in the Pico's memory. It holds the picture we are preparing and offers operations such as `text()`, `fill()`, and `show()`. An operation called through an object is a **method**: in `oled.text("Hi Yush", 0, 0)`, `oled` names the object, `text` is the method, and the values in parentheses tell it what to draw and where.

We need `i2c` because the screen is a separate device connected by wires. The `i2c` object manages that communication. The **driver**, imported from `ssd1306.py`, knows how to use the connection to talk to this particular display's SSD1306 controller chip. You choose the picture; the driver translates display operations into the commands and data the chip needs.

Trace these lines from our program. Before selecting each one, describe its job in your own words.

{{< oled-code-guide >}}

Notice that `i2c` is passed into `SSD1306_I2C(...)`. That is how the display object gets its connection. We will open the borrowed driver in a later phase; for now, we can use its methods and investigate their effects.

{{< lesson-exercise number="2" title="Does the name control the hardware?" id="q2-does-the-name-control-the-hardware" >}}

A friend prefers the name `screen` and writes this below the existing connection setup:

```python
screen = SSD1306_I2C(128, 64, i2c)
screen.fill(0)
oled.text("HI", 0, 0)
screen.show()
```

Read this as a program with no earlier `oled` variable. Find the inconsistent name and repair the code. Would renaming the object require changing the wires or replacing `i2c` too? Explain your answer.

To test your repair, replace the earlier `oled = ...` line and drawing commands with your corrected block, keeping the imports and connection setup. Use the name `oled` again after this experiment.

{{< hints >}}
- Which name receives the object created on the first line?
- Follow the name before each dot. The connection is a separate object passed into `SSD1306_I2C(...)`.
{{< /hints >}}

{{< answer >}}
Replace the third line with:

```python
screen.text("HI", 0, 0)
```

All three method calls now use `screen`. The name `oled` was never assigned in this fresh run, so using it would cause a `NameError`. No wires need to move, and `i2c` still refers to the same connection object.

**A variable name is our way to refer to an object; it is not a hardware setting.**
{{< /answer >}}

{{< /lesson-exercise >}}

If a later scan returns `[]`, changing the message or the variable name will not restore the connection. Check power, wiring, and the selected pins first. A missing Python name and a device that does not answer are different clues.

## Explore the Screen as a Grid

A **pixel** is one individually controlled point. Our display has **128 columns and 64 rows**, called its resolution. That makes `128 × 64 = 8,192` pixel positions.

We locate a pixel with two coordinates, `(x, y)`:

- The top-left pixel is `(0, 0)`.
- Increasing `x` moves right; increasing `y` moves down.
- Columns run from **0 to 127**, and rows from **0 to 63**. Counting starts at zero, so the last coordinate is one less than the number of positions.

Our picture is **monochrome**: each pixel is either lit (`1`) or dark (`0`). To light the pixel at `(8, 4)` on a blank picture:

```python
oled.fill(0)
oled.pixel(8, 4, 1)
oled.show()
```

This replaces the drawing part of your file; keep the connection setup and `oled = ...` line above it. The position is eight steps right and four steps down from the top-left pixel.

Individual pixels are tiny on the real OLED. Use this magnified model to explore their positions:

{{< oled-coordinate-lab >}}

{{< lesson-exercise number="3" title="Find the edge, then move inward" id="q3-find-the-edge-then-move-inward" >}}

{{< exercise-step "predict" >}}
A friend calls `(128, 64)` the bottom-right pixel. Write down the correct coordinate. From that pixel, move one column left and two rows up. Where do you land?
{{< /exercise-step >}}

{{< exercise-step "try" >}}
Check the two positions one at a time in the toy. Then display both pixels together on the Pico, clearing first and showing once at the end.
{{< /exercise-step >}}

{{< exercise-step "explain" >}}
Why is the last row numbered 63 rather than 64? Starting from that row, how many steps take you to row 61?
{{< /exercise-step >}}

{{< hints >}}
- A width of 128 gives 128 positions numbered from zero. Apply the same reasoning to the height.
- Start the movement from the last valid coordinate. Left decreases `x`; up decreases `y`.
{{< /hints >}}

{{< answer >}}
The bottom-right pixel is `(128 - 1, 64 - 1) = (127, 63)`. Moving inward gives `(127 - 1, 63 - 2) = (126, 61)`.

```python
oled.fill(0)
oled.pixel(127, 63, 1)
oled.pixel(126, 61, 1)
oled.show()
```

**A size counts positions; movement counts steps between positions.** The edge calculation accounts for numbering from zero. The movement calculation changes an existing coordinate.
{{< /answer >}}

{{< /lesson-exercise >}}

## Give Text a Starting Position

Text uses the same coordinates, but a letter occupies a group of pixels. The `(x, y)` in `text()` locates the **top-left of the text area**. The visible strokes can leave some blank space inside that area.

For example, `oled.text("HI", 64, 32)` starts the text area near the screen's center and extends right and down. It does not center the word. Changing only `x` to 0 moves the word left while keeping its vertical position. You can compare those two placements in your file. We will calculate character sizes and text layouts in Phase 5.

## Drawing Can Add or Remove Pixels

We have used `1` to light a pixel. Passing `0` to `pixel()` darkens that one pixel. By comparison, `fill(0)` darkens the entire prepared picture:

```python
oled.pixel(10, 10, 0)  # Darken one position.
oled.fill(0)           # Darken every position.
```

Choose the operation to match how much you want to change. Neither call sends the changed picture to the screen by itself.

## Draw First, Show Second

The image we prepare in the Pico's memory is called a **frame buffer**. Calling `fill()`, `pixel()`, or `text()` changes that image. Calling `show()` sends it to the physical OLED. The OLED can keep showing its previous image while we prepare the next one.

Order matters inside the prepared picture too. If we draw a message and then call `fill(0)`, we erase that message before it is sent. A useful pattern is **clear → draw every part → show the finished picture**.

{{< lesson-exercise number="4" title="What picture did we actually send?" id="q4-what-picture-did-we-actually-send" >}}

Keep the setup and display-object creation above this drawing block:

```python
oled.fill(0)
oled.show()
oled.text("TEST", 0, 0)
oled.pixel(40, 20, 1)
```

{{< exercise-step "predict" >}}
After the file finishes, what is on the physical screen? What picture is prepared in Pico memory?
{{< /exercise-step >}}

{{< exercise-step "try" >}}
Run it. Then move just one existing line so the greeting and dot appear together. Keep exactly one `show()` in this drawing block.
{{< /exercise-step >}}

{{< exercise-step "explain" >}}
Why would moving `fill(0)` to the end give a different result from moving `show()` to the end?
{{< /exercise-step >}}

{{< hints >}}
- At the moment the original code calls `show()`, the prepared picture is blank.
- Send the picture after drawing both parts. Clearing after drawing would erase them.
{{< /hints >}}

{{< answer >}}
The original leaves the physical screen blank, with TEST and a dot prepared in memory. Move `show()` to the end:

```python
oled.fill(0)
oled.text("TEST", 0, 0)
oled.pixel(40, 20, 1)
oled.show()
```

A final `fill(0)` would clear the prepared picture; it would not send it. If placed just before `show()`, it would make us send a blank picture.

**Drawing changes what is prepared; showing changes what is displayed.** Follow those two pictures separately when reading a program.
{{< /answer >}}

{{< /lesson-exercise >}}

<hr class="lesson-review-divider" id="what-we-understandand-what-comes-next">

## Homework

### Explain yourself {#explain-yourself}

<span id="glossary"></span>

With the lesson closed, explain these terms to yourself or someone else. Give examples, make connections, and try a sketch or analogy. How do **coordinates** relate to **pixels**? How does the **driver** use **I²C** to get a picture onto the screen?

Select a term to check its meaning. **Revisit anything unclear, then hide the definitions and try again later.**

{{< reveal-controls scope="glossary" >}}

{{< recall-glossary >}}

### Exercises

<span id="make-a-screen-of-your-own"></span>

Close the earlier examples and write your own drawing code below setup. These challenges combine the ideas you have learned; you choose the steps. Try them before opening the hints or answers, and check the result on your Pico.

★ Challenging · ★★ Very challenging.

{{< lesson-exercise number="5" level="4" title="Design a welcome screen" id="q5-design-a-welcome-screen" >}}

Create a screen with your name or nickname, two other short messages on separate lines, and a lit pixel in each of the four corners. Choose positions that keep the messages visible and apart. Clear once at the start and call `show()` once after drawing everything.

{{< hints >}}
- Sketch the layout first. Short messages starting at `(8, 8)`, `(8, 24)`, and `(8, 48)` leave space between lines.
- Combine the first and last valid coordinates to find the four corners.
{{< /hints >}}

{{< answer >}}
One possible design is:

```python
oled.fill(0)
oled.text("Hi Yush", 8, 8)
oled.text("READY!", 8, 24)
oled.text("MY PICO", 8, 48)
oled.pixel(0, 0, 1)
oled.pixel(127, 0, 1)
oled.pixel(0, 63, 1)
oled.pixel(127, 63, 1)
oled.show()
```

Your wording and layout can differ. Check each message and all four corners on the screen; revise anything that overlaps or disappears.

**A complete picture is built from smaller drawing operations that share one coordinate system.**
{{< /answer >}}

{{< /lesson-exercise >}}

{{< lesson-exercise number="6" level="4" title="Move the marker, keep the message" difficulty="1" id="q6-move-the-marker-keep-the-message" >}}

Start with this working drawing block:

```python
oled.fill(0)
oled.text("MAP", 0, 0)
oled.pixel(20, 12, 1)
oled.show()
```

Append code that moves the dot seven columns right and three rows down, leaving MAP unchanged and no dot at the old position. After the block above, use only `pixel()` calls and one more `show()`. Do not redraw the text or clear the whole picture.

{{< hints >}}
- Calculate the new coordinate before writing the calls.
- Drawing a second dot does not erase the first. Change the old pixel to 0 and the new one to 1.
- Finish both edits before sending the updated picture.
{{< /hints >}}

{{< answer >}}
The new position is `(20 + 7, 12 + 3) = (27, 15)`. Append:

```python
oled.pixel(20, 12, 0)
oled.pixel(27, 15, 1)
oled.show()
```

The display object still holds the picture drawn earlier, including MAP. These calls edit only two positions. The two transfers may happen too quickly to see the original dot pause, so judge the final picture: MAP and exactly one dot at the new position.

**An update can preserve most of a picture. Moving something requires removing its old appearance as well as drawing its new one.**
{{< /answer >}}

{{< /lesson-exercise >}}

{{< lesson-exercise number="7" level="4" title="Leave two different pictures" difficulty="2" id="q7-leave-two-different-pictures" >}}

Write a drawing block that finishes with both of these conditions true:

- The physical OLED shows GO at `(8, 24)` and a lit pixel at `(127, 63)`.
- The picture prepared in Pico memory contains only NEXT at `(0, 0)`, with that corner pixel dark.

Use exactly **one `show()` call in your drawing block**. No pauses, loops, or changes to setup are needed. Before running, explain how your sequence produces both results. How could one final line let you check the second picture afterward?

{{< hints >}}
- Prepare and send the GO picture first.
- After sending, clear the prepared picture and draw NEXT. Clearing in memory does not clear the physical screen immediately.
- Stop without sending again. Think about what appending `show()` would reveal.
{{< /hints >}}

{{< answer >}}
```python
oled.fill(0)
oled.text("GO", 8, 24)
oled.pixel(127, 63, 1)
oled.show()
oled.fill(0)
oled.text("NEXT", 0, 0)
```

| After this operation | Prepared in Pico memory | Displayed on the OLED |
| --- | --- | --- |
| First `show()` | GO and the corner dot | GO and the corner dot |
| Second `fill(0)` | Blank | GO and the corner dot |
| Final `text()` | NEXT only | GO and the corner dot |

To check the second picture, append `oled.show()` and rerun the whole file. This time, NEXT should replace GO and the corner dot should disappear.

**The prepared image and the displayed image are separate pieces of state.** This is how we can build a new picture while the previous one remains visible—the starting point for animation in later phases.
{{< /answer >}}

{{< /lesson-exercise >}}

## What's next {#what-comes-next}

You can now choose what to draw, where to put it, and when to display it. Next we'll investigate the numbers behind that picture, working toward understanding and rebuilding the borrowed driver.

Next question: **how can a collection of numbers represent the picture you just made?**

[Continue to Phase 2: Pictures as Data →](/post/pictures-as-data/) · [Return to the project roadmap](/post/pico-oled-project/)

For reference: [MicroPython I²C](https://docs.micropython.org/en/v1.26.0/library/machine.I2C.html), [drawing and text](https://docs.micropython.org/en/v1.26.0/library/framebuf.html), and the [driver source included in our kit](https://github.com/micropython/micropython-lib/blob/a08087249fda8a7994f7c54ccaad29fb9fcc448a/micropython/drivers/display/ssd1306/ssd1306.py).
