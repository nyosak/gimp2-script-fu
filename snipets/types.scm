#!/usr/bin/env tinyscheme
; Tiny Scheme tool for type conversioning
; copyright 2025, hanagai
;
; types.scm
; version: March 10, 2025
;
; copy and paste the code to your script
; or load this file by (load "/path/to/types.scm")

; is-blank?: string -> boolean
; string is blank, or not
; Returns #t if the string is blank, otherwise #f.
; (is-blank? "") ; Returns #t
; (is-blank? "not blank") ; Returns #f
(define (is-blank? str)
  (if (string=? "" str) #t #f))

; int->boolean: int(TRUE/FALSE) -> boolean
; Convert int to boolean
; Returns #t if the int is 1, otherwise #f.
; on TinyScheme, TRUE and FALSE are not defined.
;   (int->boolean 1) ; Returns #t
;   (int->boolean 0) ; Returns #f
; on GIMP Script-Fu Console, TRUE and FALSE are defined as 1 and 0.
;   (int->boolean TRUE) ; Returns #t
;   (int->boolean FALSE) ; Returns #f
(define (int->boolean int)
  (if (eqv? (if (defined? 'TRUE) TRUE 1) int) #t #f))
  ;(if (eqv? TRUE int) #t #f))

; boolean->string: boolean -> string
; Convert boolean to string
; Returns "TRUE" if the boolean is #t, otherwise "FALSE".
; (boolean->string #t) ; Returns "TRUE"
; (boolean->string #f) ; Returns "FALSE"
(define (boolean->string bool)
  (if bool "TRUE" "FALSE"))

; int-boolean->string: int(TRUE/FALSE) -> string
; Convert int(TRUE/FALSE) to string
; Returns "TRUE" if the int is 1, otherwise "FALSE".
; on TinyScheme, TRUE and FALSE are not defined.
;   (int-boolean->string 1) ; Returns "TRUE"
;   (int-boolean->string 0) ; Returns "FALSE"
; on GIMP Script-Fu Console, TRUE and FALSE are defined as 1 and 0.
;   (int-boolean->string TRUE) ; Returns "TRUE"
;   (int-boolean->string FALSE) ; Returns "FALSE"
(define (int-boolean->string int)
  (boolean->string (int->boolean int)))


; test
(load "./test.scm")

(define (types-submit-test)
  (let *
    (
      (testCase
        '(

          (
            is-blank? ; function
            #f  ; expected return
            "not blank" ; arguments from here
          )
          (
            is-blank? ; function
            #t  ; expected return
            "" ; arguments from here
          )

          (
            int->boolean ; function
            #f  ; expected return
            0 ; arguments from here
          )
          (
            int->boolean ; function
            #t  ; expected return
            1 ; arguments from here
          )

          (
            boolean->string ; function
            "FALSE"  ; expected return
            #f ; arguments from here
          )
          (
            boolean->string ; function
            "TRUE"  ; expected return
            #t ; arguments from here
          )

          (
            int-boolean->string ; function
            "FALSE"  ; expected return
            0 ; arguments from here
          )
          (
            int-boolean->string ; function
            "TRUE"  ; expected return
            1 ; arguments from here
          )

        )
      )
    )
    (submit-test testCase)
  )
)

(types-submit-test)
