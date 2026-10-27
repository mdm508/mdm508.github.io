---
title: "Phase 2: Pictures as Data — Binary, Hex, and Bit Masks"
date: 2026-09-06T12:00:00-07:00
draft: false
description: "Represent monochrome pixels with bits, read binary and hexadecimal, and use masks to set, clear, and inspect individual bits."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics", "binary", "hexadecimal"]
summary: "Build and edit a picture's smallest pieces: bits and bytes. Explore binary and hex in an interactive byte-building game."
reading_time: 120
toc_depth: 3
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/pico-oled-project/">Pico OLED project: guide and lesson roadmap</a>. Previously: <a href="/post/meet-the-oled/">Phase 1: Meet the OLED</a>.</aside>

In Phase 1, you put Hi Yush on a real screen. Now let's look inside the picture. **How can numbers describe which pixels should light up?** By the end, you'll be able to build a byte deliberately and change one of its bits without disturbing the others.

## What You Will Be Able to Do

- Explain why one bit can represent one monochrome pixel, and calculate an image's raw storage.
- Read a byte in binary, hexadecimal, and decimal, including inside an RGB color code.
- Shift patterns and use masks to set, clear, or inspect selected bits.
- Build reusable bit operations and explain how they preserve the states you want to keep.

## Get Ready

{{< download "/downloads/pico/phase-2-byte-lab.py" "Download the Phase 2 byte lab" >}}. Only a starting value and a readiness message run; the comments give prompts for your own code. No OLED or driver is needed. Ordinary Python on your computer and MicroPython on the Pico both work for this phase.

Write one experiment at a time in the file and run it. Predict the result first, then use `print()` to check. Keep the answers closed until you've given the problem a serious try.

## From Pixels to Bytes

A **bit** is a single binary digit: `0` or `1`. Give those two values a meaning and you can record a choice: no or yes, off or on. A **byte** is a group of eight bits. Patterns of bits can represent numbers, text, colors, and recorded sound. The rules we choose give a pattern its meaning.

For our monochrome picture, each bit has one job: **`0` means a dark pixel; `1` means a lit pixel.** One byte can therefore describe eight pixel states:

{{< byte-lights >}}

We'll choose where those pixels sit on the OLED in Phase 3. For now, let's work out how much space a picture needs.

**Try it:** Imagine a picture with **16 columns and 8 rows**. Each pixel needs one bit, and each byte holds eight bits. **How many bytes do we need to store the whole picture?** Work out the number of pixels first, then the bits, then the bytes. Try it before opening the answer.

{{< hints >}}
- Each of the eight rows contains sixteen pixels.
- Once you have the bit count, group those bits into eights.
{{< /hints >}}

{{< answer >}}

{{< math >}}
\begin{aligned}
16 \times 8 &= 128\ \text{pixels} \\
128 \times 1 &= 128\ \text{bits} \\
128 \div 8 &= 16\ \text{bytes}
\end{aligned}
{{< /math >}}

We need **16 bytes** for this picture's pixel data.

**A dark pixel still needs a bit.** Turning every pixel off changes the stored values to zero; we still reserve the same space for all 128 pixel states.
{{< /answer >}}

## Read and Construct a Byte

We've read a bit pattern as lights. We can also read it as a number.

<aside class="lesson-context" aria-label="Optional binary background">We'll cover the binary basics we need here. For more explanation and practice, try <a href="https://www.mathsisfun.com/binary-number-system.html">Maths Is Fun's binary number guide</a>. You can come back to it whenever you like.</aside>

Binary uses powers of two, just as decimal uses powers of ten. In an eight-bit pattern, count bit positions from **0 at the right**. A position's weight is the value it contributes when its bit is `1`.

```text
bit:       7   6   5   4   3   2   1   0
weight:  128  64  32  16   8   4   2   1
```

