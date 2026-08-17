---
title: "Brightening and Averaging Images with NumPy"
date: 2026-08-16T00:00:00-07:00
draft: false
description: "Learn how NumPy brightens and averages RGB images while avoiding overflow, clipping safely, and working with array axes."
tags: ["python", "numpy", "image-processing"]
summary: "A question-and-answer introduction to safe image arithmetic, vectorization, clipping, stacking, axes, and image averages with NumPy."
---

An image looks like a picture to us, but to NumPy it is an array of numbers. Once you are comfortable moving between those two views, image processing becomes a practical way to learn data types, vectorization, Boolean masks, shapes, axes, and summary statistics.

The central question for this lesson is:

> How can we translate an image-transformation rule from ordinary Python loops into a concise NumPy operation, and what numerical problems do we need to understand before doing it safely?

By the end, you should be able to:

- explain the limits of the `uint8` data type;
- brighten an image with loops and with NumPy;
- use `astype()`, Boolean masks, `np.count_nonzero()`, `np.clip()`, and `np.rint()`;
- average two images with loops and with array arithmetic;
- use `np.stack()` and `np.mean()` with an axis;
- calculate simple color-channel statistics; and
- explain why changing the order of two transformations can change the result.

When you see a **P.R.E.** question, pause and **Predict** the result, **Run** the code, and **Explain** what happened. The prediction matters. It gives you something concrete to compare with the computer's answer.

## Before You Begin

### Question: What files and imports do I need?

You will need two RGB images with identical dimensions. Put them in an `images` folder:

```text
images/
├── first.jpg
└── second.jpg
```

**Answer.** Start with this setup code:

```python
from pathlib import Path

import numpy as np
from PIL import Image


OUTPUT_FOLDER = Path("output")
OUTPUT_FOLDER.mkdir(exist_ok=True)

first_image = Image.open("images/first.jpg").convert("RGB")
second_image = Image.open("images/second.jpg").convert("RGB")

first = np.array(first_image)
second = np.array(second_image)

print("First shape:", first.shape)
print("Second shape:", second.shape)
print("Data type:", first.dtype)
```

The examples below use images with shape `(825, 1100, 3)`, but your height and width may be different. The final `3` represents the red, green, and blue channels.

## 1. Brightening Is Multiplication with a Boundary

Brightening means multiplying each color channel by a factor greater than `1`. There is one important limit: an ordinary 8-bit RGB channel cannot store a value greater than `255`. If a calculation crosses that boundary, we need to clip it.

### Question 1: What happens when we brighten one pixel?

Apply a brightness factor of `1.5` to this pixel:

```text
[100, 180, 240]
```

What values do you calculate, and what pixel can actually be stored?

**Answer.** Multiply each channel separately:

```text
100 × 1.5 = 150
180 × 1.5 = 270
240 × 1.5 = 360
```

The calculated result is `[150, 270, 360]`. Because RGB channels stop at `255`, the stored result must be `[150, 255, 255]`.

Notice what was lost here. The green result was `270` and the blue result was `360`, but both became `255`. After clipping, their original difference is gone. Clipping keeps the image valid, but it cannot preserve detail that lies beyond the boundary.

### Question 2: Why not store values such as 270 or 360?

**Answer.** These image arrays use the `uint8` data type. The name means **unsigned 8-bit integer**:

- unsigned means there are no negative values;
- 8 bits provide 256 possible patterns; and
- those patterns represent the integers `0` through `255`.

A value such as `270` does not fit. Before we save the image, every channel must be returned to the legal range. This is not just an image-processing concern. Every numerical data type has limits, so choosing a type and converting at the right time are part of doing reliable data work.

### Question 3 (P.R.E.): What will this print?

Predict the output before running the code:

```python
values = np.array([250], dtype=np.uint8)

print(values + 10)
```

**Answer.** The output is:

```text
[4]
```

It is not `260`. A `uint8` value wraps around after `255`:

```text
250 + 10 = 260
260 - 256 = 4
```

This is called **integer overflow**. The surprising answer is a useful warning: do not perform image arithmetic in `uint8` when the intermediate result might leave the range `0` through `255`.

## 2. Brighten the Image with Ordinary Loops

Before using NumPy's shorter solution, it helps to write the long version. The loops make every step visible.

### Question 4: How can we brighten every pixel with loops?

Complete the missing expressions:

