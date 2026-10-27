"""Phase 5: compose a scene and animate successive frames.

Lesson: https://mdm508.github.io/post/drawing-graphics/
Keep ssd1306.py in the SAME FOLDER ON THE PICO as this file.
Upload the driver from the Phase 1 kit too; a laptop copy is not enough.
Wiring: GP0 -> SDA, GP1 -> SCL, 3V3(OUT) -> VCC, GND -> GND.

Only setup runs below. Write your own experiments beneath it, then run
this WHOLE file on the Pico in Thonny or with MicroPico in VS Code.
Replace earlier drawing experiments; keep a function when a later problem
needs it. Use finite loops so the animation finishes by itself.

No input() pauses or preserved session are required. If you choose to use
>>> instead, the lesson links an optional MicroPico Python-session note.
"""

from machine import Pin, I2C
from ssd1306 import SSD1306_I2C
from time import sleep_ms

WIDTH = 128
HEIGHT = 64
i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=200_000)
print("I2C devices:", i2c.scan())
oled = SSD1306_I2C(WIDTH, HEIGHT, i2c)

# Q1: Compare a line's ending coordinate with a horizontal line's length.
# Q2: Fit an outlined 8 x 8 square at the edge, then move one pixel farther.
# Q3: Place two adjacent character cells without gaps or overlaps.
# Q4: Write draw_scene(x), keeping preparation separate from show().

# Homework
# Q5: Center Hi Yush on a lit panel with four pixels of padding.
# Q6 (challenging): Animate through the final fitting x; count frames and
# image bytes. Keep your scene function above this finite loop.
# Q7 (very challenging): Trace and repair a loop that shows before drawing.
