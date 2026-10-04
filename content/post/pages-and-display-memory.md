---
title: "Phase 3: Memory Organization — Pages, Bytes, and Coordinates"
date: 2026-10-04T08:00:00-07:00
draft: false
description: "Map SSD1306 screen coordinates to pages, bytes, and bits, then change individual pixels in a raw MicroPython bytearray."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "binary", "hexadecimal"]
summary: "Trace a pixel from (x, y) to its page, byte, and bit in SSD1306 display memory."
reading_time: 120
---

## Where This Lesson Fits

In [Phase 1: Meet the OLED](/post/meet-the-oled/), we treated the 128 × 64 display as a coordinate grid. `x` moves across columns; `y` moves down rows. We used drawing commands and `show()` without opening the driver.

In [Phase 2: Pictures as Data](/post/pictures-as-data/), we learned that a monochrome pixel needs one bit, a byte contains eight bits, and a full screen requires 1,024 bytes. We also practiced masks for changing individual bits.

So we know how much memory the picture needs and how to change a bit. We have not yet connected a screen coordinate to a particular byte.

**Today's goal:** build that map, then answer one question: to turn on pixel `(37, 29)`, which byte do we change, and which bit inside it?

Phase 4 will pick up after that. We will look at the frame waiting in the Pico's RAM and ask why drawing text does not immediately change the physical screen.

## Build the Memory Model

### Start with the screen coordinates

The OLED is a grid 128 pixels wide and 64 pixels high. We name a pixel with `(x, y)`:

- `x` is its column: 0 at the left edge, 127 at the right.
- `y` is its row: 0 at the top, 63 at the bottom.

For example, `(37, 29)` means column 37, row 29. These coordinates describe where the pixel is on the screen. They do not yet tell us where its information is stored.

### What is the buffer?

A **buffer** is a stretch of memory used to hold data. Here, the data describes the pixels that make up the image. In Python, `bytearray(1024)` creates 1,024 numbered, changeable byte slots, each starting at zero:

```text
buffer[0], buffer[1], buffer[2], ... buffer[1023]
```

Each slot stores one byte, a value from 0 through 255. The index tells us which byte slot we mean. It does not mean that one slot stores one screen pixel; the display packs several pixels into a byte.

### One byte holds eight vertical pixels

For the standard MicroPython SSD1306 layout used here, the eight bits of a byte control eight vertically stacked pixels in one screen column. The driver calls this arrangement `MONO_VLSB`: monochrome, vertical, least-significant bit first.

```text
one screen column         one byte
row 0  pixel                 bit 0 (D0)
row 1  pixel                 bit 1 (D1)
row 2  pixel                 bit 2 (D2)
row 3  pixel                 bit 3 (D3)
row 4  pixel                 bit 4 (D4)
row 5  pixel                 bit 5 (D5)
row 6  pixel                 bit 6 (D6)
row 7  pixel                 bit 7 (D7)
```

Within each group, bit 0 represents the top pixel and bit 7 the bottom. For example, `00000001` turns on the top pixel; `10000000` turns on the bottom one. The binary digits are usually written left-to-right as bit 7 down to bit 0, so the printed order runs opposite to the physical top-to-bottom order.

### What is a page?

A **page** is a horizontal band of eight screen rows. It stretches across the full 128-pixel width. Since one byte represents eight vertical pixels in one column, each column in that band uses one byte:

```text
Page 0: rows  0–7   → 128 bytes, one byte for each x-column
Page 1: rows  8–15  → 128 bytes
Page 2: rows 16–23  → 128 bytes
Page 3: rows 24–31  → 128 bytes
  ...
Page 7: rows 56–63  → 128 bytes
```

A page is not a separate display or a single row. It is one eight-row-tall strip. The pages are stored consecutively in the buffer:

| Page | Screen rows | Byte indices in the buffer |
| ---: | --- | --- |
| 0 | 0–7 | 0–127 |
| 1 | 8–15 | 128–255 |
| 2 | 16–23 | 256–383 |
| 3 | 24–31 | 384–511 |
| … | … | … |
| 7 | 56–63 | 896–1023 |

That also checks our memory count: 8 pages × 128 bytes per page = 1,024 bytes.

### From `(x, y)` to page, byte, and bit

Now each part of the mapping has a meaning:

1. Divide `y` by 8 to find which page contains that row.
2. The remainder after dividing `y` by 8 is the bit position inside the byte.
3. Each page uses `width` bytes, so skip `page * width` bytes, then move `x` bytes across that page.
4. Shift a `1` left by the bit number to make a mask for that pixel.

That gives us four expressions:

```python
page = y // 8
bit = y % 8
index = page * width + x
mask = 1 << bit
```

The standard display in this lesson is 128 pixels wide, so `width` is 128. Using the name `width` makes clear what that number means and lets the same formula work for another display width.

### Walk through `(37, 29)` once

The row is `y = 29`. Page 3 covers rows 24 through 31, so row 29 is in Page 3. It is the sixth row of that page when counting from zero:

```text
page = 29 // 8 = 3
bit  = 29 % 8  = 5
```

Page 3 starts after three complete pages. Each page has 128 bytes, and column 37 is 37 bytes from the start of the page:

```text
index = 3 * 128 + 37 = 421
mask  = 1 << 5 = 00100000 = 0x20
```

So the answer to our driving question is: change bit 5 of `buffer[421]`. We have not changed the display yet; we have only located the pixel's stored bit. The questions below give you practice deriving and using each part of this model.

## Check the Model

### Q1: Does the buffer size tell us a pixel's address?

**Problem:** We know the display image needs 1,024 bytes. Does that number alone tell us which byte holds pixel `(37, 29)`? What other parts of the memory model do we need?

{{< hints >}}
- The size tells us how many byte slots are available.
- We also need to know what a byte represents and how the screen is divided into pages.
{{< /hints >}}

{{< answer >}}
No. The size tells us the buffer's capacity, not the meaning of each index. To locate a pixel, we need the page layout, the column's byte position within that page, and the bit's position inside that byte. The model above supplies those missing connections.
{{< /answer >}}

## One Byte, Eight Vertical Pixels

### Q2: What part of the screen does one byte represent?

**Problem:** A byte has eight bits. Sketch the group of screen pixels represented by one byte in this display layout.

{{< hints >}}
- The SSD1306 groups pixels vertically, not horizontally.
- Picture one column, eight pixels tall.
{{< /hints >}}

{{< answer >}}
One byte controls eight vertically stacked pixels in a single screen column. For the orientation used here, D0 is the top pixel and D7 is the bottom:

```text
screen column       byte bits
    pixel             D0
    pixel             D1
    pixel             D2
    pixel             D3
    pixel             D4
    pixel             D5
    pixel             D6
    pixel             D7
```

So one byte represents one column across an eight-pixel-high strip.
{{< /answer >}}

### Q3: What do `00000001` and `10000000` look like?

**Problem:** For each byte, identify which of its eight vertical pixels is on.

{{< hints >}}
- The rightmost digit is bit 0; the leftmost is bit 7.
- Bit 0 is at the top of this group, and bit 7 is at the bottom.
{{< /hints >}}

{{< answer >}}
`00000001` sets only bit 0, so the top pixel is on. `10000000` sets only bit 7, so the bottom pixel is on:

```text
00000001       10000000
D0  ●          D0  ○
D1  ○          D1  ○
D2  ○          D2  ○
D3  ○          D3  ○
D4  ○          D4  ○
D5  ○          D5  ○
D6  ○          D6  ○
D7  ○          D7  ●
```

Binary is written from bit 7 on the left to bit 0 on the right, while physical pixels run from D0 at the top to D7 at the bottom. Keep the direction straight.
{{< /answer >}}

### Q4: Decode `0x2D` as a vertical pattern.

**Problem:** Convert `0x2D` to binary, then list which of the eight pixels are on from top to bottom.

{{< hints >}}
- Convert each hex digit separately: `2` is `0010` and `D` is `1101`.
- The rightmost bit, D0, is the top pixel.
{{< /hints >}}

{{< answer >}}
`0x2D` is `0010 1101`. Read the bits from D0 upward to get the physical pattern:

```text
D0  1  ●
D1  0  ○
D2  1  ●
D3  1  ●
D4  0  ○
D5  1  ●
D6  0  ○
D7  0  ○
```

From top to bottom: on, off, on, on, off, on, off, off.
{{< /answer >}}

## Divide the Screen into Pages

