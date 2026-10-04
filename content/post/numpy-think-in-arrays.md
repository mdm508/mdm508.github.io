---
title: "NumPy: Think in Arrays"
date: 2026-10-04T09:00:00-07:00
draft: false
description: "Learn NumPy arrays, shape, indexing, vectorized operations, Boolean masks, axes, and simulation through concise examples and practice."
tags: ["python", "numpy", "programming", "data-science"]
summary: "Organize data in arrays, transform many values at once, and use masks and axes to answer questions about the data."
reading_time: 35
---

NumPy lets us organize many values into an array and apply the same operation to all of them at once. That raises a practical question:

> How can one clear expression transform or analyze a whole collection of data—and how do we keep track of what each result means?

We will build the answer by making arrays, reading their shapes, selecting values, and using a small simulation.

## An Array Is a Structured Collection

Import NumPy with its usual abbreviation:

```python
import numpy as np
```

A one-dimensional array is a sequence. A two-dimensional array is a grid. Its `shape` tells us the size along each dimension.

```python
values = np.arange(12)
grid = values.reshape(3, 4)

print(grid)
print(grid.shape)
```

```text
[[ 0  1  2  3]
 [ 4  5  6  7]
 [ 8  9 10 11]]

(3, 4)
```

This grid has 3 rows and 4 columns. NumPy counts from zero when we access values, as Python lists do.

### Q1: What shape will this array have?

**Problem:** Create a grid with 2 rows and 3 columns, filled with zeroes. What will its shape be?

{{< hints >}}
- `np.zeros` creates an array of zeroes.
- Give the shape as a tuple: rows first, columns second.
{{< /hints >}}

{{< answer >}}
```python
grid = np.zeros((2, 3))
grid.shape
```

The shape is `(2, 3)`. NumPy's default values are floating-point zeroes; use `dtype=int` for integer zeroes:

```python
np.zeros((2, 3), dtype=int)
```
{{< /answer >}}

## Select Values by Position

For a two-dimensional array, write the row first and the column second:

```python
grid[row, column]
```

A colon means “take everything” along that dimension:

```python
grid[1, 2]   # row 1, column 2
grid[1, :]   # all columns in row 1
grid[:, 2]   # all rows in column 2
```

With the grid above, `grid[1, 2]` is `6`. The second row is `[4, 5, 6, 7]`; the third column is `[3, 7, 11]`.

Slices include the starting index and stop before the ending index. So `grid[:2, 1:3]` selects the first two rows and columns 1 and 2.

### Q2: Which values does that slice select?

**Problem:** What does `grid[:2, 1:3]` return for the 3 × 4 grid above?

{{< hints >}}
- `:2` selects rows 0 and 1.
- `1:3` selects columns 1 and 2.
{{< /hints >}}

{{< answer >}}
```text
[[1 2]
 [5 6]]
```

The result has shape `(2, 2)`: two selected rows and two selected columns.
{{< /answer >}}

## Apply One Operation to Many Values

NumPy arithmetic works entry by entry:

```python
values = np.array([2, 4, 6])
values * 3
```

The result is `[6, 12, 18]`. NumPy applies the multiplication to each value. This is often called **vectorized** code: we describe the operation once instead of writing a loop for every entry.

A single number also applies to every entry in a grid:

```python
grid + 10
```

NumPy expands that scalar across the grid as needed. This is a simple example of **broadcasting**. Smaller arrays can also combine with larger ones when their shapes line up. For example, adding a length-3 array to a grid with three columns adds one value to each column:

```python
grid + np.array([100, 200, 300])
```

### Q3: What does broadcasting add here?

**Problem:** Given this grid, what is the result of `grid + np.array([10, 20, 30])`?

```python
grid = np.array([
    [1, 2, 3],
    [4, 5, 6],
])
```

{{< hints >}}
- The smaller array has one value for each column.
- Apply those three additions to each row.
{{< /hints >}}

{{< answer >}}
```text
[[11 22 33]
 [14 25 36]]
```

NumPy reuses the length-3 array across both rows. Their shapes are compatible because the last dimension of each is 3.
{{< /answer >}}

## Comparisons Make Boolean Arrays

A comparison such as `values > 5` checks each entry and returns `True` or `False`:

```python
values = np.array([2, 5, 8, 11])
values > 5
```

```text
[False False  True  True]
```

We can use that Boolean array as a filter:

```python
values[values > 5]
```

```text
[ 8 11]
```

To combine conditions, use `&` for “and” or `|` for “or.” Put each comparison in parentheses:

```python
(values > 3) & (values < 10)
```

NumPy uses `&` rather than Python's `and` because it checks each position in the arrays.

### Q4: Which values are strictly between 3 and 10?

**Problem:** Select values strictly between 3 and 10 from `[1, 4, 8, 12]`.

