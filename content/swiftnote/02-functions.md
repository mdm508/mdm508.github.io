---
title: "Chapter 02 Functions"
date: 2025-11-03T03:46:31-08:00
draft: false
tags: ["swift"]
categories: ["Swift"]
summary: "Functions are first class citizens"
# github: "https://github.com/mdm508/02-functions"
weight: 2
reading: "Chapter 02-functions"
---

# Chapter 2 — Functions (Part 1)

---

## Function Parameters and Return Value

### Summary
- A function declares **inputs** (parameters) and an **output** (return type): `func name(_ a: Int, _ b: Int) -> Int { ... }`.
- Parameter names become **local variables** inside the function; they’re **scoped** to the function body.
- `return` both **produces** the value and **stops** execution; its value’s type must match the declared return type.
- A **call** uses the function name plus parentheses and arguments: `sum(4, 5)`. Argument variable names outside do **not** carry inside.
- You can **ignore** a result (compiler warns) or silence it with `_ = ...` or mark the function `@discardableResult`.
- Calls can be **nested**: `sum(4, sum(5, 6))`.

```swift
func sum(_ x: Int, _ y: Int) -> Int {
    let result = x + y
    return result
}

let z = sum(4, 5)                 // 9
let w = sum(4, sum(5, 6))         // 15
_ = sum(1, 2)                     // deliberately ignore result
```

### Free-Response (leave space to write)
1) In your own words, what are **parameters** and a **return type**? How do they act like a contract for the function?

2) What does `return` do besides give back a value? Why must its value’s type match the declared return type?

3) Why do `x` and `y` inside `sum` not refer to variables named `x` and `y` outside the function?

4) Show a legal call to `sum` and a call that **won’t** compile. Explain why the second fails.


### Programming Exercises
- **E1 (starter):** Write `func steepTime(_ grams: Int, _ tempC: Int) -> Int` that returns minutes. Rule of thumb: `return max(1, min(5, grams / 3 + (tempC >= 90 ? 1 : 0)))`. Call it with `(6, 95)` and `(3, 80)`.
- **E2 (from scratch):** Write `func addThree(_ a: Int, _ b: Int, _ c: Int) -> Int` and test `addThree(1, 2, 3)`. Then nest a call: `addThree(addThree(1,1,1), 2, 3)`.

---

## Void Return Type and Parameters

### Summary
- A function may return **nothing**: write `-> Void`, `-> ()`, **or omit** the return type entirely.
- A function may take **no parameters**: keep the empty parentheses in both declaration and call.
- A function can have **neither** parameters nor a return value.

```swift
func say1(_ s: String) -> Void { print(s) }
func say2(_ s: String) -> ()   { print(s) }
func say3(_ s: String)         { print(s) }

func greet() -> String { return "howdy" }
let g = greet()        // note the parentheses: greet()
```

### Free-Response
1) When would you choose a function that returns **Void** vs one that returns a value?


2) Why must you still write `()` when calling a parameterless function?


### Programming Exercises
- **E3 (starter):** `func logBrew(_ message: String)` prints `"☕️ " + message`. Call it three times.
- **E4 (from scratch):** `func ping()` prints `"ping"` and returns nothing. Call it twice.

---

## Function Signature

### Summary
- A function’s **type** is its **signature**: `(Int, Int) -> Int` describes “takes two `Int`, returns an `Int`”.
- Empty forms are `() -> Void` or `() -> ()`.
- Because functions have types, you can **store them in variables** and **pass them around**.

```swift
func sum(_ a: Int, _ b: Int) -> Int { a + b }
let f: (Int, Int) -> Int = sum
let result = f(2, 3)  // 5
```

### Free-Response
1) What is a **function signature**, and why is it useful?

