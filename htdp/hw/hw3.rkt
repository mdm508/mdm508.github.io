#lang at-exp s-exp "hw.rkt"

@3 @'(9 16 2011)

@,p{The next step for Mildly Annoyed Ducks is to have a list of bricks for
    a flying duck to destroy. We'll ease into that problem, however, with a
    set of warm-up exercises using just lists of numbers:}

@,pre[#:indent 2]{
  ;; A list-of-number is either
  ;;   - empty
  ;;   - (cons string list-of-number)
}

@,p{The list of numbers represents vertical locations for bricks that
are each 30 pixels high. For example, @tt{(cons 10 (cons 70 (cons 40
empty)))} represents three bricks that form a solid wall spanning
position 10 through 100.}


@,part[1]{Wall-Height}

@,p{Write the function @tt{wall-height}, which takes a list of numbers
representing bricks and returns the maximum position covered by the
wall's bricks (i.e., 30 more than the maximum number in the
list). Assume that all the bricks have a zero or positive location, and
if the wall has no bricks, the result should be 0.
You'll probably want to use the @tt{max} function.}

@,p{For example, @tt{(wall-height (cons 10 (cons 70 (cons 40
empty))))} should produce @tt{100}.}


@,part[2]{Aligned-Bricks?}

@,p{Write the function @tt{aligned-bricks?}, which takes a list of
numbers and returns @tt{true} if the lists contains only integers,
@tt{false} otherwise. You'll probably want to use the @tt{integer?}
function.}

@,p{For example, @tt{(aligned-bricks? (cons 10 (cons 70 (cons 40
empty)))} should produce @tt{true}, while
@tt{(aligned-bricks? (cons 10.2 empty))} should produce @tt{false}.}

@,p{Note that every number in the empty list is an integer, since
there are no numbers in the list that have a fractional part.}


@,part[3]{Align-Bricks}

@,p{Write the function @tt{align-bricks}, which takes a list of
numbers and returns a list of the same length, but where every number
in the list is rounded to an integer. You'll probably want to use the
@tt{round} function.}

@,p{For example, @tt{(align-bricks (cons 10.1 (cons 70 (cons 39.6
empty))))} should produce @tt{(cons 10 (cons 70 (cons 40 empty)))}.}


@,part[4]{Search-and-Delete}

@,p{Write the function @tt{search-and-delete}, which takes a number
and a list of numbers. The @tt{search-and-delete} function returns a
list like the one that it is given, except that any brick that touches
the given position (i.e., a number that is @tt{<=} the given one and
whose sum with 30 is @tt{>=} the given one) is removed from the list.}

@,p{For example,
@tt{(search-and-delete 40 (cons 10 (cons 70 (cons 40
empty))))} should produce @tt{(cons 70 empty)}.}


@,part[5]{Insert}

@,p{Write the function @tt{insert}, which takes a number to insert, a
position (as a number) to insert the new number, and a list of numbers. The @tt{insert}
function returns a list like the one that it is given, except that the
number to insert is added after the number of elements indicated by
the position. If the position is beyond the end of the list (i.e., it
is more than the number of number in the list), then add the new
number to the end of the list.}

@,p{For example, @tt{(insert 40 5 empty)} should produce
@tt{(cons 40 empty)}, and
@tt{(insert 40 2 (cons 10 (cons 70 (cons 100
empty))))} should produce @tt{(cons 10 (cons 70 (cons 40 (cons 100 empty))))}.}
