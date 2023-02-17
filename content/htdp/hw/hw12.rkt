#lang at-exp s-exp "hw.rkt"

@12 @'(12 2 2011)

@,p{Implement @a["http://en.wikipedia.org/wiki/Minesweeper_%28computer_game%29"]{Minesweeper}.}

@,p{The details are up to you, but your solution should include the
following required elements:}

@,ul{

 @li{It should be a graphical game implemented with Racket and the
     @tt{2htdp/universe} library or in Java with swing GUI classes.
     (Racket is probably easier for this task.)}

 @li{All tiles should be covered intially.}

 @li{Handle clicks on a tile to reveal either a blank space
     (no adjacent bombs), a number (between 1 and 8 adjacent bombs),
     or a bomb.}

 @li{The initial board should be configurable and it should describe
     where the bombs are located.  Numbers showing adjacent-bomb counts
     should be computed from that initial board.}

}

@,p{You can choose a fixed size for the board, or you can make the
size configurable.  For initial boards, you can try to generate them
randomly or just use a fixed board (as long as the rest of the
implementation doesn't depend on that specific fixed board).}

@,p{For extra credit, include an option in the game to indicate which
of the currently covered tiles could be safely uncovered using at least
single-square analysis (as described on the Wikipedia page) and
information about the uncovered tiles.}