```python
factor = 1.5
brightened_loop = first.copy()

height, width, channels = first.shape

for row in range(height):
    for column in range(width):
        red, green, blue = first[row, column]

        new_red = __________________________
        new_green = ________________________
        new_blue = _________________________

        brightened_loop[row, column] = [
            new_red,
            new_green,
            new_blue,
        ]
```

**Answer.** Convert each channel to a regular Python integer, multiply it, round it, and cap it at `255`:

```python
factor = 1.5
brightened_loop = first.copy()

height, width, channels = first.shape

for row in range(height):
    for column in range(width):
        red, green, blue = first[row, column]

        new_red = min(255, round(int(red) * factor))
        new_green = min(255, round(int(green) * factor))
        new_blue = min(255, round(int(blue) * factor))

        brightened_loop[row, column] = [
            new_red,
            new_green,
            new_blue,
        ]
```

Save the result:

```python
Image.fromarray(brightened_loop).save(
    OUTPUT_FOLDER / "brightened_loop.png"
)
```

You can read the traversal almost like a set of directions: visit a row, visit a column, unpack one pixel, calculate its three new channels, and place the result into the output array.

### Question 5: What jobs do `int()`, `round()`, and `min()` perform?

**Answer.** Each function handles a different part of the operation:

```python
int(red)
```

`int()` converts the NumPy `uint8` channel to an ordinary Python integer before the arithmetic.

```python
round(100 * 1.5)
```

`round()` turns a possibly fractional result into a whole number.

```python
min(255, calculated_value)
```

`min()` enforces the upper boundary. If the calculated value is `270`, the smaller value is `255`.

Together, the three steps say: calculate safely, produce a whole-number channel, and do not cross the image boundary.

## 3. Replace the Loops with NumPy

A **vectorized operation** asks NumPy to apply one rule across an entire array. Many calculations still happen, but NumPy handles the iteration internally instead of making us write a Python loop for every row and column.

### Question 6 (P.R.E.): What changes when we call `astype()`?

Predict what will change and what will stay the same:

```python
working = first.astype(np.float32)

print(first.shape)
print(working.shape)
print(first.dtype)
print(working.dtype)
```

**Answer.** The shapes are identical:

```text
(825, 1100, 3)
(825, 1100, 3)
```

The data types differ:

```text
uint8
float32
```

`astype(np.float32)` creates a new array with the same values and shape. The new representation can safely hold decimals and values above `255`. The original array remains `uint8`.

The distinction between a value and its representation is important. A number may look the same when printed, but the data type determines which values can be represented and how arithmetic behaves.

### Question 7: What does `working * 1.5` produce?

Does this expression create one value, one pixel, or an entire image?

```python
scaled = working * 1.5
```

**Answer.** It creates an entire array with the same shape as `working`:

```text
(825, 1100, 3)
```

NumPy applies `1.5` to every red, green, and blue channel in every row and column. Applying one scalar value throughout a larger array is a simple example of **broadcasting**.

### Question 8: What does an array comparison produce?

```python
too_high = scaled > 255
```

**Answer.** The comparison produces a Boolean array with the same shape as `scaled`. Every position contains either `True` or `False`.

For example:

```text
scaled value: [150, 270, 360]
comparison:   [False, True, True]
```

This kind of array is called a **Boolean mask**. It records exactly where a condition is true. We can count the channels that would need clipping:

```python
number_clipped = np.count_nonzero(too_high)

print("Channels requiring clipping:", number_clipped)
```

`np.count_nonzero()` counts the `True` entries because `True` behaves like `1` in this context. This condition-mask-count pattern appears often in data analysis: state a condition, create a mask, and count or select the observations that satisfy it.

### Question 9: What does `np.clip()` do?

```python
clipped = np.clip(scaled, 0, 255)
```

**Answer.** `np.clip()` applies a lower and upper boundary to every value:

- values below `0` become `0`;
- values from `0` through `255` stay unchanged; and
- values above `255` become `255`.

For example:

```text
Before: [-10, 80, 270]
After:  [0, 80, 255]
```

The clipped result is still a floating-point array. We wait until the arithmetic is finished before converting it back to `uint8`.

### Question 10: What does a complete NumPy brightness function look like?

How can we check that it agrees with the loop version?

**Answer.** Put the safe conversion, multiplication, clipping, rounding, and final conversion into one function:

```python
def brighten_numpy(pixels, factor):
    """Return a safely brightened RGB array."""
    working = pixels.astype(np.float32)
    scaled = working * factor
    clipped = np.clip(scaled, 0, 255)
    rounded = np.rint(clipped)

    return rounded.astype(np.uint8)
```

Apply it and save the result:

```python
brightened_numpy = brighten_numpy(first, 1.5)

Image.fromarray(brightened_numpy).save(
    OUTPUT_FOLDER / "brightened_numpy.png"
)
```

Now compare every value in the two output arrays:

```python
print(
    "Do the methods agree?",
    np.array_equal(brightened_loop, brightened_numpy),
)
```

For this example, the result should be `True`. `np.array_equal()` checks that the arrays have the same shape and that every corresponding value is equal.

We can also compare a numerical summary:

```python
print("Original mean:", np.mean(first))
print("Brightened mean:", np.mean(brightened_numpy))
```

The brightened mean will usually be higher. It cannot grow without limit, though, because clipping keeps every channel at or below `255`.

## 4. Average Two Images

To average two images, pair corresponding pixels. Red is averaged with red, green with green, and blue with blue. This only makes sense when the images have matching shapes.

### Question 11: Why must the image shapes match?

```python
print(first.shape)
print(second.shape)
```

**Answer.** Every position in the first image needs exactly one partner in the second:

```python
first[row, column, channel]
second[row, column, channel]
```

If one image has more rows, columns, or channels, some values have no corresponding partner. Check the requirement explicitly:

```python
if first.shape != second.shape:
    raise ValueError("The two images must have matching shapes.")
```

Resizing is a separate image-processing task. For this lesson, use matching images so that we can focus on the arithmetic.

### Question 12: How do we average two pixels?

```text
First:  [200,  50,  10]
Second: [100, 150, 250]
```

**Answer.** Average corresponding channels:

```text
Red:   (200 + 100) / 2 = 150
Green: ( 50 + 150) / 2 = 100
Blue:  ( 10 + 250) / 2 = 130
```

The averaged pixel is `[150, 100, 130]`. We never mix the channels with one another; red is paired only with red, and so on.

### Question 13 (P.R.E.): Is direct `uint8` addition safe?

Predict the result before running:

```python
a = np.array([200], dtype=np.uint8)
b = np.array([100], dtype=np.uint8)

print(a + b)
```

**Answer.** The output is:

```text
[44]
```

The mathematical sum is `300`, but `uint8` arithmetic wraps around:

```text
300 - 256 = 44
```

That means this natural-looking expression is unsafe:

```python
(first + second) / 2
```

The overflow occurs during the addition. Dividing afterward cannot repair the information that was already lost.

### Question 14: How can we average the images with loops?

**Answer.** A triple loop makes all three array dimensions explicit:

```python
average_loop = first.copy()

height, width, channels = first.shape

for row in range(height):
    for column in range(width):
        for channel in range(channels):
            first_value = int(first[row, column, channel])
            second_value = int(second[row, column, channel])

            mean_value = round(
                (first_value + second_value) / 2
            )

            average_loop[row, column, channel] = mean_value
```

Save it:

```python
Image.fromarray(average_loop).save(
    OUTPUT_FOLDER / "average_loop.png"
)
```

The `int()` conversions prevent `uint8` overflow during addition. The loop is verbose, but it is useful while you are learning what every dimension represents.

### Question 15: How can NumPy average the images safely?

**Answer.** Convert both arrays before adding them:

```python
first_working = first.astype(np.float32)
second_working = second.astype(np.float32)

average_values = (first_working + second_working) / 2
average_numpy = np.rint(average_values).astype(np.uint8)
```

Save and compare the result:

```python
Image.fromarray(average_numpy).save(
    OUTPUT_FOLDER / "average_numpy.png"
)

print(
    "Do the averaging methods agree?",
    np.array_equal(average_loop, average_numpy),
)
```

The comparison should return `True`.

We do not need clipping here. The average of two values that are both between `0` and `255` must also be between `0` and `255`.

## 5. Stack the Images and Choose an Axis

Data work often involves organizing several related datasets into one larger array. We can stack two images, then tell NumPy to average across the new image axis.

### Question 16: What shape does `np.stack()` create?

Suppose both images have shape `(825, 1100, 3)`. What shape will this produce?

```python
pair = np.stack([first, second], axis=0)
```

**Answer.** The new shape is:

```text
(2, 825, 1100, 3)
```

The dimensions now mean:

```text
axis 0 = image
axis 1 = row
axis 2 = column
axis 3 = color channel
```

Nothing has been averaged yet. `np.stack()` has only organized two arrays inside a new, larger array.

### Question 17: What does `axis=0` mean here?

What does this operation average, and what shape will it return?

```python
average_values = np.mean(pair, axis=0)
```

