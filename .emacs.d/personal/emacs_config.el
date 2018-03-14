;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; basic emacs configuration to be used in conjunction with prelude       ;;
;; pragmaticemacs.com/installing-and-setting-up-emacs/                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Add MELPA repository for packages
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

;; Setup rosemacs
;; (add-to-list 'load-path "/opt/ros/kinetic/share/emacs/site-lisp")
;; (require 'rosemacs-config)
;; (require 'rosemacs)
;; ;;(invoke-rosemacs)
;; (global-set-key "\C-x\C-r" ros-keymap)

;; Disable flyspell
(setq prelude-flyspell nil)

;; Setup neotree
(setq neo-theme (if window-system 'ascii 'ascii))
(global-set-key [f8] 'neotree-toggle)

;; (use-package dired-sidebar
;;   :ensure t
;;   :commands (dired-sidebar-toggle-sidebar)
;;   :config
;;   (use-package all-the-icons-dired
;;     ;; M-x all-the-icons-install-fonts
;;     :ensure t
;;     :commands (all-the-icons-dired-mode)))

;; Highlight latex-code in org-mode
(setq org-highlight-latex-and-related '(latex))

;; Org-Download
;; (require 'org-download)
;; (setq org-image-actual-width '(300))

;; Org-capture
;;(setq org-default-notes-file (concat org-directory "/.org/notes.org"))
;;(define-key global-map "\C-cc" 'org-capture)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prelude options                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; install additional packages - add anyto this list that you want to

;; be installed automatically
(prelude-require-packages '(multiple-cursors ess))

;;smooth scrolling
(setq prelude-use-smooth-scrolling t)

(setq whitespace-line-column 120)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display options                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;enable tool and menu bars
(tool-bar-mode 0)
(menu-bar-mode 1)

;; Insert new line below current line
;; and move cursor to new line
;; it will also indent newline
(global-set-key (kbd "<C-return>") (lambda ()
                                     (interactive)
                                     (end-of-line)
                                     (newline-and-indent)))

;; HS keys
(global-set-key (kbd "<C-tab>") 'hs-toggle-hiding)
(add-hook 'c-mode-common-hook 'hs-minor-mode t)
(add-hook 'c-mode-common-hook 'hs-hide-initial-comment-block t)


;; Scoll without moving the point
(global-set-key "\M-n"  (lambda () (interactive) (scroll-up   4)) )
(global-set-key "\M-p"  (lambda () (interactive) (scroll-down 4)) )

;;; Elfeed
;; use an org file to organise feeds
(use-package elfeed-org
             :ensure t
             :config
             (elfeed-org)
             (setq rmh-elfeed-org-files (list "~/.org/elfeed.org")))

;;shortcut functions
(defun bjm/elfeed-show-all ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "elfeed-all"))
(defun bjm/elfeed-show-all-unread ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "elfeed-all-unread"))
(defun bjm/elfeed-show-emacs ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "elfeed-emacs"))
(defun bjm/elfeed-show-daily ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "elfeed-daily"))

(defun bjm/elfeed-show-other ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "elfeed-other"))

;;functions to support syncing .elfeed between machines
;;makes sure elfeed reads index from disk before launching
(defun bjm/elfeed-load-db-and-open ()
  "Wrapper to load the elfeed db from disk before opening"
  (interactive)
  (elfeed-db-load)
  (elfeed)
  (elfeed-search-update--force))

;;write to disk when quitting
(defun bjm/elfeed-save-db-and-bury ()
  "Wrapper to save the elfeed db to disk before burying buffer"
  (interactive)
  (elfeed-db-save)
  (quit-window))

(use-package elfeed
             :ensure t
             :bind (:map elfeed-search-mode-map
                         ("A" . bjm/elfeed-show-all)
                         ("a" . bjm/elfeed-show-all-unread)
                         ("E" . bjm/elfeed-show-emacs)
                         ("D" . bjm/elfeed-show-daily)
                         ("O" . bjm/elfeed-show-other)
                         ("q" . bjm/elfeed-save-db-and-bury)))

(global-set-key (kbd "C-x C-r") 'bjm/elfeed-load-db-and-open)

;; Dumb jump
(use-package dumb-jump
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g j" . dumb-jump-go)
         ("M-g i" . dumb-jump-go-prompt)
         ("M-g x" . dumb-jump-go-prefer-external)
         ("M-g z" . dumb-jump-go-prefer-external-other-window))
  :config (setq dumb-jump-selector 'ivy) ;; (setq dumb-jump-selector 'helm)
  :ensure)

;;;; Avy
(use-package avy
  :ensure t
  :bind (("M-s" . avy-goto-word-1)))

(use-package srefactor
  :ensure t
  :bind (
         :map c-mode-map
         ("M-RET" . srefactor-refactor-at-point)
         :map c++-mode-map
         ("M-RET" . srefactor-refactor-at-point)
         )
  )

(use-package winum
  :ensure t
  :init
  (dotimes (n 10)
    (global-set-key (kbd (format "M-%s" n)) (intern (format "winum-select-window-%s" n)))
    )
  ;; :bind(
  ;;       (dotimes (n 10)
  ;;         ((format "M-%s" n) . (intern (format "winum-select-window-%s" n)))
  ;;         )
  ;;       )
  :config
  (winum-mode)
  )


(use-package helm-descbinds
  :ensure t
  :bind (
         ("C-h b" . helm-descbinds)))

;; Multiple cursors
;;(global-set-key (kbd "C-c m c") 'mc/edit-lines)
(use-package multiple-cursors
  :ensure t
  :bind (;;("M-." . mc/mark-next-like-this)
         ;;("M-," . mc/unmark-next-like-this)
         ("C-c m c" . mc/edit-lines)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)))

;; ROS-style formatting
(defun ROS-c-mode-hook()
  (setq c-basic-offset 2)
  (setq indent-tabs-mode nil)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'innamespace 0)
  (c-set-offset 'case-label '+)
  (c-set-offset 'statement-case-open 0))

(add-hook 'c-mode-common-hook 'ROS-c-mode-hook)

;;; In order to get namespace indentation correct, .h files must be opened in C++ mode
(add-to-list 'auto-mode-alist '("\\.h$" . c++-mode))


(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
         (next-win-buffer (window-buffer (next-window)))
         (this-win-edges (window-edges (selected-window)))
         (next-win-edges (window-edges (next-window)))
         (this-win-2nd (not (and (<= (car this-win-edges)
                     (car next-win-edges))
                     (<= (cadr this-win-edges)
                     (cadr next-win-edges)))))
         (splitter
          (if (= (car this-win-edges)
             (car (window-edges (next-window))))
          'split-window-horizontally
        'split-window-vertically)))
    (delete-other-windows)
    (let ((first-win (selected-window)))
      (funcall splitter)
      (if this-win-2nd (other-window 1))
      (set-window-buffer (selected-window) this-win-buffer)
      (set-window-buffer (next-window) next-win-buffer)
      (select-window first-win)
      (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "C-x |") 'toggle-window-split)

(setq visible-bell t)

(use-package dired-subtree
  :config
  (bind-keys :map dired-mode-map
             ("i" . dired-subtree-insert)
             (";" . dired-subtree-remove)))

(setq x-stretch-cursor t)

(use-package spacemacs-theme
  :ensure t
  :init
  (load-theme 'spacemacs-dark t)
  (load-theme 'smart-mode-line-dark t)
  (setq spacemacs-theme-org-agenda-height nil)
  (setq spacemacs-theme-org-height nil))

(use-package spaceline
  :demand t
  :init
  (setq powerline-default-separator 'arrow-fade)
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))


(use-package eyebrowse
  :diminish eyebrowse-mode
  :config (progn
            (define-key eyebrowse-mode-map (kbd "C-M-1") 'eyebrowse-switch-to-window-config-1)
            (define-key eyebrowse-mode-map (kbd "C-M-2") 'eyebrowse-switch-to-window-config-2)
            (define-key eyebrowse-mode-map (kbd "C-M-3") 'eyebrowse-switch-to-window-config-3)
            (define-key eyebrowse-mode-map (kbd "C-M-4") 'eyebrowse-switch-to-window-config-4)
            (eyebrowse-mode t)
            (setq eyebrowse-new-workspace t)))

(use-package with-editor
  :ensure t
  )

;; Bind TAB to complete stuff.
(define-key helm-map (kbd "TAB")         'helm-execute-persistent-action)
;; Rebind `helm-select-action' (originally bound to TAB).
(define-key helm-map (kbd "C-j")         'helm-select-action)

;; (use-package irony
;;   :init
;;   (add-hook 'c++-mode-hook 'irony-mode)
;;   (add-hook 'c-mode-hook 'irony-mode)
;;   (add-hook 'objc-mode-hook 'irony-mode)
;;   (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
;;   )

;; (use-package rtags
;;   :init
;;   (add-hook 'irony-mode-hook 'rtags-start-process-unless-running)
;;   )

;; (eval-after-load 'company
;;   '(add-to-list 'company-backends 'company-irony))

(setq org-reveal-root "file:///home/sindre/.reveal.js-3.5.0")

(provide 'emacs_config)
;;; emacs_config.el ends here
