---
title: "Pictures as Data: Binary, Hex, and Bit Masks"
date: 2026-09-06T12:00:00-07:00
draft: false
description: "Represent monochrome OLED pixels as bits, translate bytes between binary and hexadecimal, and manipulate individual bits with Python masks."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "binary", "hexadecimal"]
summary: "Move from OLED pixels to bytes, binary, hexadecimal, shifts, and masks—then practice the connections in an interactive byte-building game."
reading_time: 120
---

This lesson continues [Meet the OLED: Pixels, Coordinates, and `show()`](/post/meet-the-oled/). We know that drawing commands prepare an image in memory before `show()` sends it to the display. Now we can ask what that image is made of.

> How can thousands of physical pixels be represented and manipulated using nothing but numbers?

Our goal is not to memorize isolated conversions. It is to construct and change the exact bit patterns that will eventually control hardware.

## From Pixels to Bytes

### Q1: Does one monochrome pixel need a whole byte?

The OLED gives each pixel only two possible states: off or on. Someone argues that a pixel must use one byte because computers store information in bytes. What is wrong with that reasoning?

{{< answer >}}
It confuses a common storage unit with the amount of information required.

A monochrome pixel has two states, and one bit has two states:

```text
0 → off
1 → on
```

One bit therefore contains enough information to describe one pixel. A byte offers 256 possible patterns, far more than a single two-state pixel needs.

This tells us the theoretical information required. A language or device may organize that information in larger units, but that is a separate implementation question.
{{< /answer >}}

### Q2: How large is one complete screen image?

Our display is 128 pixels wide and 64 pixels tall. Calculate the minimum number of bytes required for one monochrome frame. Then predict what happens if both dimensions double to 256 × 128.

{{< answer >}}
The current display contains:

```text
128 × 64 = 8,192 pixels
8,192 pixels × 1 bit = 8,192 bits
8,192 bits ÷ 8 = 1,024 bytes
```

Doubling the width doubles the pixel count. Doubling the height doubles it again, so the larger frame requires four times as much memory:

```text
256 × 128 = 32,768 bits = 4,096 bytes
```

Image memory grows with area. Doubling both dimensions quadruples the raw pixel data.
{{< /answer >}}

## Read and Construct a Byte

An eight-bit byte has positions numbered from 7 down to 0. Each position represents a power of two.

```text
bit:       7   6   5   4   3   2   1   0
weight:  128  64  32  16   8   4   2   1
```

### Q3: What value does `00101101` represent?

Identify the positions containing `1` before calculating the decimal value.

{{< answer >}}
Bits 5, 3, 2, and 0 are on:

```text
bit:    7 6 5 4 3 2 1 0
state:  0 0 1 0 1 1 0 1
weight:     32    8 4   1
```

Add only those weights:

```text
32 + 8 + 4 + 1 = 45
```

Therefore `00101101₂` represents `45₁₀`. The durable skill is seeing which powers of two are present, not memorizing that particular result.
{{< /answer >}}

### Q4: How can you build the byte for decimal 173?

Work backward by decomposing 173 into powers of two. Do not begin with repeated division.

{{< answer >}}
Choose the largest available power of two without exceeding the remaining value:

```text
173 = 128 + 32 + 8 + 4 + 1
```

Place `1` under those weights and `0` everywhere else:

```text
weight: 128 64 32 16 8 4 2 1
state:    1  0  1  0 1 1 0 1
```

The byte is `10101101`. Working from powers of two reinforces what every position means, which will matter when we begin targeting individual bits.
{{< /answer >}}

## Use Hexadecimal as Compact Binary

Binary shows every bit, but it becomes tiring to read. Hexadecimal stays compact while preserving the structure because one hexadecimal digit represents exactly four bits.

```text
0  0000    4  0100    8  1000    C  1100
1  0001    5  0101    9  1001    D  1101
2  0010    6  0110    A  1010    E  1110
3  0011    7  0111    B  1011    F  1111
```

### Q5: Why might hardware documentation prefer `0x2D`?

The same byte can be written as `00101101` or `0x2D`. Why is the second form useful without hiding the bit structure?

{{< answer >}}
Split the binary byte into two four-bit groups, called nibbles:

```text
0010 1101
  2    D
```

Each nibble becomes one hexadecimal digit, so the byte becomes `0x2D`. The `0x` prefix tells Python and the reader that the following digits are hexadecimal.

Hardware documentation often uses values such as `0x3C`, `0x81`, `0xAE`, and `0xFF` because they are shorter than binary while remaining easy to expand into groups of four bits.
{{< /answer >}}

### Q6: Can you convert hex directly to binary?

Convert `0xA7`, `0x3C`, `0xF0`, and `0x55` without passing through decimal.

{{< answer >}}
Replace each hex digit with its four-bit group:

```text
0xA7 → 1010 0111 → 10100111
0x3C → 0011 1100 → 00111100
0xF0 → 1111 0000 → 11110000
0x55 → 0101 0101 → 01010101
```

The alternating pattern in `0x55` is especially easy to recognize. Its opposite is `0xAA`, or `10101010`. Patterns such as `0x00`, `0xFF`, `0x55`, and `0xAA` are useful when testing hardware because their shapes are unmistakable.
{{< /answer >}}

### Q7: Are `0x3C`, `60`, and `0b00111100` different values?

{{< answer >}}
They are different written representations of the same numerical value:

```text
60            decimal
0x3C          hexadecimal
0b00111100    binary
```

The prefixes tell Python how to interpret the source text. They do not create three different values. This resembles writing the same quantity as `1/2`, `0.5`, or `50%`.