**Answer.** `axis=0` tells NumPy to average across the image axis. For each row, column, and channel, NumPy averages:

```python
pair[0, row, column, channel]
pair[1, row, column, channel]
```

The image axis disappears after it is averaged, so the result has shape `(825, 1100, 3)`.

Finish the conversion like this:

```python
average_stack = np.rint(average_values).astype(np.uint8)
```

When you work with an axis, try to name the dimension being removed. Saying “average the image axis” is more useful than memorizing the number `0` without its meaning.

### Question 18: Do these two NumPy methods agree?

```python
method_a = np.rint(
    (
        first.astype(np.float32)
        + second.astype(np.float32)
    ) / 2
).astype(np.uint8)

pair = np.stack([first, second], axis=0)

method_b = np.rint(
    np.mean(pair, axis=0)
).astype(np.uint8)
```

**Answer.** Yes. Both methods calculate the arithmetic mean of corresponding channels.

```python
print(np.array_equal(method_a, method_b))
```

The result should be `True`. The first method states the two-image formula directly. The stack-and-mean method extends more naturally when you have three or more images.

### Question 19: What do channel means tell us?

```python
channel_means = np.mean(first, axis=(0, 1))

print(channel_means)
print(channel_means.shape)
```

**Answer.** This operation averages across all rows (`axis 0`) and all columns (`axis 1`). It leaves the RGB channel dimension, so the result has shape `(3,)`:

```text
[mean red, mean green, mean blue]
```

This is a small but genuine data-analysis operation. A large image has been reduced to three summary statistics. Look at your photograph and compare it with the numbers. Does the channel with the largest mean seem visually dominant?

## 6. Does Transformation Order Matter?

### Question 20: Will averaging and brightening give the same result in either order?

Consider one channel from each of two images:

```text
First value:      240
Second value:     120
Brightness factor: 1.5
```

Compare these two procedures:

1. Average first, then brighten.
2. Brighten each value first, then average.

**Answer.** Start by averaging:

```text
(240 + 120) / 2 = 180
180 × 1.5 = 270
270 clipped to 255
```

So **average, then brighten** gives `255`.

Now reverse the order:

```text
240 × 1.5 = 360 → 255 after clipping
120 × 1.5 = 180
(255 + 180) / 2 = 217.5 → 218 after rounding
```

So **brighten, then average** gives `218`.

The answers differ because clipping loses information. Once `360` has become `255`, the later calculation cannot recover the original value. In mathematical language, these transformations do not always **commute**: reversing their order can change the result.

## What You Have Learned

The image work in this lesson introduced a useful collection of NumPy ideas:

- data types and type conversion;
- integer overflow;
- vectorized operations and broadcasting;
- Boolean masks and counting;
- clipping and rounding;
- shapes and array comparisons;
- stacking and axes; and
- reductions and summary statistics.

The pictures make the results visible, but the deeper lesson is about how NumPy represents and transforms data.

## Practice Lab: NumPy Image Data

The questions above included answers so that you could check your reasoning. This lab is where you try the same ideas independently. Give yourself about two or three hours, and use two RGB images with identical dimensions.

### Part 0: Plan Before Coding

Write an informal planning paragraph of five to eight sentences. Address these questions:

1. What functions will your program contain?
2. Which functions transform images?
3. Which code opens and saves files?
4. Where could `uint8` overflow occur?
5. What tiny arrays could verify your calculations?
6. What output images will your program create?

Your plan does not need to sound formal. Its purpose is to help you think before the program grows.

### Part 1: Conceptual Checks

Answer each question in complete sentences.

1. What range can a `uint8` value represent? What happens when an arithmetic result exceeds that range?
2. Why might we convert an image array to `np.float32` before multiplying or adding its values?
3. Henry says, “A vectorized operation means that NumPy performs a calculation only once instead of applying it to every value.” What is wrong with that statement?
4. What problem does `np.clip(values, 0, 255)` solve? What information can clipping destroy?
5. Two arrays both contain 900 values. Does that prove they have matching shapes? Explain.
6. If three images each have shape `(825, 1100, 3)`, what shape results from `np.stack([first, second, third], axis=0)`? Explain every dimension.
7. In that stacked array, what would `np.mean(images, axis=0)` average? What would `np.mean(images, axis=3)` average?
8. Henry says, “A full photograph makes the best first test because it checks millions of values.” Why can a one-pixel or two-pixel array be a better first test?

### Part 2: P.R.E. Investigations

For each investigation, predict the output without running the code, run it, and explain the result in your own words. Do not skip the prediction.

