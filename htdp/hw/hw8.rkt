#lang at-exp s-exp "hw.rkt"

@8 @'(10 28 2011)

@,p{Although you implement this assignment in Java with Eclipse, handin your
    work using DrRacket. The handin server will not try to run any tests.
    The handin server will call your submitted file @tt{hw.java}; unfortuately,
    however, the  file will be saved in DrRacket's non-text format.}

@,p{Use the subset of Java that we have covered in class. In particular,
    use the @tt{=} assignment operator only in constructors.}

@,part[1]{Lions}

@,p{The relevant properties of a lion are, in order}
@,ol{
  @li{The number of teeth it has}
  @li{The name of the person it most recently ate (maybe @tt{"no one"})}}

@,p{Here is an initial class definition:}
@,pre[#:indent 2]|{
class Lion {
  int teeth;
  String ate;
  Lion(int teeth, String ate) {
     this.teeth = teeth;
     this.ate = ate;
  }
}
}|

@,p{Implement the @tt{Lion} method @tt{moreScary}, which
    produces a lion with two additional teeth (but the same stomach contents).}


@,part[2]{and Tigers}

@,p{Design a representation for tigers, where the relevant properties of a tiger are}
@,ol{
  @li{The number of stripes it has (an integer)}
  @li{The length of its claws in centimeters (a @tt{double})}
  @li{The name of the person it most recently ate (maybe @tt{"no one"})}}

@,p{Use @tt{Tiger} as the name of your class, and put the constructor arguments in the above order.}

@,p{Implement the @tt{Tiger} method @tt{moreScary}, which
   produces a tiger (with the same fur pattern and stomach contents) 
   whose claws are one centimeter longer.}


@,part[3]{and Bears}

@,p{Design a representation for bears, where the relevant properties of a bear are}

@,ol{
 @li{Its fur color, as a string}
  @li{The name of the person it most recently ate (maybe @tt{"no one"})}}

@,p{Use @tt{Bear} as the name of your class, and put the constructor arguments in the above order.}

@,p{Implement the @tt{Bear} method @tt{moreScary}, which
    produces a bear (with the same fur color)
    that hasn't eaten recently.}


@,part[4]{Oh My!}

@,p{Define the interface @tt{IOzAnimal} and adjust your earlier
    class declarations so that an Oz animal is a lion, tiger, or bear.}

@,p{Add the @tt{IOzAnimal} method @tt{moreScary}, which produces a scarier animal (as above).
    Adjust the return types of previoulsy implemented methods if necessary.}


@,part[5]{Erp}

@,p{Define the @tt{IOzAnimal} method @tt{feed} that takes a string
    for a person's name. The result should be an @tt{IOzAnimal}
    that just ate the person whose name is given.}


@,part[6]{Rescue}

@,p{Define the @tt{IOzAnimal} method @tt{rescue} that takes no
    arguments and returns an @tt{IOzAnimal} that hasn't recently eaten anyone.}


@,part[7]{Oz Scenes}

@,p{An Oz scene consists of one person and one @tt{IOzAnimal}. 
    It is represented as an @tt{OzScene}:}

@,pre[#:indent 2]|{
class OzScene {
  String person;
  IOzAnimal animal;
  OzScene(String person, OzAnimal animal) {
    this.person = person;
    this.animal = animal;
  }
}|

@,p{Implement the @tt{OzScene} method @tt{moreScary}, which takes no
    arguments and produces one with a scarier animal and the same person.}


@,part[8]{A Wizard of Oz}

@,p{An Oz scene moves the next scene as follows:}

@,ul{
 @li{If a person is in the scene, then the animal
     eats the person (and no one is left), unless the person is named @tt{"wizard"}.}
 @li{If the person is named @tt{"wizard"}, and 
     if the animal's stomach is not empty, then the previously eaten person is rescued to
     and takes the wizard's place (and the wizard leaves).}
 @li{If no one is present, the animal simply gets scarier.}
 @li{Otherwise (only a wizard and an animal with an empty stomach), nothing happens.}
}


@,p{Implement the @tt{OzScene} method @tt{next}, which takes no arguments returns
    the next @tt{OzScene} according to the rules above.}

@,p{Don't forget to break up the problem into smaller pieces. For example, you might
    find an @tt{animalAte} method of @tt{OzAnimal}
    useful (that takes no arguments returns a string for
    the person that the animal recently ate).}

