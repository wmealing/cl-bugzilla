;;; Wmealing 2023

(defpackage #:bugzilla
  (:use #:cl
        #:cl-json)
  (:nicknames :bz)
  (:export
   :request
   :get-bug
   :get-bugs
   :update-bug
   :get-comments
   :test
   :version
   :*api-key*))

(in-package #:bugzilla)

(defparameter *domain* ".bugzilla.com")

(defparameter *root-endpoint* "https://bugzilla.redhat.com/rest/")

(defvar *api-key*)

(defun request (method resource &key params data)
  "Do the http request and return an alist.

- method: keyword :GET :POST,
- resource: ids must be either an integer or an url-encoded couple user/project: `/projects/user%2Frepo`
- params: alist of params: '((\"login\" . \"foo\")) will be url-encoded.

Example:
(bugzilla:request :GET \"/version\")"

  (let* ((p (and params (str:concat "?" (quri:url-encode-params params))))
         (d (encode-json-to-string data))
         (auth-header (str:concat "Bearer " *api-key*))
         (h (list (cons "Authorization"  auth-header)))
         (url (str:concat *root-endpoint* resource p)))
    (print url)
    (print h)
    (print d)
    (with-input-from-string (s (dex:request url :method method :content d :headers h))
      (cl-json:decode-json s))))
(defun version ( &key params data)
  (request :GET "version"))

(defun get-bug ( bug &key params data)
  (let* ((p (and params (str:concat "?" (quri:url-encode-params params))))
         (d (and data (encode-json data)))
         (url (str:concat "bug/" (write-to-string bug) p)))
    (request :GET url)))

(defun get-bugs (bug-list &key params)
  (let* ((p (and params (str:concat "?" (quri:url-encode-params params))))
         (url (str:concat "bug?id=" (format nil "~{~A~^,~}" bug-list) p)))

    (request :GET url)))

(defun update-bug (bug-id &key data)
  "Update a single bug
  Example:
    (bugzilla:update-bug \"2210552\" :data '((\"summary\" . \"Test Please ignore\")))
  Possible fields to update shown in the docs, see:
     https://bugzilla.redhat.com/docs/en/html/api/core/v1/bug.html#update-bug"
  (let* ((url (str:concat "bug/" (write-to-string bug-id)))
         (d (encode-json-to-string data)))
    (request :PUT url :data data)))

(defun get-comments
    (bug-id)
  "Get all comments from a specific bug.

   Example of usage from:
    https://bugzilla.redhat.com/docs/en/html/api/core/v1/comment.html"

  (request :GET
           (str:concat "/bug/" (write-to-string bug-id) "/comment" )))
