---
title: "Functions"
date: 2025-07-29T09:25:22-07:00
draft: true
tags: ["swift",]
categories: ["Swift"]
summary: 
github: "https://github.com/mdm508/SwiftTour"
requirements:
  - 
noteid: 2
---

A function takes inputs and gives outputs. In Swift, we must tell the compiler the types of our inputs and the type of our output.

```swift
func sayHello(to name: String) -> String {
    return "Hello, \(name)!"
}

sayHello(to: "Mr.Whiskers")
sayHello(to: "Tunses")
sayHello(to: "Kitty")
```

`sayHello` took a `String` and returned a `String`.

```swift
func addTwoNumbers(_ a: Int, _ b: Int) -> Int {
    return a + b
}
addTwoNumbers(10, 20)
```

If you add a `_` before the parameter names you can exclude them when you call the function.

---

## Void Functions

```swift
func foo() -> Void {
    print("Hello, World!")
}

func bar() {
    print("Hello, World!")
}

foo()
bar()
```

These functions don't return any data. Such functions are said to return `Void`.\
Note that you do not have to write `-> Void` always, such as with `bar`.

---

## One-line Functions

```swift
func diceRoll() -> Int {
     Int.random(in: 1...6)
}
diceRoll()
```

Functions that are one line can omit the `return` keyword.

---

## Testing Functions

```swift
func square(_ x: Int) -> Int {
    return x * x
}

square(3) == 9  // true
square(2) == 5  // false

let result: Bool = square(2) == 4

assert(square(3) == 9)
// assert(false)  // Uncomment to see a failing assertion
```

- The expressions `square(3) == 9` and `square(2) == 5` evaluate to a `Bool`.
- Use `assert` to crash on a false condition, signaling an error.

---

## Exercises

1. **Coffee Shop Order**

   - Write a function
     ```swift
     func submitOrder(for customer: String, item: String) -> String
     ```
     that returns `"Order submitted for <customer> for a <item>"`.
   - Test with:
     ```swift
     assert(submitOrder(for: "Kailey", item: "Latte") == "Order submitted for Kailey for a Latte")
     assert(submitOrder(for: "Alex",  item: "Espresso") == "Order submitted for Alex for a Espresso")
     ```

2. **Order Total Calculator**

   - Write a function
     ```swift
     func calculateTotal(prices: [Double]) -> Double
     ```
     that returns the sum of all prices.
   - Test with:
     ```swift
     assert(calculateTotal(prices: [3.5, 4.0, 2.75]) == 10.25)
     ```

3. **Discount Application**

   - Write a function
     ```swift
     func applyDiscount(to total: Double, percent: Double) -> Double
     ```
     that returns the total after applying the discount percentage.
   - Test with:
     ```swift
     assert(applyDiscount(to: 50, percent: 10) == 45)
     ```

4. **Tip Calculator**

   - Write a function
     ```swift
     func addTip(to total: Double, tipPercent: Double) -> Double
     ```
     that adds a tip (percent) to the total.
   - Test with:
     ```swift
     assert(addTip(to: 40, tipPercent: 15) == 46)
     ```

5. **Receipt Formatter**

   - Write a function
     ```swift
     func formatReceipt(items: [String], total: Double) -> String
     ```
     that returns a multi-line receipt with each item on its own line, then `"Total: $<total>"`.
   - Test with sample items and total.

6. **Bonus – Process Multiple Orders**

   - Write a function
     ```swift
     func processOrders(orders: [(customer: String, item: String, price: Double)]) -> String
     ```
     that returns a summary string listing each order on its own line and a final `"Combined total: $<sum>"` line.
   - Test with at least three different orders.

