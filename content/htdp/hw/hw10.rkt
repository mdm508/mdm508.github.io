#lang at-exp s-exp "hw.rkt"

@10 @'(11 11 2011 "11:11am")

@,p{Start with @tt{@a["eval.zip"]{eval.zip}}.}

@,part[1]{Absolute Value}

@,p{Add support for an @tt{abs} expression, which has a single sub-expression
    for its argument and produces the absolute value of its argument's
    value.}

@,p{For example, if you call your new class @tt{Abs}, then @tt{new
    Abs(new Num(-5.0)).eval()} should produce @tt{5.0}.}


@,part[2]{Functions}

@,p{Like parts 4 and 5 of @a["hw7.html"]{HW 7}, add function definitions and
    function-call expressions to the evaluator. You will need to change the
    @tt{eval} method in @tt{IExpr} to accept a list of definitions as an argument.}

@,p{The @i{factorial} function is a traditional toy example to demostrate
    an evaluator. Make sure your function tests include calling the
    factorial function on @tt{5.0} (like the last example shown for 
    part 5 of @a["hw7.html"]{HW 7}).}
