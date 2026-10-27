---
title: "Phase 3: Memory Organization — Pages, Bytes, and Coordinates"
date: 2026-10-04T08:00:00-07:00
draft: false
description: "Connect a 2D grid to a flat list, then map OLED coordinates to pages, byte indices, and bit positions."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "binary", "hexadecimal"]
summary: "Explore a tiny Lite-Brite, practice grid-to-list addresses, and trace a pixel into the SSD1306's page-organized bytes."
reading_time: 120
toc_depth: 3
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/pico-oled-project/">Pico OLED project: guide and lesson roadmap</a>. Previously: <a href="/post/pictures-as-data/">Phase 2: Pictures as Data</a>.</aside>

You can now change one bit without disturbing its neighbors. But a screen has rows and columns, while our picture is stored in **one long sequence of bytes**. How do we connect the two?

## What You Will Be Able to Do

- Translate between a position in a grid and an index in a flat list.
- Explain a page and the eight vertical pixels stored in one byte.
- Calculate a pixel's page, byte index, bit position, and mask—and work backward.
- Write a pixel operation that preserves neighbors and checks screen boundaries.

## Get Ready

{{< download "/downloads/pico/phase-3-memory-map.py" "Download the Phase 3 memory lab" >}}. Only dimensions and an empty `bytearray` run; you write the mapping code. Ordinary Python or MicroPython works. **No OLED or driver is needed.** These are memory experiments; nothing in this file sends data to a physical screen.

Keep the dimensions and buffer allocation at the top, replace earlier experiment code as you move on, and run the whole file. The toy uses width 8; the starter begins with the real display's width of 128. Always check which width a problem specifies.

## Start with a Tiny Lite-Brite

Have you ever made a picture with a Lite-Brite? You push colored pegs through black paper into a board and light them from behind. A picture emerges from lots of small points of light.

<figure class="lite-brite-photo">
<img src="/images/pico/lite-brite-hello.jpg" width="960" height="789" loading="lazy" alt="A Lite-Brite toy with colored pegs spelling hello across its illuminated board.">
<figcaption>A Lite-Brite spelling “hello,” with its black paper removed so you can see the holes. Photo: <a href="https://commons.wikimedia.org/wiki/File:Hello_on_a_Lite-Brite.jpg">thomas ambridge / Dhscommtech</a>, <a href="https://creativecommons.org/licenses/by-sa/3.0/">CC BY-SA 3.0</a>. Reduced size.</figcaption>
</figure>

Our OLED does something similar: **a lit pixel is like a lit peg; a dark pixel is like an unfilled hole.** We only need on and off, so ignore peg colors. The browser model below shrinks the OLED to **8 columns and 16 rows**, making each point easy to follow.

Now add the OLED's storage rule: **one byte controls eight vertically stacked lights in one column.** This is how our display driver arranges pixels, not how the real Lite-Brite stores a picture.

Here are the rules for our little board:

- Coordinates count from zero: `x` goes across; `y` goes down.
- A **page** is an eight-row band. Page 0 covers rows 0–7; Page 1 covers rows 8–15.
- Choose a **page and column**, then send one byte to that vertical group. Each `1` lights a point; each `0` leaves it dark. Sending a byte replaces all eight states in that group.
- Within either page, bit 0 controls the top light and bit 7 the bottom. Written binary still puts bit 7 on the left.

Let's draw a triangle silhouette in Page 1. The dashed circles show the goal. **Write your predicted byte before sending it.** Then compare the lit points with your prediction and explain why those bit positions worked. Use the controls below the board to move to the next column. For now, a page and column are enough to choose where a byte goes.

{{< lite-brite-walkthrough >}}

The model shows each byte immediately. On the physical OLED, editing the buffer still needs `show()` to reach the screen.

## One Byte, Eight Vertical Pixels

Our driver uses a layout called **`MONO_VLSB`**: monochrome pixels packed vertically, with the least-significant bit at the top of each group. Here is one byte in Page 0:

| Screen row | Bit position | Mask |
| ---: | ---: | --- |
| 0 | 0 | `00000001` |
| 1 | 1 | `00000010` |
| 2 | 2 | `00000100` |
| 3 | 3 | `00001000` |
| 4 | 4 | `00010000` |
| 5 | 5 | `00100000` |
| 6 | 6 | `01000000` |
| 7 | 7 | `10000000` |

