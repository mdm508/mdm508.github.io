;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname hw3-soln) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; A list-of-num is either
;;   - empty
;;   - (cons num list-of-num)

;; wall-height : list-of-num -> num
;;  To return the max of the list plus 30
;(define (wall-height lon)
;  (cond
;    [(empty? lon) ....]
;    [(cons? lon) 
;     ... (first lon) ... (wall-height (rest lon)) ...]))
(define (wall-height lon)
  (cond
    [(empty? lon) 0]
    [(cons? lon) 
     (max (+ (first lon) 30) (wall-height (rest lon)))]))

(check-expect (wall-height empty)
              0)
(check-expect (wall-height (cons 10 empty))
              40)
(check-expect (wall-height (cons 10 (cons 70 (cons 40 empty))))
              100)

;; aligned-bricks? : list-of-num -> bool
;;  To determine whether all the numbers in the list
;;  are integers.
;(define (aligned-bricks? lon)
;  (cond
;    [(empty? lon) ....]
;    [(cons? lon) 
;     ... (first lon) ... (aligned-bricks? (rest lon)) ...]))
(define (aligned-bricks? lon)
  (cond
    [(empty? lon) true]
    [(cons? lon) 
     (and (integer? (first lon))
          (aligned-bricks? (rest lon)))]))

(check-expect (aligned-bricks? empty)
              true)
(check-expect (aligned-bricks? (cons 10.1 empty))
              false)
(check-expect (aligned-bricks? (cons 10 empty))
              true)
(check-expect (aligned-bricks? (cons 10 (cons 70.1 (cons 40 empty))))
              false)
(check-expect (aligned-bricks? (cons 10 (cons 70 (cons 40 empty))))
              true)

;; align-bricks : list-of-num -> list-of-num
;;  To replace all nums in the list with "x".
;(define (align-bricks lon)
;  (cond
;    [(empty? lon) ....]
;    [(cons? lon) 
;     ... (first lon) ... (align-bricks (rest lon)) ...]))
(define (align-bricks lon)
  (cond
    [(empty? lon) empty]
    [(cons? lon) 
     (cons (round (first lon)) (align-bricks (rest lon)))]))

(check-expect (align-bricks empty)
              empty)
(check-expect (align-bricks (cons 10.1 empty))
              (cons 10 empty))
(check-expect (align-bricks (cons 10.1 (cons 70.4 (cons 39.7 empty))))
              (cons 10 (cons 70 (cons 40 empty))))

;; search-and-delete : num list-of-num -> list-of-num
;;  To remove every number in lon between n-30 and n.
;(define (search-and-delete n lon)
;  (cond
;    [(empty? lon) ....]
;    [(cons? lon) 
;     ... (first lon) ... (search-and-delete s (rest lon)) ...]))
(define (search-and-delete n lon)
  (cond
    [(empty? lon) empty]
    [(cons? lon) 
     (cond
       [(and (<= (- n 30) (first lon)) (>= n (first lon)))
        (search-and-delete n (rest lon))]
       [else
        (cons (first lon) (search-and-delete n (rest lon)))])]))

(check-expect (search-and-delete 20 empty)
              empty)
(check-expect (search-and-delete 20 (cons 10 empty))
              empty)
(check-expect (search-and-delete 20 (cons 70 empty))
              (cons 70 empty))
(check-expect (search-and-delete 20 (cons 10 (cons 70 (cons 40 empty))))
              (cons 70 (cons 40 empty)))
(check-expect (search-and-delete 40 (cons 10 (cons 70 (cons 40 empty))))
              (cons 70 empty))

;; insert : num num list-of-num -> list-of-num
;;  To insert n after the first pos elements of lon
;(define (insert s pos lon)
;  (cond
;    [(empty? lon) ....]
;    [(cons? lon) 
;     ... (first lon) ... (insert s pos (rest lon)) ...]))
(define (insert n pos lon)
  (cond
    [(empty? lon) (cons n empty)]
    [(cons? lon) 
     (cond
       [(zero? pos) (cons n lon)]
       [else
        (cons (first lon) (insert n (sub1 pos) (rest lon)))])]))

(check-expect (insert 70 5 empty) (cons 70 empty))
(check-expect (insert 70 0 (cons 40 empty)) (cons 70 (cons 40 empty)))
(check-expect (insert 70 1 (cons 40 empty)) (cons 40 (cons 70 empty)))
(check-expect (insert 70 1 (cons 40 (cons 10 (cons 110 empty))))
              (cons 40 (cons 70 (cons 10 (cons 110 empty)))))
(check-expect (insert 70 2 (cons 40 (cons 10 (cons 110 empty))))
              (cons 40 (cons 10 (cons 70 (cons 110 empty)))))
