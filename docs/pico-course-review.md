# Pico OLED course review

Reviewed 2026-10-27. Scope: the five published OLED phases, with Phase 1 as the editorial and visual reference. Phases 2–5 were revised locally. Planned Phases 6–10 were not written or published as part of this review.

## Shared format

Each phase now has:

- A quiet project/previous-phase aside, a motivating opening, four learning objectives, and setup instructions.
- Explanations and worked examples before students need a concept in a problem.
- Numbered problems along the way, then independent exercises after the review terms. Phase 2 has six teaching questions and seven homework exercises; the other phases have four and three. Formats vary; Predict/Try/Explain is used when it supports an actual experiment.
- One to three hints followed by a closed answer. Each answer ends with the idea the problem makes useful, rather than merely a result.
- A divider and Homework heading, with Explain yourself and Exercises nested beneath it in the outline. What's next stays at the main level.
- Definitions revealed by selecting the terms, with one glossary-only show/hide pair. ★ and ★★ identify challenging and very challenging exercises; the first homework problem is unmarked.
- The existing coffee-and-cream palette, shared exercise components, native expandable answers, and keyboard focus cues.

Phase 2's homework was expanded in response to the request for more binary, hex, shift, and mask practice, with seven homework exercises in a deliberate progression. The retained interactive games can generate additional practice. The format should not force every activity into the same sequence of labels.

## Phase 2: Pictures as Data

| Revision | Reason and learning payoff |
| --- | --- |
| Moved bits, byte capacity, positional weights, notation prefixes, and operator rules into the explanation before the questions. | Previously several essential ideas first appeared inside solutions. A student should be able to attempt a problem without opening the explanation it depends on. |
| Consolidated repeated conversion questions into Q1 (build from weights) and Q6 (interpret the real display address). | These test construction and equivalence instead of repeating the same conversion routine. They reconnect to Phase 1's scan. |
| Q3 compares repeated OR with repeated addition. | The counterexample explains why the operation matters: setting an already-set bit should not carry into a neighbor. |
| Q2 clears a bit and then tests a different bit, using Predict/Try/Explain cues. | Students commit to both outputs before running code, then distinguish updating a value from inspecting it and explain the role of assignment. bool() is introduced before the question. |
| Moved bit operations immediately after binary, in NOT → AND → OR order, each with its own truth table and Python examples. Put hexadecimal after the shift questions. | Early masks are explicit binary literals: no shift syntax or hex notation appears before it is explained. AND follows NOT so students can see why selecting eight positions turns Python’s unbounded complement into a byte. |
| Added two shift questions after the two operator questions: Q4 selects positions 6, 0, and 7; Q5 predicts whole-pattern shifts and distinguishes expressions from assignment. | Students first understand what masks do, then use shifting to construct them from a variable. The edge positions address zero-based counting; moving a complete pattern distinguishes shifting from setting a bit. |
| Q7 translates three bytes across binary, hex, and decimal, with a Python checker. | The cases exercise high hex digits, a binary input, and a leading-zero byte. Printed width is distinguished from value. |
| Q8 shifts a pattern in both directions, tries reversing a lossy shift, and masks a ninth bit. | Students distinguish movement, information loss, and the deliberate choice to keep eight positions. |
| Q9 constructs and applies one combined mask to an existing byte. | Choosing multiple bits and preserving the existing state are separate parts of the operation. Replacing the byte with the mask is a concrete counterexample. |
| Q10 compares filtering and clearing, then challenges an any-bit/all-bits claim. | A nonzero masked result only proves at least one selected bit is on; comparison with the complete mask tests all of them. |
| Q11 compares two monochrome sizes and a same-size, three-byte RGB picture. | Storage grows with area and with information per pixel. The RGB format needs 24 times the raw storage at the same dimensions. |
| Q12 supplies a reusable bit-switch header and test cases, then uses the function to build and inspect a pattern with loops. | The previous low-to-high bit-reading task is retained inside this programming exercise, preserving the bridge to Phase 3. Previous question and section anchors remain as aliases. |
| Q13 combines an interactive RGB conversion challenge with packing/unpacking function stubs and tests. | Students transfer hex, shifts, OR, and AND into a different data format. The mixer supports both directions, exact numeric checks, live swatches, and per-channel binary/hex/decimal readouts. |
| Added a short RGB primer before Homework and RGB/channel/packing review terms. | The new challenge explains its data format before asking students to use it, and explicitly preserves the OLED's one-bit-per-pixel format. |
| Replaced the 16×8 storage text fence with TeX rendered as native MathML. | The three calculations read as mathematical statements, with the bit-per-pixel and bits-per-byte assumptions stated immediately above them. Browser CSS keeps the equals signs aligned without loading an external math script. |
| Expanded the opening from a definition into representation → light states → a storage problem. Added an eight-bulb/bit diagram, with the calculation behind hints and an answer reveal. | The same data can carry different meanings. Students first see one bit per light, then attempt pixels → bits → bytes before seeing the worked math. The diagram deliberately leaves OLED memory placement for Phase 3. |
| Added a quiet optional link to Maths Is Fun's binary guide. | Students can seek extra base-2 explanation and practice without treating an external lesson as a prerequisite. |
| Retained Byte Builder and documented bin()/hex() output and leading zeroes. | Students get repeated feedback without confusing the printed representation with a different underlying value. |
| Simplified the starter to setup plus prompts. | No hidden helper silently masks values or demonstrates unfamiliar operators before the student has learned them. |