For example, `00101101` has bits 5, 3, 2, and 0 on. Add their weights: `32 + 8 + 4 + 1 = 45`. A byte ranges from all zeroes, value 0, to all ones, value `128 + 64 + 32 + 16 + 8 + 4 + 2 + 1 = 255`. There are 256 possible patterns.

In Python, prefix a binary number with **`0b`**: `0b00101101`. Leading zeroes help us see eight positions; they do not change the value. `bin(value)` gives a binary text representation, usually without those leading zeroes.

{{< lesson-exercise number="1" title="Build a byte from its weights" id="q1-build-a-byte-from-its-weights" >}}

Write decimal 173 as an eight-bit pattern. Name the bit positions that are on, then check your work with `print(bin(173))`. Explain how the weights add back to 173.

{{< hints >}}
- Begin with 128. Which weights can make the remaining 45?
- Write a digit for every position, including the zeroes between your chosen weights.
{{< /hints >}}

{{< answer >}}
```text
173 = 128 + 32 + 8 + 4 + 1
bit:    7 6 5 4 3 2 1 0
state:  1 0 1 0 1 1 0 1
```

Bits 7, 5, 3, 2, and 0 are on. Python prints `0b10101101`.

**A binary pattern tells you which powers of two are present.** You can read a pattern as a value or build a pattern from a value.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="select-bits-with-masks"></span>

## Change Bits: NOT, AND, and OR

Reading a pattern is useful; changing just the parts we choose is even better. **Bitwise operators work one position at a time.** We'll follow NOT, AND, and OR with eight-bit patterns so we can see exactly what happens.

### NOT: reverse each bit

**Bitwise NOT (`~`) inverts a pattern:** every `0` becomes `1`, and every `1` becomes `0`.

| Input bit | Inverted bit |
| ---: | ---: |
| 0 | 1 |
| 1 | 0 |

For eight positions, inverting `00001100` gives `11110011`. Python's `~` operator inverts an integer, though, and integers aren't limited to eight positions:

```python
value = 0b00001100
print(~value)  # -13
```

That negative result can be surprising. **Python hasn't been told to keep just eight bits.** We'll use AND next to select the eight positions we want; there is no need to work with negative-number representations here.

<span id="clear-and-test-bits"></span>

### AND: keep selected bits

**AND (`&`) produces a `1` only when both inputs have `1` in that position.**

| A | B | A & B |
| ---: | ---: | ---: |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

A **mask** is a pattern used to select bit positions. For AND, a `1` in the mask lets the existing bit through; a `0` forces it off. This mask keeps only the lowest four positions:

```python
value = 0b10110100
mask = 0b00001111
kept = value & mask
print(bin(kept))  # 0b100: 00000100 in eight positions
```

The expression calculates a new value. `value` still holds the original pattern; we stored the filtered result in `kept`.

Now we can keep just the lowest eight positions of our NOT result. An all-ones byte lets those eight bits through:

```python
value = 0b00001100
inverted_byte = ~value & 0b11111111
print(bin(inverted_byte))  # 0b11110011
```

**To clear a chosen bit, let every other position through.** For bit 5, invert its one-bit mask, then keep the result's lowest eight bits:

```python
mask = 0b00100000             # Select bit 5.
clear_mask = ~mask & 0b11111111
print(bin(clear_mask))        # 0b11011111
```

AND with `clear_mask` clears bit 5 and preserves every other bit. To replace the stored value, write `value = value & clear_mask`, or the shorter `value &= clear_mask`. For an existing byte, `value &= ~mask` also works: AND cannot introduce a `1` where `value` already has a `0`.

**AND can also inspect a bit without changing it.** `value & 0b00000100` is zero if bit 2 is off and nonzero if it is on. `bool(...)` turns zero into `False` and a nonzero result into `True`. Inspection doesn't change `value` because it doesn't assign a result back to it.

### OR: turn selected bits on

**OR (`|`) produces a `1` when either input has `1` in that position.**

| A | B | A \| B |
| ---: | ---: | ---: |
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

