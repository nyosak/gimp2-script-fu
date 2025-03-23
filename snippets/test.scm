; Tiny Scheme tool for unit testing
; copyright 2025, hanagai
;
; test.scm
; version: March 23, 2025
;
; (load "./test.scm")
; or copy and paste the code to your script
; define your testCase and run (submit-test testCase)
;

; (load "./string_equal.scm") on Ubuntu TinyScheme 1.42 to use (equal? )
; - See run-a-case definition for the bug on string comparison.
(load "./string_equal.scm")

;;
;; output to file

;(define port-log-1 (open-output-file "/home/kuro/tmp/log.txt"))
;(close-output-port port-log-1)

;;
;; (show-info ... args) : outupt multi-line results

(define (show-info . objs)
  (if (not (eq? () objs))
    (let
      ;((port port-log-1))
      ((port (current-output-port)))
      (echo (apply stringify (list DELIMITER (car objs))) port)
      (newline port)
      (apply show-info (cdr objs))
    )
  )
)

;;
;; (debug args ...) : output results

(define (debug obj1 . objn)
  (let
    ;((port port-log-1))
    ((port (current-output-port)))
    (echo (apply stringify (cons DELIMITER (cons obj1 objn))) port)
    (newline port)
  )
)

;;
;; default delimiter character for debug

