"""Phase 6: read the SSD1306 driver and follow its calls.

Lesson: https://mdm508.github.io/post/the-ssd1306-driver/
Keep ssd1306.py in the SAME FOLDER ON THE PICO as this file.
Use the unchanged driver from the Phase 1 kit, including its MIT license.
A copy on your laptop alone is not enough when running on the Pico.

Run this WHOLE file in MicroPython through Thonny or MicroPico in VS Code.
The driver imports MicroPython's built-in framebuf module. Ordinary desktop
Python usually does not have that module. Q1's standalone Label example
can run in desktop Python in a separate file without the driver import.

Only setup runs below. It sends nothing to an OLED. Write your own code
beneath setup, using the lesson's prompts. Keep any class a later question
needs and replace earlier experiment code. No input() pauses or preserved
session are required. The recording-bus exercises need no OLED connection.
"""

import ssd1306

WIDTH = 128
HEIGHT = 64
print("Driver lab ready. Setup sends nothing; write an experiment below.")

# Q1: Keep the lesson's Label class. Create two instances and predict which
# attribute changes when you call first.rename(...).
# Q2: Read the driver to locate text(), show(), and write_data().
# Q3: Trace why self.temp must exist before super().__init__(...) runs.
# Do not edit the working driver to break its setup order.
# Q4: Predict show() ranges and image size for 128 x 32, then count two sends.

# Homework: uncomment a scaffold only when you are ready to implement it.
# Q5: Complete a recording connection. Copy byte contents into every event.
# class RecordingI2C:
#     def __init__(self):
#         self.events = []
#
#     def writeto(self, address, data):
#         # Append ("writeto", address, an immutable byte snapshot).
#         # Return the byte count.
#         pass
#
#     def writevto(self, address, parts):
#         # Join parts, append ("writevto", address, payload), and count bytes.
#         pass
#
# bus = RecordingI2C()
# scratch = bytearray([0x80, 0xA6])
# bus.writeto(0x3C, scratch)
# scratch[1] = 0xA7
# print(bus.events[0][2] == b"\x80\xa6")  # Expected: True
# bus.writevto(0x3C, [b"\x40", bytearray([0x20, 0x00])])
# print(bus.events[1][2] == b"\x40\x20\x00")  # Expected: True
# Then clear bus.events and construct an SSD1306_I2C with this bus.
# Inspect its final event and explain where the automatic frame came from.

# Q6 (challenging): Prepare and show a dot at (37, 29), then save a snapshot
# and clear the event history. Does invert(1) change RAM or send image data?
# Compare a later show() payload with the saved image. Restore normal output.

# Q7 (very challenging): Add counters without removing the inherited transfer.
# class CountingOLED(ssd1306.SSD1306_I2C):
#     def __init__(self, width, height, bus):
#         # Initialize counters and the display, in the required order.
#         pass
#
#     def write_data(self, buf):
#         # Count one frame and its image bytes, then preserve the transfer.
#         pass
#
# bus = RecordingI2C()
# screen = CountingOLED(128, 64, bus)
# print(screen.frames, screen.image_bytes)  # Expected: 1 1024
# for x in (0, 8, 16):
#     screen.fill(0)
#     screen.pixel(x, 0, 1)
#     screen.show()
# print(screen.frames, screen.image_bytes)  # Expected: 4 4096
# Check that four writevto events reached the recorder too.
# What changes if you use height 32 instead of 64?
