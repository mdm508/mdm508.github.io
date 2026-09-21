---
title: "From Swift Objects to SwiftUI, Part 2: Data Flow and Bindings"
date: 2026-09-20T00:00:00-07:00
draft: false
description: "Move SwiftUI state into a parent, keep validation in the model, pass read-only values to display views, and use bindings when a child must request changes."
tags: ["swift", "swiftui", "data-flow", "bindings", "programming-fundamentals"]
summary: "Give the pet model one source of truth, split the interface into focused child views, and follow each change through SwiftUI's data flow."
reading_time: 120
---

This lesson continues [From Swift Objects to SwiftUI](/post/from-swift-objects-to-swiftui/). Part 1 gave `PetView` its own energy and taught it to keep that value between `0` and `10`.

That works until the interface grows. A status panel may need to display the pet. A control panel may need to feed it. A parent screen may need to save it or replace it. If each view keeps its own energy, the interface can disagree with itself.

> How can several views work with one pet without creating several conflicting sources of truth?

The answer has three parts: the model protects its own rules, one view owns the changing value, and child views receive only the access they need.

## Put the Rule in the Model

### Q1: What is wrong with protecting energy only in a button?

Part 1 used this button action:

```swift
Button("Feed") {
    energy = min(energy + 1, 10)
}
```

The boundary works. Why is the design fragile once another screen, button, or test can also change energy?

{{< answer >}}
The rule belongs to one button instead of the pet. Every new control must remember the same boundary:

```text
Feed button   must remember 0...10
Sleep button  must remember 0...10
Debug screen  must remember 0...10
```

One forgotten check can create an invalid pet. The interface should decide what action the user requested. The model should decide what counts as valid pet data.
{{< /answer >}}

### Q2: How can `Pet` enforce the rule once?

Read this model before opening the answer:

```swift
struct Pet {
    let name: String
    private(set) var energy: Int

    init(name: String, energy: Int = 5) {
        self.name = name
        self.energy = min(max(energy, 0), 10)
    }

    mutating func feed() {
        energy = min(energy + 1, 10)
    }

    mutating func play() {
        energy = max(energy - 1, 0)
    }
}
```

What happens when a caller creates `Pet(name: "Cookie")`? What happens with starting energy values of `-4` and `30`?

{{< answer >}}
The initializer supplies `5` when the caller omits energy:

```swift
Pet(name: "Cookie")
```

The nested `max` and `min` clamp every supplied value to the valid range:

```text
-4  → 0
 5  → 5
30  → 10
```

The methods preserve the same rule after initialization. A valid pet starts valid and remains valid.
{{< /answer >}}

### Q3: What does `private(set)` allow?

Compare these two lines outside `Pet`:

```swift
print(pet.energy)
pet.energy = 100
```

Which line is allowed, and why is that useful?

{{< answer >}}
Other code may read `energy`, so the first line works. Its setter is private, so the second line does not compile.

```swift
private(set) var energy: Int
```

This gives the interface enough access to display the value without giving it permission to bypass `feed()` and `play()`. The model exposes information while keeping control of its invariant.
{{< /answer >}}

## Give the State One Owner

### Q4: Which view should own the pet?

Suppose a screen contains both a pet summary and a row of controls. Which value should be state?

```swift
struct PetScreen: View {
    @State private var pet = Pet(name: "Cookie")

    var body: some View {
        // summary and controls will go here
    }
}
```

Why does the parent own the whole `Pet` instead of keeping a separate energy value in each child?

{{< answer >}}
`PetScreen` is the nearest view that needs to coordinate both children. Its `pet` is the single source of truth.

```text
PetScreen owns Pet
    ├── summary reads Pet
    └── controls request changes to Pet
```

When `pet` changes, SwiftUI reevaluates the screen and supplies the current value to its children. The children do not need competing copies of the same state.
{{< /answer >}}

### Q5: Why not give both children their own `@State`?

Imagine that `PetSummary` and `PetControls` each begin with this declaration:

```swift
@State private var pet = Pet(name: "Cookie")
```

What goes wrong after the controls feed their pet?

{{< answer >}}
The two properties create two pets. Feeding the controls' copy does not change the summary's copy.

