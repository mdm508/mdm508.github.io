---
title: "Phase 4: The Frame Buffer — Draw First, Show Second"
date: 2026-10-18T09:00:00-07:00
draft: false
description: "Trace drawing into Pico RAM, compare it with the OLED's display memory, and investigate complete-frame transfers and snapshots."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics"]
summary: "Connect raw pixel bytes to drawing methods, keep prepared and displayed images separate, and choose when to send a complete frame."
reading_time: 90
toc_depth: 3
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/pico-oled-project/">Pico OLED project: guide and lesson roadmap</a>. Previously: <a href="/post/pages-and-display-memory/">Phase 3: Memory Organization</a>.</aside>

In Phase 1, you saw that drawing and showing are separate steps. Now you can locate the exact bytes a drawing changes. **Let's connect those two ideas:** where do the bytes wait, and how do they become the picture on the physical OLED?

This time we will keep track of two images, compare a drawing method with our raw bit edit, and decide when to send a finished frame. That separation will let us prepare each new animation frame while the previous one stays visible.

## What You Will Be Able to Do

- Track the image in Pico memory separately from the image held by the OLED.
- Show that drawing methods and raw edits change the same buffer.
- Explain what this driver's `show()` sends and what it leaves behind.
- Save an independent frame snapshot and restore its bytes.

## Get Ready

{{< download "/downloads/pico/phase-4-frame-lab.py" "Download the Phase 4 frame lab" >}}. Only connection and display setup run. Write the experiments below that setup and **run the whole file**. Replace earlier drawing experiments unless a problem says otherwise. No `input()` pauses or retained interactive variables are required.

Keep `ssd1306.py` in the **same folder on the Pico** as the lab file; upload it from the [Phase 1 kit](/downloads/pico/phase-1-kit.zip) if needed. Use the same wiring: GP0 → SDA, GP1 → SCL, 3V3(OUT) → VCC, GND → GND. Run on the Pico through Thonny or MicroPico in VS Code.

Setup creates a new `oled` object and initializes the display, including clearing it. Each experiment below establishes its own starting picture after setup. If you do not have the hardware, use the toy and trace the code on paper.

{{< python-session-note >}}
### Optional: Keep Your Python Session {#keep-your-python-session}

You can skip this box when running whole files. For one-command-at-a-time experiments at the Pico's `>>>` prompt, a **Python session** is the running interpreter and the names it remembers. A **soft reset** restarts MicroPython and clears those names; files saved on the Pico remain.