For OR, zeroes in the mask preserve existing bits; a `1` turns that position on. Here the mask selects bit 3:

```python
value = 0b10100001
mask = 0b00001000
result = value | mask
print(bin(result))  # 0b10101001
```

Only bit 3 switches on. To keep that result in `value`, write `value = value | mask`, or `value |= mask`.

**The same mask has different jobs with different operators.** OR with `00001000` turns bit 3 on; AND with it keeps only bit 3. NOT helps make the mask that clears bit 3 instead.

<span id="q4-clear-one-bit-inspect-another"></span>

{{< lesson-exercise number="2" title="Clear one bit, inspect another" id="q2-clear-one-bit-inspect-another" >}}

{{< exercise-step "predict" >}}
Start with `value = 0b10110100`. After clearing bit 5, what will the eight-bit pattern be? Will testing bit 2 give `True` or `False`? Work out both before running code.
{{< /exercise-step >}}

{{< exercise-step "try" >}}
Use NOT and AND to clear bit 5 while preserving every other bit. Print the new value in binary, then print `bool(value & 0b00000100)`.
{{< /exercise-step >}}

{{< exercise-step "explain" >}}
Why does clearing change `value`, while testing leaves it alone? Point to the part of your code that makes the difference.
{{< /exercise-step >}}

{{< hints >}}
- Bit 5's one-bit mask is `00100000`. Inverting it gives a zero at the position we want to clear.
- The mask for testing bit 2 contains a single `1` at that position.
{{< /hints >}}

{{< answer >}}
```python
value = 0b10110100
mask = 0b00100000
value &= ~mask
print(bin(value))                 # 0b10010100
print(bool(value & 0b00000100))    # True
```

The final value is 148, or `10010100`. The test evaluates to `4`, which `bool()` reports as `True`; it never assigns anything back to `value`.

**Changing data and inspecting data are different operations.** Assignment determines whether the calculated result replaces the stored value.
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="3" title="Can setting a bit twice change a neighbor?" id="q3-can-setting-a-bit-twice-change-a-neighbor" >}}

{{< exercise-step "predict" >}}
Start with `value = 0`. Set bit 4 using OR twice. What should the result be? What if you add its weight, 16, twice instead?
{{< /exercise-step >}}
{{< exercise-step "try" >}}
Write and run both versions, printing `bin(value)` after each change. Use the mask `0b00010000` and start each version from zero.
{{< /exercise-step >}}
{{< exercise-step "explain" >}}
Why does one version preserve bit 4 while the other produces a carry?
{{< /exercise-step >}}

{{< hints >}}
- `00010000` has just bit 4 on, so its value is 16.
- OR of `1` with `1` stays `1`. Addition follows a different rule.
{{< /hints >}}

{{< answer >}}
```python
mask = 0b00010000
value = 0
value |= mask
print(bin(value))  # 0b10000
value |= mask
print(bin(value))  # 0b10000

value = 0
value += mask
print(bin(value))  # 0b10000
value += mask
print(bin(value))  # 0b100000
```

OR leaves bit 4 on. Addition produces 32: bit 4 turns off and bit 5 turns on.

**“Turn this bit on” should work even when it is already on.** OR does that; addition changes the value by an amount.
{{< /answer >}}
{{< /lesson-exercise >}}

## Move Bits with Shifts

So far we've written each mask by hand. What if a program needs to select whatever bit number we give it? **Shifting moves a pattern into position.**

A left shift (`<<`) moves every bit left and fills the new positions on the right with zeroes. Starting with `1`, we can build a one-bit mask:

```python
print(bin(1 << 0))  # 0b1:    00000001
print(bin(1 << 3))  # 0b1000: 00001000
print(bin(1 << 5))  # 0b100000: 00100000
```

`1 << bit` selects the numbered position: shifting zero places selects bit 0. We can now write `value |= 1 << bit` to set a bit whose number is held in a variable, or `value &= ~(1 << bit)` to clear it.

