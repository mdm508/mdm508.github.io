---
title: "Meet the OLED: Pixels, Coordinates, and show()"
date: 2026-08-16T13:00:00-07:00
draft: false
description: "Connect a Raspberry Pi Pico to an SSD1306 OLED, locate pixels and text, and learn why drawing and displaying are separate steps."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics"]
summary: "Use a Pico and SSD1306 OLED to learn I2C wiring, screen coordinates, drawing commands, and the frame buffer behind show()."
reading_time: 120
---

A small OLED gives Python a physical result you can see. It also makes several abstract ideas concrete: a program can depend on hardware, a screen is a grid of numbered positions, and drawing a picture is not the same as displaying it.

> How can a Python program tell a physical screen exactly what and where to display?

We will use a Raspberry Pi Pico and a 128 × 64 SSD1306 OLED. The driver file, `ssd1306.py`, should already be installed on the Pico. We will use it without opening it yet. Understanding what a tool accomplishes often comes before understanding its implementation.

Start with this program in `main.py`:

```python
from machine import Pin, I2C
from ssd1306 import SSD1306_I2C

# The OLED is already connected:
# GP0 -- SDA
# GP1 -- SCL
# 3V3 -- VCC
# GND -- GND

i2c = I2C(
    0,
    scl=Pin(1),
    sda=Pin(0),
    freq=200_000,
)

print("I2C devices:", i2c.scan())

oled = SSD1306_I2C(128, 64, i2c)

oled.fill(0)
oled.text("Hello, yush", 0, 0)
oled.text("Pico WH", 0, 16)
oled.show()
```

## Connect the Hardware

### Q1: What do GND, VCC, SCL, and SDA do?

{{< answer >}}
`VCC` supplies power to the OLED. `GND` gives the Pico and OLED a shared electrical reference.

`SCL` is the **serial clock**. It supplies the timing for I²C communication. `SDA` is the **serial data** line that carries information between the devices. Most of our useful data travels from the Pico to the OLED, although SDA can carry data in either direction.

You do not need to trace individual clock pulses or bits yet. For now, it is enough to know that SCL coordinates the conversation and SDA carries it.
{{< /answer >}}

### Q2: Why is correct wiring a precondition?

{{< answer >}}
A precondition is something that must already be true before a program can work. Python can control signals at the Pico's pins, but it cannot move a wire from the wrong pin to the right one.

The program therefore assumes that the hardware is connected correctly. If that assumption is false, the code may fail even when every Python statement is valid. Software often depends on facts outside itself; naming those facts makes a system easier to test.
{{< /answer >}}

### Q3: Which holes on a breadboard are connected?

Imagine one numbered row:

```text
A B C D E     F G H I J
o o o o o     o o o o o
        gap
```

{{< answer >}}
On a typical breadboard, holes A through E in one numbered row form a connected group. Holes F through J form another. The center gap separates the two groups, and different numbered rows are separate.

Plan four continuous paths before applying power:

```text
OLED SDA → GP0
OLED SCL → GP1
OLED VCC → 3V3
OLED GND → GND
```

The exact row numbers do not matter. Each signal needs an unbroken path, and unrelated signals must not share a connected row.
{{< /answer >}}

## Establish I²C Communication

### Q4: What should the starter program do?

Predict what will appear in the Shell and on the OLED. Then run the program and explain any difference.

{{< answer >}}
The Shell should usually report:

```text
I2C devices: [60]
```

The OLED should display two lines:

```text
Hello, yush
Pico WH
```

This first run establishes that the complete system works. Once the known-good program succeeds, we can change one part at a time and learn from the result.
{{< /answer >}}

### Q5: What does the `60` returned by `i2c.scan()` mean?

{{< answer >}}
It is the OLED's I²C address, not a pin number or a count of devices. I²C allows several devices to share the same pair of communication lines, so each device needs an address.

