---
title: "From Swift Objects to SwiftUI, Part 2: Data Flow and Bindings"
date: 2026-09-20T00:00:00-07:00
draft: false
description: "Move SwiftUI state into a parent, keep validation in the model, pass read-only values to display views, and use bindings when a child must request changes."
tags: ["swift", "swiftui", "data-flow", "bindings", "programming-fundamentals"]
summary: "Give the pet model one source of truth, split the interface into focused child views, and follow each change through SwiftUI's data flow."
reading_time: 120
---

This lesson continues [From Swift Objects to SwiftUI](/post/from-swift-objects-to-swiftui/). In Part 1, we built `PetView`: one view displayed the pet's name and energy, stored the energy with `@State`, and provided Feed and Play buttons.

We will now **refactor that same feature**. A refactor reorganizes working code while preserving its behavior. Our pet will still start with `5` energy, gain one when fed, lose one when played with, and stay between `0` and `10`. What changes is where those responsibilities live.

By the end, we will have a `Pet` model for the pet's data and rules, a `PetScreen` that owns the changing pet, and two smaller views for the display and controls. We will build those pieces one at a time. The questions are checkpoints after each explanation; you should be able to read the lesson without opening the answers and still follow the design.

## First, What Are Parent and Child Views?

**View composition** means building a larger interface by combining smaller views. You have already done this:

```swift
VStack {
    Text("Cookie")
    Text("Energy: 5")
}
```

Here, the `VStack` contains two `Text` views. In this relationship, the container is the **parent** and the views it contains are its **children**. These words describe how views fit together on screen. They do not mean that one Swift type inherits from another.

We can also compose views that we define ourselves. For example, we can move the labels into a named view:

```swift
struct PetSummary: View {
    var body: some View {
        VStack {
            Text("Cookie")
            Text("Energy: 5")
        }
    }
}
```

Another view can now include `PetSummary()` in its own `body`, just as it would include `Text(...)`. This gives a familiar group of interface elements a name and a focused job. The values are fixed for this first example; later, the parent will supply the current pet.

In our refactored feature, the custom views will fit together like this:

```text
PetScreen                 arranges the feature
    └── VStack            stacks its two sections vertically
        ├── PetSummary    displays the name and energy
        └── PetControls   contains Feed and Play buttons
```

We will call `PetScreen` the parent of these two custom views because it creates and coordinates them in its `body`. There is a `VStack` between them in the layout. `PetSummary` and `PetControls` are siblings: they appear alongside each other under the same parent screen. A view can be a child in one relationship and a parent in another; `PetSummary` will contain its own labels.

## Before and After: The Refactor We Are Building

The left column is the complete `PetView` from Part 1. The right column previews the new parent screen. The new screen uses three types we will define below: `Pet`, `PetSummary`, and `PetControls`. **The right column is a destination to read, not a complete program to paste yet.**

{{< code-comparison >}}
### Before: One View Does Every Job

```swift
struct PetView: View {
    let name: String
    @State private var energy = 5

    init(name: String = "Cookie") {
        self.name = name
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(name)
                .font(.title)

            Text("Energy: \(energy)")

            HStack {
                Button("Feed") {
                    energy = min(energy + 1, 10)
                }
                .disabled(energy >= 10)

                Button("Play") {
                    energy = max(energy - 1, 0)
                }
                .disabled(energy <= 0)
            }
        }
        .padding()
    }
}
```

The name, state, labels, buttons, and energy rules all live in `PetView`.
<!-- next -->
### After: A Parent Composes Smaller Views

```swift
struct PetScreen: View {
    @State private var pet = Pet(name: "Cookie")

    var body: some View {
        VStack(spacing: 12) {
            PetSummary(pet: pet)
            PetControls(pet: $pet)
        }
        .padding()
    }
}
```

`PetScreen` owns one pet and arranges the two child views. The labels move into `PetSummary`. The buttons move into `PetControls`. The energy rules move into `Pet`.

Read the two child initializers as:

```swift
// Give the summary a value to display.
PetSummary(pet: pet)

// Give the controls access to edit
// the parent's state.
PetControls(pet: $pet)
```

The `$pet` syntax supplies read-and-write access called a **binding**. We will explain and use it after the model and display are in place.
{{< /code-comparison >}}

The new parent is shorter because other types now do some of its work. The total program may be longer, but each part has a clearer purpose:

