;;;; credentials.lisp

(in-package #:alternator)

(defstruct credentials
  access-key-id
  secret-access-key
  session-token)

(defun credentials-from-section (section-alist)
  (destructuring-bind ((_tok . token) (_secret . secret-key) (_key . key-id))
      section-alist
    (declare (ignore _tok _secret _key))
    (make-credentials
     :access-key-id key-id
     :secret-access-key secret-key
     :session-token token)))

(defun credentials-from-profile (profile-name)
  (let ((parser (py-configparser:make-config)))
    (py-configparser:read-files parser (list (merge-pathnames ".aws/credentials" (user-homedir-pathname))))
    (loop for section-name in (py-configparser:sections parser)
          when (string-equal section-name profile-name)
            return (credentials-from-section (py-configparser:items parser section-name)))))

(defun credentials-from-envvars ()
    (make-credentials
     :access-key-id (uiop:getenv "AWS_ACCESS_KEY_ID")
     :secret-access-key (uiop:getenv "AWS_SECRET_ACCESS_KEY")
     :session-token (uiop:getenv "AWS_SESSION_TOKEN")))
