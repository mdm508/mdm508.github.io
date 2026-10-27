"""Phase 1: meet the OLED. Only connection setup runs below.

Lesson: https://mdm508.github.io/post/meet-the-oled/
Keep ssd1306.py in the SAME FOLDER on the Pico as this file.
Save this starter on the Pico as main.py. Run it with Thonny or MicroPico.
Wiring: SDA=GP0, SCL=GP1, VCC=3V3(OUT), GND=GND.

First run setup and check the device list. Follow "Your First Text" in the
lesson to create oled and add the first picture below this setup.
For each experiment, edit the drawing section and rerun the WHOLE file.
No input() pauses or preserved interactive session are required.
"""

from machine import Pin, I2C
from ssd1306 import SSD1306_I2C

i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=200_000)
print("I2C devices:", i2c.scan())

# Your First Text: add the display-object creation and drawing block
# from the lesson. Keep that object-creation line above later experiments.

# Q1: Personalize the first message without changing the connection.
# Q2: Repair a variable-name mismatch and explain each object's job.
# Q3: Find the bottom-right pixel, then move one left and two up.
# Q4: Repair the order of drawing and showing.
# Homework: explain the terms, then try these exercises without copying:
# Q5: Design a welcome screen with three messages and four corner pixels.
# Q6 (challenging): Move a dot while preserving the existing message.
# Q7 (very challenging): Leave different pictures prepared and displayed.