## Phase 3: Memory Organization

| Revision | Reason and learning payoff |
| --- | --- |
| Rebuilt the Lite-Brite opening around a real toy photo, explicit OLED analogy, board rules, and a six-step triangle walkthrough. | Students predict one highlighted vertical byte at a time and reveal its effect. The shape gives the activity a purpose; guided attention comes before open exploration. The analogy distinguishes actual Lite-Brite hardware from the OLED packing rule. |
| Stabilized the triangle controls in a separate row below the board and explanation; all prediction/result cards share one grid cell sized to the longest state. | Buttons stay in place across all twelve states, including on narrow screens, without clipping text or imposing a fixed height. Each step names its destination and target rows, asks for a written prediction, then reveals the byte, bit order, reasoning, and a concise transferable idea. |
| Delayed the open board and removed its early flat byte indices. It now supports both pixel clicks and whole-byte sends to a page and column. | Students isolate coordinate → page/column/bit reasoning, including (2,14) → Page 1, column 2, bit 6, 0x40. The buffer-slot explanation starts with the unresolved OLED address: Page 1, column 2 → which index? Tic-tac-toe illustrates the same row-to-list count, and that count is immediately applied to the original OLED byte before inverse mapping and the full pixel recipe. |
| Replaced twenty numbered drills plus four intermezzo problems with explanations, worked examples, and seven synthesis problems. | Repeated one-step questions had obscured the main model. Page height, page width, and bit order are now explained once and then used together. |
| Explicitly distinguished row/column list indexing from screen (x, y) order. | Both conventions occur in one lesson; leaving the order implicit creates avoidable mistakes. |
| Showed every step for (2, 14), width 8, before asking students to scale to (37, 29), width 128. | The page, within-page offset, skipped bytes, column offset, and mask each have a visible meaning. The width switch is deliberate and labelled. |
| Replaced the intermezzo framing with an explicit OLED index problem, a tic-tac-toe analogy, and an immediate return to `buffer[10]`. | Students know why they are looking at another grid. The shared counting rule is named, while a square's mark and a byte of eight pixels are kept distinct. Previous section anchors remain available. |
| Aligned the explorer's row labels, pixel labels, and form fields; moved byte values into a full-width table with one row per page. | The visual layout now matches the explanation of two pages × eight columns. Pages no longer wrap into misleading two-row groups, and narrow screens scroll the byte table inside its own region. |
| Q2 interprets the same flat index at two widths; Q6 decodes the same byte at two widths. | Together they establish that an address needs layout information, in both directions. |
| Q4 repairs a whole-byte assignment that erases an existing neighboring pixel. | The problem connects correct addressing with Phase 2's preservation masks; getting one of these right is insufficient. |
| Added coordinate checks before address arithmetic, with the counterexample (128, 0). | An out-of-screen coordinate can produce a valid index in another page. Negative Python indices can also silently target the end. |
| Q7 combines width-aware mapping, set/clear, neighbor preservation, and an explicit invalid-input rule. | Students build a useful small operation instead of reciting four formulas. Dimensions and integer-input assumptions are stated. |
| Replaced loose bytearray truncation wording with valid 0–255 operations and explicit masking when intended. | CPython and MicroPython versions can differ on out-of-range assignments. The examples should not depend on an implicit conversion. |