{{< lesson-exercise number="4" title="Choose a bit by its number" id="q4-choose-a-bit-by-its-number" >}}

You want to turn on just bit 6 in an empty byte. Predict the eight-bit mask and its decimal value, then replace the TODOs:

```python
bit = 6
mask = 0  # TODO: create the mask from bit, using a shift.
value = 0
# TODO: turn the selected bit on using your mask.
print(bin(mask), value)
```

Change only `bit` to `0`, then to `7`. What should each version print? Why would shifting by `bit - 1` select the wrong position?

{{< hints >}}
- The starting `1` already occupies bit 0; it needs zero moves to select that position.
- A bit's weight is two raised to its position: bit 6 has weight 64.
{{< /hints >}}

{{< answer >}}
```python
bit = 6
mask = 1 << bit
value = 0
value |= mask
print(bin(mask), value)  # 0b1000000 64
```

For `bit = 0`, the mask is `00000001` and the value is 1. For `bit = 7`, the mask is `10000000` and the value is 128. Bit 6's mask is `01000000`.

**The shift count is the bit position, not the position minus one.** Our numbering starts at zero. A formula lets the same code select any of the eight positions.
{{< /answer >}}
{{< /lesson-exercise >}}

### Move a whole pattern

Shifts move more than one lit bit. For the nonnegative values we use here, a right shift (`>>`) moves bits right and discards positions that fall off that end:

```text
original:  00001100
left 1:    00011000
right 1:   00000110
```

These expressions calculate new values. `value` only changes if you assign a result back to it. Python integers can grow beyond eight bits, so a left shift does not automatically keep its result inside a byte. AND with `0b11111111` keeps just the lowest eight positions when needed.

{{< lesson-exercise number="5" title="Did the pattern move—or did the variable change?" id="q5-did-the-pattern-move" >}}

{{< exercise-step "predict" >}}
Start with `value = 0b00001100`. Predict the binary outputs of `value << 2`, `value >> 2`, and `value` itself. Which positions are on in each result?
{{< /exercise-step >}}
{{< exercise-step "try" >}}
Run those three expressions with `print(bin(...))`. Then write one assignment that moves the stored pattern two places left, and print `value` again.
{{< /exercise-step >}}
{{< exercise-step "explain" >}}
How is moving a pattern different from turning on a selected bit with OR?
{{< /exercise-step >}}

{{< hints >}}
- Move both ones by two positions. A shift doesn't just add two to the number.
- Calculating `value << 2` alone does not replace `value`.
{{< /hints >}}

{{< answer >}}
```python
value = 0b00001100
print(bin(value << 2))  # 0b110000: 00110000, bits 5 and 4
print(bin(value >> 2))  # 0b11:     00000011, bits 1 and 0
print(bin(value))       # 0b1100:   00001100, bits 3 and 2
value = value << 2
print(bin(value))       # 0b110000: now value has changed
```

**A shift moves every bit; OR sets the positions selected by a mask.** Both calculate a result, and assignment decides whether we keep it. We'll test what happens when bits fall outside a byte in the homework.
{{< /answer >}}
{{< /lesson-exercise >}}

## Use Hexadecimal as Compact Binary

We can now read and change bit patterns. As those patterns get longer, writing every zero and one gets awkward. Hexadecimal gives us a shorter way to write the same values.

A group of four bits is a **nibble**. It has sixteen possible patterns, so one base-16, or **hexadecimal**, digit can describe the whole group. The digits after 9 are A through F, representing 10 through 15.

```text
0  0000    4  0100    8  1000    C  1100
1  0001    5  0101    9  1001    D  1101
2  0010    6  0110    A  1010    E  1110
3  0011    7  0111    B  1011    F  1111
```

