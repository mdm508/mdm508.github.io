---
title: "Object Types: Building Things with State and Behavior"
date: 2026-08-16T12:00:00-07:00
draft: false
description: "Learn how Swift types combine instances, properties, initializers, methods, self, and static members."
tags: ["swift", "object-types", "programming-fundamentals"]
summary: "Build a small virtual-pet model while learning how Swift types hold state, define behavior, and create valid instances."
reading_time: 90
---

Programs become easier to reason about when related data and behavior live together. A virtual pet, for example, has a name and an energy level. It can also introduce itself. Swift lets us describe that idea as a type and then create as many individual pets as we need.

> How do we turn a description of a thing into a Swift type whose instances hold their own state and perform useful work?

We will use one small program throughout the lesson:

```swift
struct Pet {
    var name: String
    var energy: Int

    func introduce() {
        print("I'm \(name). My energy is \(energy).")
    }
}

var cookie = Pet(name: "Cookie", energy: 4)
var butter = Pet(name: "Butter", energy: 7)

cookie.introduce()
butter.introduce()
```

The code is short, but it contains the foundation of Swift's object types: a declaration, properties, instances, initialization, and a method.

## A Type Is a Blueprint

Swift has three principal ways to declare an object type: `struct`, `class`, and `enum`. They serve different purposes, but their declarations share a recognizable shape.

### Q1: What pattern do these declarations share?

Study the code before opening the answer:

```swift
struct Pet {
}

class Robot {
}

enum Direction {
}
```

Which word identifies the kind of type? Which word names it? What belongs inside the braces?

{{< answer >}}
Each declaration follows this broad pattern:

```text
kind-of-type TypeName {
    contents
}
```

`struct`, `class`, and `enum` tell Swift which kind of type we are declaring. `Pet`, `Robot`, and `Direction` name the new types. The braces hold the members that define what the type contains and can do.

We will use a `struct` today. The important first step is recognizing that the declaration creates a new kind of value for the program to use.
{{< /answer >}}

### Q2: Is `Pet` one particular pet?

Consider this line:

```swift
var cookie = Pet(name: "Cookie", energy: 4)
```

What are `Pet`, `cookie`, `"Cookie"`, and `4`?

{{< answer >}}
`Pet` is the type. It describes what every pet value contains and can do.

`cookie` refers to one instance of that type. The string `"Cookie"` becomes this instance's `name`, and `4` becomes its `energy`.

The distinction matters because one type can produce many independent instances:

```swift
var cookie = Pet(name: "Cookie", energy: 4)
var butter = Pet(name: "Butter", energy: 7)
```

Both values are pets, but they are not the same pet. A type defines; an instance exists.
{{< /answer >}}

## Properties Give Each Instance State

A property is a value declared as part of a type. Together, an instance's property values form its state at a particular moment.

### Q3: Why does changing Cookie leave Butter alone?

Predict all four lines of output, then run the code:

```swift
print(cookie.energy)
print(butter.energy)

cookie.energy = 9

print(cookie.energy)
print(butter.energy)
```

{{< answer >}}
The output is:

```text
4
7
9
7
```

The type says that every `Pet` has an `energy` property. Each instance stores its own value for that property. Changing `cookie.energy` therefore changes Cookie's state, not the definition of `Pet` and not Butter's state.

Instances of one type share a structure. They do not share all their values.
{{< /answer >}}

### Q4: How is a property different from a local variable?

```swift
struct Player {
    var name: String

    func announce() {
        let message = "Player: \(name)"
        print(message)
    }
}

let player = Player(name: "Mika")
```

Which expression should compile: `player.name` or `player.message`? Why?

{{< answer >}}
`player.name` compiles because `name` is declared directly inside `Player`. It is a property and therefore part of every `Player` instance.

`player.message` does not compile. `message` is created inside `announce()`, so it exists only while that method runs. It is a local variable, not part of the player's lasting state.

Placement carries meaning: a property belongs to the type's instances; a local variable belongs to one execution of a function or method.
{{< /answer >}}

## Methods Put Behavior Where It Belongs

Properties answer, “What does this value know or contain?” Methods answer, “What can this value do?” A method is a function declared inside a type.

### Q5: Why doesn't `introduce()` need a pet parameter?

Compare these designs:

```swift
func introducePet(_ pet: Pet) {
    print("I'm \(pet.name). My energy is \(pet.energy).")
}

introducePet(cookie)
```

```swift
cookie.introduce()
```

Both can print the same sentence. Why does the first form need a parameter while the second does not?

{{< answer >}}
The standalone function has no pet of its own, so the caller must supply one:

```swift
introducePet(cookie)
```

The method belongs to `Pet`, and the receiver is already visible in the call:

```swift
cookie.introduce()
```

That expression reads naturally: ask this particular pet to introduce itself. Methods are useful when behavior closely depends on the state of an instance.

This does not make methods universally better than functions. It means the second design expresses the relationship between the behavior and the pet more directly.
{{< /answer >}}

### Q6: What does `self` mean inside a method?

Predict the output:

```swift
struct Counter {
    var value: Int

    func report() {
        print(self.value)
    }
}

let first = Counter(value: 2)
let second = Counter(value: 9)

first.report()
second.report()
```

During each call, what does `self` refer to? Would `print(value)` behave differently here?

{{< answer >}}
The output is:

