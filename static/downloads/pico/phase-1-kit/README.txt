PHASE 1: MEET THE OLED
======================

Lesson: https://mdm508.github.io/post/meet-the-oled/

FILES
-----
main.py       Connection setup and prompts for your experiments.
ssd1306.py    The official MicroPython SSD1306 display driver.
LICENSE.txt  The driver's MIT license notice.

Keep main.py and ssd1306.py together in the SAME FOLDER on the Pico.
The driver being on your computer alone is not enough.

HARDWARE
--------
Use a 128 x 64 SSD1306 I2C OLED:
  OLED SDA -> Pico GP0
  OLED SCL -> Pico GP1
  OLED VCC -> Pico 3V3(OUT)
  OLED GND -> Pico GND

Disconnect USB and any battery power before moving wires. Match the
labels on your actual boards; OLED pin order can vary. The project guide
linked in the lesson shows UPS breakout and breadboard wiring options.

RUN IT
------
1. Extract the ZIP on your computer.
2. Connect Thonny or VS Code with MicroPico to your Pico running MicroPython.
3. Open main.py and copy/save it and ssd1306.py together onto the Pico.
4. Run main.py ON THE PICO. It prints the I2C addresses that answer.
   Our OLED commonly appears as 60 (0x3C). If the list is empty or an
   error appears, check the connection before adding drawing code.
5. Follow "Your First Text" in the lesson to create the oled object and
   add the first drawing block. Rerun the whole file to display the words.

The starter only runs connection setup: no image is drawn yet. Write your
experiments below setup, following the lesson's problems. Keep the setup
and oled object-creation line when replacing a drawing experiment.
Use short messages at first. No input() pauses are needed.

ABOUT THE DRIVER
----------------
ssd1306.py is copied unchanged from the official MicroPython Library:
https://github.com/micropython/micropython-lib/blob/a08087249fda8a7994f7c54ccaad29fb9fcc448a/micropython/drivers/display/ssd1306/ssd1306.py

Its source is distributed under the MIT License (LICENSE.txt). We borrow
the driver now, investigate it in later lessons, and work toward building
a small SSD1306-specific driver ourselves using MicroPython's tools.
