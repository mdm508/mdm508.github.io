---
title: "Phase 5: Drawing Graphics — Shapes, Scenes, and Animation"
date: 2026-10-25T09:00:00-07:00
draft: false
description: "Draw pixels, lines, rectangles, and text on a Pico OLED, assemble a scene, then animate it by preparing and displaying successive frames."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "animation"]
summary: "Build a scene from simple drawing commands, then explore motion, trails, screen boundaries, and timing in a frame-by-frame animation lab."
reading_time: 90
---

Part of the [Pico OLED project: start here and see all phases](/post/pico-oled-project/).

## Where This Lesson Fits

In [Phase 3](/post/pages-and-display-memory/), we mapped a coordinate to a byte and a bit. In [Phase 4](/post/the-frame-buffer/), we separated drawing in Pico RAM from sending that image with `show()`.

Now we can build something with those ideas. **How do a few drawing commands become a scene—and how does a sequence of scenes become movement?**

Today's goal is to assemble one complete picture, then change one part of it across several frames. We will keep using the supplied driver. Opening its classes is Phase 6.

## Start with One Moving Shape

A **frame** is one complete still image. In an animation, we display successive frames with small changes between them. A square can appear to move right when we turn off its old pixels and light pixels farther right in the next image.

Try stepping through those images before writing a loop. The toy sends each frame for you; its code panel shows the drawing commands that produced the current picture.

{{< graphics-animation-lab >}}

### Q1: What makes a trail?

**Problem:** Step through three frames with clearing enabled. Reset, turn clearing off, and repeat. What stays in the second version's memory?

{{< hints >}}
- Drawing the next square does not automatically erase the previous one.
- `fill(0)` removes old pixels from the prepared image.
{{< /hints >}}

{{< answer >}}
With clearing enabled, each frame contains only the square at its current position. Without clearing, pixels from earlier squares remain. Overlapping positions build a trail.

The trail is part of the picture stored in RAM. Every `show()` sends that accumulated picture.
{{< /answer >}}

## Get Ready on the Pico

{{< download "/downloads/pico/phase-5-graphics-lab.py" "Download the Phase 5 graphics lab" >}}. **Only setup is executable**; the rest contains instructions for code you write yourself. The lesson link is at the top.

Keep `ssd1306.py` in the **same folder on the Pico** as the lab file. Upload the driver from the [Phase 1 kit](/downloads/pico/phase-1-kit.zip) if needed. Use the same wiring as before.

Run setup using MicroPico in VS Code or Thonny. Enter short experiments at the Pico's `>>>` prompt or Thonny's Shell. Write complete functions and animation loops in the lab file, then run the file with setup. Our loops will finish by themselves.