| Responsibility | Before | After |
| --- | --- | --- |
| Store changing data | `PetView.energy` | `PetScreen.pet` |
| Keep energy in `0...10` | Each button action | Methods on `Pet` |
| Display the pet | Labels inside `PetView` | `PetSummary` |
| Respond to Feed and Play | Buttons inside `PetView` | `PetControls` |
| Arrange the feature | `PetView.body` | `PetScreen.body` |

This lets us change the summary's layout without searching through button code, reuse the summary in another screen, and reuse safe pet operations wherever they are needed. Splitting a view does not automatically improve a program; the useful split gives each piece a job we can describe.

We will make this refactor in three steps: move the pet's rules into a model, put one pet in the parent, and connect the children to it.

## Step 1: Put the Rule in the Model

A **model** represents the information and behavior of the thing our program works with. `Pet` is our model; labels and buttons are its interface. The rule that energy stays between `0` and `10` describes a valid pet, so it belongs in `Pet`.

In Part 1, each button enforced part of that rule:

```swift
// Feed button
energy = min(energy + 1, 10)

// Play button
energy = max(energy - 1, 0)
```

That works for those buttons. But if a second screen changes energy, it must remember the same checks. Moving the rule into model methods gives every interface a safe operation to call.

### Q1: What problem would another Feed button create?

Suppose a new screen feeds the pet with `energy += 1`. The pet already has `10` energy. What would happen, and which rule did the new button forget?

{{< answer >}}
Energy would become `11`. The button forgot the upper boundary. When validation lives in individual buttons, every new button must remember it. A shared model method can enforce the boundary for every caller.
{{< /answer >}}

### Build a Pet That Starts and Stays Valid

Here is the model we will use in the refactored feature:

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

The initializer's default, `energy: Int = 5`, lets us write `Pet(name: "Cookie")`. The expression `min(max(energy, 0), 10)` **clamps** the starting value: `max` raises anything below `0` to `0`, and `min` lowers anything above `10` to `10`. For example, starting energy `30` becomes `10`.

The methods are marked `mutating` because they change a stored property of a struct. Calling `feed()` or `play()` keeps the same valid range after initialization.

`private(set)` means that code outside `Pet` can read energy but cannot assign to it directly:

```swift
var pet = Pet(name: "Cookie")
print(pet.energy)  // Allowed: read the energy.
pet.feed()         // Allowed: use a safe model operation.
// pet.energy = 100  // Not allowed: the setter is private.
```

A rule that must always hold is sometimes called an **invariant**. Here, the invariant is `0 <= energy && energy <= 10`. Restricting direct assignment helps `Pet` protect it.

### Q2: What energy will each new pet have?

Predict the energy of these three pets, using the initializer above:

```swift
Pet(name: "Cookie")
Pet(name: "Mochi", energy: -4)
Pet(name: "Pepper", energy: 30)
```

{{< answer >}}
Cookie starts at the default `5`, Mochi at `0`, and Pepper at `10`. The initializer clamps supplied values into the valid range.
{{< /answer >}}

### Q3: Which changes are allowed outside `Pet`?

Given `var pet = Pet(name: "Cookie")`, decide which of these lines compile:

```swift
print(pet.energy)
pet.energy = 100
pet.feed()
```

{{< answer >}}
Reading `pet.energy` and calling `pet.feed()` compile. Direct assignment to `energy` does not, because its setter is private. Callers can change the pet through its methods while the model keeps control of the rule.
{{< /answer >}}

## Step 2: Give the Parent One Pet to Own

Now we need somewhere to keep the pet while the interface is in use. In Part 1, `@State` preserved an integer for `PetView`. It can also preserve a whole `Pet` value for `PetScreen`:

```swift
struct PetScreen: View {
    @State private var pet = Pet(name: "Cookie")

    var body: some View {
        Text("Energy: \(pet.energy)")
    }
}
```

At this intermediate step, the parent still displays energy directly. Next, it will pass the pet to the two children from our diagram.

Here, **owns the state** means that this view declares the `@State` property whose storage SwiftUI manages. A **single source of truth** is the one stored value all parts of the feature use. Both children need the same pet, so we keep it in their shared parent, `PetScreen`.

Creating a separate `@State private var pet` in each child would create two independent pets. Matching names and starting energies would not connect them. Feeding one would leave the other unchanged.

### Q4: Where should the shared pet live?

`PetSummary` needs to display energy, and `PetControls` needs to change it. In the view diagram above, which custom view contains both of them and should declare `@State private var pet`?