**Printed binary runs bit 7 to bit 0; these physical pixels run bit 0 to bit 7 from top to bottom.** For example, `0x2D`, or `00101101`, lights positions 0, 2, 3, and 5 within its vertical group—the order you practiced inspecting in Phase 2.

Each page needs one byte per column. The toy needs eight bytes for each of its two pages: sixteen bytes altogether. The real 128 × 64 display has **eight pages of 128 bytes**, or 1,024 bytes. A page is eight pixel rows tall, not a single row of pixels.

## Your Turn: Choose a Pixel

Now try the open board. Start with **`(2, 14)`**. Before clicking it, decide: which page contains row 14, which column do you need, and which bit within that eight-light group must turn on? What byte would light just that point in an empty group?

Click the point to check. Then clear the picture, choose Page 1 and column 2 in the controls, and send your predicted byte. Do these two routes make the same picture? Try one more coordinate of your own and explain each choice before checking it.

{{< pixel-memory-toy >}}

{{< lesson-exercise number="1" title="What changes at the page boundary?" id="q1-what-changes-at-the-page-boundary" >}}

Clear the toy. Predict what will happen, then click `(2, 0)`, `(2, 7)`, and `(2, 8)`. Which clicks share a byte? Explain why moving down from row 7 to row 8 changes the vertical group and restarts its bit number.

{{< hints >}}
- The highlighted eight-light group shares one byte.
- Page 0 ends at row 7. Page 1 starts at row 8.
{{< /hints >}}
{{< answer >}}
`(2, 0)` and `(2, 7)` belong to Page 0, column 2, bits 0 and 7. Together they make `10000001`, or `0x81`. `(2, 8)` belongs to Page 1, column 2, bit 0: the first light in a different eight-light group.

**Moving down the screen advances through bits, then into the next page.** It does not simply advance to a new byte on every row.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="intermezzo-a-2d-board-in-a-1d-list"></span>

## Which Index Belongs to This Byte?

The toy let us choose a byte with **two numbers: page and column**. For pixel `(2, 14)`, we found Page 1, column 2, bit 6. We even know the one-bit pattern: `01000000`. But to change the picture in Python, we need to know **which `buffer[index]` holds that byte**.

A **buffer** is memory holding data. For our little display, `bytearray(16)` creates sixteen editable byte slots, numbered 0–15. An **index** is a slot's number. `buffer[2]` selects the third byte, which controls eight pixels; it doesn't select the third pixel.

**So which slot holds Page 1, column 2?** The table above has two rows of eight bytes, but the buffer is one long sequence. We need a rule that turns a position in that table into one index.

### The Same Question on a Tic-Tac-Toe Board

A tic-tac-toe board gives us a familiar version of exactly this problem: **how can a row and column locate one entry in a flat list?** Each square holds a mark instead of a byte, but the counting works the same way. We'll work out that count here, then use it for our OLED byte.

A tic-tac-toe board has three rows and three columns. Here is a Python list of lists:

```python
board = [
    ["X", "O", " "],
    [" ", "X", " "],
    ["O", " ", "X"],
]
```

`board[1][2]` chooses row 1, column 2: the middle-right square. These indices count from zero. **A list of rows uses row, then column; a screen coordinate `(x, y)` uses column, then row.**

We can store the same nine values in a flat, one-dimensional list by placing complete rows one after another. This is **row-major order**:

```python
flat = ["X", "O", " ", " ", "X", " ", "O", " ", "X"]
```

```text
row:         0       |       1       |       2
flat index:  0  1  2  |    3  4  5    |    6  7  8
```

The bars mark row boundaries; they do not occupy entries. These two Python lists are separate objects, so changing one will not automatically change the other. They show two ways to arrange the same information.

Try the address game in both directions. Count complete earlier rows, then move across the current one. If you can explain that count, you're ready to write the formula.

{{< grid-index-game >}}

For row 1, column 2, skip one complete row of three entries, then move two positions across: `1 * 3 + 2 = 5`. In general:

```python
index = row * width + column
```

### Apply That Count to the OLED

