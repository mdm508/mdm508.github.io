---
title: "Start Here: The Raspberry Pi Pico OLED Project"
date: 2025-01-01T09:00:00-08:00
draft: false
description: "A ten-phase journey from lighting OLED pixels to building a small display driver, with a guide to the lessons and the ideas behind them."
tags: ["python", "micropython", "raspberry-pi-pico", "electronics"]
summary: "Start the Pico OLED series: explore the ten-phase roadmap, find each published lesson, and see why rebuilding a small driver helps the ideas connect."
toc: false
---

How does a Python instruction become light on a screen?

This project follows that question using a Raspberry Pi Pico and a small 128 × 64 SSD1306 OLED. We begin by wiring the display and drawing something we can see. Then we open one layer at a time: bits, bytes, memory, drawing operations, communication, and the display controller itself.

Eventually, we will build a small driver of our own and use it in a project. Each phase gives us a working result and a new part of the explanation.

## Series Contents

Read the published lessons in order. Each one builds on the ideas introduced before it.

| Published phase | What you will learn and do | The question behind it |
| --- | --- | --- |
| [Phase 1: Meet the OLED](/post/meet-the-oled/) | Connect the hardware, locate pixels, place text, and use `show()`. | How can Python control a physical screen? |
| [Phase 2: Pictures as Data](/post/pictures-as-data/) | Read and construct bytes using binary, hexadecimal, shifts, and masks. | How can numbers represent a picture? |
| [Phase 3: Memory Organization](/post/pages-and-display-memory/) | Explore a tiny Lite-Brite, flatten a 2D board into a list, and map coordinates to pages, bytes, and bits. | Which stored bit controls a particular pixel? |
| [Phase 4: The Frame Buffer](/post/the-frame-buffer/) | Compare the image in Pico RAM with the image held by the OLED, and investigate drawing versus sending. | Why doesn't drawing immediately change the screen? |
| [Phase 5: Drawing Graphics](/post/drawing-graphics/) | Combine pixels, lines, rectangles, and text into scenes, then make simple animations. | How does a sequence of still frames create movement? |

### Coming Next

These phases are planned. Their lesson links will be added here as they become available.

| Planned phase | What you will learn and do | The question behind it |
| --- | --- | --- |
| Phase 6: The SSD1306 Driver | Read the driver we have been using and examine how its classes share responsibilities. | Where do drawing methods and hardware operations come from? |
| Phase 7: I²C Communication | Follow addresses, commands, and image data from the Pico to the OLED controller. | What actually travels between the two devices? |
| Phase 8: Inside the SSD1306 Chip | Use selected datasheet diagrams to understand display memory and the controller's job. | What happens after the bytes arrive? |
| Phase 9: Build Our Own Driver | Assemble a minimal driver that initializes the OLED and sends a prepared image. | Can we build the small layer we now understand? |
| Phase 10: Use the Display | Create a sensor dashboard, a game, or another project that uses the OLED. | What can we make with this system? |

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

The OLED makes abstract ideas visible. A bit becomes a light. An index becomes a location. Changing a byte changes a small group of pixels. That gives us something concrete to test while we learn how computers represent information.

The same reasoning carries into other programming. Flattening a tic-tac-toe board helps explain image buffers and other grids. Tracking a prepared frame separately from the displayed frame teaches us to distinguish two pieces of state. Following an I²C transfer introduces the idea of a communication protocol: an agreed way for devices to exchange information.

Rebuilding the driver connects those ideas. We first use a working tool, then investigate its parts, then assemble a small version ourselves. A method such as `show()` becomes a sequence we can explain and test.

This also makes debugging more deliberate. A drawing error, an undefined Python variable, and a loose wire call for different investigations. Understanding the layers helps us decide what evidence to look for and what to change next.

Our own driver will have a focused scope. We will keep using MicroPython's existing I²C and frame-buffer tools, and build the SSD1306-specific layer: initialization, commands, and image transfer. Named constants and a small, explained setup sequence will keep the hardware details manageable.

The aim is to understand how the pieces cooperate. Looking up a command value is useful; being able to explain why we send it is the deeper skill.

## How to Work Through the Lessons

You should be comfortable with Python variables, loops, and simple functions. We introduce the new concepts before asking you to use them. The early phases use the supplied driver; later phases explain its structure.

For each experiment, predict what will happen, run a small change, and compare the result with your prediction. The practice problems have hints and expandable answers. Use them to check your reasoning, then explain the result in your own words.

The interactive toys let you explore without hardware. The downloadable starter scripts give you a starting point for the Pico experiments. Phases 2 and 3 can also be studied without an OLED.

For the physical project, have a Pico running MicroPython, a 128 × 64 SSD1306 I²C OLED, jumper wires and a breadboard, and a USB data cable. Phase 1 provides the wiring and driver kit. You can work in Thonny or VS Code with MicroPico; Phase 4 includes a note on preserving the Python session between experiments.

[Begin Phase 1: Meet the OLED →](/post/meet-the-oled/)

## Glossary

| Term | Meaning in this project |
| --- | --- |
| Driver | Code that provides convenient operations for using the OLED hardware. |
| Frame buffer | Memory holding the pixels of the image being prepared. |
| Controller | The SSD1306 chip that receives commands and image data and drives the OLED pixels. |
| Protocol | An agreed way to exchange information; I²C is the protocol connecting our devices. |
