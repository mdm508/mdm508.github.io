"""Phase 2 starter: inspect and modify eight-bit values.

No OLED driver is required. Run in Thonny or on a MicroPython Pico.
Work through the TODOs alongside the lesson questions.
"""


def show_byte(label, value):
    """Display a value as an eight-bit pattern, hexadecimal, and decimal."""
    value &= 0xFF
    bits = "".join(str((value >> bit) & 1) for bit in range(7, -1, -1))
    print(label, "binary:", bits, "hex:", hex(value), "decimal:", value)


# Start with a known byte. Change it to test other examples.
value = 0b00101101
show_byte("Starting value", value)

# TODO 1: Build 173 from shifted one-bit masks and OR.
# value = ...
# show_byte("Built value", value)

# TODO 2: Turn bit 3 on in 0b10100001 without changing other bits.
# value = 0b10100001
# value |= ...
# show_byte("Bit 3 on", value)

# TODO 3: Clear bit 5 in 0b11101111, keeping the result to eight bits.
# value = 0b11101111
# mask = ...
# value &= mask
# show_byte("Bit 5 cleared", value)

# TODO 4: Test whether bit 2 is on in 0b10110100.
# value = 0b10110100
# print("Bit 2 is on:", ...)

# Compare alternating patterns used to test grouped pixels.
show_byte("Alternating A", 0xAA)
show_byte("Alternating 5", 0x55)