### Programming Exercises
- **E5 (starter):** Declare `var combine: (Int, Int) -> Int = sum`. Reassign it to a new function `func mul(_ a:Int,_ b:Int)->Int { a*b }` and call `combine(3,4)` before/after reassignment.
- **E6 (from scratch):** Write `func minus(_ a:Int,_ b:Int)->Int` and store it in `let op: (Int,Int)->Int`. Call `op(10, 7)`.

---

## External Parameter Names

### Summary
- **By default**, parameter names are **external** and used as **labels** at the call site.
- Change the external name by **writing it before** the internal name; **suppress** it with `_`.
- Labels help readability but **do not** let you reorder arguments.

```swift
func echo(string s: String, times n: Int) -> String {
    var out = ""
    for _ in 1...n { out += s }
    return out
}

let a = echo(string: "hi", times: 3)   // labels required

func multiply(_ x: Int, _ y: Int) -> Int { x * y } // labels suppressed
let b = multiply(3, 4)
```

### Free-Response
1) What’s the difference between **external** and **internal** parameter names?


2) When might you **suppress** labels with `_`?


### Programming Exercises
- **E7 (starter):** Implement `func card(for work: String, by composer: String) -> String` so `card(for: "Goldberg Variations", by: "Bach")` returns `"Bach — Goldberg Variations"`.
- **E8 (from scratch):** Write `func brew(tea name: String, at tempC: Int)` that prints a sentence. Call it using labels.

---

## Overloading

### Summary
- You may define multiple functions with the **same name** if their **signatures differ** (parameter types/arity or return type with clear context).
- If two overloads differ **only by return type**, the **context must disambiguate** (type annotation or using the result where a specific type is expected).
- You can also disambiguate with **`as`** plus the function type.

```swift
func say(_ what: String) { print(what) }
func say(_ what: Int)    { print(what) }

func say() -> String { "one" }
func say() -> Int    { 1 }

let s: String = say()                 // picks String version
let i = (say as () -> Int)()          // calls Int version
```

### Free-Response
1) What is **overloading**?

2) Why is `let x = say()` ambiguous above? Show two ways to fix it?


### Programming Exercises
- **E9 (starter):** Overload `describe` so `describe(42)` returns `"number 42"` and `describe("Bach")` returns `"composer Bach"`. Print both.
- **E10 (from scratch):** Create two `score(of:)` overloads: one that takes a `String` (returns `"Theme: <name>"`), one that takes an `Int` (returns `"Movement \(n)"`). Call both.

---

## Default Parameter Values

### Summary
- Give a **default** with `=` in the declaration; callers may **omit** that argument.
- Defaults effectively create **multiple ways** to call the same function.

```swift
func brew(_ tea: String, at tempC: Int = 90) {
    print("Brewing \(tea) at \(tempC)°C")
}

brew("Oolong")          // uses 90
brew("Matcha", at: 75)  // override
```


### Programming Exercises
- **E11 (starter):** `func repeatPrint(_ text: String, times: Int = 1)` prints `text` a total of `times` times, on one line separated by spaces. Hint is to look at how the print function works. 

---

## Variadic Parameters

### Summary
- Mark a parameter **variadic** with `...` to accept **zero or more** values; inside, it’s an **array**.
- Other parameters may follow; the next one often needs an **external label** to show where the list ends.
- Swift 5.4+ allows **multiple variadics** (adjacent second needs a label).
- **No splat**: you **cannot** pass an existing array as a variadic list directly; write an overload that takes `[T]` instead.

```swift
func sum(_ nums: Int...) -> Int {
    nums.reduce(0, +)
}
let s1 = sum(1, 2, 3, 4)   // 10

print("Manny", "Moe", separator: ", ", terminator: ", ")
print("Jack")              // Manny, Moe, Jack

func playlist(_ works: String..., by composer: String) {
    print("\(composer): \(works.joined(separator: " | "))")
}
playlist("Prelude", "Fugue", by: "Bach")
```

### Free-Response
1) What does it mean that a parameter is **variadic**? How is it seen inside the function?