The SSD1306 commonly uses hexadecimal address `0x3C`. Python prints the same value here in decimal:

```text
60 decimal = 0x3C hexadecimal
```

An empty list, `[]`, means that no device answered the scan.
{{< /answer >}}

### Q6: What would happen if SDA were disconnected?

Power off the Pico before moving a wire. Disconnect only SDA, then run the I²C setup and `print(i2c.scan())`—not the rest of the OLED program. Predict, run, and explain the result.

{{< answer >}}
With SDA connected, the scan commonly returns `[60]`. Without SDA, it should return `[]` because the OLED cannot answer.

The comparison gives us evidence that SDA is essential to the exchange. Reconnect SDA before continuing.
{{< /answer >}}

### Q7: How would you translate the I²C setup into ordinary English?

```python
i2c = I2C(
    0,
    scl=Pin(1),
    sda=Pin(0),
    freq=200_000,
)
```

{{< answer >}}
Create an I²C connection using the Pico's I²C hardware controller 0. Carry the clock signal through GP1, carry the data signal through GP0, and use a clock frequency of 200,000 cycles per second.

The first `0` selects the RP2040's `I2C0` controller. It does not mean GP0; `Pin(0)` names GP0 separately.
{{< /answer >}}

## Treat the Screen as a Grid

### Q8: What do `128` and `64` describe?

```python
oled = SSD1306_I2C(128, 64, i2c)
```

{{< answer >}}
They describe the display's resolution: 128 pixels wide and 64 pixels tall. The screen is a rectangular grid with 128 columns and 64 rows.

It contains:

```text
128 × 64 = 8,192 pixels
```

If only the width doubled to 256, the display would contain 16,384 pixels. Doubling one dimension doubles the total area.
{{< /answer >}}

### Q9: Where are the corners of the screen?

The origin is at the top-left. As `x` increases, you move right. As `y` increases, you move down.

Find the top-left, top-right, bottom-left, bottom-right, and approximate center.

{{< answer >}}

```text
(0, 0)       top-left
(127, 0)     top-right
(0, 63)      bottom-left
(127, 63)    bottom-right
(64, 32)     approximate center
```

Both dimensions are even, so the exact geometric center lies between pixels. `(64, 32)` is a useful nearby position.
{{< /answer >}}

### Q10: Why is the bottom-right pixel `(127, 63)`, not `(128, 64)`?

{{< answer >}}
The coordinates use zero-based indexing. The 128 horizontal positions are numbered `0` through `127`, and the 64 vertical positions are numbered `0` through `63`.

The final valid index is therefore one less than the number of positions.
{{< /answer >}}

## Place Pixels and Text

### Q11: How can you turn on the four corner pixels and one near the center?

Use `oled.pixel(x, y, 1)`. Calculate all five coordinates before you run the code.

{{< answer >}}

```python
oled.fill(0)

oled.pixel(0, 0, 1)
oled.pixel(127, 0, 1)
oled.pixel(0, 63, 1)
oled.pixel(127, 63, 1)
oled.pixel(64, 32, 1)

oled.show()
```

Inspect the physical display. The pixels are tiny, but their positions should agree with the coordinate model.
{{< /answer >}}

### Q12: What will happen if text begins at `(125, 0)`?

Predict, run, and explain:

```python
oled.fill(0)
oled.text("HELLO", 125, 0)
oled.show()
```

{{< answer >}}
Only three horizontal positions—125, 126, and 127—remain. A letter requires a group of pixels, so the word cannot fit.

The coordinates passed to `text()` mark where the drawing begins. They do not place the entire word inside one pixel. Anything beyond the edge is not visible.
{{< /answer >}}

### Q13: Why doesn't `(64, 32)` center a message?

```python
oled.fill(0)
oled.text("THIS IS A LONG MESSAGE", 64, 32)
oled.show()
```

{{< answer >}}
The point `(64, 32)` is near the center of the screen, but it becomes the text's starting position. The message then extends to the right.