### Q5: How many pages fit on a 64-pixel-high display?

**Problem:** Each byte represents eight vertical pixels. How many eight-pixel groups fit in a display that is 64 pixels tall?

{{< hints >}}
- Divide the display height by the height represented by one byte.
- Each group is called a page.
{{< /hints >}}

{{< answer >}}
`64 ÷ 8 = 8`, so the screen has eight pages. A page is a memory-layout group, not a separate screen:

| Page | Rows |
| --- | --- |
| 0 | 0–7 |
| 1 | 8–15 |
| 2 | 16–23 |
| 3 | 24–31 |
| 4 | 32–39 |
| 5 | 40–47 |
| 6 | 48–55 |
| 7 | 56–63 |
{{< /answer >}}

### Q6: How many bytes are in one page?

**Problem:** A page is 128 pixels wide and eight pixels tall. If one byte controls eight vertical pixels in one column, how many bytes does a page need? Check that all pages account for the whole buffer.

{{< hints >}}
- Count the columns across one page.
- There is one byte for each column.
{{< /hints >}}

{{< answer >}}
There are 128 columns, so a page needs 128 bytes. Across eight pages:

```text
8 pages × 128 bytes = 1,024 bytes
```

That matches our original framebuffer size. The two ways of counting the memory agree.
{{< /answer >}}

## Find a Page and Bit from `y`

### Q7: Which page contains row `y`?

**Problem:** Page 0 contains rows 0–7, Page 1 contains rows 8–15, and so on. Find a rule that maps `y` to a page, then test `y = 3, 8, 19, 29, 63`.

{{< hints >}}
- Each page contains eight rows.
- Integer division discards the remainder.
{{< /hints >}}

{{< answer >}}
Use integer division:

```python
page = y // 8
```

The examples are `3 // 8 = 0`, `8 // 8 = 1`, `19 // 8 = 2`, `29 // 8 = 3`, and `63 // 8 = 7`. The result tells us which eight-row group contains the pixel.
{{< /answer >}}

### Q8: Which bit within that page represents row `y`?

**Problem:** Row 29 is in Page 3. Find an operation that gives its position, from 0 through 7, inside that page.

{{< hints >}}
- Subtracting the page's first row would work.
- The remainder after division by 8 gives the same result.
{{< /hints >}}

{{< answer >}}
Use modulo:

```python
bit = y % 8
```

For `y = 29`, `29 % 8 = 5`. So row 29 uses bit 5 in a byte on Page 3. Integer division finds the group; modulo finds the position inside it.
{{< /answer >}}

### Q9: Calculate the page and bit for several rows.

**Problem:** Without code, find `page = y // 8` and `bit = y % 8` for `y = 0, 7, 8, 15, 16, 37, 63`.

{{< hints >}}
- Divide each row by 8; the quotient is the page.
- The remainder is the bit position.
{{< /hints >}}

{{< answer >}}
| `y` | Page | Bit |
| ---: | ---: | ---: |
| 0 | 0 | 0 |
| 7 | 0 | 7 |
| 8 | 1 | 0 |
| 15 | 1 | 7 |
| 16 | 2 | 0 |
| 37 | 4 | 5 |
| 63 | 7 | 7 |

Notice the boundary: row 7 is the last bit of Page 0; row 8 starts Page 1 at bit 0.
{{< /answer >}}

## Find the Byte from Page and `x`

### Q10: Where does Page 3 begin in the buffer?

**Problem:** Each page contains 128 bytes. What is the index of the first byte in Page 3?

{{< hints >}}
- Pages 0, 1, and 2 come before Page 3.
- Multiply the number of earlier pages by 128.
{{< /hints >}}

{{< answer >}}
Three complete pages come first: `3 × 128 = 384`. Page 3 begins at `buffer[384]`. In general, `page_start = page * 128`.
{{< /answer >}}

### Q11: Which byte in Page 3 represents column 37?

**Problem:** Page 3 begins at byte 384. Each column uses one byte. Find the buffer index for column `x = 37` on that page.

{{< hints >}}
- Column 0 is the first byte in the page.
- Add the column number to the page's starting index.
{{< /hints >}}

{{< answer >}}
`384 + 37 = 421`, so `buffer[421]` stores the eight-pixel group in column 37 on Page 3.
{{< /answer >}}