In VS Code, first read the [grey Python-session note in Phase 4](/post/the-frame-buffer/#keep-your-python-session). It explains how to keep names such as `oled` available after running setup. No `input()` pauses are needed here.

## Learn the Drawing Tools

A **drawing primitive** is a basic operation we can combine with others: a pixel, a line, a rectangle, or text. All the drawing operations below edit the same frame buffer. After preparing a picture, call `oled.show()` to display it.

For this monochrome display, `1` draws lit pixels and `0` draws dark pixels. Zero is useful as an eraser inside a larger picture.

| Operation | Meaning |
| --- | --- |
| `oled.fill(0)` | Clear the whole prepared image. |
| `oled.pixel(x, y, 1)` | Turn on one pixel. |
| `oled.line(x1, y1, x2, y2, 1)` | Draw a one-pixel-thick line between two endpoints. |
| `oled.hline(x, y, width, 1)` | Draw a horizontal line using a pixel count. |
| `oled.vline(x, y, height, 1)` | Draw a vertical line using a pixel count. |
| `oled.rect(x, y, width, height, 1)` | Draw a rectangle's outline. |
| `oled.fill_rect(x, y, width, height, 1)` | Draw a filled rectangle. |
| `oled.text("PICO", x, y, 1)` | Draw text beginning at its top-left position. |

The line methods are described in the [MicroPython drawing reference](https://docs.micropython.org/en/v1.26.0/library/framebuf.html#drawing-primitive-shapes); `fill_rect()` is also provided by the [frame-buffer implementation](https://github.com/micropython/micropython/blob/v1.26.0/extmod/modframebuf.c).

### Coordinates and Sizes Have Different Jobs

In `rect(10, 20, 12, 8, 1)`, `(10, 20)` is the top-left corner. The next two numbers are a **width of 12 pixels** and a **height of 8 pixels**. They are counts, not the opposite corner.

Starting at column 10, twelve columns end at `10 + 12 - 1 = 21`. The last row is `20 + 8 - 1 = 27`.

```text
right edge  = x + width - 1
bottom edge = y + height - 1
```

### Q2: Do these two lines occupy the same pixels?

**Problem:** Compare `oled.line(4, 12, 11, 12, 1)` with `oled.hline(4, 12, 8, 1)`. Predict the occupied columns and number of pixels, then test each on a cleared frame.

{{< hints >}}
- `line()` takes an ending coordinate.
- `hline()` takes a length. Count both endpoints of the first line.
{{< /hints >}}

{{< answer >}}
Both light columns 4 through 11 in row 12: `11 - 4 + 1 = 8` pixels.

```python
oled.fill(0)
oled.line(4, 12, 11, 12, 1)
oled.show()
```

Replace the line call with `oled.hline(4, 12, 8, 1)` and run again. The image should match. Passing `11` as the horizontal line's length would instead extend through column 14.
{{< /answer >}}

### Q3: What changes when a rectangle is filled?

**Problem:** Draw `rect(10, 20, 12, 8, 1)`, then draw `fill_rect(10, 20, 12, 8, 1)` on a separately cleared frame. Find the last occupied column and row. Does filling change those bounds?

{{< hints >}}
- Add the size to the starting coordinate, then subtract one.
- Both versions have the same outer dimensions.
{{< /hints >}}

{{< answer >}}
The right edge is `10 + 12 - 1 = 21`; the bottom edge is `20 + 8 - 1 = 27`. Filling adds the interior pixels and keeps those same bounds.

```python
oled.fill(0)
oled.rect(10, 20, 12, 8, 1)
oled.show()
```

For the second picture, change `rect` to `fill_rect`. A filled 12 × 8 rectangle lights 96 pixels when drawn on a blank frame.
{{< /answer >}}

### Q4: Where can an 8 × 8 square fit?

**Problem:** Find the largest top-left `x` and `y` that keep an 8 × 8 square completely inside a 128 × 64 display.

{{< hints >}}
- The final screen column is 127 and the final row is 63.
- The square extends seven positions beyond its starting position.
{{< /hints >}}

{{< answer >}}
```text
x + 8 - 1 ≤ 127  →  x ≤ 120
y + 8 - 1 ≤ 63   →  y ≤ 56
```

So the last fitting top-left corner is `(120, 56)`.

```python
oled.fill(0)
oled.fill_rect(120, 56, 8, 8, 1)
oled.show()
```

This also explains why the toy stops the square at x = 120, while a single pixel can reach x = 127.
{{< /answer >}}

## Add Text and Compose a Scene

The built-in text font uses **8 × 8 character cells**. A four-character word therefore occupies a 32-pixel-wide text area. The coordinates passed to `text()` locate the area's top-left corner. These are the dimensions of the character cells; individual letters can have blank space inside them. See [MicroPython's text reference](https://docs.micropython.org/en/v1.26.0/library/framebuf.html#drawing-text).

Drawing order matters too. A later operation can overwrite earlier pixels. Clearing after drawing a heading erases that heading. Clearing first, then adding every part, prepares a complete scene.

### Q5: Can you center PICO?

**Problem:** Center the text area for PICO horizontally on our 128-pixel-wide display. Put its top at y = 4. Calculate x before drawing it.

{{< hints >}}
- Four character cells use `4 * 8` horizontal pixels.
- Split the remaining width equally between the left and right margins.
{{< /hints >}}

{{< answer >}}
```text
text width = 4 × 8 = 32
remaining width = 128 - 32 = 96
left margin = 96 ÷ 2 = 48
```

```python
oled.fill(0)
oled.text("PICO", 48, 4, 1)
oled.show()
```

The character-cell area runs from x = 48 through 79, leaving 48 columns on each side.
{{< /answer >}}

### Q6: Can several primitives make one picture?

**Problem:** Prepare a scene with a border around the full screen, the centered PICO heading, a ground line from `(4, 56)` to `(123, 56)`, and a filled 8 × 8 square at `(12, 28)`. Send the finished scene once.

{{< hints >}}
- Clear before drawing any part of the scene.
- A full-screen border has width 128 and height 64.
- Put `show()` after all the drawing operations.
{{< /hints >}}

{{< answer >}}
```python
oled.fill(0)
oled.rect(0, 0, 128, 64, 1)
oled.text("PICO", 48, 4, 1)
oled.line(4, 56, 123, 56, 1)
oled.fill_rect(12, 28, 8, 8, 1)
oled.show()
```

The drawing calls all contribute to one frame in RAM. Only the last call transfers that prepared picture to the OLED.
{{< /answer >}}

## Describe the Scene with One Changing Value

To move the square, its x-coordinate must change between frames. The heading and ground can stay at fixed positions. The changing value is part of our program's **state**.

A function can describe the whole scene using an argument such as `x`. Calling `draw_scene(12)` prepares the square at x = 12; calling `draw_scene(16)` prepares it four pixels farther right.

If the function clears the buffer, it must redraw the background too. The OLED can keep showing the previous frame while the Pico prepares the replacement. We will leave `show()` outside the function so drawing and sending remain separate.

### Q7: Can one argument move only the square?

**Problem:** Turn Q6's drawing code into `draw_scene(x)`. Make the square's x-coordinate depend on the argument, and keep the other positions fixed. Prepare and display the scene at x = 12, then at x = 16.

{{< hints >}}
- Replace only the square's starting x-coordinate with `x`.
- Keep clearing and background drawing inside the function.
- Call `show()` after each call to your function.
{{< /hints >}}

{{< answer >}}
```python
def draw_scene(x):
    oled.fill(0)
    oled.rect(0, 0, 128, 64, 1)
    oled.text("PICO", 48, 4, 1)
    oled.line(4, 56, 123, 56, 1)
    oled.fill_rect(x, 28, 8, 8, 1)
```

After defining the function, enter these pairs separately so you can inspect each picture:

```python
draw_scene(12)
oled.show()
# STOP: inspect the scene before entering the next pair.
draw_scene(16)
oled.show()
```

The program rebuilds the whole frame each time. The square's position changes; the background is drawn again at its original positions.
{{< /answer >}}

## Turn Frames into Animation

Now repeat that process with a loop:

```text
choose a position → prepare the whole frame → show it → pause
        ↑                                                   |
        └──────────────── next position ────────────────────┘
```

`range(start, stop, step)` produces positions starting at `start`, stopping before `stop`, and changing by `step`. For example, `range(0, 121, 4)` gives 0, 4, 8, …, 120. It finishes, so we can inspect the last picture afterward.

`sleep_ms(100)` pauses for at least 100 milliseconds; 1,000 milliseconds make one second. The starter imports it from `time`. Drawing and sending also take time, so a 100 ms pause alone does not guarantee ten frames per second. See the [MicroPython timing reference](https://docs.micropython.org/en/v1.26.0/library/time.html#time.sleep_ms).

### Q8: Can you animate the scene across the screen?

**Problem:** After defining `draw_scene(x)`, write a finite loop that moves the square from x = 0 to x = 120 in steps of four, displaying every frame and pausing 100 ms after each transfer. How many frames does it send?

{{< hints >}}
- `range()` excludes its stop value.
- Each iteration needs drawing, sending, and a pause, in that order.
- Count both the first and last positions.
{{< /hints >}}

{{< answer >}}
```python
for x in range(0, 121, 4):
    draw_scene(x)
    oled.show()
    sleep_ms(100)
```

There are `(120 - 0) // 4 + 1 = 31` positions and therefore 31 frames. The square ends at x = 120, occupying columns 120–127. The loop finishes and the last frame remains visible.

The square appears to move because successive frames light different pixels. No physical pixel changes its location.
{{< /answer >}}

### Q9: What happens if you stop clearing?

**Problem:** Remove `oled.fill(0)` from `draw_scene(x)` and rerun the animation, starting from a cleared image. Predict what remains behind the square. Then restore clearing.

{{< hints >}}
- Redrawing the background's lit pixels does not erase old square pixels.
- The new square overlaps some previous positions and extends farther right.
{{< /hints >}}

{{< answer >}}
Earlier square pixels remain in RAM, so the square leaves a growing horizontal trail. Sending more often cannot remove it: the old pixels are still part of every frame you send.

Restoring `fill(0)` removes the old image before the background and current square are drawn. Clearing only a moving object's old rectangle is another possible strategy, but it can erase background pixels too. Rebuilding this small scene keeps the steps easy to reason about.
{{< /answer >}}

### Q10: How can you slow the same movement?

**Problem:** Keep the same positions and change only the pause from 100 ms to 200 ms. Which parts of the animation stay the same? How much total deliberate pause does each version contain?

{{< hints >}}
- There are still 31 positions.
- Multiply the pause per frame by the frame count.
{{< /hints >}}

{{< answer >}}
The path, frame count, and four-pixel step stay the same. The longer pause makes the movement slower.

```text
31 × 100 ms = 3,100 ms = 3.1 seconds of pauses
31 × 200 ms = 6,200 ms = 6.2 seconds of pauses
```

Actual running time also includes preparing and transferring the frames. These totals include a pause after the last frame, as written in our loop.
{{< /answer >}}

### Q11: Why is this animation one frame behind?

**Problem:** Begin with a blank buffer and display, then run this code. What does the first `show()` send? After the loop finishes, where is the square in RAM and where is it on the OLED?

```python
oled.fill(0)
oled.show()

for x in range(0, 9, 4):
    oled.show()
    draw_scene(x)
    sleep_ms(100)
```

{{< hints >}}
- The three x values are 0, 4, and 8.
- Each transfer happens before the new frame is prepared.
- The final prepared frame has no later transfer.
{{< /hints >}}

{{< answer >}}
The first transfer inside the loop sends a blank frame. The second sends the scene at x = 0, and the third sends the scene at x = 4. The loop leaves x = 8 prepared in RAM but unsent.

The fix is the Q8 order: `draw_scene(x)`, then `oled.show()`, then the pause.
{{< /answer >}}

## Make Your Own Scene

### Q12: Can you explain and animate a scene you designed?

**Problem:** Create a scene with a short heading, at least two kinds of drawing primitive, and one moving part. Sketch it first. Choose safe movement bounds and use a finite loop. Explain which values change and why the background remains visible.

{{< hints >}}
- Begin with a small variation on `draw_scene(x)`.
- Account for the moving object's size when choosing its final position.
- Rebuild the background after clearing and send once per frame.
{{< /hints >}}

{{< answer >}}
There are many valid designs. One is a small square crossing a star field: use `pixel()` for fixed stars, `text()` for a heading, and `fill_rect()` for the moving object.

Define a scene function that clears RAM, redraws the fixed stars and heading, then places the square using its changing x-coordinate. Reuse the finite loop from Q8. For an 8 × 8 square, x values from 0 through 120 keep it inside the display.

A successful solution shows a complete scene each frame, preserves the background by redrawing it, and stops at a position you can justify. Explain what would change if you moved vertically instead.
{{< /answer >}}

## Next: The SSD1306 Driver

We can now combine drawing primitives, prepare a scene with a function, and animate it by changing state between transfers. Where do `pixel()`, `rect()`, and `text()` actually come from? Why does the driver contain `show()` but so little drawing code?

Phase 6 will open `ssd1306.py` and follow how its classes share work with MicroPython's frame-buffer tools.

[Back to Phase 4: The Frame Buffer ←](/post/the-frame-buffer/) · [See the full project roadmap](/post/pico-oled-project/)

## Glossary

| Term | Definition | Example |
| --- | --- | --- |
| Drawing primitive | A basic operation used to assemble a picture. | A pixel, line, or rectangle. |
| Endpoint | A coordinate where a line begins or ends. | `line(4, 12, 11, 12, 1)` ends at `(11, 12)`. |
| Dimensions | An object's width and height, measured as counts. | An 8 × 8 square extends seven positions beyond its starting coordinate. |
| Outline | Only the boundary of a shape. | `oled.rect(...)`. |
| Filled shape | A shape whose interior is drawn too. | `oled.fill_rect(...)`. |
| Character cell | The area reserved for one character. | The built-in font uses 8 × 8 cells. |
| Scene | A picture assembled from several parts. | A heading, stars, and a moving square. |
| State | Values describing the program's current situation. | The square's current x-coordinate. |
| Frame | One complete still image. | A scene with the square at x = 12. |
| Animation | A sequence of displayed frames that creates apparent change or movement. | Show the square at x = 0, then 4, then 8. |
| Trail | Pixels left from earlier object positions. | Moving without clearing leaves old squares behind. |
| Millisecond | One thousandth of a second. | `sleep_ms(100)` pauses for at least 0.1 seconds. |