Representation is how we write a value. The value is the quantity being represented.
{{< /answer >}}

## Construct Patterns with Shifts and OR

The expression `1 << bit` moves a single `1` into the requested position. It produces a **mask** that selects one bit.

### Q8: How can you turn on bits 6, 3, and 1?

Write the byte first. Then construct the same value in Python using shifts.

{{< answer >}}
The requested positions produce this pattern:

```text
bit:    7 6 5 4 3 2 1 0
state:  0 1 0 0 1 0 1 0
```

Each shift creates one mask:

```text
1 << 6  → 01000000
1 << 3  → 00001000
1 << 1  → 00000010
```

Bitwise OR combines them:

```python
value = (1 << 6) | (1 << 3) | (1 << 1)
```

The result is `01001010`, or `0x4A`. We are no longer merely reading a pattern; we are constructing it deliberately.
{{< /answer >}}

### Q9: How can OR turn on one bit without disturbing the others?

Predict the result:

```python
value = 0b10100001
value = value | (1 << 3)
```

{{< answer >}}
The mask contains a `1` only at bit 3:

```text
  10100001
| 00001000
  --------
  10101001
```

OR produces `1` when either input bit is `1`. The mask's zeroes therefore preserve every other position while its single `1` turns bit 3 on.

Python offers a shorter assignment form:

```python
value |= 1 << 3
```
{{< /answer >}}

## Clear and Test Individual Bits

### Q10: How can you turn bit 5 off?

Start with `11101111`. Clear bit 5 while leaving every other position unchanged.

{{< answer >}}
AND preserves a bit when the mask contains `1` and clears it when the mask contains `0`. We therefore need `11011111`: zero at bit 5, one everywhere else.

```text
  11101111
& 11011111
  --------
  11001111
```

In Python:

```python
value &= ~(1 << 5)
```

Python integers are not limited to eight bits, so `~(1 << 5)` is a negative integer if printed by itself. The AND expression still clears the intended bit. When you need to display or transmit the mask as an explicit byte, keep only its low eight bits:

```python
mask = ~(1 << 5) & 0xFF  # 0b11011111
value &= mask
```
{{< /answer >}}

### Q11: How can you test bit 2 without changing the byte?

```python
value = 0b10110100
```

Use a mask and `&` to determine whether bit 2 is on.

{{< answer >}}
Create a mask containing a `1` only at bit 2:

```python
mask = 1 << 2
```

Then use AND:

```text
  10110100
& 00000100
  --------
  00000100
```

The nonzero result means the bit is on. Python can test it directly:

```python
if value & (1 << 2):
    print("bit is on")
```

If bit 2 were off, the result would be zero. The operation reads the selected bit without modifying `value`.
{{< /answer >}}

### Q12: Why isn't addition a safe replacement for OR?

Henry wants to turn on bit 4:

```python
value = value + (1 << 4)
```

Find a value for which this produces the wrong result.

{{< answer >}}
Addition appears to work only when bit 4 is currently zero. If it is already on, adding another `1 << 4` causes a carry:

```text
  00010000
+ 00010000
  --------
  00100000
```

Bit 4 turns off and bit 5 turns on. OR behaves differently:

```text
  00010000
| 00010000
  --------
  00010000
```

Arithmetic addition changes a number by a quantity. Bitwise OR combines positions according to a truth rule. Use OR when the job is to turn a selected bit on.
{{< /answer >}}

## Recognize Useful Test Patterns

### Q13: What would `0xAA` look like as eight on/off states?

Without converting through decimal, find its binary pattern and the hex value for the opposite pattern.

{{< answer >}}
Each `A` expands to `1010`:

```text
0xAA → 10101010
```

If each bit controlled one physical element, the result would alternate on and off. The opposite pattern is:

```text
01010101 → 0x55
```

Alternating patterns are good diagnostics. They make stuck, swapped, or unexpectedly grouped positions easier to see than an arbitrary value would.
{{< /answer >}}

### Q14: Can you construct and then modify an arbitrary byte?

Build a byte with bits 7, 6, 3, 1, and 0 on. Give its binary, hexadecimal, and decimal forms; construct it with shifts and OR; then clear bit 6 and give the new binary and hex values.

{{< answer >}}
The original pattern is:

```text
bit:    7 6 5 4 3 2 1 0
state:  1 1 0 0 1 0 1 1
```

That gives:

```text
binary:       11001011
hexadecimal:  0xCB
decimal:      128 + 64 + 8 + 2 + 1 = 203
```

Construct it with one shifted mask per on bit:

```python
value = (
    (1 << 7)
    | (1 << 6)
    | (1 << 3)
    | (1 << 1)
    | (1 << 0)
)
```

Now clear bit 6:

```python
value &= ~(1 << 6)
```

The result is `10001011`, or `0x8B`.
{{< /answer >}}

## Practice: Byte Builder

Each round gives you either a decimal or hexadecimal target. Toggle the eight bits to build the target byte, then supply the missing conversion. A correct answer requires both parts.

{{< byte-trainer >}}

## Prepare for Phase 3

We can now read, construct, test, set, and clear any bit inside a byte. One problem remains hidden: the OLED frame contains 1,024 bytes, so how do coordinates select the right byte and bit?

Suppose we want pixel `(37, 29)`. Which byte contains it? Which bit inside that byte must change? We do not yet have enough information to answer.

That is the next lesson: **Pages and Display Memory**. It will connect screen coordinates to the SSD1306's byte layout.
