; GIMP script to export webp file from current visible image
; copyright 2025, hanagai
;
; export_copy_as_webp.scm
; version: March 24, 2025
;
; copy visible as new image
; scale image if specified
; export as webp file
; return the file name and size of image

(define (export-copy-as-webp inImage inWidth inFileName inParentDir . inDirs)


  (let* (
          ; define local variables
          (imageSrc inImage) ; the image to copy from
          (copiedDest)  ; (image layer display) created
          (imageDest) ; the image to be created
          (layerDest) ; the drawable of the new image
          (displayDest) ; the display of the new image
          (imageWidth (car (gimp-image-width imageSrc)))  ; the width of the image
          (imageHeight (car (gimp-image-height imageSrc)))  ; the height of the image
          (layerDestName "copy to export")  ; the name of the new layer

          (newWidth inWidth)  ; the width of the new image
          (newHeight)  ; the height of the new image

          (fileName inFileName)  ; the name of the file to be created
          (filePath)  ; the path of the file to be created
          (fileFullPath)  ; the full path of the file to be created
          (webp-save-procedure-args)  ; arguments for webp save procedure
          (fileSaveResult)  ; the result of the file save procedure

          ; GIMP_RUN_INTERACTIVE is already defined by GIMP as RUN-INTERACTIVE
          ;(GIMP_RUN_INTERACTIVE 0)  ; Interactive mode
          ;(GIMP_RUN_NONINTERACTIVE 1) ; Non-interactive mode
          ;(GIMP_RUN_WITH_LAST_VALS 2) ; Run with last values

          ; GIMP_RGB is already defined by GIMP as RGB
          ;(GIMP_RGB 0)  ; RGB color space
          ;(GIMP_GRAY 1)  ; Gray color space
          ;(GIMP_INDEXED 2)  ; Indexed color space

          (NO_PARENT_LAYER 0)  ; no parent layer
          (LAYER_POSITION_TOP 0)  ; top layer
          (MESSAGE-DONE "Done!")  ; message to show when done
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


    ; from string.scm

    ; string-blank?: string -> boolean
    ; string is blank, or not
    ; Returns #t if the string is blank, otherwise #f.
    ; (string-blank? "") ; Returns #t
    ; (string-blank? "not blank") ; Returns #f
    (define (string-blank? str)
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
              (if (string-blank? this_segment)
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


    ;;
    ;; process start here

;    (debug "Current Image:" (car (gimp-image-get-name imageSrc)))

    ; create full path to save
;    (debug "inFileName: " inFileName ", inParentDir: " inParentDir ", inDirs: " inDirs)
    ;(set! filePath (apply join-file-path (list "a" "b" "c" "d")))
    (set! filePath (apply join-file-path (cons inParentDir inDirs)))
    (set! fileFullPath (join-file-path filePath inFileName))
;    (debug "fileName: " fileName ", filePath: " filePath ", fileFullPath: " fileFullPath)

    ; new image from visible
    ;(set! copiedDest (copy-visible-as-new-image RUN-NONINTERACTIVE imageSrc))
    (set! copiedDest (copy-visible-as-new-image imageSrc))
    (set! imageDest (car copiedDest))
    (set! layerDest (cadr copiedDest))
    (set! displayDest (caddr copiedDest))
;    (debug "New Image:" imageDest ", New Layer:" layerDest ", New Display:" displayDest)

    ; scale image if specified and differs
;    (debug "New Width:" newWidth)
    (if (and (positive? newWidth) (not (eqv? imageWidth newWidth)))
      (begin
        (set! newHeight (/ (* newWidth imageHeight) imageWidth))
;        (debug "New Height:" newHeight)
        (gimp-image-scale imageDest newWidth newHeight)
      )
      (begin
        (set! newWidth imageWidth)
        (set! newHeight imageHeight)
;        (debug "Sacle not changed: Width:" newWidth ", Height:" newHeight)
      )
    )

    ; flush the display
    (gimp-displays-flush)

    ; save as webp file
    (set! webp-save-procedure-args
      (list
        RUN-NONINTERACTIVE ; run mode
        ;RUN-INTERACTIVE ; run mode
        imageDest ; image
        layerDest ; drawable
        fileFullPath  ; filename
        fileFullPath  ; raw-filename
        0 ; preset (Default=0, Picture=1, Photo=2, Drawing=3, Icon=4, Text=5)
        0 ; Use lossless encoding (0/1)
        90 ; Quality of the image (0 <= quality <= 100)
        90 ; Quality of the image's alpha channel (0 <= alpha-quality <= 100)
        0 ; Use layers for animation (0/1)
        0 ; Loop animation infinitely (0/1)
        0 ; Minimize animation size (0/1)
        0 ; Maximum distance between key-frames (>=0)
        0 ; Toggle saving exif data (0/1)
        0 ; Toggle saving iptc data (0/1)
        0 ; Toggle saving xmp data (0/1)
        ;param for file-webp-save2 ;0 ; Toggle saving thumbnail (0/1)
        0 ; Delay to use when timestamps are not available or forced
        0 ; Force delay on all frames
      )
    )
;    (debug "webp-save-procedure-args:" webp-save-procedure-args)

    (set! fileSaveResult (apply file-webp-save webp-save-procedure-args))
;    (debug "fileSaveResult:" fileSaveResult)

    ; discard the copy
;    (debug "Delete display and image:" displayDest)
    (gimp-display-delete displayDest)


    ; done
;    (debug MESSAGE-DONE)

    ; return the file full path, width and height
    (list fileFullPath newWidth newHeight)
  )
)

(script-fu-register
    _"export-copy-as-webp"                ;function name
    _"Export Copy as Webp File..."        ;menu label
    "Copy visible from current image. \
      Scale image if specified. \
      Export as webp file. \
      Discard the copy."                  ;description
    "hanagai"                             ;author
    "copyright 2025, hanagai"             ;copyright notice
    "March 11, 2025"                      ;date created
    "*"                                   ;image type that the script works on
    SF-IMAGE       "Image"           0    ;an image variable
    SF-ADJUSTMENT _"Width"   '(128 1 16384 32 10 0 SF_SPINNER) ;scale image by width
    SF-STRING     _"File Name"       "exported.webp" ;file name
    SF-DIRNAME    _"File Path 1"     ""    ;file path
    SF-STRING     _"File Path 2"     "tmp" ;file path
    SF-STRING     _"File Path 3"     ""    ;file path
    SF-STRING     _"File Path 4"     ""    ;file path
)
(script-fu-menu-register "export-copy-as-webp" "<Image>/File/x Export")

