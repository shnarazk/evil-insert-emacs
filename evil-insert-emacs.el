;;; evil-insert-emacs.el --- post to slack channel

;;--------------------------------------------------------------------------------
;;
;; Copyright (C) 2017 Shuji Narazaki
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
;; Author: Shuji Narazaki <shuji.narazaki@gmail.com>
;; Created: 2017-02-17
;; Version: 0.0.1
;; Keywords: 
;;
;;; Commentary:
;;
;; another insert mode (state) for Evil
;;
;;--------------------------------------------------------------------------------

;;; Code:
(require 'evil)

(defvar evil-insert-emacs-key (kbd "C-]"))
(defvar evil-insert-emacs-use-emacs-commands t)

(define-key global-map evil-insert-emacs-key 'evil-normal-state-or-mode)
(defun evil-normal-state-or-mode ()
  "FIXME"
  (interactive)
  (cond ((not (boundp 'evil-local-mode)) (evil-local-mode))
	((not evil-local-mode) (turn-on-evil-mode))
	((eq evil-state 'normal) (turn-off-evil-mode))
	(t (evil-normal-state))))

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
	    backward-kill-word
	    capitalize-word
	    upcase-word
	    downcase-word)))

(provide 'evil-insert-emacs)
