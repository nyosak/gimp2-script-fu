#!/usr/bin/env tinyscheme
; Tiny Scheme tool for string manipuration
; copyright 2025, hanagai
;
; string.scm
; version: March 13, 2025; 17:20 JST
;
; copy and paste the code to your script
; or load this file by (load "/path/to/string.scm")
;
; Expects GIMP2 Script Fu
; where these 3 functions work with UTF-8 strings:
;   string=? substring string-length
; Load string_equal.scm at TinyScheme.
(load "./string_equal.scm")

; DIR-SEPARATOR is pre-defined at GIMP
(if (not (defined? 'DIR-SEPARATOR))
  (define DIR-SEPARATOR "/")
)

; is-blank?: string -> boolean
; string is blank, or not
; Returns #t if the string is blank, otherwise #f.
; (is-blank? "") ; Returns #t
; (is-blank? "not blank") ; Returns #f
(define (is-blank? str)
  (if (zero? (string-length str)) #t #f))

; string-starts-with?: string string -> boolean
; Returns #t if the 1st string starts with the 2nd string, otherwise #f.
; (string-starts-with? "abc" "ab") ; Returns #t
; (string-starts-with? "abc" "bc") ; Returns #f
; (string-starts-with? "abc" "abcd") ; Returns #f
; (string-starts-with? "abc" "abc") ; Returns #t
; (string-starts-with? "abc" "") ; Returns #t
; (string-starts-with? "aあbc" "aあ") ; Returns #t
; (string-starts-with? "あbc" "aあ") ; Returns #f
(define (string-starts-with? str prefix)
  (let
    ((prefix-length (string-length prefix)))
    (if (>= (string-length str) prefix-length)
      (string=? (substring str 0 (- prefix-length 1)) prefix)
      #f
      ; substring ignores -1 for end position, so it works
    )
  )
)

; string-ends-with?: string string -> boolean
; Returns #t if the 1st string ends with the 2nd string, otherwise #f.
; (string-ends-with? "abc" "bc") ; Returns #t
; (string-ends-with? "abc" "ab") ; Returns #f
; (string-ends-with? "abc" "abcd") ; Returns #f
; (string-ends-with? "abc" "abc") ; Returns #t
; (string-ends-with? "abc" "") ; Returns #t
; (string-ends-with? "aあbc" "あbc") ; Returns #t
; (string-ends-with? "あbc" "aあ") ; Returns #f
(define (string-ends-with? str postfix)
  (let*
    (
      (postfix-length (string-length postfix))
      (base-length (string-length str))
      (start (- base-length postfix-length))
    )
    (if (>= (string-length str) postfix-length)
      (string=? (substring str start) postfix)
      #f
    )
  )
)

; ltrim: string string -> string
; Returns a new string that removed the 2nd string at the top of the string.
; (ltrim "abc" "a") ; Returns "bc"
; (ltrim "abc" "b") ; Returns "abc"
; (ltrim "abc" "abc") ; Returns ""
; (ltrim "abcabcd" "abc") ; Returns "d"
(define (ltrim str remove)
  (if (string-starts-with? str remove)
    (ltrim (substring str (string-length remove)) remove)
    str
  )
)

; rtrim: string string -> string
; Returns a new string that removed the 2nd string at the end of the string.
; (rtrim "abc" "c") ; Returns "ab"
; (rtrim "abc" "b") ; Returns "abc"
; (rtrim "abc" "abc") ; Returns ""
; (rtrim "abcdabab" "ab") ; Returns "abcd"
(define (rtrim str remove)
  (if (string-ends-with? str remove)
    (rtrim (substring str 0 (- (string-length str) (string-length remove) 1)) remove)
    str
  )
)

; trim-both-separators: string -> string
; Returns a new string that removed both leading and trailing spaces and directory separators.
; (trim-both-separators " /path/to/dir/ ") ; Returns "path/to/dir"
; (trim-both-separators "/path/to/dir/") ; Returns "path/to/dir"
; (trim-both-separators "path/to/dir") ; Returns "path/to/dir"
; (trim-both-separators " / ") ; Returns ""
(define (trim-both-separators str)
  (ltrim (ltrim
    (rtrim (rtrim str " ") DIR-SEPARATOR)
   " ") DIR-SEPARATOR)
)

; trim-right-separator: string -> string
; Returns a new string that removed both leadnig and trailing spaces,
; and trailing directory separators.
; (trim-right-separator " /path/to/dir/ ") ; Returns "/path/to/dir"
; (trim-right-separator "/path/to/dir/") ; Returns "/path/to/dir"
; (trim-right-separator "path/to/dir") ; Returns "path/to/dir"
; (trim-right-separator " / ") ; Returns ""
; root will be removed to be a blank, but it works with next joining proces.
(define (trim-right-separator str)
  (rtrim (ltrim (rtrim str " ") " ") DIR-SEPARATOR)
)
; (define (trim-right-separator str)
;   (let
;     ((space-trimmed (ltrim (rtrim str " ") " ")))
;     (if (string=? DIR-SEPARATOR space-trimmed)
;       space-trimmed ; root
;       (rtrim space-trimmed DIR-SEPARATOR)
;     )
;   )
; )

; join-file-path: string ... -> string
; join-file-path: string ... -> string
; Joins multiple path segments into a single path.
; (join-file-path "/path" "to" "dir") ; Returns "/path/to/dir"
; (join-file-path "/path/" "to" "dir/") ; Returns "/path/to/dir"
; (join-file-path "path" "to" "dir") ; Returns "path/to/dir"
; (join-file-path "path/" "/to/" "/dir") ; Returns "path/to/dir"
; (join-file-path "path" "//" "to" " " "dir") ; Returns "path/to/dir"
; (join-file-path " / " " home " "user ") ; Returns "/home/user"
(define (join-file-path path1 . paths)
  (define (join-file-path-relatives joined paths)
    (if (null? paths)
      joined
      (let
        (
          (this_segment (trim-both-separators(car paths)))
          (rest (cdr paths))
        )
        (join-file-path-relatives
          (if (is-blank? this_segment)
            joined
            (string-append joined DIR-SEPARATOR this_segment)
          )
          rest
        )
      )
    )
  )

  (join-file-path-relatives (trim-right-separator path1) paths)
)


; test
(load "./test.scm")

(define (string-submit-test)
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
            string-starts-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "ab"
          )
          (
            string-starts-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "bc"
          )
          (
            string-starts-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "abcd"
          )
          (
            string-starts-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "abc"
          )
          (
            string-starts-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            ""
          )
          (
            string-starts-with? ; function
            #t  ; expected return
            "aあbc" ; arguments from here
            "aあ"
          )
          (
            string-starts-with? ; function
            #f  ; expected return
            "あbc" ; arguments from here
            "aあ"
          )

          (
            string-ends-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "bc"
          )
          (
            string-ends-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "ab"
          )
          (
            string-ends-with? ; function
            #f  ; expected return
            "abc" ; arguments from here
            "abcd"
          )
          (
            string-ends-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            "abc"
          )
          (
            string-ends-with? ; function
            #t  ; expected return
            "abc" ; arguments from here
            ""
          )
          (
            string-ends-with? ; function
            #t  ; expected return
            "aあbc" ; arguments from here
            "あbc"
          )
          (
            string-ends-with? ; function
            #f  ; expected return
            "あbc" ; arguments from here
            "aあ"
          )

          (
            ltrim ; function
            "bc" ; expected return
            "abc" ; arguments from here
            "a"
          )
          (
            ltrim ; function
            "abc" ; expected return
            "abc" ; arguments from here
            "b"
          )
          (
            ltrim ; function
            "" ; expected return
            "abc" ; arguments from here
            "abc"
          )
          (
            ltrim ; function
            "d" ; expected return
            "abcabcd" ; arguments from here
            "abc"
          )

          (
            rtrim ; function
            "ab" ; expected return
            "abc" ; arguments from here
            "c"
          )
          (
            rtrim ; function
            "abc" ; expected return
            "abc" ; arguments from here
            "b"
          )
          (
            rtrim ; function
            "" ; expected return
            "abc" ; arguments from here
            "abc"
          )
          (
            rtrim ; function
            "abcd" ; expected return
            "abcdabab" ; arguments from here
            "ab"
          )

          (
            trim-both-separators ; function
            "path/to/dir" ; expected return
            " /path/to/dir/ " ; arguments from here
          )
          (
            trim-both-separators ; function
            "path/to/dir" ; expected return
            "/path/to/dir/" ; arguments from here
          )
          (
            trim-both-separators ; function
            "path/to/dir" ; expected return
            "path/to/dir" ; arguments from here
          )
          (
            trim-both-separators ; function
            "" ; expected return
            " / " ; arguments from here
          )

          (
            trim-right-separator ; function
            "/path/to/dir" ; expected return
            " /path/to/dir/ " ; arguments from here
          )
          (
            trim-right-separator ; function
            "/path/to/dir" ; expected return
            "/path/to/dir/" ; arguments from here
          )
          (
            trim-right-separator ; function
            "path/to/dir" ; expected return
            "path/to/dir" ; arguments from here
          )
          (
            trim-right-separator ; function
            "" ; expected return
            " / " ; arguments from here
          )

          (
            join-file-path ; function
            "/path/to/dir" ; expected return
            "/path" ; arguments from here
            "to"
            "dir"
          )
          (
            join-file-path ; function
            "/path/to/dir" ; expected return
            "/path/" ; arguments from here
            "to"
            "dir/"
          )
          (
            join-file-path ; function
            "path/to/dir" ; expected return
            "path" ; arguments from here
            "to"
            "dir"
          )
          (
            join-file-path ; function
            "path/to/dir" ; expected return
            "path/" ; arguments from here
            "/to/"
            "/dir"
          )
          (
            join-file-path ; function
            "path/to/dir" ; expected return
            "path" ; arguments from here
            "//"
            "to"
            " "
            "dir"
          )
          (
            join-file-path ; function
            "/home/user" ; expected return
            " / " ; arguments from here
            " home "
            "user "
          )

        )
      )
    )
    (submit-test testCase)
  )
)

(string-submit-test)