2) Why can’t you pass an array directly to a variadic parameter? What’s a practical workaround?


### Programming Exercises
- **E13 (starter):** Write `func multiply(_ values: Int...) -> Int` that returns the product (empty input returns `1`). Test with `multiply(2,3,4)` and `multiply()`.
- **E14 (from scratch):** Overload `sum` with `func sum(_ nums: [Int]) -> Int` so you can call `sum([1,2,3])`.

---

## Initializers Are Functions

### Summary
- Calling `Type(...)` invokes an **initializer** — a special function that constructs an instance.
- Initializers can have **parameters**, **labels**, **defaults**, and can be **overloaded**.
- Standard types (e.g., `String`) provide many initializers.

```swift
let s1 = String(42)                          // "42"
let s2 = String(repeating: "ho", count: 2)   // "hoho"

struct Tea {
    let name: String
    let tempC: Int
}
let eg = Tea(name: "Earl Grey", tempC: 95)
```

### Free-Response
1) What does `String(42)` do? Why is that an initializer call?


2) Give an example of an initializer with **labels** that improves clarity?


### Programming Exercises
- **E15 (starter):** Define `struct Sonata { let key: String; init(_ key: String) { self.key = key } }`. Create `Sonata("C minor")`.
- **E16 (from scratch):** Add a second initializer `init(repeating motif: String, count: Int)` to build a `String` motif inside `Sonata` (store it as `let motif: String?`). Create one with `("la", 3)` → `"lalala"`.


## Mini Project

Create the Dice Roller mini-project as a Markdown file and save it for download.


### Overview
Build a tiny library of functions to simulate common tabletop dice rolls (e.g., “roll 3d6 + 2”). You’ll practice **parameters and return values**, **external labels**, **default values**, **overloading**, **variadic parameters**, and **function signatures**. Keep it console-only and focused on functions—no UI.

### Learning goals 
- Parameters & return: `func rollDie(sides: Int) -> Int`
- External labels: `roll(count:sides:)`, `applyModifier(total:add:multiply:)`
- Defaults: `sides:` default to 6; `add:` default to 0; `multiply:` default to 1
- Overloading: `roll(_ notation: String)` vs `roll(count:sides:)`
- Variadic: `sum(_ values: Int...)`
- Function signatures: potentially store a function in a variable for later use

---

### Starter outline (paste into `main.swift`)
(Implement some; create others from scratch where noted.) See description of problems below

```swift
import Foundation

// 1) Basic single-die roll (starter)
func rollDie(sides: Int = 6) -> Int {
    // TODO: return an Int between 1 and sides (inclusive).
    // Guard against invalid sides (< 2): if invalid, return 1.
    return 1
}

// 2) Multiple dice (starter, uses external labels + default)
func roll(count n: Int, sides s: Int = 6) -> [Int] {
    // TODO: roll n dice of s sides each, return array of results.
    // Guard: if n < 1, return [].
    return []
}

// 3) Summation (from scratch, variadic)
// Signature: func sum(_ values: Int...) -> Int

// 4) Apply modifier (from scratch, defaults)
// Signature: func applyModifier(total: Int, add: Int = 0, multiply: Int = 1) -> Int

// 5) Overload roll to return a total directly (from scratch, overloading)
// Signature: func roll(_ notation: String) -> Int
// Minimal requirement: support "NdS+K" where N, S, K are positive Ints (K optional).
// Example: "3d6+2", "2d8", "1d20+0"
// If parsing fails, return 0.

// 6) Tiny demo (optional)
// print(rollDie())
// print(roll(count: 3, sides: 6))
// print(sum(1,2,3,4))
// let total = applyModifier(total: 12, add: 2)    // 14
// print(roll("3d6+2"))
```
---

### Tasks & requirements (with API hints)

### 1) `rollDie(sides:)`
- Return a random Int in `1...sides`.
- Default: `sides: 6`.
- Guard invalid input (`sides < 2` → return 1).

