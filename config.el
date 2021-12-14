;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; deft
(setq deft-directory "~/Dropbox/Org")
(setq deft-recursive t)
(setq deft-use-filter-string-for-filename t)
(setq deft-use-filename-as-title t)
(setq deft-org-mode-title-prefix t)

;; modeline
(use-package! doom-modeline
  :init
  (setq doom-modeline-github t
        doom-modeline-major-mode-icon t
        doom-modeline-modal-icon nil))

;; treemacs
(use-package! treemacs
  :config
  (setq +treemacs-git-mode 'extended))

(use-package jest
  :after (js2-mode)
  :hook (js2-mode . jest-minor-mode))

;; org
(after! org
  (setq org-directory "~/Dropbox/Org/")
  (setq org-agenda-files '("~/Dropbox/Org/planner/planner.org"
                           "~/Dropbox/Org/school/fall-21/fall-21.org"
                           "~/Dropbox/Org/school/fall-21/algorithms/algo.org"
                           "~/Dropbox/Org/school/fall-21/japanese/japanese.org"
                           "~/Dropbox/Org/school/fall-21/geology/geo.org"
                           "~/Dropbox/Org/school/fall-21/compilers/compilers.org"
                           "~/Dropbox/Org/school/career/career.org"
                           "~/Dropbox/Org/school/fall-21/clubs/acm/mentorship.org")))

(after! projectile
  (setq projectile-project-root-files-bottom-up (remove ".git" projectile-project-root-files-bottom-up)
        projectile-globally-ignored-file-suffixes '("json")))

;; (after! org-roam
;;   (setq org-roam-directory "~/Dropbox/Org/"))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Nathan Whyte"
      user-mail-address "nathanwhyte35@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)
;; (setq doom-theme 'doom-vibrant)

;; (setq doom-theme 'doom-city-lights)
(setq doom-theme 'doom-dracula)
;; (setq doom-theme 'doom-moonlight)
;; (setq doom-theme 'doom-monokai-pro)
;; (setq doom-theme 'doom-nord)
;; (setq doom-theme 'doom-sourcerer)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; (setq display-line-numbers-type t)
(setq display-line-numbers-type 'relative)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
