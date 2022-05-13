;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; icb-functions.el
;;;
;;; These are a bunch of one-off functions I wrote for EMACS. Put them in
;;; their own file to be distinct from .emacs, dot.emacs.el, etc.
;;;
;;; Currently:
;;;   sign-it             Insert a signature at the bottom of the buffer
;;;   mark-all            Marks the buffer top to bottom
;;;   insert-date         Inserts the current date.
;;;   add-PDF-YAML-header Inserts code into buffer to tell pandoc margins
;;;                       and paper size when converting Markdown to
;;;                       PDF.
;;;   tempword-buffer     Runs pandoc on a Markdown buffer, and writes to
;;;                       a designated Microsoft Word file.
;;;   xkcd-it             Sets the font to xkcd script
;;;   use-machine-font    Restores typeface to the font designated in the
;;;                       machine-font variable in dot.emacs.el
;;;   tempodt-buffer      Runs pandoc on a Markdown buffer, and writes to
;;;                       a designated OpenText file. 
;;;   jekyll-post-header  Adds YAML information fora post to my blog in
;;;                       the jekyll management system.
;;;   mdcopy              Copies buffer to clipboard, converting from markdown
;;;                       to RTF. 
;;;   md-to-html-copy     Copies buffer to clipboard, coverting from markdown
;;;                       to HTML.
;;;   md-to-plain-copy    Copies buffer to clipboard, coverting from markdown
;;;                       to plain text.
;;;   delete-buffer       Deletes a buffer
;;;   html-for-metafilter Convert Pandoced HTML to something better for pasting
;;;                       at MetaFilter.
;;;   save-as-word        Prompts for a file name, and runs pandoc on the
;;;                       text in the buffer to output to a Microsoft Word
;;;                       file of that name. Assumes buffer is in
;;;                       Markdown format.
;;;   md-region-to-html-copy Same as md-to-html-copy, but for a region.
;;; 
;;;
;;; Last updated 2021-12-11
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(print "ICB Functions update 2021-12-11")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Defining Variables
;;;
;;; I used to have this in dot.emacs.el, but I realize that's not really
;;; the place for it. I had to reconfigure that to have icb-functions.el
;;; load *before* the machine tests (so these could be set here, then reset
;;; by machine). 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar sigfile "~/.signature"
  "Location and name of the signature file on the machine. Default is ~/.signature")

(defvar tempword "~/tempword-markdown.docx"
  "Location and name of a temporary file to dump conversion of markdown to word. Default is ~/tempword-markdown.docx")

(defvar tempword-template nil
  "Location and name of a template to use for creating a temporary word file. Path must be absolute (no ~).")

(defvar tempodt "~/tempodt-markdown.odt"
  "Location and name of a temporary file to dump conversion of markdown to the OpenText format. Default is ~/tempodt-markdown.odt")

(defvar tempodt-template nil
  "Location and name of a template to use for creating a temporary odt file. Path must be absolute (no ~).")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This will insert a specified file at the end of a buffer. Assumes
;;; the sigfile variable is set in .emacs (or similar).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun sign-it ()
  "Insert a signature file at the end of the buffer."
  (interactive)
  (goto-char (point-max))
  (insert "\n")
  (insert-file sigfile)
  (goto-char (point-min))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mark the whole buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mark-all ()
  "Mark the buffer, from top to bottom."
  (interactive)
  (set-mark (point-min))
  (goto-char (point-max))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Insert the date
