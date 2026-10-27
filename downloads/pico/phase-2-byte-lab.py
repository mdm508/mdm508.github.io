"""Phase 2: build and edit byte values.

Lesson: https://mdm508.github.io/post/pictures-as-data/
No OLED or ssd1306.py driver is needed for this lab.
Use ordinary Python on your computer or MicroPython on the Pico.

Only a starting value and readiness message run below. Write one experiment
at a time beneath setup and run the whole file. Predict before printing.
Keep the lesson's answers closed while you work.
"""

value = 0
print("Byte lab ready. Write your experiment below setup.")

# Q1: Build 173 from bit weights and check its binary form.
# Q2: Use NOT and AND to clear bit 5 of 0b10110100, then inspect bit 2.
# Use explicit binary masks here; shifting comes next.
# Q3: Set bit 4 twice with OR; compare adding its weight twice.
# Q4: Use 1 << bit to select bit 6, then try bit 0 and bit 7.
# bit = 6
# mask = 0  # TODO: create the mask from bit, using a shift.
# value = 0
# TODO: turn the selected bit on using your mask.
# print(bin(mask), value)
# Q5: Predict shifts of 0b00001100 left and right by two positions.
# Does printing a shifted expression change the original value?
# Q6: Compare the three written forms of the display's address.

# Homework
# Q7: Convert 0xA6, 0b01011010, and 0x0F into binary, hex, and decimal.
# Predict first, then uncomment this check:
# values = (0xA6, 0b01011010, 0x0F)
# for value in values:
#     print(value, bin(value), hex(value))
#
# Q8: Shift 0x2D left by one and right by two. Can shifting back recover it?
# Does 0x81 << 1 fit in a byte? Keep its lowest eight bits explicitly.
# value = 0x2D
# print(bin(value << 1), hex(value << 1))
# print(bin(value >> 2), hex(value >> 2))
# print((value >> 2) << 2)
#
# Q9: Start with 0x81; use one combined mask to set bits 1, 3, and 6.
# value = 0x81
# mask = 0        # TODO: combine the three one-bit masks.
# result = value  # TODO: apply the mask while preserving other bits.
# print(bin(mask), hex(mask))
# print(bin(result), hex(result))
#
# Q10 (challenging): Use a mask for bits 1 and 4 to filter and clear 0xD6.
# Does bool(value & mask) test ANY selected bit or ALL of them?
# Test the claim with value = 0x02, then write an ALL-bits comparison.
#
# Q11: Budget pixel data for 128x64 mono, 256x128 mono, and 128x64 RGB.
# Monochrome uses one bit per pixel; this RGB format uses three bytes.
#
# Q12 (very challenging): Write change_bit(value, bit, on).
# Uncomment this scaffold when you reach Q12, then replace pass:
# def change_bit(value, bit, on):
#     # Return the new byte value.
#     pass
#
# print(change_bit(0xC3, 3, True))   # Expected: 203 (0xCB)
# print(change_bit(0xCB, 3, False))  # Expected: 195 (0xC3)
# Then build a byte by looping over bits (0, 2, 3, 5), keeping each return.
# Inspect the finished byte from bit 0 through bit 7 with masks and a loop.
#
# Q13 (very challenging): Try the lesson's RGB color challenge, then write
# pack_rgb(red, green, blue) and unpack_rgb(color). Assume valid inputs.
# def pack_rgb(red, green, blue):
#     # Leave eight bit positions for each channel.
#     pass
#
# def unpack_rgb(color):
#     # Return (red, green, blue).
#     pass
#
# print(pack_rgb(0x20, 0x40, 0x80) == 0x204080)  # Expected: True
# print(pack_rgb(0, 0, 255) == 0x0000FF)         # Expected: True
# print(unpack_rgb(0x12ABF0))                  # Expected: (18, 171, 240)
