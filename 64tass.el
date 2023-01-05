
(defun 64tass-create-temp-file (file-name)
  "Writes the current buffer to a temporary file in location provided by built-in `make-temp-file'"
  (let ((tmp-file (expand-file-name (file-name-nondirectory file-name) (make-temp-file "_64tass" 'directory))))
    (write-region nil nil tmp-file nil 0)
    tmp-file))

(defun 64tass-target-name (&optional ext file-name)
  (or ext (setq ext "prg"))
  (concat (car (split-string (or file-name buffer-file-name) "\\.")) "." ext))

(defun 64tass-compile ()
  "Compile/Assemble current buffer using 64tass. Result will be stored in a file named after
   the buffer, with the file extension .prg"
  (interactive)
  (let ((result (call-process "64tass"
                              nil
                              "*64tass compilation log*"
                              nil
                              buffer-file-name
                              "-o"
                              (64tass-target-name))))
    (when (not (= 0 result))
      (switch-to-buffer-other-frame "*64tass compilation log*"))
    result))

(defun 64tass-execute (src-file produce-args)
  (let* ((include-dir (file-name-directory buffer-file-name))
         (out-file (concat (file-name-directory file-name) (file-name-base src-file) ".out")))
    (apply 'call-process (append '("64tass" nil nil nil)
                                 (funcall produce-args src-file include-dir out-file)))
    out-file))

(defun 64tass-export-labels (&optional file-name)
  "Exports all label symbols using the 64tass binary, passing the
location/directory as include path"
  (interactive)
  (64tass-execute (or file-name buffer-file-name)
                  (lambda (src-file include-dir out-file) (list "--no-output"
                                                                src-file
                                                                "-I" include-dir
                                                                "-l" out-file))))

(defun 64tass-export-list (&optional file-name)
  "Exports list into file"
  (interactive)
  (64tass-execute (or file-name buffer-file-name)
                  (lambda (src-file include-dir out-file) (list "--no-output"
                                                                src-file
                                                                "-I" include-dir
                                                                "-L" out-file
                                                                "--line-numbers"))))

(provide '64tass)