Split our byte into two nibbles: `0010 1101` becomes `2 D`. In Python, **`0x2D`** is hexadecimal notation for the same value as `0b00101101` or decimal `45`. The prefix chooses how we write the number; it does not change the number. `hex(value)` gives its hexadecimal text representation.

<span id="q2-is-the-display-address-three-different-numbers"></span>

{{< lesson-exercise number="6" title="Is the display address three different numbers?" id="q6-is-the-display-address-three-different-numbers" >}}

Phase 1's scan printed decimal `60`. The driver uses `0x3C`. Expand each hex digit into four bits, identify which bit positions are on, and decide whether those two values differ. Write one Python comparison to check.

{{< hints >}}
- Keep four positions for each hex digit: `3` becomes `0011`.
- Python's `==` compares values, even when their written forms differ.
{{< /hints >}}

{{< answer >}}
`0x3C` becomes `0011 1100`. Bits 5, 4, 3, and 2 are on: `32 + 16 + 8 + 4 = 60`.

```python
print(60 == 0x3C == 0b00111100)  # True
```

**Notation and value are different ideas.** Hex stays compact while keeping the four-bit groups easy to recover.
{{< /answer >}}
{{< /lesson-exercise >}}

## Practice: Byte Builder

Build a decimal or hex target by toggling bits, then supply its other representation. Try reading the pattern before checking it. Useful patterns to recognize include `0x00` (all off), `0xFF` (all on), `0xAA` (`10101010`), and `0x55` (`01010101`).

{{< byte-trainer >}}

## Another Use for Hex: RGB Color

Our OLED picture uses one bit per pixel. For another use of bytes, imagine mixing red, green, and blue light on a color screen. In this **RGB** format, each color component, or **channel**, gets one byte: `00` through `FF` in hex, or 0 through 255. Zero contributes none of that component; 255 is its maximum.

A six-digit web color code, **`#RRGGBB`**, gives each channel two hex digits. For example, `#204080` contains:

| Channel | Hex byte | Decimal value |
| --- | --- | ---: |
| Red | `20` | 32 |
| Green | `40` | 64 |
| Blue | `80` | 128 |

The code combines three bytes, or **24 bits**, for one pixel. The left byte is red, the middle byte is green, and the right byte is blue. Those separate groups will let us pack channels together with shifts and OR, then recover them with shifts and AND.

Keep two digits per channel: `#0000FF` is blue with no red or green. `#000000` is black; `#FFFFFF` is white. The web code uses `#`; a Python integer uses `0x`, as in `0x204080`. `hex(0x0000FF)` prints `0xff`, while the web color still needs all six digits to preserve the channel positions.

You'll try mixing and decoding colors in the last homework exercise. This six-digit notation is the [RGB hex form used in CSS](https://www.w3.org/TR/css-color-4/#hex-notation).

<hr class="lesson-review-divider">

## Homework

### Explain yourself

With the explanations closed, explain each term to yourself or someone else. Connect a byte's bit positions, masks, and written forms. How can bits describe both a monochrome picture and an RGB color? Explain a setting operation without just naming its operator.

<span id="glossary"></span>

{{< reveal-controls scope="glossary" >}}
{{< recall-glossary data="phase2_glossary" >}}

### Exercises

Write your own solution before looking at the hints. ★ Challenging · ★★ Very challenging.

<span id="q5-translate-the-same-byte-three-ways"></span>

{{< lesson-exercise number="7" level="4" title="Translate the same byte three ways" id="q7-translate-the-same-byte-three-ways" >}}

Write `0xA6`, `0b01011010`, and `0x0F` in all three forms: eight-bit binary, two-digit hex, and decimal. Work them out first, then use this code to check:

```python
values = (0xA6, 0b01011010, 0x0F)
for value in values:
    print(value, bin(value), hex(value))
```

Why does Python print `0xf` rather than `0x0F`? Has it lost any of the value?