{{< hints >}}
- “Strictly between” means greater than 3 and less than 10.
- Use `&` between the comparisons, with parentheses around each one.
{{< /hints >}}

{{< answer >}}
```python
values = np.array([1, 4, 8, 12])
values[(values > 3) & (values < 10)]
```

The result is `[4, 8]`.
{{< /answer >}}

## Understand Axes Before Reducing

### What is an axis?

An **axis** is one of an array's dimensions. A one-dimensional array has one axis. A two-dimensional grid has two: rows and columns. NumPy numbers dimensions from zero in the order they appear in the shape.

This grid has shape `(2, 3)`: 2 rows, then 3 columns. That makes rows `axis=0` and columns `axis=1`:

```text
                  axis 1: columns →
axis 0: rows ↓     [ 2  5  1 ]
                   [ 7  3  4 ]
```

An axis number is not a row or column index. `axis=0` does not mean “choose row 0”; it names the entire row dimension. Likewise, `axis=1` names the column dimension.

### What does it mean to reduce along an axis?

A **reduction** combines several values into fewer values. `sum`, `mean`, and `max` are reductions. When we reduce along an axis, NumPy combines values in that direction and removes that dimension from the result. The other dimension remains.

For the same 2 × 3 grid, reducing with `axis=0` combines values down the rows, leaving one result for each column:

```python
scores = np.array([
    [2, 5, 1],
    [7, 3, 4],
])
```

```text
[2  5  1]       [7  5  4]
  ↓  ↓  ↓
[7  3  4]
```

So `scores.max(axis=0)` returns `[7, 5, 4]`, with shape `(3,)`: the row dimension was reduced, and the three columns remain.

Reducing along `axis=1` combines values across each row, leaving one result for each row:

```text
[2  5  1] → 5
[7  3  4] → 7
```

So `scores.max(axis=1)` returns `[5, 7]`, with shape `(2,)`: the column dimension was reduced, and the two rows remain. Without an axis argument, `scores.max()` reduces the whole grid to one value: `7`.

In short: reducing `axis=0` leaves columns; reducing `axis=1` leaves rows. The axis you reduce is the dimension that disappears from the result.

Use this small grid to watch each reduction direction. The highlighted bands show the values being reduced together.

{{< axis-explorer >}}

### Q5: Which axis gives one maximum per column?

**Problem:** For the `scores` grid above, choose the `axis` value that returns one maximum per column. What are those values?

{{< hints >}}
- Each column contains two values.
- Reducing down the rows leaves one result for each column.
{{< /hints >}}

{{< answer >}}
Use `axis=0`:

```python
scores.max(axis=0)
```

The result is `[7, 5, 4]`, the maximum of each column.
{{< /answer >}}

## Put the Ideas Together with a Simulation

Suppose we roll four six-sided dice many times. Each row can represent one experiment, and each column one die:

```python
rng = np.random.default_rng(7)
rolls = rng.integers(1, 7, size=(100_000, 4))
```

The upper bound in `rng.integers` is excluded, so these rolls range from 1 through 6. The shape `(100_000, 4)` means 100,000 experiments with four dice in each.

Now find the maximum roll in each experiment and check whether it is exactly 5:

```python
largest = rolls.max(axis=1)
success = largest == 5
```

`success` is a Boolean array with one value per experiment. Since `True` counts as 1 and `False` as 0, its mean is the fraction of experiments that succeeded:

```python
estimated_probability = success.mean()
```

The exact probability is about `0.285`. The simulation should get close, though its precise result can vary. This example uses array creation, shape, a reduction along an axis, comparison, and a Boolean average.

### Q6: Why does `success.mean()` estimate a probability?

**Problem:** Explain why the mean of a Boolean array gives the fraction of successful experiments.

{{< hints >}}
- Treat `True` as 1 and `False` as 0.
- What does the average of zeroes and ones measure?
{{< /hints >}}

{{< answer >}}
The mean is the sum divided by the number of experiments. Each success contributes 1; each failure contributes 0. So the mean is `number of successes / number of experiments`—the estimated probability of success.
{{< /answer >}}

## Homework

Try each problem before opening its hints. The problems build from reading shapes to combining filters, broadcasting, and simulation.

### 1. Make a sequence

**Problem:** What values does `np.arange(3, 8)` produce?

{{< hints >}}The stop value is excluded.{{< /hints >}}

{{< answer >}}`[3, 4, 5, 6, 7]`{{< /answer >}}

### 2. Read a shape

**Problem:** What is the shape of `np.zeros((4, 2))`?

{{< hints >}}The tuple is `(rows, columns)`.{{< /hints >}}

{{< answer >}}`(4, 2)`{{< /answer >}}

### 3. Index a grid

**Problem:** What value is selected by `a[2, 1]`?

```python
a = np.arange(12).reshape(3, 4)
```

