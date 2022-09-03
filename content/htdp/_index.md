---
title: "Htdp"
date: 2022-08-14T10:18:54-07:00
draft: false
toc: true
tableOfContents:
    endLevel: 2
    ordered: true
    startLevel: 1
hw: Homework
---



{{<toc>}}

Please complete the readings or watch the videos before class.
This will allow us to focus on problem solving during the labs.


## Resources

- [Design Recipes Summary](https://courses.edx.org/courses/course-v1:UBCx+SPD1x+2T2016/77860a93562d40bda45e452ea064998b/)
- [Cheat Sheet](https://s3.amazonaws.com/edx-course-spdx-kiczales/HTC/recipe-checklist.pdf)
- [Light Videos](http://www.cs.utah.edu/~mflatt/htdp-lite/)

- [Typing Practice](https://www.keybr.com/) 

Learning how to type accurately
without looking at the keys will make your life a lot easier when programming. You might
also consider learning an alternative keyboard layout such as [Dvorak](https://en.wikipedia.org/wiki/Dvorak_keyboard_layout) if you already developed bad habits in
QWERTY. I
- [Alcumus](https://artofproblemsolving.com/alcumus) 
  
Great resource for improving your math skills. I recommend solving all of the 
pre-algebra problems before moving onto algebra. This will give you a better foundation. In my opinion this website is much better then Khan Academy for learning mathematics. 

This page has links to very shorty videos that parallel many of the topics below.

#### Conventions used on this page
\*  :: material is supplementary  

# I Fixed-Size Data

## Arithmetic
{{<estimate 5>}}

{{<header_ass>}}
- Read and code along with the [Prologue](https://htdp.org/2022-8-7/Book/part_prologue.html)
- {{< download "practice/00-arithmetic.zip" "Arithmetic Practice">}}

{{<header_read>}}
- [1 Arithmetic](https://htdp.org/2022-8-7/Book/part_one.html#%28part._ch~3abasic-arithmetic%29) 
- [2.1 Function Basics](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3afuncs%29) 
- [2.2 Computing with Functions](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3acomputing%29)
- [2.4 Global Constants](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3aglobal%29)
- [2.5 Batch Programs vs World Programs](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3aprogs%29) 
- Simple animations with [animate](https://docs.racket-lang.org/teachpack/2htdpuniverse.html#%28def._%28%28lib._2htdp%2Funiverse..rkt%29._animate%29%29) \*
1. [programs in the world](https://www.youtube.com/watch?v=dJbpHukiQ7I&t=1s&ab_channel=SystematicProgramDesign)\*
2. [Expressions](https://www.youtube.com/watch?v=6wABnrIFZmQ&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=4&ab_channel=SystematicProgramDesign)
3. [How racket evaluates expressions](https://www.youtube.com/watch?v=4wUiCxxCc68&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=5&ab_channel=SystematicProgramDesign)
4. [Strings and images](https://www.youtube.com/watch?v=wYyKnPA5fSI&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=6&ab_channel=SystematicProgramDesign)
5. [Define constants](https://www.youtube.com/watch?v=KoaAUyyDl4A&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=7&ab_channel=SystematicProgramDesign)
6. [Functions](https://www.youtube.com/watch?v=bAv-q4oXVd4&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=9&ab_channel=SystematicProgramDesign)
7. [Booleans](https://www.youtube.com/watch?v=G8zM3j4mg_Y&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=10&ab_channel=SystematicProgramDesign)
8. [How to use Racket's steppep](https://www.youtube.com/watch?v=TjrEjhnW6oc&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=11&ab_channel=SystematicProgramDesign)
9.  [Looking stuff up in the documentation](https://www.youtube.com/watch?v=PCSlKWX1jlQ&list=PL6NenTZG6Krqu5RRQi3TUGc605rrGGGWw&index=12&ab_channel=SystematicProgramDesign)


## How to Design Functions
{{<estimate 6-7>}}

{{<header_ass>}}
- {{< download "practice/01-htdf.zip" "Function Practice">}}
- [Lab Duck Animation](hw/hw1.html)

{{<header_read>}}

- [3.4 Wish lists](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3adesign%29)
- [3.5 Testing](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3atesting%29)
1. [Fast Design Recipe](https://www.youtube.com/watch?v=AyFI91za4P0&list=PL6NenTZG6KroMpbQDFNmv6YuydU1DTklw&index=2&ab_channel=SystematicProgramDesign)
2. [Slow Design Recipe](https://www.youtube.com/watch?v=q6GwIWwKowU&list=PL6NenTZG6KroMpbQDFNmv6YuydU1DTklw&index=3&ab_channel=SystematicProgramDesign)
3. [Function Design Recipe Example: Yell](https://www.youtube.com/watch?v=v7gGyazV5W8&list=PL6NenTZG6KroMpbQDFNmv6YuydU1DTklw&index=4&ab_channel=SystematicProgramDesign)
4. [Function Design Recipe Example: Image Area](https://www.youtube.com/watch?v=atp8QPRsPgE&list=PL6NenTZG6KroMpbQDFNmv6YuydU1DTklw&index=4&ab_channel=SystematicProgramDesign)
5. [Function Design Recipe Example: Tall](https://www.youtube.com/watch?v=RR8Q_Hd6t4U&list=PL6NenTZG6KroMpbQDFNmv6YuydU1DTklw&index=7&ab_channel=SystematicProgramDesign)

## How to Design Data
{{<estimate 6-8>}}

{{<header_ass>}}
- {{< download "practice/02-htdd.zip" "Data Definitions Practice">}}
- *Lab TBD*

{{<header_read>}}
- [3.1 Designing Functions](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3adesign-func%29)
- [4.1 Programming with Conditionals](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3acond%29)
- [4.2 Computing Conditionally](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3aworks%29)
- [4.3 Enumerations](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3aenums%29)
- [4.6 Itemizations](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3adesign-itemization%29)
- [4.7 Finite State Machines](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3aworlds-more%29) \*
1. [Cond](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3aworlds-more%29)
2. [Data Definitions](https://www.youtube.com/watch?v=DG7LSGvqPYg&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=3&ab_channel=SystematicProgramDesign)
3. [Atomic Non Distinct Data Definitions](https://www.youtube.com/watch?v=kIduaD7ccg0&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=3&ab_channel=SystematicProgramDesign)
4. [Non Primitive Data](https://www.youtube.com/watch?v=yMuZjvzaczA&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=5&ab_channel=SystematicProgramDesign)
5. [Structure of Data Orthogonality](https://www.youtube.com/watch?v=GTqbCPsofkQ&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=6&ab_channel=SystematicProgramDesign) \*
6. [Interval](https://www.youtube.com/watch?v=aPxi3XWm0fQ&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=7&ab_channel=SystematicProgramDesign)
7. [Enumeration](https://www.youtube.com/watch?v=dcdgMEH55mM&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=8&ab_channel=SystematicProgramDesign)
8. [Itemization](https://www.youtube.com/watch?v=VWICZSxaeZw&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=9&ab_channel=SystematicProgramDesign)
9. [How to design functions with Intervals](https://www.youtube.com/watch?v=Peq6IgKFZBc&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=10&ab_channel=SystematicProgramDesign)
10. [How to design functions with Enumeration](https://www.youtube.com/watch?v=700ReRUYhhc&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=10&ab_channel=SystematicProgramDesign)
11. [How to design functions with Itemizations](https://www.youtube.com/watch?v=Ljf1MQeDITg&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=12&ab_channel=SystematicProgramDesign)
12. [Structure of Information Flow](https://www.youtube.com/watch?v=AWyOzz4AO2U&list=PL6NenTZG6KroGuvVv1wvU2wgq9tG45la1&index=13&ab_channel=SystematicProgramDesign)


## How to Design Worlds
{{<estimate 3-6>}}
{{<header_ass>}}
- {{< download "practice/03-hdw.zip" "World Practice">}}
- [Lab Ducks in the World](hw/hw2.html)
  
{{<header_read>}}
- [3.3 Domain Knowledge](https://htdp.org/2022-8-7/Book/part_one.html#%28part._sec~3adomain%29) (You can skip the part about batch programs)
- [3.6 Designing World Programs](https://htdp.org/2022-2-9/Book/part_one.html#%28part._.D.K._sec~3adesign-world%29)

*These videos are longer than usual*
1. [World Programs](https://www.youtube.com/watch?v=Zd-jXZArWa8&list=PL6NenTZG6KrqMkX3XpyVLbhwThXdUID_t&index=2&ab_channel=SystematicProgramDesign)
2. [Big bang mechanism](https://www.youtube.com/watch?v=Az4ARYVJNTY&list=PL6NenTZG6KrqMkX3XpyVLbhwThXdUID_t&index=3&ab_channel=SystematicProgramDesign)
3. [Domain analysis](https://www.youtube.com/watch?v=Y85Pcp_E0TU&list=PL6NenTZG6KrqMkX3XpyVLbhwThXdUID_t&index=4&ab_channel=SystematicProgramDesign)
4. [Program through the main function](https://www.youtube.com/watch?v=W6jxmA4kJjw&list=PL6NenTZG6KrqMkX3XpyVLbhwThXdUID_t&index=5)
5. [Working through the wish list](https://www.youtube.com/watch?v=hxz3lo0m4gk&list=PL6NenTZG6KrqMkX3XpyVLbhwThXdUID_t&index=6&ab_channel=SystematicProgramDesign)
6. [Improving a World Program](https://www.youtube.com/watch?v=Qn6ULPxLGpQ&list=PL6NenTZG6KrqMkX3XpyVLbhwThXdUID_t&index=7)
7. [Improving a World Program Even More](https://www.youtube.com/watch?v=d1AXrJpP9fQ&list=PL6NenTZG6KrqMkX3XpyVLbhwThXdUID_t&index=7&ab_channel=SystematicProgramDesign)
  
## Compound Data
{{<estimate 5-7>}}
{{<header_ass>}}
- {{< download "practice/04-compound.zip" "Compound Practice">}}
- [Lab Part 1 Graphical Editor](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3aedit1%29)
- [Lab Part 2 Virtual Pet World](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3azoo1%29)

{{<header_read>}}
- [5.1-5.3 Posns](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3aposn-structures%29)
- [5.4-5.7 Define,Compute and Program with Structs](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3astructures%29)
- [5.7 The universe of data](https://htdp.org/2022-2-9/Book/part_one.html#%28part._data-uni._sec~3adata-uni%29) \*
- [5.8 Design with structs](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3adesignstructs%29)
- [5.9 World programs with structs](https://htdp.org/2022-2-9/Book/part_one.html#%28part._sec~3aworld-structs%29)
1. [Define structs](https://www.youtube.com/watch?v=k-Bvyh65Vy4&list=PL6NenTZG6KrpA-ww35EwcaxY-tgh82TAh&ab_channel=SystematicProgramDesign)
2. [Compound data definitions](https://www.youtube.com/watch?v=ieSkX9RdobM&list=PL6NenTZG6KrpA-ww35EwcaxY-tgh82TAh&index=3&ab_channel=SystematicProgramDesign)
3. [Compound data and world programs](https://www.youtube.com/watch?v=hBuDgdIRhYo&list=PL6NenTZG6KrpA-ww35EwcaxY-tgh82TAh&index=4&ab_channel=SystematicProgramDesign) *22 minutes*




*Matthew's Todo List*
- Add lab for data definitions
- Add material for these sections
- II Arbitrarily Large Data
- III Abstraction
- IV Intertwined Data
- V Generative Recursion
- VI Accumulators -->