**API hint:** Use `Int.random(in: 1...sides)` and `guard sides >= 2 else { return 1 }`.

---

### 2) `roll(count:sides:)`
- Return an array of `count` rolls using `rollDie(sides:)`.
- Defaults: `sides` defaults to 6.
- External labels must be used at call sites.
- Guard: `count < 1` → return `[]`.

**API hint:** Use ranges and mapping, e.g. `(0..<n).map { _ in rollDie(sides: s) }`.

---

### 3) `sum(_:)` (variadic)
- Implement `sum(_ values: Int...) -> Int`.
- Empty input returns `0`.

**API hint:** `values.reduce(0, +)` is concise; or loop and accumulate into a `var total = 0`.

---

### 4) `applyModifier(total:add:multiply:)`
- Return `(total + add) * multiply`.
- Defaults: `add = 0`, `multiply = 1`.
- Use external labels for readability.

**API hint:** Just arithmetic and defaults; consider `max`, `min` if you want to clamp results (optional).

---

### 5) `roll(_ notation:)` (overloading)
- Overload base name `roll` with a different signature: it takes a `String`.
- Parse minimal dice notation: `NdS+K` (K optional).
  - Examples: `"3d6+2"`, `"2d8"`, `"1d20+0"`.
- Use `roll(count:sides:)` and `sum(_:)`, then pass the total to `applyModifier`.
- If parsing fails, return `0`.

**API hints:**
- Split the string:  
  `let parts = notation.split(separator: "d", maxSplits: 1)` → `N` and `"S+K"`  
  Then `S+K` can be split by `"+"`: `let tail = tailPart.split(separator: "+", maxSplits: 1)`  
  Convert pieces with `Int(String(...))`.
- Validate with `guard let` for each integer; on failure, `return 0`.

---

### 6) Tiny smoke test (manual)
Show at least three calls demonstrating labels, defaults, variadic, and overloading.

**API hint:** Print results with `print(...)` and use optional binding if needed.

---

### Acceptance checklist
- Uses **external parameter names** appropriately (e.g., `count:`, `sides:`, `add:`).
- Employs **default parameter values** (e.g., `sides: 6`, `add: 0`, `multiply: 1`).
- Demonstrates **overloading** with `roll(_ notation: String)`.
- Includes a **variadic** function `sum(_:)`.
- Input validation with clear fallbacks (no crashes on bad input).
- Small, readable functions with clear names.

---

### Hints & API cheat sheet
- Random number: `Int.random(in: 1...s)`
- Ranges: `0..<n`, `1...s`
- Collections: `.map`, `.reduce`, `.filter`, `.isEmpty`
- Parsing: `String.split(separator:)`, `Int(String)`
- Control flow: `guard`/`else`, `if`/`else`, `return 0` on failure
- String building (optional): `joined(separator:)` for printing rolls

---

### Stretch goals (optional)
- Add `"adv"` / `"dis"` suffix: `"2d20adv"` (roll twice, take higher) / `"2d20dis"` (take lower).
- Support `"NdSxR"` exploding dice: each max roll adds a reroll once.
- Add `printRolls: Bool = false` default param to display intermediate results.
- Add `best(count:sides:keep:)` to keep the highest K dice from N rolls.

---

### Reflection questions (beginner)
1) Where did you use **external parameter names** and why did they help readability?
2) Show one call that relies on a **default parameter**. What would the call look like without the default?
3) Explain how your **overloaded** `roll` functions differ by **signature**. Why can Swift tell them apart?
4) Why is `sum(_:)` a good candidate for a **variadic** parameter?
5) If you had to pass a function as a parameter later (e.g., a custom modifier), how would you write its **signature**?


## Modifiable Parameters

### Summary

