---
title: "Phase 5: Drawing Graphics — Shapes, Scenes, and Animation"
date: 2026-10-25T09:00:00-07:00
draft: false
description: "Place shapes and character cells precisely, compose a complete scene, and animate it by preparing and sending successive frames."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "animation"]
summary: "Connect counts to coordinates, place neighboring characters, and turn a scene function into a finite animation."
reading_time: 90
toc_depth: 3
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/pico-oled-project/">Pico OLED project: guide and lesson roadmap</a>. Previously: <a href="/post/the-frame-buffer/">Phase 4: The Frame Buffer</a>.</aside>

You can prepare an image, inspect its bytes, and choose when to show it. Now let's build a scene and make part of it move. **The pixels stay fixed; the pictures change.** We'll use simple drawing tools, precise coordinates, and one changing value to create that effect.

## What You Will Be Able to Do

- Distinguish an ending coordinate from a size, and calculate the last fitting position.
- Lay out text using 8 × 8 character cells, including two directly adjacent characters.
- Use a function to rebuild a complete scene from its current state.
- Animate it with a finite draw–show–pause loop and explain its bounds and timing.

## Get Ready

{{< download "/downloads/pico/phase-5-graphics-lab.py" "Download the Phase 5 graphics lab" >}}. Only setup runs; write your experiments below it. Keep `ssd1306.py` in the **same folder on the Pico**, using the [Phase 1 kit](/downloads/pico/phase-1-kit.zip) if needed. Wiring remains GP0 → SDA, GP1 → SCL, 3V3(OUT) → VCC, GND → GND.

Run the whole file on the Pico through Thonny or MicroPico in VS Code. Keep setup, replace earlier drawing experiments, and keep any function a later problem uses. Our loops finish by themselves. You do not need `input()` or a session that preserves names between runs.[^vscode-session]

Without the hardware, use the animation model and calculate layouts on paper. Your Python functions and loops are the same ones you will use on the Pico.

