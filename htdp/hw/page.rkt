#lang racket/base
(require xml
         racket/date)
(empty-tag-shorthand html-empty-tags)

(provide make-page
         part
         underline
         literal-link
         stars choice
         tt pre
         p ol ul li
         i  h1 h2 h3 sup sub
         a
         ill png step-ill)

(define (part n [label #f])
  `(h3 "Part " ,(number->string n)
       ,@(if label (list " " 'ndash " " label) null)))

(define (make-page what title-template number body)
  (let ([title (if (pair? number)
                   (cadr number)
                   (format title-template number))])
    (let ([page
           `(html
             (head
              (title ,title))
             (body 
              ((style "bgcolor: white; width: 45em; margin-left: auto; margin-right: auto"))

              (h2 ,title)
              
              ,@body

              (hr)
              
              (table ((width "100%"))
                     (tr
                      (td ((align "right"))
                          "Last update: "
                          ,(date->string (seconds->date (current-seconds)))
                          (address
                           "matthedm@uci.edu"))))))])
      (with-output-to-file (format "~a~a.html" 
                                   what
                                   (if (pair? number)
                                       (car number)
                                       number))
        #:exists 'truncate/replace
        (lambda ()
          (printf "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n")
          (write-xml/content (xexpr->xml page))
          (newline))))))

(define (underline x)
  `(span ((style "text-decoration: underline;")) ,x))

(define (literal-link x)
  `(a ((href ,x)) ,x))

(define (stars n)
  `(font () ,@(vector->list (make-vector n #x2605))))

(define (choice n s . l)
  `(tr (td ((valign "top") (align "right"))
	    (font ((size "-2")) ,s) nbsp ,(format "~a." n))
       (td ,@l)))

(define (a url . l) `(a ((href ,url)) ,@(decode-all l)))

(define (make-decoder tag)
  (lambda l
    `(,tag ,@(decode-all l))))

(define p (make-decoder 'p))
(define ol (make-decoder 'ol))
(define ul (make-decoder 'ul))
(define li (make-decoder 'li))
(define i (make-decoder 'i))
(define sup (make-decoder 'sup))
(define sub (make-decoder 'sub))
(define h1 (make-decoder 'h1))
(define h2 (make-decoder 'h2))
(define h3 (make-decoder 'h3))

(define (decode-all l)
  (apply
   append
   (map (lambda (s)
          (if (string? s)
              (decode s)
              (list s)))
        l)))

(define (decode s)
  (cond
   [(regexp-match #rx"^(.*?)(``|''|'|---|--)(.*)$" s)
    => (lambda (m)
         (append (decode (cadr m))
                 (let ([s (caddr m)])
                   (cond
                    [(equal? s "``") '(ldquo)]
                    [(equal? s "''") '(rdquo)]
                    [(equal? s "'") '(rsquo)]
                    [(equal? s "---") '(mdash)]
                    [(equal? s "--") '(ndash)]))
                 (decode (cadddr m))))]
   [else (list s)]))

(define (pre #:indent [indent 2] . l)
  `(pre ,@(let loop ([l l][indent? #t])
            (cond
             [(null? l) null]
             [indent? 
              (cons (make-string indent #\space)
                    (loop l #f))]
             [(equal? (car l) "\n")
              (cons (car l) (loop (cdr l) #t))]
             [else
              (cons (car l) (loop (cdr l) #f))]))))

(define (tt . l) `(tt ,@l))


(define (ill a b)
  `(table ((align "center") (bgcolor "#cccccc"))
          (tr (td ((align "center")) ,a))
          (tr (td ((align "center")) ,b))))
(define (png f)
  `(img ((src ,(string-append f ".png")))))
(define (step-ill a x b)
  `(table ((align "center") (bgcolor "#cccccc"))
          (tr (td ((align "center")) ,a)
              (td ((align "center")) nbsp rarr nbsp ,x nbsp rarr nbsp)
              (td ((align "center")) ,b))))
