;;; counsel-fd.el --- counsel interface for fd  -*- lexical-binding: t; -*-

;; Copyright © 2018, Rashawn Zhang, all rights reserved.

;; Version: 0.1.0
;; URL: https://github.com/yqrashawn/counsel-fd
;; Package-Requires: ((emacs "24.4"))
;; Author: Rashawn Zhang <namy.19@gmail.com>
;; Created: 27 August 2018
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;  counsel interface for fd

;;; Code:
(require 'counsel)

(defcustom counsel-fd-base-command "fd -L -I --hidden -a --color never "
  "FD command to invoke."
  :type 'string
  :group 'ivy)

(defun counsel-fd-function (string base-cmd)
  "Grep in the current directory for STRING using BASE-CMD.
If non-nil, append EXTRA-fd-ARGS to BASE-CMD."
  (or (counsel-more-chars)
      (let ((default-directory counsel-fd-current-dir)
            (regex (counsel-unquote-regex-parens
                    (setq ivy--old-re
                          (ivy--regex-plus string)))))
        (let* ((fd-cmd (concat (format base-cmd) (concat " " (s-wrap regex "'")))))
          (counsel--async-command fd-cmd)
          nil))))

;;;###autoload
(defun counsel-fd (&optional initial-input initial-directory fd-prompt fd-args)
  "Grep for file or directory in the current directory using fd.
INITIAL-INPUT can be given as the initial minibuffer input.
INITIAL-DIRECTORY, if non-nil, is used as the root directory for search.
FD-ARGS string, if non-nil, is appended to `counsel-fd-base-command'.
FD-PROMPT, if non-nil, is passed as `ivy-read' prompt argument."
  (interactive
   (list nil
         (when current-prefix-arg
           (read-directory-name (concat
                                 (car (split-string counsel-fd-base-command))
                                 " in directory: ")))))
  (counsel-require-program (car (split-string counsel-fd-base-command)))
  (ivy-set-prompt 'counsel-fd counsel-prompt-function)
  (setq counsel-fd-current-dir (or initial-directory default-directory))
  (ivy-read (or fd-prompt (car (split-string counsel-fd-base-command)))
            (lambda (string)
              (counsel-fd-function string (concat counsel-fd-base-command " " (or fd-args " "))))
            :initial-input initial-input
            :dynamic-collection t
            ;; :keymap counsel-ag-map
            :history #'counsel-git-grep-history
            :action #'counsel-find-file-action
            :unwind (lambda ()
                      (counsel-delete-process)
                      (swiper--cleanup))
            :caller 'counsel-fd))

(provide 'counsel-fd)
;;; counsel-fd.el ends here