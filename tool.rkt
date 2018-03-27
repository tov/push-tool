#lang racket

(provide tool@)
(require drracket/tool
         framework
         racket/gui/base)

(define dest "delta:public_html/tmp/x.rkt")

(define-local-member-name fetch-code)

(define tool@
  (unit
    (import drracket:tool^)
    (export drracket:tool-exports^)

    (define send-code-frame-mixin
      (mixin (drracket:unit:frame<%> frame:editor<%>) ()
        (inherit get-editor create-new-tab)

        (define/override (file-menu:between-open-and-revert file-menu)
          (new menu:can-restore-menu-item%
               [label "Push 111 Code"]
               [parent file-menu]
               [shortcut #\2]
               [shortcut-prefix (cons 'shift (get-default-shortcut-prefix))]
               [callback (λ (_1 _2) (push-code))])
          (super file-menu:between-open-and-revert file-menu))
        
        (define/public (push-code)
          (define txt (get-editor))
          (send txt save-file)
          (define filename (send txt get-filename))
          (unless (or (send txt is-modified?)
                      (not filename))
            (define sp (open-output-string))
            (define failed?
              (parameterize ([current-output-port sp]
                             [current-error-port sp])
                (system* "/usr/bin/scp" (~a filename) dest)))
            (message-box "DrRacket"
                         (~a "scp finished\n\n"
                             (get-output-string sp)))))
        
        (super-new)))
    
    (drracket:get/extend:extend-unit-frame send-code-frame-mixin)
    
    (define (phase1) (void))
    (define (phase2) (void))))

