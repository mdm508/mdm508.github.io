"""Phase 5: drawing graphics and making frames change over time.

Lesson: https://mdm508.github.io/post/drawing-graphics/

You need ssd1306.py in the SAME FOLDER on the Pico as this lab file.
Get the driver from the Phase 1 kit linked in the lesson and upload it too.

Wiring: GP0 -> SDA, GP1 -> SCL, 3V3 -> VCC, GND -> GND.

Only setup runs below. Write your own experiment code using the prompts.
Use MicroPico's Run command in VS Code, or run setup in Thonny.
Read the Python-session note linked in the lesson before using >>>.
Use the Pico's MicroPico terminal or Thonny Shell for short experiments.
For a function or animation loop, write the block in this file and run it
with setup. The animation should stop on its own after a finite loop.
No input() pauses are needed.
"""
from machine import Pin, I2C
from ssd1306 import SSD1306_I2C
from time import sleep_ms


WIDTH = 128
HEIGHT = 64
i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=200_000)
oled = SSD1306_I2C(WIDTH, HEIGHT, i2c)

# Experiment 1 (Q2-Q4): compare drawing primitives.
# Draw a line, an outlined rectangle, and a filled rectangle, one at a
# time. Predict their last occupied coordinates before displaying them.

# Experiment 2 (Q5-Q6): compose a complete scene.
# Center a short heading. Add a border, ground line, and small square.
# Draw every part before sending the frame once.

# Experiment 3 (Q7): describe the scene with a function.
# Give your function an x argument. Rebuild the entire picture in RAM,
# using x to position the moving square. Keep show() outside the function.

# Experiment 4 (Q8-Q11): animate and investigate.
# Use a finite loop to move the square while keeping it fully on screen.
# Send each prepared frame, then pause briefly. Compare keeping versus
# clearing old pixels, and try two different pause lengths.

# Experiment 5 (Q12): make it yours.
# Design a scene with two drawing primitives, a heading, and one moving
# part. State which values change, which stay fixed, and where it stops.
