#!/usr/bin/env tinyscheme
; Tiny Scheme tool for tree structure
; copyright 2025, hanagai
;
; tree.scm
; version: March 21, 2025
;
; copy and paste the code to your script
; or load this file by (load "/path/to/tree.scm")
;
; read the output of tools/android_icon_specification.py


; string=?: string string -> boolean
; string equivalence by value
; Returns #t if strings have same value, otherwise #f.
; (string=? "ab" "ab") ; Returns #t
; (string=? "aa" "ab") ; Returns #f
; NOT REQUIRED on GIMP script-fu
; intends to override the buggy builtin function on TinyScheme
(define (string=? str1 str2)
  (eq? (string->symbol str1) (string->symbol str2))
)

;
; above here is NOT REQUIRED on GIMP script-fu
;

; the tree structure
;
; tree consists of nested list,
; having a node identifier character as a 1st item.
;
;   ( #\L          ; nodes
;     ( #\N        ; node
;       ( #\A      ; attributes
;         (        ; an attribute is represented by a pair
;           "size" ; key
;         .
;           96     ; value
;         )
;       )
;       ( #\H      ; node body is nodes or hierarchy
;         "/home/kuro"
;         "tmp/art_work"
;
; a node is a list of 3 items:
;   1st: node identifier char
;   2nd: attributes
;   3rd: node body (child nodes or hierarchy list)


; enum-node-type: list of char
; define enumerations of identifiers for node types
(define enum-node-type
  '(
    #\L ; "nodes"
    #\N ; "node"
    #\A ; "attributes"
    #\H ; "hierarchy"
  )
)

; invalid-node-type: char
; undefined type of node (means error)
(define invalid-node-type #\Space)

; empty-list: ()
; empty, null
(define empty-list '())

; get-node-identifier: list -> char (expected)
; get an identifier of node
; 1st item
(define (get-node-identifier node)
  (car node)
)

; get-node-body: list -> list (expected)
; get node itself from which an identifier is removed
; 2nd item and after
(define (get-node-body node)
  (cdr node)
)

; get-1st-node-body: list -> list (expected)
; get 1st item of node body
; 2nd item of list
; eg. attributes of node
(define (get-1st-node-body node)
  (cadr node)
)

; get-2nd-node-body: list -> list (expected)
; get 2nd item of node body
; 3rd item of list
; eg. body of node without attributes
(define (get-2nd-node-body node)
  (caddr node)
)

; get-attribute-key: pair -> string (expected)
; get a key of an attribute
(define (get-attribute-key pair)
  (car pair)
)

; get-attribute-key: pair -> string or integer (expected)
; get a value of an attribute
(define (get-attribute-value pair)
  (cdr pair)
)

; valid-node-type?: char (expected) -> boolean
; validate node identifier
; Returns #t if the identifier is the one listed, otherwise #f.
(define (valid-node-type? obj)
  (and
    (char? obj)
    (foldr (lambda (x c) (or x (char=? c obj))) #f enum-node-type)
  )
)

; char-node-type: char (expected) -> char (one of the listed or undefined)
; convert the char to undefined identifire when it's not listed.
; (char-node-type #\L) ; Returns #\L
; (char-node-type #\H) ; Returns #\H
; (char-node-type #\X) ; Returns #\Space
; (char-node-type "H") ; Returns #\Space
(define (char-node-type obj)
  (if (valid-node-type? obj) obj invalid-node-type)
)

; node-type: list (expected) -> char (one of the listed or undefined)
; Returns valid identifier of specified node, or undefined identifier.
(define (node-type obj)
  (if
    (and
      (list? obj)
      (positive? (length obj))
    )
    (char-node-type (get-node-identifier obj))
    invalid-node-type
  )
)

; nodes?: list (expected) -> boolean
; Returns #t if the specified list is a nodes, otherwise #f.
(define (nodes? obj)
  (char=? #\L (node-type obj))
)

; node?: list (expected) -> boolean
; Returns #t if the specified list is a node, otherwise #f.
(define (node? obj)
  (char=? #\N (node-type obj))
)

; attributes?: list (expected) -> boolean
; Returns #t if the specified list is attributes, otherwise #f.
(define (attributes? obj)
  (char=? #\A (node-type obj))
)

; hierarchy?: list (expected) -> boolean
; Returns #t if the specified list is a hierarchy, otherwise #f.
(define (hierarchy? obj)
  (char=? #\H (node-type obj))
)

; nodes-siblings: list (expected) -> list (expected)
; Returns a list of node in the specified nodes
; the identifier is removed
(define (nodes-siblings nodes)
  (get-node-body nodes)
)

; node-attributes: list (expected) -> list (expected)
; Returns a list of attribute of the specified node
(define (node-attributes node)
  (get-1st-node-body node)
)

; node-body: list (expected) -> list (expected)
; Returns a body content of the specified node
(define (node-body node)
  (get-2nd-node-body node)
)

; node-children: list (expected) -> list (expected)
; Returns a child nodes of the specified node
; Returns an empty list if there're no children
(define (node-children node)
  (let
    ((body (node-body node)))
    (if (nodes? body) body empty-list)
  )
)

; node-hierarchy: list (expected) -> list (expected)
; Returns a hierarchy content of the specified node
; Returns an empty list if there is no hierarchy
(define (node-hierarchy node)
  (let
    ((body (node-body node)))
    (if (hierarchy? body) body empty-list)
  )
)

; node-attribute-keys: list (expected) -> list
; Returns a list of key in attributes of the specified node
(define (node-attribute-keys node)
  (map get-attribute-key (node-attributes node))
)

; node-attribute-values: list (expected) -> list
; Returns a list of values in attributes of the specified node
(define (node-attribute-values node)
  (map get-attribute-value (node-attributes node))
)

; node-has-attribute?: list (expected) . optional strings -> boolean
; check if the node has attribute of specified keys
; Return #t if the node has all of keys as attributes, otherwise #f
; Return #t if no keys are specified
(define (node-has-attribute? node . keys)
  (let
    ((attr (node-attributes node)))
    (foldr (lambda (x key) (and x (attribute-has-key? attr key))) #t keys)
  )
)

; node-get-attribute: list (expected) string -> pair (expected)
; Returns an attribute pair from the node by the specified key
; Returns () if the key is not found
(define (node-get-attribute node key)
  (attribute-search-key (node-attributes node) key)
)

; attribute-has-key?: list (expected) string -> boolean
; Returns #t if the attributes has the specified key, otherwise #f
(define (attribute-has-key? attr key)
  (not (null? (attribute-search-key attr key)))
)

; attribute-search-key: list (expected) string -> string or integer (expected)
; search the key in attributes and get the value of it
; Returns () if the key is not found
(define (attribute-search-key attr key)
  (if (zero? (length attr))
    ()
    (if (string=? key (get-attribute-key (car attr)))
      (get-attribute-value (car attr))
      (attribute-search-key (cdr attr) key)
    )
  )
)

; apply-node: func func func func func list (expected) list -> list
; switch functions by node type
; call func-a when the type is attributes
; call func-else when the identifier is unknown
(define (apply-node func-l func-n func-a func-h func-else node opts)
  (let
    (
      (func
        (case (node-type node)
          ((#\L) 'func-l)
          ((#\N) 'func-n)
          ((#\A) 'func-a)
          ((#\H) 'func-h)
          (else 'func-else)
        )
      )
    )
    ((eval func) node opts)
  )
)

; traverse-tree: list (expected) list -> list
; define functions fo apply-node and extract the whole tree
(define (traverse-tree node opts)
  (define (func-l node opts)
    (let
      (
        (depth (get-depth opts))
      )
      (map
        (lambda (n) (traverse-tree n (make-opts (+ 1 depth))))
        (nodes-siblings node)
      )
    )
  )

  (define (func-n node opts)
    (list
      (traverse-tree (node-attributes node) opts)
      (traverse-tree (node-body node) opts)
    )
  )

  (define (func-a node opts)
    `(,node ,opts)

  )

  (define (func-h node opts)
    `(,node ,opts)

  )

  (define (func-else node opts)
    ;`(,node ,opts)
    (if (eqv? empty-list node)
      ()
      ("Unknown contens found")
    )
  )

  (define (get-depth opts)
    (car opts)
  )

  (define (make-opts depth)
    (list depth)
  )

  (apply-node func-l func-n func-a func-h func-else node opts)
)


; test
(load "./test.scm")

(define (tree-submit-test)
  (let*
    (

      (icon-list
        '
        (
          #\L
          (
            #\N
            (
              #\A
              (
                "build"
              .
                "main"
              )
              (
                "shape"
              .
                "square"
              )
            )
            (
              #\L
              (
                #\N
                (
                  #\A
                  (
                    "size"
                  .
                    96
                  )
                )
                (
                  #\H
                  "/home/kuro"
                  "tmp/art_work"
                  "p"
                  "v"
                  "app/src"
                  "main"
                  "res"
                  "mipmap-xhdpi"
                  "ic_launcher.webp"
                )
              )
            )
          )
        )
      )

      (icon-list-vector
        '
        (list
          (vector
            (vector
              (
                "build"
              .
                "main"
              )
              (
                "shape"
              .
                "square"
              )
            )
            (list
              (vector
                (vector
                  (
                    "size"
                  .
                    96
                  )
                )
                (vector
                  "/home/kuro"
                  "tmp/art_work"
                  "p"
                  "v"
                  "app/src"
                  "main"
                  "res"
                  "mipmap-xhdpi"
                  "ic_launcher.webp"
                )
              )
            )
          )
        )
      )

      (icon-list-cons
        '
        (
          (
            (
              (
                "build"
              .
                "main"
              )
              (
                "shape"
              .
                "square"
              )
            )
          .
            (
              (
                (
                  (
                    "size"
                  .
                    96
                  )
                )
              .
                (
                  "/home/kuro"
                  "tmp/art_work"
                  "p"
                  "v"
                  "app/src"
                  "main"
                  "res"
                  "mipmap-xhdpi"
                  "ic_launcher.webp"
                )
              )
            )
          )
        )
      )

      (testCase
        `(

          (
            valid-node-type? ; function
            #t  ; expected return
            #\L ; arguments from here
          )
          (
            valid-node-type? ; function
            #t  ; expected return
            #\N ; arguments from here
          )
          (
            valid-node-type? ; function
            #t  ; expected return
            #\A ; arguments from here
          )
          (
            valid-node-type? ; function
            #t  ; expected return
            #\H ; arguments from here
          )
          (
            valid-node-type? ; function
            #f  ; expected return
            #\x ; arguments from here
          )
          (
            valid-node-type? ; function
            #f  ; expected return
            "L" ; arguments from here
          )

          (
            char-node-type ; function
            #\L  ; expected return
            #\L ; arguments from here
          )
          (
            char-node-type ; function
            #\N  ; expected return
            #\N ; arguments from here
          )
          (
            char-node-type ; function
            #\A  ; expected return
            #\A ; arguments from here
          )
          (
            char-node-type ; function
            #\H  ; expected return
            #\H ; arguments from here
          )
          (
            char-node-type ; function
            #\Space  ; expected return
            #\x ; arguments from here
          )
          (
            char-node-type ; function
            #\Space  ; expected return
            123 ; arguments from here
          )

          (
            node-type ; function
            #\L  ; expected return
            (#\L "body") ; arguments from here
          )
          (
            node-type ; function
            #\N  ; expected return
            (#\N "body") ; arguments from here
          )
          (
            node-type ; function
            #\A  ; expected return
            (#\A "body") ; arguments from here
          )
          (
            node-type ; function
            #\H  ; expected return
            (#\H "body") ; arguments from here
          )
          (
            node-type ; function
            #\Space  ; expected return
            (#\x "body") ; arguments from here
          )
          (
            node-type ; function
            #\Space  ; expected return
            (123 "body") ; arguments from here
          )
          (
            node-type ; function
            #\L  ; expected return
            ,icon-list ; arguments from here
          )
          (
            node-type ; function
            #\N  ; expected return
            ,(list-ref icon-list 1) ; arguments from here
          )
          (
            node-type ; function
            #\A  ; expected return
            ,(list-ref (list-ref icon-list 1) 1) ; arguments from here
          )
          (
            node-type ; function
            #\L  ; expected return
            ,(list-ref (list-ref icon-list 1) 2) ; arguments from here
          )
          (
            node-type ; function
            #\N  ; expected return
            ,(list-ref (list-ref (list-ref icon-list 1) 2) 1) ; arguments from here
          )
          (
            node-type ; function
            #\A  ; expected return
            ,(list-ref (list-ref (list-ref (list-ref icon-list 1) 2) 1) 1) ; arguments from here
          )
          (
            node-type ; function
            #\H  ; expected return
            ,(list-ref (list-ref (list-ref (list-ref icon-list 1) 2) 1) 2) ; arguments from here
          )

          (
            nodes? ; function
            #t  ; expected return
            ,icon-list ; arguments from here
          )

          (
            traverse-tree ; function
            "expects fail"  ; expected return
            ,icon-list ; arguments from here
            (0)
          )

        )
      )
    )
    (submit-test testCase)
    (write icon-list)
    (newline)
  )
)

(tree-submit-test)
