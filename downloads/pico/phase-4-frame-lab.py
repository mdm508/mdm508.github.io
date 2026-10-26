"""Phase 4: draw in RAM, then send the image with show().

Lesson: https://mdm508.github.io/post/the-frame-buffer/

You need the driver file ssd1306.py in the SAME FOLDER on the Pico.
Get it from the Phase 1 kit linked in the lesson, and upload it too;
keeping the driver only in your computer's folder is not enough.

Use the Phase 1 wiring:
GP0 -> SDA, GP1 -> SCL, 3V3 -> VCC, GND -> GND.

Only the setup below runs automatically. You write the experiments.
In VS Code, use MicroPico's Run command, then enter your experiment
commands one at a time at its >>> prompt. In Thonny, use the Shell.
Read the lesson's grey Python-session note before using VS Code.
Stop between commands to inspect the OLED; no input() pauses are needed.
"""
from machine import Pin, I2C
from ssd1306 import SSD1306_I2C


i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=200_000)
oled = SSD1306_I2C(128, 64, i2c)

# Experiment 1 (Q3): prepare versus display.
# Establish a blank display. Draw WAITING in RAM, then stop and inspect
# the OLED. Decide which command will make your prepared word visible.

# Experiment 2 (Q4 and Q7): inspect versus clear.
# Find the buffer's length. With a word visible, clear only RAM and
# inspect the OLED. Then send the blank frame. Explain each result.

# Experiment 3 (Q5 and Q6): methods versus raw bytes.
# Begin with a blank frame and display. Draw pixel (37, 29) and inspect
# its byte in RAM before sending it. Repeat with a raw buffer edit
# that preserves neighboring bits. Use Phase 3 to find the byte and bit.

# Experiment 4 (Q10): assemble a complete frame.
# Prepare READY at (0, 0) and PICO at (0, 16). Send both lines together
# in one transfer, without showing a blank intermediate frame.
