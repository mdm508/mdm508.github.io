PHASE 1: MEET THE OLED
======================

This folder contains the two files needed to run the Phase 1 starter program:

  main.py       The program that connects to the OLED and draws a first screen.
  ssd1306.py    The MicroPython SSD1306 display driver.

HARDWARE
--------

This starter program expects a 128 x 64 SSD1306 I2C OLED connected as follows:

  OLED SDA  -> Pico GP0
  OLED SCL  -> Pico GP1
  OLED VCC  -> Pico 3V3
  OLED GND  -> Pico GND

Power off the Pico before changing any wires. Check your display's pin labels;
do not assume the pins are in the same order on every module.

RUN IT WITH THONNY
------------------

1. Extract this ZIP on your computer.
2. Open Thonny and connect it to the Raspberry Pi Pico running MicroPython.
3. In Thonny, open main.py from the extracted folder.
4. In the file pane, open ssd1306.py too. Save both files to the Pico so they
   appear together in the Pico's file list. Do not rename ssd1306.py.
5. Run main.py. The Shell prints the I2C devices it finds; the OLED should show
   two short lines of text.

The program uses I2C controller 0, GP0 for SDA, GP1 for SCL, and the driver's
default OLED address (0x3C). If the scan does not find the display, stop and
check the wiring and module before continuing.

ABOUT THE DRIVER
----------------

ssd1306.py is copied from the official MicroPython Library repository:
https://github.com/micropython/micropython-lib/blob/a08087249fda8a7994f7c54ccaad29fb9fcc448a/micropython/drivers/display/ssd1306/ssd1306.py

The source is distributed under the MIT License. The license notice is in
LICENSE.txt. The driver is included unchanged.