In VS Code, if you want names to survive **between file runs**, search Settings for `micropico.noSoftResetOnRun` and enable it for this workspace. The setting disables the automatic soft reset **before** running a file. It does not recover names lost in an earlier reset, and old variables can remain until you replace them. MicroPico also has a separate **Soft-reset after upload** setting, so uploading and running need not behave identically. See the [extension's setting descriptions](https://github.com/paulober/MicroPico/blob/main/package.nls.json).

If `oled` is undefined, run setup successfully in the current Pico session before using it. If setup raises `EIO`, investigate the I²C connection; that is a different clue. The experiments in this lesson work without changing either setting.
{{< /python-session-note >}}

## Try Two Screens

A **frame** is one complete image. A **frame buffer** holds that image's pixel data. Our program's frame buffer lives in the Pico's **RAM**, its working memory.

The SSD1306 controller has separate **display memory**. Drawing in Pico RAM does not automatically change the controller's copy. `show()` sends the prepared bytes over I²C.

{{< frame-buffer-toy >}}

{{< lesson-exercise number="1" title="Can the two images disagree?" id="q1-can-the-two-images-disagree" >}}

In the toy, draw a pattern and press `show()`. Change one more pixel without sending, then clear RAM. Describe the two pictures after each action. What will one more `show()` do? Predict before pressing it.

{{< hints >}}
- Track the RAM bytes and OLED bytes separately.
- A cleared buffer is still a complete picture: its bytes are zero.
{{< /hints >}}
{{< answer >}}
After the first `show()`, both images match. Editing one pixel changes only RAM. Clearing RAM makes the left image blank while the OLED keeps the pattern already sent. Another `show()` sends the blank picture, so both are blank.

**A disagreement between the prepared image and the displayed image can be intentional.** It lets us choose when a change becomes visible.
{{< /answer >}}
{{< /lesson-exercise >}}

## Follow the Real Bytes

For our 128 × 64 display, `oled.buffer` exposes the same 1,024 bytes that the drawing methods edit. It is not a second, unrelated picture. Phase 3 tells us that `(37, 29)` belongs to byte 421, bit 5.

```text
Pico RAM                         OLED controller
┌──────────────────┐             ┌──────────────────┐
│ oled.buffer      │   show()     │ display memory   │
│ 1,024 image bytes│ ───────────► │ drives the pixels│
└──────────────────┘     I²C      └──────────────────┘
  drawing changes this             keeps data already sent
```

`pixel(x, y, 1)` changes a bit in RAM. Without the color argument, `pixel(x, y)` **reads** that pixel's value from RAM. It does not ask the physical screen what it is showing.

{{< lesson-exercise number="2" title="Does the drawing method reach the byte we found?" id="q2-does-the-drawing-method-reach-the-byte-we-found" >}}

Write a drawing block that clears and displays a blank frame, draws pixel `(37, 29)` without sending again, and prints both `oled.buffer[421]` and `oled.pixel(37, 29)`. Predict the two printed values and the final physical screen.

Then replace the drawing call with a raw bit edit that preserves neighbors. Will the results change? Run each version as a whole file.

{{< hints >}}
- A cleared byte with bit 5 set has value `1 << 5`.
- A pixel read returns its state, not the whole byte's value.
- The only transfer happens before the new drawing.
{{< /hints >}}
{{< answer >}}
```python
oled.fill(0)
oled.show()
oled.pixel(37, 29, 1)
print(oled.buffer[421])       # 32, or 0x20
print(oled.pixel(37, 29))     # 1
```

The physical OLED finishes blank. Replacing the third line with `oled.buffer[421] |= 1 << 5` produces the same results. Appending `oled.show()` and rerunning makes the pixel visible.

**A drawing method and a raw edit operate on the same bytes.** A convenient interface does not imply a different image underneath it.
{{< /answer >}}
{{< /lesson-exercise >}}

## A Frame Is a Result, Not a Replay

The buffer holds current pixel values, not a history of drawing instructions. Drawing A, clearing, and drawing B leaves only B to send. Likewise, drawing several parts before `show()` sends the resulting picture, rather than playing back every drawing stage.

{{< lesson-exercise number="3" title="Follow two pictures through one program" id="q3-follow-two-pictures-through-one-program" >}}

Trace this block on paper. At A, B, and C, write what is prepared in Pico RAM and what is displayed. Then predict the final picture and run the whole file to check it. The checkpoints are for reasoning; comments do not pause the program, so the intermediate images may pass too quickly to inspect.

```python
oled.fill(0)
oled.text("OLD", 0, 0)
oled.show()
# A
oled.fill(0)
# B
oled.text("NEW", 0, 0)
# C
oled.show()
```

{{< hints >}}
- Make two columns in your trace, one for each memory location.
- `fill(0)` changes only the prepared image. Transfers happen at `show()`.
{{< /hints >}}
{{< answer >}}
| Checkpoint | Prepared in Pico RAM | Displayed on the OLED |
| --- | --- | --- |
| A | OLD | OLD |
| B | Blank | OLD |
| C | NEW | OLD |
| After final `show()` | NEW | NEW |

The program sends no blank intermediate picture. OLD remains visible while NEW is prepared.

**Follow state changes in order, in the place where each operation acts.** The two-column trace makes a confusing sequence easier to explain.
{{< /answer >}}
{{< /lesson-exercise >}}

## What Does This Driver Send?

In the [driver supplied with Phase 1](/downloads/pico/phase-1-kit.zip), `show()` sets the destination ranges and sends the **whole buffer**, even when only one pixel changed. Sending does not empty or clear that buffer.

The controller keeps driving the display from its own memory while powered and configured normally. You do not need to resend an unchanged picture just to keep it visible. Send another frame when you want the prepared changes to appear.

The transfer takes time. Sending one completed picture avoids deliberately displaying unfinished stages; it does not make I²C instantaneous or guarantee that every physical pixel updates at the same instant.

{{< lesson-exercise number="4" title="Does sending consume the picture?" id="q4-does-sending-consume-the-picture" >}}

Prepare a picture and display it. Without drawing again, call `show()` a second time. Predict whether the picture or buffer length changes. How many **image bytes** do those two calls send altogether? Would changing just one pixel before the second call reduce that count in this driver?

{{< hints >}}
- Eight pages of 128 bytes make one frame.
- The driver sends all image bytes on each call and leaves RAM intact.
{{< /hints >}}
{{< answer >}}
The same picture remains, and `len(oled.buffer)` stays 1,024. Two calls send `2 * 1024 = 2048` image bytes. A one-pixel edit would not reduce the second transfer's image payload.

Commands and I²C control information travel too, so this is not a count of every byte or bit on the bus.

**Sending copies data; it does not consume the prepared image.** How much gets transferred depends on the driver's update strategy.
{{< /answer >}}
{{< /lesson-exercise >}}

## Keep a Snapshot

Sometimes we want to save a complete frame for later. `saved = bytes(oled.buffer)` makes an independent, unchangeable copy of the current bytes. By contrast, `saved = oled.buffer` only gives the same editable buffer another name; later drawing would affect what both names refer to.

To restore a snapshot of the same length, use `oled.buffer[:] = saved`. The slice `[:]` means the whole buffer. This copies values into the **existing storage** that the drawing methods use. Reassigning `oled.buffer` to another object is not the same operation.

Restoring bytes is still a RAM edit; you decide when to call `show()`.

Each full-screen snapshot stores another 1,024 image bytes, in addition to the working buffer and Python object overhead. Keeping several frames has a memory cost—the same image-size calculation you made in Phase 2.

<hr class="lesson-review-divider">

## Homework

### Explain yourself

Explain each term with the definitions hidden. Tell the story of `text()` followed by `show()`, naming both memory locations. How does saving a frame differ from giving its buffer a second name? Sketch the story or invent an analogy, then check its limits.

<span id="glossary"></span>

{{< reveal-controls scope="glossary" >}}
{{< recall-glossary data="phase4_glossary" >}}

### Exercises

Write each block below setup and run the whole file. ★ Challenging · ★★ Very challenging.

{{< lesson-exercise number="5" level="4" title="Prepare a complete announcement" id="q5-prepare-a-complete-announcement" >}}

After setup, display OLD at `(0, 0)`. Then replace it with READY at `(0, 0)` and PICO at `(0, 16)`. Do not send a blank frame or the unfinished one-line replacement between those two finished pictures. How many explicit `show()` calls does your drawing block need?

{{< hints >}}
- Send OLD first to establish the starting image within this run.
- Clear RAM, draw both new lines, then send the replacement.
{{< /hints >}}
{{< answer >}}
```python
oled.fill(0)
oled.text("OLD", 0, 0)
oled.show()

oled.fill(0)
oled.text("READY", 0, 0)
oled.text("PICO", 0, 16)
oled.show()
```

The drawing block has two transfers: one per finished picture. There is no transfer between clearing RAM and completing the replacement. OLD may be visible only briefly when you run the whole file; the toy lets you step through the same principle slowly.

**Choose transfers around complete pictures, rather than around individual drawing calls.**
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="6" level="4" title="Same final pixels, different transfer cost" difficulty="1" id="q6-same-final-pixels-different-transfer-cost" >}}

