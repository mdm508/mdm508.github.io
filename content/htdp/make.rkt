#lang racket

(require make)

(define run
  (case-lambda
   [(file) (run file #())]
   [(file args) (parameterize ([current-namespace (make-base-namespace)])
		  (namespace-set-variable-value! 'argv args)
		  (dynamic-require file #f))]
   [(file args outfile)
    (let ([p (open-output-file outfile #:exists 'truncate/replace)])
      (dynamic-wind
	  void
	  (lambda () (parameterize ([current-output-port p])
		       (run file args)))
	  (lambda () (close-output-port p))))]))

(define hws      '(0 1 2 3 4 5 6 7 8 9 10 11 12))
(define labs     '(0 1 2 3 4 5 6 7 8 9 10 11))
(define starters '())
(define hwsols   '())

(define codes '(2 3 4 5 6 7 8 9 10 11 12 14 18))
(define slides '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
                   17 18 19 20 21 22 23 24 25 26 27 28 29 
                   30 31))

(define outfiles
  (append
   (list
    "index.html" "schedule.html"
    "syllabus.html" "scribble-common.js" "scribble-style.css" "scribble.css"
    "syllabus.pdf"
    "cs1410-handin.plt" "cartoon-duck.png"
    "mt1-sample.pdf" 
    "mini-dr.rkt" "string.rkt" "mini-dr-defns.png"
    "tester.jar" "eclipse.txt" "Animals.java" "Animals2.java"
    "mt2ex.pdf" "mt2ex-soln.pdf" "more-java.pdf" "Maze.java" "Maze2.java"
    "maze2.zip" "maze3.zip" "maze.rkt" "maze2.rkt" "eval.zip"
    "calc.rkt" "fish.rkt"
    "battleship-1.rkt" "battleship-2.rkt" "battleship-3.zip"
    "battleship-4.zip" "battleship-5.zip" "battleship-j.zip"
    "final-ex.txt" "final-ex-ans.txt"
    )
   (map (lambda (n) (format "lecture~a.pdf" n)) slides)
   (map (lambda (n) (format "lec~a.rkt" n)) codes)
   (map (lambda (n) (format "hw~a.html" n)) hws)
   (map (lambda (n) (format "lab~a.html" n)) labs)
   (map (lambda (n) (format "hw~a.scm" n)) starters)
   (map (lambda (n) (format "hw~asol.scm" n)) hwsols)))

(define (zip files n)
  (let ([dest (format "~a.zip" n)])
    (when (file-exists? dest)
      (delete-file dest))
    (system (format
             "zip ~a.zip ~a"
             n
             (let ([s (substring (format "~s" files) 1)])
               (substring s 0 (sub1 (string-length s))))))))

(define (desc-zip dir . files)
  (let ([deps (map (lambda (s)
                     (format "~a/~a" dir s))
                   files)]
        [name (string-append dir ".zip")])
    `[,name (,@deps)
            ,(lambda ()
               (zip deps dir))]))

(define maze2
  (desc-zip "maze2"
            "Escape.java" "IDoor.java" "Left.java" "Right.java"
            "Success.java"
            "Examples.java" "IPath.java" "Locked.java" "Room.java"
            "Fail.java" "Into.java" "Person.java" "Short.java"))

(define maze3
  (desc-zip "maze3"
            "Escape.java" "IDoor.java" "Left.java" "Right.java" 
            "ISuccess.java" "Immediate.java"
            "Examples.java" "IPath.java" "Locked.java" "Room.java"
            "Fail.java" "Into.java" "Person.java" "Short.java"))

(define eval
  (desc-zip "eval"
            "Add.java" "Examples.java" "IfZero.java" "Num.java" "Var.java"
            "Binary.java" "IExpr.java" "Mult.java" "Sub.java"))

(define battleship-3
  (desc-zip "battleship-3"
            "battleship-data.rkt" "battleship-fire.rkt" "battleship.rkt"
            "battleship-draw.rkt" "battleship-universe.rkt" "provide.rkt"))

(define battleship-4
  (desc-zip "battleship-4"
            "battleship-data.rkt" "battleship-fire.rkt" "battleship.rkt"
            "battleship-draw.rkt" "battleship-universe.rkt" "provide.rkt"
            "battleship-mouse.rkt"))

(define battleship-5
  (desc-zip "battleship-5"
            "battleship-data.rkt" "battleship-fire.rkt" "battleship.rkt"
            "battleship-draw.rkt" "battleship-universe.rkt" "provide.rkt"
            "battleship-mouse.rkt"))

(define battleship-j
  (desc-zip "battleship-j"
            "APeg.java" "Examples.java" "IBoat.java" "NoBoat.java"
            "Board.java" "HPeg.java" "IResponse.java" "Sink.java"
            "Boat.java" "Hit.java" "Miss.java" "View.java"))

(make/proc
 `(["all" ,outfiles]

   ["www" (,@outfiles ,@(map (lambda (f) (build-path "web" f)) outfiles))]
   
   ,@(map (lambda (f)
	    `[,(build-path "web" f) (,f)
				    ,(lambda () 
				       (let ([dest (build-path "web" f)])
					 (when (file-exists? dest)
					   (delete-file dest))
					 (copy-file f dest)
                                         (system (format "chmod a+r ~a" dest))))])
	  outfiles)

   ["index.html" ("index.rkt")
		 ,(lambda () 
		    (run "index.rkt" #() "index.html"))]
   
   ["schedule.html" ("schedule.rkt")
		    ,(lambda () 
		       (run "schedule.rkt" #() "schedule.html"))]

   ["syllabus.html" ("syllabus.scrbl")
		    ,(lambda () 
                       (system "scribble syllabus.scrbl"))]

   ,@(map (lambda (n)
	    `[,(format "hw~a.html" n) ("hw.rkt" "page.rkt" ,(format "hw~a.rkt" n))
				      ,(lambda ()
					 (run (format "hw~a.rkt" n)))])
	  hws)

   ,@(map (lambda (n)
	    `[,(format "lab~a.html" n) ("lab.rkt" "page.rkt" ,(format "lab~a.rkt" n))
				      ,(lambda ()
					 (run (format "lab~a.rkt" n)))])
	  hws)

   ,maze2
   ,maze3
   ,eval
   ,battleship-3
   ,battleship-4
   ,battleship-5
   ,battleship-j
   )
 (current-command-line-arguments))
