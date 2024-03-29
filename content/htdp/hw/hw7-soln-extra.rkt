;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname hw7-soln-extra) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require htdp/gui)
(require "string.rkt")

;; An expr is either
;;  - num
;;  - sym
;;  - (list '+ expr expr)
;;  - (list '- expr expr)
;;  - (list '* expr expr)
;;  - (list 'if0 expr expr expr)
;;  - (list 'lambda (list sym) expr)
;;  - (list expr expr)

;; A func is
;;   (list 'define (list sym sym) expr)

;; eval-expr : expr list-of-funcs -> num
(define (eval-expr x lof)
  (cond
    [(number? x) x]
    [(symbol? x)
     (local [(define f (lookup lof x))]
       (list 'lambda 
             (list (second (second f)))
             (third f)))]
    [(equal? '+ (first x))
     (+ (eval-expr (second x) lof)
        (eval-expr (third x) lof))]
    [(equal? '- (first x))
     (- (eval-expr (second x) lof)
        (eval-expr (third x) lof))]
    [(equal? '* (first x))
     (* (eval-expr (second x) lof)
        (eval-expr (third x) lof))]
    [(equal? 'if0 (first x))
     (if (zero? (eval-expr (second x) lof))
         (eval-expr (third x) lof)
         (eval-expr (fourth x) lof))]
    [(equal? 'lambda (first x))
     x]
    [else
     (local [(define f (eval-expr (first x) lof))
             (define a (eval-expr (second x) lof))]       
       (eval-expr (subst (third f)
                         (first (second f))
                         a)
                  lof))]))

(check-expect (eval-expr '5 empty) 5)
(check-expect (eval-expr '(+ 1 2) empty) 3)
(check-expect (eval-expr '(- 8 7) empty) 1)
(check-expect (eval-expr '(* 2 3) empty) 6)
(check-expect (eval-expr '(+ (* 8 7) (- 9 8)) empty) 57)
(check-expect (eval-expr '(if0 0 2 3) empty) 2)
(check-expect (eval-expr '(if0 1 2 3) empty) 3)
(check-expect (eval-expr '(if0 (- 8 8) 2 3) empty) 2)
(check-error (eval-expr 'x empty))
(check-error (eval-expr '(+ 1 x) empty))
(check-expect (eval-expr '(f 1) (list '(define (f x) (+ x 2))))
              3)
(check-expect (eval-expr '(g (+ 3 4)) (list '(define (f x) (+ x 2))
                                            '(define (g y) (f (- y 3)))))
              6)
(check-expect (eval-expr '(fact 5) (list '(define (fact x)
                                            (if0 x
                                                 1
                                                 (* x (fact (- x 1)))))))
              120)
(check-expect (eval-expr '(lambda (x) (+ x 1)) empty)
              '(lambda (x) (+ x 1)))
(check-expect (eval-expr 'f (list '(define (f x) (+ x 1))))
              '(lambda (x) (+ x 1)))

;; subst : expr sym num -> expr
(define (subst x s n)
  (cond
    [(number? x) x]
    [(symbol? x) (if (symbol=? s x)
                     n
                     x)]
    [(equal? '+ (first x))
     (list '+ 
           (subst (second x) s n)
           (subst (third x) s n))]
    [(equal? '- (first x))
     (list '-
           (subst (second x) s n)
           (subst (third x) s n))]
    [(equal? '* (first x))
     (list '* 
           (subst (second x) s n)
           (subst (third x) s n))]
    [(equal? 'if0 (first x))
     (list 'if0
           (subst (second x) s n)
           (subst (third x) s n)
           (subst (fourth x) s n))]
    [(equal? 'lambda (first x))
     (if (symbol=? s (first (second x)))
         x
         (list 'lambda 
               (list (first (second x)))
               (subst (third x) s n)))]
    [else
     (list (subst (first x) s n)
           (subst (second x) s n))]))

(check-expect (subst 'x 'x 4) 4)
(check-expect (subst 'y 'x 4) 'y)
(check-expect (subst 8 'x 4) 8)
(check-expect (subst '(+ 1 x) 'x 3) '(+ 1 3))
(check-expect (subst '(- 1 x) 'x 3) '(- 1 3))
(check-expect (subst '(* x 1) 'x 3) '(* 3 1))
(check-expect (subst '(+ 1 y) 'x 3) '(+ 1 y))
(check-expect (subst '(if0 (+ 1 y) x y) 'y 10) '(if0 (+ 1 10) x 10))
(check-expect (subst '(f x) 'x 4) '(f 4))
(check-expect (subst '(lambda (x) x) 'x 10) '(lambda (x) x))
(check-expect (subst '(lambda (y) x) 'x 10) '(lambda (y) 10))
  
;; lookup : list-of-funcs sym -> func
(define (lookup lof s)
  (cond
    [(empty? lof) (error "function not defined" s)]
    [(cons? lof)
     (if (func-named? (first lof) s)
         (first lof)
         (lookup (rest lof) s))]))

;; is-func? : func sym -> boolean
;;  Determined whether `f' has the name `n'
(define (func-named? f s)
  (symbol=? (first (second f)) s))

(check-expect (func-named? '(define (f x) x) 'f) true)
(check-expect (func-named? '(define (f x) x) 'g) false)

(check-error (lookup empty 'f))
(check-expect (lookup (list '(define (f x) x)) 'f) '(define (f x) x))
(check-expect (lookup (list '(define (g y) y)
                            '(define (f x) x)) 'f)
              '(define (f x) x))


(define defns
  (list
   ;; Encode `cons', `first', `rest', `empty', and `empty?'
   ;; using functions:
   '(define (pair a) (lambda (b) (lambda (p) ((p a) b))))
   '(define (fst v) (v (lambda (a) (lambda (b) a))))
   '(define (snd v) (v (lambda (a) (lambda (b) b))))
   '(define (empty p) ((p 0) 0))
   '(define (cons a) (lambda (b) ((pair 1) ((pair a) b))))
   '(define (empty? x) (fst x))
   '(define (cons? x) (- (fst x) 1))
   '(define (first c) (fst (snd c)))
   '(define (rest c) (snd (snd c)))
   
   ;; Implement `sum' using `empty?', `first', and `rest':
   '(define (sum l)
      (if0 (empty? l)
           0
           (+ (first l) (sum (rest l)))))))

;; Call the `sum' function:
(check-expect (eval-expr '(sum ((cons 8) ((cons 17) empty)))
                         defns)
              25)

;; ----------------------------------------

(define (read-eval-print evt)
  (draw-message result-msg
                (to-string
                 (eval-expr
                  (from-string
                   (text-contents expr-field))
                  (many-from-string
                   (text-contents defns-field))))))

(define defns-field 
  (make-text "Defns:"))
(define expr-field 
  (make-text "Expr:"))
(define eval-button
  (make-button "Evaluate" read-eval-print))
(define result-msg
  (make-message "__________________________"))

;; Like `big-bang' --- so don't include it in
;; handin!
#;
(create-window (list (list defns-field)
                     (list expr-field)
                     (list eval-button)
                     (list result-msg)))
