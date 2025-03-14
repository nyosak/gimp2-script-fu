; GIMP script to create new image from current visible image
; copyright 2025, hanagai
;
; copy_visible_as_new_image.scm
; version: March 14, 2025
;
; create a new image from current visible
; ignore selection
; return the new image, the new layer and the new display

(define (copy-visible-as-new-image inImage)

  (let* (
          ; define local variables
          (imageSrc inImage) ; the image to copy from
          (imageDest) ; the image to be created
          (layerDest) ; the drawable of the new image
          (imageWidth (car (gimp-image-width imageSrc)))  ; the width of the image
          (imageHeight (car (gimp-image-height imageSrc)))  ; the height of the image
          (imageType (car (gimp-image-base-type imageSrc)))  ; the type of the image (RGB, Gray, Indexed)
          (layerDestName "copied visible")  ; the name of the new layer
          (newDisplay) ; the display of new image

          ;(GIMP_RGB 0)  ; RGB color space
          ;(GIMP_GRAY 1)  ; Gray color space
          ;(GIMP_INDEXED 2)  ; Indexed color space
          (NO_PARENT_LAYER 0)  ; no parent layer
          (LAYER_POSITION_BOTTOM 0)  ; top layer
          (MESSAGE-DONE "Done!")  ; message to show when done
;-;-           (MESSAGE_ERROR_SELECTED "Copied only selected area.")
    ) ;end of local variables

    ;;
    ;; helper functions

    ; from test.scm

    (define (debug obj1 . objn)
      (echo (apply stringify (cons DELIMITER (cons obj1 objn))))
      (newline)
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
    ;(define echo display) ; TineyScheme, GIMP Script-Fu Console
    (define echo gimp-message)  ; GIMP Script-Fu Console
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


    ;;
    ;; process start here

;-;- copy visible and paste still works, but it depends SELECTION
;-;- 
;-;- ;    (debug "Current Image:" (car (gimp-image-get-name imageSrc)))
;-;- 
;-;-     ; check selection
;-;- ;    (if (zero? (car (gimp-selection-is-empty imageSrc)))
;-;- ;      (debug MESSAGE_ERROR_SELECTED)
;-;- ;    )
;-;- 
;-;-     ; select none
;-;-     ;(gimp-selection-clear imageSrc)
;-;- 
;-;-     ; copy visible
;-;-     (gimp-edit-copy-visible imageSrc)
;-;- 
;-;-     ; paste as new image
;-;-     (set! imageDest (car (gimp-edit-paste-as-new-image)))
;-;- ;    (debug imageDest)
;-;- 
;-;-     ; new image is already created.
;-;-     ; but stays invisible before opening new view
;-;-     (gimp-display-new imageDest)
;-;- 

    ;;
    ;; gimp-layer-new-from-visible offers direct copy of visible area
    ;; without depending on SELECTION
    ;; but it requires GIMP 2.6 or later

;    (debug "Current Image:" (car (gimp-image-get-name imageSrc)))
;    (debug "Width:" imageWidth "Height:" imageHeight "Type:" imageType)

    ; create new image
    (set! imageDest (car (gimp-image-new imageWidth imageHeight imageType)))
;    (debug "New Image:" imageDest)

    ; copy to new layer
    (set! layerDest (car (gimp-layer-new-from-visible imageSrc imageDest layerDestName)))
;    (debug "New Layter:" layerDest)

    ; add the new layer to the new image
    (gimp-image-insert-layer imageDest layerDest NO_PARENT_LAYER LAYER_POSITION_BOTTOM)

    ; display the new image
    (set! newDisplay (car (gimp-display-new imageDest)))

    ; done
;    (debug MESSAGE-DONE)

    ; return the new image, the new layer and the new display
    ; newDisplay will be required to delete this image later
    (list imageDest layerDest newDisplay)
  )
)

(script-fu-register
    _"copy-visible-as-new-image"            ;function name
    _"Copy Visible as New Image"            ;menu label
    "Copy visible from current image. \
      Paste as new image."                  ;description
    "hanagai"                               ;author
    "copyright 2025, hanagai"               ;copyright notice
    "March 11, 2025"                        ;date created
    "*"                                     ;image type that the script works on
    SF-IMAGE       "Image"           0      ;an image variable
)
(script-fu-menu-register "copy-visible-as-new-image" "<Image>/File/Create")

