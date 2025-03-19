; Tiny Scheme tool for type conversioning
; copyright 2025, hanagai
;
; string_equal.scm
; version: March 13, 2025
;
; copy and paste the code to your script
; or load this file by (load "/path/to/string_equal.scm")
;
; test case for this file is located at string_equal_testcase.scm

;;
;; work around the bug on built-in string comparison
;;
; At Ubuntu 22.04, TinyScheme 1.42, string-ref is not working properly,
; it affects string=? and equal? functions, at least.
; Built-in functions may calling each other internally,
; so we override string=? and equal?, instead of string-ref.

; string->byte-list: string -> byte-list
; Returns a list of byte values of the characters in the string.
; (string->byte-list "abc") ; Returns (97 98 99)
; (string->byte-list "アイ") ; Returns (227 130 162 227 130 164)
(define (string->byte-list str)
  (let *
    ((port (open-input-string str)))

    (define (read-byte-from-string port)
      (unless (eof-object? (peek-char port))
        (cons
          (char->integer (read-char port))
          (read-byte-from-string port)
        )
      )
    )

    (car (cons (read-byte-from-string port) (close-port port)))
  )
)

; byte-length-utf8: 1st byte -> int
; Returns the byte length of a UTF-8 character expected by the 1st byte.
; (byte-length-utf8 #x61) ; Returns 1
; (byte-length-utf8 #xA3) ; Returns 2
; (byte-length-utf8 #xE3) ; Returns 3
(define (byte-length-utf8 first-byte)
  (cond
    ((< first-byte #x80) 1)  ; 0xxxxxxx
    ((< first-byte #xC0) -1) ; 10xxxxxx (intermediate)
    ((< first-byte #xE0) 2)  ; 110xxxxx
    ((< first-byte #xF0) 3)  ; 1110xxxx
    ((< first-byte #xF8) 4)  ; 11110xxx
    (else 0)
  )
)

; code-points-utf8: byte-list -> int-list
; Returns a list of code point of the UTF-8 characters in the byte list.
; expects the byte list of a string, that returned by string->byte-list.
; (code-points-utf8 (string->byte-list "abc")) ; Returns (1 1 1)
; (code-points-utf8 (string->byte-list "アイ")) ; Returns (3 -1 -1 3 -1 -1)
; (code-points-utf8 (string->byte-list "aあA")) ; Returns (1 3 -1 -1 1)
(define (code-points-utf8 bytes)
  (map (lambda (byte) (byte-length-utf8 byte)) bytes)
)

; string->byte-list-with-code-point-utf8: string -> (byte . int)-list
; Returns a list of byte values of the characters in the string with byte length.
; (string->byte-list-with-code-point-utf8 "abc") ; Returns ((97 . 1) (98 . 1) (99 . 1))
; (string->byte-list-with-code-point-utf8 "アイ") ; Returns ((227 . 3) (130 . -1) (162 . -1) (227 . 3) (130 . -1) (164 . -1))
; (string->byte-list-with-code-point-utf8 "aあA") ; Returns ((97 . 1) (227 . 3) (129 . -1) (130 . -1) (65 . 1))
(define (string->byte-list-with-code-point-utf8 str)
  (map
    (lambda (byte)
      (cons byte (byte-length-utf8 byte)))
    (string->byte-list str)
  )
)

; string->multi-byte-list: string -> multi-byte-list
; Returns a list of list of byte values of the characters in the string.
; (string->multi-byte-list "abc") ; Returns ((97) (98) (99))
; (string->multi-byte-list "アイ") ; Returns ((227 130 162) (227 130 164))
(define (string->multi-byte-list str)
  (define (handle-first-utf8-char bytes)
    (let loop ((i 0) (r ()))
      (if (eqv? i (length bytes))
        r
        (let*
          (
            (byte (list-ref bytes i)) ; current byte
            (i2 (+ 1 i))  ; prepare for next
            (r1 (cons byte r))  ; result of this turn
          )
          (case (cdr byte)
            ((0) (error "Not UTF-8 encoded"))
            ((-1) (loop i2 r1)) ; intermediate defined at byte-length-utf8
            (else
              (if (eqv? i2 (cdr byte))
                (cons
                  r1
                  (handle-first-utf8-char (list-tail bytes i2))
                )
                (error "Broken UTF-8 encoding")
              )
            )
          )
        )
      )
    )
  )

  ; we want to scan the string from the end at above loop
  ; to catch the 1st byte as a break point,
  ; so we reverse the list.
  ; finally, remove the code point information.
  (map (lambda (x) (map car x))
    (reverse (handle-first-utf8-char
      (reverse (string->byte-list-with-code-point-utf8 str))
    ))
  )
)

; string-length-char: string -> int
; Returns the number of characters in the string.
; (string-length-char "abc") ; Returns 3
; (string-length-char "アイ") ; Returns 2
; (string-length-char "aあA") ; Returns 3
; While string-length is based on the byte length,
; this function is based on the character length.
(define (string-length-char str)
  (length (string->multi-byte-list str))
)

; string-ref-byte: string int -> byte
; Returns the byte value at the specified index in the string.
; (string-ref-byte "abc" 1) ; Returns 98
; (string-ref-byte "アイ" 2) ; Returns 162
; The definition of string-ref is ambiguous on mulit-byte characters,
; so we define string-ref-byte instead of string-ref.
(define (string-ref-byte str index)
  (list-ref (string->byte-list str) index)
)

; string-ref-string: string int -> string
; Returns the character at the specified index in the string.
; (string-ref-string "abc" 1) ; Returns "b"
; (string-ref-string "アイ" 2) ; Returns "イ"
; This index is based on the string length, not the byte length,
; so it retuns a character string instead of the character itself.
(define (string-ref-string str index)
  (let
    (
      (port (open-output-string))
      (bytes (list-ref (string->multi-byte-list str) index))
    )
    (for-each
      (lambda (byte) (write-char (integer->char byte) port))
      bytes
    )
    (car (cons (get-output-string port) (close-port port)))
  )
)

; substring-char: string start end -> string
; Retuns a new string between start and end in the string.
; (substring-char "abc" 1) ; Returns "bc"
; (substring-char "aアイbc" 2 3) ; Returns "イb"
; Start and end are based on the character index, not the byte index.
(define (substring-char str start . end)
  (let
    (
      (port (open-output-string))
      (bytes-list (apply sublist (cons (string->multi-byte-list str) (cons start end))))
    )
    (for-each
      (lambda (bytes)
        (for-each
          (lambda (byte) (write-char (integer->char byte) port))
          bytes
        )
      )
      bytes-list
    )
    (car (cons (get-output-string port) (close-port port)))
  )
)

; sublist: list start end -> list
; Returns a new list between start and end of the list.
; (sublist '(1 2 3 4 5) 2) ; Returns (3 4 5)
; (sublist '(1 2 3 4 5) 2 3) ; Returns (3 4)
(define (sublist list start . end)
  (let
    ((tail (list-tail list start)))
    (if (null? end)
      tail
      (reverse
        (list-tail (reverse tail) (- (length list) (car end) 1))
      )
    )
  )
)

; car-string: string -> string
; Returns the first character in the string.
; (car-string "abc") ; Returns "a"
; (car-string "アイ") ; Returns "ア"
(define (car-string str)
  (string-ref-string str 0)
)

; cdr-string: string -> string
; Returns the string without the first character.
; (cdr-string "abc") ; Returns "bc"
; (cdr-string "アイ") ; Returns "イ"
(define (cdr-string str)
  (let
    ((byte-length-of-1st-char (string-length-buitlin (car-string str))))
    (substring-builtin str byte-length-of-1st-char (string-length-buitlin str))
  )
)

; string->string-list: string -> list of string
; Returns list of string splitted by a character
; (string->string-list "abc") ; Returns ("a" "b" "c")
; (string->string-list "アイ") ; Returns ("ア" "イ")
(define (string->string-list str)
  (map
    (lambda (char-byte)
      (let
        ((port (open-output-string)))
        (for-each
          (lambda (byte)
            (write-char (integer->char byte) port)
          )
          char-byte
        )
        (car (cons (get-output-string port) (close-port port)))
      )
    )
    (string->multi-byte-list str)
  )
)


; number-list=?: number-list number-list -> boolean
; Returns #t if the two number lists are equal, otherwise #f.
; (number-list=? (1 2 3) (1 2 3)) ; Returns #t
; (number-list=? (1 2 3) (1 2 4)) ; Returns #f
; (number-list=? (1 2 3) (1 2)) ; Returns #f
; This function works only for the flat list of numbers.
(define (number-list=? list1 list2)
  (if (eqv? (length list1) (length list2))
    (if (null? list1)
      #t
      (if (eqv? (car list1) (car list2))
        (number-list=? (cdr list1) (cdr list2))
        #f
      )
    )
    #f
  )
)

; number-list-head=?: number-list number-list -> boolean
; Returns #t if the 2nd number equals to the head of 1st number, otherwise #f.
; (number-list-head=? (1 2 3) (1 2)) ; Returns #t
; (number-list-head=? (1 2 3) (1 4)) ; Returns #f
; (number-list-head=? (1 2 3) (1 2 3)) ; Returns #t
; (number-list-head=? (1 2 3) (1 2 3 4)) ; Returns #f
; (number-list-head=? (1 2 3) ()) ; Returns #t
; This function works only for the flat list of numbers.
(define (number-list-head=? list1 list2)
  (if (>= (length list1) (length list2))
    (if (null? list2)
      #t
      (if (eqv? (car list1) (car list2))
        (number-list-head=? (cdr list1) (cdr list2))
        #f
      )
    )
    #f
  )
)

; number-list-tail=?: number-list number-list -> boolean
; Returns #t if the 2nd number equals to the tail of 1st number, otherwise #f.
; (number-list-tail=? (1 2 3) (2 3)) ; Returns #t
; (number-list-tail=? (1 2 3) (3 3)) ; Returns #f
; (number-list-tail=? (1 2 3) (1 2 3)) ; Returns #t
; (number-list-tail=? (1 2 3) (0 1 2 3)) ; Returns #f
; (number-list-tail=? (1 2 3) ()) ; Returns #t
; This function works only for the flat list of numbers.
(define (number-list-tail=? list1 list2)
  (number-list-head=? (reverse list1) (reverse list2))
)

; string-start-with?: string string -> boolean
; Returns #t if the 1st string starts with the 2nd string, otherwise #f.
; (string-start-with? "abc" "ab") ; Returns #t
; (string-start-with? "abc" "bc") ; Returns #f
; (string-start-with? "abc" "abcd") ; Returns #f
; (string-start-with? "abc" "abc") ; Returns #t
; (string-start-with? "abc" "") ; Returns #t
; (string-start-with? "aあbc" "aあ") ; Returns #t
; (string-start-with? "あbc" "aあ") ; Returns #f
(define (string-start-with? str prefix)
  (number-list-head=? (string->byte-list str) (string->byte-list prefix))
)

; string-end-with?: string string -> boolean
; Returns #t if the 1st string ends with the 2nd string, otherwise #f.
; (string-end-with? "abc" "bc") ; Returns #t
; (string-end-with? "abc" "ab") ; Returns #f
; (string-end-with? "abc" "abcd") ; Returns #f
; (string-end-with? "abc" "abc") ; Returns #t
; (string-end-with? "abc" "") ; Returns #t
; (string-end-with? "aあbc" "あbc") ; Returns #t
; (string-end-with? "あbc" "aあ") ; Returns #f
(define (string-end-with? str suffix)
  (number-list-tail=? (string->byte-list str) (string->byte-list suffix))
)

;;
;; override builtin functions

; string=?: string string -> boolean

; keeps builtin available
(if (not (defined? 'string-builtin=?))
  (define string-builtin=? string=?)
)

; override
(define (string=? str1 str2)
  (number-list=? (string->byte-list str1) (string->byte-list str2))
)

; eual?: obj obj -> boolean

; keeps builtin available
(if (not (defined? 'equal-builtin?))
  (define equal-builtin? equal?)
)

; override
(define (equal? obj1 obj2)
  (if (and (string? obj1) (string? obj2))
    (string=? obj1 obj2)
    (equal-builtin? obj1 obj2)
  )
)

; string-length: string -> integer

; keeps builtin available
(if (not (defined? 'string-length-buitlin))
  (define string-length-buitlin string-length)
)

; override
(define string-length string-length-char)

; substring: string start end -> string

; keeps builtin available
(if (not (defined? 'substring-builtin))
  (define substring-builtin substring)
)

; override
(define substring substring-char)