[^vscode-session]: **Optional, for VS Code users:** If you choose to experiment at `>>>` and names such as `oled` are unavailable, see [Phase 4's grey Python-session note](/post/the-frame-buffer/#keep-your-python-session). Whole-file runs do not require that setting.

## Start with One Moving Shape

An **animation** displays successive frames with changes between them. Step through three frames in the toy with clearing enabled. Reset, turn clearing off, and repeat. Old square pixels remain in the second version, forming a **trail**. Drawing a new position does not automatically erase the old one.

The toy prepares and sends each frame for you. Its code panel shows the calls used for the current picture; we'll learn those tools next.

{{< graphics-animation-lab >}}

## Learn the Drawing Tools

A **drawing primitive** is a basic operation we can combine with others. These operations all edit the same frame buffer. `show()` sends their combined result.

| Operation | Meaning |
| --- | --- |
| `oled.fill(0)` | Clear the whole prepared image. |
| `oled.pixel(x, y, 1)` | Light one pixel. |
| `oled.line(x1, y1, x2, y2, 1)` | Draw a one-pixel-thick line between two endpoints, including both. |
| `oled.hline(x, y, width, 1)` | Draw a horizontal line with a given pixel count. |
| `oled.vline(x, y, height, 1)` | Draw a vertical line with a given pixel count. |
| `oled.rect(x, y, width, height, 1)` | Draw a rectangle's outline. |
| `oled.fill_rect(x, y, width, height, 1)` | Draw a filled rectangle. |
| `oled.text("PICO", x, y, 1)` | Draw text from its top-left starting position. |

The drawing tools come from MicroPython's **`framebuf.FrameBuffer`** type. The SSD1306 driver builds on that type, adding the display-specific setup and transfer operations. You can use the tools now; Phase 6 will open the classes and explain how they share this work.

For this monochrome picture, color `1` draws lit pixels and `0` draws dark pixels. Drawing with zero can erase just part of a picture.

{{< lesson-exercise number="1" title="Are these two line descriptions equivalent?" id="q1-are-these-two-line-descriptions-equivalent" >}}

Compare `oled.line(4, 12, 11, 12, 1)` with `oled.hline(4, 12, 8, 1)`. Predict their occupied columns and pixel counts. Test each separately on a cleared picture, then explain what would change if the `hline()` length were 11 instead of 8.

{{< hints >}}
- `line()` takes an ending coordinate; `hline()` takes a count.
- Count both endpoints, not just the steps between them.
{{< /hints >}}
{{< answer >}}
Both light columns 4 through 11 at row 12:

{{< math >}}
N = b - a + 1 = 11 - 4 + 1 = 8
{{< /math >}}

```python
oled.fill(0)
oled.line(4, 12, 11, 12, 1)
oled.show()
```

Replace the line call with `oled.hline(4, 12, 8, 1)` and rerun. A length of 11 would instead occupy columns 4 through 14.

**A coordinate difference counts steps; add one to count both endpoints' pixels.**
{{< /answer >}}
{{< /lesson-exercise >}}

## Fit a Square at the Edge

In `rect(10, 20, 12, 8, 1)`, `(10, 20)` is a starting coordinate; 12 and 8 are counts. The right edge is `10 + 12 - 1 = 21`; the bottom edge is `20 + 8 - 1 = 27`.

```text
last occupied column = x + width - 1
last occupied row    = y + height - 1
```

An **off-by-one error** makes a count or boundary one too large or too small. An outlined square is a useful test: if its right edge lies outside the screen, that border disappears. **Clipping** means the part outside the drawable area is not drawn.

{{< lesson-exercise number="2" title="Why subtract eight rather than seven?" id="q2-why-subtract-eight-rather-than-seven" >}}

{{< exercise-step "predict" >}}
Find the last column and row of `oled.rect(120, 56, 8, 8, 1)`. Will all four borders fit? What changes if its starting x is 121?
{{< /exercise-step >}}
{{< exercise-step "try" >}}
Display each version on a cleared picture. Use an outline so a missing border is easy to spot.
{{< /exercise-step >}}
{{< exercise-step "explain" >}}
Why is the last fitting x `128 - 8`, even though the last column is seven steps beyond the start?
{{< /exercise-step >}}

{{< hints >}}
- The final screen column is 127, not 128.
- An eight-pixel width includes its starting column.
- Apply `last = start + size - 1` before deciding whether it fits.
{{< /hints >}}
{{< answer >}}
At `(120, 56)`, the square ends at `(127, 63)`. All four borders fit:

```python
oled.fill(0)
oled.rect(120, 56, 8, 8, 1)
oled.show()
```

At x = 121, the right border would be at column 128, so it is clipped.

{{< pixel-spacing-diagram "edge" >}}

For a screen width `W` and an object width `w`:

{{< math >}}
x + w - 1 \le W - 1 \quad\Longrightarrow\quad x \le W - w
{{< /math >}}

The last fitting start is `128 - 8 = 120`, with y at most `64 - 8 = 56`.

**Subtract one to find an occupied edge; subtract the whole size to find the last fitting start.**
{{< /answer >}}
{{< /lesson-exercise >}}

## From a Square to a Character

The built-in font gives each character an **8 × 8 cell**. The `(x, y)` in `text()` locates that cell's top-left corner. A **glyph** is the visible letter shape inside it; some rows or columns can be blank.

That means `oled.text("A", 120, 56, 1)` uses the same cell bounds as our square: columns 120–127 and rows 56–63. If A still looks complete at x = 121, that does not prove the cell fits. A blank edge column can hide the clipping. Use the cell dimensions to plan the layout.

{{< lesson-exercise number="3" title="Put two characters directly beside each other" id="q3-put-two-characters-directly-beside-each-other" >}}

Put B in the rightmost fitting cell at `(120, 56)`. Where should A start so its cell sits directly to B's left, with no gap or overlap: x = 112 or x = 113? Explain, then draw both on a blank picture. Could one `text()` call create the same layout?

{{< hints >}}
- The column immediately before B is 119.
- A's cell ends seven positions beyond its start.
- `text()` advances eight pixels for each character, including a space.
{{< /hints >}}
{{< answer >}}
A starts at `120 - 8 = 112`, occupying 112–119. B occupies 120–127. Starting A at 113 would make its cell end at 120, overlapping B's first column.

{{< pixel-spacing-diagram "neighbors" >}}

```python
oled.fill(0)
oled.text("A", 112, 56, 1)
oled.text("B", 120, 56, 1)
oled.show()
```

On a blank picture, `oled.text("AB", 112, 56, 1)` gives the same layout. The glyph strokes can still have visible space between them because the cells include blank pixels.

{{< math >}}
x_{\text{next}} = x + w \qquad x_{\text{last}} = x + w - 1
{{< /math >}}

**Add eight to reach the next cell's start; add seven to reach this cell's last column.**
{{< /answer >}}
{{< /lesson-exercise >}}

## Compose and Rebuild a Scene

A **scene** combines several parts into one picture. To center a heading with `n` character cells, calculate its width, subtract it from the screen width, and split the remaining space between two margins:

{{< math >}}
x = \left\lfloor\frac{W - 8n}{2}\right\rfloor
{{< /math >}}

The floor brackets mean round down to a whole pixel; Python uses `// 2`. For PICO, four cells use 32 pixels. On a 128-wide screen, `(128 - 32) // 2 = 48`. Its cell area occupies 48–79, leaving 48 columns on each side. With an odd amount of spare space, the margins differ by one pixel.

Drawing order matters where parts overlap. To make a dark label on a lit panel, draw a filled rectangle in color 1 first, then its text in color 0. The text method draws glyph strokes; it does not paint a whole cell's background. Reversing those two calls lets the panel cover the lettering.

For movement, a function can rebuild a scene from one changing value. `draw_scene(12)` prepares a square at x = 12; `draw_scene(16)` prepares it farther right. We can reuse the same working buffer for every position, with no need to save a separate bitmap for each one. If the function clears the buffer, it must redraw the background too. Keep `show()` outside it so preparation and transfer remain separate.

{{< lesson-exercise number="4" title="Can one argument move only the square?" id="q4-can-one-argument-move-only-the-square" >}}

Write `draw_scene(x)` to prepare a full-screen border, PICO centered at y = 4, a ground line from `(4, 56)` through `(123, 56)`, and a filled 8 × 8 square at `(x, 28)`. Clear first; leave sending to the caller.

Display the scene at x = 12. Change that call to x = 16 and rerun the whole file. Explain why the background remains in the same place even though the function clears it each time.

{{< hints >}}
- The border uses dimensions 128 × 64; the heading starts at x = 48.
- Only the square's x-coordinate comes from the argument.
- Redraw the fixed background after clearing, then call `show()` after your function returns.
{{< /hints >}}
{{< answer >}}
```python
def draw_scene(x):
    oled.fill(0)
    oled.rect(0, 0, 128, 64, 1)
    oled.text("PICO", 48, 4, 1)
    oled.hline(4, 56, 120, 1)
    oled.fill_rect(x, 28, 8, 8, 1)

draw_scene(12)
oled.show()
```

Change 12 to 16 for the second run. The ground's 120 pixels include both endpoint columns. The function redraws the background at fixed positions and draws the square from its argument.

**One changing value can describe motion while one function keeps the whole picture consistent.** Keep this function for the animation problems below.
{{< /answer >}}
{{< /lesson-exercise >}}

## Turn Frames into Animation

Repeat this sequence for each position:

```text
choose state → prepare the whole frame → show it → pause
     ↑                                              |
     └──────────────── next frame ──────────────────┘
```

The x-coordinate is part of the program's **state**. Changing it changes which fixed pixels light up; no physical pixel moves.

`range(start, stop, step)` supplies a finite sequence of positions, excluding `stop`. For example, `range(2, 7, 2)` gives 2, 4, 6. `sleep_ms(100)`, imported by the starter, pauses for at least 100 milliseconds, or 0.1 seconds. Drawing and I²C transfer take additional time, so that pause alone does not guarantee ten frames per second.

Speed and smoothness are different choices. Ignoring drawing and transfer time, steps of four pixels every 0.1 seconds and eight pixels every 0.2 seconds both give 40 pixels per second. The smaller, more frequent steps show more intermediate positions and should look smoother.

<hr class="lesson-review-divider">

## Homework

### Explain yourself

Explain the terms before opening their definitions. Use a square and a character cell to connect sizes, endpoints, and boundaries. Then connect state, a scene function, and a sequence of displayed frames. How does Phase 4 explain a trail or a picture that is one frame behind?

<span id="glossary"></span>

{{< reveal-controls scope="glossary" >}}
{{< recall-glossary data="phase5_glossary" >}}

### Exercises

Keep setup and any function you need above your new code. ★ Challenging · ★★ Very challenging.

{{< lesson-exercise number="5" level="4" title="Center a greeting inside a panel" id="q5-center-a-greeting-inside-a-panel" >}}

On a blank picture, draw **Hi Yush** as dark text on a lit panel. Center the text area horizontally on the 128-wide screen, with its top at y = 20. Give it four pixels of panel padding on every side. Calculate the text start, panel start, panel dimensions, and final occupied coordinates before drawing. Show once when complete.

{{< hints >}}
- Count the space too: Hi Yush uses seven character cells.
- Four pixels on each side add eight pixels to each dimension.
- Draw the lit panel before the dark text.
{{< /hints >}}
{{< answer >}}
The text area is `7 * 8 = 56` pixels wide, so x is `(128 - 56) // 2 = 36`. It occupies columns 36–91 and rows 20–27. The panel starts four pixels earlier at `(32, 16)` and is `64 × 16`, ending at `(95, 31)`.

```python
oled.fill(0)
oled.fill_rect(32, 16, 64, 16, 1)
oled.text("Hi Yush", 36, 20, 0)
oled.show()
```

The panel has 32 columns of screen margin on each side; the text cell area has four pixels of padding inside it. Visible glyph strokes can leave additional blank space within the cells.

**Layout combines counts and positions; contrast and drawing order make that layout visible.**
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="6" level="4" title="Reach the final fitting position" difficulty="1" id="q6-reach-the-final-fitting-position" >}}