#### Investigation A: Overflow

```python
import numpy as np


values = np.array([100, 200, 250], dtype=np.uint8)

print("Original:", values)
print("uint8 result:", values * 2)
print(
    "float result:",
    values.astype(np.float32) * 2,
)
```

Explain why the two multiplication results differ.

#### Investigation B: Boolean Masks

```python
pixel = np.array(
    [[[100, 180, 240]]],
    dtype=np.uint8,
)

scaled = pixel.astype(np.float32) * 1.5
too_high = scaled > 255

print("Scaled:", scaled)
print("Mask:", too_high)
print(
    "Count:",
    np.count_nonzero(too_high),
)
```

Before running, predict:

1. the three scaled values;
2. the three Boolean values; and
3. the count.

Then explain the relationship between the shape of `scaled` and the shape of `too_high`.

#### Investigation C: Stacking and Axes

```python
first = np.array(
    [[[0, 60, 120], [30, 90, 150]]],
    dtype=np.uint8,
)

second = np.array(
    [[[100, 160, 220], [130, 190, 250]]],
    dtype=np.uint8,
)

pair = np.stack([first, second], axis=0)

print("First shape:", first.shape)
print("Pair shape:", pair.shape)
print("Mean over axis 0:", np.mean(pair, axis=0))
print(
    "Mean-over-axis-0 shape:",
    np.mean(pair, axis=0).shape,
)
print("Mean over axis 3:", np.mean(pair, axis=3))
print(
    "Mean-over-axis-3 shape:",
    np.mean(pair, axis=3).shape,
)
```

Predict all four shapes before running. Afterward, explain what information is removed when axis `0` is averaged and when axis `3` is averaged.

### Part 3: Find and Fix the Bugs

For each program, identify the bug, correct the code, explain why your correction works, and demonstrate it with a tiny array.

#### Bug 1: Overflow During Averaging

```python
def average_images(first, second):
    result = (first + second) / 2
    return np.rint(result).astype(np.uint8)
```

Use this test case:

```python
first = np.array([[[200, 200, 200]]], dtype=np.uint8)
second = np.array([[[100, 100, 100]]], dtype=np.uint8)
```

The correct result is:

```text
[[[150, 150, 150]]]
```

#### Bug 2: The Wrong Axis Disappears

```python
def average_images(first, second):
    pair = np.stack([first, second], axis=0)
    values = np.mean(pair, axis=2)
    return np.rint(values).astype(np.uint8)
```

The output must have the same shape as either input image. Which axis should be averaged, and why?

#### Bug 3: Same Size, Different Shape

```python
def average_images(first, second):
    if first.size != second.size:
        raise ValueError("Images do not match.")

    working_first = first.astype(np.float32)
    working_second = second.astype(np.float32)

    return np.rint(
        (working_first + working_second) / 2
    ).astype(np.uint8)
```

Why is comparing `.size` insufficient? Replace it with the correct shape check, then provide two arrays that have the same number of values but different shapes.

### Part 4: Implement the Core Functions

Create a file named `filters.py`.

#### Function 1: Brighten

```python
def brighten(pixels, factor):
    """Return a safely brightened copy of an RGB array."""
```

Your function must:

- reject a negative factor with `ValueError`;
- leave `pixels` unchanged;
- use vectorized NumPy operations;
- clip the result to `0` through `255`;
- preserve the input shape; and
- return an array with dtype `np.uint8`.

#### Function 2: Average Two Images

```python
def average_images(first, second):
    """Return the pixelwise mean of two RGB arrays."""
```

Your function must:

- raise `ValueError` if the shapes differ;
- avoid `uint8` overflow;
- leave both inputs unchanged;
- round the means;
- preserve the original shape; and
- return dtype `np.uint8`.

#### Function 3: Channel Means

```python
def channel_means(pixels):
    """Return the mean red, green, and blue values."""
```

Use one call to `np.mean()`, average across the row and column axes, return an array with shape `(3,)`, and do not use a loop.

### Part 5: Test the Functions

Create `test_filters.py`. Use tiny arrays whose correct results you can calculate by hand. At minimum, test:

1. ordinary brightening without clipping;
2. brightening that requires clipping;
3. a brightness factor of zero;
4. a negative brightness factor;
5. averaging without overflow;
6. averaging values whose sum exceeds `255`;
7. mismatched image shapes;
8. the output shape;
9. the output dtype;
10. non-mutation of the original arrays; and
11. all three channel means.

Useful assertions include:

```python
assert np.array_equal(actual, expected)
np.testing.assert_array_equal(actual, expected)
```

For floating-point statistics, use:

```python
assert np.allclose(actual, expected)
```

Explain why exact equality is suitable for finished `uint8` images while approximate equality is sometimes better for floating-point calculations.

Run the tests with:

```bash
python -m pytest -q
```

### Part 6: Modify the Averaging Rule

Ordinary averaging gives each image equal influence:

```text
result = 0.5 × first + 0.5 × second
```

Create this function:

```python
def weighted_blend(first, second, alpha):
    """Blend two images using alpha as the first image's weight."""
```

Use the rule:

```text
result = alpha × first + (1 - alpha) × second
```

Requirements:

- `alpha` must be between `0` and `1`, inclusive;
- invalid values must raise `ValueError`;
- the image shapes must match;
- intermediate arithmetic must not overflow;
- the result must be rounded and returned as `np.uint8`; and
- neither input may be changed.

Before coding, calculate this example by hand:

```text
First pixel:  [200, 100,   0]
Second pixel: [  0, 100, 200]
Alpha:        0.25
```

Write tests for alpha values `0`, `0.25`, `0.5`, and `1`. Explain which original image should be returned when alpha is `0` and when it is `1`.

### Part 7: Measure Clipping

Write:

```python
def clipping_percentage(pixels, factor):
    """Return the percentage of channel values that would exceed 255."""
```

The function should convert safely for arithmetic, calculate the scaled values, create a Boolean mask, count its `True` values, divide by the total number of channel values, and return a percentage from `0` through `100`. Do not use a loop.

Run it with these factors:

```text
1.00
1.25
1.50
2.00
```

Record your results:

| Factor | Percentage clipped |
| ---: | ---: |
| 1.00 | |
| 1.25 | |
| 1.50 | |
| 2.00 | |

Explain the trend in two or three sentences.

### Part 8: Design Your Own NumPy Transformation

Choose one additional transformation. You might keep one color channel, swap two channels, use a different multiplier for each channel, apply a threshold, or create a posterized image.

Before coding, fill in this plan:

```text
Transformation name:

Rule in words:

Example original pixel:

Expected transformed pixel:

NumPy operations that might be useful:
```

Your function must accept an RGB NumPy array, return a new RGB array, preserve the original shape, return dtype `np.uint8`, leave the input unchanged, and use a vectorized operation instead of row-and-column loops. Write at least two tiny-array tests. After running it on a photograph, explain whether the result matched your prediction.

### Part 9: Mini-Project

Use your two matching photographs to produce:

```text
output/
├── average.png
├── blend_25.png
├── blend_50.png
├── blend_75.png
├── brightened_average.png
└── custom_transformation.png
```

Complete this sequence:

1. Save an equal average.
2. Save weighted blends with alpha values `0.25`, `0.50`, and `0.75`.
3. Brighten the equal average.
4. Apply your custom transformation to one blend.
5. Calculate the RGB channel means for both originals and the equal average.
6. Calculate the clipping percentage before brightening the average.

Finish with a paragraph that answers these questions:

- Which original image dominates each weighted blend?
- How did the RGB channel means change?
- How much clipping occurred?
- What visual information was lost through clipping?
- Which NumPy operation now seems most useful to you?
- Which operation remains least clear?

### Engineering Power-Up: Add Type Hints

Add type hints to your public functions:

```python
def brighten(
    pixels: np.ndarray,
    factor: float,
) -> np.ndarray:
    ...
```

Type hints do not enforce these requirements at runtime. What help do they still provide to readers, editors, and static-analysis tools?

### Optional Hard Challenge: Blend Any Number of Images

Design:

```python
def blend_many(images, weights):
    """Return a weighted blend of any number of matching images."""
```

Requirements:

- `images` is a sequence of RGB arrays;
- all images have matching shapes;
- there is one weight per image;
- no weight is negative;
- the weights sum to `1`;
- the images are stacked along a new axis;
- the weights are reshaped or expanded so NumPy can broadcast them;
- a reduction is used along the image axis;
- there are no loops over individual pixels; and
- the result is a rounded `np.uint8` image.

Test your function with three one-pixel images and weights that you can calculate by hand.

### Submission Checklist

Before you finish, make sure you have:

- `filters.py`;
- `test_filters.py`;
- your main program;
- the six required output images;
- your P.R.E. predictions and explanations;
- three corrected debugging examples;
- your planning paragraph;
- your final reflection; and
- the optional challenge, if you attempted it.
