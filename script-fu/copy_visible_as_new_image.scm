; GIMP script to create new image from current visible image
; copyright 2025, hanagai
;
; copy_visible_as_new_image.scm
; version: March 11, 2025
;
; copy visible
; paste as new image
; return the new image

(define (copy-visible-as-new-image inImage)

  (let* (
          ; define local variables
          (imageSrc inImage) ; the image to copy from
          (imageDest) ; the image to be created

          (MESSAGE-DONE "Done!")  ; message to show when done
          (MESSAGE_ERROR_SELECTED "Copied only selected area.")
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

;    (debug "Current Image:" (car (gimp-image-get-name imageSrc)))

    ; check selection
;    (if (zero? (car (gimp-selection-is-empty imageSrc)))
;      (debug MESSAGE_ERROR_SELECTED)
;    )

    ; select none
    ;(gimp-selection-clear imageSrc)

    ; copy visible
    (gimp-edit-copy-visible imageSrc)

    ; paste as new image
    (set! imageDest (car (gimp-edit-paste-as-new-image)))
;    (debug imageDest)

    ; new image is already created.
    ; but stays invisible before opening new view
    (gimp-display-new imageDest)

    ; done
;    (debug MESSAGE-DONE)

    ; return the new image
    (list imageDest)
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