Return to our question: **which byte holds Page 1, column 2?** Each page is one row of eight bytes in the toy's table. Count complete earlier pages, then move across to the column:

```text
1 earlier page × 8 bytes per page = 8 bytes to skip
8 + column 2 = index 10
```

So `buffer[10]` is the byte we need. We used the same count as for the board; only the row name and width changed:

| Tic-tac-toe list | OLED byte buffer |
| --- | --- |
| Row | Page |
| Three entries per row | One byte per column: eight per page in the toy |
| A square's mark | A byte holding eight vertical pixels |
| `row * width + column` | `page * width + x` |

**One table row is a whole page of bytes, not one row of pixels.** That's the important difference between our two grids. The real display uses the same rule with 128 bytes per page.

### Work Backward from an Index

We can reverse the same count too. This will help us identify the pixels belonging to a byte later in the lesson.

To go backward, divide the index into complete groups of `width`. For nonnegative indices, **integer division `//`** gives the number of complete groups; **modulo `%`** gives the remainder:

```text
7 = 2 × 3 + 1
7 // 3 = 2 complete rows
7 % 3 = 1 position across
```

So `row = index // width` and `column = index % width`.

{{< lesson-exercise number="2" title="Can the same index describe a different square?" id="q2-can-the-same-index-describe-a-different-square" >}}

In the three-column board, which row and column contain index 7? Now imagine a grid four columns wide. Where is index 7 in that grid? Check both answers with the forward formula and explain why the width matters.

{{< hints >}}
- Separate the index into complete rows and a remainder.
- For width 4, write `7 = row * 4 + column`.
{{< /hints >}}
{{< answer >}}
| Width | Row | Column | Forward check |
| ---: | ---: | ---: | --- |
| 3 | `7 // 3 = 2` | `7 % 3 = 1` | `2 * 3 + 1 = 7` |
| 4 | `7 // 4 = 1` | `7 % 4 = 3` | `1 * 4 + 3 = 7` |

**An index only tells us a grid position when we also know the layout and width.** The flat list itself has no drawn row boundaries.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="back-to-the-oled-find-the-pixel"></span>

## From a Pixel to Its Byte and Bit

We can now turn a page and column into an index. A pixel coordinate gives us `x` and `y` instead, so there is one more question: **which page contains row `y`, and which bit controls that row within the page?**

Divide `y` into eight-row groups. The quotient is the page; the remainder is the bit position. Combine that with the index rule we just learned:

```python
page = y // 8
bit = y % 8
index = page * width + x
mask = 1 << bit
```

Put all the steps together for **`(2, 14)` on the eight-column toy**. We should recover the byte index 10 we found above:

1. Row 14 lies in Page 1, which covers rows 8–15: `14 // 8 = 1`.
2. Its offset inside that page is `14 - 8 = 6`, also `14 % 8 = 6`.
3. Skip Page 0's eight bytes: `1 * 8 = 8`.
4. Move to column 2: `8 + 2 = 10`.
5. Select bit 6: `1 << 6 = 0b01000000 = 0x40 = 64`.

The pixel is **byte 10, bit 6**. That byte holds all eight pixels in column 2, rows 8–15; the mask selects just one of them. Find it in the toy to check every part of the calculation.

{{< lesson-exercise number="3" title="Scale the address up to the real screen" id="q3-scale-the-address-up-to-the-real-screen" >}}

{{< exercise-step "predict" >}}
For width 128 and height 64, locate pixel `(37, 29)`. Find its page, bit, byte index, and mask. Explain which complete pages you skip.
{{< /exercise-step >}}
{{< exercise-step "try" >}}
Write the four calculations in the starter and print the results. Do not use the toy's width of eight for this problem.
{{< /exercise-step >}}
{{< exercise-step "explain" >}}
Would changing only the display width change the page and bit, or the byte index? Why?
{{< /exercise-step >}}

{{< hints >}}
- `29 = 3 * 8 + 5` tells you the page and position inside it.
- Three complete pages come before Page 3. Each contains 128 bytes.
- Make the mask from the bit position, not from `y` itself.
{{< /hints >}}
{{< answer >}}
```text
page  = 29 // 8 = 3
bit   = 29 % 8 = 5
index = 3 * 128 + 37 = 384 + 37 = 421
mask  = 1 << 5 = 0b00100000 = 0x20 = 32
```

