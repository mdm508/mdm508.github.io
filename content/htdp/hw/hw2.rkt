#lang at-exp s-exp "hw.rkt"

@2 @'(9 9 2011)

@,p{Now that we have compund data and variants, we can begin the
implementation of Mildy Annoyed Ducks (MAD).}

@,p{The game scene is 800 pixels
wide and 600 pixels high. The duck starts with its center 200 pixels
from the left edge of the scene and 400 pixels from the top. You should
give those constants names in your program, such as @tt{(define WIDTH 800)}.}

@,p{The
player clicks to drag the duck, which initially sits in an
invisible (for now) slingshot. A player clicks on the duck to start
dragging it---constrained by the limits of the slingshot---and releases
the click to fling the duck. The duck flies with an initial velocity
that is determined by the stretched slingshot, and the duck's velocity
is adjusted as it flies by gravity. When the duck leaves the screen, the game
resets to the initial position.}

@,p{In a future homework assignment, we'll add blocks to the game that
a player can destroy by flinging a duck.}

@,p{@i{This assignment looks long, but it's not as bad as it looks. A
full implementation with data definitions, contracts, functions,
tests, and generous spacing can be around 200 lines of code.}}


@,part[1]{Slingshot Angle and Distance}

@,p{The MAD slingshot stretches no more than 80 pixels from the duck's
initial position. For example, if the user drags 100 pixels to the
left of the duck's initial position, then the duck will move only 80
pixels to the left. More generally, dragging the duck moves the duck
from its starting position in a straight line toward the mouse click,
but it moves the duck no more than 80 pixels from the starting
position. If the user drags 100 pixels to the left and 100 pixels
above the starting position, then the duck will move only 80 times the
square root of 2 left and up.}

@,p{The slingshot constraint is easiest to implement by working in
terms of an angle and distance. Implement
@tt{slingshot-position-from-angle}, which takes two numbers and
returns a @tt{posn}. The arguments are an angle @i{a} (in radians
increasing counter-clockwise from due east) and a distance @i{d} from
the starting position (200, 400). The result point should be at the
given angle from the starting position. If @i{d} is 80 or less, the
result point is @i{d} pixels from the starting position; if @i{d} is
more than 80, the result point will be only 80 pixels from the
starting position.}

@,p{Recall that you can multiply @tt{(cos @i{a})} by the result point's
distance from the starting point to get its horizontal offset from the
starting point. You can multiple @tt{(sin @i{a})} by the distance to
get the vertical offset from the starting point.}

@,p{For example, @tt{(slingshot-position-from-angle pi 10)} should produce
approximately @tt{(make-posn (- START-X 10) START-Y)} if @tt{START-X}
and @tt{START-Y} correspond to the starting position. As another
example, @tt{(slingshot-position-from-angle (/ pi 4) 100)} should
produce @tt{(make-posn (+ START-X (/ 80 (sqrt 2))) (- START-Y (/
80 (sqrt 2))))}.}

@,p{Your tests will need to use @tt{check-within}, since calculations
involving @tt{pi}, @tt{cos}, or @tt{sin} are usually inexact. You should be
able to predict the results within @tt{0.01}.}


@,part[2]{Mouse to Slingshot Constraint}