{{< answer >}}
`PetScreen` contains and coordinates both children, so it owns the shared state. The summary will receive the current value; the controls will receive access to change the same state.
{{< /answer >}}

### Q5: What would two independent state properties display?

Imagine both children declare their own `@State private var pet = Pet(name: "Cookie")`. Both pets start at `5`. The controls feed their pet once. What energy would each copy now have?

{{< answer >}}
The controls' pet would have `6` energy, and the summary's pet would still have `5`. Each `@State` declaration created independent storage. A child that needs the parent's data should receive it instead of starting a second source of truth.
{{< /answer >}}

## Step 3: Connect the Children to the Parent's Pet

### A Display Child Receives a Value

First, replace our fixed-label `PetSummary` with a version that accepts a `Pet`:

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

The declaration `let pet: Pet` makes this a read-only input. Swift automatically supplies an initializer whose parameters come from the stored properties, called a **memberwise initializer**. That lets the parent create this child and supply its `pet` property with:

```swift
PetSummary(pet: pet)
```

Replace the parent's `Text(...)` with that line. The parent still owns the state; the child receives the current `Pet` value to display. When the state changes, SwiftUI updates the dependent interface and supplies the child with the current value. A `let` input does not freeze the display at its first energy reading.

This is **data flowing down**: the parent supplies information to the views it composes. Because `Pet` is a struct, passing its value does not give the child shared writable storage. Calling a `mutating` method such as `feed()` on this `let` property would fail to compile.

### Q6: What will the summary show after a change?

The parent passes `PetSummary(pet: pet)` when energy is `5`. Later, the parent's pet is fed and energy becomes `6`. Which value should the summary display after SwiftUI updates the interface?

{{< answer >}}
It displays `6`. SwiftUI supplies the current pet as input when updating the child. `let` prevents the child from mutating its input; it does not prevent the parent from supplying updated input.
{{< /answer >}}

### Q7: Can the display child feed its input?

Would this button compile inside the `PetSummary` above? Explain using the child's property declaration.

```swift
Button("Feed") {
    pet.feed()
}
```

{{< answer >}}
No. `pet` is a `let` property, and `feed()` is a mutating method. This child has read-only input. The control child needs a different kind of access.
{{< /answer >}}

### An Editing Child Receives a Binding

`PetControls` needs to change the pet that `PetScreen` owns. A **binding** provides read-and-write access to a value stored elsewhere. It connects an editing view to existing state instead of creating a separate state value.

The child declares this access with `@Binding`:

```swift
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

Here is the difference among the declarations we have used:

| Declaration | Role in this feature |
| --- | --- |
| `@State private var pet` | The parent declares the changing state. |
| `let pet: Pet` | The summary receives a value to read. |
| `@Binding var pet: Pet` | The controls receive access to read and edit existing state. |

To supply a binding from its `@State` property, the parent writes `$pet`:

```swift
PetControls(pet: $pet)
```

`pet` gives us the current `Pet` value. `$pet` gives us a `Binding<Pet>` connected to the parent's state. The `$` form is called a **projected value**; for `@State`, that projected value is a binding. A **property wrapper** such as `@State` or `@Binding` adds behavior to a property. For `@State`, this includes SwiftUI-managed storage and access to a binding. The `$` form depends on what the wrapper provides; it is not syntax we can add to any ordinary variable.

The parent can now compose both children inside its `VStack`:

```swift
PetSummary(pet: pet)
PetControls(pet: $pet)
```

The two lines look similar, but they grant different access. The summary reads a value; the controls can change the parent's state through a binding. The model still prevents direct assignment to `energy`, so the controls use `feed()` and `play()`.

### Q8: Does `@Binding` create another pet to own?

The controls call `pet.feed()` through their binding. Which view's state changes, and does the summary receive the result?

{{< answer >}}
The binding writes the changed pet back to `PetScreen`'s state. It does not create an independent source of truth in `PetControls`. SwiftUI updates the summary with the new value.
{{< /answer >}}

### Q9: Which argument belongs in each call?

Fill the blanks with `pet` or `$pet`, using the property declarations in the children above:

```swift
PetSummary(pet: _____)
PetControls(pet: _____)
```

{{< answer >}}
```swift
PetSummary(pet: pet)
PetControls(pet: $pet)
```

The summary expects a `Pet` value. The controls expect a `Binding<Pet>`.
{{< /answer >}}

### Follow One Feed Press

We have now moved the original code into the parts shown in the early comparison. Follow a press with energy starting at `5`:

```text
1. The user presses Feed in PetControls.
2. The button calls pet.feed() through the binding.
3. Pet.feed() calculates min(5 + 1, 10), producing 6.
4. The binding writes the updated Pet to PetScreen's state.
5. SwiftUI updates the dependent interface.
6. PetSummary receives the current pet and displays Energy: 6.
```

The button chooses an operation, the model enforces its rule, and the binding connects the edit to the parent's state. The parent then supplies updated data to its children. This route is what we mean by **data flow** in this feature.

Disabling a button communicates a limit to the user. The model's boundary checks still matter: code outside this button may call the same methods.

### Q10: Does the model still protect the boundary?

Suppose code calls `feed()` on a pet with energy `10`, even though the Feed button would be disabled. What energy results, and where is the boundary enforced?

{{< answer >}}
Energy remains `10` because `Pet.feed()` evaluates `min(10 + 1, 10)`. The model enforces the boundary. It does not depend on every interface disabling its controls correctly.
{{< /answer >}}

## Read the Whole Feature

We have completed the refactor previewed at the start. This version keeps the same plain energy label and Feed/Play behavior as Part 1. The new types separate the work; a progress bar or other display improvements can come later.

This is the complete example. In the SwiftUI project from Part 1, replace the old `PetView` with these four declarations. Where your app's root view previously used `PetView()`, use `PetScreen()` instead. Keep the project's existing app entry point.

Read from the model to the parent, then through its two children:

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
        VStack(spacing: 12) {
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

            Text("Energy: \(pet.energy)")
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

### Q11: How do the pieces fit together?

Before running the complete example, identify which view owns the state, which child receives a value, which child receives a binding, and which type can assign directly to `energy`.

Then run it. Confirm that energy starts at `5`, Feed stops at `10`, Play stops at `0`, and the summary changes after each press. Compare the result with Part 1: the behavior should be familiar even though the code is organized differently.

{{< answer >}}
`PetScreen` owns the pet through `@State`. `PetSummary` receives a read-only value through a plain property. `PetControls` receives read-and-write access through `@Binding`.

Only code inside `Pet` can assign to `energy` because its setter is private. The controls can call the model's methods, but they cannot invent a new energy rule.

The feature has one changing value, one place that validates it, and explicit paths for reading and editing it.
{{< /answer >}}

## Practice: Extend the Data Flow

Use the completed example for these exercises. Each extension builds on the same route: the parent stores the pet, the summary displays it, and the controls change it through model operations.

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

### Derive Information Instead of Storing It Twice

A **derived value** is calculated from existing data. For example, a pet's mood can depend entirely on its energy. A **computed property** returns such a calculation when it is read instead of storing another independent value.

```swift
// Inside Pet:
var isTired: Bool {
    energy <= 2
}
```

The summary could read `pet.isTired`. When energy changes, the next read uses the new energy. We do not need another `@State` property to remember the same information in a different form.

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

### Another Control Can Request the Same Operations

A `Stepper` is a SwiftUI control with increment and decrement actions, often shown as plus and minus buttons. One form edits a numeric binding directly. Another accepts action closures: code to run when the user increments or decrements. We will use the action form so `Pet` can keep protecting its energy.

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

The complete feature above uses `@Binding`. An alternative is useful when a child should be allowed to request only a few specific operations.

A **closure** is a function value that can be passed to other code. You used closures for button actions in Part 1. Here, the parent can supply the button actions instead of giving the child a binding to the whole pet.

In the alternative below, `onFeed` and `onPlay` have type `() -> Void`: functions that take no arguments and return no result. The controls receive the current energy for display decisions and these two actions to run. This is an optional replacement for `PetControls`, not another declaration to add alongside the binding version:

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

If you choose this alternative, also replace `PetControls(pet: $pet)` in the parent with:

```swift
PetControls(
    energy: pet.energy,
    onFeed: { pet.feed() },
    onPlay: { pet.play() }
)
```

This child can request exactly two changes and nothing else. Prefer the clearest contract for the job: a value for reading, a binding for general editing, or closures for a small set of named actions.

For Apple's explanation of state storage and sharing it between views, see [Managing user interface state](https://developer.apple.com/documentation/swiftui/managing-user-interface-state).

## What Comes Next

One parent and one pet give us a clean data-flow path. A larger program introduces new questions: how do we display several pets, preserve each pet's identity, edit one item in a collection, and share data across screens that do not have a simple parent-child relationship?

Those questions lead from local data flow to collections, identity, and shared models.