To center text, you need its width and must move the starting x-coordinate left by about half that width. Position and size are separate properties.
{{< /answer >}}

### Q14: What is the difference between `fill(0)` and `fill(1)`?

Predict, run, and explain these two cases:

```python
oled.fill(0)
oled.show()
```

```python
oled.fill(1)
oled.show()
```

{{< answer >}}
This display is monochrome, so each pixel has two states:

```text
0 → off
1 → on
```

`fill(0)` makes the entire drawing area black. `fill(1)` turns every pixel on. Why one bit can represent these states is a question for the next lesson.
{{< /answer >}}

## Draw First, Display Second

### Q15: Does `text()` immediately change the physical OLED?

Predict what will remain visible after this code runs:

```python
oled.fill(0)
oled.show()

oled.text("TEST", 0, 0)

# Do not call oled.show() again.
```

{{< answer >}}
The display remains blank. `text()` changes an image being prepared in the Pico's memory; it does not immediately update the physical OLED.

`show()` transfers the prepared image to the display. That separation gives the program time to assemble a complete frame before the viewer sees it.

The memory holding the prepared image is called a **frame buffer**. We will examine its representation later.
{{< /answer >}}

### Q16: Which methods draw, and which method displays?

Sort these methods by job:

```python
oled.fill(0)
oled.pixel(20, 20, 1)
oled.text("HELLO", 10, 10)
oled.show()
```

{{< answer >}}
`fill()`, `pixel()`, and `text()` are drawing operations. Each changes the frame buffer—the prepared picture in memory.

`show()` is a display operation. It sends that picture to the SSD1306 so the physical screen reflects it.

```text
draw in memory → show the completed image
```
{{< /answer >}}

## Read the Whole Program

### Q17: What does `SSD1306_I2C(128, 64, i2c)` accomplish?

{{< answer >}}
It creates a Python object representing a 128 × 64 SSD1306 display and tells the driver to communicate through the connection stored in `i2c`.

That explanation describes what the constructor accomplishes. It does not explain how the driver implements the constructor—and it does not need to yet. A useful model can be accurate without exposing every layer beneath it.
{{< /answer >}}

### Q18: What story does the complete program tell?

{{< answer >}}
It proceeds in four stages:

```text
establish I²C communication
            ↓
create an object that represents the OLED
            ↓
prepare an image in memory
            ↓
send that image to the physical display
```

The wiring must already be correct. The program then establishes communication, describes the screen to the driver, draws into a frame buffer, and calls `show()` to make the result visible.
{{< /answer >}}

## Build Your Own Screen

### Q19: Can you place three messages deliberately?

Modify only the display portion of the starter program. Put one short message near the top, one near the middle, and one near the bottom. Sketch your expected result first. Then run it and adjust the coordinates.

{{< answer >}}
There is no single correct arrangement. A solution should have this shape:

```python
oled.fill(0)

oled.text("MESSAGE 1", x1, y1)
oled.text("MESSAGE 2", x2, y2)
oled.text("MESSAGE 3", x3, y3)

oled.show()
```

Choose values that keep each message inside the screen. Be ready to explain why each coordinate is reasonable and what you changed after seeing the first result.
{{< /answer >}}

## What Comes Next

### Q20: What can we use without understanding yet?

{{< answer >}}
We can now wire the OLED, find it on the I²C bus, place pixels and text, and control when a prepared image becomes visible. Several useful questions remain open:

- Where is the frame buffer stored?
- How does text become pixels?
- How are those pixels packed into bytes?
- What travels along SDA when `show()` runs?
- What does the SSD1306 do with the data it receives?

Those questions lead naturally from drawing pictures to representing pictures as data:

```text
pixel → bit → byte → frame buffer → display
```

For now, the essential model is enough: drawing methods prepare an image in memory, and `show()` sends it to the screen.
{{< /answer >}}
