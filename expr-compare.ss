#lang racket
(define (expr-compare x y)
  (cond
    ; if they're the same then we're done
    [(equal? x y) x]

    ; special case with #t and #f giving '%, then we're done
    [(and (equal? x #t) (equal? y #f)) '%]
    [(and (equal? x #f) (equal? y #t)) (list 'not '%)]

    ; if either starts with a quote, we're done
    [(and (pair? x) (pair? y)
     (or (equal? (car x) 'quote)
         (equal? (car y) 'quote)))
        (list 'if '% x y)]

    ; if one but not the other starts with if, we're done
    [(and (pair? x) (pair? y)
          (or (and (equal? (car x) 'if)
                   (not (equal? (car y) 'if)))
              (and (not (equal? (car x) 'if))
                   (equal? (car y) 'if))))
        (list 'if '% x y)]
    
    ; if both start with either lambda or λ but have different numbers of args, combine with "if" and continue
    [(and (pair? x) (pair? y) (equal? (length x) 3) (equal? (length y) 3)
          (or (equal? (car x) 'lambda)
              (equal? (car y) 'λ)
              (equal? (car x) 'λ)
              (equal? (car y) 'lambda))
          (or (not (equal? (length (cadr x)) (length (cadr y))))
          ; if one of them isn't a lambda or λ
              (or (not (or (equal? (car y) 'lambda)
                           (equal? (car y) 'λ)))
                  (not (or (equal? (car x) 'lambda)
                           (equal? (car x) 'λ))))))
        (list 'if '% x y)]
    
    ; special case: one starts with lambda and the other starts with λ, and both lengths = 3  (do we have to consider if one is lambda and the other isn't?)
    ; or: both start with λ
    ; also special case: bound variables use ! operator
    [(and (pair? x) (pair? y) (equal? (length x) 3) (equal? (length y) 3)
          (or (and (equal? (car x) 'lambda)
                   (equal? (car y) 'λ))
              (and (equal? (car x) 'λ)
                   (equal? (car y) 'lambda))
              (and (equal? (car x) 'λ)
                   (equal? (car y) 'λ))))
        (let ((car-result 'λ)
              (initial-result (binding-compare (cadr x) (cadr y) (list) (list))))
              (let
               ((cadr-result (car initial-result))
                (xdict (cadr initial-result))
                (ydict (car (cddr initial-result)))) ; be careful with cddr
                (let
                    ((cddr-result (expr-compare (replace-vars-with-values (cddr x) xdict) (replace-vars-with-values (cddr y) ydict))))
        (cons car-result (cons cadr-result cddr-result)))))]
    
    ; special case: both start with lambda, len=3, and bound variables use ! operator
    [(and (pair? x) (pair? y) (equal? (length x) 3) (equal? (length y) 3)
          (and (equal? (car x) 'lambda)
               (equal? (car y) 'lambda)))
        (let ((car-result 'lambda)
              (initial-result (binding-compare (cadr x) (cadr y) (list) (list))))
              (let
               ((cadr-result (car initial-result))
                (xdict (cadr initial-result))
                (ydict (car (cddr initial-result)))) ; be careful with cddr
                (let
                    ((cddr-result (expr-compare (replace-vars-with-values (cddr x) xdict) (replace-vars-with-values (cddr y) ydict))))
        (cons car-result (cons cadr-result cddr-result)))))]

    ; both are pairs with neither's length = 1
    [(and (pair? x) (pair? y) 
        (not (or (and (> (length x) 1) (equal? (length y) 1)) (and (> (length y) 1) (equal? (length x) 1)))))
     (let ((car-result (expr-compare (car x) (car y)))
           (cdr-result (expr-compare (cdr x) (cdr y))))
     (cons car-result cdr-result))]

    ; if they're not pairs then we're done
    [(not (equal? x y)) (list 'if '% x y)]
  )
)

; returns list with variables combined with ! notation and xdict and ydict
(define (binding-compare x y xdict ydict)
; write xdict and ydict
    (cond
        ; if they're the same then we're done
        [(equal? x y) (list x xdict ydict)]
    
        ; if one is a list and the other isn't, we're done
        [(and (pair? x) (not (pair? y))) (list (list 'if '% x y) xdict ydict)]
        [(and (not (pair? x)) (pair? y)) (list (list 'if '% x y) xdict ydict)]
    
        ; if both are lists, compare the car and cdr
        [(and (pair? x) (pair? y))
         (let ((car-result (car (binding-compare (car x) (car y) xdict ydict)))
               (xdict-result (cadr (binding-compare (car x) (car y) xdict ydict)))
               (ydict-result (car (cddr (binding-compare (car x) (car y) xdict ydict))))
               (cdr-result (if (or (equal? (cdr x) '()) (equal? (cdr y) '())) '() (car (binding-compare (cdr x) (cdr y) xdict ydict))))
               (cdr-xdict-result (if (or (equal? (cdr x) '()) (equal? (cdr y) '())) '() (cadr (binding-compare (cdr x) (cdr y) xdict ydict))))
               (cdr-ydict-result (if (or (equal? (cdr x) '()) (equal? (cdr y) '())) '() (car (cddr (binding-compare (cdr x) (cdr y) xdict ydict))))))
         (list (cons car-result cdr-result) (append xdict-result cdr-xdict-result) (append ydict-result cdr-ydict-result)))]
    
        ; if they're not pairs then we use the ! notation
        [(not (equal? x y)) (let 
                                ((newid (string->symbol (string-append (symbol->string x) "!" (symbol->string y)))))
                                (list newid (cons (cons x newid) xdict) (cons (cons y newid) ydict)))]
    )
)

(define (replace-vars-with-values pair alist)
  (cond
    ((null? pair) pair)
    ((pair? pair)
     (cond [(and (pair? (car pair)) (or (eq? (car (car pair)) 'lambda) (eq? (car (car pair)) 'λ))) ; add λ
            (cons (car pair)
              (replace-vars-with-values (cdr pair) alist))]
           [else
            (cons (replace-vars-with-values (car pair) alist)
                  (replace-vars-with-values (cdr pair) alist))]))
    ((and (symbol? pair) (pair? alist))
     (if (and (eq? pair (car (car alist)))
              (eq? (cdr (car alist)) pair))
         pair
         (let ((value (assq pair alist)))
           (if value
               (cdr value)
               pair))))
    (else pair)))

(define (test-expr-compare x y)
    (let ((xoutput (eval x))
          (youtput (eval y)))
         (and (equal? xoutput (eval `(let ((% #t)) ,(expr-compare x y))))
              (equal? youtput (eval `(let ((% #f)) ,(expr-compare x y)))))
    )
)

(define test-expr-x '((lambda (x y)
(if (and (bad? x y) #t)
(+ x y)
((λ (a b) ((λ (a b) (if #f a b)) b a)))))
2 3))
(define test-expr-y '((λ (x y)
(if (or (good? x y) #f)
(+ x y)
((lambda (b a) ((lambda (a b) (if #t a b)) b a)))))
4 1))