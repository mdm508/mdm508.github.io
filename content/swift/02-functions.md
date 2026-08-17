---
title: "Functions"
date: 2025-11-03T03:46:31-08:00
draft: true
tags: ["swift"]
categories: ["Swift"]
summary: "Functions are first class citizens"
weight: 2
reading: "Chapter 02-functions"
---

# Functions

Functions are first-class citizens in Swift. This lesson covers parameters, return types, signatures, overloading, default parameters, variadic parameters, and inout behavior.

---

## Key Terms

<div class="lesson-section">

<div class="question">
<strong>Parameter</strong>
<details><summary>Show Definition</summary>
A named input to a function, treated as a local constant.
</details>
</div>

<div class="question">
<strong>Return Type</strong>
<details><summary>Show Definition</summary>
The type of value a function outputs.
</details>
</div>

<div class="question">
<strong>Function Signature</strong>
<details><summary>Show Definition</summary>
The full type of a function: parameters + return type.
</details>
</div>

<div class="question">
<strong>Scope</strong>
<details><summary>Show Definition</summary>
Where a value can be accessed in code.
</details>
</div>

<div class="question">
<strong>Overloading</strong>
<details><summary>Show Definition</summary>
Multiple functions with same name but different signatures.
</details>
</div>

<div class="question">
<strong>inout</strong>
<details><summary>Show Definition</summary>
Allows a function to modify the caller’s variable directly.
</details>
</div>

</div>

---

## Function Parameters & Return Values

<div class="lesson-section">

<div class="question">1. What is the purpose of a function parameter?
<details><summary>Show Solution</summary>
It provides input values to the function.
</details></div>

<div class="question">2. What does return do besides output a value?
<details><summary>Show Solution</summary>
It immediately ends function execution.
</details></div>

<div class="question">3. Why must return types match exactly?
<details><summary>Show Solution</summary>
Swift enforces strict type safety.
</details></div>

<div class="question">4. Why don’t external variable names affect function parameters?
<details><summary>Show Solution</summary>
Parameters are locally bound inside the function call.
</details></div>

<div class="question">5. What happens if you ignore a return value?
<details><summary>Show Solution</summary>
It is discarded; Swift may warn unless explicitly ignored.
</details></div>

</div>

---

## Void Functions & No Parameters

<div class="lesson-section">

<div class="question">6. What does Void mean?
<details><summary>Show Solution</summary>
The function returns no value.
</details></div>

<div class="question">7. Why are parentheses still required for no-parameter functions?
<details><summary>Show Solution</summary>
They indicate a function call.
</details></div>

<div class="question">8. Can a function have no parameters and no return?
<details><summary>Show Solution</summary>
Yes.
</details></div>

<div class="question">9. When are Void functions useful?
<details><summary>Show Solution</summary>
When performing actions like printing or logging.
</details></div>

</div>

---

## Function Signatures

<div class="lesson-section">

<div class="question">10. What is a function signature?
<details><summary>Show Solution</summary>
The full type: parameters + return type.
</details></div>

<div class="question">11. Why are signatures important?
<details><summary>Show Solution</summary>
They allow functions to be stored and passed as values.
</details></div>

<div class="question">12. What does (Int, Int) -> Int represent?
<details><summary>Show Solution</summary>
A function taking two Ints and returning an Int.
</details></div>

</div>

---

## External Parameter Names

<div class="lesson-section">

<div class="question">13. What is an external parameter name?
<details><summary>Show Solution</summary>
A label used when calling a function.
</details></div>

<div class="question">14. What does _ mean in a parameter list?
<details><summary>Show Solution</summary>
It removes the external label requirement.
</details></div>

<div class="question">15. Why are labels useful?
<details><summary>Show Solution</summary>
They improve readability.
</details></div>

</div>

---

## Function Overloading

<div class="lesson-section">

<div class="question">16. What is overloading?
<details><summary>Show Solution</summary>
Multiple functions with the same name but different signatures.
</details></div>

<div class="question">17. How does Swift distinguish overloads?
<details><summary>Show Solution</summary>
By parameter types and structure.
</details></div>

<div class="question">18. Can two functions differ only by return type?
<details><summary>Show Solution</summary>
Not unless context disambiguates the call.
</details></div>

</div>

---

## Default Parameters

<div class="lesson-section">

<div class="question">19. What is a default parameter?
<details><summary>Show Solution</summary>
A value used when no argument is provided.
</details></div>

<div class="question">20. What happens when omitted?
<details><summary>Show Solution</summary>
Swift uses the default value.
</details></div>

</div>

---

## Variadic Parameters

<div class="lesson-section">

<div class="question">21. What is a variadic parameter?
<details><summary>Show Solution</summary>
A parameter that accepts multiple values.
</details></div>

<div class="question">22. How is it used internally?
<details><summary>Show Solution</summary>
As an array.
</details></div>

<div class="question">23. Can you pass an array directly?
<details><summary>Show Solution</summary>
No, unless overloaded.
</details></div>

</div>

---

## Inout Parameters

<div class="lesson-section">

<div class="question">24. What does inout allow?
<details><summary>Show Solution</summary>
Direct modification of caller variables.
</details></div>

<div class="question">25. Why is & required?
<details><summary>Show Solution</summary>
To indicate mutation of external state.
</details></div>

<div class="question">26. What is shadowing a parameter?
<details><summary>Show Solution</summary>
Creating a local copy of a parameter.
</details></div>

</div>

---

## Concept Review

<div class="lesson-section">

<div class="question">27. Why are parameters constants?
<details><summary>Show Solution</summary>
To prevent unintended side effects.
</details></div>

<div class="question">28. Difference between local and inout modification?
<details><summary>Show Solution</summary>
Local changes are temporary; inout affects caller state.
</details></div>

<div class="question">29. Why is inout powerful but risky?
<details><summary>Show Solution</summary>
It introduces side effects that are harder to track.
</details></div>

</div>