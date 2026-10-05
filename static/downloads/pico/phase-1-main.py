"""Phase 1 starter: connect to an SSD1306 OLED and draw a first screen.

Save this file to the Pico as main.py. Install ssd1306.py on the Pico first.
Wiring used in the lesson: SDA=GP0, SCL=GP1, VCC=3V3, GND=GND.
"""

from machine import Pin, I2C
from ssd1306 import SSD1306_I2C

i2c = I2C(
    0,
    scl=Pin(1),
    sda=Pin(0),
    freq=200_000,
)

print("I2C devices:", i2c.scan())

oled = SSD1306_I2C(128, 64, i2c)

oled.fill(0)
oled.text("Hello, yush", 0, 0)
oled.text("Pico WH", 0, 16)
oled.show()