### Q12: Solve the original coordinate problem.

**Problem:** Find the page, bit, buffer index, and bit mask for pixel `(37, 29)`.

{{< hints >}}
- Use `page = y // 8` and `bit = y % 8`.
- A page has 128 bytes; add `x` to its starting index.
- The mask is a 1 shifted left by the bit number.
{{< /hints >}}

{{< answer >}}
For `x = 37` and `y = 29`:

```text
page  = 29 // 8 = 3
bit   = 29 % 8  = 5
index = 3 × 128 + 37 = 421
mask  = 1 << 5 = 00100000 = 0x20
```

Therefore pixel `(37, 29)` is controlled by bit 5 of `buffer[421]`.
{{< /answer >}}

## Change Pixels in Raw Memory

### Q13: How do you turn this pixel on without changing its neighbors?

**Problem:** The target is bit 5 of `buffer[421]`. Write the operation that sets it while preserving the other seven bits.

{{< hints >}}
- Build a mask with one 1 at bit 5.
- OR preserves a bit when the mask has 0 and sets it when the mask has 1.
{{< /hints >}}

{{< answer >}}
Use the mask with OR:

```python
buffer[421] |= 1 << 5
```

The mask is `00100000`. OR sets bit 5 and leaves every other bit unchanged.
{{< /answer >}}

### Q14: Can you derive the general set-pixel operation?

**Problem:** Replace 37 and 29 with arbitrary coordinates `x` and `y`. Write the expressions for page, bit, index, and mask, then turn the pixel on.

{{< hints >}}
- The row `y` determines both the page and the bit.
- The column `x` selects a byte within that page.
- Combine the index and mask with OR.
{{< /hints >}}

{{< answer >}}
The coordinate mapping is:

```python
page = y // 8
bit = y % 8
index = page * 128 + x
mask = 1 << bit

buffer[index] |= mask
```

That is the core logic behind drawing a pixel. A full function should also check that the coordinates are inside the display.
{{< /answer >}}

### Q15: How can the code support a different display width?

**Problem:** The expression `index = page * 128 + x` assumes the display is always 128 pixels wide. Rewrite it so the mapping can use a width supplied by the program.

{{< hints >}}
- Every page contains one byte per horizontal column.
- The number of columns is the page's byte length.
{{< /hints >}}

{{< answer >}}
Use `width` instead of the literal `128`:

```python
index = page * width + x

def set_pixel(buffer, x, y, width):
    page = y // 8
    bit = y % 8
    index = page * width + x
    buffer[index] |= 1 << bit
```

This version focuses on the mapping. A robust version should also validate the coordinates and buffer dimensions.
{{< /answer >}}

### Q16: How do you turn a pixel off?

**Problem:** Write an operation that clears only the selected pixel and preserves the other seven bits in its byte.

{{< hints >}}
- First make the same one-bit mask.
- Invert the mask, then use AND to preserve every other bit.
{{< /hints >}}

{{< answer >}}
Clear the selected bit with:

```python
buffer[index] &= ~(1 << bit)
```

A combined function can select whether to set or clear it:

```python
def set_pixel(buffer, x, y, width, on):
    page = y // 8
    bit = y % 8
    index = page * width + x
    mask = 1 << bit

    if on:
        buffer[index] |= mask
    else:
        buffer[index] &= ~mask
```

Python integers can be wider than a byte, but assignment back into a `bytearray` stores the result as one byte.
{{< /answer >}}

### Q17: Do the four corners fit in the buffer?

**Problem:** For a 128 × 64 screen, find the byte index and bit for `(0, 0)`, `(127, 0)`, `(0, 63)`, and `(127, 63)`.

{{< hints >}}
- The first row is Page 0, bit 0.
- The last row is Page 7, bit 7.
- Check that the last byte index is one less than the buffer length.
{{< /hints >}}

{{< answer >}}
| Coordinate | Page | Bit | Byte index |
| --- | ---: | ---: | ---: |
| `(0, 0)` | 0 | 0 | 0 |
| `(127, 0)` | 0 | 0 | 127 |
| `(0, 63)` | 7 | 7 | 896 |
| `(127, 63)` | 7 | 7 | 1023 |

The last coordinate lands in byte 1023, the final byte of a 1,024-byte buffer. The boundaries line up.
{{< /answer >}}

