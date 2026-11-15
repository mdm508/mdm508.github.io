# Phase 6: editorial and validation notes

Added and revised 2026-11-14. Lesson: [The SSD1306 Driver](/post/the-ssd1306-driver/).

## Why this sequence

The opening asks why `text()` works when its definition is absent from the driver. The revision keeps that question central: one display instance can use methods defined in several classes, and can hold a separate connection object. A TinyDisplay class reuses Phase 3's bytearray and vertical-column model to introduce instance state and self; the unrelated Label example is removed.

| Part | Learning payoff |
| --- | --- |
| Q1: two TinyDisplay instances | The same set_column() code can edit separate pictures. A class now has an immediate connection to familiar display memory. |
| Guided text() → show() trace | One question at a time distinguishes the method definition, receiving object, and effect. Wrong or missing predictions do not advance; explicit reveals remain available. A completed text trace unlocks show, and the two completed guided calls unlock the later construction/inversion choices. |
| Object map | The three defining classes sit inside one display-object box with one picture buffer. The connection occupies a separate box outside that class chain. Definition and receiver highlights are independent. |
| Q2: compare write_data() and show() | The range-setting recipe is explained first. Students can then identify the preparation a direct writer call skips without needing undisclosed controller knowledge. |
| Q3: delay the temporary array | A successful, same-instance construction path is worked through before the broken-order question. The first base-to-subclass writer call is explicit. A Python AttributeError and an I2C EIO call for different investigations. |
| Q4: change I2C to SPI | Students explain why the class boundaries exist: the shared buffer, initialization, drawing, and show recipe can remain while the transport writers and connection setup change. No SPI wiring knowledge is required. The former half-height calculation remains as a concise worked example. |
| Q5: repair one recorder line | The connection-method scaffolding is supplied. Students predict the shared-reference failure and repair the byte snapshot; byte concatenation no longer becomes a separate implementation task. |
| Q6: inversion versus image bytes | A controller setting can change output without rewriting the prepared image. The repaired recorder checks command writes and image payloads; it does not simulate the physical display. |
| Q7: optional counting subclass | Overriding/delegation is an extension rather than a core completion requirement. Counter setup precedes the base initializer; recorded transfers independently verify that the override preserves the inherited work. |

Seven numbered problems use one to three hints, closed answers, and explicit takeaways. Four appear during the lesson; Homework contains Explain yourself, two core exercises, and the optional subclass challenge. The glossary retains one show/hide control pair and labels overriding as extension vocabulary. The starter runs only import/dimensions/readiness setup; supplied classes and repair scaffolds remain commented. Its header links to the lesson and explains the driver/runtime requirements. Hi Yush remains in the opening and guided drawing trace.

The model places prediction controls before the expanding explanation, so revealing an answer does not intentionally reposition those controls. All question prompts share a sizing cell. Empty/wrong choices receive focused feedback; deliberate reveals are labelled as comparisons rather than correct answers. These are structural and unit-tested properties, not a claim of measured browser layout.

The source survey still covers initialization, power, contrast, inversion, rotation, I2C, and SPI responsibilities. Detailed framing belongs to Phase 7; interpreting controller configuration belongs to Phase 8. The eventual driver continues to reuse MicroPython's frame-buffer and I2C facilities.

## Navigation

Phase 5 links forward to Phase 6 and now promises using the recorder rather than implementing its plumbing. The project guide moves Phase 6 into the published table, and the Pico course index lists it sixth. The lesson links back to Phase 5 and the project guide. Phase 7 remains labelled as planned, with no broken link to an unwritten post.

## Checks and limits

- `python3 scripts/check_pico_driver_lesson.py --build-dir BUILD_DIRECTORY` checks seven exercises, glossary structure, all 14 Python fences, setup-only starter execution, navigation, rendered local links/fragments/assets, unique IDs, and inline JavaScript syntax.
- Behavioral tests import the unchanged bundled driver with a small independent FrameBuffer storage stand-in. They execute the actual lesson solutions and cover independent picture buffers, the provided recorder's failure and its repaired snapshots, shared SPI/I2C base behavior, a copied-AST version of the Q3 mistake, 128×32 and 128×64 show ranges, whole-image payloads, mutable-array snapshots, inversion without RAM edits, and four delegated transfers including construction. The model tests MONO_VLSB fill/pixel storage, not MicroPython's C implementation, font artwork, physical I2C, or an OLED.
- `node scripts/check_driver_trace.cjs` tests all 13 prediction steps in four routes, empty/wrong choices, explicit reveals, guided unlocks, resetting, switching mid-call, isolated question accessibility, and independent class/receiver highlighting. It uses a minimal DOM stand-in and does not render CSS.
- The Hugo release render includes the new lesson and its navigation. A temporary static staging directory omits only the unrelated js-draw development source checkout to avoid slow cold-file reads; all website assets and the lesson downloads are included. Repository build configuration remains unchanged.
- Browser preview was attempted, but local browser access is disabled in Work settings. Visual, responsive, and actual browser interaction checks could not be performed; no screenshot or hardware result is claimed.
- The official driver and its MIT license remain unchanged. Generated output/ is excluded from the commit.

Primary references: the bundled [SSD1306 source](/downloads/pico/phase-1-kit/ssd1306.py), [upstream MicroPython driver](https://github.com/micropython/micropython-lib/blob/master/micropython/drivers/display/ssd1306/ssd1306.py), [FrameBuffer reference](https://docs.micropython.org/en/v1.26.0/library/framebuf.html), [Python classes/inheritance](https://docs.python.org/3/tutorial/classes.html#inheritance), and [super()](https://docs.python.org/3/library/functions.html#super).
