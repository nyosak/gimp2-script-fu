#!/usr/bin/env tinyscheme
; Tiny Scheme lesson about apply
; copyright 2025, hanagai
;
; apply.scm
; version: March 20, 2025
;
; to help understanding apply, let, let* and quote

(define (lesson1)
  (write "lesson1")
  (newline)

  ;(apply 3 4)
  ; illegal function
  ; 3 is called as (3 4)
  ; because 3 is not a function, this causes an error.
  ; (apply "a" "b") gets the same error.

  ;(apply a b)
  ; eval: unbound variable: a
  ; (a b) is called
  ; because a is not defined, this causes an error.

  ;(let ((a pair?)) (apply a 5))
  ; pair?: needs 1 argument(s)
  ; (pair? is called without arguments
  ; because apply requires a list as arguments,
  ; this error is that 5 is not a list.

  ;(let ((a pair?)) (apply a (5)))
  ; (5) is called before (apply
  ; 5 is not a funtion, this causes an error.

  (let ((a pair?)) (apply a '(5)))
  (let ((a pair?)) (write (apply a '(5)))(newline))
  ; #f
  ; (pair? 5) is called to be #f

  (let ((a pair?)) (write (apply a `(5)))(newline))
  ; #f
  ; quasiquote gives same result as quote

  (let ((a pair?)) (write (apply a '('5)))(newline))
  ; #t
  ; double quote gives #t
  (let ((a car)) (write (apply a '('5)))(newline))
  ; quote
  ; (pair? '(quote 5)) (car '(quote 5)) is called for each
  ; the 1st of pair is (quote

  (let ((a car)) (write (apply a '(`5)))(newline))
  ; quasiquote
  ; (car '(quasiquote 5)) is called

  (let ((a eval)) (write (apply a '('5)))(newline))
  ; 5
  ; (eval '(quote 5)) is called

  (let ((a eval)) (write (apply a '('('5))))(newline))
  ; ('5)
  ; (eval ''('5)), or (eval '(quote ((quote 5)))) is called
  (write (eval '''5))(newline)
  ; '5
  (write (eval ''''''5))(newline)
  ; ''''5
  ; so, the 1st quote is removed on calling,
  ;     the 2nd one is removed by eval.

  (write (eval (eval (eval 5))))(newline)
  ; 5
  ; multiple eval is safe for simple values

  ;(write (eval (eval (eval '(cons 7 8)))))(newline)
  ; illegal function
  ; unsafe for something requires quote


)

(lesson1)

(define (lesson2)
  (write "lesson2")
  (newline)

  (let ((a write) (b '(6 7))) (write (apply a '(b)))(newline))
  ; b#t
  (let ((a symbol?) (b '(6 7))) (write (apply a '(b)))(newline))
  ; #t
  ; b is returned as symbol
  (let* ((a write) (b '(6 7))) (write (apply a '(b)))(newline))
  ; b#t
  (let* ((a symbol?) (b '(6 7))) (write (apply a '(b)))(newline))
  ; #t
  ; no differences between let and let*

  (let ((a write) (b '(6 7))) (write (apply a '((eval b))))(newline))
  ;(eval b)#t
  ; it doesn't work
  ; because eval is stil quoted when apply is called

  ;(let* ((a car) (b '(6 7))) (write (apply a '(b)))(newline))
  ; car: argument 1 must be: pair
  ; because b is (quote (6 7)), it's not a pair
  (let* ((b '(6 7))) (write (car b))(newline))
  ; 6
  ;(let* ((b '(6 7))) (write (car 'b))(newline))
  ; car: argument 1 must be: pair
  ;(let* ((b '(6 7))) (write (car `b))(newline))
  ; car: argument 1 must be: pair
  (let* ((b '(6 7))) (write (car (eval 'b)))(newline))
  ; 6
  ; if the quote is removed after called, it may work

  (let* ((a car) (b '(6 7)))
    (define (x p) (car (eval p)))
    (write (apply x '(b)))(newline)
  )
  ; 6
  ; it works, but when we have to call eval?
  ; there may be no functions like (quote?) or (quoted?)

)

(lesson2)

(define (lesson3)
  (write "lesson3")
  (newline)

  (let* ((a write) (b '(6 7))) (write (apply a `(,b)))(newline))
  ; (6 7)#t
  ; a combination of quasiquote and unquote works
  (let* ((a cdr) (b '(6 7))) (write (apply a `(,b)))(newline))
  ; (7)
  ; good
  (let* ((a car) (b '(6 7))) (write (apply a (quasiquote ( (unquote b) )) ))(newline))
  ; 6
  ; quote of b is expanded by unquote before going to apply, so it works

  (let ((a car) (b '(6 7))) (write (apply a (quasiquote ( (unquote b) )) ))(newline))
  ; 6
  ; let also works in this case

  (let ((a cdr) (c 8) (b '(6 7 c))) (write (apply a (quasiquote ( (unquote b) )) ))(newline))
  ; (7 c)
  ; in this case, c is left quoted

  ;(let ((a cdr) (c 8) (b `(6 7 ,c))) (write (apply a (quasiquote ( (unquote b) )) ))(newline))
  ; eval: unbound variable: c
  ; now, we need let*

  (let* ((a cdr) (c 8) (b `(6 7 ,c))) (write (apply a (quasiquote ( (unquote b) )) ))(newline))
  ; (7 8)
  ; very well!

)

(lesson3)