{{< hints >}}
- Translate one hex digit into four binary digits at a time.
- Leading zeroes help show the width of a group; they do not add to its value.
{{< /hints >}}
{{< answer >}}
{{< scroll-table "Byte conversions" >}}
| Given | Eight-bit binary | Two-digit hex | Decimal |
| --- | --- | --- | ---: |
| `0xA6` | `10100110` | `A6` | 166 |
| `0b01011010` | `01011010` | `5A` | 90 |
| `0x0F` | `00001111` | `0F` | 15 |
{{< /scroll-table >}}

`hex()` uses lowercase letters and leaves out unnecessary leading zeroes. `0xf`, `0x0F`, and decimal `15` are equal.

**A printed number does not remember the width or notation you originally used.** Add zeroes when a fixed-width representation helps you see the groups.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="q6-follow-a-shifted-pattern"></span>

{{< lesson-exercise number="8" level="4" title="Follow a shifted pattern" id="q8-follow-a-shifted-pattern" >}}

For `value = 0x2D`, predict the binary and hex results of `value << 1` and `value >> 2`. Could shifting the second result left by two recover the original pattern? Explain before checking:

```python
value = 0x2D
print(bin(value << 1), hex(value << 1))
print(bin(value >> 2), hex(value >> 2))
print((value >> 2) << 2)
```

Then try `wide = 0x81 << 1`. Does the result still fit in one byte? Use AND to keep just its lowest eight bits.

{{< hints >}}
- Begin with `00101101`. Move every bit, not just the ones at the edges.
- A right shift discards the positions that fall off the right.
- `0xFF` has a `1` in each of the lowest eight positions.
{{< /hints >}}
{{< answer >}}
{{< scroll-table "Shifted patterns" >}}
| Expression | Binary pattern | Hex | Decimal |
| --- | --- | --- | ---: |
| `0x2D << 1` | `01011010` | `0x5A` | 90 |
| `0x2D >> 2` | `00001011` | `0x0B` | 11 |
{{< /scroll-table >}}

Shifting 11 back left gives 44, or `00101100`. The original bit 0 was discarded, so we cannot recover 45 just by shifting back.

```python
wide = 0x81 << 1
print(wide, bin(wide), hex(wide))  # 258 0b100000010 0x102
byte = wide & 0xFF
print(byte, bin(byte), hex(byte))  # 2 0b10 0x2
```

**Moving a pattern and choosing its stored width are separate operations.** Python keeps the ninth bit until we explicitly discard it; a right shift can also lose information.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="q7-turn-on-several-bits-with-one-mask"></span>

{{< lesson-exercise number="9" level="4" title="Turn on several bits with one mask" id="q9-turn-on-several-bits-with-one-mask" >}}

Start with `value = 0x81`. Build one mask that selects bits **1, 3, and 6**, using shifts and OR. Apply it so those bits turn on while every other position keeps its state. Predict the mask and the final byte in binary and hex.

```python
value = 0x81
mask = 0      # TODO: combine the three one-bit masks.
result = value  # TODO: apply your mask while preserving the other bits.
print(bin(mask), hex(mask))
print(bin(result), hex(result))
```

Why would replacing `value` with the mask alone give the wrong picture?

{{< hints >}}
- The selected weights are 2, 8, and 64.
- OR the three masks together, then OR that combined mask with the existing value.
{{< /hints >}}
{{< answer >}}
```python
value = 0x81
mask = (1 << 1) | (1 << 3) | (1 << 6)
result = value | mask
print(bin(mask), hex(mask))      # 0b1001010 0x4a
print(bin(result), hex(result))  # 0b11001011 0xcb
```

The eight-bit mask is `01001010`; the result is `11001011`. Replacing the original with the mask would lose its existing bits 7 and 0.

**The mask describes what to select; the existing byte supplies what to preserve.**
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="q8-keep-remove-and-test-bits"></span>

{{< lesson-exercise number="10" level="4" title="Keep bits, remove bits, and test a claim" difficulty="1" id="q10-keep-remove-and-test-bits" >}}

