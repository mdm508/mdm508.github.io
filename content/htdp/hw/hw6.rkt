#lang at-exp s-exp "hw.rkt"

@6 @'(10 7 2011)

@,part[1]{Using Map}

@,p{Use @tt{map} to implement @tt{numbers->strings}, which takes
    a list of numbers and produces a list of strings, where each
    number is converted to its string form.
    For example, @tt{(numbers->strings '(1 2 3))} should produce @tt{'("1" "2" "3")}.}

@,p{Your handin must not contain any definitions except @tt{numbers->strings}
    before the tests for @tt{numbers->string}.}

@,p{Hint: This function is easy because the @tt{number->string} function (which
    converts a single number to a string) is built in.}


@,part[2]{Using Map and Local}

@,p{Use @tt{map} to implement @tt{percents->strings}, which takes
    a list of numbers and produces a list of strings, where each
    number is divided by 100 and converted to its string form.
    For example, @tt{(percents->strings '(10 20 300))} should produce @tt{'("1/10" "1/5" "3")}.}

@,p{Your handin must not contain any non-@tt{local} definitions except 
    @tt{numbers->strings} and @tt{percents->strings}
    before the tests for @tt{percents->string}.}

@,p{Hint: As the part name suggests, you'll need to use @tt{local} or @tt{lambda}.}


@,part[3]{Parallel Number Lists}

@,p{During the @a["lec9.rkt"]{September 15 lecture}, we implemented a 
   @tt{parallel-sum} function.}

@,p{Implement @tt{parallel-product}, which takes two lists of numbers
    and returns a list of multiplied numbers. For example,
    @tt{(parallel-product '(0 1 2) '(3 4 5))} should produce @tt{'(0 4 10)}.}

@,p{Implement @tt{parallel-product} by abstracting @tt{parallel-sum}
    to define @tt{parallel-map}. Include @tt{parallel-product}, @tt{parallel-sum},
    and @tt{parallel-map} in your handin. The @tt{parallel-product} and @tt{parallel-sum}
    functions must be implemented using @tt{parallel-map}.}

@,p{You solution must @i{not} use the built-in @tt{map} function.}


@,part[4]{Parallel-List Contract}

@,p{Adjust the contract of @tt{parallel-map} so that the first and second
    lists can contain any kind of value --- and the second list
    might contain a different kind of value than the first.}


@,part[5]{Parallel Lists of Different Types}

@,p{Implement the function @tt{flip-some} which takes a 
    list of @tt{posn}s and a list of @tt{bool}s, and which 
    produces a list of @tt{posn}s. The result list of @tt{posn}s
    should be the same as the given list, except that wherever the corresponding boolean is
    @tt{true} in the list of @tt{bool}s, the result @tt{posn} is flipped
    (see @tt{@a["lec8.rkt"]{flip-posns}}).}

@,p{For example, @tt{(flip-some (list (make-posn 1 2) (make-posn 3 4)) (list true false))}
   should produce @tt{(list (make-posn 2 1) (make-posn 3 4))}.}

@,p{Your implementation must use your @tt{parallel-map}.}


@,part[6]{Parallel Lists and Operators}

@,p{Implement @tt{choose} which takes two lists of anything (but the same kind of thing in both lists)
    and a comparison operator. The result is a list containing some elements from the 
    first list and some elements from the second list, depending on the comparison result.
    When the comparison is true, the result uses the first list's item, and when the result is false,
    it uses the second lists's item.}

@,p{For example, @tt{(choose '(1 2 3) '(3 2 1) <)} should produce @tt{'(1 2 1)},
    and  @tt{(choose '(1 2 3) '(3 2 1) >)} should produce @tt{'(3 2 3)}. Finally,}

@,pre{
     (local [(define (first-is-apple? a b)
               (symbol=? a 'apple))]
       (choose '(apple banana) '(cherry cherry) first-is-apple?))
}

@,p{should produce @tt{'(apple cherry)}.}

@p{Your implementation must use your @tt{parallel-map}. Hint: You will also need
   @tt{local} or @tt{lambda}.}


