;; anthy-isearch.el -- Anthy

;; Copyright (C) 2003
;; Author: Yusuke Tabata <yusuke@cherbim.icw.co.jp>

;; DO NOT USE NOW.
;;

;;; Commentary:
;; TOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO many things to be implemented.
;; most of the code is stolen from SKK.
;; for Emacs-21

(require 'anthy)

(defvar anthy-isearch-mode-map nil)

;; $B8!:wBP>]$NJ8;zNs$H%W%j%(%G%#%C%H$rF~$l$k%P%C%U%!(B
(defconst anthy-isearch-working-buffer " *anthy-isearch*")

;; $B8!:wBP>]$NJ8;zNs$r<hF@$9$k(B
(defun anthy-isearch-search-string ()
  (with-current-buffer (get-buffer-create anthy-isearch-working-buffer)
    (if (string-equal anthy-preedit "")
	;; $B%W%j%(%G%#%C%H$,L5$$;~$O(B
	(buffer-string)
      (save-restriction
	(narrow-to-region (point-min) anthy-preedit-start)
	(buffer-string)))))

;; $B8!:wBP>]$NJ8;zNs(B + $BF~NOESCf$NJ8;zNs(B
(defun anthy-isearch-search-message ()
  (with-current-buffer (get-buffer-create anthy-isearch-working-buffer)
    (buffer-string)))

(defun anthy-isearch-process-search-string (string msg)
  (setq isearch-string "")
  (setq isearch-message "")
  (isearch-process-search-string string msg))

(defun anthy-isearch-raw-input ()
  (with-current-buffer (get-buffer-create anthy-isearch-working-buffer)
    (self-insert-command 1)))

(defun anthy-isearch-wrapper (&rest args)
  (interactive "P")
  (if current-input-method
      (with-current-buffer (get-buffer-create anthy-isearch-working-buffer)
	(anthy-insert))
    (anthy-isearch-raw-input))
  (anthy-isearch-process-search-string
   (anthy-isearch-search-string)
   (anthy-isearch-search-message)))

(defun anthy-isearch-keyboard-quit (&rest args)
  (interactive "P")
  (let ((p nil))
    (with-current-buffer (get-buffer-create anthy-isearch-working-buffer)
      (if (not (string-equal "" anthy-preedit))
	  (setq p t)))
    (if p
	(anthy-isearch-wrapper)
      (progn
	(setq isearch-string "")
	(setq isearch-message "")
	(isearch-abort)))))

(defun anthy-isearch-toggle-input-method (&rest args)
  (interactive "P")
  (isearch-toggle-input-method))

(defun anthy-isearch-setup-keymap (map)
  (let ((i 0))
    (while (< i 127)
      (define-key map (char-to-string i) 'anthy-isearch-wrapper)
      (setq i (+ 1 i)))
    (define-key map "\C-g" 'anthy-isearch-keyboard-quit)
    (substitute-key-definition
     'isearch-toggle-input-method 
     'anthy-isearch-toggle-input-method
     map isearch-mode-map)
    map))

(defun anthy-isearch-mode-setup ()
  ;; $B:G=i$O%-!<%^%C%W$r=`Hw$9$k(B
  (or (keymapp anthy-isearch-mode-map)
      (setq anthy-isearch-mode-map
	    (anthy-isearch-setup-keymap (copy-keymap isearch-mode-map))))
  ;;
  (setq overriding-terminal-local-map anthy-isearch-mode-map)
  (with-current-buffer (get-buffer-create anthy-isearch-working-buffer)
    (erase-buffer))
  ())

(defun anthy-isearch-mode-cleanup ()
  (setq overriding-terminal-local-map nil)
  (kill-buffer anthy-isearch-working-buffer)
  ())

(add-hook 'isearch-mode-hook 'anthy-isearch-mode-setup)
(add-hook 'isearch-mode-end-hook 'anthy-isearch-mode-cleanup)
(setq debug-on-error 't)
