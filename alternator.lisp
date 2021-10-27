;;;; alternator.lisp

(in-package #:alternator)

(defvar *default-credentials* nil "The credentials to use if they are passed explicitly in a call.")
(defvar *default-region* "us-east-1" "The region to use if it is not passed explicitly in a call.")

(defun list-tables (&key (credentials *default-credentials*) (region *default-region*))
  "Returns the list of tables."
  (flex:octets-to-string (run-request credentials region "ListTables" "{}")))
