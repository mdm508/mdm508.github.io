---
title: "Phase 4: The Frame Buffer — Draw First, Show Second"
date: 2026-10-18T09:00:00-07:00
draft: false
description: "Explore the image in the Pico's RAM, compare it with the OLED's display memory, and discover what show() sends."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics"]
summary: "Draw in an interactive frame buffer, then trace text(), fill(), and show() from Pico RAM to the OLED."
reading_time: 90
---

## Where This Lesson Fits

In [Phase 1](/post/meet-the-oled/), we drew pixels and text, then called `show()`. [Phase 2](/post/pictures-as-data/) gave us bits and masks. In [Phase 3](/post/pages-and-display-memory/), we found the exact byte and bit for a screen coordinate.

Now we can ask: **if drawing changes those bytes, why doesn't the physical screen change immediately?**

Today's goal is to track two things separately: the image being prepared in the Pico's memory and the image currently held by the OLED controller.

## Try Two Screens

A **frame** is one complete image. A **frame buffer** is memory holding the pixels of that image. Our program's frame buffer lives in the Pico's **RAM**, the working memory used while the program runs.

The OLED controller has its own display memory. Drawing in the Pico's RAM does not automatically change that separate memory. `show()` sends the prepared bytes to the controller.

Try that separation on a small display first:

{{< frame-buffer-toy >}}

### Q1: Can you change the picture without changing the display?

**Problem:** Draw a small pattern on the left. Press `show()`, then change one more pixel. Which picture changes at each step?

{{< hints >}}
- Watch the two rows of hexadecimal bytes.
- Only one button sends the prepared image to the right-hand screen.
{{< /hints >}}

{{< answer >}}
Drawing changes only the left picture and its RAM bytes. `show()` copies the prepared image to the right. The next pixel edit changes RAM again, while the right picture keeps the previous image.

The frame buffer and display can disagree. That is an expected part of preparing the next frame.
{{< /answer >}}

### Q2: Does clearing RAM erase the visible picture?

**Problem:** Send a pattern with `show()`. Press `fill(0): clear RAM`. Predict what another press of `show()` will do, then try it.

{{< hints >}}
- Clearing changes the prepared frame.
- A blank image is still image data that can be sent.
{{< /hints >}}

{{< answer >}}
Clearing RAM leaves the displayed pattern visible. The next `show()` sends the zero-filled bytes, making the display blank too.

`fill(0)` prepares a blank frame. `show()` makes that blank frame visible.
{{< /answer >}}

## Follow the Real Bytes

On our 128 × 64 OLED, the Pico's frame buffer contains 1,024 bytes. The driver exposes that same storage as `oled.buffer`. Drawing methods change these bytes; they do not create a separate picture hidden elsewhere.

For the driver included in the [Phase 1 kit](/downloads/pico/phase-1-kit.zip), the path is:

```text
Pico RAM                     OLED controller
┌──────────────────┐         ┌──────────────────┐
│ oled.buffer      │ show()  │ display memory   │
│ 1,024 image bytes│ ──────► │ drives the pixels│
└──────────────────┘  I²C    └──────────────────┘
  ↑ drawing changes this       keeps the last data sent
```

`pixel()`, `text()`, and `fill()` edit the frame buffer. `text()` turns character shapes into pixel changes in RAM; we will explore drawing shapes in Phase 5.

In this driver, `show()` sets the destination column and page ranges, then sends the **whole buffer**, even if only one pixel changed. It does not clear RAM afterward. The controller uses its own memory to keep driving the display between transfers; the Pico does not need to resend the picture continuously for it to remain visible while powered and configured normally.

The transfer takes time. Preparing a complete frame before sending it avoids deliberately sending each unfinished drawing stage, but it does not make the physical transfer instantaneous. We will examine the I²C bytes and the controller itself in later phases.

## Try It on the Pico

[Download the Phase 4 frame lab](/downloads/pico/phase-4-frame-lab.py). Save it alongside `ssd1306.py` on the Pico using the wiring from Phase 1. Run it in Thonny, then use the Shell to press Enter at each checkpoint. No rewiring is needed.

