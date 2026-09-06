---
title: "From Swift Objects to SwiftUI"
date: 2026-09-06T09:00:00-07:00
draft: false
description: "Use familiar Swift types, properties, initializers, closures, and state to build an interactive SwiftUI view."
tags: ["swift", "swiftui", "object-types", "programming-fundamentals"]
summary: "Turn the object-type ideas from the previous Swift lesson into a small interface with composed views, buttons, modifiers, and local state."
reading_time: 90
---

This lesson continues [Object Types: Building Things with State and Behavior](/post/swift-object-types/). There, a `Pet` struct stored information and performed work. Now we will use the same Swift ideas to describe an interface.

> How do familiar Swift types become an interface that changes when the user acts?

SwiftUI adds new tools, but it does not replace Swift. Views are values created from types. They have properties, use initializers, call methods, and receive closures. The new part is how those pieces describe what should appear on screen.

## Views Are Swift Values

### Q1: What is familiar about `Text("Hello")`?

Compare these expressions:

```swift
Text("Hello")
Pet(name: "Cookie", energy: 5)
```

Which names identify types? What do the complete expressions produce, and what familiar Swift feature do the parentheses suggest?

{{< answer >}}
`Text` and `Pet` are type names. Each complete expression calls an initializer and produces a value of that type:

```text
Pet(...)  → a Pet value
Text(...) → a Text value
```

The string `"Hello"` supplies the information needed to initialize the `Text`. SwiftUI is already using the same relationship between types, initializers, and values that we used to create pets.
{{< /answer >}}

### Q2: What does a custom view declaration promise?

Read this code line by line:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}
```

Identify the familiar struct declaration and the property. Then decide what `: View` and `some View` must mean well enough for now.

{{< answer >}}
`ContentView` is a struct, and `body` is a computed property. It is a property rather than a method because its name is not followed by parentheses.

```swift
struct ContentView: View
```

The colon says that `ContentView` conforms to the SwiftUI `View` protocol. In plain language, the type promises to meet SwiftUI's requirements for a view.

```swift
var body: some View
```

The `body` property produces one specific kind of value that conforms to `View`. The keyword `some` lets the implementation keep that exact type out of the declaration. At this stage, the useful reading is: **the body produces a view**.
{{< /answer >}}

### Q3: How is `ContentView` like `Pet`?

Compare:

```swift
struct Pet {
    var name: String
}
```

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}
```

What do these types share, and what different job does each perform?

{{< answer >}}
Both are structs with properties. `Pet` has a stored property named `name`; `ContentView` has a computed property named `body`.

Their purposes differ:

```text
Pet          models a thing
ContentView  describes an interface
```

A SwiftUI view is not a separate species of programming construct. It is a Swift type that satisfies the rules of the `View` protocol.
{{< /answer >}}

## Compose an Interface

One `Text` value is not much of an interface. SwiftUI builds larger views by combining smaller ones.

### Q4: What layout will `VStack` produce?

Predict the arrangement before running the code:

```swift
VStack {
    Text("Cookie")
    Text("Energy: 5")
    Text("Hungry")
}
```

Will the three values appear across one row, down one column, or will only the first appear?

{{< answer >}}
They appear in a vertical column:

```text
Cookie
Energy: 5
Hungry
```

`VStack` is both a view and a container for other views. It arranges its children vertically. This is **view composition**: a larger interface is built from smaller views instead of being written as one giant object.
{{< /answer >}}

### Q5: What do view modifiers actually do?

Use what you know about dot notation to read this expression:

```swift
Text("Cookie")
    .font(.title)
    .padding()
```

What does the expression begin with? What does each chained call affect? Does either call change the string `"Cookie"`?

{{< answer >}}
The expression begins by creating a `Text` view. `.font(.title)` describes a title-sized font, and `.padding()` adds space around the result.

The string remains `"Cookie"`. More precisely, a SwiftUI modifier returns a new view that includes the requested change. It does not reach into the original `Text` value and mutate it.

```text
create Text → return a view with a title font → return a view with padding
```

The calls look like ordinary methods because they are methods. SwiftUI uses familiar Swift syntax to construct a description of the interface.
{{< /answer >}}

### Q6: Which container matches the intended layout?

This code compiles, but it places the labels beside each other:

```swift
struct ContentView: View {
    var body: some View {
        HStack {
            Text("Cookie")
            Text("Energy: 5")
        }
    }
}
```

Change it so the energy appears below the name. What does your repair tell SwiftUI?

