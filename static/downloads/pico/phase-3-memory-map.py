"""Phase 3 starter: map screen coordinates into a raw SSD1306 buffer.

No OLED driver is required. Complete the TODOs as you work through the lesson,
then uncomment the test lines at the bottom.
"""

WIDTH = 128
HEIGHT = 64
PAGE_HEIGHT = 8

# One byte for each column in each 8-pixel-high page.
buffer = bytearray(WIDTH * HEIGHT // PAGE_HEIGHT)


def locate_pixel(x, y):
    """Return (byte_index, bit) for an on-screen coordinate."""
    if not (0 <= x < WIDTH and 0 <= y < HEIGHT):
        raise ValueError("pixel coordinate is outside the display")

    # TODO: calculate the page and bit position from y.
    page = ...
    bit = ...

    # TODO: calculate the byte index using page, WIDTH, and x.
    index = ...
    return index, bit


def set_pixel(x, y, on=True):
    """Set or clear one pixel in buffer without disturbing its neighbors."""
    index, bit = locate_pixel(x, y)

    # TODO: make a one-bit mask, then set or clear that bit in buffer[index].
    mask = ...
    if on:
        ...
    else:
        ...


print("Buffer bytes:", len(buffer))
print("Expected for a 128 x 64 display:", 1024)

# After completing the functions, uncomment and run these checks:
# index, bit = locate_pixel(37, 29)
# print("Pixel (37, 29) is in byte", index, "bit", bit)
# set_pixel(37, 29)
# print("Byte value:", buffer[index], "(expected 32 after the mapping is correct)")
