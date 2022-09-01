#lang at-exp s-exp "hw.rkt"

@7 @'(10 21 2011)

@,p{Start with @tt{@a["mini-dr.rkt"]{mini-dr.rkt}}, which needs @tt{@a["string.rkt"]{string.rkt}}
    in the same directory.}


@,part[1]{Add Multiplication}

@,p{The initial Mini DrRacket works only with number values, plus, and
minus. Add times:}

@,pre{
  (check-expect (eval-expr '(* 2 3)) 6)
}


@,part[2]{Add If0}

@,p{To suport conditionals, we could add booleans to the set of
expressions and values. It's easier, however, to add an @tt{if0} form that
looks for @tt{0} instead of @tt{true}.}

@,p{Add an @tt{if0} form to the @tt{expr} datatype so that the
following examples are allowed, and then adjust @tt{eval-expr} to make
the examples work:}

@,pre{
  (check-expect (eval-expr '(if0 0 2 3)) 2)
  (check-expect (eval-expr '(if0 1 2 3)) 3)
  (check-expect (eval-expr '(if0 (- 8 8) 2 3)) 2)
}


@,part[3]{Add Variables}

@,p{Extend the set of expressions to include variables, where a
variable is represented by a symbol. For now, using a variable simply
triggers an error by using the @tt{error} function. You can test for an 
error using @tt{check-error}.}

@,pre{
  (check-error (eval-expr 'x))
  (check-error (eval-expr '(+ 1 x)))
}

@,p{Hint: It's eaisest to add variables to you data definition
right after numbers, so that later tests for the other forms can assume
that the expression is represented by a list.}


@,part[4]{Substitution}

@,p{Create a new function (that is not connected to the GUI, for now)
called @tt{subst}. The @tt{subst} function takes an expression, a
symbol (representing a variable), and a number. It returns an
expression like the given one, except that every use of the given
variable is replaced by the given number.}

@,pre{
 (check-expect (subst '(+ 1 x) 'x 3) '(+ 1 3))
 (check-expect (subst '(+ 1 y) 'x 3) '(+ 1 y))
 (check-expect (subst '(if0 (+ 1 y) x y) 'y 10) '(if0 (+ 1 10) x 10))
}

@,p{Note that you'll need more examples/tests for @tt{subst} than the
ones given above.}



@,part[5]{Functions}

@,p{A function of one argument always has the form}

@,pre{(define (@i{name} @i{arg}) @i{expr})}

@,p{which suggests the data defintion}

@,pre{
 ;; A func is
 ;;   (list 'define (list sym sym) expr)
}

@,p{Implement the function @tt{lookup}, which takes a list of
@tt{func}s and a symbol. The @tt{lookup} function returns a @tt{func}
whose name matches the given symbol. If no matching function exists,
@tt{lookup} should report an error.}


@,part[5]{Function Calls}

@,p{Extend the definition of @tt{expr} to including function calls:}

@,pre{
 ;; An expr is either
 ;;  ....
 ;;  - (list sym expr)
}

@,p{Assume that a function name is never @tt{+}, @tt{-}, or @tt{if0},
so that this new case in the definition of @tt{expr} does not overlap
with the other cases.}

@,p{Adjust your @tt{eval-expr} function to accept an expression and a
list of @tt{func}s:}

@pre{;; eval-expr : expr list-of-funcs -> num}

@,p{For now, you can adjust the GUI to pass @tt{empty} as the list of
function definitions.}

@,p{The list of @tt{func}s for @tt{eval-expr} is mostly along for the
ride, but to implement the case of function calls, @tt{eval-expr} will
need to use @tt{lookup} to find a function in the list of @tt{func}s,
and it will need to use @tt{subst} to put the argument value in place
of the function argument in the body of the found function.}

@,pre{
 (check-expect (eval-expr '(f 1) (list '(define (f x) (+ x 2))))
               3)
 (check-expect (eval-expr '(g (+ 3 4)) (list '(define (f x) (+ x 2))
                                             '(define (g y) (f (- y 3)))))
               6)
 (check-expect (eval-expr '(fact 5) (list '(define (fact x)
                                             (if0 x
                                                  1
                                                  (* x (fact (- x 1)))))))
               120)
}


@,part[6]{Definitions in the GUI}

@,p{Add a new field to the GUI before the expr field. The new field
accepts a sequence of definitions. A user of the GUI will have to type
all the definitions on a single line, which is annoying, but that
could be easily fixed with a slightly fancier GUI library. Your GUI will
look like this:}

@,p{@png["mini-dr-defns"]}

@,p{Use @tt{many-from-string} to convert the content of the
definitions text field to a list of @tt{func}s, then pass that list as
the second argument to @tt{eval-expr}.}


@,part[7]{Extra Credit: Anonymous Functions}

@,p{Add @tt{lambda} forms (with a single argument) to the set of expressions.
A @tt{lambda} form is a value:}

@,pre{
  (check-expect (eval-expr '(lambda (x) (+ x 1)) empty)
                '(lambda (x) (+ x 1)))
}

@,p{Generalize function calls to allow an arbitrary
expression (instead of just a function name) as the function to
call:}

@,pre{
  (check-expect (eval-expr '((lambda (x) (+ x 1)) 8) empty)
                9)
}

@,p{Hint: For the cases of @tt{expr}, it's easier to use @tt{equal?} at this point
instead of @tt{symbol=?}, because the first sub-expression in a function call
is not always represented as a symbol.}

@,p{You will also need to adjust the way that @tt{eval-expr} handles
variables: instead of reporting an error, the value of a variable
should be a function from the list of @tt{func}s given to
@tt{eval-expr} (if there is a function with a matching name), but
converted to @tt{lambda} form:}

@,pre{
  (check-expect (eval-expr 'f (list '(define (f x) (+ x 1))))
                '(lambda (x) (+ x 1)))
}

@,p{Finally, adding @tt{lambda} complicates @tt{subst}. If @tt{subst} is
    given @tt{'(lambda (x) (+ x 1))} and asked to replace every @tt{'x}
    with @tt{7}, then it should leave the @tt{lambda} form alone, because the
    @tt{x} for the @tt{lambda} argument must be a different @tt{x} than the one
    that is being replaced. More generally,
    @tt{subst} should leave a @tt{lambda} alone when the name of the @tt{lambda}'s
    argument matches the name that is being replaced.}

@,pre[#:indent 2]{
  (check-expect (subst '(lambda (x) x) 'x 10) '(lambda (x) x))
  (check-expect (subst '(lambda (y) x) 'x 10) '(lambda (y) 10))
}

@,p{Adding @tt{lambda} to your interpreter makes it extremely powerful, although that
    may not be immediately apparent. It turns out, for example, that you can
    encode lists using @tt{lambda} without explicitly adding support for lists to
    your interpreter. Below is a stress test for your interpreter that defines
    and encoding of lists and uses it to sum the numbers in a list containing
    8 and 17. (The calls to @tt{cons} and other functions look funny, because we have
    only single-argument functions, so we curry a two-argument function to make it
    a function of one argument that returns a function for the second argument.)}

@,pre{
   (define defns
     (list
      ;; Encode `cons', `first', `rest', `empty', and `empty?'
      ;; using functions:
      '(define (pair a) (lambda (b) (lambda (p) ((p a) b))))
      '(define (fst v) (v (lambda (a) (lambda (b) a))))
      '(define (snd v) (v (lambda (a) (lambda (b) b))))
      '(define (empty p) ((p 0) 0))
      '(define (cons a) (lambda (b) ((pair 1) ((pair a) b))))
      '(define (empty? x) (fst x))
      '(define (cons? x) (- (fst x) 1))
      '(define (first c) (fst (snd c)))
      '(define (rest c) (snd (snd c)))

      ;; Implement `sum' using `empty?', `first', and `rest':
      '(define (sum l)
         (if0 (empty? l)
              0
              (+ (first l) (sum (rest l)))))))

   ;; Call the `sum' function:
   (check-expect (eval-expr '(sum ((cons 8) ((cons 17) empty)))
                            defns)
                 25)
}