Starting with a cleared buffer, light `(0, 0)`, `(1, 0)`, and `(2, 0)`. Write two versions: one sends after every pixel, the other sends once after all three. Calculate the image bytes sent by each version. Explain what intermediate pictures they send and why the final picture matches.

{{< hints >}}
- A transfer sends the current result, including pixels drawn earlier.
- Count explicit `show()` calls in each drawing block, then multiply by 1,024.
{{< /hints >}}
{{< answer >}}
The first version is:

```python
oled.fill(0)
for x in range(3):
    oled.pixel(x, 0, 1)
    oled.show()
```

The second version moves the transfer outside the loop:

```python
oled.fill(0)
for x in range(3):
    oled.pixel(x, 0, 1)
oled.show()
```

The first sends three frames—one dot, two dots, three dots—for 3,072 image bytes. The second sends only the three-dot picture, for 1,024 image bytes. Both end with those same three pixels lit. This counts the drawing block's calls, not display initialization.

**Grouping edits can reduce communication without changing the final image.** It also gives us control over which intermediate states become visible.
{{< /answer >}}
{{< /lesson-exercise >}}

{{< lesson-exercise number="7" level="4" title="Save two frames, choose what to display" difficulty="2" id="q7-save-two-frames-choose-what-to-display" >}}

Prepare and save two independent frames: ONE at `(0, 0)` and TWO at `(0, 16)`. Then restore and display ONE. Finish with TWO restored in Pico RAM but not yet sent. Use only one explicit `show()` in your drawing block.

What should the final physical screen show? How would using `saved = oled.buffer` instead of a byte copy break your plan? Check the second prepared picture by adding one final transfer afterward.

{{< hints >}}
- Clear before preparing each frame, and take a `bytes(...)` snapshot after drawing it.
- Restore a snapshot into the existing buffer with slice assignment.
- A restore changes RAM; the position of `show()` chooses what reaches the screen.
{{< /hints >}}
{{< answer >}}
```python
oled.fill(0)
oled.text("ONE", 0, 0)
first = bytes(oled.buffer)

oled.fill(0)
oled.text("TWO", 0, 16)
second = bytes(oled.buffer)

oled.buffer[:] = first
oled.show()
oled.buffer[:] = second
```

The screen shows ONE while RAM holds TWO. Appending another `oled.show()` and rerunning displays TWO instead. If both saved names referred to `oled.buffer`, neither would preserve an earlier picture: both would refer to the same changing data.

**Keeping a previous state requires a copy, not just another name.** We can choose when a saved image becomes the displayed image.
{{< /answer >}}
{{< /lesson-exercise >}}

## What's next {#next-drawing-graphics}

You can now follow the same bytes through drawing, saving, and sending. In Phase 5, we'll prepare complete scenes with simple drawing tools and change their positions over time. **Animation is repeated preparation and transfer, with a deliberate change between frames.**

[Continue to Phase 5: Drawing Graphics →](/post/drawing-graphics/) · [Back to Phase 3 ←](/post/pages-and-display-memory/) · [Project roadmap](/post/pico-oled-project/)

For reference: [MicroPython's frame-buffer drawing and pixel-reading methods](https://docs.micropython.org/en/v1.26.0/library/framebuf.html) and the [exact driver used in the kit](https://github.com/micropython/micropython-lib/blob/a08087249fda8a7994f7c54ccaad29fb9fcc448a/micropython/drivers/display/ssd1306/ssd1306.py).
