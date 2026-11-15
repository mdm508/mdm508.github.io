#!/usr/bin/env python3
"""Check Phase 6 examples against the bundled driver without an OLED.

The small FrameBuffer stand-in models only MONO_VLSB fill/pixel storage.
It does not test MicroPython's C implementation, fonts, bus timing, or hardware.
Pass --build-dir to also check rendered links, IDs, and inline JavaScript syntax.
"""

import argparse
import ast
import contextlib
import copy
from html.parser import HTMLParser
import importlib.util
import io
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import types
from urllib.parse import unquote, urlsplit

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "content/post/the-ssd1306-driver.md"
DRIVER = ROOT / "static/downloads/pico/phase-1-kit/ssd1306.py"
STARTER = ROOT / "static/downloads/pico/phase-6-driver-lab.py"


def blocks(text):
    return re.findall(r"```python\n(.*?)```", text, re.S)


def run(code, env):
    with contextlib.redirect_stdout(io.StringIO()) as output:
        exec(compile(code, "<Phase 6 example>", "exec"), env)
    return output.getvalue().strip()


class FrameBuffer:
    """An independent storage model for the pixel operations used in the tests."""

    def __init__(self, buffer, width, height, format):
        assert format == 0 and len(buffer) == width * height // 8
        self._storage = buffer
        self._width = width
        self._height = height

    def fill(self, color):
        self._storage[:] = bytes([255 if color else 0]) * len(self._storage)

    def pixel(self, x, y, color=None):
        if not (0 <= x < self._width and 0 <= y < self._height):
            return None
        index = (y // 8) * self._width + x
        mask = 2 ** (y % 8)
        if color is None:
            return int(bool(self._storage[index] & mask))
        if color:
            self._storage[index] |= mask
        else:
            self._storage[index] &= ~mask


def load_driver():
    micropython = types.ModuleType("micropython")
    micropython.const = lambda value: value
    framebuf = types.ModuleType("framebuf")
    framebuf.FrameBuffer = FrameBuffer
    framebuf.MONO_VLSB = 0
    saved = {name: sys.modules.get(name) for name in ("micropython", "framebuf")}
    sys.modules.update(micropython=micropython, framebuf=framebuf)
    try:
        spec = importlib.util.spec_from_file_location("lesson_ssd1306", DRIVER)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    finally:
        for name, previous in saved.items():
            if previous is None:
                sys.modules.pop(name, None)
            else:
                sys.modules[name] = previous
    return module


class Page(HTMLParser):
    def __init__(self, html):
        super().__init__()
        self.ids = []
        self.links = []
        self.feed(html)

    def handle_starttag(self, tag, attrs):
        attributes = dict(attrs)
        if "id" in attributes:
            self.ids.append(attributes["id"])
        for key in ("href", "src"):
            if key in attributes:
                self.links.append(attributes[key])


def check_build(build):
    slugs = (
        "post/the-ssd1306-driver", "post/drawing-graphics",
        "post/pico-oled-project", "courses/pico",
    )
    for slug in slugs:
        path = build / slug / "index.html"
        html = path.read_text()
        page = Page(html)
        assert len(page.ids) == len(set(page.ids)), f"Duplicate IDs in {slug}"
        for href in page.links:
            url = urlsplit(href)
            if url.scheme or url.netloc or (url.path and not url.path.startswith("/")):
                continue
            target = build / url.path.lstrip("/") if url.path else path
            if target.is_dir():
                target /= "index.html"
            assert target.exists(), (slug, href)
            if url.fragment and target.suffix == ".html":
                assert unquote(url.fragment) in Page(target.read_text()).ids, (slug, href)
        if slug == "post/the-ssd1306-driver":
            assert "driver-call-trace" in page.ids
            assert "&lt;option" not in html and "&lt;section" not in html
            assert html.count("class=lesson-review-divider") == 1
            assert len(re.findall(r'<details class=[\"\']?glossary-definition(?:[\"\' >])', html)) == 14
            assert "data-scope=lesson" not in html
            for attrs, script in re.findall(r"<script([^>]*)>(.*?)</script>", html, re.S):
                if "application/ld+json" in attrs or not script.strip():
                    continue
                assert shutil.which("node"), "Node is needed to check inline JavaScript"
                with tempfile.NamedTemporaryFile(mode="w", suffix=".js") as temporary:
                    temporary.write(script)
                    temporary.flush()
                    subprocess.run(["node", "--check", temporary.name], check=True)
    assert (build / "downloads/pico/phase-6-driver-lab.py").read_bytes() == STARTER.read_bytes()
    guide = (build / "post/pico-oled-project/index.html").read_text()
    table = re.search(r"<table.*?</table>", guide, re.S)[0]
    assert "/post/the-ssd1306-driver/" in table, "Phase 6 must be in the published table"
    print("PASS rendered lesson, glossary, navigation, local assets/fragments, and JavaScript syntax.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build-dir", type=Path)
    args = parser.parse_args()
    source = SOURCE.read_text()
    questions = dict((int(number), body) for number, body in re.findall(
        r'{{< lesson-exercise number="(\d+)"[^>]* >}}(.*?){{< /lesson-exercise >}}', source, re.S
    ))
    assert list(questions) == list(range(1, 8))
    answers = {}
    for number, body in questions.items():
        hints = re.search(r"{{< hints >}}(.*?){{< /hints >}}", body, re.S)
        assert hints and 1 <= len(re.findall(r"^- ", hints[1], re.M)) <= 3, number
        answers[number] = re.search(r"{{< answer >}}(.*?){{< /answer >}}", body, re.S)[1]
    assert source.index("## Homework") < source.index("### Explain yourself") < source.index("### Exercises") < source.index("## What's next")
    for code in blocks(source):
        ast.parse(code)
    starter = ast.parse(STARTER.read_text())
    assert all(isinstance(node, (ast.Expr, ast.Import, ast.ImportFrom, ast.Assign)) for node in starter.body)
    assert not any(isinstance(node, (ast.FunctionDef, ast.ClassDef, ast.For, ast.While)) for node in starter.body)
    glossary = json.loads((ROOT / "data/phase6_glossary.json").read_text())
    assert len(glossary) == len({term["id"] for term in glossary}) == 14

    driver = load_driver()
    env = {"ssd1306": driver, "WIDTH": 128, "HEIGHT": 64}
    assert run(blocks(source)[0], env) == "64"
    assert run(blocks(questions[1])[0], env) == "64 0"
    assert env["first"].buffer is not env["second"].buffer
    assert "show" not in driver.SSD1306_I2C.__dict__
    assert "show" in driver.SSD1306.__dict__
    assert "text" not in driver.SSD1306_I2C.__dict__ and "text" not in driver.SSD1306.__dict__
    assert driver.SSD1306.fill is FrameBuffer.fill
    # The supplied scaffold is intentionally wrong in one recording line.
    run(blocks(questions[5])[0], env)
    assert run(blocks(questions[5])[1], env) == "False\nTrue"
    assert env["bus"].events[0][2] is env["scratch"]
    repaired = next(code for code in blocks(answers[5]) if code.startswith("class RecordingI2C:"))
    run(repaired, env)
    assert run(blocks(questions[5])[1], env) == "True\nTrue"
    assert run(blocks(answers[5])[-1], env) == "1024\nwritevto\n1025"
    assert env["bus"].events[-1] == ("writevto", 60, b"\x40" + bytes(1024))
    Recorder = env["RecordingI2C"]
    assert Recorder().writeto(60, b"ab") == 2
    assert Recorder().writevto(60, [b"a", bytearray(b"bc")]) == 3

    assert driver.SSD1306_SPI.show is driver.SSD1306_I2C.show
    assert driver.SSD1306_SPI.init_display is driver.SSD1306_I2C.init_display
    assert driver.SSD1306_SPI.write_data is not driver.SSD1306_I2C.write_data
    assert driver.SSD1306_SPI.write_cmd is not driver.SSD1306_I2C.write_cmd
    assert source.index("## Read show() as a Recipe") < source.index('{{< lesson-exercise number="2"')
    assert source.index("## Follow a Successful Setup First") < source.index('{{< lesson-exercise number="3"')
    assert source.index("{{< driver-call-trace >}}") < source.index("## Read show() as a Recipe")
    assert 'title="Optional: count transfers' in source

    # Simulate precisely the Q3 edit on a copy of the class AST, never on disk.
    tree = ast.parse(DRIVER.read_text())
    cls = copy.deepcopy(next(node for node in tree.body if isinstance(node, ast.ClassDef) and node.name == "SSD1306_I2C"))
    cls.name = "LateScratch"
    init = next(node for node in cls.body if isinstance(node, ast.FunctionDef) and node.name == "__init__")
    assignment = next(node for node in init.body if isinstance(node, ast.Assign) and any(isinstance(t, ast.Attribute) and t.attr == "temp" for t in node.targets))
    init.body.remove(assignment)
    init.body.append(assignment)
    namespace = dict(driver.__dict__)
    exec(compile(ast.fix_missing_locations(ast.Module(body=[cls], type_ignores=[])), "<Q3 delayed scratch>", "exec"), namespace)
    bus = Recorder()
    try:
        namespace["LateScratch"](128, 64, bus)
        raise AssertionError("Delayed scratch initialization did not fail")
    except AttributeError as error:
        assert "temp" in str(error) and not bus.events

    for height, last_page, image_size in [(32, 3, 512), (64, 7, 1024)]:
        bus = Recorder()
        screen = driver.SSD1306_I2C(128, height, bus)
        assert screen.pages == last_page + 1 and len(screen.buffer) == image_size
        bus.events.clear()
        for x in range(10):
            screen.pixel(x, 0, 1)
        assert not bus.events, "Drawing unexpectedly requested a transfer"
        screen.show()
        screen.show()
        commands = [event[2][1] for event in bus.events if event[0] == "writeto"]
        assert commands == [0x21, 0, 127, 0x22, 0, last_page] * 2
        frames = [event[2] for event in bus.events if event[0] == "writevto"]
        assert len(frames) == 2 and frames[0] == frames[1] == b"\x40" + bytes(screen.buffer)
        assert sum(len(frame) - 1 for frame in frames) == image_size * 2

    result = run(blocks(answers[6])[0], env).splitlines()
    assert result == ["True", r"1 b'\x80\xa7'", "True"], result
    assert env["oled"].buffer[421] == 32
    assert len(env["bus"].events) == 9
    assert env["bus"].events[-1][2] == b"\x80\xa6"
    run(blocks(answers[7])[0], env)
    for height, size in [(64, 1024), (32, 512)]:
        code = blocks(questions[7])[1].replace("CountingOLED(128, 64, bus)", f"CountingOLED(128, {height}, bus)")
        assert run(code, env) == f"1 {size}\n4 {4 * size}"
        frames = [event[2] for event in env["bus"].events if event[0] == "writevto"]
        assert len(frames) == 4 and frames[0] == b"\x40" + bytes(size)
        for frame, x in zip(frames[1:], (0, 8, 16)):
            expected = bytearray(size)
            expected[x] = 1
            assert frame == b"\x40" + bytes(expected)
    previous_driver = sys.modules.get("ssd1306")
    sys.modules["ssd1306"] = driver
    try:
        assert "Setup sends nothing" in run(STARTER.read_text(), {})
    finally:
        if previous_driver is None:
            sys.modules.pop("ssd1306", None)
        else:
            sys.modules["ssd1306"] = previous_driver
    print(f"PASS seven problems, {len(blocks(source))} Python snippets, setup-only starter, instance state, initialization order, ranges, snapshots, inversion, and delegated transfer counts at both heights.")
    if args.build_dir:
        check_build(args.build_dir.resolve())


if __name__ == "__main__":
    main()