;;;
;;; From https://www.emacswiki.org/emacs/InsertDate
;;; I swapped the "not prefix" with first prefix. Just my default.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun insert-date (prefix)
    "Insert the current date. With prefix-argument, use ISO format. With
   two prefix arguments, write out the day and month name."
    (interactive "P")
    (let ((format (cond
                   ((not prefix) "%Y-%m-%d")
                   ((equal prefix '(4)) "%m/%d/%Y")  ;;; prefix: C-u
                   ((equal prefix '(16)) "%A, %B %d, %Y"))) ;;; prefix: C-u C-u
      (system-time-locale "en_US"))
      (insert (format-time-string format))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Add a YAML Header to Make a PDF
;;;
;;; This is to go with pandoc. Basically, it will add the bits needed
;;; to set page size, margins, etc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun add-PDF-YAML-header ()
  "Add basic YAML header for a PDF. Some tweaks may be required."
  (interactive)
  (goto-char (point-min))
  (insert "---\n")
  (insert "geometry: \"left=3cm,right=1cm,top=2cm,bottom=2cm\"\n") ;Set margins
  (insert "papersize: a4\n") ;Paper Size. Can be letter, a5, etc. Case Sensative
  (insert "output: pdf_document\n")
  (insert "---\n")
  (insert "\\pagenumbering{gobble}\n") ;turns off page numbering
  (insert "\n")
  (goto-char (point-min))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Take a buffer written in markdown, put in a standard, temporary
;;; Word file.
;;;
;;; Variable "tempword" set in dot.emacs.el or similar. This is the location
;;; and name of the Word file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun tempword-buffer (prefix)
  "Runs the buffer through pandoc and puts the output in a standard, temporary file. With C-u prefix, uses template defined as tempword-template"
    (interactive "P")
    (setq dacommand (concat "pandoc -f markdown -t docx -o " tempword))
    (if tempword-template  ;;;is there a tempword-template defined
	(progn
	  (if (equal prefix `(4)) ;;; Do I want to use it (C-u)?
	      (setq dacommand (concat dacommand " --reference-doc=" tempword-template))
	    )))
  (shell-command-on-region (point-min) (point-max) dacommand))

;;; This is the old version. I wanted to keep it around in case the new
;;; version doesn't work. 
(defun old-tempword-buffer ()
  "Runs the buffer through pandoc and puts the output in a standard, temporary file."
  (interactive)
  (setq dacommand (concat "pandoc -f markdown -t docx -o " tempword))
  (shell-command-on-region (point-min) (point-max) dacommand))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Prompts for a file name, and runs pandoc on the text in the
;;; buffer to output to a Microsoft Word file of that name. Assumes
;;; buffer is in Markdown format.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun save-as-word (arg)
  "Prompts for a file name, and runs pandoc on the text in the buffer to output to a Microsoft Word file of that name. Assumes buffer is in Markdown format."
  (interactive
   (list
    (read-string "Enter name of new Microsoft Word file: ")))
    (shell-command-on-region (point-min) (point-max) (concat "pandoc -f markdown -t docx -o " arg)))

;;; Original save-as-word, for reference.
;;;(defun save-as-word (arg)
;;;  "Prompts for a file name, and runs pandoc on the text in the buffer to output to a Microsoft Word file of that name. Assumes buffer is in Markdown format."
;;;  (interactive
;;;   (list
;;;    (read-string "Enter name of new Microsoft Word file: ")))
;;;    (setq dacommand (concat "pandoc -f markdown -t docx -o " arg))
;;;    (shell-command-on-region (point-min) (point-max) dacommand))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Swap to the XKCD typeface. Just 'cause
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun xkcd-it ()
  "Swaps to the XKCD font (if installed)"
  (interactive)
  (set-face-attribute 'default nil :font "XKCD Script"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Return to whatever font we prefer to use.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun use-machine-font ()
  "Returns to the font specific to value set in machine-font."
  (interactive)
  (set-face-attribute 'default nil :font machine-font))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Take a buffer written in markdown, put in a standard, temporary
;;; OpenText file.
;;;
;;; Variable "tempodt" set in dot.emacs.el or similar. This is the location
;;; and name of the OpenText file. Basically, this is a version of
;;; tempword-buffer that plays better with OpenSource software. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun tempodt-buffer (prefix)
  "Runs the buffer through pandoc and puts the output in a standard, temporary file. With C-u prefix, uses template defined as tempodt-template"
    (interactive "P")
    (setq dacommand (concat "pandoc -f markdown -t odt -o " tempodt))
    (if tempword-template  ;;;is there a tempodt-template defined
	(progn
	  (if (equal prefix `(4)) ;;; Do I want to use it (C-u)?
	      (setq dacommand (concat dacommand " --reference-doc=" tempodt-template))
	    )))
  (shell-command-on-region (point-min) (point-max) dacommand))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Add Jekyll Post Header
;;;
;;; For Jekyll posts. Inserts a template of what is needed at the top
;;; of a post. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun jekyll-post-header ()
  "Add Jekyll post YAML header template."
  (interactive)
  (goto-char (point-min))
  (insert "---\n")
  (insert "layout: post\n")
  (insert "title: \"\"\n")
  (insert "tags: \n")
  (insert "date: ")
  (insert (format-time-string "%Y-%m-%d %H:%M:%S"))
  (insert "\n---\n")
  (goto-char (point-min))
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Markdown Copy
;;;
;;; For my MacBook, this will run pandoc on the buffer and send it to
;;; the clipboard as rich text. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mdcopy ()
  "Copies the buffer to the clipboard, converting from Markdown to Rich Text in the prodcess."
  (interactive)
  (shell-command-on-region (point-min) (point-max) "pandoc --standalone -f markdown -t rtf | pbcopy"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Markdown to HTML Copy
;;;
;;; For my MacBook, this will run pandoc on the buffer and send it to
;;; the clipboard as HTML. It will not put any headers--just HTML-ize the
;;  text (i.e. it can't be a file on its own).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun md-to-html-copy ()
  "Copies the buffer to the clipboard, converting from Markdown to Rich Text in the prodcess."
  (interactive)
  (if (eq system-type `darwin)
      (progn
	(shell-command-on-region (point-min) (point-max) "pandoc -f markdown -t html | pbcopy")) ;;; Mac-Specific: it will use PBCopy to put it in the Mac clipboard.
    (progn
      	(shell-command-on-region (point-min) (point-max) "pandoc -f markdown -t html" t t)) ;;; This will replace the text in the buffer
    )
)  

(defun old-md-to-html-copy ()
  "Copies the buffer to the clipboard, converting from Markdown to Rich Text in the prodcess."
  (interactive)
  (shell-command-on-region (point-min) (point-max) "pandoc -f markdown -t html | pbcopy"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Markdown to Plain Copy
;;;
;;; For my MacBook, this will run pandoc on the buffer and send it to
;;; the clipboard as plain text.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun md-to-plain-copy ()
  "Copies the buffer to the clipboard, converting from Markdown to Rich Text in the prodcess."
  (interactive)
  (shell-command-on-region (point-min) (point-max) "pandoc -f markdown -t plain | pbcopy"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Delete Buffer
;;;
;;; One function to delete a whole buffer. Moslty this is to make a touchbar
;;; icon.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun delete-buffer ()
       "Delete the whole buffer"
       (interactive)
       (delete-region (point-min) (point-max)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; HTML for MetaFilter
;;;
;;; Convert Pandoced HTML to something better for pasting at MetaFilter.
;;;
;;; Pandoc produces HTML with <p>/</p> pairs. This does goofy stuff when
;;; pasting into MetaFilter, where it's just expecting newlines. This converts
;;; it.
;;;
;;; May be useful for other sites as well. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun html-for-metafilter ()
  "Convert Pandoced HTML to something better for pasting at MetaFilter."
  (interactive)
  (goto-char (point-min))
  (replace-string "</p>" "\n")
  (goto-char (point-min))
  (replace-string "<p>" "")
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Markdown region to HTML Copy
;;;
;;; For my MacBook, this will run pandoc on the region and send it to
;;; the clipboard as HTML. It will not put any headers--just HTML-ize the
;;  text. The initial use case is to take something from SimpleNote to paste
;;  into an existing HTML file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun md-region-to-html-copy ()
  "Copies the buffer to the clipboard, converting from Markdown to Rich Text in the prodcess."
  (interactive)
  (if (eq system-type `darwin)
      (progn
	(shell-command-on-region (region-beginning) (region-end) "pandoc -f markdown -t html | pbcopy")) ;;; Mac-Specific: it will use PBCopy to put it in the Mac clipboard.
    (progn
      	(shell-command-on-region (region-beginning) (region-end) "pandoc -f markdown -t html" t t)) ;;; This will replace the text in the buffer
    )
)