The first two experiments are ready to run. Later TODOs are commented out until you reach their problems. If you do not have the hardware, use the toy and trace the code on paper.

For the snippets below, run the starter's setup first so `oled` exists. Each experiment explicitly establishes its starting picture. `input()` pauses the program until you press Enter, giving you time to compare RAM with the screen.

### Q3: Where is WAITING while the program waits?

**Problem:** Predict the display before and after pressing Enter:

```python
oled.fill(0)
oled.show()
oled.text("WAITING", 0, 0)
input("Inspect the screen, then press Enter: ")
oled.show()
```

{{< hints >}}
- The first `show()` sends a blank frame.
- `text()` changes RAM during the pause.
{{< /hints >}}

{{< answer >}}
During the pause, the OLED is blank. The pixels spelling WAITING already exist in `oled.buffer`, but have not been sent. After Enter, `show()` sends them and the word appears.

The text was drawn before it became visible.
{{< /answer >}}

### Q4: What does the buffer's length tell us?

**Problem:** Predict `len(oled.buffer)` for our display. Explain why it is not the number of lit pixels.

{{< hints >}}
- Phase 3 counted eight pages, each containing 128 bytes.
- Turning a bit off does not remove its byte slot.
{{< /hints >}}

{{< answer >}}
The length is `8 * 128 = 1024`. That is the number of stored bytes. A blank picture and a fully lit picture use the same buffer size; their byte values differ.
{{< /answer >}}

### Q5: Can a drawing method change the byte you calculated?

**Problem:** Complete Experiment 3 in the starter. Begin with a cleared buffer and blank display. Draw pixel `(37, 29)`, inspect byte 421, pause, and finally display the pixel.

{{< hints >}}
- Phase 3 placed this pixel at byte 421, bit 5.
- `1 << 5` is 32.
- Print and pause before calling `show()`.
{{< /hints >}}

{{< answer >}}
```python
oled.fill(0)
oled.show()
oled.pixel(37, 29, 1)
print("Byte 421:", oled.buffer[421])
input("The screen is blank. Press Enter to show the pixel: ")
oled.show()
```

The printed value is 32 (`0x20`). The drawing method has performed the byte-and-bit change we worked out by hand. Only the final call sends it to the OLED.
{{< /answer >}}

### Q6: Does a raw buffer edit follow the same rule?

**Problem:** Replace `oled.pixel(37, 29, 1)` in Q5 with a raw byte edit that preserves neighboring bits. Will the timing change?

{{< hints >}}
- Use OR to set bit 5 of byte 421.
- Both approaches change the same storage in Pico RAM.
{{< /hints >}}

{{< answer >}}
```python
oled.buffer[421] |= 1 << 5
```

The timing is the same: RAM changes immediately, but the display waits for `show()`. A convenient drawing method and a raw buffer edit reach the same prepared image.
{{< /answer >}}

## Keep Track of Two Images

### Q7: What survives a clear?

**Problem:** Trace the buffer and screen at each pause:

```python
oled.fill(0)
oled.text("OLD", 0, 0)
oled.show()
input("Pause A: ")
oled.fill(0)
input("Pause B: ")
oled.text("NEW", 0, 0)
input("Pause C: ")
oled.show()
```

{{< hints >}}
- Track RAM and the visible display in separate columns.
- `fill(0)` clears the old text in RAM before NEW is drawn.
{{< /hints >}}

{{< answer >}}
| Checkpoint | Pico frame buffer | OLED display |
| --- | --- | --- |
| Pause A | OLD | OLD |
| Pause B | Blank | OLD |
| Pause C | NEW | OLD |
| After final `show()` | NEW | NEW |

The OLED keeps OLD while we prepare NEW. We do not need to display the blank intermediate frame.
{{< /answer >}}

### Q8: Is `show()` a list of drawing commands?

**Problem:** Suppose you draw A, clear RAM, then draw B, all before calling `show()`. Will the screen play back A, a blank frame, and B?

{{< hints >}}
- The buffer stores pixel values, not a history of function calls.
- Ask which bytes remain when `show()` starts.
{{< /hints >}}

