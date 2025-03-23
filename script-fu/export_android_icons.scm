; GIMP script to export webp files for android app icons
; copyright 2025, hanagai
;
; export_android_icons.scm
; version: March 23, 2025
;
; use tools/android_icon_specification.py to customize output.
;
; Export Android app icons.
; Works on a copy of current image.
; Iterates build shape and size in all combinations.
; Export as webp file.
; Discard the working copy.

(define (export-android-icons inImage inProject inVersion)

  (let*
    (

      (hierarchy
        '("user_home" "studio_home" "project" "version" "src" "build" "res" "mipmap" "icon_name")
      )

      (arguments
        '(#f #f "project" "version" #f #f #f #f #f)
      )

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

      ; parameters
      (image inImage)     ; current image
      (project inProject) ; project name (required)
      (version inVersion) ; version name (required)

      ; variables
      (return-value #f)  ; store return value
      (parameter-is-missing (or (zero? (string-length project)) (zero? (string-length version)))) ; project or version is missing

      ; constants
      (LOG-FILE "/home/kuro/tmp/log.txt") ; to write info
      (DISCARD-FILE "/dev/null") ; to discard
      (ERROR-PARAMETER-MISSING "ERROR: Both of project and version are required.")  ; message to show when project or version are missing
      (MESSAGE-DONE "Done!")  ; message to show when done
    )

    ;;
    ;; helper functions

    ; from test.scm

    ; TODO only for debug
    ;(load "../snippets/string_equal.scm")

    ;;
    ;; output to file

    ;(define port-log-1 (open-output-file "/home/kuro/tmp/log.txt"))
    ;(close-output-port port-log-1)

    ;;
    ;; (show-info ... args) : outupt multi-line results

    (define (show-info . objs)
      (if (not (eq? () objs))
        (let
          ((port port-log-1))
          ;((port (current-output-port)))
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
        ;(echo (apply stringify (cons DELIMITER (cons obj1 objn))) port)
        ;(newline port)
        (echo-d (apply stringify (cons DELIMITER (cons obj1 objn))))
        (newline)
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
    (define echo-d gimp-message)  ; GIMP Script-Fu Console
    ;(define echo print) ; GIMP Script-Fu Console

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


    ; from tree.scm

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
      (map get-attribute-key (get-node-body (node-attributes node)))
    )

    ; node-attribute-values: list (expected) -> list
    ; Returns a list of values in attributes of the specified node
    (define (node-attribute-values node)
      (map get-attribute-value (get-node-body (node-attributes node)))
    )

    ; node-has-any-attribute?: list (expected) . optional strings -> boolean
    ; check if the node has attribute of specified keys
    ; Return #t if the node has one of keys as attributes, otherwise #f
    ; Return #f if no keys are specified
    (define (node-has-any-attribute? node . keys)
      (if (eq? () keys )
        #f
        (if (node-has-attribute? node (car keys))
          #t
          (apply node-has-any-attribute? (cons node (cdr keys)))
        )
      )
    )

    ; node-has-attribute?: list (expected) . optional strings -> boolean
    ; check if the node has attribute of specified keys
    ; Return #t if the node has all of keys as attributes, otherwise #f
    ; Return #t if no keys are specified
    (define (node-has-attribute? node . keys)
      (let
        ((attr (get-node-body (node-attributes node))))
        (foldr (lambda (x key) (and x (attribute-has-key? attr key))) #t keys)
      )
    )

    ; node-get-attribute: list (expected) string -> string/integer (expected)
    ; Returns an attribute value from the node by the specified key
    ; Returns () if the key is not found
    (define (node-get-attribute node key)
      (attribute-search-key (get-node-body (node-attributes node)) key)
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

    ; node functions

    (define (func-l node opts)
      (show-info "--- func-l ---" node opts)
      (show-info "INFO: nodes at depth:" (get-depth opts))
      (map
        (lambda (n) (example1 n (depth+ opts)))
        (nodes-siblings node)
      )
    )

    (define (func-n node opts)
      (show-info "--- func-n ---" node opts)
      (show-info "INFO: node at depth:" (get-depth opts))
      (list
        (example1 (node-attributes node) opts)
        (example1 (node-body node) opts)
      )
    )

    (define (func-a node opts)
      (show-info "--- func-a ---" node opts)
      (let
        (
          (depth (get-depth opts))
        )
        (show-info "INFO: attributes at depth:" depth)
        (case depth
          ((1) (func-a-1 node opts))
          ((2) (func-a-2 node opts))
          (else "ERROR: Too deep for a human")
        )
      )
    )

    (define (func-a-1 node opts)
      (show-info "--- func-a-1 ---" node opts)
      (let*
        (
          (attr (get-node-body node))
          (image (get-image opts))
        )
        (show-info "INFO: modify image to fit specified build and shape")
        (list
          (if (attribute-has-key? attr "build")
            (let
              ((value (attribute-search-key attr "build")))
              (list
                value
                (handle-build image value)
              )
            )
          )
          (if (attribute-has-key? attr "shape")
            (let
              ((value (attribute-search-key attr "shape")))
              (list
                value
                (handle-shape image value)
              )
            )
          )
        )
      )
    )

    (define (func-a-2 node opts)
      (show-info "--- func-a-2 ---" node opts)
      (let*
        (
          (attr (get-node-body node))
          (image (get-image opts))
        )
        (show-info "INFO: set size to local variable")
        (list
          (if (attribute-has-key? attr "size")
            (list
              ; `size` here is defined at parent scope
              (set! size (attribute-search-key attr "size"))
              (handle-size image size)
            )
          )
        )
      )
    )

    (define (func-h node opts)
      (show-info "--- func-h ---" node opts)
      (let*
        (
          (image (get-image opts))
          (project (get-project opts))
          (version (get-version opts))
          (arguments (get-arguments opts))
          (hierarchy (get-hierarchy opts))
          (new-hierarchy (merge-arguments hierarchy arguments project version))
        )
        (show-info "INFO: reflect arguments (project, version) into hierarchy")
        (show-info hierarchy arguments project version new-hierarchy)
        (export-scaled-webp image size new-hierarchy)
      )
    )

    (define (func-else node opts)
      (show-info "--- func-else ---" node opts)
      (if (eqv? empty-list node)
        ()
        (begin
          (show-info "ERROR: Unknown contens found")
          "ERROR: Unknown contens found"
        )
      )
    )

    ; gimp

    (define (duplicate-image image)
      (show-info "INFO: duplicate current image" image)
      (show-info "TODO: handle GIMP")
      (let
        (
          (new-image 0) ; set new image
          (new-display 0) ; st new display
        )
        (set! new-image (car (gimp-image-duplicate image)))
        (show-info new-image)
        (set! new-display (car (gimp-display-new new-image)))
        (show-info new-display)
        (list new-image new-display)
      )
    )

    (define (discard-image display)
      (show-info "GIMP: delete display and image" display)
      (gimp-display-delete display)
      "INFO: delete display and image"
    )

    (define (handle-build image build)
      (show-info "--- handle-build ---" image build)
      (show-info "INFO: change layer visibility by build")
      (show-info "TODO: handle GIMP")
      (show-info "TODO: remember flush display")
      "INFO: change layer visibility by build"
    )

    (define (handle-shape image shape)
      (show-info "--- handle-shape ---" image shape)
      (show-info "INFO: change layer visibility by shape")
      (show-info "TODO: handle GIMP")
      (show-info "TODO: remember flush display")
      "INFO: change layer visibility by shape"
    )

    (define (handle-size image arg_size)
      (show-info "--- handle-size ---" image arg_size)
      (show-info "INFO: nothing here for GIMP")
      "INFO: nothing here for GIMP"
    )

    (define (export-scaled-webp image arg_size hierarchy)
      (show-info "--- export-scaled-webp ---" image arg_size hierarchy)
      (show-info "INFO: scale image and export as webp")
      (show-info "TODO: handle GIMP")
      "INFO: scale image and export as webp"
    )

    ; helper

    (define (merge-arguments hierarchy arguments project version)
      (if (eq? () hierarchy)
        ()
        (let*
          (
            (h (car hierarchy))
            (a (car arguments))
            (new-h
              (if a
                (if (string=? "project" a)
                  project
                  (if (string=? "version" a)
                    version
                    h
                  )
                )
                h
              )
            )
          )
          (cons new-h (merge-arguments (cdr hierarchy) (cdr arguments) project version))
        )
      )
    )

    ; opts

    (define (get-depth opts)
      (car opts)
    )

    (define (get-after-depth opts)
      (cdr opts)
    )

    (define (get-image opts)
      (cadr opts)
    )

    (define (get-after-image opts)
      (cddr opts)
    )

    (define (get-project opts)
      (caddr opts)
    )

    (define (get-version opts)
      (cadddr opts)
    )

    (define (get-arguments opts)
      (car (cddddr opts))
    )

    (define (get-hierarchy opts)
      (cadr (cddddr opts))
    )

    (define (make-opts depth image project version arguments hierarchy)
      (list depth image project version arguments hierarchy)
    )

    (define (depth+ opts)
      (cons (+ 1 (get-depth opts)) (get-after-depth opts))
    )

    (define (with-image opts image)
      (cons (get-depth opts) (cons image (get-after-image opts)))
    )

    (define (with-image-depth+ opts image)
      (cons (+ 1 (get-depth opts)) (cons image (get-after-image opts)))
    )

    ; internode variable

    ; defines size to communicate between leaves directly
    (define size 0)
    ; Attribute gives size to hierarchy.
    ; It also can be done using paired return value,
    ; (return as node . additional return as attributes including size),
    ; because the both have same parent node.
    ; Maybe, in this example, using wide scope variable seems simpler.
    ; At multi threading, such a variable cannot work,
    ; so requires latter solution of structured return value.
    ; On TinyScheme we can forget that.
    ;
    ; In the case where the entire return value is not required,
    ; using node return value to pass size or something is best.


    ; example1: for GIMP
    ; depth 1: modify image to fit build and shape
    ; depth 2: update size in opts
    ;          export scaled image as webp
    (define (example1 node opts)
      ; begin this node
      (apply-node func-l func-n func-a func-h func-else node opts)
    )

    ; execute-example1: execute example1
    (define (execute-example1 image project version arguments hierarchy node)
      (let
        ((return-value ()))
        (show-info "BEGIN:")
        (let*
          (
            ; a copy is used as a base working image
            (working (duplicate-image image))
            (new-image (car working))
            (new-display (cadr working))
            (depth 0)
            (opts (make-opts depth new-image project version arguments hierarchy))
          )
          (show-info "INFO: image is duplicated for working")
          (show-info new-image new-display)
          (show-info node opts)

          (set! return-value (example1 node opts))
          (show-info "return-value" return-value)
          (discard-image new-display)

          (show-info "INFO: working image was discarded")
        )
        (show-info "DONE:")
        return-value
      )
    )


    ;;
    ;; process start here

    ;; output to file BEGIN
    (define port-log-1 (open-output-file LOG-FILE))
    ;(define port-log-1 (current-output-port))

    (debug "parameters: " image project version)

    (if parameter-is-missing
      (begin
        (show-info ERROR-PARAMETER-MISSING)
        (debug ERROR-PARAMETER-MISSING)
      )
      (begin
        (set! return-value
          (execute-example1 image project version arguments hierarchy icon-list)
        )
        ; done
        (debug MESSAGE-DONE)
      )
    )


;    (debug "Current Image:" (car (gimp-image-get-name imageSrc)))




    ;; output to file END
    (close-output-port port-log-1)

    return-value
  )

)

; TODO only for debug
;(export-android-icons 0 "new-project" "new-version")

(script-fu-register
    _"export-android-icons"                ;function name
    _"Export Android app icons..."        ;menu label
    "Works on a copy of current image. \
      Iterates build shape and size in all combinations. \
      Export as webp file. \
      Discard the working copy."                  ;description
    "hanagai"                             ;author
    "copyright 2025, hanagai"             ;copyright notice
    "March 23, 2025"                      ;date created
    "*"                                   ;image type that the script works on
    SF-IMAGE       "Image"            0   ;an image variable
    SF-STRING     _"Project"          ""  ;project name
    SF-STRING     _"Version"          ""  ;project version
)
(script-fu-menu-register "export-android-icons" "<Image>/File/x Export")