Use your `draw_scene(x)` function in a finite loop. Move the square from x = 0 through its last fitting x in steps of four. Prepare, show, and pause 100 ms for each frame. Would `range(0, 120, 4)` include the last position? Calculate the number of frames and the image bytes sent by those calls to `show()`.

{{< hints >}}
- The final fitting start is screen width minus square width.
- `range()` excludes its stop. Count the first position as a frame too.
- Phase 4 found that each `show()` sends 1,024 image bytes in this driver.
{{< /hints >}}
{{< answer >}}
After your function definition:

```python
for x in range(0, 121, 4):
    draw_scene(x)
    oled.show()
    sleep_ms(100)
```

Using a stop of 120 would end at 116. A stop of 121 includes 120, where the square occupies columns 120–127.

{{< math >}}
N = \frac{120 - 0}{4} + 1 = 31
{{< /math >}}

There are 31 frames, sending `31 * 1024 = 31744` image bytes, apart from setup and bus control information. The 31 pauses total 3.1 seconds; drawing and sending add time. The loop finishes with the final scene visible.

**The final screen coordinate is inclusive; the loop's stop is exclusive.** Correct bounds need both the object's size and the loop's counting rule.
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="7" level="4" title="Repair the animation that is one frame behind" difficulty="2" id="q7-repair-the-animation-that-is-one-frame-behind" >}}