(define DELIMITER #\Space)
;(define DELIMITER #\:)
;(define DELIMITER #\,)
;(define DELIMITER #\Tab)
;(define DELIMITER #\Newline)

;;
;; writing procedure used for debug

;(define echo write) ; TineyScheme, GIMP Script-Fu Console
(define echo display) ; TineyScheme, GIMP Script-Fu Console
;(define echo gimp-message)  ; GIMP Script-Fu Console
;(define echo print) ; GIMP Script-Fu Console

;;
;; writing procedure used for submit-test

;(define echo-submit write) ; TineyScheme, GIMP Script-Fu Console
;(define echo-submit display) ; TineyScheme, GIMP Script-Fu Console
;(define echo-submit gimp-message)  ; GIMP Script-Fu Console
;(define echo-submit print) ; GIMP Script-Fu Console
(define echo-submit (lambda (x) (display x) (newline))) ; TinyScheme, GIMP Script-Fu Console

;;
;; target functions to test (example)

; string is blank
(define (example-is-blank? str)
  (if (string=? "" str) #t #f))

; int-to-boolean: int(TRUE/FALSE) -> boolean
(define (example-int-to-boolean int)
  (if (eqv? TRUE int) #t #f))

; boolean-to-string: boolean(TRUE/FALSE) -> string
(define (example-boolean-to-string bool)
  (if (eqv? TRUE bool) "true" "false"))

;;
;; test helper functions

; stringify: object list -> string (with delimited)
(define (stringify delimiter . objects)
  (apply stringify-base (cons write (cons delimiter objects)))
  ;(apply stringify-base (cons display (cons delimiter objects)))
)

; stringify: object list -> string (with delimited)
(define (stringify-base output-procedure delimiter . objects)
  (let *
    ((port (open-output-string)))

    (define (write-to-string delimiter objects port)
      (unless (eq? () objects)
        (output-procedure (car objects) port)
        (write-char delimiter port)
        (write-to-string delimiter (cdr objects) port)
      )
    )

    (write-to-string delimiter objects port)
    (car (cons (get-output-string port) (close-port port)))
  )
)

; describe-list: values descriptions -> string
;    string[0] value[0] string[1] value[1] ... value[n] string[n+1]
;    if descriptions is shorter than values, use "" for the rest
(define (describe-list values . descriptions)
  (define (describe-values values descriptions)
    (if (eq? () values)
      (list (car descriptions))
      (cons (car descriptions)
        (cons (car values)
          (describe-values (cdr values)
            (if (eq? () (cdr descriptions))
              (list "")
              (cdr descriptions)
            )
          )
        )
      )
    )
  )

  (apply stringify-base (cons display (cons #\Space (describe-values values descriptions))))
)


; run-a-case: execute a single test from the case
; return #t if the test is passed, #f otherwise
; (run-a-case '(function expected arguments ...))
(define (run-a-case test)
  (let*
    (
      (function (car test))
      (expected (cadr test))
      (arguments (cddr test))
      (realized (apply (eval function) arguments))
    )
    (debug function expected arguments realized)  ; output details
    (equal? expected realized)
    ; use equal? on GIMP Script-Fu Console
    ; (load "./string_equal.scm") on Ubuntu TinyScheme 1.42 to use (equal? )
    ;(eqv? expected realized)
    ; on Ubutu TinyScheme 1.42 both equal? and string=? fails for string
    ; `Error: string-ref: index must be exact: 0
    ; using eqv? always tells #f for string comparison, but still works for other types
  )
)

; run-cases: execute all tests in the case
; return a list of #t/#f for each test
; (run-cases '((function expected arguments ...) ...))
(define (run-cases testCase)
  (map run-a-case testCase)
)

; human-readable-result: convert #t/#f list to "PASS"/"FAIL" list
; (human-readable-result '(#t #f #t))
(define (human-readable-result result)
  (map
    (lambda (x)
      (if x
          "pass"
          "FAIL"))
    result
  )
)

; list+: add two numeric lists
; (list+ '(1 2 3) '(4 5 6))
; return a list of sum of each element
(define (list+ list1 list2)
  (if (or (eq? () list1) (eq? () list2))  ; if either list is empty
    ()
    (cons (+ (car list1) (car list2)) (list+ (cdr list1) (cdr list2)))
  )
)

; calculate-score: calculate the score from the result
; (calculate-score '(#t #f #t))
; return a list of fail, pass, and total
(define (calculate-score result)
  (define (count-score result score)
    (if (eq? () result)
      score
      (count-score (cdr result)
        (list+
          score
          (list
            (if (car result) 0 1)  ; fail
            (if (car result) 1 0)  ; pass
            1  ; total
          )
        )
      )
    )
  )

  ;                 fail pass total
  (count-score result '(0 0 0))
)

; human-readable-score: convert score to human-readable string
; (human-readable-score '(1 2 3))
(define (human-readable-score score)
  ;(describe-list score "Fail" "Pass" "Total")
  (describe-list score "" "failed." "passed.  Of total" "tests.")
)

; list-select: select item that mets condition from list
; (list-select '(1 2 3) (lambda (i) (eqv? 2 i)))
(define (list-select list func)
  (let loop ((i 0))
    (if (eqv? i (length list))
      ()
      (let*
        (
          (item (list-ref list i))
          (i2 (+ 1 i))
          (select? ((eval func) item))
        )
        (if select?
          (cons item (list-select (list-tail list i2) func))
          (loop i2)
        )
      )
    )
  )
)

; list-select-by-list: select item from list by the 2nd list,
; that matches 3rd value.
; (list-select-by-list '(1 2 3) '(#f #t #f) #t
(define (list-select-by-list list boolean-list value)
  (let loop ((i 0))
    (if (eqv? i (length list))
      ()
      (let*
        (
          (item (list-ref list i))
          (i2 (+ 1 i))
          (select? (eqv? value (list-ref boolean-list i)))
        )
        (if select?
          (cons item (list-select-by-list
              (list-tail list i2)
              (list-tail boolean-list i2)
              value
            )
          )
          (loop i2)
        )
      )
    )
  )
)

; submit-test: run the test case and output the result
; (submit-test '((function expected arguments ...) ...))
(define (submit-test testCase)
  (let*
    (
      (result (run-cases testCase))
      (score (calculate-score result))
    )
    (echo-submit (apply stringify-base (cons display (cons DELIMITER (human-readable-result result)))))
    (echo-submit (human-readable-score score))

    ; show additional information for failed tests
    (if #t  ; change this do enable/disable
      (if (zero? (car score))
        (echo-submit "Very good!")
        (begin
          (echo-submit "")
          (echo-submit "Failed tests")
          (echo-submit (apply stringify-base (cons display (cons #\Newline (list-select-by-list testCase result #f)))))
        )
      )
    )
  )
)

; test-myself: run self test
; (test-myself)
(define (test-myself)
  (debug "# begin self test.")

  (debug "# show-info")
  (show-info "show-info begin" 1 2 3 '(4 5 6) "show-info end")

  (debug "# stringify")
  (debug (stringify #\Newline "a" "b" "c"))
  (debug (stringify #\: 1 2 #f stringify "a" '(5 6 7)))

  (debug "# describe-list")
  (debug (describe-list '(1 2 3) "one" "two" "three"))
  (debug (describe-list '(1 2 3) "one" "two" "three" "four"))
  (debug (describe-list '(1 2 3) "one" "two"))

  (debug "# run-a-case")
  (debug (run-a-case '(example-is-blank? #f "not blank")))

  (debug "# run-cases")
  (debug (run-cases
      '(

        (
          example-is-blank? ; function
          #f  ; expected return
          "not blank" ; arguments from here
        )
        (
          example-is-blank? ; function
          #t  ; expected return
          "" ; arguments from here
        )
        (
          example-is-blank? ; function
          #t  ; expected return
          "blank?" ; arguments from here
        )

      )
    )
  )

  (debug "# human-readable-result")
  (debug (human-readable-result '(#t #f #t)))

  (debug "# list+")
  (debug (list+ '(1 2 3) '(4 5 6)))
  (debug (list+ '(1 2 3) '()))
  (debug (list+ '() '(4 5 6)))
  (debug (list+ '() '()))
  (debug (list+ '(1 2 3) '(4 5)))
  (debug (list+ '(1 2) '(4 5 6)))

  (debug "# calculate-score")
  (debug (calculate-score '(#t #f #t)))

  (debug "# human-readable-score")
  (debug (human-readable-score '(1 2 3)))

  (debug "# submit-test")
  (example-submit-test)

  (debug "# end self test.")
)

; example test case
(define (example-submit-test)
  (let*
    (
      (testCase
        '(

          (
            example-is-blank? ; function
            #f  ; expected return
            "not blank" ; arguments from here
          )
          (
            example-is-blank? ; function
            #t  ; expected return
            "" ; arguments from here
          )

          (
            list-select ; function
            (1 2 3)  ; expected return
            (0 1 2 3 4 5)  ; argumetns from here
            (lambda (i) (and (< i 4) (> i 0)))
          )
          (
            list-select ; function
            ()  ; expected return
            (0 1 2 3 4 5)  ; argumetns from here
            string?
          )

          (
            list-select-by-list ; function
            (2 3)  ; expected return
            (0 1 2 3 4 5)  ; argumetns from here
            (#f #f #t #t #f #f)
            #t
          )
          (
            list-select-by-list ; function
            (0 1 4 5)  ; expected return
            (0 1 2 3 4 5)  ; argumetns from here
            (#f #f #t #t #f #f)
            #f
          )

        )
      )
    )
    (submit-test testCase)
  )
)

;(example-submit-test)
;(test-myself)

; hint: this will run test-myself without editing this file
; sed '$a(test-myself)' test.scm | tinyscheme -
