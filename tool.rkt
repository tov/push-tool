#lang racket

(provide tool@)
(require drracket/tool
         framework
         racket/gui/base)

(define dest "login.eecs.northwestern.edu:public_html/tmp/pull-tool.rkt")

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
            (define succeeded?
              (parameterize ([current-output-port sp]
                             [current-error-port sp])
                (system* "/usr/bin/scp" (~a filename) dest)))
            (cond
              [succeeded?
               (message-box "DrRacket" "Sent!")]
              [else
               (message-box "DrRacket"
                            (format "scp error: ~a" (get-output-string sp)))])))

        (super-new)))

    (drracket:get/extend:extend-unit-frame send-code-frame-mixin)

    (define (phase1) (void))
    (define (phase2) (void))))

