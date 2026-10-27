---
title: "Project 1: The Pico OLED Display"
date: 2025-01-01T09:00:00-08:00
draft: false
description: "Build and understand a Pico OLED display through ten phases: pixels, binary, memory, graphics, communication, and a driver of your own."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics"]
summary: "The first Pico project: find the prerequisites, supplies, wiring, and lesson roadmap for learning an OLED from its first pixels to a small driver."
toc: true
---

<aside class="lesson-context" aria-label="Related guides">Part of the <a href="/post/raspberry-pi-pico-wh/">Raspberry Pi Pico WH projects</a>. <a href="/courses/pico/">Browse the Pico lessons in order</a>.</aside>

**How does a Python instruction become light on a screen?** In this first project, we will connect a tiny OLED, make pictures, explore how those pictures are stored, animate them, and eventually write a small display driver ourselves.

The OLED gives us a visible result at every step. One project becomes a way to connect programming, data representation, memory, and electronics. The ten phases below follow that explanation one layer at a time.

## Before You Begin

This project assumes some basic familiarity with **programming and electronics**: Python variables, conditionals, loops, and simple functions, plus experience making a simple circuit and identifying power and ground connections. The lessons introduce binary, bit masks, display memory, and I²C as we need them.

If the Pico itself is new to you, read the [Pico WH introduction](/post/raspberry-pi-pico-wh/) first. It explains microcontrollers, the board's parts, the kit, and the choice between Thonny and VS Code. Then return here for the display-specific supplies and wiring.

## Series Contents

Read the published lessons in order. Each one builds on the ideas introduced before it.

| Published phase | What you will learn and do | The question behind it |
| --- | --- | --- |
| [Phase 1: Meet the OLED](/post/meet-the-oled/) | Connect the hardware, locate pixels, place text, and use `show()`. | How can Python control a physical screen? |
| [Phase 2: Pictures as Data](/post/pictures-as-data/) | Read and construct bytes using binary, hexadecimal, shifts, and masks. | How can numbers represent a picture? |
| [Phase 3: Memory Organization](/post/pages-and-display-memory/) | Explore a tiny Lite-Brite, flatten a 2D board into a list, and map coordinates to pages, bytes, and bits. | Which stored bit controls a particular pixel? |
| [Phase 4: The Frame Buffer](/post/the-frame-buffer/) | Connect drawing methods to raw bytes, save frames, and investigate complete-image transfers. | What changes in Pico RAM, and what reaches the screen? |
| [Phase 5: Drawing Graphics](/post/drawing-graphics/) | Fit shapes and character cells precisely, compose scenes, and animate them with a finite loop. | How does a sequence of still frames create movement? |

### Coming Next

These phases are planned. Their lesson links will be added here as they become available.

| Planned phase | What you will learn and do | The question behind it |
| --- | --- | --- |
| Phase 6: The SSD1306 Driver | Read the driver we have been using and examine how its classes share responsibilities. | Where do drawing methods and hardware operations come from? |
| Phase 7: I²C Communication | Follow addresses, commands, and image data from the Pico to the OLED controller. | What actually travels between the two devices? |
| Phase 8: Inside the SSD1306 Chip | Use selected datasheet diagrams to understand display memory and the controller's job. | What happens after the bytes arrive? |
| Phase 9: Build Our Own Driver | Assemble a minimal driver that initializes the OLED and sends a prepared image. | Can we build the small layer we now understand? |
| Phase 10: Use the Display | Create a sensor dashboard, a game, or another project that uses the OLED. | What can we make with this system? |

## Supplies for the OLED Project

