; GIMP script to duplicate a text layer with new text
; copyright 2025, hanagai
;
; spawn_text_layer.scm
; version: March 8, 2025
;
; duplicates current layter (must be a text layer)
; modify the text by the given text

; for debugging
(define debug #f)

(define (spawn-text-layer inImage inDrawable inText)

  (let* (
          ; define our local variables
          (image inImage) ; the image to work on
          (layer inDrawable)  ; the layer to work on
          (inText inText)  ; the text to be set
          (newLayer)  ; the layer to be created
          (layerIsTextLayer #f)  ; flag to check if the layer is a text layer
          (newLayerName (if (is-blank? inText) "spawned" inText))  ; the name of the new layer

          (UPON_LAYER -1)  ; the layer to be created upon
          (NO_PARENT_LAYER 0)  ; no parent layer
          (MESSAGE-DONE "Done!")  ; message to show when done (debug only)
          (MESSAGE_ERROR_NOT_TEXT_LAYTER "The selected layer is not a text layer.")
    ) ;end of our local variables

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

    (if debug (gimp-message (car (gimp-item-get-name layer))))

    (set! layerIsTextLayer (int-to-boolean (car (gimp-item-is-text-layer layer))))

    ; check if the layer is a text layer
    (if (not layerIsTextLayer)
        (begin
          ;(gimp-message "The selected layer is not a text layer.")
          (error MESSAGE_ERROR_NOT_TEXT_LAYTER)
        )
    )

    ; duplicate the layer
    (set! newLayer (car (gimp-layer-copy layer TRUE)))
    (gimp-image-insert-layer image newLayer NO_PARENT_LAYER UPON_LAYER)
    (gimp-item-set-name newLayer newLayerName)

    ; update the text when some text is given
    (if (is-blank? inText)
        (if debug (gimp-message "No text given."))
        (begin
          ; set the text
          (gimp-text-layer-set-text newLayer inText)
          (if debug (gimp-message "Text updated."))
        )
    )

    ; center layer
    (center-layer image newLayer)

    ; update display
    (gimp-displays-flush)

    ; done
    (if debug (gimp-message MESSAGE-DONE))

  )
)

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
    (if debug (gimp-message (string-append "imageWidth: " (number->string imageWidth) ", imageHeight: " (number->string imageHeight) ", layerWidth: " (number->string layerWidth) ", layerHeight: " (number->string layerHeight) ", offsetX: " (number->string offsetX) ", offsetY: " (number->string offsetY))))
    ; cannot do it
    ;(use extras)
    ;(if debug (gimp-message (format #t "image: (~a, ~a), layer: (~a, ~a), offset: (~a, ~a)%" imageWidth imageHeight layerWidth layerHeight offsetX offsetY)))

    (gimp-layer-set-offsets layer offsetX offsetY)
  )
)

; string is blank
(define (is-blank? str)
  (if (string=? "" str) #t #f))

; int-to-boolean: int(TRUE/FALSE) -> boolean
(define (int-to-boolean int)
  (if (eqv? TRUE int) #t #f))

; boolean-to-string: boolean -> string
(define (boolean-to-string bool)
  (if (eqv? TRUE bool) "true" "false"))


(script-fu-register
    _"spawn-text-layer"                        ;function name
    _"Duplicate with New Text..."                                  ;menu label
    "Duplicate text layer. \
      Change text."              ;description
    "hanagai"                             ;author
    "copyright 2025, hanagai"        ;copyright notice
    "March 8, 2025"                          ;date created
    "*"                                      ;image type that the script works on
    SF-IMAGE       "Image"           0         ;an image variable
    SF-DRAWABLE    "Drawable"        0       ;a drawable variable
    SF-STRING      _"Text"          ""   ;a string variable
)
(script-fu-menu-register "spawn-text-layer" "<Image>/Layer/Spawn")

