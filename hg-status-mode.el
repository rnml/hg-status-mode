
(define-derived-mode hg-status-mode tabulated-list-mode "hg-status"
  "Minimalistic major mode for viewing and editing hg status"
  (setq tabulated-list-format [("Action" 6 nil) ;; pending action
                               ("B"      1 nil) ;; status
                               ("A"      1 nil) ;; future status
                               ("File"   0 t)])
  (setq tabulated-list-sort-key (cons "File" nil))
  (tabulated-list-init-header))

(defun hg-status-forward-entry (n)
  (when (save-excursion (forward-line n) (tabulated-list-get-id))
    (forward-line n)))

(defun hg-status-next-entry (&optional n)
  (interactive "P")
  (hg-status-forward-entry (or n 1)))

(defun hg-status-prev-entry (&optional n)
  (interactive "P")
  (hg-status-forward-entry (- (or n 1))))

(defun hg-status-set-action (action &optional allowed-statuses)
  (let* ((entry (tabulated-list-get-entry))
         (status (elt entry 1))
         (future-status
          (if allowed-statuses (cadr (assoc status allowed-statuses)) "")))
    (when future-status
      (aset entry 0 action)
      (aset entry 2 future-status)
      (tabulated-list-print t)
      (hg-status-next-entry))))

(defun hg-status-unmark ()
  (interactive)
  (let* ((entry (tabulated-list-get-entry)))
    (aset entry 0 "")
    (aset entry 2 "")
    (tabulated-list-print t)
    (hg-status-next-entry)))

(dolist (z
         '(("add"    (("?" "A") ("I" "A")))
           ("commit" (("A" "C") ("M" "C") ("R" "D")))
           ("delete" (("A" "!") ("?" "D") ("M" "!")))
           ("forget" (("A" "?") ("C" "R") ("M" "R") ("!" "R")))
           ("ignore" (("?" "I")))
           ("revert" (("A" "?") ("!" "C") ("M" "C") ("R" "C"))))
         )
  (let* ((action (car z))
         (alist (cadr z))
         (fn-name (intern (concat "hg-status-mark-" action))))
    (eval
     `(defun ,fn-name ()
        (interactive)
        (hg-status-set-action ,action ',alist)))))

(defun hg-status-goto-file ()
  (interactive)
  (find-file (concat default-directory (tabulated-list-get-id))))

(defun hg-status-show-diff ()
  (interactive)
  (async-shell-command (format "hg pdiff %s" (tabulated-list-get-id))))

(defun my-concat-sep (sep sequences)
  (mapconcat 'identity sequences sep))

(defun hg-status-commit-phase1 (cwd files)
  (let* ((buf (get-buffer-create "*commit-message*")))
    (switch-to-buffer buf)
    (erase-buffer)
    (make-local-variable   'cwd-to-commit) (setq   cwd-to-commit cwd)
    (make-local-variable 'files-to-commit) (setq files-to-commit files)
    (defun hg-status-commit-phase2 ()
      (interactive)
      (let* ((temp-file (make-temp-file "commit-message.")))
        (write-region (point-min) (point-max) temp-file)
        (shell-command
         (format "hg commit --cwd %s --logfile %s %s"
                 cwd-to-commit
                 temp-file
                 (my-concat-sep " " files-to-commit)))
        (delete-file temp-file)
        (kill-buffer (current-buffer))
        (hg-status)))
    (local-set-key (kbd "C-c C-c") 'hg-status-commit-phase2)))

(defun hg-status-ignore (cwd files)
  "find enclosing .hgignore and add file to it"
  (let* ((.hg (locate-dominating-file cwd ".hg")))
    (with-temp-buffer 
      (dolist (file files) (insert file "\n"))
      (append-to-file (point-min) (point-max) (concat .hg ".hgignore")))))

(defun hg-status-doit ()
  (interactive)
  (let* ((entries tabulated-list-entries)
         (commits-made nil))
    (dolist (action '(("add"    . "hg add")
                      ("delete" . "/bin/rm")
                      ("forget" . "hg forget")
                      ("revert" . "hg revert")
                      ("ignore" . hg-status-ignore)
                      ("commit" . hg-status-commit-phase1)))
      (let* ((files (List.filter-map
                     (lambda (e)
                       (let* ((e (cadr e)))
                         (if (equal (car action) (elt e 0)) (elt e 3) nil)))
                     entries)))
        (when files
          (setq commits-made (or commits-made (equal (car action) "commit")))
          (let* ((action (cdr action)))
            (if (symbolp action)
                (funcall action default-directory files)
              (shell-command (my-concat-sep " " (cons action files))))))))
    (unless commits-made (hg-status))))

(dolist (binding
         '(;; refresh
           ("g" hg-status)
           ;; movement, exploration
           ("j" hg-status-next-entry)
           ("k" hg-status-prev-entry)
           ("s" hg-status-show-diff)
           ("f" hg-status-goto-file)
           ;; status marking/unmarking
           (" " hg-status-unmark)
           ("a" hg-status-mark-add)
           ("c" hg-status-mark-commit)
           ("d" hg-status-mark-delete)
           ("-" hg-status-mark-forget)
           ("i" hg-status-mark-ignore)
           ("r" hg-status-mark-revert)
           ;; commit to marked actions
           ("!" hg-status-doit)))
  (let* ((key (car binding))
         (def (cadr binding)))
    (define-key hg-status-mode-map key def)))

(defun hg-status ()
  (interactive)
  (let* ((dir default-directory))
    (switch-to-buffer "*hg status*")
    (cd dir)
    (hg-status-mode)
    (setq tabulated-list-entries
          (let* ((result nil))
            (with-temp-buffer
              (cd dir)
              (shell-command "hg status ."
                             (current-buffer) "*hg-status-error*")
              (goto-char (point-min))
              (while (not (equal (point) (point-max)))
                (let* ((beg-status (point)) 
                       (beg-file   (search-forward " "))
                       (end-status (- beg-file 1))
                       (end-file   (- (search-forward "\n") 1))
                       (status     (buffer-substring beg-status end-status))
                       (file       (buffer-substring beg-file   end-file)))
                  (add-to-list 'result
                               (list file (vector "" status "" file))))))
            result))
    (tabulated-list-print t)
    (hl-line-mode t)))

(when (featurep 'evil)
  (add-to-list 'evil-emacs-state-modes 'hg-status-mode)
  (define-key hg-status-mode-map evil-leader/leader
    (lookup-key evil-normal-state-map evil-leader/leader))
)
