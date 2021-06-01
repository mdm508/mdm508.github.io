---
title: 01 How to design functions
description:
toc: true
authors: []
date: 2021-05-25T16:39:29-07:00
lastmod: 2021-05-25T16:39:29-07:00
draft: false
weight: 1
---


## What is a design recipe?
- Creating a function involves a series of several steps
- The design recipe is a systematic approach to designing functions.
  
## Steps in the design recipe

### Create the contract and stub
#### Contract
Every function will take some arguments. Those arguments have some type. 
When you make a function one of the first things to do is to state
what types of input can this function handle. 

Additionally, every function will output a value, and that value has a type. So 
you should also say what type of output the function produces.

We can specify both the types of the input and output in the **contract**.

<pre>
Number Number -> Number
</pre>

#### Stub
- Every function must have a name
- Functions also need to name the parameters.
- In the stub we specfify the name of the function as well as the name of each parameter

<pre>
fun add(a, m):
...
end
</pre>

### Turn examples into test cases

- test cases help us have more confidence that our function is doing what we want it to do
- turning examples into test cases help us to think of different strategies for how to solve the problem

When you create a test case avoid hard coding the answer. You have to somehow take the input and turn it into the desired output using some sort of transformation on the input.

```
check:
   add(3,2) is 6
end
```

This is an example of hardcoding a test case. It doesn't
how to transform 3 and 2 into 6.

A better test case shows you how to do that transformation.

'''
check:
    add(3,2) is 3 + 2
end
'''

### Apply template if appopriate

- Depending on what the input types are you may or may not use a template

In this example we are using a template because Flavor is an enum
and we know that enums have multiple cases depending on the value of 
the input.

```
Flavor is one of
- "vanilla"
- "chocolate"

Flavor ->
fun flavor(f):
  if f == "vanilla":
     ...
  else f == "chocolate":
     ...
  else:
     ...
end
```


### Write the body
- Looking back at your template and your examples it should be pretty easy to write the body of the function


## Test it

Make sure that you actually passed all the test cases.