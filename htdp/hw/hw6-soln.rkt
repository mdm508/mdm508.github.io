;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname hw7-soln) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

; numbers->strings : list-of-num -> list-of-string
(define (numbers->strings l)
  (map number->string l))

(check-expect (numbers->strings empty) empty)
(check-expect (numbers->strings '(1 2 7)) '("1" "2" "7"))


; percents->strings : list-of-num -> list-of-string
(define (percents->strings l)
  (local [(define (percent->string i)
            (number->string (/ i 100)))]
    (map percent->string l)))

(check-expect (percents->strings empty) empty)
(check-expect (percents->strings '(1 2 7)) '("1/100" "1/50" "7/100"))


; parallel-map : (X Y -> Z) list-of-X list-of-Y -> list-of-Z
(define (parallel-map F al bl)
  (cond
    [(empty? al) empty]
    [(cons? al)
     (cons (F (first al) (first bl))
           (parallel-map F (rest al) (rest bl)))]))

(check-expect (parallel-map - '(10 9 8) '(7 2 3)) '(3 7 5))


; parallel-sum : list-of-num list-of-num -> list-of-num
(define (parallel-sum al bl)
  (parallel-map + al bl))

(check-expect (parallel-sum empty empty) empty)
(check-expect (parallel-sum (list 1 3 5) (list 0 4 6)) (list 1 7 11))
  

; parallel-product : list-of-num list-of-num -> list-of-num
(define (parallel-product al bl)
  (parallel-map * al bl))

(check-expect (parallel-product empty empty) empty)
(check-expect (parallel-product (list 1 3 5) (list 0 4 6)) (list 0 12 30))


; flip-some : list-of-posn list-of-bool -> list-of-posn
(define (flip-some lop lob)
  (local [(define (maybe-flip p b)
            (cond
              [b (make-posn (posn-y p) (posn-x p))]
              [else p]))]
    (parallel-map maybe-flip lop lob)))

(check-expect (flip-some empty empty) empty)
(check-expect (flip-some (list (make-posn 1 2) (make-posn 3 4))
                         (list true false))
              (list (make-posn 2 1) (make-posn 3 4)))


; choose : list-of-X list-of-X (X X -> X) -> list-of-X
(define (choose l1 l2 COMP)
  (local [(define (pick a b)
            (cond
              [(COMP a b) a]
              [else b]))]
    (parallel-map pick l1 l2)))
    
(check-expect (choose empty empty <) empty)
(check-expect (choose '(1 2 3) '(3 2 1) <) '(1 2 1))
(check-expect (choose '(1 2 3) '(3 2 1) >) '(3 2 3))
(check-expect
 (local [(define (first-is-apple? a b)
           (symbol=? a 'apple))]
   (choose '(apple banana) '(cherry cherry) first-is-apple?))
 '(apple cherry))