This project uses a few parts from the **52Pi KR-0006 Pico WH kit**. The [Pico WH introduction](/post/raspberry-pi-pico-wh/#the-kit-and-your-workbench) describes the whole kit and its other components. You can also buy the required parts individually.

For the OLED experiments, gather the following parts:

| For this project | What to look for |
| --- | --- |
| Pico WH | The small green board with wireless hardware and soldered header pins. A compatible Pico with headers also works; Wi-Fi is not needed here. |
| OLED module | A **128 × 64 SSD1306 display with a four-pin I²C connection**, labelled GND, VCC, SCL, and SDA. The kit's larger blue LCD is a different display. |
| USB data cable | A micro-USB cable for the Pico, plus an adapter if your laptop needs one. A charge-only cable cannot carry your code. |
| Four female-to-female jumper leads | Socket ends that slide over the metal pins on both boards. My recommended route uses these and the UPS board's labelled breakout pins. |
| Pico UPS board, optional | Holds the Pico and exposes labelled connections. Its battery-power features are useful for later portable projects. |
| Breadboard and suitable leads, optional | An alternative way to connect the same four signals. Use male-to-female leads when the OLED stays beside the breadboard. |
| Computer | Windows, macOS, or Linux, with Thonny or VS Code plus MicroPico. |

**Check for female-to-female leads before the lesson.** The kit photo includes them, but the written parts list names male-to-male and male-to-female leads. If your box has no female-to-female leads, get a small set separately. “Female” means a socket; “male” means an exposed metal pin.

The UPS and a battery are optional. Either wiring route below works with the lesson code.

## Meet the OLED

An **OLED** is an organic light-emitting diode display. Its pixels make their own light. Our small module is about 0.96 inches diagonally and has **128 columns and 64 rows**: 8,192 pixel positions. In these lessons, each pixel is on or off.

<figure>
<img src="https://wiki.52pi.com/images/thumb/e/e8/Da1.jpg/480px-Da1.jpg" width="480" height="480" alt="A lit 0.96-inch OLED module, with its four connection labels GND, VCC, SCL, and SDA visible above the screen." loading="lazy" style="display:block;max-width:500px;width:100%;height:auto;margin:auto;">
<figcaption>An OLED module. Photo and module specifications: <a href="https://wiki.52pi.com/index.php/S-0005">52Pi</a>. Match the labels on your own four-pin module before wiring.</figcaption>
</figure>

The **SSD1306** is the controller chip that receives instructions and image data, then drives the pixels. **I²C** (also written IIC) is the communication method we use to send those instructions. It needs two signal connections, plus power and ground. [52Pi's OLED reference](https://wiki.52pi.com/index.php/S-0005) describes the 128 × 64 SSD1306 module.

| OLED label | Job | Our Pico connection |
| --- | --- | --- |
| GND | Shared electrical reference | GND, for example physical pin 3 |
| VCC | Power for the module | 3V3(OUT), physical pin 36 |
| SCL | Serial clock: timing for the conversation | GP1, physical pin 2 |
| SDA | Serial data: information being exchanged | GP0, physical pin 1 |

<details>
<summary>Find the OLED connections on the Pico pin guide</summary>

{{< pico-pin-guide project="oled" >}}

</details>

The pin order can differ between modules. **Match the printed names, rather than copying left-to-right positions from a picture.** Use 3V3(OUT) for this project; VBUS, VSYS, and 3V3_EN are different connections.

## Wire the Pico and OLED

Choose either route below. The program and the four electrical connections are the same.

Before fitting the Pico or changing wires, disconnect its USB cable and turn off/disconnect any UPS battery supply. A connected USB cable can still power the Pico even when the UPS switch is off. Reconnect power after checking the four paths.

### Route A: Labelled UPS Board and Female-to-Female Leads

This is my recommended route for the kit. The UPS is a power accessory, and it also gives us a convenient set of labelled breakout pins. For this first experiment, we use those labels to connect the display; we do not need battery operation.

<figure>
<img src="/images/pico/pico-wh-on-ups.png" width="495" height="505" alt="Pico WH seated on a black UPS board, with labelled breakout pins, a battery holder, power switch, and a separate micro-USB charging port." loading="lazy" style="display:block;max-width:495px;width:100%;height:auto;margin:auto;">
<figcaption>Pico WH on the UPS accessory. Manufacturer photo from the <a href="https://wiki.52pi.com/index.php?title=EP-0159">52Pi Pico UPS documentation</a>.</figcaption>
</figure>

1. With power disconnected, seat the Pico in the UPS sockets according to the manufacturer's orientation diagram. Check that both rows are aligned and no pins are offset or bent.
2. Find the exposed breakout labels **GND, 3V3, GP1, and GP0**. Labels such as `GP0` may be shortened to `0`; check against the pinout. Use the GPIO breakout, rather than the UPS's separate TX/RX telemetry header.
3. Fit one female socket over each selected pin. Connect the other ends to OLED **GND, VCC, SCL, and SDA**, respectively. Follow the table above.
4. Check each wire from label to label. Connect the laptop's USB data cable to the **Pico's own USB connector** to program it.

{{< pico-wiring "ups" >}}

**Two USB connectors, two jobs:** the Pico's connector carries programming data. The UPS connector labelled `USB_IN` is for charging; 52Pi says not to connect that charging port to a laptop or PC. See the [UPS instructions](https://wiki.52pi.com/index.php?title=EP-0159) for assembly and battery use. A battery is not needed for our USB-powered lesson.

### Route B: Pico on a Breadboard

A breadboard makes temporary connections without soldering. On a typical board, **A–E in one numbered row are connected**, and **F–J in that row form a separate connected group**. The center gap separates the groups. The next numbered row is a new connection.

1. With power disconnected, place the Pico across the center gap, with one header row on each side. Keep the USB connector accessible.
2. Find a free hole in the **same connected group** as each required Pico pin. A nearby hole in the next row is not connected to it.
3. Use four male-to-female leads: male ends into those breadboard holes, female ends over the OLED pins. Connect GP0 → SDA, GP1 → SCL, 3V3 → VCC, and GND → GND.
4. Check the paths, then connect USB to the Pico. Power rails are unnecessary for this four-wire version.

{{< pico-wiring "breadboard" >}}

The drawing uses Pico headers in columns B and I, beginning at row 1. In that example, A1 shares GP0's group, A2 shares GP1's, A3 shares GND's, and J5 shares 3V3's. Your board may use different rows; follow the pin names and connected groups.

### A Quick Connection Check

**Problem:** Before running the full OLED example, trace each of the four wires with your finger. Which two connections belong to the power path, and which two carry the conversation? Explain why a correctly written program still needs all four.

{{< hints >}}
- Find the OLED's VCC and GND labels first.
- Separate the clock signal from the data signal.
{{< /hints >}}

{{< answer >}}
VCC connects to the Pico's 3V3 output; GND provides the shared reference and return path. SCL carries the clock and SDA carries data. The display needs power and a working communication path: Python cannot replace a missing electrical connection.

**The wiring is part of the program's starting conditions.** We check it before investigating our drawing code.
{{< /answer >}}

[Phase 1](/post/meet-the-oled/#establish-ic-communication) introduces `i2c.scan()`: a small test for whether a device answers. It commonly reports `[60]`, which is the same address as `0x3C`. The rest of Phase 1 takes us from that connection to our first visible text.

### The Kit's Demo Code and Libraries

The manufacturer also provides a [demo-code ZIP](https://wiki.52pi.com/images/5/52/RPi_Pico_WH_IoT_starter_kit.zip), with its [source and file history on the 52Pi wiki](https://wiki.52pi.com/index.php?title=File:RPi_Pico_WH_IoT_starter_kit.zip).

Inside `Demo_code and libraries`, you will find:

| Folder | What it contains |
| --- | --- |
| `Democode` | Example projects combining components: a potentiometer with the OLED, a joystick with the OLED, an ultrasonic distance display, and sensor web projects. |
| `lib` | Supporting libraries, including `ssd1306.py` for the OLED, plus libraries for other displays and sensors. |

Use these examples as a reference and a source of future project ideas. For our lessons, start with the [Phase 1 kit](/post/meet-the-oled/) and each phase's starter file; we introduce the pieces as we need them.

**Check each demo's wiring before trying it.** For example, the joystick demo puts its OLED on **GP2/GP3 using I²C1**, while this series uses **GP0/GP1 using I²C0**. An example's code, required libraries, and connections need to agree.

## What We Are Building Toward

A **driver** is code that gives the rest of a program a convenient way to use hardware. Calling `oled.show()` is convenient because the driver handles the display commands and transfers underneath it.

By the end of the series, you should be able to explain this journey:

```text
Python drawing commands
          ↓
image bytes in the Pico's RAM
          ↓
driver sends commands and data over I²C
          ↓
OLED controller stores the image and drives the pixels
```

You should also be able to change the picture deliberately, decide when to send it, and investigate which part of the journey failed when the screen stays blank.

## Why Build a Driver from Scratch?

A tiny display gives us a surprisingly rich programming project. Making it work brings together numbers, memory, graphics, program design, and communication—ideas we will meet again across many other projects. Following one device closely helps us understand how those pieces cooperate, and rebuilding its driver gives us a chance to put that understanding to work. There is also pleasure in the investigation itself: something that first seemed mysterious becomes something we can explain, change, and create with.

**Ideas we'll explore:**

- **Representing information:** bits, bytes, binary, hexadecimal, shifts, masks.
- **Organizing data:** coordinates, grids, arrays, indexing, memory, frame buffers.
- **Designing programs:** variables, loops, functions, parameters, modules, classes, inheritance, abstraction.
- **Creating graphics:** pixels, shapes, text, frames, animation, timing, state.
- **Connecting hardware:** circuits, GPIO, I²C, addresses, commands, data, drivers.
- **Investigating systems:** predictions, experiments, boundary errors, debugging, reading documentation.

## How to Work Through the Lessons

**Programming isn't a spectator sport.** Take your time and give every problem a serious try before opening the hints or solution. If you need the solution, come back later and try again with the answer closed.

Each lesson ends with **Homework**: **Explain yourself** asks you to connect the ideas in your own words; **Exercises** asks you to use them independently. ★ marks a challenging problem and ★★ a very challenging one.

If you're lost, I may not have explained it clearly—I'm sorry when that happens. Don't blame yourself. Take a break, ask questions, and keep experimenting. Have fun with it.

[Begin Phase 1: Meet the OLED →](/post/meet-the-oled/)

## Glossary

| Term | Meaning in this project |
| --- | --- |
| Microcontroller | A chip that runs a program and connects it to electronic inputs and outputs. |
| MicroPython | A version of Python designed to run on small devices such as the Pico. |
| GPIO | A general-purpose input/output connection whose job is selected by the program. |
| Header | A row of metal pins or sockets used to connect boards and wires. |
| I²C | A way for devices to communicate using clock (SCL) and data (SDA) signals, plus shared ground. |
| REPL | The interactive prompt where you can run short instructions on the Pico. |
| Driver | Code that provides convenient operations for using the OLED hardware. |
| Frame buffer | Memory holding the pixels of the image being prepared. |
| Controller | The SSD1306 chip that receives commands and image data and drives the OLED pixels. |
| Protocol | An agreed way to exchange information; I²C is the protocol connecting our devices. |