Start with `value = 0xD6`. Build a mask for bits **1 and 4**. Calculate two new values without changing the original: one that keeps only the selected bits, and one that clears them. Predict both results in hex.

A friend says `bool(value & mask)` means **both** selected bits are on. Try that claim with `value = 0x02`. Write a comparison that really checks whether both selected bits are on.

{{< hints >}}
- AND with `mask` keeps selected positions; AND with `~mask` removes them.
- A nonzero result could contain just one of the selected bits.
- If all selected bits are on, the masked result will equal the whole mask.
{{< /hints >}}
{{< answer >}}
```python
value = 0xD6
mask = (1 << 1) | (1 << 4)  # 0x12
print(hex(value & mask))    # 0x12: keep the selected bits
print(hex(value & ~mask))   # 0xc4: clear the selected bits

value = 0x02
print(bool(value & mask))   # True: bit 1 is on, but bit 4 is off
print((value & mask) == mask)  # False
```

**Nonzero means at least one selected bit is on.** To require all selected bits, compare the masked result with the mask. One-bit tests hide this distinction because “one” and “all” mean the same thing there.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="q5-budget-a-pictures-memory"></span>

<span id="q9-budget-a-pictures-memory"></span>

{{< lesson-exercise number="11" level="4" title="Budget a picture's memory" id="q11-budget-a-pictures-memory" >}}

Calculate the raw pixel bytes for these pictures:

- A 128 × 64 monochrome picture, at one bit per pixel.
- A 256 × 128 monochrome picture, also at one bit per pixel.
- A 128 × 64 RGB picture, at three bytes per pixel.

How does doubling both dimensions change the storage? How does switching from our monochrome format to this RGB format change it? Check your calculations in Python.

{{< hints >}}
- Width times height counts pixels. Convert bits into bytes for the monochrome pictures.
- RGB already gives its cost in bytes per pixel, so do not divide that result by eight.
{{< /hints >}}
{{< answer >}}
```python
mono = 128 * 64 // 8
larger = 256 * 128 // 8
rgb = 128 * 64 * 3
print(mono, larger, rgb)  # 1024 4096 24576
```

Doubling both dimensions needs four times the storage. The RGB picture needs 24 times the raw storage of the same-size monochrome picture: 24 bits per pixel instead of one. These totals count pixel data, not Python object overhead or compression.

**Storage depends on both the number of pixels and the information stored per pixel.**
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="q6-write-a-reusable-bit-switch"></span>
<span id="q7-read-the-bits-in-the-other-direction"></span>

<span id="q10-write-and-inspect-a-bit-switch"></span>

{{< lesson-exercise number="12" level="4" title="Write and inspect a reusable bit switch" difficulty="2" id="q12-write-and-inspect-a-bit-switch" >}}

Write `change_bit(value, bit, on)` to return a new byte value. If `on` is `True`, set the requested bit; otherwise clear it. Preserve all other bits. Assume `value` is from 0 through 255 and `bit` from 0 through 7.

Replace `pass` in this starter; it is just a placeholder, so the unfinished function returns `None`:

```python
def change_bit(value, bit, on):
    # Return the new byte value.
    pass

print(change_bit(0xC3, 3, True))   # Expected: 203 (0xCB)
print(change_bit(0xCB, 3, False))  # Expected: 195 (0xC3)
```

Then use your function in a loop to turn bits **0, 2, 3, and 5** on in an empty byte. Keep each returned value for the next change. Write a second loop that prints every bit number and state, starting at bit 0 and ending at bit 7, using masks. Keep the finished byte unchanged while inspecting it. Why does that inspection run in the opposite direction from usual written binary?