{{< answer >}}
Replace `HStack` with `VStack`:

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Cookie")
            Text("Energy: 5")
        }
    }
}
```

`HStack` arranges its children horizontally. `VStack` arranges them vertically. Choosing a container is part of describing the relationship among views, not merely a way to make the compiler accept several expressions.
{{< /answer >}}

## Buttons Run Closures

An interface becomes useful when it can respond to someone.

### Q7: When does a button's code run?

```swift
Button("Feed") {
    print("Feeding pet")
}
```

What appears on screen? When does the `print` statement execute, and what familiar Swift concept appears between the braces?

{{< answer >}}
The user sees a button labeled **Feed**. The print statement runs when the button is pressed, not when Swift creates the button.

The braces contain a closure: a function value passed to `Button` so SwiftUI can call it later. This form is called **trailing-closure syntax** because the closure appears after the initializer's parentheses.

The button therefore combines two different pieces of information:

```text
"Feed"                  what the button displays
{ print("Feeding pet") } what the button does
```
{{< /answer >}}

## State Connects Data to the Screen

Printing proves that a button ran, but it does not change the visible energy. The number on screen must depend on a value that can change.

### Q8: What changes after each press?

Predict the initial display and the result after four button presses:

```swift
struct ContentView: View {
    @State private var energy = 5

    var body: some View {
        VStack {
            Text("Energy: \(energy)")

            Button("Feed") {
                energy += 1
            }
        }
    }
}
```

Which line changes the state, and which line displays it?

{{< answer >}}
The interface begins with `Energy: 5`. One press changes it to `Energy: 6`; four presses change it to `Energy: 9`.

This line changes the state:

```swift
energy += 1
```

This line reads that state while describing the interface:

```swift
Text("Energy: \(energy)")
```

When `energy` changes, SwiftUI reevaluates the view's body and updates the affected display. You describe the relationship between state and interface; SwiftUI performs the update.
{{< /answer >}}

### Q9: Why isn't an ordinary property enough?

A first attempt might look like this:

```swift
struct ContentView: View {
    let energy = 5

    var body: some View {
        Button("Feed") {
            energy += 1
        }
    }
}
```

Why does this fail? Why is changing `let` to an ordinary `var` still not the right model for local interface state?

{{< answer >}}
`let` creates a constant, so `energy += 1` cannot compile.

An ordinary mutable property is also a poor fit. SwiftUI view structs are temporary descriptions that the framework may create again as the interface changes. Local state needs storage with a lifetime managed by SwiftUI:

```swift
@State private var energy = 5
```

`@State` tells SwiftUI to preserve this value for the view's identity and to update the interface when it changes. `private` keeps the storage as an implementation detail of `ContentView`.
{{< /answer >}}

## Read the Whole View

### Q10: How do the old and new ideas work together?

Read the complete view before opening the answer:

```swift
import SwiftUI

struct PetView: View {
    let name: String
    @State private var energy = 5

    var body: some View {
        VStack(spacing: 12) {
            Text(name)
                .font(.title)

            Text("Energy: \(energy)")

            HStack {
                Button("Feed") {
                    energy += 1
                }

                Button("Play") {
                    energy -= 1
                }
            }
        }
        .padding()
    }
}
```

Identify the custom type, its three properties, the views composed inside `body`, the modifiers, and the two closures. Then explain what the interface does when either button is pressed.

{{< answer >}}
`PetView` is a struct that conforms to `View`. It has three properties with different roles:

```swift
let name: String                 // information supplied from outside
@State private var energy = 5   // changing local state
var body: some View              // the interface description
```

The body composes `VStack`, `HStack`, `Text`, and `Button` views. `.font(.title)` and `.padding()` are modifiers. Each button receives a closure: Feed adds one to `energy`, while Play subtracts one.

Both labels read properties. `Text(name)` displays fixed input, while `Text("Energy: \(energy)")` displays changing state. When a closure changes `energy`, SwiftUI reevaluates the body and refreshes the energy label.

The bridge from the previous lesson is direct:

```text
struct and protocol conformance → PetView: View
properties                      → name, energy, body
initializers                    → Text(...), Button(...)
closures                        → button actions
dot notation                    → view modifiers
state                           → @State
```
{{< /answer >}}

## Practice: Extend the Pet View

First add a **Sleep** button that increases energy by `2`. Keep Feed and Play, and arrange all three buttons in an `HStack`. Predict the energy after a short sequence of presses before testing it.

Next add an ordinary property:

```swift
let species: String
```

Display the name, species, and energy. Create `PetView` values with different names and species so you can distinguish information supplied by a caller from state owned by the view.

For a separate exercise, build a counter with a `Text` label, a button that adds one, and a reset button. Then build a two-fighter screen from this model:

```swift
struct Fighter {
    let name: String
    var health: Int
}
```

Let each fighter attack the other. Keep asking which code models a fighter and which code describes how a fighter appears.

## Prepare for the Next Lesson

`PetView` currently owns its energy. That is enough for one small view, but larger interfaces raise new questions. What if a parent view owns the pet? How can a smaller child view display that value? How can the child change state it does not own? Where should rules such as minimum and maximum energy live?

Those questions lead to SwiftUI data flow: passing values into views, separating model rules from presentation, and using bindings when one view needs to edit state owned by another.
