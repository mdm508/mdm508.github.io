"""PokePlot, Lesson 1: build a tiny Pokémon image collection.

Fill in one function at a time. Keep the annotations and use each docstring as
your specification. The functions deliberately have no working implementation.

``PokemonData`` is a type alias: a shorter name for ``dict[str, Any]``. An API
record contains values of several types, including nested dictionaries and lists.
``str | None`` means either a string or ``None``; PokéAPI uses JSON ``null``
(decoded as Python ``None``) when a particular sprite is unavailable.

The Pokémon response contains image URLs, not the image files themselves.
Downloading an image needs a second request whose body is binary image data.

Requires Python 3.10+ and requests. There are no requests or downloads on import.
"""

import json
from pathlib import Path
from typing import Any, TypeAlias

import requests


PokemonData: TypeAlias = dict[str, Any]


def pokemon_url(name: str) -> str:
    """Return this Pokémon's PokéAPI URL.

    TODO: Remove surrounding whitespace and convert the name to lowercase.
    Put that name after ``https://pokeapi.co/api/v2/pokemon/`` and include a
    final slash. For example, ``" Pikachu "`` should produce
    ``"https://pokeapi.co/api/v2/pokemon/pikachu/"``.
    """
    raise NotImplementedError("TODO: Build the Pokémon URL.")


def fetch_pokemon(name: str, cache_dir: Path = Path("data")) -> PokemonData:
    """Return a Pokémon record, reusing a saved JSON file when possible.

    TODO: Normalize the name with ``strip`` and ``lower``. The cache filename
    should be the normalized name followed by ``.json`` inside ``cache_dir``.

    If that file exists, read its UTF-8 text and decode it with ``json.loads``.
    Otherwise, use ``pokemon_url`` and ``requests.get`` with ``timeout=10``.
    Check the HTTP status before decoding the response with ``.json()``.
    Create ``cache_dir`` and any missing parents, save the decoded record as
    UTF-8 JSON using ``json.dumps``, and return the dictionary.

    Calling this function again for the same Pokémon should use the local file.
    Let connection errors and HTTP errors remain visible while learning.
    """
    raise NotImplementedError("TODO: Read cached JSON or fetch and save it.")


def sprite_url(pokemon: PokemonData, shiny: bool = False) -> str | None:
    """Return the URL of a normal or shiny front-facing sprite.

    TODO: Look inside the record's ``sprites`` dictionary. Select
    ``front_default`` when ``shiny`` is False and ``front_shiny`` when it is True.
    Return the selected value, including ``None`` if the sprite is unavailable.

    This function only looks up a value; it does not make a network request.
    """
    raise NotImplementedError("TODO: Select the requested sprite URL.")


def download_image(url: str, destination: Path) -> Path:
    """Save an image's binary data and return its local path.

    TODO: If ``destination`` already exists, return it without downloading again.
    Otherwise, request ``url`` with ``timeout=10`` and check the HTTP status.
    Create the destination's parent directory and any missing parents.
    Save ``response.content`` with ``Path.write_bytes`` and return ``destination``.

    Predict why ``response.json()`` and ``write_text`` would be wrong here.
    """
    raise NotImplementedError("TODO: Download and save the image bytes.")


def download_team(
    names: list[str],
    output_dir: Path = Path("team"),
    shiny: bool = False,
) -> list[Path]:
    """Optional challenge: download a sprite for each Pokémon in ``names``.

    TODO: Combine ``fetch_pokemon``, ``sprite_url``, and ``download_image``.
    A small Python loop is appropriate. Skip a Pokémon if its sprite URL is None.

    Use normalized lowercase names for the saved files: ``pikachu.png`` for a
    normal sprite or ``pikachu-shiny.png`` for a shiny sprite. Save the images
    inside ``output_dir`` and return the list of paths in input order, omitting
    Pokémon with unavailable sprites. Reuse the other functions' caches.
    """
    raise NotImplementedError("TODO: Combine the functions to collect a team.")


# Manual checks: run these yourself after implementing each function.
# Keep them commented until you are ready; this file makes no requests by itself.
#
# 1. Predict this result before checking it:
# print(pokemon_url(" Pikachu "))
#
# 2. Fetch one record, inspect it, then call again to exercise the local cache:
# pikachu: PokemonData = fetch_pokemon("pikachu")
# print(pikachu["name"])
# pikachu_again: PokemonData = fetch_pokemon("pikachu")
#
# 3. Compare the two URL strings before downloading anything:
# normal: str | None = sprite_url(pikachu)
# shiny: str | None = sprite_url(pikachu, shiny=True)
# print(normal)
# print(shiny)
#
# 4. Only a string URL can be passed to download_image:
# if normal is not None:
#     saved: Path = download_image(normal, Path("team/pikachu.png"))
#     print(saved)
# Open the saved file. Is it an image or a file containing an image URL?
#
# 5. Optional: choose three favorites and collect their normal and shiny sprites:
# favorites: list[str] = ["pikachu", "eevee", "bulbasaur"]
# print(download_team(favorites))
# print(download_team(favorites, shiny=True))
