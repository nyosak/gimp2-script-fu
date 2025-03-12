#!/usr/bin/env tinyscheme
; Tiny Scheme tool for type conversioning
; copyright 2025, hanagai
;
; string_equal_testcase.scm
; version: March 12, 2025
;
; copy and paste the code to your script
; or load this file by (load "/path/to/string_equal_testcase.scm")
;
; test case for string_equal.scm
; the file is divided because too huge file cannot be loaded in TinyScheme

(load "./string_equal.scm")

; test
(if (not (defined? `submit-test))
  (load "./test.scm")
)

(define (string-equal-submit-test)
  (let *
    (
      (testCase
        '(

          (
            string->byte-list ; function
            (97 98 99)  ; expected return
            "abc" ; arguments from here
          )
          (
            string->byte-list ; function
            (227 130 162 227 130 164)  ; expected return
            "アイ" ; arguments from here
          )
          (
            string->byte-list ; function
            (97 227 129 130 65)   ; expected return
            "aあA" ; arguments from here
          )

          (
            byte-length-utf8 ; function
            1  ; expected return
            #x61 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            -1  ; expected return
            #xA3 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            2  ; expected return
            #xC3 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            3  ; expected return
            #xE3 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            1  ; expected return
            #b01111111 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            -1  ; expected return
            #b10000000 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            -1  ; expected return
            #b10111111 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            2  ; expected return
            #b11000000 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            2  ; expected return
            #b11011111 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            3  ; expected return
            #b11100000 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            3  ; expected return
            #b11101111 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            4  ; expected return
            #b11110000 ; arguments from here
          )
          (
            byte-length-utf8 ; function
            0  ; expected return
            #b11111111 ; arguments from here
          )

          (
            code-points-utf8 ; function
            (1 1 1)  ; expected return
            (97 98 99) ; arguments from here
          )
          (
            code-points-utf8 ; function
            (3 -1 -1 3 -1 -1)  ; expected return
            (227 130 162 227 130 164) ; arguments from here
          )
          (
            code-points-utf8 ; function
            (1 3 -1 -1 1)  ; expected return
            (97 227 129 130 65) ; arguments from here
          )

          (
            string->byte-list-with-code-point-utf8 ; function
            ((97 . 1) (98 . 1) (99 . 1))  ; expected return
            "abc" ; arguments from here
          )
          (
            string->byte-list-with-code-point-utf8 ; function
            ((227 . 3) (130 . -1) (162 . -1) (227 . 3) (130 . -1) (164 . -1))  ; expected return
            "アイ" ; arguments from here
          )
          (
            string->byte-list-with-code-point-utf8 ; function
            ((97 . 1) (227 . 3) (129 . -1) (130 . -1) (65 . 1))  ; expected return
            "aあA" ; arguments from here
          )

          (
            string->multi-byte-list ; function
            ((97) (98) (99))  ; expected return
            "abc" ; arguments from here
          )
          (
            string->multi-byte-list ; function
            ((227 130 162) (227 130 164))  ; expected return
            "アイ" ; arguments from here
          )
          (
            string->multi-byte-list ; function
            ((97) (227 129 130) (65))  ; expected return
            "aあA" ; arguments from here
          )

          (
            string-length-char ; function
            3  ; expected return
            "abc" ; arguments from here
          )
          (
            string-length-char ; function
            2  ; expected return
            "アイ" ; arguments from here
          )
          (
            string-length-char ; function
            3  ; expected return
            "aあA" ; arguments from here
          )

          (
            string-ref-byte ; function
            98  ; expected return
            "abc" ; arguments from here
            1
          )
          (
            string-ref-byte ; function
            162  ; expected return
            "アイ" ; arguments from here
            2
          )

          (
            string-ref-string ; function
            "b"  ; expected return
            "abc" ; arguments from here
            1
          )
          (
            string-ref-string ; function
            "イ"  ; expected return
            "アイ" ; arguments from here
            1
          )

          (
            car-string ; function
            "a"  ; expected return
            "abc" ; arguments from here
          )
          (
            car-string ; function
            "ア"  ; expected return
            "アイ" ; arguments from here
          )

          (
            cdr-string ; function
            "bc"  ; expected return
            "abc" ; arguments from here
          )
          (
            cdr-string ; function
            "イ"  ; expected return
            "アイ" ; arguments from here
          )

          (
            string->string-list ; function
            ("a" "b" "c") ; expected return
            "abc" ; arguments from here
          )
          (
            string->string-list ; function
            ("ア" "イ") ; expected return
            "アイ" ; arguments from here
          )

          (
            number-list=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            (1 2 3)
          )
          (
            number-list=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (1 2 4)
          )
          (
            number-list=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (1 2)
          )
          (
            number-list=? ; function
            #t  ; expected return
            () ; arguments from here
            ()
          )

          (
            number-list-head=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            (1 2)
          )
          (
            number-list-head=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (1 4)
          )
          (
            number-list-head=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            (1 2 3)
          )
          (
            number-list-head=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (1 2 3 4)
          )
          (
            number-list-head=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            ()
          )

          (
            number-list-tail=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            (2 3)
          )
          (
            number-list-tail=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (3 3)
          )
          (
            number-list-tail=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            (1 2 3)
          )
          (
            number-list-tail=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (0 1 2 3)
          )
          (
            number-list-tail=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            ()
          )

          (
            string-start-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "a"
          )
          (
            string-start-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "ab"
          )
          (
            number-list-tail=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            (2 3)
          )
          (
            number-list-tail=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (3 3)
          )
          (
            number-list-tail=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            (1 2 3)
          )
          (
            number-list-tail=? ; function
            #f  ; expected return
            (1 2 3) ; arguments from here
            (0 1 2 3)
          )
          (
            number-list-tail=? ; function
            #t  ; expected return
            (1 2 3) ; arguments from here
            ()
          )

          (
            string-start-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "a"
          )
          (
            string-start-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "ab"
          )
          (
            string-start-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "bc"
          )
          (
            string-start-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "abcd"
          )
          (
            string-start-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "abc"
          )
          (
            string-start-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            ""
          )
          (
            string-start-with? ; function
            #t  ; expected return
            "aあbc" ; arguments from here
            "aあ"
          )
          (
            string-start-with? ; function
            #f  ; expected return
            "あbc" ; arguments from here
            "aあ"
          )

          (
            string-end-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "bc"
          )
          (
            string-end-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "ab"
          )
          (
            string-end-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "abcd"
          )
          (
            string-end-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "abc"
          )
          (
            string-end-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            ""
          )
          (
            string-end-with? ; function
            #t  ; expected return
            "aあbc" ; arguments from here
            "あbc"
          )
          (
            string-end-with? ; function
            #f  ; expected return
            "あbc" ; arguments from here
            "aあ"
          )

          (
            string=? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "abc"
          )
          (
            string=? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "def"
          )
          (
            string=? ; function
            #t  ; expected return
            "" ; arguments from here
            ""
          )
          (
            string=? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "abcd"
          )
          (
            string=? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "ab"
          )
          (
            string=? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "abcd"
          )
          (
            string=? ; function
            #t  ; expected return
            "aあbc" ; arguments from here
            "aあbc"
          )
          (
            string=? ; function
            #f  ; expected return
            "aあbc" ; arguments from here
            "aあb"
          )

          (
            equal? ; function
            #t  ; expected return
            3 ; arguments from here
            3
          )
          (
            equal? ; function
            #f  ; expected return
            3 ; arguments from here
            "a"
          )
          (
            equal? ; function
            #f  ; expected return
            "a" ; arguments from here
            3
          )
          (
            equal? ; function
            #t  ; expected return
            "a" ; arguments from here
            "a"
          )
          (
            equal? ; function
            #f  ; expected return
            "a" ; arguments from here
            "b"
          )

        )
      )
    )
    (submit-test testCase)
  )
)

(string-equal-submit-test)