## Phase 4: The Frame Buffer

| Revision | Reason and learning payoff |
| --- | --- |
| Reframed the opening as connecting Phase 1's observation to Phase 3's exact bytes. | This lesson now deepens something students have already seen instead of presenting drawing versus showing as entirely new. |
| Made whole-file execution the default and explained display initialization at setup. | The experiments no longer depend on retained REPL variables, input(), editor timing, or an image left by an earlier run. |
| Kept the grey session note optional and clarified reset-before-run versus reset-after-upload. | The platform issue should not become a prerequisite for understanding memory. The setting's actual scope matters. |
| Q2 compares a drawing method, a raw byte edit, and a pixel read. | It demonstrates that these interfaces reach the same storage and distinguishes one pixel's state from the containing byte's value. |
| Q3 uses a two-column trace; comments are explicitly not pauses. | Students reason about intermediate states without being promised that fast script execution will leave time to inspect them physically. |
| Consolidated whole-frame transfer, persistence, and no-replay explanations. | These establish what the driver does without repeating near-identical questions about show(). |
| Q6 compares per-dot transfers with one batched transfer. | Students connect visible intermediate states to communication cost; payload bytes are distinguished from total bus traffic. |
| Added snapshots, shared references, and restoring bytes into the existing buffer; Q7 uses them. | A second name does not save a previous state. This recurring programming concept becomes concrete and extends the final exercise beyond Phase 1's two-image question. |
| Added the memory cost of frame copies. | This carries Phase 2's image budget into a real design choice and prepares Phase 5's reuse of one working buffer. |

## Phase 5: Drawing Graphics

| Revision | Reason and learning payoff |
| --- | --- |
| Preserved the square → 8×8 character cell → adjacent characters progression and its diagrams. | A visible square makes an otherwise invisible character-cell boundary testable. This was particularly effective in the classroom discussion. |
| Q1 counts inclusive endpoints; Q2 derives the last fitting start; Q3 distinguishes next-cell start from current-cell last column. | The three problems address different off-by-one ideas, rather than repeating one calculation with new numbers. |
| Taught character-cell versus glyph, centering, contrast, and drawing order before the composition tasks. | The concepts are available before students need them. A letter that appears complete does not prove its cell fits. |
| Explained where drawing commands originate without opening the driver yet. | FrameBuffer supplies drawing tools; the driver adds OLED-specific work. This answers a natural question and sets up Phase 6. |
| Q4 prepares a scene from x, leaving show() outside the function. | Separating state, drawing, and transfer gives the animation loop a clear structure. The example is tested by editing and rerunning, without STOP comments. |
| Homework Q5 centers Hi Yush in a padded panel. | This combines text-cell counts, coordinates, padding, contrast, and layering in one concrete design. |
| Homework Q6 counts frames and image bytes for the finite animation. | It connects object size and range()'s exclusive stop with Phase 4's full-frame transfer cost. |
| Homework Q7 traces and repairs a one-frame lag. | A correct final picture alone does not prove every displayed frame was correct. Students must reason about the sequence, not patch its last symptom. |
| Retained speed/smoothness as a concise worked comparison and kept timing overhead explicit. | Movement per second and number of intermediate frames are different choices; sleep time alone is not actual frame rate. |

## Second pass: the course as a whole

| Connection | How the revised sequence supports it |
| --- | --- |
| Phase 1 → 2 | A visible message and its numeric I²C address motivate bits, bytes, and equivalent number notation. |
| Phase 2 → 3 | Set/clear/test masks become pixel edits. Low-to-high bit inspection becomes top-to-bottom interpretation in the explicitly introduced MONO_VLSB layout. |
| Phase 3 → 4 | A raw standalone buffer becomes the same storage used by the real drawing methods. Students keep using (37, 29), byte 421, bit 5 as a reference case. |
| Phase 4 → 5 | Separate prepared/displayed state becomes a draw–show–pause sequence. Snapshot cost makes reuse of one buffer meaningful. Transfer counts carry into the animation calculation. |
| Phase 5 → planned 6 | Students have used functions and objects and know drawing and hardware work are shared. Phase 6 still needs to introduce class/inheritance vocabulary before asking students to read those parts of the driver. |