The problem is not that `@State` is weak. The problem is that it creates ownership. Use it when a view truly owns a changing value, not whenever a view needs to see one.
{{< /answer >}}

## Pass Read-Only Data Down

### Q6: How can a child display the pet without owning it?

```swift
struct PetSummary: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 8) {
            Text(pet.name)
                .font(.title)

            Text("Energy: \(pet.energy)")
        }
    }
}
```

Why is `let pet: Pet` enough? Will the summary become stale when the parent changes its state?

{{< answer >}}
The summary only displays information, so a read-only property is the honest interface.

The child does not keep a second source of truth. When the parent's state changes, SwiftUI creates a new description of the screen and passes the current pet into `PetSummary` again.

```swift
PetSummary(pet: pet)
```

Think of this as data flowing down from the owner, not as the parent handing away ownership.
{{< /answer >}}

### Q7: Why can't the summary call `pet.feed()`?

`feed()` is a mutating method. What would this button do inside `PetSummary`?

```swift
Button("Feed") {
    pet.feed()
}
```

{{< answer >}}
It does not compile because `pet` is a `let` property. That is useful feedback: a display-only child is trying to perform a job outside its contract.

We could make every child more powerful, but that would hide the design. A clearer program distinguishes views that read from views that may request changes.
{{< /answer >}}

## Let a Child Request Changes with a Binding

### Q8: What does `@Binding` mean?

The control view needs to work with the parent's pet:

```swift
struct PetControls: View {
    @Binding var pet: Pet

    var body: some View {
        HStack {
            Button("Feed") {
                pet.feed()
            }

            Button("Play") {
                pet.play()
            }
        }
    }
}
```

Does `PetControls` now own another pet?

{{< answer >}}
No. A binding is read-and-write access to state owned somewhere else.

```text
@State    owns changing storage
@Binding  refers to changing storage owned by another view
```

Calling `pet.feed()` through the binding changes the `PetScreen` state. The control view can edit the value, but it does not decide how long that value lives.
{{< /answer >}}

### Q9: Why does the parent pass `$pet` instead of `pet`?

The parent constructs its children like this:

```swift
PetSummary(pet: pet)
PetControls(pet: $pet)
```

What different meanings do `pet` and `$pet` have?

{{< answer >}}
`pet` is the current `Pet` value. That is what the read-only summary needs.

`$pet` is the binding projected by `@State`. It carries a path back to the parent's storage. That is what a child with `@Binding` expects.

The dollar sign does not mean “the more powerful version of every variable.” Property wrappers may expose a projected value with `$`. For `@State`, that projected value is a binding.
{{< /answer >}}

### Q10: Where is the energy rule enforced now?

The button closure contains only this line:

```swift
pet.feed()
```

Trace one press from the button to the updated label. Which layer handles the request, which layer validates it, and which layer redraws the interface?

{{< answer >}}
The action follows one clear route:

```text
button press
    → PetControls calls pet.feed()
    → Pet.feed() protects the 0...10 rule
    → PetScreen's state changes through the binding
    → SwiftUI reevaluates the screen
    → PetSummary receives and displays the new pet
```

The control expresses intent. The model enforces validity. The parent owns the result. SwiftUI keeps the display synchronized.
{{< /answer >}}

## Read the Whole Feature

### Q11: How do the pieces fit together?

Read the complete example from the model upward:

```swift
import SwiftUI

struct Pet {
    let name: String
    private(set) var energy: Int

    init(name: String, energy: Int = 5) {
        self.name = name
        self.energy = min(max(energy, 0), 10)
    }

    mutating func feed() {
        energy = min(energy + 1, 10)
    }

    mutating func play() {
        energy = max(energy - 1, 0)
    }
}

struct PetScreen: View {
    @State private var pet = Pet(name: "Cookie")

    var body: some View {
        VStack(spacing: 20) {
            PetSummary(pet: pet)
            PetControls(pet: $pet)
        }
        .padding()
    }
}

struct PetSummary: View {
    let pet: Pet

    var body: some View {
        VStack(spacing: 8) {
            Text(pet.name)
                .font(.title)

            ProgressView(
                "Energy",
                value: Double(pet.energy),
                total: 10
            )

            Text("\(pet.energy) / 10")
        }
    }
}

struct PetControls: View {
    @Binding var pet: Pet

    var body: some View {
        HStack {
            Button("Feed") {
                pet.feed()
            }
            .disabled(pet.energy >= 10)

            Button("Play") {
                pet.play()
            }
            .disabled(pet.energy <= 0)
        }
    }
}
```

