# Phase 6: editorial and validation notes

Added 2026-11-14. Lesson: [The SSD1306 Driver](/post/the-ssd1306-driver/).

## Why this sequence

The opening asks why `text()` works when its definition is absent from the driver. This continues Phase 5's explanation that drawing tools come from FrameBuffer. A small Label class introduces instance state and self before any inheritance vocabulary is required. The driver then becomes a concrete example of those ideas, rather than a list of unfamiliar definitions.

| Part | Learning payoff |
| --- | --- |
| Q1: two Label instances | Shared method code does not imply shared instance attributes; self identifies the receiver. |
| Q2: find text, show, and write_data | Method lookup follows the class chain. The same object exposes behavior from different classes, with one image buffer. The bus is a separate held object. |
| Q3: delay the temporary array | Initializer order follows dependencies. Base code can call a subclass's writer before the base initializer returns. A Python attribute error is different from a bus EIO. |
| Four-route call trace | Students predict and reveal method lookup and handoffs for drawing, showing, inversion, and construction. All cards share a sizing cell so explanations do not intentionally move the controls. The model is labelled as a source-reading aid. |
| Q4: 128×32 rather than 128×64 | Inclusive page endpoints and full-buffer transfer cost carry forward from Phases 3–5. The unchanged 128-column width deliberately avoids the driver's centered-column branch. |
| Q5: a recording connection | A driver depends on an interface, not necessarily a physical bus. Immutable byte snapshots preserve events despite the driver's reused scratch array, revisiting Phase 4's reference/copy distinction. |
| Q6: inversion versus image bytes | A controller setting can change output without rewriting the prepared image. Tests distinguish command writes from image transfers; a recorder is not evidence of physical display behavior. |
| Q7: counting subclass | Students combine self, initialization order, overriding, and delegation. Counts include the constructor's blank frame. Checking recorded writes prevents an apparently correct counter from hiding a removed transfer. |

Seven numbered problems use one to three hints, closed answers, and explicit takeaways. Four appear during the lesson; Homework contains Explain yourself and three independent exercises. Difficulty stars mark the last two. The glossary has one show/hide control pair. The starter executes only import/dimensions/readiness setup, includes the published lesson URL and driver location requirements, and keeps class scaffolds commented. Hi Yush is retained in the opening, class example, and trace.

The source walkthrough also surveys initialization, power, contrast, inversion, rotation, I2C, and SPI responsibilities. It does not ask students to memorize setup registers. Detailed bus framing belongs to Phase 7; interpreting controller configuration belongs to Phase 8. Phase 9 will reuse MicroPython's frame-buffer and I2C facilities when building the SSD1306 layer.

## Navigation

Phase 5 now links forward to Phase 6. The project guide moves Phase 6 into the published table, and the Pico course index lists it sixth. The lesson links back to Phase 5 and the project guide. Phase 7 remains labelled as planned, with no broken link to an unwritten post.

## Checks and limits

- `python3 scripts/check_pico_driver_lesson.py --build-dir BUILD_DIRECTORY` checks seven exercises, glossary structure, all 14 Python fences, setup-only starter execution, navigation, rendered local links/fragments/assets, unique IDs, and inline JavaScript syntax.
- Behavioral tests import the unchanged bundled driver with a small independent FrameBuffer storage stand-in. They execute the actual lesson solutions and cover independent instances, a copied-AST version of the Q3 mistake, 128×32 and 128×64 show ranges, whole-image payloads, mutable-array snapshots, inversion without RAM edits, and four delegated transfers including construction. The model tests MONO_VLSB fill/pixel storage, not MicroPython's C implementation, font artwork, physical I2C, or an OLED.
- `node scripts/check_driver_trace.cjs` tests all 18 trace steps in four routes, resetting, switching mid-call, active-card isolation, owner highlighting, and accessible state. It uses a minimal DOM stand-in and does not render CSS.
- The Hugo release render includes the new lesson and its navigation. A temporary static staging directory omits only the unrelated js-draw development source checkout to avoid slow cold-file reads; all website assets and the lesson downloads are included. Repository build configuration remains unchanged.
- Browser preview was attempted, but local browser access is disabled in Work settings. Visual, responsive, and actual browser interaction checks could not be performed; no screenshot or hardware result is claimed.
- The official driver and its MIT license remain unchanged. Generated output/ is excluded from the commit.

Primary references: the bundled [SSD1306 source](/downloads/pico/phase-1-kit/ssd1306.py), [upstream MicroPython driver](https://github.com/micropython/micropython-lib/blob/master/micropython/drivers/display/ssd1306/ssd1306.py), [FrameBuffer reference](https://docs.micropython.org/en/v1.26.0/library/framebuf.html), [Python classes/inheritance](https://docs.python.org/3/tutorial/classes.html#inheritance), and [super()](https://docs.python.org/3/library/functions.html#super).