{{< hints >}}
- Make the mask with `1 << bit`, then choose OR or AND with the inverted mask.
- Build the pattern by looping over `(0, 2, 3, 5)` and assigning each returned value back to `value`.
- Use `range(8)` and test `value & (1 << bit)` to inspect the result.
{{< /hints >}}
{{< answer >}}
```python
def change_bit(value, bit, on):
    mask = 1 << bit
    if on:
        return value | mask
    return value & ~mask

print(change_bit(0xC3, 3, True))   # 203
print(change_bit(0xCB, 3, False))  # 195
```

```python
value = 0
for bit in (0, 2, 3, 5):
    value = change_bit(value, bit, True)
print(hex(value))  # 0x2d

for bit in range(8):
    if value & (1 << bit):
        state = 1
    else:
        state = 0
    print(bit, state)
```

The states from bit 0 through bit 7 are `1, 0, 1, 1, 0, 1, 0, 0`. Written `00101101` puts bit 7 first. Our inspection changed the order of reading, not the stored value.

**A reusable operation lets us build and inspect a pattern deliberately.** In Phase 3, that low-to-high inspection will become a top-to-bottom group of pixels.
{{< /answer >}}
{{< /lesson-exercise >}}

<span id="q11-mix-and-pack-a-color"></span>

{{< lesson-exercise number="13" level="4" title="Mix a color, then pack its bytes" difficulty="2" id="q13-mix-and-pack-a-color" >}}

Try the color challenge in both directions: convert a hex code to three decimal channel values, then convert decimal channels back to a hex code. Predict each conversion before checking. The two swatches let you compare your mix with the target; the numbers let you check it exactly.

{{< rgb-byte-lab >}}

Now write `pack_rgb(red, green, blue)` to combine three channel bytes into one integer, and `unpack_rgb(color)` to return the three bytes as a tuple. Assume valid channel values from 0 through 255 and a color integer from `0x000000` through `0xFFFFFF`.

Start here. The two comparisons should print `True` and the last line should print `(18, 171, 240)` when the functions work:

```python
def pack_rgb(red, green, blue):
    # Leave eight bit positions for each channel.
    pass

def unpack_rgb(color):
    # Return (red, green, blue).
    pass

print(pack_rgb(0x20, 0x40, 0x80) == 0x204080)
print(pack_rgb(0, 0, 255) == 0x0000FF)
print(unpack_rgb(0x12ABF0))
```

Explain how your shifts make room for each byte and how your masks separate the channels again.

{{< hints >}}
- Blue stays in the lowest eight positions; green moves left by eight; red moves left by sixteen.
- OR the non-overlapping groups together.
- To recover a channel, shift it down to the lowest positions, then AND with `0xFF`.
{{< /hints >}}
{{< answer >}}
```python
def pack_rgb(red, green, blue):
    return (red << 16) | (green << 8) | blue

def unpack_rgb(color):
    red = (color >> 16) & 0xFF
    green = (color >> 8) & 0xFF
    blue = color & 0xFF
    return red, green, blue

print(pack_rgb(0x20, 0x40, 0x80) == 0x204080)  # True
print(pack_rgb(0, 0, 255) == 0x0000FF)         # True
print(unpack_rgb(0x12ABF0))                  # (18, 171, 240)
```

For the mixer's first target, `#4080C0`, the channels are `0x40 = 64`, `0x80 = 128`, and `0xC0 = 192`. `unpack_rgb(0x4080C0)` can check that conversion too.

**The same shifts and masks can organize several values inside one larger integer.** Each channel keeps eight positions, just as our monochrome byte keeps eight pixel states.
{{< /answer >}}
{{< /lesson-exercise >}}

## What's next {#prepare-for-phase-3}

You can choose bits inside a byte. Our OLED picture contains 1,024 bytes, so the next question is **which byte and bit belong to a particular coordinate?** Phase 3 connects these patterns to pages of vertical pixels, using a smaller display and a familiar tic-tac-toe board first.

[Continue to Phase 3: Memory Organization →](/post/pages-and-display-memory/) · [Back to Phase 1 ←](/post/meet-the-oled/) · [Project roadmap](/post/pico-oled-project/)
