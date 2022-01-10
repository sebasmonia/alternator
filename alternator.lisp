;;;; alternator.lisp

(in-package #:alternator)

(defvar *default-credentials* nil "The credentials to use if they are passed explicitly in a call.")
(defvar *default-region* "us-east-1" "The region to use if it is not passed explicitly in a call.")
(defvar *default-lispify* t
  "Return format when not explicit. If t, the data will be converted  to Lisp objects.")

(defun list-tables (&key (credentials *default-credentials*)
                      (region *default-region*)
                      (lispify *default-lispify*))
  "Returns the list of tables."
  (let ((response-data (flex:octets-to-string (run-request credentials region "ListTables" "{}"))))
    (if lispify
        ;; seems more appropriate to return this as a list than a vector. To me, at least
        (loop for name across (gethash "TableNames" (json-to-lisp response-data))
              collect name)
        response-data)))

(defun get-item (&key table-name item-key
                   (credentials *default-credentials*)
                   (region *default-region*)
                   (lispify *default-lispify*))
  "Obtain a single item from TABLE-NAME using ITEM-KEY (an alist of keys and values)."
  (let ((response-data  (flex:octets-to-string
                         (run-request credentials region "GetItem" (get-item-format-body
                                                                    table-name item-key)))))
    (if lispify
        (unmarshall-get-item (json-to-lisp response-data))
        response-data)))

(defun get-item-format-body (table-name item-key)
  (lisp-to-json
   (list (cons "TableName" table-name)
         (cons "Key" (format-key-values item-key)))))