@,p{A user click arrives from the window manager as a position, rather
than and angle and distance. Write the function
@tt{slingshot-position}, which takes two numbers and returns a
@tt{posn}. The two numbers represent the screen position where the
user clicks: number of pixels right from the scene's left edge, and
number of pixels down from the scene's top edge. The result of 
@tt{slingshot-position} is the duck's new location.}

@,p{Your @tt{slingshot-position} function should call
@tt{slingshort-position-from-angle} with a conversion of the input
@i{x} and @i{y} coordinates to an angle @i{a} and distance @i{d}. To
get the angle @i{a}, call @tt{atan} with two arguments: the difference
between @i{y} and the starting vertical position, and the difference
between @i{x} and the starting horizontal position. To get the
distance @i{d}, take the square root of the sum of the
differences. (The Racket name for the square-root function is
@tt{sqrt}.)}

@,p{For example, @tt{(slingshot-position (+ START-X 30) (+ START-Y
30))} should produce approximately @tt{(make-posn (+ START-X 30) (+
START-Y 30))}, since the input position is within the slingshot's
stretching ability. In contrast, @tt{(slingshot-position (- START-X
100) (- START-Y 100))} should produce

@pre{
              (make-posn (- START-X (/ SLINGSHOT-MAX (sqrt 2))) 
                         (- START-Y (/ SLINGSHOT-MAX (sqrt 2))))
}

assuming that @tt{SLINGSHOT-MAX} is 80, since the combination of 100
pixels in both direction is more than 80 pixels away from the starting
position.}



@,part[3]{Slingshot Scene}

@,p{Implement the function @tt{duck-at-posn-scene}, which takes a
@tt{posn} for the duck's position and returns a 800-by-600 scene.}

@,p{Here's the duck: @png["cartoon-duck"]}

@,p{You can skip tests for this function.}

@,p{The @tt{big-bang} form from @tt{2htdp/universe} lets you put your
slingshot computation and @tt{duck-as-posn-scene} pieces together.
You can try out the combination by @i{temporarily} adding the following lines to the
end of your program:}

@,pre{
 ;; mouse-slingshot : posn x y string -> posn
 (define (mouse-slingshot p x y e)
   (slingshot-position x y))

 (big-bang
  (make-posn START-X START-Y)
  [to-draw duck-at-posn-scene]
  [on-mouse mouse-slingshot])
}

@,p{The first argument to @tt{big-bang} is the state of a universe,
which in this universe is the duck's position. When @tt{big-bang}
wants to draw the universe, it calls the function provided with
@tt{to-draw} to convert the universe's state into a scene. When the
user clicks on the scene, @tt{big-bang} calls the function provided
with @tt{on-mouse} to adjust the universe state. The function for
@tt{on-mouse} gets the current state, the mouse X position, the mouse
Y position, and the mouse action. The @tt{mouse-slingshot} function
above ignores the current position @tt{p}, because it doesn't matter
for dragging the duck; only the mouse location matters. The
@tt{mouse-slingshot} function also ignores the event string @tt{e},
because it doesn't care (yet) where the user merely moved the mouse,
clicked a mouse button, or is dragged the mouse.}

@,p{When you run the @tt{big-bang} call, then the duck should follow 
your mouse but stay within an 80-pixel radius of its starting position.}


@,part[4]{Flinging a Duck}

@,p{Implement the function @tt{fling-duck}, which takes a position
and returns a @tt{duck}, where a @tt{duck} has a position and a velocity:}

@,pre{
 ;; A duck is
 ;;   (make-duck posn num num)
 (define-struct duck (loc dx dy))
}

@,p{The @tt{duck} produced by @tt{fling-duck} should have the given
position. Its horizontal velocity @tt{dx} (in pixels per second) should be four times the
difference between the given position's X-coodinate and
@tt{START-X}. Its vertical velocity @tt{dy} (in pixels per second) should be four times the
difference between the given position's Y-coordinate and @tt{START-Y}.}

@,p{For example, @tt{(fling-duck (make-posn (- START-X 10) (+ START-Y 30)))}
should produce @tt{(make-duck (make-posn (- START-X 10) (+ START-Y 30)) 40 -120)}.}


@,part[5]{Moving a Duck}

@,p{Implement the function @tt{step-duck}, which takes a number and a
@tt{duck}.  The number represents a fraction of a second, such as
@tt{1} for a full second or @tt{1/2} for half a second. The result
should be a duck that has moved
and accelerated due to gravity.}

@,p{The duck's position should change by its current velocity in each
direction as scaled by the given fraction of a second. The duck's
velocity in the X direction should stay unchanged (i.e., a
frictionless world), and its velocity in the Y direction should change
by 200 pixels/second per second.}

@,p{For example, @tt{(step-duck 1/2 (make-duck (make-posn 100 200) 10 -100))}
shoudl produce @tt{(make-duck (make-posn 105 150) 10 0))}.}

@,p{Now you can make your duck fly with @tt{big-bang}. @i{Temporarily} add the
following to your program to try it out:}

@,pre{
;; duck-tick : duck -> duck
(define (duck-tick d)
  (step-duck 1/28 d))
;; duck-scene : duck -> scene
(define (duck-scene d)
  (duck-at-posn-scene (duck-loc d)))
    
(big-bang
 (make-duck (make-posn (- START-X 10) (+ START-Y 30)) 320 -320)
 [to-draw duck-scene]
 [on-tick duck-tick])
}

@,p{In this case, the state of the universe is a duck (at a position and
with some velocity) instead of just a position. Also, when an @tt{on-tick}
function is given to @tt{big-bang}, the function is called 28 times a second, so
@tt{duck-tick} steps the duck by 1/28 second.}


@,part[6]{A Launch}

@,p{At any point in time, a duck launch is in one of three modes:}

@,ul{

 @li{Waiting for the user to click. In this mode, the duck is always
     at its starting position.}

 @li{Being dragged by the user. In this mode, the duck as a current
     position, but it hasn't been flung, so it doesn't yet have
     a velocity.}

 @li{Flying. The duck has a position and velocity.}

}

@,p{Based on this analysis, we define a @tt{launch} as follows:}

@,pre{
 ;; A launch is either
 ;;   - false
 ;;   - posn
 ;;   - duck
}

@,p{That is, we use @tt{false} to represent a waiting duck, a
@tt{posn} to represent a duck that is being dragged, and a @tt{duck}
to represent a flying duck.}

@,p{Implement the function @tt{launch-scene}, which takes a
@tt{launch} and produces a suitable scene image. For example,
@tt{(launch-scene false)} should produce the same image as
@tt{(duck-at-posn-scene (make-posn START-X START-Y))}.}


@,part[7]{Stepping a Launch}

@,p{When the @tt{big-bang} clock ticks, a waiting or dragging duck
stays where it is, but a flying duck moves and accelerates---but if it
moves off the screen, then it goes back to waiting mode. ``Off the
screen'' means that the duck's center is beyond the right or bottom of
the scene.}

@,p{Implement the function @tt{step-launch}, which takes a @tt{launch}
and produces a @tt{launch}. For example, @tt{(step-launch false)}
should produce @tt{false}, @tt{(step-launch (make-duck (make-posn 0 0)
10 10))} should produce the same result as @tt{(step-duck 1/28
(make-duck (make-posn 0 0) 10 10))}, while @tt{(step-launch (make-duck
(make-posn WIDTH HEIGHT) 1 1))} should produce @tt{false} since the
duck would move off the screen.}


@,part[8]{Controlling a Launch}

@,p{Implement the function @tt{mouse-launch}, which takes a
@tt{launch}, a number for the mouse's X position, a number for the
mouse's Y position, and a string that is either @tt{"button-down"},
@tt{"button-up"}, @tt{"drag"}, @tt{"move"}, @tt{"enter"}, or
@tt{"leave"}. The result should be a @tt{launch} according to the
following:}

@,ul{

 @li{For a waiting launch, if the string is @tt{"button-down"}, then
 the launch should switch to dragging mode at the position that
 @tt{slingshot-position} determines given the mouse X and Y numbers.
 If the string is anything else, the launch stays in waiting mode.}

 @li{For a dragging launch, if the string is @tt{"button-up"}, the
 launch should switch to flying mode with the position determined by
 @tt{slingshot-position} on the mouse position and the corresponding
 velocity as determined by @tt{fling-duck}. If the string is
 @tt{"drag"}, the launch should stay in dragging mode, but with the
 position suitably updated via @tt{slingshot-position}. If the string
 is anything else, the launch should stay as-is.}

 @li{For a flying launch, the mouse has no effect, so the launch stays
 as-is.}

}

@,p{At this point, you can put all the pieces together, where the
universe state is a launch that starts in waiting mode, and
@tt{launch-scene}, @tt{step-launch}, and @tt{mouse-launch} all work on
the universe:}

@,pre{
(big-bang
 false
 [to-draw launch-scene]
 [on-tick step-launch]
 [on-mouse mouse-launch])
}

@,p{If you're having fun, you might try some of the following MAD
extensions (optional; extra credit will be considered by the grader):}

@,ul{

 @li{When drawing the duck, rotate it according to its velocity. (Unfortunately,
     the @tt{rotate} function in Racket versions 5.1.2 and 5.1.3 is slow at rotation, so you might
     want the latest version if you try this; type ``racket nightly build''
     into a search engine.)}

 @li{While a duck is flying, handle a mouse click by boosting the
     duck's horizontal velocity---but only on the first click.  The
     best way to do this is with a new @tt{launch} variant for
     flying-and-boosted.}

 @li{When the duck reaches the right end of the screen, make it bounce
     back. When the duck hits the ground, make it stop there---perhaps
     squashed---and wait for one second before switching back to wait
     mode. The best way to do this is with a new @tt{launch} variant
     for stopped mode.}

}

     
