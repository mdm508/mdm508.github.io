---
title: "Chapter 01 Ground of Being in Swift"
date: 2025-01-08T00:00:00-00:00
draft: false
tags: ["swift"]
categories: ["Swift"]
summary: "A comprehensive tour of Swift fundamentals covering statements, operators as functions, custom types (struct/class/enum), variables vs constants, scope and lifetime, namespaces, and access control with practical examples."
weight: 1
reading: "Chapter 1"
---

# Chapter 1 

## How do I run my code?
Since we are doing pure swift right now I reccomend creating a **command line app** instead of an iOS app. 

1) Open **Xcode** → **File** → **New** → **Project…**  
2) Choose **macOS** → **Command Line Tool** → **Next**.  
3) Set **Product Name**: `HelloWorldCLI` · **Language**: **Swift** → **Next** → **Create**.  
4) Xcode creates **`main.swift`** with `print("Hello, World!")` already inside.  
5) Press **⌘R** (Run). You'll see **Hello, World!** in Xcode's console at the bottom.

### What's Xcode doing for you?
It's okay to skip or come back to this section. Read this if you want to know a bit more about the magic behind running
your code. 

When you press **⌘R**, Xcode performs several steps automatically:

1. **Compilation**: The Swift compiler (`swiftc`) reads your `.swift` files and translates them into machine code that your computer's processor can understand.

   **Machine code** is the lowest-level programming language—just numbers (represented as 1s and 0s) that directly tell the processor what to do. For example, your Swift code `let x = 5` might become something like this in machine code:
   ```
   48 c7 c0 05 00 00 00    mov    $0x5,%rax
   48 89 45 f8             mov    %rax,-0x8(%rbp)
   ```
   Those cryptic numbers and letters are instructions like "move the value 5 into a storage location." Fortunately, you never have to write or read machine code—that's what Swift is for!

2. **Linking**: The compiler combines your code with Swift's standard library (which provides things like `print()`, `String`, `Int`, etc.) to create a complete executable program.

   Think of it this way: When you write `print("Hello")`, you're calling a function that you didn't write yourself—it's part of Swift's standard library. Your compiled code might say "call the print function," but it doesn't contain the actual code that makes printing work. The linker finds that `print()` function in Swift's pre-compiled library and connects (or "links") it to your program, so when your program runs, it knows where to find `print()`.

3. **Execution**: Xcode runs the resulting executable and captures its output to display in the console.

 You write instructions in Swift (human-readable), the compiler translates them into machine language (computer-readable), and then your computer follows those instructions. It's similar to how you might write a recipe in English, translate it to another language, and then someone who speaks that language can follow it.


### Want to try compiling Swift yourself?
You don't need Xcode! Here's how to compile and run Swift code manually:

1. **Create a text file**: Open **TextEdit** → **Format** → **Make Plain Text** (⇧⌘T)
2. **Write some Swift code**:
   ```swift
   print("Hello from the command line!")
   let name = "Swift"
   print("I'm learning \(name)")
   ```
3. **Save it**: Save as `hello.swift` on your **Desktop** (make sure it ends with `.swift`)
4. **Open Terminal**: Press **⌘Space**, type "Terminal", press **Enter**
5. **Navigate to Desktop**: Type `cd Desktop` and press **Enter**
6. **Compile and run**: Type `swift hello.swift` and press **Enter**

You should see your output! The `swift` command both compiles and runs your code in one step. Pretty cool that you can write Swift code in any text editor and run it from the command line!

**Why am I showing you this?** I want you to know that Swift isn't just for creating iPhone and Mac apps! You can use Swift for many other things:

- **Command-line tools** (like file organizers, text processors, or calculators)
- **Web servers** (using frameworks like Vapor to build websites)
- **Data analysis scripts** (processing CSV files, analyzing data)
- **Automation scripts** (automating repetitive tasks on your computer)
- **System administration** (managing files, networks, or servers)
- **Cross-platform apps** (desktop apps that run on Windows, Linux, and Mac)

Swift is a general-purpose programming language, not just an "app language"!

# 7 Key Concepts

## 1. Statements & Newlines
Swift is written as a series of **statements**. A newline usually ends a statement; semicolons are optional and mainly for multiple statements on one line. Prefer one idea per line for clarity.

```swift
let teaCups = 2
print("Brewing \(teaCups) cups of oolong")

let a = 1; let b = 2; print(a + b) // valid, but harder to read
```

---

## 2. Operators Are Functions; Method Chains Read Top-to-Bottom

Operators like `+` are real functions, so `(+)(3, 4)` equals `3 + 4`. Long transformations read well when you break **before** the dot.

```swift
let sum = (+)(3, 4) // same as 3 + 4

let title = "fugue"
    .uppercased()
    .replacingOccurrences(of: "F", with: "🎼F")
print(title) // 🎼FUGUE
```

---

## 3. Three Custom Type Shapes: `struct`, `class`, `enum`

Use a `struct` for simple value data, a `class` when you need shared identity (reference semantics), and an `enum` for clear, finite choices.

```swift
struct Tea { var name: String; var tempC: Int }          // copies on assign
final class MusicPlayer { var isPlaying = false }        // shared reference
enum PokemonType { case fire, water, grass }             // finite cases
```

---

## 4. `let` vs `var` and First Functions

`let` makes a constant; `var` makes a variable. Functions can use external/internal parameter names so calls read like English.

```swift
let composer = "Bach"
var movement = 1

func move(from start: Int, to end: Int) -> String {
    "Moved from \(start) to \(end)"
}
print(move(from: 1, to: 3))
```

---

## 5. Top-Level Code, Scope, and Lifetime

You can write simple top-level code in playgrounds and scripts. **Scope** = where a name is visible. **Lifetime** = how long it exists.