Resolved gaps: layout width versus value, row/column versus x/y order, coordinate validity versus index validity, assignment versus masking, names versus copies, whole-file initialization versus persistent sessions, inclusive coordinates versus exclusive loop stops, and image payload versus total I²C traffic.

Retained boundaries: these lessons do not claim all image layouts pack pixels vertically, all drivers send whole frames, or that show() creates an instantaneous physical update. Detailed I²C signaling, controller commands, and datasheet reading remain the work of planned Phases 7–9. The eventual driver still reuses MicroPython's I²C and frame-buffer tools.

The project guide and reading-order index were updated to describe the revised work and shared Homework convention. The board/project introductions remain guides rather than receiving artificial homework sections.

## Validation

- Hugo minified build succeeded using an allowed temporary cache directory.
- Five rendered lesson pages checked for local links, fragment targets, unique IDs, 41 numbered exercises (13 in Phase 2, seven in each other phase), one-to-three hints, and the shared Homework hierarchy.
- Python syntax checked for all fenced examples; JavaScript syntax checked for all 14 inline lesson scripts. All four revised starters execute in the test environment and contain only setup as executable code. The expanded Phase 2 answers were executed, including 1,024 RGB round trips checked against Python's independent byte-to-integer conversion.
- Bit-switch behavior checked for every byte value and bit position. Pixel mapping and set/clear behavior checked for every coordinate in both 8×16 and 128×64 pictures, including invalid-input preservation.
- The bundled driver was exercised against an in-memory FrameBuffer/I²C model for full-buffer sends, copies/restores, batched transfers, 31-frame animation boundaries, and lag diagnosis/repair. The model checks state and geometry; it uses stand-in glyph artwork and is not a physical OLED test.
- Browser checks passed for definitions, keyboard disclosures, Byte Builder, both grid-index game modes, separate RAM/display changes, and the animation's final x=120/frame=31. The revised Lite-Brite walkthrough was checked through all six columns (6, 12, 16, 20, 22, 24 lit points), answer hiding between steps, completion, and restart. The explorer was checked for (2,14), equivalent byte sends, preserving neighbors on a pixel toggle, and rejecting invalid byte input without changing the picture.
- All revised lessons checked at 390px and 663px widths with answers and definitions expanded; no page-width overflow was observed. Byte Builder's minimum column sizing was corrected to fit the smaller layout.
- The expanded Phase 2 was additionally checked at 320px and 390px widths with answers and definitions expanded. Its new wide conversion tables scroll inside their own regions. RGB checks cover both directions, wrong-channel feedback, byte bounds, incomplete/invalid codes, leading zeroes, case-insensitive hex, keyboard submission, and resetting between rounds.
- The guided triangle was checked through all twelve prediction/reveal states and reset at actual CSS widths of 320px, 390px, and 1280px. Button positions and heights stayed constant; all six writes produced the expected pixels without clearing previous columns. Only the active explanation is exposed to assistive technology, and no page-width overflow was observed.
- The open explorer's board/readout top edges and Page/Column controls were measured for alignment. Every row label is vertically centered with its pixel row. At 320px and 390px, the page stays within the viewport and the eight-column byte table scrolls internally. Clicking (2,14), sending 0x41 to Page 1/column 2, and rejecting 256 updated or preserved the expected pixels and table cells.
- Official driver and MIT license kept unchanged. Unrelated Swift/PokéPlot work and output/ were not staged or edited. Nothing was published.

Primary references checked: [MicroPython framebuf](https://docs.micropython.org/en/v1.26.0/library/framebuf.html), [framebuf implementation](https://github.com/micropython/micropython/blob/v1.26.0/extmod/modframebuf.c), [sleep_ms timing](https://docs.micropython.org/en/v1.26.0/library/time.html#time.sleep_ms), the bundled SSD1306 source, and [MicroPico setting descriptions](https://github.com/paulober/MicroPico/blob/main/package.nls.json).

Photo in Phase 3: [Hello on a Lite-Brite](https://commons.wikimedia.org/wiki/File:Hello_on_a_Lite-Brite.jpg), thomas ambridge / Dhscommtech, [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). The reduced-size Wikimedia preview is stored locally; the lesson caption credits the author, links the source and license, and notes the size change.
