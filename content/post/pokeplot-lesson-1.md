---
title: "PokePlot, Lesson 1: Ask the Pokédex"
date: 2026-10-18T12:00:00-07:00
draft: false
description: "Explore PokéAPI, understand JSON, and follow image URLs to download a small Pokémon gallery with Python."
summary: "Read the API docs, turn JSON into Python data, and download three Pokémon pictures. Then complete a few small functions to collect your team."
tags: ["python", "apis", "pokemon", "pokeplot", "data-science"]
reading_time: 60
toc: false
---

## Where This Lesson Fits

**Can Python collect pictures of your favorite Pokémon?** Today we will explore a real API and finish with a small gallery of downloaded images. Later, PokePlot will use the same records to investigate questions, calculate statistics, make plots, and simulate a small game.

Our larger project follows this path:

**Question → URL → HTTP response → JSON → Python dictionaries/lists → NumPy array → plot → interpretation**

Today's useful side trip is **an image URL → another response → an image file**. Aim to save your first picture during the first 40 minutes, then use the rest of the hour to collect three favorites. Work through one question at a time: predict, try it, and explain before opening an answer.

## Before You Begin

{{< download "/downloads/pokeplot/pokeplot-lesson-1.ipynb" "Download the starter notebook" >}} and open it in Jupyter. Use Python 3.10 or newer. If needed, install the two libraries we will use:

```python
%pip install requests pillow
```

You can also {{< download "/downloads/pokeplot/pikachu.json" "download a saved Pikachu response" >}} for offline practice. Keep it in the notebook's working folder. This is a saved JSON body, not a live response. You can explore it offline, but downloading an image you have not already saved still needs a connection.

## Meet PokéAPI

