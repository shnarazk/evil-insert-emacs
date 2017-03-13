;;; evil-insert-emacs.el --- Another insert mode (state) for Evil

;; Copyright (C) 2017 Shuji Narazaki
;; Author: Shuji Narazaki (@shnarazk on github)
;; Created: 2017-02-17
;; Package-Version: 0.0.6
;; Version: 0.0.6
;; URL: http://github.com/shnarazk/evil-insert-emacs
;; Keywords: convenience
;; Package-Requires: ((evil "1.2"))
;;

;;--------------------------------------------------------------------------------
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA
;;
;;-------------------------------------------------------------------
;;
;;; Commentary:
;;
;; - Usage:
;;    Use package.el toinstall this; some keys, commands, and autoloads are defined.
;;    Evil and this package itself will be loaded on-demand.
;;
;;--------------------------------------------------------------------------------

;;; Code:
(eval-when-compile (require 'evil))

(autoload 'evil-local-mode "evil" nil t)

;;;###autoload
(defvar evil-insert-emacs-key (kbd "C-]"))

;;;###autoload
(define-key global-map evil-insert-emacs-key 'evil-normal-state-or-mode)

;;;###autoload
(defun evil-normal-state-or-mode ()
  "Toggle Evil state."
  (interactive)
  (cond ((not (boundp 'evil-local-mode)) (evil-local-mode))
	((not evil-local-mode) (turn-on-evil-mode))
	((eq evil-state 'normal) (turn-off-evil-mode))
	(t (evil-normal-state))))

;;; customize -- FIXME
(defvar evil-insert-emacs-use-emacs-commands t
  "Overwrite Evil's evil-declare-change/abort-repeat setting to use more commands in insert-emacs state.")
(defvar evil-insert-emacs-overlay-indicator t
  "Use overlay to indiate whether the current state is insert-emacs.")
(defvar evil-insert-use-overlay-indicator t
  "Use overlay to indiate whether the current state is insert or insert-emacs.")
(defvar evil-insert-emacs-sandbox t
  "Restrict editable region by using 'cursor-intangible-mode'.")

;;; local variables
(defvar evil-insert-emacs-beg-marker (make-marker))
(set-marker-insertion-type evil-insert-emacs-beg-marker nil)
(defvar evil-insert-emacs-end-marker (make-marker))
(set-marker-insertion-type evil-insert-emacs-end-marker t)

(eval-after-load 'evil
  '(progn
     (evil-define-state insert-emacs
       "Emacs state that can't be exited with the escape key."
       :tag " <IE> "
       :message "-- EMACS WITH ESCAPE --"
       :input-method t
       )
     (define-key global-map (kbd evil-toggle-key) 'evil-normal-state-or-mode)
     (define-key evil-normal-state-map (kbd evil-toggle-key) 'evil-normal-state-or-mode)
     (define-key evil-emacs-state-map (kbd evil-toggle-key) 'evil-normal-state)
     (define-key evil-insert-emacs-state-map (kbd evil-toggle-key) 'evil-normal-state)
     (define-key evil-insert-state-map (kbd evil-toggle-key) 'evil-insert-emacs-state)
     (if evil-insert-emacs-use-emacs-commands
	 (mapc #'evil-declare-change-repeat
	       '(move-beginning-of-line
		 move-end-of-line
		 backward-word
		 forward-word
		 transpose-chars
		 delete-horizontal-space
		 kill-word
		 backward-kill-word
		 capitalize-word
		 upcase-word
		 downcase-word
		 just-one-space)))
     ;; By defining a more emacs-flavored state, insert-mode doesn't need universal-argument.
     (define-key evil-insert-state-map "\C-u" 'evil-insert-delete-all)
     ;; Furthermore import C-c from vim
     (define-key evil-insert-state-map "\C-c" 'evil-normal-state)
     ))

(defun evil-insert-state-set-overlay-indicator ()
  "Display insert mode (state) indicator using overlay."
  (set-marker evil-insert-emacs-beg-marker (point))
  (set-marker evil-insert-emacs-end-marker (point))
  (when evil-insert-emacs-overlay-indicator
    (let ((o (make-overlay (point) (point) (current-buffer) nil t)))
      (overlay-put o 'face 'region))
    (when evil-insert-emacs-sandbox
          (let ((l (make-overlay (point-min) (point) (current-buffer) t nil))
		(r (make-overlay (point) (point-max) (current-buffer) t nil)))
	    (cursor-intangible-mode 1)
	    (overlay-put l 'cursor-intangible t)
	    (overlay-put r 'cursor-intangible t)))))

(defun evil-insert-state-clear-overlay-indicator ()
  "Clear the overlay that was created by 'evil-insert-state-set-overlay-indicator'."
  (when evil-insert-emacs-overlay-indicator
    (when evil-insert-emacs-sandbox
      (remove-overlays (point-min) (point-max) 'cursor-intangible t))
    (remove-overlays evil-insert-emacs-beg-marker evil-insert-emacs-end-marker 'face 'region)))

(add-hook 'evil-insert-emacs-state-entry-hook #'evil-insert-state-set-overlay-indicator)
(add-hook 'evil-insert-emacs-state-exit-hook #'evil-insert-state-clear-overlay-indicator)

(when evil-insert-use-overlay-indicator
  (add-hook 'evil-insert-state-entry-hook #'evil-insert-state-set-overlay-indicator)
  (add-hook 'evil-insert-state-exit-hook #'evil-insert-state-clear-overlay-indicator))

(defun evil-insert-delete-all ()
  "Clear the content typed in."
  (interactive "*")
  (delete-region evil-insert-emacs-beg-marker evil-insert-emacs-end-marker))

(provide 'evil-insert-emacs)
;;; evil-insert-emacs.el ends here
