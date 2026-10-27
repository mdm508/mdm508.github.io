"""Phase 3: map a 2D picture into a flat sequence of bytes.

Lesson: https://mdm508.github.io/post/pages-and-display-memory/
No OLED or ssd1306.py driver is needed. Ordinary Python or MicroPython works.

Only dimensions and an empty buffer are prepared below. Write your own
experiments or functions beneath setup, using the lesson's prompts.
Run the whole file for each experiment; replace earlier experiment code.
The browser toy is 8 columns wide. This starter begins with width 128.
Check which dimensions each problem asks for before using its formula.
"""

WIDTH = 128
HEIGHT = 64
PAGE_HEIGHT = 8
buffer = bytearray(WIDTH * (HEIGHT // PAGE_HEIGHT))
print("Buffer bytes:", len(buffer))

# Q1: Use the browser toy to investigate the boundary between pages.
# Q2: Map a flat-list index in grids with different widths.
# Q3: Calculate the page, bit, byte index, and mask for (37, 29).
# Q4: Repair a whole-byte assignment that erases a neighboring pixel.

# Homework: start each memory experiment with a fresh buffer.
# Q5: Locate and set the four corners of the 128 x 64 picture.
# Q6 (challenging): Decode byte 10, value 0x41, for two different widths.
# Q7 (very challenging): Write a width-aware pixel function that sets and
# clears a bit, preserves neighbors, and rejects out-of-screen coordinates.