```swift
func favoriteBook() {
    let title = "Pride and Prejudice" // scope: only inside function
    print(title)
}
// print(title) // error: not visible here
```

---

## 6. Namespaces, Modules, Instances, and `self`

Types are **namespaces** for their members. Modules (what you `import`) are larger namespaces. Access members on an **instance** with `.`, and use `self` when needed (e.g., to disambiguate).

```swift
struct Sonata {
    var key = "C minor"
    func label() -> String { "Sonata in \(key)" }
}

let pathetique = Sonata()
print(pathetique.label()) // "Sonata in C minor"
```

---

## 7. Access Control: `private`, `fileprivate`, `internal`, `public`, `open`

Hide details to keep APIs clean. Default is `internal`. Use `private` for helpers inside a type; `public`/`open` only for APIs meant for other modules.

```swift
public struct Library {
    public private(set) var books: [String] = []
    func add(_ title: String) { books.append(title) } // internal by default
}
```

# Key Terms

<div class="swiftnote-table">

| Term | Definition |
|------|------------|
| **Statement** | A single instruction in Swift code, usually ending with a newline |
| **Operator** | A symbol like `+`, `-`, `*` that performs operations; operators are actually functions |
| **Struct** | A custom type that creates value semantics (copies when assigned) |
| **Class** | A custom type that creates reference semantics (shared identity) |
| **Enum** | A custom type that represents a finite set of cases |
| **Constant** | A value declared with `let` that cannot be changed |
| **Variable** | A value declared with `var` that can be modified |
| **Scope** | The area of code where a name is visible and can be used |
| **Lifetime** | How long a value exists in memory |
| **Namespace** | A container that groups related names together |
| **Module** | A collection of Swift code that can be imported |
| **Instance** | A specific occurrence of a type with its own state |
| **Method** | A function that belongs to a type |
| **Parameter** | Input to a function; can have external and internal names |
| **Access Control** | Keywords that control visibility of code (`private`, `public`, etc.) |
| **Internal** | Default access level; visible within the same module |
| **Public** | Access level that makes code visible to other modules |
| **Private** | Access level that hides code within the same type |

</div>

---

# Free-Response Questions

1. Look through the key terms section and select three terms to define in your own words.

2. What are reserved words? List a few examples.

3. What's the difference between `let` and `var`? Create one useful constant and one useful variable.

4. What is *scope*? Why can't a local variable be used outside its function?

5. What is an **instance**? Make one instance of a simple type (like `Tea` or `Sonata`) and say what it represents.

6. Instances have state. What is state? Give an example of some real world object and explain how you might model its state.

7. Explain what Nuenberg meant by "an instance is both code and data".

8. What is the purpose of `self`?


---

# Drills 

1. Put two statements on one line with semicolons, then split them onto separate lines.

2. Call an operator as a function: `(+)(10, 20)`; compare with `10 + 20`.

3. Define a `struct` `Tea { var name: String; var tempC: Int }`; make two teas and print them.

4. Write `func label(song: String, composer: String) -> String` that returns `"composer — song"`. Call it.

5. Inside a function, declare `let pages = 300`; try using it outside the function (show the compiler error in a comment).

6. Create `enum PokemonType { case fire, water, grass }` and a `switch` that returns a one-sentence description for each.

7. Make a `public struct Library` with `public private(set) var books = [String]()` and an `add(_:)` method; show that callers can read `books` but not modify it directly.

---

# Programming Exercises 

## 1. Tea Temperature Tracker 

Practice `struct`, `let`/`var`, and methods.

```swift
struct Tea {
    var name: String
    var tempC: Int

    func cool(by degrees: Int) -> Tea {
        return Tea(name: name, tempC: max(0, tempC - degrees))
    }

    func label() -> String { "\(name) — \(tempC)°C" }
}

// TODO:
// 1) Make two teas ("Oolong" at 90, "Matcha" at 75).
// 2) Cool one by 10 degrees; print both labels.
// 3) Notice how `cool(by:)` returns a new Tea instead of modifying the original.
```

---

## 2. Pokémon Type Announcer (from scratch)

Use an `enum` + exhaustive `switch`.

**Requirements**

* Define `enum PokemonType { case fire, water, grass }`
* Write `func announce(_ t: PokemonType) -> String`
* Return: `"🔥 Fire beats Grass"`, `"💧 Water beats Fire"`, `"🌿 Grass beats Water"`

**Test**

```swift
print(announce(.fire))
print(announce(.water))
print(announce(.grass))
```

---

## 3. Composer Card 

Practice external/internal parameter names and string interpolation.

```swift
// Implement so the call reads like English.
func card(for work: String, by composer: String) -> String {
    // TODO: return "composer — work"
    return ""
}

// Expected: "Bach — Goldberg Variations"
print(card(for: "Goldberg Variations", by: "Bach"))
```

1. Add one more call with a favorite piece.
2. Go listen to some [Bach](https://www.youtube.com/watch?v=KYouXtuk0T8&start_radio=1)

---

## 4. Little Library (from scratch)

Access control + type as namespace.

* Create `public struct Library` with `public private(set) var books: [String] = []`
* Add `func add(_ title: String)`
* Add `private func normalize(_ title: String) -> String` that trims spaces
* Show that `normalize` isn't visible outside `Library`
* Demonstrate that external code can read `books` but must call `add(_:)` to modify it

---

## 5. Operator-as-Function Mini-Lab (starter provided)

See how operators are ordinary functions.

```swift
let a = 7, b = 5
let sum1 = a + b
let sum2 = (+)(a, b)
print(sum1 == sum2) // expect true

// TODO:
// 1) Compare `a * b` with `(*)(a, b)`.
// 2) In a comment, explain how knowing this helps you read fluent chains and unfamiliar code.
```

---