```text
2
9
```

During `first.report()`, `self` is `first`. During `second.report()`, it is `second`. The same method body works with either value because `self` means the instance that received the call.

In this example, `print(value)` produces the same result. Swift can infer that `value` means the current instance's property. Writing `self.value` simply makes that relationship explicit.
{{< /answer >}}

## Initializers Establish a Valid State

Declaring a type does not create a particular value. An initializer creates an instance and gives every required property a starting value.

### Q7: What work does this initializer perform?

```swift
struct Pet {
    var name: String
    var energy: Int

    init(name: String) {
        self.name = name
        self.energy = 5
    }
}

let cookie = Pet(name: "Cookie")
```

Why does the caller provide a name but no energy value? What state does Cookie have afterward?

{{< answer >}}
The initializer receives `"Cookie"` through its `name` parameter.

```swift
self.name = name
```

stores that incoming value in the new instance's `name` property. The next line gives every pet created this way the same starting energy:

```swift
self.energy = 5
```

Cookie therefore begins with the name `"Cookie"` and an energy of `5`. The caller does not choose the energy because the type's initializer has already made that design choice.
{{< /answer >}}

### Q8: Why does Swift reject this initializer?

```swift
struct Robot {
    var name: String
    var power: Int

    init(name: String) {
        self.name = name
    }
}
```

Identify the missing state, explain why it matters, and find two repairs.

{{< answer >}}
`power` never receives a value. If Swift allowed the initializer to finish, the new robot would have incomplete state.

One repair is to assign a value inside the initializer:

```swift
init(name: String) {
    self.name = name
    self.power = 100
}
```

Another is to give the property a default value:

```swift
struct Robot {
    var name: String
    var power: Int = 100

    init(name: String) {
        self.name = name
    }
}
```

Both designs guarantee that every new `Robot` begins with a name and a power level. Initialization is not ceremony; it protects the type's basic rules.
{{< /answer >}}

### Q9: Who should choose a pet's starting energy?

Suppose every pet must begin with energy `5`. Now suppose instead that the caller should choose the starting energy. Which initializer expresses each rule?

```swift
init(name: String) {
    self.name = name
    self.energy = 5
}
```

```swift
init(name: String, energy: Int) {
    self.name = name
    self.energy = energy
}
```

{{< answer >}}
The first initializer expresses a shared game rule: every pet starts at `5`. Callers provide only a name, so they cannot bypass that rule accidentally.

The second initializer makes starting energy a choice that every caller must make.

This is a design decision, not merely a difference in syntax. An initializer defines what information callers must supply and what guarantees the new instance receives. Choose the first form when equal starting energy is part of the game. Choose the second when varied starting energy is part of the model.
{{< /answer >}}

## Instance Members and Type Members

The members we have used so far belong to individual instances. Swift uses `static` when a property or method should belong to the type itself.

### Q10: Does this member describe one pet or every pet?

```swift
struct Pet {
    static let maxEnergy = 10

    var name: String
    var energy: Int
}

let cookie = Pet(name: "Cookie", energy: 4)
```

Predict which expressions compile:

```swift
Pet.maxEnergy
cookie.maxEnergy
Pet.name
cookie.name
```

Then explain why `maxEnergy` and `energy` belong in different places.

{{< answer >}}
`Pet.maxEnergy` compiles and evaluates to `10`. The value describes a rule for the type as a whole.

`cookie.name` also compiles and evaluates to `"Cookie"`. The name belongs to that instance.

`cookie.maxEnergy` does not compile because a static property is accessed through the type. `Pet.name` does not compile because an instance property needs a particular pet.

The same distinction applies to methods. A static method is called through the type and does not receive an instance as `self`:

```swift
struct Pet {
    static let maxEnergy = 10

    static func energyIsValid(_ value: Int) -> Bool {
        value >= 0 && value <= maxEnergy
    }

    var name: String
    var energy: Int
}

print(Pet.energyIsValid(8))
```

Ask one question when placing a member: does this information or behavior require one particular instance? Names and current energy do. A shared maximum and a rule for checking it do not.
{{< /answer >}}

## What You Have Learned

A type describes a kind of value; an instance is one value of that type. Properties hold each instance's state, while methods place related behavior beside that state. Inside an instance method, `self` means the instance receiving the call.

An initializer establishes complete starting state and controls which choices a caller must make. Most members belong to an instance. A `static` member belongs to the type and is accessed through the type's name.

## Practice: Design Another Type

Start by extending `Pet`. Add an `age` property, update the initializer, and include the age in `introduce()`. Then add this method and test it with pets that have different energy values:

```swift
func isTired() -> Bool
```

A pet is tired when its energy is less than `3`. Add `static let maxEnergy = 10`, then print the maximum without creating another pet.

Next, create a `Book` type with a title, a page count, an initializer, and a `describe()` method. Create two books so you can see that one type produces independent instances.

If you want a larger design problem, build a `GameCharacter` whose initializer always starts `level` at `1`. Give it a name, health, `describe()`, and `isAlive() -> Bool`. Decide which values belong to each character and whether the type needs a shared rule.

Finally, design a `Spaceship` with at least three instance properties, one static property, a custom initializer, and two instance methods. One method should return a value. Create two ships and explain what the initializer guarantees, which member belongs to the type, and what `self` means inside each instance method.
