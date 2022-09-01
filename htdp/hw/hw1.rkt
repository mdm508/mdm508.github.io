#lang at-exp s-exp "hw.rkt"

@1 @'(8 12 16)

@,p{If you drop a cartoon duck in a frictionless cartoon
environment, it will move ever more quickly toward the cartoon ground
with constant acceleration---until it hits the ground, at which point
it will sqaush by an amount inversely related to the duck's speed.}

@,p{Assume that the duck starts at rest and that acceleration is 200
pixels per second per second.}


@,part[1]{Velocity}

@,p{Implement the function @tt{velocity}, which takes a number
representing an elapsed time in seconds and returns a number
representing a dropped duck's velocity in pixels per second. Assume
that the duck has not hit the ground by the given time. Recall that
velocity is acceleration multiplied by time.}

@,p{For example, @tt{(velocity 1)} should produce @tt{200}.}


@,part[2]{Distance}

@,p{Implement the function @tt{distance}, which takes a number
representing an elapsed time in seconds and returns the number of
pixels that a dropped duck has moved. Assume that the duck has not hit
the ground by the given time.  Recall that distance is one-half of
acceleration multiplied by time squared.}

@,p{For example, @tt{(distance 1)} should produce @tt{100}.}


@,part[3]{Time to Impact}

@,p{Implement the function @tt{time}, which takes a number representing
a distance to the ground in pixels (from the duck's starting point) and returns a number representing
an elapsed time in seconds required for the duck to hit the
ground. Assume that the duck starts more than the given distance from
the ground. Recall that time is the square root of twice distance
divided by acceleration.}

@,p{For example, @tt{(time 100)} should produce @tt{1}.}


@,part[4]{Squashing Ratio}

@,p{Implement the function @tt{squash}, which takes a number
representing a velocity in pixels per second and returns the ratio of
a duck's squashed size to its original size when after it hits the
ground with the given velocity. The ratio is determined as follows:
divide the velocity by 400 pixels per second, add one to that result,
and then take the multiplicative inverse (i.e., divide 1 by one more
than the velocity divided by 400).}

@,p{For example, @tt{(squash 400)} should produce @tt{1/2}.}


@,part[5]{Squashing Ratio During a Fall}

@,p{A falling cartoon duck stays its normal shape until it hits the
ground. Implement the function @tt{current-squash}, which takes two
numbers: an elapsed time in seconds and the distance to the ground in
pixels from the duck's starting point. Compute the duck's squashing
ratio at the given time. The ratio will be @tt{1} if the duck has not
yet reached the ground. If the duck has hit the ground by the given
time, then the ratio is determined by the velocity of the duck at the
time when it hit the ground.}

@,p{For example, @tt{(current-squash 2 400)} should produce @tt{1/2}.}

@,p{Don't forget to use functions that you've already written if they
can help.}



@,part[6]{Making a Scene with a Duck}

@,p{Implement a @tt{place-duck} function that takes an image and a
number to produce a scene image. The given image represents a duck,
and the number represents the number of pixels that the duck has
fallen; specifically, the bottom edge of the duck image should the
given number of pixels from the result scene's top. The duck should be
centered hoziontally in the scene, and the scene should be 150 pixels
wide and 400 pixels tall.}

@,p{In addition to @tt{(require 2htdp/image)}, use @tt{(require
2htdp/universe)} to get the @tt{empty-scene} and @tt{place-image}
functions. Use @tt{empty-scene} to create the 150-by-400 scene, and
use @tt{place-image} to add the duck in the scene. Note that the
@tt{place-image} function takes numbers to position the center of the
duck, so if you want to put a duck's bottom edge at position @i{y} in
a scene, then subtract half of the duck image's height from @i{y} to
get the third argument for @tt{place-image}.}

@,p{Here's a duck to use: @png["cartoon-duck"]}

@,p{Writing test cases for functions that produce images is difficult
at best, since it's difficult to produce the right image by hand. You
can skip tests for @tt{place-duck}.}


@,part[7]{Seconds to Scene}

@,p{Implement a @tt{duck-scene/seconds} function that takes a number
representing an elapsed time in seconds and returns an image. The
returned image should be one produced by @tt{place-duck} with the bottom
of the duck down from the top of the scene by as many pixels as
@tt{distance} produces for the elapsed time---but no further down than
the bottom of the scene. Furthermore, if the duck has reached the
bottom of the scene, then it should be suitably squashed.}

@,p{The @tt{scale/xy} function from @tt{2htdp/image} can be used for
squashing a duck. Use @tt{1} for the first argument and a squashing
ratio for the second argument.}

@,p{Although generating images by hand would be difficult for
testing, you can at least check that @tt{(duck-scene/seconds 1)}
produces the same result as @tt{(place-duck duck 100)}, and check that
@tt{(duck-scene/seconds 10)} produces the same result as
@tt{(place-duck (scale/xy 1 1/2 duck) 400)}.}


@,part[8]{Drop a Duck}

@,p{The @tt{animate} form of @tt{2htdp/universe} creates a kind of
movie given a function from a number to a scene. The function receives
a number in @i{ticks} instead of seconds, where each tick is 1/28 of a
second.}

@,p{Implement a function @tt{duck-scene} that is like
@tt{duck-scene/seconds}, but that takes a number in ticks instead of
seconds. (Your @tt{duck-scene} function should mostly just call your
@tt{duck-scene/seconds} function.)}

@,p{In DrRacket's interactions window (@i{not} your program), run the
movie with}

@,pre{
 (animate duck-scene)
}
