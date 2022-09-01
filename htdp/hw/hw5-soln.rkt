;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname hw5-soln) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Part 1 --------------------

;; A family-tree-node is either
;;  - empty
;;  - (make-child family-tree-node family-tree-node symbol
;;                number symbol) 
(define-struct child (father mother name date eyes))


(define abe (make-child empty empty 'Abe 1920 'black))
(define mona (make-child empty empty 'Mona 1930 'green))

(define jackie (make-child empty empty 'Jacqueline 1929 'blue))
(define clancy (make-child empty empty 'Clancy 1929 'blue))

(define homer (make-child abe mona 'Homer 1955 'black))
(define marge (make-child clancy jackie 'Marge 1954 'blue))

(define maggie (make-child homer marge 'Maggie 1990 'brown))

;; fun-for-ftn : family-tree-node ->  ...
#;
(define (fun-for-ftn ftn)
  (cond
    [(empty? ftn) ...]
    [(child? ftn)
     ... (fun-for-ftn (child-mother ftn))
     ... (fun-for-ftn (child-father ftn))
     ... (child-name ftn)
     ... (child-date ftn)
     ... (child-eyes ftn) ...]))


;; Part 2 --------------------

;; count-persons : family-tree-node ->  number
(define (count-persons ftn)
  (cond
    [(empty? ftn) 0]
    [(child? ftn)
     (+ (count-persons (child-mother ftn))
        (count-persons (child-father ftn))
        1)]))

(check-expect (count-persons empty) 0)
(check-expect (count-persons abe) 1)
(check-expect (count-persons maggie) 7)

;; Part 3 --------------------

;; in-family? : family-tree-node symbol ->  boolean?
(define (in-family? ftn who)
  (cond
    [(empty? ftn) #f]
    [(child? ftn)
     (or (symbol=? who (child-name ftn))
         (in-family? (child-mother ftn) who)
         (in-family? (child-father ftn) who))]))

(check-expect (in-family? empty 'Abe) false)
(check-expect (in-family? abe 'Abe) true)
(check-expect (in-family? maggie 'Abe) true)
(check-expect (in-family? abe 'Maggie) false)

;; Part 4 --------------------

;; eye-colors : family-tree-node ->  list-of-symbol
(define (eye-colors ftn)
  (cond
    [(empty? ftn) empty]
    [(child? ftn)
     (cons (child-eyes ftn)
           (append (eye-colors (child-mother ftn))
                   (eye-colors (child-father ftn))))]))

(check-expect (eye-colors empty) empty)
(check-expect (eye-colors abe) '(black))
(check-expect (eye-colors maggie) '(brown blue blue blue black green black))

;; Part 5 --------------------

;; A parent is
;;  - (make-parent list-of-children symbol number symbol) 
(define-struct parent (children name date eyes))

;; A list-of-children is either
;;  - empty
;;  - (cons parent list-of-children)

(define bart (make-parent empty 'Bart 1985 'black))
(define lisa (make-parent empty 'Bart 1985 'green))
(define baby-maggie (make-parent empty 'Bart 1985 'blue))

(define marjorie (make-parent (list bart lisa baby-maggie)
                              'Marge 1954 'blue))
(define patricia (make-parent empty 'Patty 1950 'green))
(define selma (make-parent empty 'Selma 1950 'green))

(define jacqueline (make-parent (list marjorie patricia selma)
                                'Jacqueline 1929 'blue))

;; fun-for-parent : parent ->  ...
#;
(define (fun-for-parent p)
  ... (fun-for-loc (parent-children p))
  ... (parent-name p)
  ... (parent-date p)
  ... (parent-eyes p) ...)

;; fun-for-loc : list-of-children -> ...
#;
(define (fun-for-loc loc)
  (cond
    [(empty? loc) ...]
    [(cons? loc)
     ... (fun-for-parent (first loc))
     ... (for-for-loc (rest loc)) ...]))


;; count-descendants : parent ->  number
(define (count-descendants p)
  (+ 1 (count-children-descendants (parent-children p))))

;; count-children-descendants : list-of-children -> ...
(define (count-children-descendants loc)
  (cond
    [(empty? loc) 0]
    [(cons? loc)
     (+ (count-descendants (first loc))
        (count-children-descendants (rest loc)))]))

(check-expect (count-children-descendants empty) 0)
(check-expect (count-children-descendants (list baby-maggie)) 1)
(check-expect (count-children-descendants (list marjorie selma)) 5)

(check-expect (count-descendants selma) 1)
(check-expect (count-descendants jacqueline) 7)
