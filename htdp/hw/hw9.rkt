#lang at-exp s-exp "hw.rkt"

@9 @'(11 4 2011)

@,p{Start with @tt{@a["Maze2.java"]{Maze2.java}} or @tt{@a["maze2.zip"]{maze2.zip}}.}

@,p{Although you implement this assignment in Java with Eclipse, you can handin your
    work using DrRacket. Alternatively, you can handin through a web browser using
    the @a["https://rains.cs.utah.edu:7979/servlets/status.ss"]{handin status server}.
    The latter is better if you work with multiple files, in which case you can
    submit a @tt{.zip} file containing your work.}

@,part[1]{Color-Detecting Doors}

@,p{Add a new kind of door, @tt{ColorDetector}, though which only players
    holding color keys (i.e., any key that is not @tt{"black"} or @tt{"white"})
    can pass. A color-detector door goes into a room.}

@,p{For example, given}

@,pre{
  IDoor monoDoor = new ColorDetector(northRoom);
}

@,p{then}

@,pre{
  monoDoor.escapePath(new Person("Alaska", 5.0, "blue"))
}

@,p{should produce a non-failure path, since the person has a color key.}


@,part[2]{Multiple Keys}

@,p{Generalize @tt{Person} to hold a list of keys. Although Java has
    some built-in classes for holding collections of values, for now define
    an @tt{IKeyList} type and use it for the list of keys.}


@,part[3]{Preparing for Kinds of Rooms}

@,p{So far, we have only one kind of room. To support more kinds of
rooms, change the maze code by switching uses of the @tt{Room} type to
@tt{IRoom}, and make the existing @tt{Room} class implement
@tt{IRoom}.}

@,p{For this step, @tt{Room} will be the only kind of @tt{IRoom}.}


@,part[4]{Accumulating Keys}

@,p{Add a new kind of @tt{IRoom} called @tt{KeyRoom} that has only one door (unlike @tt{Room})
    plus a key of a given color. When a player passes through
    the room, the player also picks up the key.}

@,p{For example, given the door}

@,pre{
  new Into(new KeyRoom(new Into(new Room(blueToPlanets, new Escape("Provo"))),
                       "blue"))
}

@,p{then a player who starts with no keys will be able to reach @tt{"mars"},
    because the key room lets the player pick up a blue key before
    reaching the blue-keyed door. In contrast, the door}

@,pre{
  new Locked(new KeyRoom(planets, "blue"), "blue")
}

@,p{is impassable to a player who doesn't start with a blue key, since
    the key is supplied on the wrong side of the door.}

@,p{With this change, the @tt{Person} argument to @tt{escapePath} serves as an
    accumulator that gathers keys from @tt{KeyRoom}s while looking
    for an escape.}
