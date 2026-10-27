"""Phase 4: prepare a frame in RAM, then choose when to send it.

Lesson: https://mdm508.github.io/post/the-frame-buffer/
Keep ssd1306.py in the SAME FOLDER ON THE PICO as this file.
Upload the driver from the Phase 1 kit too; a laptop copy is not enough.
Wiring: GP0 -> SDA, GP1 -> SCL, 3V3(OUT) -> VCC, GND -> GND.

Only setup runs below. Write one experiment at a time beneath it and run
the WHOLE file on the Pico in Thonny or with MicroPico in VS Code.
Keep setup; replace earlier experiment blocks unless asked to append.
Setup initializes and clears the physical display. Establish each
experiment's starting image within that same run.

No input() pauses or preserved Python session are required. Comments do
not pause a running script. The optional session note in the lesson is
only for students choosing to experiment command by command at >>>.
"""

from machine import Pin, I2C
from ssd1306 import SSD1306_I2C

WIDTH = 128
HEIGHT = 64
i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=200_000)
print("I2C devices:", i2c.scan())
oled = SSD1306_I2C(WIDTH, HEIGHT, i2c)

# Q1: Use the browser toy to compare the two images after edits and clears.
# Q2: Draw (37, 29), inspect its byte and pixel state, then try a raw edit.
# Q3: Trace prepared and displayed images through the OLD/NEW sequence.
# Q4: Repeat a transfer without drawing; reason about its contents and cost.

# Homework
# Q5: Send two complete announcements with no blank intermediate transfer.
# Q6 (challenging): Compare sending after every dot with sending once.
# Q7 (very challenging): Save two byte snapshots, restore one for display,
# then leave the other prepared in RAM without sending it yet.
