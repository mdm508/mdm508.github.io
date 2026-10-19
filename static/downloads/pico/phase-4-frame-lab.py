"""Phase 4: draw in RAM, then send the image with show().

Save beside ssd1306.py on the Pico. Use the Phase 1 wiring:
GP0 -> SDA, GP1 -> SCL, 3V3 -> VCC, GND -> GND.
Run in Thonny; press Enter in the Shell at each checkpoint.
"""
from machine import Pin, I2C
from ssd1306 import SSD1306_I2C


i2c = I2C(0, scl=Pin(1), sda=Pin(0), freq=200_000)
oled = SSD1306_I2C(128, 64, i2c)

# Establish a known starting image.
oled.fill(0)
oled.show()

# Experiment 1: drawing changes RAM before the display.
oled.text("WAITING", 0, 0)
print("Buffer length:", len(oled.buffer))
input("RAM holds WAITING. Predict the OLED, then press Enter to show it. ")
oled.show()

# Experiment 2: clearing is also a drawing operation.
oled.fill(0)
input("RAM is clear. Predict the OLED, then press Enter to send the blank frame. ")
oled.show()

# Experiment 3 (Q5): complete the TODOs, then uncomment the lines.
# oled.pixel(37, 29, 1)
# print("Byte 421:", oled.buffer[421])  # Expected: 32
# TODO: pause so you can inspect the unchanged display.
# TODO: send the prepared frame to the OLED.

# Experiment 4 (Q10): put fill(0), two text() calls, and show() here.
# Prepare both text lines before sending the completed frame once.