An **API**, short for *application programming interface*, gives programs an agreed way to request information or actions. **[PokéAPI](https://pokeapi.co/)** is a public Pokémon data service. It provides records about Pokémon, moves, types, abilities, and more. We will use its HTTP API directly from Python; no account or API key is required.

Start by browsing the [PokéAPI documentation](https://pokeapi.co/docs/v2). Skim the Information section, then jump to the [Pokémon endpoint](https://pokeapi.co/docs/v2#pokemon). Notice the sample request, the example reply, and the table explaining each field. You do not need to read the whole page.

### Q1: Where should we look for a picture?

**Problem:** Our goal is to collect Pokémon pictures. Which field in the Pokémon documentation looks like a useful starting point?

{{< hints >}}
Look for a field whose description mentions pictures or sprites. A sprite is a small image used to depict a character in a game.
{{< /hints >}}

{{< answer >}}
The `sprites` field leads to information about Pokémon pictures. Follow its type link to see fields such as `front_default` and `front_shiny`.

The documentation describes what the API promises to return. We will inspect an actual response to see how those fields are organized.
{{< /answer >}}

## Ask for a Pokémon

Open [Pikachu's API URL](https://pokeapi.co/api/v2/pokemon/pikachu/):

```text
https://pokeapi.co/api/v2/pokemon/pikachu/
```

A **URL** is an address. An **endpoint** is an address where an API makes a resource or operation available. Here, `pokeapi.co` is the server's domain, `pokemon` selects the kind of resource, and `pikachu` identifies the Pokémon.

Your browser may display a large block of text or a collapsible tree. Find the top-level `"name"` and `"sprites"` fields. The browser's formatting can make the reply easier to explore; Python will receive data it must decode itself.

### Q2: Can you ask for a different Pokémon?

**Problem:** Predict what will change if you replace `pikachu` with `eevee` in the URL. Then try it and find the returned name.

{{< hints >}}
Keep the server and `/api/v2/pokemon/` part the same. Change only the Pokémon's name.
{{< /hints >}}

{{< answer >}}
The server returns Eevee's record. The URL describes which resource you want; it does not contain the returned data itself.
{{< /answer >}}

## Send a Request from Python

A **client** sends a request; a **server** sends a response. Your browser was the client in Q2. Now Python will take that role.

**HTTP** is the protocol used for this exchange. **GET** is the method we use to retrieve a resource.

Run this cell once, then reuse the response:

```python
import requests

url: str = "https://pokeapi.co/api/v2/pokemon/pikachu/"
response: requests.Response = requests.get(url, timeout=10)
print(response.status_code)
```

`requests.get(...)` sends the request and returns a `Response` object. `timeout=10` limits network waiting; it is not a guaranteed ten-second deadline for the entire download.

The response has a **status**, **headers** describing its content, and a **body** containing that content. Its status code tells us how the request went:

| Status | Meaning |
| --- | --- |
| `200` | The request succeeded. |
| `404` | The requested resource was not found. |
| `500` | The server encountered an internal error. |

### Q3: Did the server answer successfully?

**Problem:** Use the printed status code to explain whether the request succeeded.

{{< hints >}}
Receiving a response and receiving the resource you wanted are different things. Match the number to the table.
{{< /hints >}}

{{< answer >}}
For this valid URL, expect `200`. The request succeeded, and we can inspect the body.

A connection failure is different: Python may raise an exception before there is any response to inspect.
{{< /answer >}}

Check for an HTTP error, then save the body so you can reuse it:

```python
from pathlib import Path

response.raise_for_status()
cache_file: Path = Path("pikachu.json")
_ = cache_file.write_text(response.text, encoding="utf-8")
```

`raise_for_status()` raises an exception for HTTP error statuses. `write_text` saves the body as text. `_` receives a character count that we do not need. Reusing saved responses follows [PokéAPI's caching policy](https://pokeapi.co/docs/v2#fairuse).

## JSON Is Text with Structure

`response.text` gives us the body as a Python string. Inspect just the beginning:

```python
raw_json: str = response.text
print(type(raw_json))
print(raw_json[:200])
```

The body uses **JSON**, short for *JavaScript Object Notation*. JSON is a text format for exchanging structured values. It can describe names, numbers, lists, and nested records using characters that travel over a network or live in a file.

The full reply is large, so first experiment with this **shortened practice record**. We have kept just a few fields from Pikachu:

```python
tiny_json: str = """{
  "name": "pikachu",
  "height": 4,
  "is_default": true,
  "types": [{"type": {"name": "electric"}}],
  "sprites": {
    "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png"
  }
}"""
```

The outer triple quotes make this a Python string. Inside that string, braces group named fields, a colon separates a field name from its value, and commas separate fields. Double quotes surround JSON names and string values; the number `4` has no quotes. The `sprites` value is itself another grouped record.

### Q4: What does indexing the JSON text select?

**Problem:** Predict `tiny_json[0]` before running it. Are you selecting a field or a character?

{{< hints >}}
The annotation says `str`. A string is a sequence of characters, even when its text looks like a dictionary.
{{< /hints >}}

{{< answer >}}
It returns the character `{`. `tiny_json` is still text, so indexing selects a character. `tiny_json["name"]` would raise a `TypeError`; a string does not support a dictionary lookup by key.
{{< /answer >}}

**Decoding** turns the JSON text into Python objects:

```python
import json
from typing import Any

tiny_data: dict[str, Any] = json.loads(tiny_json)
print(type(tiny_data))
```

`json.loads` means “load JSON from a string.” It interprets the text's structure instead of treating every character separately. It does not execute Python code; use the JSON decoder rather than `eval`.

### Q5: Does decoding turn every value into a string?

**Problem:** Predict the type of `tiny_data["height"]`, then check it with `type(...)`.

{{< hints >}}
Look at whether the `4` has quotation marks in the JSON. Compare it with `"pikachu"`.
{{< /hints >}}

{{< answer >}}
It is an `int`. JSON describes the value as a number, so decoding creates a Python number. The `"name"` value becomes a string, and `"sprites"` becomes a dictionary.
{{< /answer >}}

Some spellings change during decoding:

| In JSON text | In Python after decoding |
| --- | --- |
| `{...}` | `dict` |
| `[...]` | `list` |
| `"pikachu"` | `str` |
| `4` | `int` |
| `true` / `false` | `True` / `False` |
| `null` | `None` |

Our small example uses `true` inside text. Python's Boolean object is `True`. Missing images may be represented by JSON `null`, which becomes Python `None`.

An object groups values under names; an array keeps a sequence in order. In the practice record, `tiny_data["types"]` is a list. `tiny_data["types"][0]` selects its first dictionary. We use a string key to enter an object and an integer index to select an array entry.

Now decode the real response:

```python
pokemon: dict[str, Any] = response.json()
print(type(pokemon))
```

`response.json()` decodes the existing body, just as `json.loads(response.text)` would. It does not send another request. `dict[str, Any]` describes our expected dictionary with string keys and mixed value types; annotations do not validate the API's data.

After restarting the notebook, or when using the saved file offline, restore the dictionary with:

```python
pokemon: dict[str, Any] = json.loads(
    Path("pikachu.json").read_text(encoding="utf-8")
)
```

This local read creates no new HTTP response.

## Follow the Image's Address

Explore the top-level keys:

```python
print(pokemon.keys())
```

### Q6: How can you retrieve the name?

**Problem:** Retrieve and print just the Pokémon's name. Annotate the name variable.

{{< hints >}}
A dictionary lookup uses a key in square brackets. The returned name is a string.
{{< /hints >}}

{{< answer >}}
```python
name: str = pokemon["name"]
print(name)
```
{{< /answer >}}

Look at the smaller dictionary of sprite information:

```python
sprites: dict[str, Any] = pokemon["sprites"]
print(sprites.keys())
```

### Q7: Does the JSON contain a picture, or its address?

**Problem:** Retrieve `front_default` from the real record's `sprites` dictionary. Print the value and its Python type, then open that value in your browser.

{{< hints >}}
Use two dictionary lookups: first `"sprites"`, then `"front_default"`. Compare the returned value with the URL you used to request the Pokémon record.
{{< /hints >}}

{{< answer >}}
```python
image_url: str | None = pokemon["sprites"]["front_default"]
print(image_url)
print(type(image_url))
```

For Pikachu, this is a string containing a PNG image's URL. The JSON record gives us an address. The picture is retrieved by requesting that address separately.
{{< /answer >}}

`str | None` means a string or a missing value. Check before trying to request an image:

```python
if image_url is None:
    raise ValueError("This Pokémon has no default front sprite.")
```

Changing an image's URL locally does not change the Pokémon record on the server. Retrieving another key from `pokemon` also does not make another request.

## Download the Picture

Make a second GET request, this time to the image's URL:

```python
image_response: requests.Response = requests.get(image_url, timeout=10)
image_response.raise_for_status()

print(image_response.headers.get("Content-Type"))
image_bytes: bytes = image_response.content
print(type(image_bytes))
```

A **header** can describe what the body contains. This image response reports `image/png`. `.content` gives us the body as **bytes**, suitable for writing an image file. Calling `.json()` here would ask Python to interpret PNG data as JSON.

### Q8: How should we save image data?

Prepare a filename:

```python
image_path: Path = Path("images/pikachu.png")
image_path.parent.mkdir(parents=True, exist_ok=True)
```

**Problem:** Should we use `image_path.write_text(...)` or `image_path.write_bytes(...)` to save `image_bytes`? Choose one, write the line, and save your first picture.

{{< hints >}}
The response body is a `bytes` object. Match the writing method to that type. Saving `image_url` would save the address rather than the picture.
{{< /hints >}}

{{< answer >}}
```python
_ = image_path.write_bytes(image_bytes)
```

The file now contains the PNG data. Giving a text file a `.png` filename would not turn its contents into an image.
{{< /answer >}}

Open the saved file, or inspect it with Pillow in the notebook:

```python
from PIL import Image

with Image.open(image_path) as image:
    print(image.format)
    print(image.size)
    display(image)
```

`display` is available in Jupyter. In a `.py` file, open the saved image in your image viewer instead.

### Q9: Are file bytes the same thing as pixels?

**Problem:** Compare `len(image_bytes)` with the image's width times height. Explain why these numbers need not match.

{{< hints >}}
Width times height counts pixels. PNG is a compressed file format, and a pixel can have several color channels.
{{< /hints >}}

{{< answer >}}
`len(image_bytes)` counts bytes in the PNG file. Width times height counts pixels in the decoded image. The file includes format information and compressed image data, so its byte count is not a pixel count or a NumPy array shape.

The supplied Pikachu sprite is 96 × 96, or 9,216 pixels. Its downloaded PNG uses 597 bytes. These are counts of different things.

Pillow decodes those file bytes into an image. In a later lesson, NumPy can represent the decoded pixels as an array.
{{< /answer >}}

## Collect Three Favorites

### Q10: Can you make a tiny Pokémon gallery?

**Problem:** Choose two more favorites and repeat the process for each. Finish with three image files in your `images` folder, each named after its Pokémon. Open them to check that each name matches its picture.

```text
images/
├── pikachu.png
├── eevee.png
└── bulbasaur.png
```

Those are example choices; pick your own favorites. Keep each Pokémon's JSON under a matching name too. Reuse files you already have rather than downloading again.

Here are those three saved example sprites:

<p>
  <img src="/downloads/pokeplot/example-team/pikachu.png" alt="Pikachu's front sprite" width="96" height="96">
  <img src="/downloads/pokeplot/example-team/eevee.png" alt="Eevee's front sprite" width="96" height="96">
  <img src="/downloads/pokeplot/example-team/bulbasaur.png" alt="Bulbasaur's front sprite" width="96" height="96">
</p>

{{< hints >}}
For each new Pokémon, request its record, decode it, find its own image URL, then request and save the image. Change both the requested name and the destination filename.
{{< /hints >}}

{{< answer >}}
Each new Pokémon needs its own record so you can discover its image URL. The response body for that URL supplies the image bytes.

Renaming `pikachu.png` to `eevee.png` would only change the filename; it would still contain Pikachu's picture. Verify the contents by opening each saved file.
{{< /answer >}}

The two related requests have different jobs:

```text
Pokémon endpoint → JSON text → Python dictionary → image URL
Image URL        → PNG bytes → saved picture
```

## Turn Your Steps into Functions

Your notebook now contains the steps for one Pokémon. Give each job a small function so you can reuse those steps.

{{< download "/downloads/pokeplot/pokeplot-starter.py" "Download the unfinished Python starter" >}}, or paste these headers into `pokeplot.py`. Importing the starter makes no requests. The function bodies intentionally raise `NotImplementedError` until you fill them in.

```python
import json
from pathlib import Path
from typing import Any, TypeAlias

import requests

PokemonData: TypeAlias = dict[str, Any]


def pokemon_url(name: str) -> str:
    """Build the endpoint URL; strip whitespace and lowercase the name."""
    raise NotImplementedError


def fetch_pokemon(name: str, cache_dir: Path = Path("data")) -> PokemonData:
    """Read a cached record, or fetch it once, save its JSON, and return it."""
    raise NotImplementedError


def sprite_url(pokemon: PokemonData, shiny: bool = False) -> str | None:
    """Return the normal or shiny front-sprite URL, or None if missing."""
    raise NotImplementedError


def download_image(url: str, destination: Path) -> Path:
    """Reuse an existing file, or download its bytes; return the saved path."""
    raise NotImplementedError
```

`PokemonData` is a type alias: a shorter name for the dictionary type we already used. The downloadable file gives each function a more detailed specification and includes an optional `download_team(...) -> list[Path]` challenge.

For saving a decoded record, `json.dumps(pokemon)` performs the reverse of `json.loads`: it produces JSON text that `write_text` can save.

Complete one function at a time. Start with a prediction such as `pokemon_url(" Pikachu ")`, then check your result. For `sprite_url`, test with your existing dictionary before making another request. The same function should work with another Pokémon's record.

## Homework: Build Your Team's Photo Collection

**Your mission:** choose a team of six Pokémon and collect their pictures using your functions. You should finish with six normal-sprite PNG files, their saved JSON records, and code that can repeat the task using the local files.

Work in stages:

1. **Make the helpers work.** Complete `pokemon_url`, `fetch_pokemon`, `sprite_url`, and `download_image`. Start with one Pokémon you already explored. A short Python loop is fine for collecting several records.
2. **Collect your six.** Save each picture with the correct name. Run your program again: it should reuse the JSON and images already saved. The starter's commented manual checks show how to call your functions without supplying their implementations.
3. **Hunt for shinies.** Use `shiny=True` to collect shiny versions of three team members. Keep both versions with names such as `pikachu.png` and `pikachu-shiny.png`. Predict which colors will change before opening them.

**Choose a challenge:**

- **Bigger artwork:** Explore `sprites` in the response and find official artwork for one team member. Download it under a different filename and compare its pixel dimensions with the small sprite.
- **A missing picture:** Try `sprite_url` with the practice dictionary `{"sprites": {"front_default": None, "front_shiny": None}}`. Make your team collector skip missing images without trying to request `None`.
- **One command, a whole team:** Finish `download_team` in the starter. Return the list of saved paths so another part of your program can use the pictures later.

Bring your gallery and one data question about your team to the next lesson. Name a field you would investigate and make a prediction before calculating anything.

## References

- [PokéAPI documentation](https://pokeapi.co/docs/v2)
- [Pokémon fields and sprite descriptions](https://pokeapi.co/docs/v2#pokemon)
- [PokéAPI fair-use policy](https://pokeapi.co/docs/v2#fairuse)
- [Requests quickstart: JSON and binary responses](https://requests.readthedocs.io/en/latest/user/quickstart/)