Keep `draw_scene(x)` above this block. The aim is to show the scenes at x = 0, 4, and 8, pausing after each new frame. Trace what the following code actually sends on each iteration and where the square ends in RAM and on the OLED. Then repair the order without changing the range, adding a final transfer, or sending more than once per iteration.

```python
oled.fill(0)
oled.show()
for x in range(0, 9, 4):
    oled.show()
    draw_scene(x)
    sleep_ms(100)
```

{{< hints >}}
- The loop positions are 0, 4, and 8.
- Ask which picture exists when each `show()` begins.
- Preparing, sending, and pausing are three separate steps; putting them in the right order fixes every iteration.
{{< /hints >}}
{{< answer >}}
| Iteration's x | Picture sent by the broken loop | Picture prepared afterward |
| ---: | --- | --- |
| 0 | Blank | Scene at x = 0 |
| 4 | Scene at x = 0 | Scene at x = 4 |
| 8 | Scene at x = 4 | Scene at x = 8 |

It finishes with x = 8 prepared and x = 4 displayed. Repair the loop:

```python
for x in range(0, 9, 4):
    draw_scene(x)
    oled.show()
    sleep_ms(100)
```

Appending a transfer to the broken loop would reveal the last frame, but would still leave the earlier pauses following the wrong pictures. Reordering fixes the cause.

**A correct final image is not enough to prove a sequence is correct.** Animation requires the right picture at each step, which is why we track prepared and displayed state separately.
{{< /answer >}}
{{< /lesson-exercise >}}

## What's next {#next-the-ssd1306-driver}

You can now explain a scene's positions, prepare it from a changing value, and send it at the right point in a loop. We have used the driver extensively; next we'll open it. **How does it share work with `framebuf.FrameBuffer`, and which parts are specific to this OLED?**

Phase 6 is planned. Until it is available, try changing your scene's artwork or square size and recalculate its safe movement bounds.

[Back to Phase 4 ←](/post/the-frame-buffer/) · [Project roadmap and planned phases](/post/pico-oled-project/)

For reference: [MicroPython drawing and 8 × 8 text](https://docs.micropython.org/en/v1.26.0/library/framebuf.html), the [implementation that provides `fill_rect()`](https://github.com/micropython/micropython/blob/v1.26.0/extmod/modframebuf.c), and [`sleep_ms()` timing](https://docs.micropython.org/en/v1.26.0/library/time.html#time.sleep_ms).