Page 3 covers rows 24–31. Row 29 is five steps below its first row, so it uses bit 5. The byte index depends on width because width determines how many bytes each earlier page occupies. Page and bit depend only on `y`.

**First choose the vertical group, then its column byte, then the bit within it.** Capacity alone—“1,024 bytes”—would not tell us this mapping.
{{< /answer >}}
{{< /lesson-exercise >}}

## Change a Pixel Without Erasing Its Neighbors

The starter's `buffer` is a `bytearray`. Read a byte with `buffer[index]`, and assign a new byte value to change it. Use the Phase 2 masks when you want to preserve neighboring pixels:

```python
buffer[index] |= mask   # Set the selected bit.
buffer[index] &= ~mask  # Clear the selected bit.
```

For valid byte values and bit positions 0–7, these expressions stay in the range 0–255. If you intend to keep only the lowest eight bits of a larger integer, calculate `value & 0xFF` explicitly, as in Phase 2. That makes the operation clear and keeps our code independent of how a particular Python runtime handles out-of-range assignments.

{{< lesson-exercise number="4" title="Why did the neighboring pixel disappear?" id="q4-why-did-the-neighboring-pixel-disappear" >}}

On the 128-wide display, pixel `(37, 30)` is already on. Start with `buffer[421] = 0b01000000`. You also want `(37, 29)` on. A friend writes `buffer[421] = 1 << 5`.

Predict both pixels' states after that assignment. Repair it so both pixels remain on, then print the resulting byte in hex. Which Phase 2 rule explains the repair?

{{< hints >}}
- Rows 29 and 30 are in the same page and column, at bits 5 and 6.
- Plain assignment replaces the whole byte. OR can preserve its other bits.
{{< /hints >}}
{{< answer >}}
The assignment replaces `01000000` with `00100000`, turning off bit 6. Instead:

```python
buffer[421] = 0b01000000
buffer[421] |= 1 << 5
print(hex(buffer[421]))  # 0x60: 01100000
```

**A byte is shared by eight pixels.** Knowing the right address is only half the job; the update must preserve the seven bits you did not select.
{{< /answer >}}
{{< /lesson-exercise >}}

## Work Backward and Check Boundaries

The reverse map first recovers a page and column from the byte index, just as we recovered a row and column from a flat-list index:

```python
page = index // width
x = index % width
y = page * 8 + bit
```

For example, byte 135, bit 2 on a 128-wide screen gives `page = 1`, `x = 7`, and `y = 1 * 8 + 2 = 10`.

Valid screen coordinates are `0 <= x < width` and `0 <= y < height`. Check those **before** calculating and writing an address. Python allows negative list and bytearray indices to count from the end, and an out-of-screen `x` can even produce an in-range index in the wrong page. An address being in the buffer does not prove the original coordinate was on screen.

<hr class="lesson-review-divider">

## Homework

### Explain yourself

Explain each term before checking it. Sketch a board, its flat list, and one OLED page. Which parts of the grid-to-list idea carry over? Which extra step does a byte of vertical pixels require?

<span id="glossary"></span>

{{< reveal-controls scope="glossary" >}}
{{< recall-glossary data="phase3_glossary" >}}

### Exercises

Try these from the memory model before returning to the formulas. ★ Challenging · ★★ Very challenging.

{{< lesson-exercise number="5" level="4" title="Check all four corners" id="q5-check-all-four-corners" >}}

For width 128 and height 64, find the byte and bit for all four screen corners. Starting with the empty starter buffer, turn on those four pixels using raw byte edits. Print the four byte values and explain why the last corner fits inside a 1,024-byte buffer.

{{< hints >}}
- Use the first and last valid coordinates from Phase 1.
- The top corners use bit 0; the bottom corners use bit 7.
- The last valid byte index is one less than the length.
{{< /hints >}}
{{< answer >}}
| Coordinate | Page | Byte index | Bit |
| --- | ---: | ---: | ---: |
| `(0, 0)` | 0 | 0 | 0 |
| `(127, 0)` | 0 | 127 | 0 |
| `(0, 63)` | 7 | 896 | 7 |
| `(127, 63)` | 7 | 1023 | 7 |

