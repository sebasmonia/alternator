;;;; alternator.lisp

(in-package #:alternator)

(defvar *default-credentials* nil "The credentials to use if they are passed explicitly in a call.")
(defvar *default-region* "us-east-1" "The region to use if it is not passed explicitly in a call.")

(defun list-tables (&key (credentials *default-credentials*) (region *default-region*))
  "Returns the list of tables."
  (flex:octets-to-string (run-request credentials region "ListTables" "{}")))

(defun get-item (&key table-name item-key (credentials *default-credentials*) (region *default-region*))
  "Obtain a single item from TABLE-NAME using ITEM-KEY (an alist of keys and values)."
  (flex:octets-to-string
   (run-request credentials region "GetItem" (get-item-format-body table-name item-key))))

(defun get-item-format-body (table-name item-key)
  (lisp-to-json
   (list (cons "TableName" table-name)
         (cons "Key" (format-key-values item-key)))))

(defun format-key-values (key-value-pairs)
  (loop for (k . v) in key-value-pairs
               collect (cons k (list (append-type-qualifier v)))))

(defun append-type-qualifier (value)
  "Return VALUE as a cons cell ( [type] . VALUE ) where [type] is a one-letter AWS type qualifier."
  ;; TODO: ehhh write the code, right now it will hardcode everything as string.
  (cons "S" value))

(defun json-to-lisp (string)
  (shasht:read-json* :stream string :object-format :alist :array-format :list))

(defun lisp-to-json (alist)
  (shasht:write-json* alist :stream nil :alist-as-object t))