Before running it, identify the owner, the two borrowers, and the only code allowed to assign a new energy value.

{{< answer >}}
`PetScreen` owns the pet through `@State`. `PetSummary` borrows read-only information through a plain property. `PetControls` borrows read-and-write access through `@Binding`.

Only code inside `Pet` can assign to `energy` because its setter is private. The controls can call the model's methods, but they cannot invent a new energy rule.

The feature has one changing value, one place that validates it, and explicit paths for reading and editing it.
{{< /answer >}}

## Practice: Extend the Data Flow

### Q12: Can you add rest without duplicating the boundary?

Add a model method named `rest()` that restores `2` energy, then add a **Rest** button to `PetControls`. The button should disable at full energy.

The control may call the method, but it may not contain `min`, `max`, or a direct energy assignment.

{{< answer >}}
Put the rule beside the other model rules:

```swift
mutating func rest() {
    energy = min(energy + 2, 10)
}
```

Then let the child express the request:

```swift
Button("Rest") {
    pet.rest()
}
.disabled(pet.energy >= 10)
```

If another interface adds a Rest control later, it can reuse the same safe operation.
{{< /answer >}}

### Q13: Where should a derived mood live?

Add a mood with these rules:

```text
0...2   Tired
3...7   Ready
8...10  Energetic
```

Both a SwiftUI view and a future command-line program might want this description. Should mood be `@State`, a view-only calculation, or a computed model property?

{{< answer >}}
Mood is derived from model data and is useful outside one particular view, so make it a computed property on `Pet`:

```swift
var mood: String {
    if energy <= 2 {
        return "Tired"
    }

    if energy >= 8 {
        return "Energetic"
    }

    return "Ready"
}
```

The summary can display it without storing another value:

```swift
Text(pet.mood)
```

There is still one source of truth. Mood cannot disagree with energy because it is recalculated from energy.
{{< /answer >}}

### Q14: Can you learn `Stepper` without weakening the model?

Read Apple's [`Stepper` documentation](https://developer.apple.com/documentation/swiftui/stepper). Find an initializer that accepts separate increment and decrement actions.

Replace the Feed and Play buttons with a stepper. Its actions must call `feed()` and `play()`; do not expose a writable energy property merely to satisfy the view.

{{< answer >}}
One solution uses the action-based initializer:

```swift
Stepper {
    Text("Energy: \(pet.energy)")
} onIncrement: {
    pet.feed()
} onDecrement: {
    pet.play()
}
```

This uses the action-based initializer instead of binding the stepper directly to `energy`. The view requests an increment or decrement, and the model protects the range.

Test the stepper at `0` and `10`. A control is not finished merely because it changes the value in the middle of the range.
{{< /answer >}}

## How Much Power Should a Child Receive?

A binding is appropriate when a child genuinely edits a value owned by its parent. It is not the only option. A small control can receive closures instead:

```swift
struct PetControls: View {
    let energy: Int
    let onFeed: () -> Void
    let onPlay: () -> Void

    var body: some View {
        HStack {
            Button("Feed", action: onFeed)
                .disabled(energy >= 10)

            Button("Play", action: onPlay)
                .disabled(energy <= 0)
        }
    }
}
```

The parent supplies the actions:

```swift
PetControls(
    energy: pet.energy,
    onFeed: { pet.feed() },
    onPlay: { pet.play() }
)
```

This child can request exactly two changes and nothing else. Prefer the clearest contract for the job: a value for reading, a binding for general editing, or closures for a small set of named actions.

## What Comes Next

One parent and one pet give us a clean data-flow path. A larger program introduces new questions: how do we display several pets, preserve each pet's identity, edit one item in a collection, and share data across screens that do not have a simple parent-child relationship?

Those questions lead from local data flow to collections, identity, and shared models.
