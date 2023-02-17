#lang at-exp s-exp "hw.rkt"

@4 @'(9 23 2011)

@,p{It's finally time to smash some blocks with your duck.  For this
assignment, start with either your @a["hw2.html"]{HW 2} code or start
with the @a["https://rains.cs.utah.edu:7979/servlets/status.ss"]{HW 2
solution}.  You won't have to modify any of your old program; just add
new functions to the end. You should use templates to implement functions,
but the templates need not be included in the work that you handin this time.}

@,p{The main data structure for this assignment is a @tt{block}, which
has a position and color.  The position refers to the location of the
block's top-left corner in the scene, and each block is 30 pixels wide
and 30 pixels high. The specific @tt{block} data definition is up to
you.}


@,p{If you'd like a peek at the result of this homework, executables
are available for @a["mad.zip"]{Windows} and @a["mad.dmg"]{Mac OS
X}. The executables were created from the instructor's solution using
``Create Executable'' in the ``Racket'' menu.}


@,part[1]{Generate Blocks}

@,p{Implement the function @tt{gen-blocks}, which takes three
arguments: a natural number @i{n}, a number @i{x}, a number @i{y}, and
a string @i{col}. The @tt{gen-blocks} function should produce a list
of @i{n} blocks with color @i{col}, where the last block (for
@i{n}@char->integer[#\≤]1) is positioned @i{x} pixels from the left edge of the scene
and @i{y} pixels down, the next-to-last one (for @i{n}@char->integer[#\≥]2) is also @i{x} pixels
from the left edge but @i{y}+30 pixels down, and so on---forming a
solid vertical wall of @i{n} blocks. Alternatively, your @tt{gen-blocks} can produce
the list in the reverse order; either order is ok.}


@,part[2]{Removing Blocks}

@,p{Implement the function @tt{remove-blocks}, which takes a list of
@tt{block}s and a @tt{posn}. The result should be a list of
@tt{block}s that @i{do not} touch the given @tt{posn}.}

@,p{A @tt{block} touches a @tt{posn} if the @tt{block}'s left edge is
no greater than the @tt{posn}'s x-coordinate, the @tt{block}'s right edge
is no less than the @tt{posn}'s x-coordinate, the @tt{block}'s top edge is
no greater than the @tt{posn}'s y-coordinate, and the @tt{block}'s bottom edge
is no less than the @tt{posn}'s y-coordinate.}

@,p{For example, @tt{(remove-blocks (gen-blocks 2 10
10 "blue") (make-posn 20 20))} should produce the same result as
@tt{(gen-blocks 1 10 40 "blue")}.}

@,p{Don't forget that when you're writing a function that consumes a
list of @tt{block}s, you almost certainly want a function that handles
each individual @tt{block}. The function that takes a @tt{block} will have its own contract,
purpose, template (whether you keep it or not), and tests.}


@,part[3]{Adding Blocks to a Scene}

@,p{Implement @tt{add-blocks-to-scene}, which takes a list of
@tt{block}s and a @tt{scene} and returns a new @tt{scene} with the
blocks added. Each block should be added to the scene at its position
and using the block's color.}



@,part[4]{The Game}

@,p{A @tt{game} combines a @tt{launch} (from @a["hw2.html"]{HW 2}) with a
list of @tt{block}s:}

@,pre{
;; A game is
;;   (make-game launch list-of-block)
(define-struct game (launch blocks))
}

@,p{Implement}

@,ul{@li{@tt{game-scene}, which takes a @tt{game} and produces a @tt{scene}
         that includes both the duck and the blocks;}

     @li{@tt{mouse-game}, which takes a @tt{game}, a number, a number,
         and a mouse-event string and returns a new @tt{game}, where
         the mouse event can affect the launch in the same way as for @tt{mouse-scene}; 
         and}

     @li{@tt{step-game}, which takes a @tt{game} and returns a @tt{game} that, for now,
         simply steps the @tt{launch} while keeping the list of @tt{block}s the same.}
}

@,p{With those pieces, you can try running you game so far:}

@,pre{
(big-bang
 (make-game false (gen-blocks 10 600 300 "blue"))
 [to-draw game-scene]
 [on-tick step-game]
 [on-mouse mouse-game])
}

@,p{Of course, the duck doesn't yet smash the blocks.}



@,part[5]{Smash Blocks}

@,p{Change @tt{step-game} so that after the @tt{game}'s @tt{launch} is
stepped, if the @tt{launch} is a flying @tt{duck}, then any blocks
that are touched by the duck's center are removed from the @tt{game}
returned by @tt{step-game}.}

@,p{You will probably want to implement a helper function
@tt{combine-game}, which takes a (new) @tt{launch} and a list of
@tt{block}s and returns the @tt{launch} combined with a suitably
filtered list of @tt{block}s. The @tt{combine-game} helper, in turn,
should use other functions that you've written for this
assignment.}


@,part[6]{Watch out for Falling Blocks}

@,p{After a flying duck smashes blocks, blocks that are not supported
by other blocks should fall.}

@,p{Implement @tt{drop-blocks}, which takes a list of @tt{block}s and
moves each @tt{block} in the list down by 1 (i.e., increases its
y-position by 1) if no @tt{block} with a greater y position anywhere in
the list touches the @tt{block} and if the @tt{block}'s bottom edge is not
already touching the ground (which is at 600 pixels).}

@,p{You'll probably want several helper functions:}

@,ul{

 @li{The @tt{drop-blocks} function might simply call
@tt{drop-blocks*}, which takes a list of @tt{blocks} to potentially drop
and an unchanging list of all @tt{block}s. The two lists start the
same, but the second list is along for the ride in
@tt{drop-blocks*} (i.e., recursive calls keep the second list the
same).}

 @li{To implement @tt{drop-blocks*}, you'll probably need
@tt{drop-one-block}, with takes a single @tt{block} and a list of
@tt{block}s and drops the single @tt{block} if it is not touching any
lower @tt{block} (i.e., greater y position) in the list of @tt{block}s 
and not touching the ground.}

@li{To implement @tt{drop-one-block}, you'll probably want a
@tt{any-below?}  function that takes the same arguments as
@tt{drop-one-block}, but simply reports whether any @tt{block} in the
list of @tt{block}s is below and touching the single @tt{block}.}

@li{To implement @tt{any-below?}, you'll probably need a
@tt{block-below?} function that takes two @tt{block}s and determines
whether the first @tt{block} has a greater y position than the second
@tt{block}, whether any of the first @tt{block}'s four corners touch the
second @tt{block}, and whether and the second @tt{block} is not already touching
the ground.}

}


@,part[7]{Mildy Annoyed Ducks!}

@,p{Adjust @tt{step-game} so that after the @tt{launch} is stepped and before
blocks are smashed, the blocks drop as implemented by @tt{drop-blocks}.}

@,p{Use the @tt{big-bang} form above to play your game.}
