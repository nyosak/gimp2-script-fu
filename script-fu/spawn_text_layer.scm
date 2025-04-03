; GIMP script to duplicate a text layer with new text
; copyright 2025, hanagai
;
; spawn_text_layer.scm
; version: April 3, 2025
;
; duplicates current layter (must be a text layer)
; modify the text by the given text
; center the new layer

(define (spawn-text-layer inImage inDrawable inText)

  (let* (
          ; define local variables
          (image inImage) ; the image to work on
          (layer inDrawable)  ; the layer to work on
          (inText inText)  ; the text to be set
          (newLayer)  ; the layer to be created
          (layerIsTextLayer #f)  ; flag to check if the layer is a text layer
          (newLayerName "")  ; the name of the new layer

          (UPON_LAYER -1)  ; the layer to be created upon
          (NO_PARENT_LAYER 0)  ; no parent layer
          (MESSAGE-DONE "Done!")  ; message to show when done
          (MESSAGE_ERROR_NOT_TEXT_LAYTER "The selected layer is not a text layer.")
    ) ;end of local variables

    ;;
    ;; helper functions

    ; translate the new layer to the center of the image
    (define (center-layer image layer)
      (let* (
              (imageWidth (car (gimp-image-width image)))  ; the width of the image
              (imageHeight (car (gimp-image-height image)))  ; the height of the image
              (layerWidth (car (gimp-drawable-width layer)))  ; the width of the layer
              (layerHeight (car (gimp-drawable-height layer)))  ; the height of the layer
              (offsetX (- (/ imageWidth 2) (/ layerWidth 2)))  ; the x offset
              (offsetY (- (/ imageHeight 2) (/ layerHeight 2)))  ; the y offset
        )
;        (debug "center-layer: (imageWidth" imageWidth ", imageHeight" imageHeight ") (layerWidth" layerWidth ", layerHeight" layerHeight ") (offsetX" offsetX ", offsetY" offsetY ")")

        (gimp-layer-set-offsets layer offsetX offsetY)
      )
    )

    ; from types.scm
    ;
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
      ;(if (eqv? (if (defined? 'TRUE) TRUE 1) int) #t #f))
      (if (eqv? TRUE int) #t #f))

    ; from test.scm

    ; on GIMP Script-Fu Console
    (define (debug obj1 . objn)
      ;(gimp-message (apply stringify (cons #\NewLine (cons obj1 objn))))
      (gimp-message (apply stringify (cons #\Space (cons obj1 objn))))
    )

    ; stringify: object list -> string (with delimited)
    (define (stringify delimiter . objects)
      (let *
        ((port (open-output-string)))

        (define (write-to-string delimiter objects port)
          (unless (eq? () objects)
            (write (car objects) port)
            (write-char delimiter port)
            (write-to-string delimiter (cdr objects) port)
          )
        )

        (write-to-string delimiter objects port)
        (car (cons (get-output-string port) (close-port port)))
      )
    )

    ;;
    ;; process start here

    ; maybe not required if harmless.
    ; give "*" for image type that the script works on.
    ; that will disable the menu automatically, so better than the following.
    ;
    ; check if the image is valid
    ;(if (eqv? 0 image)
    ;    (begin
    ;      ;(gimp-message "No image to work on.")
    ;      (error "No image to work on.")
    ;    )
    ;)

;    (debug "Current layer:" (car (gimp-item-get-name layer)))

    (set! layerIsTextLayer (int->boolean (car (gimp-item-is-text-layer layer))))

    ; check if the layer is a text layer
    (if (not layerIsTextLayer)
        (begin
          ;(gimp-message "The selected layer is not a text layer.")
          (error MESSAGE_ERROR_NOT_TEXT_LAYTER)
        )
    )

    ; duplicate the layer
    (set! newLayerName (if (is-blank? inText) "spawned" inText))
    (set! newLayer (car (gimp-layer-copy layer TRUE)))
    (gimp-image-insert-layer image newLayer NO_PARENT_LAYER UPON_LAYER)
    (gimp-item-set-name newLayer newLayerName)

    ; update the text when some text is given
    (if (is-blank? inText)
        (begin
;        (debug "No text given.")
        )
        (begin
          ; set the text
          (gimp-text-layer-set-text newLayer inText)
;          (debug "Text updated.")
        )
    )

    ; center layer
    (center-layer image newLayer)

    ; update display
    (gimp-displays-flush)

    ; done
;    (debug MESSAGE-DONE)
  )
)

(script-fu-register
    _"spawn-text-layer"                 ;function name
    _"Duplicate with New Text..."       ;menu label
    "Duplicate text layer. \
      Change text."                     ;description
    "hanagai"                           ;author
    "copyright 2025, hanagai"           ;copyright notice
    "March 8, 2025"                     ;date created
    "*"                                 ;image type that the script works on
    SF-IMAGE       "Image"           0  ;an image variable
    SF-DRAWABLE    "Drawable"        0  ;a drawable variable
    SF-STRING      _"Text"          ""  ;a string variable
)
(script-fu-menu-register "spawn-text-layer" "<Image>/Layer/Spawn")

