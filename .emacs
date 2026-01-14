;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'downcase-region 'disabled nil)

;;; Package setup
(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; color scheme
(use-package modus-themes
  :init
  (load-theme 'modus-vivendi t))

;;; vterm
(use-package vterm)
(setq vterm-shell "/bin/bash")
(global-set-key (kbd "C-c t") #'vterm)


;;; hooks
;; Activate 'display-line-numbers-mode' when programming
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; put ~files one place instead of all over the FS
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq tramp-backup-directory-alist backup-directory-alist)

;;; fix indentaion, remove tabs and trailing whitespace
(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

;; ========== cpp ==========
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode)) ;; .h files treated as c++ instead of c
(setq c-default-style "bsd" c-basic-offset 2)

;; ========== python ========== 
(setq  py-indent-offset  2)
(setq  py-continuation-offset  4)