### Q18: Can you recover a coordinate from a byte and bit?

**Problem:** A pixel is stored at `buffer[421]`, bit 5. Recover its `(x, y)` coordinate on a 128-pixel-wide display.

{{< hints >}}
- Divide the byte index by the page width to find the page.
- The remainder is the column within that page.
- Convert the page and bit back into a row.
{{< /hints >}}

{{< answer >}}
Work backward:

```text
page = 421 // 128 = 3
x = 421 % 128 = 37
y = page * 8 + bit = 3 * 8 + 5 = 29
```

So the coordinate is `(37, 29)`. The byte index records page and column; the bit records the row within that page.
{{< /answer >}}

## Put the Mapping Together

### Q19: What changes inside the bytearray?

**Problem:** Start with `buffer = bytearray(1024)`. Set pixel `(37, 29)`, then clear pixel `(37, 30)`. What is the final value of `buffer[421]`?

{{< hints >}}
- Pixel `(37, 29)` is bit 5 of byte 421; `(37, 30)` is bit 6 of that same byte.
- Set bit 5, then clear bit 6 without changing the others.
{{< /hints >}}

{{< answer >}}
Setting bit 5 gives `00100000`. Clearing bit 6 leaves it unchanged because bit 6 was already off:

```python
buffer[421] |= 1 << 5
buffer[421] &= ~(1 << 6)
```

The final byte is `00100000`, or `0x20`. We have changed the image data in the Pico's memory. We have not yet explained how that memory reaches the physical screen; that is the next phase.
{{< /answer >}}

### Q20: How does `(x, y)` become one changed pixel?

**Problem:** Explain how a screen coordinate leads to a byte and a bit, then give the operation that turns that pixel on.

{{< hints >}}
- `y` chooses the page and position within that page.
- `x` selects the byte within the page.
- A one-bit mask changes just the target pixel.
{{< /hints >}}

{{< answer >}}
For this page-organized display:

```python
page = y // 8
bit = y % 8
index = page * width + x
mask = 1 << bit
buffer[index] |= mask
```

The page locates a group of eight rows. The index locates the byte for column `x` within that page. The bit selects one row inside that byte. For `(37, 29)` on a 128 × 64 display, that gives byte 421 and bit 5.
{{< /answer >}}

## Next: The Frame Buffer

We can now translate coordinates into bytes and bits, then change that data in a `bytearray`. But the bytes we changed live in the Pico's RAM. Why doesn't a call such as `text()` immediately change the physical screen? What does `show()` do with the frame waiting in memory?

That is Phase 4: **The Frame Buffer**. We will follow a drawing operation from the Pico's RAM to the display and learn why drawing and displaying are separate steps.

[Back to Phase 2: Pictures as Data ←](/post/pictures-as-data/)

## Glossary

| Term | Definition | Example |
| --- | --- | --- |
| Coordinate | A screen location written `(x, y)`, with `x` across and `y` down. | `(37, 29)` means column 37, row 29. |
| Buffer | A region of memory holding the display's pixel data. | `bytearray(1024)` creates 1,024 editable byte slots. |
| Byte | Eight bits; in this layout, one byte stores eight vertical pixels in one column. | `0b00100000` turns on the pixel at bit 5 in that group. |
| Page | A horizontal band eight pixels tall. | Page 3 contains rows 24 through 31. |
| Page number | The eight-row group containing row `y`. | `29 // 8` gives page 3. |
| Bit position | The row's position within its page, numbered 0 through 7. | `29 % 8` gives bit 5. |
| Byte index | The position of a byte in the buffer, starting at zero. | For `(37, 29)`, `3 * 128 + 37` is index 421. |
| Integer division (`//`) | Division that keeps the whole-number quotient. | `29 // 8` is `3`. |
| Modulo (`%`) | The remainder after division. | `29 % 8` is `5`. |
| Bit mask | A value with a selected bit used to change or test that position. | `1 << 5` creates `00100000`. |
| Bitwise OR (`\|=`) | Sets selected bits while preserving the other bits. | `buffer[421] |= 1 << 5` turns on bit 5. |
| `MONO_VLSB` | A monochrome layout packed vertically, with the least-significant bit at the top of each group. | Bit 0 represents the top pixel; bit 7 the bottom. |