```python
buffer[0] |= 1 << 0
buffer[127] |= 1 << 0
buffer[896] |= 1 << 7
buffer[1023] |= 1 << 7
print(buffer[0], buffer[127], buffer[896], buffer[1023])  # 1 1 128 128
```

Byte 1023 is the final slot, not one past it.

**Boundary cases check whether the coordinate model and storage model agree.** These commands prepare data; they do not display it.
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="6" level="4" title="Decode a byte back into pixels" difficulty="1" id="q6-decode-a-byte-back-into-pixels" >}}

An **eight-column, sixteen-row** picture has only byte 10 set to `0x41`; all other bytes are zero. Without using the toy first, find every lit pixel's `(x, y)`. Then draw your prediction in the toy and check its byte values. What would byte 10 mean on a 128-wide screen instead?

{{< hints >}}
- Split byte index 10 into complete pages of eight bytes and a column remainder.
- `0x41` is `01000001`: two bits are on.
- Rebuild `y` from the page's first row and the bit position.
{{< /hints >}}
{{< answer >}}
For width 8, `page = 10 // 8 = 1` and `x = 10 % 8 = 2`. Bits 0 and 6 are on, so the pixels are `(2, 8)` and `(2, 14)`.

For width 128, byte 10 is on Page 0 at column 10, so the same byte value would light `(10, 0)` and `(10, 6)`.

**Byte values describe a pattern; the layout tells us where that pattern belongs.** Width is part of interpreting the memory.
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="7" level="4" title="Build a pixel writer that respects the edges" difficulty="2" id="q7-build-a-pixel-writer-that-respects-the-edges" >}}

Write `write_pixel(buffer, width, height, x, y, on)` to set or clear one pixel while preserving its neighbors. Return `False` without editing memory if the coordinate is outside the screen; otherwise update the byte and return `True`. Assume integer coordinates, a positive width, a height divisible by eight, and a buffer of the matching size.

Test two neighboring bits, clearing one, and rejecting `(-1, 0)` and `(128, 0)` on the real display's dimensions. Also test `(2, 14)` in a separate 8 × 16 buffer. Explain why checking only the resulting index would miss some bad coordinates.

{{< hints >}}
- Check both coordinate ranges first; an early `return False` ends the function before any edit.
- Use the supplied width when skipping complete pages.
- Set with OR, clear with AND and an inverted mask.
{{< /hints >}}
{{< answer >}}
```python
def write_pixel(buffer, width, height, x, y, on):
    if not (0 <= x < width and 0 <= y < height):
        return False
    page = y // 8
    bit = y % 8
    index = page * width + x
    mask = 1 << bit
    if on:
        buffer[index] |= mask
    else:
        buffer[index] &= ~mask
    return True

write_pixel(buffer, 128, 64, 37, 29, True)
write_pixel(buffer, 128, 64, 37, 30, True)
write_pixel(buffer, 128, 64, 37, 29, False)
print(buffer[421])  # 64: only bit 6 remains on
print(write_pixel(buffer, 128, 64, -1, 0, True))   # False
print(write_pixel(buffer, 128, 64, 128, 0, True))  # False

tiny = bytearray(16)
write_pixel(tiny, 8, 16, 2, 14, True)
print(tiny[10])  # 64
```

Without checking `x`, `(128, 0)` would produce index 128, a valid byte that belongs to another page. Negative indices can silently refer to the end of the buffer.

**A reusable drawing operation combines representation, masking, and a clear rule for invalid inputs.** This is a small piece of the graphics machinery we will eventually investigate.
{{< /answer >}}
{{< /lesson-exercise >}}

## What's next {#next-the-frame-buffer}

You can now connect a coordinate to a stored bit and edit it deliberately. Phase 1 showed that drawing and displaying happen separately; Phase 4 will connect that observation to the exact bytes you just learned to change. **Where do those bytes wait, and what does `show()` actually send?**

[Continue to Phase 4: The Frame Buffer →](/post/the-frame-buffer/) · [Back to Phase 2 ←](/post/pictures-as-data/) · [Project roadmap](/post/pico-oled-project/)

For reference: [MicroPython's description of the `MONO_VLSB` layout](https://docs.micropython.org/en/v1.26.0/library/framebuf.html#framebuf.MONO_VLSB).