- Inside a function, each parameter acts like a **local constant** (`let`): you can *use* it, but you can’t assign a new value to it.

  ```swift
  func say(_ s: String, times: Int, loudly: Bool) {
      // loudly = true   // ❌ error: cannot assign to parameter
  }
  ```

- If you want a **working copy** you can change, make a new local `var` and copy the parameter into it (you can even reuse the same name):

  ```swift
  func say(_ s: String, times: Int, loudly: Bool) {
      var loudly = loudly   // local shadow copy
      loudly = true         // ✅ ok, this is the local var
      // ...
  }
  ```

- Changing this local `var` **does not** change anything outside the function. It’s just a copy that lives inside the function body.

- If you want a function to **change the caller’s variable**, you must:
  - Mark the parameter as `inout` in the function declaration,
  - Pass a **`var`** from the caller,
  - Use `&` in front of the variable when you call the function.

  ```swift
  func removeCharacter(_ c: Character, from s: inout String) -> Int {
      var howMany = 0
      while let ix = s.firstIndex(of: c) {
          s.remove(at: ix)
          howMany += 1
      }
      return howMany
  }

  var word = "hello"
  let removed = removeCharacter("l", from: &word)
  // removed == 2, word == "heo"
  ```

- Using `inout` means the function is allowed to **modify the caller’s storage** as a side effect. Swift forces you to write `&` so you see the “danger” clearly.

---

### Free-Response Questions (leave space to write)

1) In your own words, why does Swift prevent you from assigning directly to a parameter inside a function?



2) What does it mean to “shadow” a parameter with a local `var`? How is the shadow different from the original parameter?



3) Look at this code:

```swift
func trimCopy(_ text: String) -> String {
    var text = text
    text = text.trimmingCharacters(in: .whitespaces)
    return text
}

let original = " hello "
let trimmed = trimCopy(original)
```

Explain why `original` keeps its spaces, even though `text` is changed inside the function.



4) Imagine you want a function that both **changes** a string by removing all `"a"` characters and **returns** how many `"a"` characters were removed. Why might `inout` be useful here, instead of only returning a new string?



5) When calling a function with an `inout` parameter, why does Swift require you to write `&myVar` instead of just `myVar`?



6) Describe one situation where using `inout` is a **good idea**, and one situation where it would be **unnecessary or confusing**.



---

### Drills (short, focused tasks)

- **D1 – Fix the compiler error (shadowing):**  
  The function below doesn’t compile. Rewrite it using a local `var` shadow so it compiles and behaves as intended.

  ```swift
  func markExcited(_ message: String, excited: Bool) {
      // goal: always make excited true inside this function
      // excited = true   // ❌ error
      // print(message, excited)
  }
  ```

- **D2 – Working copy vs original:**  
  Write a function `func trimmedCopy(_ text: String) -> String` that returns a version of `text` with leading and trailing spaces removed, without changing the caller’s variable. Then, in a comment, explain why the original string is unchanged.

- **D3 – In your own words:**  
  In 2–3 sentences, explain the difference between:
  - **Changing a parameter’s shadow copy** inside the function, and  
  - **Changing an `inout` parameter** that belongs to the caller.

---

### Programming Exercises

#### E1 — Shadowing a parameter (starter)

**Goal:** Practice creating a local `var` from a parameter.

Write a function:

```swift
func shout(_ message: String, times: Int, loudly: Bool) {
    // ...
}
```

Requirements:

- Inside the function, create a local `var loudly = loudly`.
- Set the local `loudly` to `true`.
- If `loudly` is `true`, print `message.uppercased()` `times` times.
- If `times` is less than 1, print nothing.

**Hint (API):**  
Use a `for _ in 1...times` loop and `message.uppercased()`.

---

#### E2 — Remove a character in place with `inout` (book-style, starter)

**Goal:** Use `inout` to change the caller’s `String` in place.

Implement:

```swift
func removeCharacter(_ c: Character, from s: inout String) -> Int {
    // ...
}
```

Requirements:

- Remove **all** occurrences of `c` from `s`.
- Return how many characters were removed.
- Test:

  ```swift
  var word = "hello"
  let removed = removeCharacter("l", from: &word)
  // Expect: removed == 2, word == "heo"
  ```

**Hints (API):**

- Use `s.firstIndex(of: c)` to find the next index.
- Use `s.remove(at: index)` to remove a character.
- A `while let` loop is helpful here.

---

#### E3 — Count and strip spaces with `inout` (multi-result)

**Goal:** Return one piece of information and also update the original string.

Write:

```swift
func countAndStripSpaces(from text: inout String) -> Int {
    // ...
}
```

Requirements:

- Remove **all spaces** (`" "`) from `text`.
- Return how many spaces were removed.
- Example:

  ```swift
  var title = "The  Well   Tempered   Clavier"
  let removedSpaces = countAndStripSpaces(from: &title)
  // Example result: removedSpaces == 6, title == "TheWellTemperedClavier"
  ```

**Hints (API):**

- One approach: loop while `text.contains(" ")` and use `firstIndex(of:)` + `remove(at:)`.
- Another approach: build a new string with `filter { $0 != " " }`, then compare lengths.
  You can still use `inout` by assigning back to `text`.

---

#### E4 — Clamp a score with `inout` (safely modify numbers)

**Goal:** Use `inout` on a simple numeric value.

Write:

```swift
func clampScore(_ score: inout Int, min: Int = 0, max: Int = 100) {
    // ...
}
```

Requirements:

- If `score` is less than `min`, set it to `min`.
- If `score` is greater than `max`, set it to `max`.
- Otherwise, leave it unchanged.
- Test:

  ```swift
  var exam = -5
  clampScore(&exam)        // exam should become 0

  var bonus = 150
  clampScore(&bonus)       // bonus should become 100

  var midterm = 88
  clampScore(&midterm)     // stays 88
  ```

**Hints (API):**

- Use simple `if`/`else if` checks.
- You can also use `score = max(min, min(score, max))` if that feels comfortable.

---

#### E5 — Decompose seconds into minutes and seconds (multiple `inout` parameters)

**Goal:** Imitate a “multiple outputs” function using `inout`.

Write:

```swift
func decompose(timeInSeconds: Int, minutes: inout Int, seconds: inout Int) {
    // ...
}
```

Requirements:

- Compute how many full minutes and leftover seconds are in `timeInSeconds`.
- Store the results in `minutes` and `seconds`.
- Example:

  ```swift
  var mins = 0
  var secs = 0
  decompose(timeInSeconds: 125, minutes: &mins, seconds: &secs)
  // mins == 2, secs == 5
  ```

**Hints (API):**

- Use integer division `/` to get minutes: `timeInSeconds / 60`.
- Use remainder `%` to get leftover seconds: `timeInSeconds % 60`.

---

#### E6 — Dog rename vs reset (reference type vs `inout`)

**Goal:** See the difference between mutating a property and replacing an object.

Start with:

```swift
class Dog {
    var name: String = ""
}
```

Tasks:

1. Write a function:

   ```swift
   func rename(_ dog: Dog, to newName: String) {
       // ...
   }
   ```

   - This should set `dog.name` to `newName` without using `inout`.
   - Test:

     ```swift
     let d = Dog()
     d.name = "Fido"
     rename(d, to: "Rover")
     // d.name should now be "Rover"
     ```

2. Write a second function:

   ```swift
   func resetDog(_ dog: inout Dog) {
       // ...
   }
   ```

   - This should **replace** the existing `Dog` with a new one named `"Default"`.
   - Test:

     ```swift
     var myDog = Dog()
     myDog.name = "Chopin"
     resetDog(&myDog)
     // myDog.name should now be "Default"
     ```

**Concept reflection:**

- In a short comment, explain why `rename(_:,to:)` didn’t need `inout`, but `resetDog(_:)` did.

