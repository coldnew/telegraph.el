;;; test.el --- telegraph test

;; Copyright (C) 2018 by Yen-Chin, Lee

;; Author: Yen-Chin, Lee <coldnew.tw@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:
(require 'ert)
(require 'telegraph)

(ert-deftest test-createAccount ()
  "Test telegraph:createAccount with "
  (let* ((account (telegraph-createAccount
		   :short_name  "Sandbox"
		   :author_name "Anonymous"))
	 (result (plist-get account :result)))
    ;; should return :ok with value t
    (should (plist-get account :ok))
    ;; should the sanme as user input
    (should (string= "Sandbox"   (plist-get result :short_name)))
    (should (string= "Anonymous" (plist-get result :author_name)))
    ;; other data should not be nil
    (should (stringp (plist-get result :author_url)))
    (should (stringp (plist-get result :access_token)))
    (should (stringp (plist-get result :auth_url)))))

;;; test.el ends here
