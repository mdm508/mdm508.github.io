#lang racket/base
(require "page.rkt"
         xml
         racket/date)

(provide (except-out (all-from-out racket/base) #%module-begin)
         (rename-out [module-begin #%module-begin])
         (except-out (all-from-out "page.rkt")
                     make-page)
         htdp-ex)

(define-syntax-rule (module-begin number due-date body ...)
  (#%module-begin (homework-page number
                                 due-date
                                 `body ...)))

(define title-template "Lab ~a")

(define (homework-page number due-date . body)
  (make-page "hw"
             title-template
             number
             (cons
              `(p "Last updated: " ,(let ([s (find-seconds 0 0 10 (cadr due-date) (car due-date) (caddr due-date))])
                             (date->string (seconds->date s)))
                  " "
                  ,(if ((length due-date) . >= . 4)
                       (list-ref due-date 3)
                       "10:45am"))
              body)))

(define (htdp-ex num page url)
  `(a ((href ,url)) ,(format "HtDP exercise ~a (page ~a)" num page)))

