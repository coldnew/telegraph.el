;;; telegraph.el --- telegra.ph api for emacs  -*- lexical-binding: t; -*-

;; Copyright (c) 2018 Yen-Chin, Lee.
;;
;; Author: coldnew <coldnew.tw@gmail.com>
;; Package-Requires: ((request "0.2.0"))
;; X-URL: http://github.com/coldnew/telegraph.el
;; Version: 0.1

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;; [![MELPA](http://melpa.org/packages/telegraph.el.svg)](http://melpa.org/#/telegraph.el)
;; [![MELPA Stable](http://stable.melpa.org/packages/telegraph.el.svg)](http://stable.melpa.org/#/telegraph.el)

;;; Installation:

;; If you have `melpa` and `emacs24` installed, simply type:
;;
;;     M-x package-install telegraph
;;
;; And add the following to your .emacs
;;
;;     (require 'telegraph)

;;; Code:

(eval-when-compile (require 'cl))
(require 'url)
(require 'request)
(require 's)
(require 'dash)
(require 'subr-x)
(require 'json)                         ;buildin


;;;; Local Functions

(cl-defun telegraph--request (&key
			      (api nil)
			      (params nil))
  "Send request to telegra.ph.

==================== ========================================================
Keyword argument      Explanation
==================== ========================================================
API        (string)   telegra.ph's api, like createAccount, getViews
PARAMS      (alist)   set \"?key=val\" part in URL
==================== ========================================================"
  ;; check for arguments
  (cl-assert (stringp api)  nil "API must be an string. Given %S" api)
  (cl-assert (listp params) nil "PARAMS must be an alist. Given %S" params)
  ;; let's make request
  (let* ((json-object-type 'plist)
	 (url "https://api.telegra.ph")
	 (api-url (concat url "/" api "?" (request--urlencode-alist params))))
    (with-temp-buffer
      (url-insert-file-contents api-url)
      (json-read))))


;;;; HTML <-> Node

(defalias 'telegraph--html-parse-region 'libxml-parse-html-region)

(defun telegraph--parse-html (html-string)
  "Parse HTML-STRING to sexp.

input:   <p>Hello, world!<br/></p>
output:  (p nil \"Hello, world!\" (br nil)"
  (cl-assert (stringp html-string)  nil "HTML-STRING must be an string. Given %S" html-string)
  ;; result:  (p nil "Hello, world!" (br nil)
  (caddr
   ;; result:  (body nil (p nil "Hello, world!" (br nil)))
   (caddr
    ;; input:   <p>Hello, world!<br/></p>
    ;; result:  (html nil (body nil (p nil "Hello, world!" (br nil))))
    (with-temp-buffer
      (insert html-string)
      (telegraph--html-parse-region (point-min) (point-max))))))


;;;; APIs

(cl-defun telegraph-createAccount (&key
				   (short_name nil)
				   (author_name nil)
				   ;; optional
				   (author_url nil))
  "Use this method to create a new Telegraph account.
Most users only need one account, but this can be useful for channel
administrators who would like to keep individual author names and
profile links for each of their channels.  On success, returns an
Account object with the regular fields and an additional
access_token field.

- SHORT_NAME  (String, 1-32 characters)

  Required.  Account name, helps users with several accounts
  remember which they are currently using.  Displayed to the user
  above the 'Edit/Publish' button on Telegra.ph, other users don't
  see this name.

- AUTHOR_NAME  (String, 0-128 characters)

  Default author name used when creating new articles.

- AUTHOR_URL  (String, 0-512 characters)

  Default profile link, opened when users click on the author's
  name below the title.  Can be any link, not necessarily to a
  Telegram profile or channel.

Sample request:
  https://api.telegra.ph/createAccount?short_name=Sandbox&author_name=Anonymous

API URL:
  https://telegra.ph/api#createAccount"
  ;; parameter checker
  (cl-assert  (stringp short_name) nil  "SHORT_NAME must be an string. Given %S" short_name)
  (cl-assert  (stringp author_name) nil "AUTHOR_NAME must be an string. Given %S" author_name)
  ;; let's send request
  (let ((params `(("short_name" . ,short_name) ("author_name" . ,author_name))))
    ;; if author_url exist, add to params
    (when author_url
      (cl-assert  (stringp author_url) nil "AUTHOR_URL must be an string. Given %S" author_url)
      (add-to-list 'params '("author_url" . author_url)))
    ;; make our request
    (telegraph--request :api "createAccount" :params params)))

(provide 'telegraph)
;;; telegraph.el ends here
