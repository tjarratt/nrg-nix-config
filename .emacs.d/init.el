;;; init.el --- Init-file
;;
;;; Commentary:
;;   For latest Emacs version:
;;   sudo add-apt-repository ppa:ubuntu-elisp/ppa
;;
;;   Inspiration:
;;    - https://www.masteringemacs.org/
;;    - https://writequit.org/org/settings.html
;;    - https://home.elis.nu/emacs/
;;    - https://pages.sachachua.com/.emacs.d/Sacha.html
;;    - https://github.com/jorgenschaefer/Config/blob/master/emacs.el
;;    - https://github.com/alhassy/emacs.d
;;
;;; Code:
;;; *** General setup ***
;;;; --- Encoding ---
(prefer-coding-system       'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-language-environment   'utf-8)
(if (eq system-type 'windows-nt)
    ;; Fixes pasting character codes instead of symbols and danish letters
    (set-selection-coding-system 'utf-16-le)
  (set-selection-coding-system 'utf-8))

;;;; --- Use-package ---
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
             '("elpy" . "https://jorgenschaefer.github.io/packages/"))
(package-initialize)

;; Bootstrap `use-package'
;; For TLS on windows: http://alpha.gnu.org/gnu/emacs/pretest/windows/
;; Download correct -dep file (x86_64) and unpack in emacs install directory
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;;;; --- Benchmark init ---
(use-package benchmark-init
  :ensure t
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'after-init-hook 'benchmark-init/deactivate))

;;;; --- Setup ---
;; Setup directories in ~/.emacs.d/
(dolist (folder '("lisp"
                  "backups"
                  "temp"
                  "autosave"
                  "org-files"
                  "org-files/gtd"))
  (let ((dir (concat "~/.emacs.d/" folder)))
    (if (not (file-directory-p dir))
        (make-directory dir))))
(add-to-list 'load-path "~/.emacs.d/lisp/")
(setq backup-directory-alist         '(("." . "~/.emacs.d/backups/"))
      temporary-file-directory       "~/.emacs.d/temp/"
      auto-save-file-name-transforms '((".*" "~/.emacs.d/autosave/" t))
      ;; This is never loaded
      custom-file                    "~/.emacs.d/custom.el")

;; Make it easier to answer prompts
(defalias 'yes-or-no-p 'y-or-n-p)

;; Load local configuration
(let ((local-init-file "~/.emacs.d/local-init.el"))
  (when (file-exists-p local-init-file)
    (load-file local-init-file)))

;; This fixes the issue with dead keys that pops up once in a while
(define-key key-translation-map [dead-grave] "`")
(define-key key-translation-map [dead-acute] "'")
(define-key key-translation-map [dead-circumflex] "^")
(define-key key-translation-map [dead-diaeresis] "\"")
(define-key key-translation-map [dead-tilde] "~")

;; At work?
(defvar at-work-p (string= user-login-name
                           "sarah.stoltze"))

;; General variables
(setq inhibit-startup-screen                t
      initial-scratch-message               nil

      ;; Load newest file from disk
      load-prefer-newer                     t

      ;; Delete to trash
      delete-by-moving-to-trash             t

      ;; Exit read-only buffers with q
      view-read-only                        t

      ;; Copy-paste
      select-enable-clipboard               t
      save-interprogram-paste-before-kill   t

      ;; Make case insensitive
      completion-ignore-case                t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case    t

      ;; Use disk space
      version-control                       t
      delete-old-versions                   t
      vc-make-backup-files                  t
      backup-by-copying                     t
      vc-follow-symlinks                    t
      kept-new-versions                     64

      ;; History
      history-length                        t
      history-delete-duplicates             t

      ;; Add newlines when scrolling a file
      next-line-add-newlines                t

      ;; Remove mouse pointer while typing
      make-pointer-invisible                t

      ;; Garbage collector
      gc-cons-threshold                     (* 100 1024 1024) ;; 100 mb

      ;; Personal info
      user-full-name                        "Sarah Stoltze"
      user-mail-address                     (cond (at-work-p "sarah.stoltze@maersk.com")
                                                  (t         "sstoltze@gmail.com"))

      ;; Disable the bell
      ring-bell-function                    'ignore

      ;; Add directory name to buffer if name is not unique
      uniquify-buffer-name-style            'forward

      ;; Prettify symbols
      prettify-symbols-unprettify-at-point  'right-edge

      ;; Font lock
      jit-lock-stealth-time                 1
      jit-lock-chunk-size                   1000
      jit-lock-defer-time                   0.05

      ;; Use memory to improve speed
      ;; Possibly this does not improve anything, so delete if any issues show up
      inhibit-compacting-font-caches        t

      ;; Themes
      custom-theme-directory                "~/.emacs.d/themes/"
      custom-safe-themes                    t

      ;; Scrolling forward and then back preserves point position
      scroll-preserve-screen-position       t

      show-paren-delay                      0

      ;; Add final newline when saving a file - set to 'visit to do it on visit but not save
      require-final-newline                 t)

;; Do not use tabs
(setq-default indent-tabs-mode              nil
              show-trailing-whitespace      t
              tab-width                     4
              tab-always-indent             'complete)

(set-face-background 'trailing-whitespace "IndianRed4")

;; Disable various modes
(dolist (mode '(tool-bar-mode
                scroll-bar-mode
                tooltip-mode
                menu-bar-mode
                electric-indent-mode
                blink-cursor-mode))
  (when (fboundp mode)
    (funcall mode -1)))

;; Enable various modes
(dolist (mode '(show-paren-mode
                ;; Prettify symbols
                global-prettify-symbols-mode
                ;; Column in modeline
                column-number-mode
                ;; Automatically reload changed files
                global-auto-revert-mode))
  (when (fboundp mode)
    (funcall mode 1)))

;; Highlight current line
(add-hook 'prog-mode-hook 'hl-line-mode)

;; Delete extra lines and spaces when saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Unset suspend keys. Never used anyway
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-x C-z"))

;; Automatic indent on pressing RET
(global-set-key (kbd "RET") 'newline-and-indent)

;; Do not ask to kill buffer every time
(global-set-key (kbd "C-x k") 'kill-this-buffer)

;; Better behaviour for M-SPC
(global-set-key (kbd "M-SPC") 'cycle-spacing)

;; Better DWIM behaviour
(global-set-key (kbd "M-c") 'capitalize-dwim)
(global-set-key (kbd "M-u") 'upcase-dwim)
(global-set-key (kbd "M-l") 'downcase-dwim)

;; Prettify symbols
;; C-x 8 RET to find and insert unicode char
;; Look at variable reference-point-alist for explanation
(defun sstoltze/prettify-symbol-list (list)
  "Add LIST to 'prettify-symbols-alist'."
  (mapc (lambda (pair)
          (push pair prettify-symbols-alist))
        list))

(defun sstoltze/remove-prettify-symbol (string)
  "Delete STRING from 'prettify-symbols-alist'."
  (setq prettify-symbols-alist (delq (assoc string prettify-symbols-alist)
                                     prettify-symbols-alist)))

(defun sstoltze/prettify-symbols-setup ()
  "Setup prettify-symbols with common expressions."
  (sstoltze/remove-prettify-symbol "lambda")
  (sstoltze/remove-prettify-symbol "&&")
  (sstoltze/remove-prettify-symbol "||")
  (sstoltze/remove-prettify-symbol "<=")
  (sstoltze/remove-prettify-symbol ">=")
  (sstoltze/remove-prettify-symbol "!=")
  (sstoltze/remove-prettify-symbol "INFINITY")
  (sstoltze/prettify-symbol-list
   '(("->"  . 8594)
     ("=>"  . 8658)
     ("->>" . (?\s (Br . Bl) ?\s (Br . Bl) ?\s
                   (Bl . Bl) ?-  (Bc . Br) ?- (Bc . Bc) ?>
                   (Bc . Bl) ?-  (Br . Br) ?>))
     ("<-"  . 8592))))
(add-hook 'prog-mode-hook 'sstoltze/prettify-symbols-setup)

(defun sstoltze/prettify-clojure ()
  "Setup pretty clojure symbols."
  (sstoltze/remove-prettify-symbol "fn")
  (sstoltze/prettify-symbol-list
   '(("fn" . (?\s (Br . Bl) ?\s
                  (Bc . Bc) ?λ)))))

;; Enable C-x C-u (upcase-region)
(put 'upcase-region    'disabled nil)
;; Enable C-x C-l (downcase region)
(put 'downcase-region  'disabled nil)
;; Enable C-x n n (narrow-to-region)
(put 'narrow-to-region 'disabled nil)

;; Press 'C-x r j e' to go to init.el
(set-register ?e '(file . "~/.emacs.d/init.el"))
(set-register ?g '(file . "~/git"))
(set-register ?w '(file . "~/work"))

;;;; --- Modeline ---

;; Time in modeline
(use-package time
  :custom
  (display-time-24hr-format          t)
  (display-time-day-and-date         nil)
  (display-time-default-load-average nil)
  (display-time-use-mail-icon        t)
  :init
  (display-time-mode t))

;;;; --- Calendar ---
(use-package calendar
  :defer t
  :custom
  ;; Weeks start monday
  (calendar-week-start-day     1)
  (calendar-date-style         'european)
  (calendar-time-display-form  '(24-hours ":" minutes))
  (calendar-date-display-form  '((if dayname
                                     (concat dayname ", "))
                                 day " " monthname " " year))
  (calendar-mark-holidays-flag t)
  :init
  ;; Week number in calendar
  (copy-face font-lock-constant-face 'calendar-iso-week-face)
  (set-face-attribute 'calendar-iso-week-face nil
                      :height 0.6
                      :foreground "dim grey")
  (copy-face font-lock-constant-face 'calendar-iso-week-header-face)
  (set-face-attribute 'calendar-iso-week-header-face nil
                      :height 0.6
                      :foreground "dark slate grey")
  (setq calendar-intermonth-text '(propertize
                                   (format "%2d"
                                           (car
                                            (calendar-iso-from-absolute
                                             (calendar-absolute-from-gregorian (list month day year)))))
                                   'font-lock-face 'calendar-iso-week-face)
        calendar-intermonth-header (propertize "Wk"
                                               'font-lock-face 'calendar-iso-week-header-face))
  :config
  (set-face-attribute 'holiday nil
                      :foreground (face-foreground 'font-lock-comment-face)
                      :background (face-background 'default))
  ;; From https://raw.githubusercontent.com/soren/elisp/master/da-kalender.el
  ;; Calculation of easter, the fix point for many holidays (taken from
  ;; sv-kalender.el, originally from holiday-easter-etc)
  (defun da-easter (year)
    "Calculate the date for Easter in YEAR."
    (let* ((century (1+ (/ year 100)))
           (shifted-epact (% (+ 14 (* 11 (% year 19))
                                (- (/ (* 3 century) 4))
                                (/ (+ 5 (* 8 century)) 25)
                                (* 30 century))
                             30))
           (adjusted-epact (if (or (= shifted-epact 0)
                                   (and (= shifted-epact 1)
                                        (< 10 (% year 19))))
                               (1+ shifted-epact)
                             shifted-epact))
           (paschal-moon (- (calendar-absolute-from-gregorian
                             (list 4 19 year))
                            adjusted-epact)))
      (calendar-dayname-on-or-before 0 (+ paschal-moon 7))))
  (defvar general-holidays
    '((holiday-fixed 1 1 "Nytårsdag")
      (holiday-fixed 1 6 "Hellige 3 konger")
      ;; Easter and Pentecost
      (holiday-filter-visible-calendar
       (mapcar
        (lambda (dag)
          (list (calendar-gregorian-from-absolute
                 (+ (da-easter displayed-year) (car dag)))
                (cadr dag)))
        '(( -49 "Fastelavn")
          (  -7 "Palmesøndag")
          (  -3 "Skærtorsdag")
          (  -2 "Langfredag")
          (   0 "Påskedag")
          (  +1 "Anden påskedag")
          ( +26 "Store bededag")
          ( +39 "Kristi himmelfartsdag")
          ( +49 "Pinsedag")
          ( +50 "Anden pinsedag"))))
      (holiday-fixed 12 24 "Juleaften")
      (holiday-fixed 12 25 "Juledag")
      (holiday-fixed 12 26 "Anden juledag")
      (holiday-fixed 12 31 "Nytårsaften")))
  (defvar other-holidays
    '((holiday-fixed 3 8 "Kvindernes internationale kampdag")
      (holiday-fixed 5 1 "Arbejdernes internationale kampdag")
      (holiday-fixed 5 4 "Danmarks befrielse")
      (holiday-float 5 0 2 "Mors dag")
      (holiday-fixed 6 5 "Grundlovsdag")
      (holiday-fixed 6 5 "Fars dag")
      (holiday-fixed 6 15 "Valdemarsdag (Dannebrog)")
      (holiday-fixed 6 24 "Skt. Hans dag")))
  (defvar calendar-holidays (append general-holidays other-holidays)))

;;;; Recentf
(use-package recentf
  :custom
  (recentf-max-saved-items 500)
  (recentf-exclude '("/auto-install/" ".recentf" "/elpa/" ".gz" "/tmp/" "/ssh:" "/sudo:" "/scp:"))
  :init
  (recentf-mode 1)
  :config
  (setq recentf-filename-handlers (append '(abbreviate-file-name) recentf-filename-handlers))
  (run-at-time nil (* 10 60)
               (lambda ()
                 (let ((save-silently t))
                   (recentf-save-list)))))

;; Make C-x C-x not activate region
(defun exchange-point-and-mark-no-activate ()
  "Identical to \\[exchange-point-and-mark] but will not activate the region."
  (interactive)
  (exchange-point-and-mark)
  (deactivate-mark nil))
(global-set-key [remap exchange-point-and-mark]
                'exchange-point-and-mark-no-activate)

;; Better C-a
(defun my/smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line.
Effectively toggle between the first non-whitespace character and
the beginning of the line.

If ARG is not nil or 1, move forward ARG - 1 lines first.  If
point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))
  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))
;; Remap C-a to `smarter-move-beginning-of-line'
(global-set-key [remap move-beginning-of-line]
                'my/smarter-move-beginning-of-line)

;; Indent entire buffer
(defun indent-buffer ()
  "Indent entire buffer."
  (interactive)
  (indent-region (point-min) (point-max)))
(global-set-key (kbd "C-c <tab>")
                'indent-buffer)

(defun byte-compile-init-dir ()
  "Byte-compile .emacs.d/."
  (interactive)
  (byte-recompile-directory user-emacs-directory 0))

(defun sstoltze/replace-danish-in-buffer ()
  "Replace weird characters in copied danish text."
  (interactive)
  (save-excursion
    (dolist (l '(("\346" . "æ")
                 ("\370" . "ø")
                 ("\345" . "å")
                 ("\306" . "Æ")
                 ("\330" . "Ø")
                 ("\305" . "Å")
                 ("\351" . "é")
                 ("\344" . "ä")
                 ("\353" . "ë")
                 ("\357" . "ï")
                 ("\366" . "ö")
                 ("\374" . "ü")
                 ("\267" . "∙")))
      (goto-char (point-min))
      (while (re-search-forward (car l) nil t)
        (replace-match (cdr l))))))

(defun toggle-comment-on-line ()
  "Comment or uncomment current line."
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))
(global-set-key (kbd "C-;") 'toggle-comment-on-line)

;; https://emacs.stackexchange.com/questions/39034/prefer-vertical-splits-over-horizontal-ones
(defun split-window-sensibly-prefer-horizontal (&optional window)
  "Split WINDOW like 'split-window-sensibly', but designed to prefer a horizontal split."
  (let ((window (or window (selected-window))))
    (or (and (window-splittable-p window t)
             ;; Split window horizontally
             (with-selected-window window
               (split-window-right)))
        (and (window-splittable-p window)
             ;; Split window vertically
             (with-selected-window window
               (split-window-below)))
        (and
         ;; If WINDOW is the only usable window on its frame (it is
         ;; the only one or, not being the only one, all the other
         ;; ones are dedicated) and is not the minibuffer window, try
         ;; to split it horizontally disregarding the value of
         ;; `split-height-threshold'.
         (let ((frame (window-frame window)))
           (or
            (eq window (frame-root-window frame))
            (catch 'done
              (walk-window-tree (lambda (w)
                                  (unless (or (eq w window)
                                              (window-dedicated-p w))
                                    (throw 'done nil)))
                                frame)
              t)))
         (not (window-minibuffer-p window))
         (let ((split-width-threshold 0))
           (when (window-splittable-p window t)
             (with-selected-window window
               (split-window-right))))))))

(defun split-window-really-sensibly (&optional window)
  "Split WINDOW with a slight preference to horizontal splits."
  (let ((window (or window (selected-window))))
    (if (> (window-total-width window) (* 2.5 (window-total-height window)))
        (with-selected-window window (split-window-sensibly-prefer-horizontal window))
      (with-selected-window window (split-window-sensibly window)))))

(setq split-window-preferred-function 'split-window-really-sensibly)

;;;; --- Whitespace ---
;; This conflicts slightly with show-trailing-whitespace, but for now I'll keep both on
(use-package whitespace-mode
  :defer t
  :diminish whitespace-mode
  :hook ((prog-mode       . whitespace-mode)
         (magit-diff-mode . whitespace-mode))
  :custom
  (whitespace-style '(face trailing tabs empty space-before-tab space-after-tab))
  :config
  (set-face-background 'whitespace-empty    "IndianRed4")
  (set-face-background 'whitespace-trailing "IndianRed4"))

;; Borrowed from https://karthinks.com/software/batteries-included-with-emacs/
(defun pulse-line (&rest _)
  "Pulse the current line."
  (pulse-momentary-highlight-one-line (point)))

(dolist (command (list #'scroll-up-command
                       #'scroll-down-command
                       #'recenter-top-bottom
                       #'other-window))
  (advice-add command :after #'pulse-line))

;; Handle long lines - currently disabled
(use-package so-long
  :ensure t
  :defer t)

;;;; --- Unicode ---
;; This took a long time starting up the first time - disable if it gets annoying
(use-package unicode-fonts
  :ensure t
  :config
  (unicode-fonts-setup))

;; This should be enough for emojis
(set-fontset-font t 'symbol "Noto Color Emoji")
(set-fontset-font t 'symbol "Symbola" nil 'append)

;;;; --- Frame-setup ---
(cond ((display-graphic-p) ;; Window system
       ;; Fonts
       ;; Iosevka - Better horizontal splits
       ;; sudo add-apt-repository ppa:laurent-boulard/fonts
       ;; sudo apt install fonts-iosevka
       ;; Or
       ;; nix-env -i iosevka iosevka-bin
       ;; guix package -i font-iosevka font-iosevka-term
       (cond ((find-font (font-spec :name "Iosevka"))
              (cond ((eq system-type 'darwin)
                     (set-frame-font "Iosevka-14" nil t))
                    (t
                     (set-frame-font "Iosevka-13" nil t)))))
       ;; Fira Code - Better vertical splits - better modeline
       ;; sudo apt install fonts-firacode
       ;; (set-frame-font "Fira Code-10")

       ;; Fringe (default): black, background: #181a26
       (with-eval-after-load 'highlight-indentation
         (set-face-background 'highlight-indentation-face "#252040"))
       ;; The default "Yellow" of deeper-blue is not great
       (set-face-foreground 'warning "goldenrod1")
       (setq frame-resize-pixelwise t)

       ;; Unset C-m = RET
       (define-key input-decode-map [?\C-m] [C-m])
       (define-key input-decode-map [?\C-\M-m] [C-M-m])

       (define-key input-decode-map [?\C-i] [C-i])

       (global-set-key (kbd "C-<tab>")
                       'other-window)
       (global-set-key (kbd "C-s-<tab>")
                       (lambda ()
                         (interactive)
                         (other-window -1)))
       (global-set-key (kbd "<C-iso-lefttab>")
                       (lambda ()
                         (interactive)
                         (other-window -1)))

       (defun sstoltze/display-buffer (buffer &optional alist)
         "Select window for BUFFER (need to use word ALIST on the first line).
Returns second visible window if there are three visible windows,
nil otherwise.  Minibuffer is ignored.
Also stolen from 'https://www.simplify.ba/articles/2016/01/25/display-buffer-alist/'."
         (let ((wnr (if (active-minibuffer-window) 2 1)))
           (when (= (+ wnr 2) (length (window-list)))
             (let ((window (nth wnr (window-list))))
               (set-window-buffer window buffer)
               window))))

       (defun sstoltze/setup-help-buffers ()
         "Setup help buffers for use with sstoltze/split-windows."
         (let ((sstoltze/help-temp-buffers '("^\\*Flycheck errors\\*$"
                                             "^\\*Completions\\*$"
                                             "^\\*Help\\*$"
                                             ;; Other buffers names...
                                             "^\\*Colors\\*$"
                                             "^\\*Async Shell Command\\*$")))

           (while sstoltze/help-temp-buffers
             (add-to-list 'display-buffer-alist
                          `(,(car sstoltze/help-temp-buffers)
                            (display-buffer-reuse-window
                             sstoltze/display-buffer
                             display-buffer-in-side-window)
                            (reusable-frames     . visible)
                            (side                . top)))
             (setq sstoltze/help-temp-buffers (cdr sstoltze/help-temp-buffers)))))

       (defun sstoltze/split-windows ()
         "Stolen from 'https://www.simplify.ba/articles/2016/01/25/display-buffer-alist/'."
         (interactive)
         ;; Create new window right of the current one
         ;; Current window is 80 characters (columns) wide
         (split-window-right)
         ;; Go to next window
         (other-window 1)
         ;; Create new window below current one
         (split-window-below)
         ;; Switch to a *scratch*
         (switch-to-buffer "*scratch*")
         ;; Go to next window
         (other-window 1)
         ;; Start eshell in current window
         (eshell)
         ;; Go to first window
         (other-window -2)
         ;; never open any buffer in window with shell
         (set-window-dedicated-p (nth 2 (window-list)) t)
         (sstoltze/setup-help-buffers))

       (when (not (or (string= (getenv "GDMSESSION") "awesome")
                      (string= (getenv "GDMSESSION") "none+awesome")))

         ;; Set initial frame size and position
         (defvar *sstoltze/position-factor*    0.40)
         (defvar *sstoltze/width-factor*       0.90)
         (defvar *sstoltze/half-width-factor*  0.45)
         (defvar *sstoltze/height-factor*      0.90)
         (defvar *sstoltze/half-height-factor* 0.50)
         (defun sstoltze/get-main-monitor-size ()
           "Get pixels for multiple-monitor setup."
           (let* ((monitors          (display-monitor-attributes-list))
                  (main-monitor      (car monitors))
                  (main-workarea     (assoc 'workarea main-monitor))
                  (main-pixel-width  (nth 3 main-workarea))
                  (main-pixel-height (nth 4 main-workarea)))
             (list main-pixel-width main-pixel-height)))
         (defun sstoltze/set-frame-position (left top width height)
           "Automatically place frame on correct display.
LEFT and TOP are window placements, WIDTH and HEIGHT are sizes."
           (let* ((main-workarea (assoc 'workarea
                                        (car (display-monitor-attributes-list))))
                  (monitor-x     (nth 1 main-workarea))
                  (monitor-y     (nth 2 main-workarea)))
             (set-frame-position (selected-frame) (+ monitor-x left) (+ monitor-y top))
             (set-frame-size     (selected-frame) width height t)))
         (defun sstoltze/set-normal-frame ()
           "Standard frame setup."
           (let* ((pixels             (sstoltze/get-main-monitor-size))
                  (main-pixel-width   (nth 0 pixels))
                  (main-pixel-height  (nth 1 pixels))
                  (frame-pixel-width  (truncate (* main-pixel-width  *sstoltze/width-factor*)))
                  (frame-pixel-height (truncate (* main-pixel-height *sstoltze/height-factor*)))
                  (frame-pixel-left   (truncate (* (- main-pixel-width  frame-pixel-width)  *sstoltze/position-factor*)))
                  (frame-pixel-top    (truncate (* (- main-pixel-height frame-pixel-height) *sstoltze/position-factor*))))
             (sstoltze/set-frame-position frame-pixel-left frame-pixel-top
                                          frame-pixel-width frame-pixel-height)))
         (defun sstoltze/set-left-small-frame ()
           "Frame on the left."
           (let* ((pixels             (sstoltze/get-main-monitor-size))
                  (main-pixel-width   (nth 0 pixels))
                  (main-pixel-height  (nth 1 pixels))
                  (frame-pixel-width  (truncate (* main-pixel-width  *sstoltze/half-width-factor*)))
                  (frame-pixel-height (truncate (* main-pixel-height *sstoltze/height-factor*)))
                  (frame-pixel-left   0)
                  (frame-pixel-top    (truncate (* (- main-pixel-height frame-pixel-height) *sstoltze/position-factor*))))
             (sstoltze/set-frame-position frame-pixel-left frame-pixel-top
                                          frame-pixel-width frame-pixel-height)))
         (defun sstoltze/set-right-small-frame ()
           "Frame on the right."
           (let* ((pixels             (sstoltze/get-main-monitor-size))
                  (main-pixel-width   (nth 0 pixels))
                  (main-pixel-height  (nth 1 pixels))
                  (frame-pixel-width  (truncate (* main-pixel-width  *sstoltze/half-width-factor*)))
                  (frame-pixel-height (truncate (* main-pixel-height *sstoltze/height-factor*)))
                  (frame-pixel-left   (truncate (- (* main-pixel-width 0.98) frame-pixel-width)))
                  (frame-pixel-top    (truncate (* (- main-pixel-height frame-pixel-height) *sstoltze/position-factor*))))
             (sstoltze/set-frame-position frame-pixel-left frame-pixel-top
                                          frame-pixel-width frame-pixel-height)))
         (defun sstoltze/set-top-small-frame ()
           "Frame on the left."
           (let* ((pixels             (sstoltze/get-main-monitor-size))
                  (main-pixel-width   (nth 0 pixels))
                  (main-pixel-height  (nth 1 pixels))
                  (frame-pixel-width  (truncate (* main-pixel-width  *sstoltze/width-factor*)))
                  (frame-pixel-height (truncate (* main-pixel-height *sstoltze/half-height-factor*)))
                  (frame-pixel-left   (truncate (* (- main-pixel-width  frame-pixel-width)  *sstoltze/position-factor*)))
                  (frame-pixel-top    0))
             (sstoltze/set-frame-position frame-pixel-left frame-pixel-top
                                          frame-pixel-width frame-pixel-height)))
         (defun sstoltze/set-bottom-small-frame ()
           "Frame on the left."
           (let* ((pixels             (sstoltze/get-main-monitor-size))
                  (main-pixel-width   (nth 0 pixels))
                  (main-pixel-height  (nth 1 pixels))
                  (frame-pixel-width  (truncate (* main-pixel-width  *sstoltze/width-factor*)))
                  (frame-pixel-height (truncate (* main-pixel-height *sstoltze/half-height-factor*)))
                  (frame-pixel-left   (truncate (* (- main-pixel-width  frame-pixel-width)  *sstoltze/position-factor*)))
                  (frame-pixel-top    (truncate (- (* main-pixel-height 0.97) frame-pixel-height))))
             (sstoltze/set-frame-position frame-pixel-left frame-pixel-top
                                          frame-pixel-width frame-pixel-height)))
         ;; Set starting frame
         (sstoltze/set-normal-frame)
         ;; Alt-enter toggles screensize
         (defmacro handle-fullscreen-mode (func)
           "Handle toggling of fullscreen.  FUNC is called after."
           `(progn
              (when *fullscreen-set*
                (toggle-frame-fullscreen)
                (setq *fullscreen-set* nil))
              (funcall ,func)))
         (defvar *fullscreen-set* nil)
         (defvar *window-status*  0)
         (defvar *window-options* (list
                                   (lambda ()
                                     (handle-fullscreen-mode #'sstoltze/set-normal-frame))
                                   (lambda ()
                                     (when (not *fullscreen-set*)
                                       (toggle-frame-fullscreen)
                                       (setq *fullscreen-set* t)))
                                   (lambda ()
                                     (handle-fullscreen-mode #'sstoltze/set-left-small-frame))
                                   (lambda ()
                                     (handle-fullscreen-mode #'sstoltze/set-right-small-frame))
                                   (lambda ()
                                     (handle-fullscreen-mode #'sstoltze/set-top-small-frame))
                                   (lambda ()
                                     (handle-fullscreen-mode #'sstoltze/set-bottom-small-frame))))
         (defun toggle-window (arg)
           "Toggle the window state to the next *window-options*.
If ARG is provided, move directly to option ARG."
           (interactive "P")
           (when arg
             (message "%s" arg)
             ;; (- arg 2) makes C-1 M-RET correspond to sstoltze/set-normal-frame
             (setq *window-status* (mod (- (prefix-numeric-value arg) 2)
                                        (length *window-options*))))
           (setq *window-status* (mod (1+ *window-status*)
                                      (length *window-options*)))
           (funcall (nth *window-status* *window-options*)))
         (global-set-key (kbd "M-RET")     'toggle-window)
         (global-set-key (kbd "M-<left>")  #'(lambda () (interactive) (toggle-window 3)))
         (global-set-key (kbd "M-<right>") #'(lambda () (interactive) (toggle-window 4)))
         (global-set-key (kbd "M-<up>")    #'(lambda () (interactive) (toggle-window 5)))
         (global-set-key (kbd "M-<down>")  #'(lambda () (interactive) (toggle-window 6)))))
      (t ;; Terminal - not used since deeper-blue seems to work well with kitty
       nil))
(load-theme 'deeper-blue t)
(set-face-background 'cursor "burlywood")

;;; *** Packages ***

;;;; --- Diminish ---
;; Remove some things from modeline. Used by use-package.
(use-package diminish
  :ensure t
  :config
  (diminish 'eldoc-mode "")
  (diminish 'company-mode "")
  (diminish 'auto-revert-mode ""))

;;;; --- Visible mark ---
(use-package visible-mark
  :ensure t
  :custom
  (visible-mark-max 1)
  :init
  ;; Set face for mark
  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Face-Attributes.html
  (defface visible-mark-face1
    '((((type graphic))        ;; Graphics support
       (:box t))               ;; (:underline (:color "green" :style wave))
      (t                       ;; No graphics support - no box
       (:inverse-video t)))    ;;
    "Style for visible mark"
    :group 'visible-mark-group)
  (defface visible-mark-face2
    '((((type graphic))        ;; Graphics support
       (:overline t :underline t))
      (t                       ;; No graphics support - no box
       (:inverse-video t)))
    "Style for secondary mark"
    :group 'visible-mark-group)
  (setq visible-mark-faces  '(visible-mark-face1
                              visible-mark-face2))
  (global-visible-mark-mode 1))

;;;; --- Dired ---
(use-package dired
  :hook ((dired-mode . hl-line-mode))
  :bind ((:map dired-mode-map
               ("b" . dired-up-directory)))
  :custom
  (ls-lisp-dirs-first                  t)
  (dired-recursive-copies              'always)
  (dired-recursive-deletes             'always)
  (dired-dwim-target                   t)
  ;; -F marks links with @
  (dired-ls-F-marks-symlinks           t)
  ;; Auto refresh dired
  (global-auto-revert-non-file-buffers t)
  ;; Make size listing human readable
  (dired-listing-switches              "-alh")
  :config
  (put 'dired-find-alternate-file 'disabled nil))

(use-package dired-x
  :after dired
  :bind (("C-x C-j" . dired-jump))
  :config
  (add-to-list 'dired-omit-extensions ".DS_Store"))

(use-package dired-aux
  :after dired)

(use-package dired-sidebar
  :ensure t
  :bind (("C-c j" . dired-sidebar-toggle-sidebar))
  :custom
  (dired-sidebar-subtree-line-prefix "  |"))

(use-package peep-dired
  :ensure t
  :after dired
  :bind ((:map dired-mode-map
               ("P" . peep-dired))
         (:map peep-dired-mode-map
               ("n" . peep-dired-next-file)
               ("p" . peep-dired-prev-file)))
  :custom
  (peep-dired-cleanup-on-disable t)
  (peep-dired-ignored-extensions
   '("mkv" "webm" "mp4" "mp3" "ogg" "iso")))

(use-package dired-collapse
  :ensure t
  :after dired
  :hook ((dired-mode . dired-collapse-mode)))

;;;; Compile
(use-package compile
  :custom
  (compilation-scroll-output 'first-error)
  (compilation-always-kill t)
  (next-error-hightlight t))

;; Native compilation
(use-package comp
  :custom
  ;; Silence all the warnings from compiling things in the background
  (native-comp-async-report-warnings-errors 'silent))

;;;; --- Proced ---
;; To highlight processes use highlight-lines-matching-regexp, M-s h l
;; Unhighlight by unhighlight-regexp, M-s h u
(use-package proced
  :bind (("C-c t" . proced))
  :hook ((proced-mode . hl-line-mode)
         ;; Update every 5 seconds
         (proced-mode . (lambda ()
                          (proced-toggle-auto-update 1)))))

;;;; --- Eshell ---
(use-package eshell
  :bind (("C-c e" . eshell))
  :hook ((eshell-mode . (lambda ()
                          (eshell-smart-initialize)
                          (esh-autosuggest-mode 1)
                          ;; We only need to create aliases once
                          (when (not (file-exists-p "~/.emacs.d/eshell/alias"))
                            (eshell/alias "emacs" "find-file $1")
                            (eshell/alias "magit" "magit-status")
                            (eshell/alias "less"  "cat $1")
                            (when (eq system-type 'windows-nt)
                              (eshell/alias "desktop"
                                            (concat "C:/Users/"
                                                    (user-login-name)
                                                    "/Desktop/"))))))
         ;; Send message when command finishes and buffer is not active
         ;; Alternatively, look at package 'alert'
         (eshell-kill . (lambda (process status)
                          "Shows process and status in minibuffer when a command finishes."
                          (let ((buffer (process-buffer process)))
                            ;; To check buffer not focused, use
                            ;;   (eq buffer (window-buffer (selected-window)))
                            ;; Check buffer is not visible
                            (if (not (get-buffer-window buffer))
                                (message "%s: %s."
                                         process
                                         ;; Replace final newline with nothing
                                         (replace-regexp-in-string "\n\\'" ""
                                                                   status)))))))
  :bind ((:map eshell-mode-map
               ("C-c h"   . (lambda ()
                              "Ivy interface to eshell history."
                              (interactive) ;; Maybe insert move-to-end-of-buffer here
                              (insert
                               (ivy-completing-read "History: "
                                                    (delete-dups
                                                     (ring-elements eshell-history-ring))))))))
  :custom
  (eshell-ls-use-colors                    t)
  ;; History
  (eshell-save-history-on-exit             t)
  (eshell-history-size                     256000)
  (eshell-hist-ignoredups                  t)
  ;; Globbing
  (eshell-glob-case-insensitive            t)
  (eshell-error-if-no-glob                 t)
  ;; Completion
  (eshell-cmpl-cycle-completions           nil)
  (eshell-cmpl-ignore-case                 t)
  ;; Remain at start of command after enter
  (eshell-where-to-jump                    'begin)
  (eshell-review-quick-commands            nil)
  ;; Close buffer on exit
  (eshell-destroy-buffer-when-process-dies t)
  ;; Scrolling
  (eshell-scroll-to-bottom-on-input        t)
  (ehsell-scroll-to-bottom-on-output       nil)
  (eshell-scroll-show-maximum-output       t)
  (eshell-smart-space-goes-to-end          t)
  ;; Banner
  (eshell-banner-message                   "")
  ;; Prompt
  (eshell-prompt-function
   (lambda ()
     (let ((path-colour   "light goldenrod")
           (time-colour   "gray")
           (user-colour   "light sky blue")
           (prompt-colour "gray80"))
       (concat (propertize (format-time-string "%H:%M"
                                               (current-time))
                           'face (list :foreground time-colour))
               " "
               (propertize (user-login-name)
                           'face (list :foreground user-colour))
               " "
               (propertize (fish-path (eshell/pwd) 30)
                           'face (list :foreground path-colour))
               (sstoltze/make-vc-prompt)
               " "
               (propertize ">"
                           'face (list :foreground prompt-colour))
               ;; This resets text properties
               " "))))
  (eshell-prompt-regexp "^[0-9]\\{1,2\\}:[0-9]\\{2\\} .+ .+> ")
  :config
  (use-package esh-autosuggest
    :ensure t
    :config
    ;; Match fish colours for suggestion
    (set-face-attribute 'company-preview-common nil
                        :foreground "gray40"
                        :background (face-background 'default)))
  (use-package em-smart)
  (use-package esh-module
    :config
    (add-to-list 'eshell-load-hook
                 (lambda ()
                   (add-to-list 'eshell-modules-list 'eshell-tramp)
                   ;; enable password caching
                   (setq password-cache t
                         ;; time in seconds
                         password-cache-expiry 600))))
  (setenv "PAGER" "cat")
  ;; Could consider making the colours parameters to be
  ;; able to change them when calling in eshell-prompt-function
  (defun sstoltze/make-vc-prompt ()
    "Small helper for eshell-prompt-function.
If includes git branch-name if magit is loaded
and tries to emulate the fish git prompt.

Can be replaced with:
\(or (ignore-errors (format \" (%s)\"
                           (vc-responsible-backend
                            default-directory)))
    \"\")"
    (let ((vc-standard-colour "pale goldenrod")
          (untracked-colour   "red")
          (unstaged-colour    "yellow green")
          (staged-colour      "royal blue")
          (vc-response        (or (ignore-errors
                                    (format "%s"
                                            (vc-responsible-backend
                                             default-directory)))
                                  "")))
      (cond ((equal vc-response "Git")
             (let ((branch    (or (ignore-errors
                                    (magit-get-current-branch))
                                  "Git"))
                   (untracked (or (ignore-errors
                                    (length (magit-untracked-files)))
                                  0))
                   (unstaged  (or (ignore-errors
                                    (length (magit-unstaged-files)))
                                  0))
                   (staged    (or (ignore-errors
                                    (length (magit-staged-files)))
                                  0)))
               (concat (propertize " ("
                                   'face (list :foreground
                                               vc-standard-colour))
                       (propertize branch
                                   'face (list :foreground
                                               vc-standard-colour))
                       (propertize (if (> (+ untracked unstaged staged) 0)
                                       "|"
                                     (if (equal branch "Git")
                                         ""
                                       "|✔"))
                                   'face (list :foreground
                                               vc-standard-colour))
                       (propertize (if (> untracked 0)
                                       (format "…%s" untracked)
                                     "")
                                   'face (list :foreground
                                               untracked-colour))
                       (propertize (if (> unstaged 0)
                                       (format "+%s" unstaged)
                                     "")
                                   'face (list :foreground
                                               unstaged-colour))
                       (propertize (if (> staged 0)
                                       (format "→%s" staged)
                                     "")
                                   'face (list :foreground
                                               staged-colour))
                       (propertize ")"
                                   'face (list :foreground
                                               vc-standard-colour)))))
            ((equal vc-response "")
             (propertize  ""
                          'face (list :foreground
                                      vc-standard-colour)))
            (t
             (propertize (format " (%s)" vc-response)
                         'face (list :foreground
                                     vc-standard-colour))))))
  (defun fish-path (path max-len)
    "Return a potentially trimmed-down version of the directory PATH, replacing
parent directories with their initial characters to try to get the character
length of PATH (sans directory slashes) down to MAX-LEN."
    (let* ((components (split-string (abbreviate-file-name path) "/"))
           (len (+ (1- (length components))
                   (seq-reduce '+ (mapcar 'length components) 0)))
           (str ""))
      (while (and (> len max-len)
                  (cdr components))
        (setq str (concat str
                          (cond ((= 0 (length (car components))) "/")
                                ((= 1 (length (car components)))
                                 (concat (car components) "/"))
                                (t
                                 (if (string= "."
                                              (string (elt (car components) 0)))
                                     (concat (substring (car components) 0 2)
                                             "/")
                                   (string (elt (car components) 0) ?/)))))
              len (- len (1- (length (car components))))
              components (cdr components)))
      (concat str (seq-reduce (lambda (a b) (concat a "/" b)) (cdr components) (car components))))))

(defun sstoltze/mark-sexp-up ()
  "Move point one level up and mark the following sexp."
  (interactive)
  (sp-backward-sexp 1)
  (sp-up-sexp -1)
  (sp-mark-sexp))

(defconst sstoltze/racket--paren-shapes
  '( (?\( ?\[ ?\] )
     (?\[ ?\{ ?\} )
     (?\{ ?\( ?\) ))
  "This is not user-configurable because we expect them have to have actual ?\( and ?\) char syntax.")

(defun sstoltze/racket-cycle-paren-shapes ()
  "In an s-expression, move to the opening, and cycle the shape among () [] {}.
Stolen from racket-mode because I miss it."
  (interactive)
  (save-excursion
    (unless (eq ?\( (char-syntax (char-after)))
      (backward-up-list))
    (pcase (assq (char-after) sstoltze/racket--paren-shapes)
      (`(,_ ,open ,close)
       (delete-char 1)
       (insert open)
       (backward-char 1)
       (forward-sexp 1)
       (backward-delete-char 1)
       (insert close))
      (_
       (user-error "Don't know that paren shape")))))

(use-package smartparens
  :ensure t
  :defer t
  :diminish smartparens-mode
  :hook ((prog-mode                        . turn-on-smartparens-strict-mode)
         (racket-repl-mode                 . turn-on-smartparens-strict-mode)
         (cider-repl-mode                  . turn-on-smartparens-strict-mode)
         (lisp-interaction-mode            . turn-on-smartparens-strict-mode)
         (slime-repl-mode                  . turn-on-smartparens-strict-mode)
         (eval-expression-minibuffer-setup . turn-on-smartparens-strict-mode)
         (haskell-interactive-mode         . turn-on-smartparens-strict-mode)
         (yaml-mode                        . turn-on-smartparens-strict-mode)
         (conf-mode                        . turn-on-smartparens-strict-mode)
         (inferior-python-mode             . turn-on-smartparens-strict-mode))
  :bind ((:map smartparens-mode-map
               ("M-s"     . sp-splice-sexp)
               ("M-S"     . sp-split-sexp)
               ("M-J"     . sp-join-sexp)
               ("C-M-SPC" . sp-mark-sexp)
               ("<C-M-m>" . sstoltze/mark-sexp-up)
               ("C-("     . sp-backward-slurp-sexp)
               ("C-)"     . sp-forward-slurp-sexp)
               ("C-{"     . sp-backward-barf-sexp)
               ("C-}"     . sp-forward-barf-sexp)
               ("M-("     . sp-wrap-round)
               ("M-{"     . sp-wrap-curly)
               ("M-["     . sp-wrap-square)
               ("M-\""    . (lambda (&optional arg) (interactive "P") (sp-wrap-with-pair "\"")))
               ("C-M-q"   . sp-indent-defun)
               ("M-R"     . sp-raise-sexp)
               ("M-?"     . sp-convolute-sexp)
               ("C-M-u"   . sp-backward-up-sexp)
               ("C-M-n"   . sp-up-sexp)
               ("C-M-d"   . sp-down-sexp)
               ("C-M-p"   . sp-backward-down-sexp)
               ("C-x n s" . sp-narrow-to-sexp)
               ("C-c C-p" . sstoltze/racket-cycle-paren-shapes)))
  :custom
  (sp-highlight-pair-overlay nil)
  :config
  ;; Make smartparens work with M-:
  (setq sp-ignore-modes-list (delete 'minibuffer-inactive-mode sp-ignore-modes-list))
  ;; Ensure ' works in lisps and does other setup
  (require 'smartparens-config))

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :hook ((prog-mode . rainbow-delimiters-mode)))

;;;; --- Nix ---
(defun in-nix-shell-p ()
  "Check whether we are currently in a nix-shell."
  (not (null (getenv "IN_NIX_SHELL"))))

(defun env->load-path (env-key)
  "If ENV-KEY is not set, return '.emacs.d/lisp' which is already in the path."
  (or (getenv env-key)
      "lisp"))

(use-package nix-mode
  :ensure t
  :defer t
  :hook ((nix-mode . (lambda ()
                       (add-hook 'before-save-hook 'nix-format-before-save 0 t))))
  :custom
  (nix-nixfmt-bin "nixpkgs-fmt"))


;;;; --- Flycheck ---
;; Next-error and prev-error are bound to M-g n and M-g p
;; Use C-c ! l to list all errors in a separate buffer
(use-package flycheck
  :ensure t
  :defer t
  ;; Always enabled, do not show in mode-line
  :diminish flycheck-mode
  :hook ((prog-mode . sstoltze/flycheck-if-not-remote)
         (text-mode . sstoltze/flycheck-if-not-remote))
  :custom
  (flycheck-check-syntax-automatically '(save idle-change mode-enable idle-buffer-switch))
  (flycheck-idle-change-delay          2)
  (flycheck-idle-buffer-switch-delay   2)
  (flycheck-elixir-credo-strict        t)
  :init
  ;; Disable flycheck for some modes on remote hosts, due to slowdowns when checking files
  (defun sstoltze/flycheck-if-not-remote ()
    "Do not start flycheck over TRAMP."
    (if (and (file-remote-p default-directory)
             (member major-mode (list 'python-mode)))
        (flycheck-mode -1)
      (flycheck-mode 1))))

(use-package flycheck-posframe
  :ensure t
  :defer t
  :hook ((flycheck-mode . flycheck-posframe-mode))
  :custom
  (flycheck-posframe-border-width 1)
  (flycheck-posframe-position 'point-window-center)
  :custom-face
  ;; This does not take effect immediately for some reason...
  (flycheck-posframe-border-face ((t (:foreground "goldenrod"))))
  :config
  (flycheck-posframe-configure-pretty-defaults))

;;;; --- Auto-insert ---
(use-package autoinsert
  :defer t
  ;; Only do it for org-mode
  :hook ((org-mode . auto-insert))
  :custom
  ;; Insert into file, but mark unmodified
  (auto-insert       'other)
  ;; Do not ask when inserting
  (auto-insert-query nil)
  :config
  (add-to-list 'auto-insert-alist
               '(("\\.org\\'" . "Org header")
                 nil
                 "#+AUTHOR: " user-full-name n
                 "#+EMAIL: "  user-mail-address n
                 "#+DATE: "   (format-time-string "%Y-%m-%d" (current-time)) n
                 "#+OPTIONS: toc:nil title:nil author:nil email:nil date:nil creator:nil" n)))

;;;; --- Org ---
;; Use C-c C-, to replace <sTAB
(use-package org
  :ensure t
  :hook ((org-mode . visual-line-mode)
         (org-mode . org-indent-mode)
         (org-agenda-mode . hl-line-mode)
         (org-babel-after-execute . org-display-inline-images)
         (org-clock-in . (lambda ()
                           ;; Start timer, use default value, replace any running timer
                           (org-timer-set-timer '(16))))
         (after-init . (lambda ()
                         (when (not (eq system-type 'windows-nt))
                           (org-agenda nil "a")))))
  :diminish org-indent-mode
  :diminish visual-line-mode
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture) ;; counsel-org-capture requires more keypresses
         ("C-c a" . org-agenda)
         ;; Use counsel for org tag selection (C-c C-q)
         ([remap org-set-tags-command] . counsel-org-tag))
  :custom
  ;; Startup
  (org-ellipsis                           "…")
  (org-startup-folded                     nil)
  (org-startup-indented                   t)
  (org-startup-with-inline-images         t)
  ;; Use the current window for most things
  (org-agenda-window-setup                'current-window)
  (org-agenda-restore-windows-after-quit  t)
  (org-agenda-start-on-weekday            nil)
  (org-agenda-skip-deadline-if-done       t)
  (org-agenda-skip-scheduled-if-done      t)
  (org-indirect-buffer-display            'current-window)
  ;; Export
  (org-export-backends                    '(ascii beamer html icalendar latex md odt))
  ;; Author, email, date of creation, validation link at bottom of exported html
  (org-html-postamble                     nil)
  (org-html-html5-fancy                   t)
  (org-html-doctype                       "html5")
  ;; Todo
  (org-todo-keywords                      '((sequence "TODO(t)" "NEXT(n)" "STARTED(s/!)" "|" "DONE(d/!)")
                                            (sequence "WAITING(w@/!)" "|" "CANCELED(c@/!)")))
  (org-time-stamp-custom-formats          '("<%Y-%m-%d>" . "<%Y-%m-%d %H:%M>"))
  (org-use-fast-todo-selection            t)
  (org-enforce-todo-dependencies          t)
  (org-log-done                           'time)
  ;; Round clock to 5 minute intervals, delete anything shorter
  (org-clock-rounding-minutes             5)
  (org-log-note-clock-out                 t)
  ;; Allow editing invisible region if it does that you would expect
  (org-catch-invisible-edits              'smart)
  ;; Refile
  (org-refile-use-outline-path            'file)
  ;; Targets complete directly with Ivy
  (org-outline-path-complete-in-steps     nil)
  ;; Allow refile to create parent tasks with confirmation
  (org-refile-allow-creating-parent-nodes 'confirm)
  ;; Reverse note order
  (org-reverse-note-order                 t)
  ;; Pomodoro timer
  ;; Check in with C-c C-x C-i (or I on heading)
  ;; Check out with C-c C-x C-o (or O on heading)
  (org-timer-default-timer                25)
  ;; I'm not sure I like this
  ;; (org-hide-emphasis-markers              t)
  :init
  ;; Most GTD setup is taken from https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html
  (let ((default-org-file  "~/.emacs.d/org-files/gtd/unsorted.org") ;; Unsorted items
        (project-org-file  "~/.emacs.d/org-files/gtd/projects.org") ;; Currently active projects
        (archive-org-file  "~/.emacs.d/org-files/gtd/archive.org") ;; Projects that are done
        (schedule-org-file "~/.emacs.d/org-files/gtd/schedule.org") ;; C-c C-s to schedule. C-c C-d to deadline
        (journal-org-file  "~/.emacs.d/org-files/journal.org"))
    (dolist (org-file (list default-org-file
                            project-org-file
                            archive-org-file
                            schedule-org-file
                            journal-org-file))
      (if (not (file-exists-p org-file))
          (write-region "" ; Start - What to write - handled with autoinsert
                        nil      ; End - Ignored when start is string
                        org-file ; Filename
                        t        ; Append
                        nil      ; Visit
                        nil      ; Lockname
                        'excl))) ; Mustbenew - error if already exists
    (setq org-capture-templates
          `(("j" "Journal"   entry (file+olp+datetree ,journal-org-file)
             "* %(format-time-string \"%R\") %?")
            ("e" "EOD" item (file+headline ,journal-org-file ,(format-time-string "EOD - %F"))
             "- %?")
            ("t" "Todo"      entry (file+headline ,default-org-file "Unsorted")
             "* TODO %?\nCREATED: %U\n"
             :empty-lines-after 1)
            ("m" "Meeting"   entry (file+headline ,default-org-file "Meetings")
             "* %? - %u :meeting:\n:ATTENDEES:\nS. Stoltze\n:END:\n"
             :empty-lines-after 1)
            ("n" "Next"      entry (file+headline ,default-org-file "Unsorted")
             "* NEXT %?\nCREATED: %U\n"
             :empty-lines-after 1)
            ("s" "Schedule"  entry (file+headline ,schedule-org-file "Schedule")
             "* %i%?\nCREATED: %U\nSCHEDULED: %^{Enter date}t"
             :empty-lines-after 1))
          org-default-notes-file journal-org-file
          org-agenda-files       (list default-org-file
                                       project-org-file
                                       schedule-org-file
                                       journal-org-file)
          org-archive-location   (concat archive-org-file "::datetree/* %s")
          ;; Possibly change levels here
          org-refile-targets     `((,project-org-file  :maxlevel . 3)
                                   (,schedule-org-file :level    . 1)
                                   (,archive-org-file  :maxlevel . 2)
                                   (,journal-org-file  :maxlevel . 3)))
    (set-register ?u (cons 'file default-org-file))
    (set-register ?a (cons 'file archive-org-file))
    (set-register ?p (cons 'file project-org-file))
    (set-register ?s (cons 'file schedule-org-file))
    (set-register ?j (cons 'file journal-org-file)))
  :config
  ;; Refile settings
  ;; Exclude DONE state tasks from refile targets
  (defun bh/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets."
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))
  (setq org-refile-target-verify-function 'bh/verify-refile-target)
  ;; Org babel evaluate
  ;; Make org mode allow eval of some langs
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((clojure    . t)
     (dot        . t)
     (lisp       . t)
     (emacs-lisp . t)
     (haskell    . t)
     (ocaml      . t)
     (python     . t)
     (R          . t)
     (ruby       . t)
     (latex      . t)
     (shell      . t)
     (sql        . t)
     ;; (stan       . t)
     (http       . t)))
  (setq org-confirm-babel-evaluate nil
        org-src-fontify-natively   t)
  (when (eq system-type 'gnu/linux)
    (setq org-babel-python-command "python3")))

;;;; Easy slides/presentations in org-mode docs
(use-package org-tree-slide
  :ensure t
  :defer t
  ;; :hook ((org-tree-slide-mode . (lambda ()
  ;;                                 (setq org-tree-slide-slide-in-effect nil))))
  :bind (("C-c i" . org-tree-slide-mode))
  :custom
  (org-tree-slide-slide-in-effect nil))

(use-package moom
  :ensure t
  :defer t)

;;;; --- Avy ---
(use-package avy
  :ensure t
  :defer t
  :bind (("C-c s"   . avy-goto-char-timer)
         ;; This behaves as goto-line if a number is entered
         ("M-g g"   . avy-goto-line)
         ("M-g M-g" . avy-goto-line)
         ("C-c C-j" . avy-resume))
  :custom
  (avy-all-windows nil)
  :config
  (avy-setup-default))

;;;; --- wgrep ---
(use-package wgrep
  :ensure t
  :defer t)

(defun swiper-isearch-other-window (prefix)
  "Function to swiper-isearch in 'other-window'.
Use PREFIX to go backwards.
Stolen from https://karthinks.com/software/avy-can-do-anything/"
  (interactive "P")
  (unless (one-window-p)
    (save-excursion
      (let ((next (if prefix -1 1)))
        (other-window next)
        (swiper-isearch)
        (other-window (- next))))))

;;;; --- Counsel / Swiper / Ivy ---
;;;;; Counsel pulls in ivy and swiper
;;;;; Doing C-x C-f, C-M-j will create currently entered text as file-name
(use-package counsel
  :ensure t
  ;; Defer to save time when just opening a file
  :defer t
  :hook ((prog-mode . ivy-mode))
  ;; Always enabled, do not show in mode-line
  :diminish counsel-mode
  :diminish ivy-mode
  ;; Load counsel when we need it
  :bind (("M-x"     . counsel-M-x)
         ("C-x b"   . ivy-switch-buffer)
         ("C-x C-f" . counsel-find-file)
         ("C-s"     . swiper-isearch)
         ("C-M-s"   . swiper-isearch-other-window)
         ;; counsel-grep-or-swiper should be faster on large buffers
         ("C-r"     . counsel-grep-or-swiper)
         ;; Find recent files
         ("C-x C-r" . counsel-recentf)
         ;; Resume last ivy completion - rarely used
         ;; ("C-c C-r" . ivy-resume)
         ;; Help commands
         ("C-h a"   . counsel-apropos)
         ("C-h b"   . counsel-descbinds)
         ("C-h f"   . counsel-describe-function)
         ("C-h v"   . counsel-describe-variable)
         ;; Store a view for the current session
         ("C-c v"   . ivy-push-view)
         ;; Remove a stored view
         ("C-c V"   . ivy-pop-view)
         (:map swiper-map
               ("C-c s" . swiper-avy)))
  :custom
  ;; Allows selecting the prompt with C-p (same as C-M-j)
  (ivy-use-selectable-prompt    t)
  ;; Use ivy while in minibuffer to e.g. insert variable names
  ;; when doing counsel-set-variable
  (enable-recursive-minibuffers t)
  ;; Recentfs, views and bookmarks in ivy-switch-buffer
  (ivy-use-virtual-buffers      t)
  :config
  (ivy-mode 1)
  (counsel-mode 1)
  ;; With fuzzy matching, we do not need the initial ^ in the prompts
  (setq ivy-initial-inputs-alist '())
  ;; Show how deep the minibuffer goes
  (minibuffer-depth-indicate-mode 1)
  ;; Sort recentf by timestamp
  (add-to-list 'ivy-sort-functions-alist
               '(counsel-recentf . file-newer-than-file-p))
  ;; Allow "M-x lis-pac" to match "M-x list-packages"
  (setq ivy-re-builders-alist '((swiper                . ivy--regex-plus)
                                (swiper-isearch        . ivy--regex-plus)
                                (counsel-rg            . ivy--regex-plus)
                                (counsel-projectile-rg . ivy--regex-plus)
                                (counsel-git-grep      . ivy--regex-plus)
                                (t                     . ivy--regex-fuzzy))
        ivy-flx-limit         5000
        ;; Special views in ivy-switch-buffer
        ;; Use {} to easily find views in C-x b
        ivy-views             (append `(("init.el {}"
                                         (file "~/.emacs.d/init.el"))
                                        ("gtd {}"
                                         (horz
                                          (file "~/.emacs.d/org-files/gtd/unsorted.org")
                                          (vert (file "~/.emacs.d/org-files/gtd/projects.org")
                                                (file "~/.emacs.d/org-files/gtd/archive.org"))))))))

;; Better fuzzy-matching
(use-package flx
  :ensure t
  :after ivy)

;; Add info to ivy-buffers like 'M-x' or 'C-x b'
(use-package ivy-rich
  :ensure t
  :after ivy
  :custom
  (ivy-rich-path-style 'abbrev)
  :config
  (ivy-rich-mode 1))

(use-package ivy-posframe
  :ensure t
  :after ivy
  :diminish ivy-posframe-mode
  :custom
  (ivy-posframe-border-width 1)
  (swiper-action-recenter t)
  (ivy-posframe-display-functions-alist '((swiper-isearch . ivy-posframe-display-at-window-bottom-left)
                                          (swiper         . ivy-posframe-display-at-window-bottom-left)
                                          (t              . ivy-posframe-display-at-point)))
  :custom-face
  (ivy-posframe-border ((t (:background "goldenrod"))))
  :config
  (ivy-posframe-mode 1))

(use-package xref
  :ensure t)
(use-package ivy-xref
  :ensure t
  :after ivy)

;;;; --- Magit ---
(use-package sqlite3
  :ensure t
  :defer t)

(use-package magit
  :ensure t
  :defer t
  :bind (("C-x g" . magit-status)       ; Display the main magit popup
         ("C-c g" . magit-file-dispatch)) ; Run blame, etc. on a file
  :custom
  (magit-completing-read-function 'ivy-completing-read)
  ;; Remove the startup message about turning on auto-revert
  (magit-no-message (list "Turning on magit-auto-revert-mode..."))
  ;; Command prefix for merge conflicts. Alternatively use 'e' for ediff
  (smerge-command-prefix "\C-cv")
  :config
  (set-face-background 'hl-line
                       ;; Magit background color
                       (face-background 'magit-section-highlight)))

(use-package forge
  :ensure t
  :after magit)

(use-package git-timemachine
  :ensure t
  :defer t)

(use-package git-link
  :ensure t
  :defer t)

(use-package god-mode
  :ensure t
  :defer t
  :hook ((god-mode-enabled  . sstoltze/god-mode-update-theme)
         (god-mode-disabled . sstoltze/god-mode-update-theme))
  :bind
  (("<escape>" . god-mode-all)
   ("C-x C-1" . delete-other-windows)
   ("C-x C-2" . split-window-below)
   ("C-x C-3" . split-window-right)
   ("C-x C-0" . delete-window)
   (:map god-local-mode-map
         ("i" . god-mode-all)
         ("." . repeat)))
  :init
  (defun sstoltze/god-mode-update-theme ()
    "Toggle cursor type in god-mode."
    (cond (god-local-mode (progn (setq cursor-type 'hbar)
                                 (set-face-background 'mode-line "dark goldenrod")))
          (t              (progn (setq cursor-type 't)
                                 (set-face-background 'mode-line "gray70"))))))

;;;; --- lsp ---
(use-package lsp-mode
  :ensure t
  :hook ((rust-mode       . lsp-deferred)
         (typescript-mode . lsp-deferred)
         ;; Make sure elixir-ls version (of elixir) matches installed/running elixir version
         (elixir-mode     . lsp-deferred)
         (lsp-mode        . yas-minor-mode)
         (lsp-mode        . projectile-mode))
  :bind ((:map lsp-mode-map
               ("M-+"     . lsp-find-references)
               ("M-."     . lsp-find-definition)
               ("C-c l s" . lsp)))
  :custom
  (lsp-keymap-prefix "C-c l")
  ;; (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  ;; Show error diagnostics in the modeline
  (lsp-modeline-diagnostics-enable t)
  (lsp-log-max 10000)
  ;; Recommended for lsp as the replies can get rather large and slow things down - 1 mb
  (read-process-output-max (* 1024 1024))
  (lsp-file-watch-threshold 2000))

;; Trying some things out to speed up LSP/emacs
(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\deps\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\priv/static\\'"))

;; Flashy, maybe remove
(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :hook ((lsp-mode . lsp-ui-mode))
  :bind ((:map lsp-mode-map
               ("M-j"     . lsp-ui-imenu)
               ("C-c l d" . lsp-ui-doc-mode)
               ("C-c l f" . lsp-ui-doc-focus-frame)
               ("C-c l !" . lsp-ui-flycheck-list))
         (:map lsp-ui-imenu-mode-map
               ("C-j" . lsp-ui-imenu--view)))
  :custom
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-alignment 'window)
  (lsp-ui-sideline-show-code-actions t)
  ;; (lsp-ui-peek-always-show t)
  ;; (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil)
  (lsp-ui-doc-show-with-cursor t))

(use-package lsp-ivy
  :ensure t
  :after lsp-mode)

;;;; --- Multiple cursors ---
(use-package multiple-cursors
  :ensure t
  :defer t
  :bind
  (("C-c m t"   . mc/mark-all-like-this)
   ("C-c m m"   . mc/mark-all-like-this-dwim)
   ("C-c m l"   . mc/edit-lines)
   ("C-c m e"   . mc/edit-ends-of-lines)
   ("C-c m a"   . mc/edit-beginnings-of-lines)
   ("C-c m n"   . mc/mark-next-like-this)
   ("C-c m p"   . mc/mark-previous-like-this)
   ("C-c m s"   . mc/mark-sgml-tag-pair)
   ("C-c m d"   . mc/mark-all-like-this-in-defun)
   ("C-c m u n" . mc/unmark-next-like-this)
   ("C-c m u p" . mc/unmark-previous-like-this)
   ("C-c m i n" . mc/insert-numbers)
   ("C-c m i l" . mc/insert-letters)
   ("C-c m r s" . mc/sort-regions)
   ("C-c m r r" . mc/reverse-regions)))

;;;; --- Outline ---
;; For elisp:
;; - ;;; is a headline
;; - ;;;; is on the same level as a top-level sexp
(use-package outline
  ;; Always enabled, do not show in mode-line
  :diminish outline-minor-mode
  :hook ((prog-mode . outline-minor-mode))
  :bind ((:map outline-mode-prefix-map
               ("C-z" . outline-cycle)))
  :bind-keymap (("C-z" . outline-mode-prefix-map)))

(use-package outline-magic
  :ensure t
  :after outline)

(use-package symbol-overlay
  :ensure t
  :defer t
  :diminish symbol-overlay-mode
  :hook ((prog-mode . symbol-overlay-mode))
  :bind-keymap (("C-c o" . symbol-overlay-map)))

;;;; --- Semantic ---
(use-package semantic
  :ensure t
  :defer t
  :hook ((c-mode    . semantic-mode)
         (c++-mode  . semantic-mode)
         (java-mode . semantic-mode))
  :config
  (add-to-list 'semantic-default-submodes
               'global-semanticdb-minor-mode)
  (add-to-list 'semantic-default-submodes
               'global-semantic-idle-local-symbol-highlight-mode)
  (add-to-list 'semantic-default-submodes
               'global-semantic-idle-scheduler-mode)
  (add-to-list 'semantic-default-submodes
               'global-semantic-idle-completions-mode)
  (add-to-list 'semantic-default-submodes
               'global-semantic-idle-summary-mode))

(use-package semantic/ia
  :after semantic)

(use-package semantic/wisent
  :after semantic)

;;;; --- Projectile ---
(defun sstoltze/counsel-projectile-rg-no-ignore (rg-options)
  "Run rg with --no-ignore, or --no-ignore --hidden if RG-OPTIONS is set."
  (interactive
   (list (if (consp current-prefix-arg)
             "-uu"
           "-u")))
  (counsel-projectile-rg rg-options))

(defun sstoltze/projectile-file-relative-name (line-number)
  "Return the current buffer file name, relative to the project root.
If LINE-NUMBER is given, append the line at point to the file name."
  (format "%s%s"
          (file-relative-name (buffer-file-name) (projectile-project-root))
          line-number))

(defun sstoltze/projectile-yank-relative-name (line-number)
  "Yank the current buffer file name, relative to the project root.
If prefix argument LINE-NUMBER is given, append the line at point to
the file name."
  (interactive (list (if (consp current-prefix-arg)
                         (format ":%d" (line-number-at-pos nil t))
                       "")))
  (kill-new (sstoltze/projectile-file-relative-name line-number)))

(defun sstoltze/projectile-run-mix-test (test)
  "Run mix test in the project.

Prefix argument TEST specifies which test to run.
No prefix to run test at point, C-u to run file, C-u C-u to run all tests."
  (interactive (list (cond ((and (consp current-prefix-arg) (>= (car current-prefix-arg) 16))
                            "")
                           ((consp current-prefix-arg) (sstoltze/projectile-file-relative-name ""))
                           (t (sstoltze/projectile-file-relative-name (format ":%d" (line-number-at-pos nil t)))))))
  (let ((test-command (format "mix test --no-color %s" test)))
    (projectile-run-async-shell-command-in-root test-command "*Mix test*")))

(use-package projectile
  :ensure t
  :defer t
  :bind-keymap (("C-c p" . projectile-command-map))
  :bind ((:map projectile-command-map
               ("s i" . #'sstoltze/counsel-projectile-rg-no-ignore)
               ("y"   . #'sstoltze/projectile-yank-relative-name)))
  :custom
  (projectile-completion-system 'ivy)
  (projectile-use-git-grep      t)
  :config
  (when (eq system-type 'windows-nt)
    ;; Seems to be necessary for windows
    (setq projectile-git-submodule-command nil
          projectile-indexing-method       'alien)))

(use-package counsel-projectile
  :ensure t
  :after (:all counsel projectile)
  :init
  (counsel-projectile-mode 1))

;;;; --- Lisp ---
(use-package slime
  :ensure t
  :defer t
  :bind ((:map slime-repl-mode-map
               ("M-s" . nil)))
  :custom
  (inferior-lisp-program "sbcl --dynamic-space-size 2560")
  (slime-default-lisp "sbcl")
  (slime-contribs '(slime-fancy))
  :config
  (when (eq system-type 'cygwin)
    (defun cyg-slime-to-lisp-translation (filename)
      (replace-regexp-in-string "\n" ""
                                (shell-command-to-string
                                 (format "cygpath.exe --windows %s" filename))))
    (defun cyg-slime-from-lisp-translation (filename)
      (replace-regexp-in-string "\n" "" (shell-command-to-string
                                         (format "cygpath.exe --unix %s" filename))))
    (setq slime-to-lisp-filename-function   #'cyg-slime-to-lisp-translation
          slime-from-lisp-filename-function #'cyg-slime-from-lisp-translation)))

;;;; --- LaTeX ---
(use-package tex
  :ensure auctex
  :defer t
  :hook ((LaTeX-mode . turn-on-auto-fill)
         (LaTeX-mode . TeX-source-correlate-mode))
  :custom
  (TeX-source-correlate-start-server t)
  (TeX-view-program-list '(("Evince" "evince --page-index=%(outpage) %o")))
  (TeX-view-program-selection
   '(((output-dvi style-pstricks) "dvips and gv")
     (output-dvi "xdvi")
     (output-pdf "Evince")
     (output-html "xdg-open")))
  ;; Not sure if this belongs here
  (doc-view-continuous t))

;;;; --- Text-mode ---
;; visual-line-mode only pretends to insert linebreaks
(remove-hook 'text-mode-hook
             'turn-on-auto-fill)
(add-hook    'text-mode-hook
             'turn-on-visual-line-mode)

;;;; --- Ediff ---
;; Ignore whitespace, no popup-window and split horizontally
(use-package ediff
  :defer t
  :hook ((ediff-before-setup . (lambda ()
                                 (setq ediff-diff-options "-w"
                                       ediff-window-setup-function 'ediff-setup-windows-plain
                                       ediff-split-window-function 'split-window-horizontally))))
  :custom-face
  (ediff-odd-diff-B ((t (:background "Grey60")))))

;;;; --- HTML/CSS ---
(use-package restclient
  :ensure t
  :defer t)

;; Allows running restclient-queries in org-babel blocks
(use-package ob-http
  :ensure t
  :defer t)

;;;; --- CSV ---
(use-package csv-mode
  :ensure t
  :defer t
  :custom
  (csv-separators (list ";" "	")))

;;;; --- Haskell ---
(defun haskell-window-setup ()
  "Setup windows for Haskell development."
  (interactive)
  (split-window-right)
  (other-window 1)
  (split-window-below)
  (haskell-interactive-switch)
  (enlarge-window -15)
  (other-window 1))

(use-package haskell-mode
  :ensure t
  :defer t
  :hook ((haskell-mode . subword-mode)
         (haskell-mode . haskell-indentation-mode)
         (haskell-mode . haskell-doc-mode)
         (haskell-mode . interactive-haskell-mode))
  :custom
  (haskell-compile-cabal-build-command         "stack build")
  (haskell-process-auto-import-loaded-modules  t)
  (haskell-process-log                         t)
  (haskell-process-suggest-add-package         t)
  (haskell-process-suggest-remove-import-lines t)
  (haskell-stylish-on-save                     t)
  ;; 'stack install hasktags'
  (haskell-tags-on-save                        (if (executable-find "hasktags")
                                                   t
                                                 nil))
  :bind ((:map haskell-mode-map
               ("C-c C-c" . haskell-compile)
               ("M-."     . haskell-mode-jump-to-def)
               ("C-c :"   . haskell-hoogle)
               ("C-c C-w" . haskell-window-setup))
         (:map haskell-cabal-mode-map
               ("C-c C-c" . haskell-compile))))

(use-package ormolu
  :ensure t
  :defer t
  :hook (haskell-mode . ormolu-format-on-save-mode)
  :bind
  (:map haskell-mode-map
        ("C-c <tab>" . ormolu-format-buffer)))

;;;; --- C/C++ ---
(defun common-c-hook ()
  "Hook for C/C++."
  (c-set-style "bsd")
  (setq-default c-basic-offset 2)
  (setq tab-width 2)
  (use-package semantic/bovine/gcc
    :after semantic))

(defun my-cpp-hook ()
  "C++ specific packages."
  (use-package modern-cpp-font-lock
    :ensure t))

(add-hook 'c-mode-hook
          'common-c-hook)
(add-hook 'c++-mode-hook
          (lambda ()
            (common-c-hook)
            (my-cpp-hook)))

;;;; --- Java ---
(add-hook 'java-mode-hook
          'subword-mode)

;;;; --- Eww ---
(use-package eww
  :ensure t
  :defer t
  :bind (("C-c w" . eww)))

(use-package browse-url
  :after eww
  :custom
  (browse-url-handlers '((".*youtube.*"           . browse-url-default-browser)
                         (".*github.*"            . browse-url-default-browser)
                         (".*docs.racket-lang.*"  . browse-url-default-browser)
                         ;; ("."                     . eww-browse-url)
                         ("."                     . browse-url-default-browser))))

(use-package eww-lnum
  :ensure t
  :after eww
  :bind ((:map eww-mode-map
               ("f" . eww-lnum-follow)
               ("F" . eww-lnum-universal))))

;;;; --- Fish ---
(use-package fish-mode
  :ensure t
  :defer t)

;;;; --- yaml ---
(use-package yaml-mode
  :ensure t
  :defer t
  :mode "\\.yml\\.tpl")

;;;; --- typescript ---
(use-package typescript-mode
  :ensure t
  :defer t
  :mode "\\.tsx")

(use-package tide
  :ensure t
  :defer t
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (typescript-mode . (lambda ()
                              (add-hook 'before-save-hook 'tide-format-before-save 0 t)))))

;;;; --- ESS - Emacs Speaks Statistics ---
(use-package ess
  :ensure t
  :defer t)

;;;; --- Stan ---
(use-package stan-mode
  :ensure t
  :defer t)

(use-package stan-snippets
  :ensure t
  :after stan-mode)

;;;; --- Python ---
(use-package pyenv-mode
  :ensure t
  :defer t
  :init
  (add-to-list 'exec-path "~/.pyenv/bin")
  (add-to-list 'exec-path "~/.pyenv/shims"))

;; python -m pip install --upgrade jedi rope black flake8 yapf autopep8 elpy
(use-package elpy
  :ensure t
  :pin elpy
  :defer t
  :hook ((python-mode . elpy-mode)
         (python-mode . (lambda ()
                          (prettify-symbols-mode -1)))
         (inferior-python-mode . (lambda ()
                                   (python-shell-switch-to-shell))))
  :init
  ;; Silence warning when guessing indent, default is 4 spaces
  (with-eval-after-load 'python
    (defun python-shell-completion-native-try ()
      "Return non-nil if can trigger native completion."
      (let ((python-shell-completion-native-enable t)
            (python-shell-completion-native-output-timeout
             python-shell-completion-native-try-output-timeout))
        (python-shell-completion-native-get-completions
         (get-buffer-process (current-buffer))
         nil "_"))))
  :config
  (setq elpy-modules (delete 'elpy-module-flymake elpy-modules))
  (elpy-enable)
  ;; Enable pyvenv, which manages Python virtual environments
  (pyvenv-mode 1)
  (defun my-restart-python-console ()
    "Restart python console before evaluate buffer or region to avoid various uncanny conflicts, like not reloding modules even when they are changed"
    (interactive)
    (kill-process "Python")
    (sleep-for 0.15)
    (kill-buffer "*Python*")
    (elpy-shell-send-region-or-buffer))
  (global-set-key (kbd "C-c C-x C-c") 'my-restart-python-console))

;;;; --- Ocaml ---
(defvar tuareg-load-path (env->load-path "TUAREG_SITE_LISP"))
(use-package tuareg
  :ensure t
  :defer t
  :load-path tuareg-load-path
  :hook ((tuareg-mode . (lambda ()
                          (prettify-symbols-mode -1))))
  :bind ((:map tuareg-mode-map
               ;; Normally bound to caml-help
               ("C-c C-h" . nil)))
  :config
  ;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
  (when (file-exists-p "~/.emacs.d/opam-user-setup.el")
    (require 'opam-user-setup "~/.emacs.d/opam-user-setup.el"))
  ;; ## end of OPAM user-setup addition for emacs / base ## keep this line
  (with-eval-after-load 'smartparens
    (sp-with-modes '(tuareg-mode)
      (sp-local-pair "struct" "end"
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
      (sp-local-pair "sig" "end"
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
      (sp-local-pair "if" "then"
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("| " "SPC")))
      (sp-local-pair "while" "done"
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("| " "SPC")))
      (sp-local-pair "for" "done"
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("| " "SPC")))
      (sp-local-pair "begin" "end"
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("||\n[i]" "RET") ("| " "SPC")))
      (sp-local-pair "object" "end"
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("| " "SPC")))
      (sp-local-pair "match" "with"
                     :actions '(insert)
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("| " "SPC")))
      (sp-local-pair "try" "with"
                     :actions '(insert)
                     :unless '(sp-in-comment-p sp-in-string-p)
                     :post-handlers '(("| " "SPC"))))))

(defvar merlin-load-path (env->load-path "MERLIN_SITE_LISP"))
(use-package merlin
  :ensure t
  :after tuareg
  :load-path merlin-load-path
  :hook ((tuareg-mode . merlin-mode))
  :bind ((:map merlin-mode-map
               ("M-." . merlin-locate)
               ("M-," . merlin-pop-stack))))

(use-package merlin-eldoc
  :ensure t
  :after merlin
  :load-path merlin-load-path
  :hook ((reason-mode tuareg-mode caml-mode) . merlin-eldoc-setup)
  :custom
  ;; Use multiple lines when necessary
  (eldoc-echo-area-use-multiline-p t)
  (merlin-eldoc-max-lines 8)
  ;; Don't highlight occurences
  (merlin-eldoc-occurrences nil))

(defvar utop-load-path (env->load-path "UTOP_SITE_LISP"))
(use-package utop
  :ensure t
  :load-path utop-load-path
  :after merlin
  :hook ((utop-mode . smartparens-mode)
         (utop-mode . merlin-mode))
  :bind ((:map tuareg-mode-map
               ("C-c C-z" . utop))
         (:map merlin-mode-map
               ("C-c C-l" . utop-eval-buffer)
               ("C-c C-r" . utop-eval-region))
         (:map utop-mode-map
               ("M-."      . merlin-locate)
               ("M-,"      . merlin-pop-stack)
               ("C-<up>"   . utop-history-goto-prev)
               ("C-<down>" . utop-history-goto-next)
               ("C-c C-q"  . utop-exit)
               ("<tab>"    . complete-symbol))
         (:map utop-minor-mode-map
               ("C-x C-r" . nil)
               ("C-c C-k" . nil)
               ("C-c C-q" . utop-exit))))

(use-package flycheck-ocaml
  :ensure t
  :after merlin
  :config
  (flycheck-ocaml-setup))

;;;; --- Erlang / Elixir
(use-package erlang
  :ensure t
  :defer t)

(use-package elixir-mode
  :ensure t
  :defer t
  :hook (
         ;; (elixir-mode . (lambda ()
         ;;                  (add-hook 'before-save-hook 'elixir-format 0 t)))
         (elixir-mode . (lambda ()
                          (add-hook 'before-save-hook 'lsp-format-buffer 0 t)))
         (elixir-format . (lambda ()
                            (if (projectile-project-p)
                                (setq elixir-format-arguments
                                      (list "--dot-formatter"
                                            (concat (locate-dominating-file buffer-file-name ".formatter.exs") ".formatter.exs")))
                              (setq elixir-format-arguments nil)))))
  :bind ((:map elixir-mode-map ("C-c t" . #'sstoltze/projectile-run-mix-test)))
  :init
  (setq lsp-elixir-server-command '("elixir-ls"))
  :custom
  (lsp-elixir-suggest-specs nil)
  (lsp-credo-version "0.1.3"))

;; (lsp-install-server), and possibly chmod +x it afterwards for some reason
(add-to-list 'exec-path "~/.emacs.d/.cache/lsp/credo-language-server")

(use-package inf-elixir
  :ensure t
  :after elixir-mode
  :bind ((:map elixir-mode-map
               ("C-c C-z" . #'inf-elixir-project))))

;;;; --- Clojure ---
(use-package clojure-mode
  :ensure t
  :defer t
  :hook ((clojure-mode . subword-mode)
         (clojure-mode . sstoltze/prettify-clojure))
  :config
  ;; To use clj-kondo, add a .clj-kondo directory in the project and run
  ;; clj-kondo --lint (string join " " (lein classpath))
  (when (executable-find "clj-kondo")
    (use-package flycheck-clj-kondo
      :ensure t)))

;; https://docs.cider.mx/cider/usage/misc_features.html
(use-package cider
  :ensure t
  :after clojure-mode
  :hook ((clojure-mode    . cider-mode)
         (cider-repl-mode . sstoltze/prettify-symbols-setup)
         (cider-repl-mode . sstoltze/prettify-clojure))
  :bind ((:map cider-mode-map
               ("C-c <tab>" . cider-format-buffer))
         (:map cider-repl-mode-map
               ("M-s" . sp-splice-sexp)))
  :custom
  ;; (nrepl-log-messages t)
  (cider-use-overlays 'both)
  ;; (cider-repl-result-prefix ";; => ")
  (cider-repl-require-ns-on-set t))

(use-package clj-refactor
  :ensure t
  :defer t)

;;;; --- Racket ---
(use-package racket-mode
  :ensure t
  :defer t
  :hook ((racket-mode . racket-xp-mode))
  :bind ((:map racket-mode-map
               ("C-c SPC" . racket-align))))

(use-package scribble-mode
  :ensure t
  :defer t)

;;;; Rust
(use-package rust-mode
  :ensure t
  :defer t
  ;; rustup component add rls
  :bind ((:map rust-mode-map
               ("C-c <tab>" . rust-format-buffer)
               ("C-c C-b"   . rust-run)
               ("C-c d"     . rust-dbg-wrap-or-unwrap)))
  :custom
  (rust-format-on-save t)
  (rust-format-show-buffer nil)
  (lsp-rust-analyzer-call-info-full nil)
  (lsp-rust-analyzer-cargo-load-out-dirs-from-check t)
  (lsp-rust-analyzer-proc-macro-enable t)
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  :init
  (when (eq system-type 'gnu/linux)
    (setenv "CARGO_HOME"  (concat (getenv "HOME") "/.local"))
    (setenv "RUSTUP_HOME" (concat (getenv "HOME") "/.local/rustup")))
  (with-eval-after-load "lsp-rust"
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-tramp-connection
                       (executable-find (car lsp-rust-analyzer-server-command)))
      :major-modes '(rust-mode)
      :priority (if (eq lsp-rust-server 'rust-analyzer) 1 -1)
      :remote? t
      :initialization-options 'lsp-rust-analyzer--make-init-options
      :notification-handlers (ht<-alist lsp-rust-notification-handlers)
      :action-handlers (ht<-alist lsp-rust-action-handlers)
      :library-folders-fn (lambda (_workspace) lsp-rust-library-directories)
      :ignore-messages nil
      :server-id 'rust-analyzer-remote
      :environment-fn (lambda () (list (cons "CARGO_HOME"  (concat (getenv "HOME") "/.cargo"))
                                       (cons "RUSTUP_HOME" (concat (getenv "HOME") "/.cargo/rustup"))))
      ))))

;; Cargo
(use-package cargo
  :ensure t
  :defer t
  :hook ((rust-mode . cargo-minor-mode)))

;; Racer
;; rustup component add rust-src
;; Or: clone git@github.com:rust-lang/rust.git to
;; ~/.local/rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src
(use-package racer
  :ensure t
  :defer t
  :hook ((rust-mode  . racer-mode)
         (racer-mode . eldoc-mode))
  :bind ((:map rust-mode-map
               ("C-c C-d" . racer-describe)))
  :config
  (setq racer-rust-src-path
        (let* ((sysroot (string-trim
                         (shell-command-to-string "rustc --print sysroot")))
               (lib-path (concat sysroot "/lib/rustlib/src/rust/library"))
               (src-path (concat sysroot "/lib/rustlib/src/rust/src")))
          (or (when (file-exists-p lib-path) lib-path)
              (when (file-exists-p src-path) src-path)))))

(use-package flycheck-rust
  :ensure t
  :defer t
  :hook ((rust-mode . flycheck-rust-setup)))

;;;; --- EPA ---
(defun sstoltze/setup-epa ()
  "Quick setup for EPA."
  ;; These allow entry of passphrase in emacs
  (use-package pinentry
    :ensure t)
  (use-package epa
    :custom
    (epa-pinentry-mode 'loopback)
    :config
    (pinentry-start)))

;;;; --- System specific setup ---
(when (executable-find "fish")
  (use-package fish-completion
    :ensure t
    :defer t
    :config
    (fish-completion-mode 1)))

;; --- Lua ---
;; For editing awesome/rc.lua
(use-package lua-mode
  :ensure t
  :defer t)

;; --- Open Street Map ---
(use-package osm
  :ensure t
  :defer t)

(cond
 ;; --- Windows specific ---
 ((eq system-type 'windows-nt)
  ;; Default directory
  (let ((desktop-dir (concat (getenv "USERPROFILE")
                             "/Desktop/")))
    (setq default-directory desktop-dir)
    (set-register ?d (cons 'file desktop-dir)))
  ;; --- Tramp - Windows ---
  ;; C-x C-f /plink:<user>@host: ENTER
  (let* ((plink-folder "C:\\Program Files (x86)\\PuTTY")
         (plink-file   (concat plink-folder
                               "\\plink.exe")))
    (when (file-exists-p plink-file)
      (setq tramp-default-method "plink")
      (when (not (executable-find "plink.exe"))
        (setenv "PATH" (concat plink-folder
                               ";"
                               (getenv "PATH")))
        (add-to-list 'exec-path
                     plink-file)))))

 ;; --- Linux specific ---
 ((eq system-type 'gnu/linux)
  ;; --- Tramp - Linux ---
  (setq tramp-default-method "ssh")

  ;; --- Mu4e ---
  (when (file-directory-p "/usr/share/emacs/site-lisp/mu4e")
    (use-package mu4e
      :defer t
      :load-path "/usr/share/emacs/site-lisp/mu/mu4e"
      :bind (("C-c q" . mu4e)
             (:map mu4e-view-mode-map
                   ("G" . (lambda ()
                            (interactive)
                            (let ((browse-url-default-function 'browse-url-default-browser))
                              (mu4e-view-go-to-url))))))
      :custom
      (mu4e-maildir                      "~/.local/.mail")
      ;; gpg-agent is set to use pinentry-qt for a dialog box
      (mu4e-get-mail-command             "mbsync -a")
      ;; Show images in mails
      (mu4e-view-show-images             t)
      ;; Don't keep message buffers around
      (message-kill-buffer-on-exit       t)
      ;; Don't ask for a 'context' upon opening mu4e
      (mu4e-context-policy               'pick-first)
      ;; Don't ask to quit.
      (mu4e-confirm-quit                 nil)
      ;; Fix "Duplicate UID" when moving messages
      (mu4e-change-filenames-when-moving t)
      (mu4e-html2text-command            'mu4e-shr2text)
      ;; Complete using ivy
      (mu4e-completing-read-function     'ivy-completing-read)
      ;; Header view - format time and date
      (mu4e-headers-time-format          "%R")
      (mu4e-headers-date-format          "%F")
      ;; Common options for servers
      (message-send-mail-function        'smtpmail-send-it)
      (smtpmail-stream-type              'starttls)
      (mu4e-use-fancy-chars              t)
      ;; Speed up indexing a bit
      (mu4e-index-cleanup                nil) ;; don't do a full cleanup check
      (mu4e-index-lazy-check             t) ;; don't consider up-to-date dirs
      ;; The standard face is a bit bright in the modeline, look for other options
      :custom-face
      (mu4e-title-face ((t (:foreground "burlywood4"))))
      ;; (mu4e-unread-face ((t (:foreground "burlywood4"))))
      :init
      (sstoltze/setup-epa)
      :config
      ;; Set account-specific details here
      (setq mu4e-contexts (list
                           (make-mu4e-context
                            :name "gmail"
                            :match-func (lambda (msg)
                                          (when msg
                                            (string-prefix-p "/gmail" (mu4e-message-field msg :maildir))))
                            :vars '((user-mail-address            . "sstoltze@gmail.com")
                                    (mu4e-trash-folder            . "/gmail/[Gmail].Trash")
                                    (mu4e-refile-folder           . "/gmail/[Gmail].Archive")
                                    ;; Gmail handles sent messages for us
                                    (mu4e-sent-messages-behavior  . delete)
                                    (smtpmail-default-smtp-server . "smtp.gmail.com")
                                    (smtpmail-smtp-server         . "smtp.gmail.com")
                                    (smtpmail-smtp-service        . 587)))))
      ;; UNTRUE?
      ;; Authinfo - open in emacs and add lines for each context, e.g.
      ;; machine <smtp.foo.com> login <mail@address.com> password <secret> port <587>
      ;; (add-to-list 'auth-sources
      ;;              "~/.local/.mail/.gmail.gpg")
      ;; (add-to-list 'auth-sources
      ;;              "~/.local/.mail/.work.gpg")
      ;; Include a bookmark to open all of my inboxes
      (add-to-list 'mu4e-bookmarks
                   (make-mu4e-bookmark
                    :name "All Inboxes"
                    :query "maildir:/work/Inbox OR maildir:/gmail/Inbox"
                    :key ?i))
      (add-to-list 'mu4e-bookmarks
                   (make-mu4e-bookmark
                    :name "Gmail"
                    :query "maildir:/gmail/Inbox"
                    :key ?g)
                   t)
      (add-to-list 'mu4e-bookmarks
                   (make-mu4e-bookmark
                    :name "Work"
                    :query "maildir:/work/Inbox"
                    :key ?s)
                   t)
      ;; Headers to see which account a mail is stored in
      (add-to-list 'mu4e-header-info-custom
                   '(:account . (:name "Account"
                                       :shortname "Account"
                                       :help "The account/folder the mail was in."
                                       :function (lambda (msg)
                                                   (let ((path (or (mu4e-message-field msg :maildir)
                                                                   "")))
                                                     (if (string= path "")
                                                         "Mail file is not accessible"
                                                       (nth 1 (split-string path "/"))))))))
      ;; Setup headers
      (setq mu4e-headers-fields
            '((:account . 8)
              (:human-date . 12)
              (:flags . 6)
              (:from . 22)
              (:thread-subject)))
      ;; Use imagemagick for images, if available
      (when (fboundp 'imagemagick-register-types)
        (imagemagick-register-types)))
    (use-package mu4e-alert
      :ensure t
      :after mu4e
      :custom
      (mu4e-alert-interesting-mail-query
       (concat
        "flag:unread maildir:/work/Inbox"
        " OR "
        "flag:unread maildir:/Gmail/Inbox"))
      (mu4e-alert-email-notification-types '(count))
      :init
      (mu4e-alert-enable-mode-line-display)
      (defun gjstein-refresh-mu4e-alert-mode-line ()
        (interactive)
        (mu4e~proc-kill)
        (mu4e-alert-enable-mode-line-display))
      ;; Refresh every 10 minutes
      (run-with-timer 600 600 'gjstein-refresh-mu4e-alert-mode-line)))

  ;; --- SAGE ---
  (when (file-directory-p "/usr/lib/sagemath")
    (use-package sage
      :defer t
      :load-path "/usr/lib/sagemath/local/share/emacs"
      :custom
      (sage-command "/usr/lib/sagemath/sage"))))
 ((eq system-type 'darwin)
  (setq mac-command-modifier 'none)))

(when (executable-find "direnv")
  (use-package direnv
    :ensure t
    :config
    (direnv-mode)))

(use-package dockerfile-mode
  :ensure t)

(use-package terraform-mode
  :ensure t
  :defer t
  :hook ((terraform-mode . terraform-format-on-save-mode)))

;; (use-package tree-sitter
;;   :ensure t
;;   :defer t
;;   :custom
;;   (treesit-language-source-alist
;;    '((bash "https://github.com/tree-sitter/tree-sitter-bash")
;;      (cmake "https://github.com/uyha/tree-sitter-cmake")
;;      (css "https://github.com/tree-sitter/tree-sitter-css")
;;      (elisp "https://github.com/Wilfred/tree-sitter-elisp")
;;      (elixir "https://github.com/elixir-lang/tree-sitter-elixir")
;;      (go "https://github.com/tree-sitter/tree-sitter-go")
;;      (html "https://github.com/tree-sitter/tree-sitter-html")
;;      (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
;;      (json "https://github.com/tree-sitter/tree-sitter-json")
;;      (make "https://github.com/alemuller/tree-sitter-make")
;;      (markdown "https://github.com/ikatyang/tree-sitter-markdown")
;;      (python "https://github.com/tree-sitter/tree-sitter-python")
;;      (toml "https://github.com/tree-sitter/tree-sitter-toml")
;;      (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
;;      (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
;;      (yaml "https://github.com/ikatyang/tree-sitter-yaml"))))

;; Run M-x package-vc-install-from-checkout and provide the correct
;; path to the project directory.
(use-package related-files
  :bind (("C-c r" . related-files-find-related-file)))

(use-package document-sections
  :bind (("C-c d" . document-sections-find-section)))

(provide 'init)
;;; init.el ends here