{{< hints >}}
- Indices start at zero.
- Select row 2, then column 1.
{{< /hints >}}

{{< answer >}}`9`{{< /answer >}}

### 4. Select a column

**Problem:** What does `a[:, 2]` return for the same array?

{{< hints >}}
- The colon means every row.
- The column index is 2.
{{< /hints >}}

{{< answer >}}`[2, 6, 10]`{{< /answer >}}

### 5. Transform every entry

**Problem:** What is `a * 2 - 1`?

```python
a = np.arange(12).reshape(3, 4)
```

{{< hints >}}
- Multiply every entry by 2.
- Then subtract 1 from each result.
{{< /hints >}}

{{< answer >}}
```text
[[-1  1  3  5]
 [ 7  9 11 13]
 [15 17 19 21]]
```
{{< /answer >}}

### 6. Filter with one condition

**Problem:** Select the values greater than 6.

```python
values = np.array([2, 6, 9, 12])
```

{{< hints >}}Build a comparison mask and use it inside the array's brackets.{{< /hints >}}

{{< answer >}}
```python
values[values > 6]
```

The result is `[9, 12]`.
{{< /answer >}}

### 7. Combine conditions

**Problem:** Select values greater than 2 and less than 10 from `[1, 4, 8, 12]`.

{{< hints >}}
- Make two comparisons.
- Combine them with `&`, with parentheses around each comparison.
{{< /hints >}}

{{< answer >}}
```python
values = np.array([1, 4, 8, 12])
values[(values > 2) & (values < 10)]
```

The result is `[4, 8]`.
{{< /answer >}}

### 8. Broadcast across columns

**Problem:** What is `a + [10, 20, 30, 40]`?

```python
a = np.arange(8).reshape(2, 4)
```

{{< hints >}}
- The list has one value per column.
- Add it to both rows.
{{< /hints >}}

{{< answer >}}
```text
[[10 21 32 43]
 [14 25 36 47]]
```
{{< /answer >}}

### 9. Reduce along an axis

**Problem:** Find the maximum of each row and the maximum of each column.

```python
a = np.array([
    [3, 8, 2],
    [5, 1, 9],
])
```

{{< hints >}}
- `axis=1` gives one result per row.
- `axis=0` gives one result per column.
{{< /hints >}}

{{< answer >}}
```python
a.max(axis=1)  # [8, 9]
a.max(axis=0)  # [5, 8, 9]
```
{{< /answer >}}

### 10. Estimate a probability

**Problem:** Simulate 20,000 experiments, each rolling four six-sided dice. Estimate the probability that at least one die shows a 6.

{{< hints >}}
- Make an array with shape `(20_000, 4)`.
- Use `rolls == 6` to test each die.
- Use `.any(axis=1)` to check each experiment, then take the mean.
{{< /hints >}}

{{< answer >}}
```python
rng = np.random.default_rng(7)
rolls = rng.integers(1, 7, size=(20_000, 4))

has_six = (rolls == 6).any(axis=1)
estimate = has_six.mean()
```

The exact probability is `1 - (5/6)**4`, about `0.518`. The simulation should land nearby.
{{< /answer >}}

For the next step, apply these ideas to real pictures: [Brightening and Averaging Images with NumPy →](/post/brightening-and-averaging-images-with-numpy/)

For more examples beyond this introduction, see the [UC Irvine Math 9 NumPy notes](https://christopherdavisuci.github.io/UCI-Math-9-F22/Week2/NumPy.html).

## Glossary

| Term | Definition | Example |
| --- | --- | --- |
| Array | An ordered collection of values arranged in one or more dimensions. | `np.array([2, 4, 6])` |
| Shape | The size of an array along each dimension. | `(2, 3)` means 2 rows and 3 columns. |
| Index | A zero-based position used to access an array value. | `grid[1, 2]` selects row 1, column 2. |
| Slice | A selection of positions; the start is included and the stop is excluded. | `grid[:2, 1:3]` selects two rows and columns 1–2. |
| Vectorized operation | An operation NumPy applies element by element across an array. | `values * 3` multiplies every value by 3. |
| Broadcasting | NumPy's rule for applying a smaller value or array across a compatible larger shape. | `grid + np.array([10, 20, 30])` adds by column. |
| Boolean mask | An array of `True`/`False` values used to select entries. | `values[values > 5]` keeps values over 5. |
| Axis | A numbered dimension of an array; in a 2-D grid, axis 0 is rows and axis 1 is columns. | `grid.shape == (2, 3)` has axes 0 and 1. |
| Reduction | An operation that combines values, often along an axis. | `scores.max(axis=1)` finds one maximum per row. |
| Random generator | An object that produces pseudo-random values; a seed makes a sequence repeatable. | `rng = np.random.default_rng(7)` |
| Simulation | A model run repeatedly to estimate an outcome. | `success.mean()` estimates the success rate. |