{{< answer >}}
No. It receives the current frame containing B. Clearing removed A from RAM. The frame buffer holds the resulting image, not instructions to replay how you made it.
{{< /answer >}}

### Q9: Does `show()` consume the image?

**Problem:** After drawing and displaying a picture, call `show()` again without changing RAM. What appears? How many image bytes does each call send on our 128 × 64 display?

{{< hints >}}
- Sending does not erase `oled.buffer`.
- This driver sends the whole frame, not just changed bytes.
{{< /hints >}}

{{< answer >}}
The same picture remains. Each call sends 1,024 image bytes. Commands and I²C control information also travel, so 1,024 is the image payload, not a count of every byte or bit on the bus.
{{< /answer >}}

## Assemble a Complete Frame

Drawing several things into RAM lets us decide when to send the result. For a static screen, we can clear the prepared image, add all its parts, then call `show()` once.

### Q10: Can two lines arrive as one prepared frame?

**Problem:** Complete Experiment 4 in the starter: prepare READY at `(0, 0)` and PICO at `(0, 16)`, then send the finished frame once. Avoid displaying a blank frame between the previous picture and this one.

{{< hints >}}
- Clear RAM first.
- Place both `text()` calls before `show()`.
{{< /hints >}}

{{< answer >}}
```python
oled.fill(0)
oled.text("READY", 0, 0)
oled.text("PICO", 0, 16)
oled.show()
```

The previous picture remains visible while RAM is being prepared. The transfer then sends the image containing both lines. Putting `show()` after each drawing call would send unfinished stages and require extra transfers.
{{< /answer >}}

### Q11: Is one `show()` enough forever?

**Problem:** You display a picture, change one pixel in RAM, and want that change to appear. Do you need another `show()`? What if you make no changes at all?

{{< hints >}}
- The display does not watch the Pico's RAM for edits.
- Its own memory preserves the last image sent while operating normally.
{{< /hints >}}

{{< answer >}}
Send again when you want the new pixel to become visible. If the picture has not changed, there is no need to resend it merely to keep it visible.

A changing display usually follows a repeated sequence: prepare the next frame, send it, then prepare another. Phase 5 will use that pattern for simple animation.
{{< /answer >}}

### Q12: Can you explain the whole journey?

**Problem:** Explain what happens from `oled.text("HI", 0, 0)` to seeing HI on the OLED. Include the two memory locations and the job of `show()`.

{{< hints >}}
- Begin with pixels being changed in the Pico's RAM.
- End with the controller using the received image data.
{{< /hints >}}

{{< answer >}}
`text()` changes bits in `oled.buffer` in Pico RAM to form the letters. `show()` sends the prepared frame over I²C to the OLED controller's display memory. The controller uses that data to drive the physical pixels.

Drawing prepares the image. Sending updates the display's image data. The controller keeps the pixels driven between transfers.
{{< /answer >}}

## Next: Drawing Graphics

We can now explain where a picture waits and when it reaches the OLED. In Phase 5, we will use pixels, lines, rectangles, and text to build complete scenes, then change those scenes over time.

[Back to Phase 3: Memory Organization ←](/post/pages-and-display-memory/) · [Revisit Phase 1's drawing experiments](/post/meet-the-oled/)

## Glossary

| Term | Definition | Example |
| --- | --- | --- |
| Frame | One complete image. | A screen containing READY and PICO. |
| Frame buffer | Memory holding the pixels of a prepared image. | `oled.buffer` contains 1,024 bytes for our display. |
| RAM | Working memory used while a program runs. | The Pico stores the prepared frame in RAM. |
| Display memory | Memory inside the OLED controller holding received image data. | It keeps OLD while the Pico prepares NEW. |
| Drawing operation | An operation that changes the prepared image. | `text()`, `pixel()`, and `fill()`. |
| Transfer | Sending data from one place to another. | `show()` sends image bytes over I²C. |
| `show()` | The driver's method for sending the current frame to the controller. | Draw two lines, then call `oled.show()`. |
| `fill(0)` | Set every pixel in the frame buffer to off. | Prepare a blank image without immediately changing the OLED. |
| Payload | The useful data carried by a transfer, apart from control information. | The 1,024 image bytes in a full-screen update. |
