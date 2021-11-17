(in-package #:alternator)

(defun format-key-values (key-value-pairs)
  (loop for (k . v) in key-value-pairs
        collect (cons k (list (append-type-qualifier v)))))

(defun append-type-qualifier (value)
  "Return VALUE as a cons cell ( [type] . VALUE ) where [type] is a one-letter AWS type qualifier."
  ;; TODO: ehhh write the code, right now it will hardcode everything as string.
  (cons "S" value))

(defun json-to-lisp (string)
  (shasht:read-json* :stream string))

(defun lisp-to-json (alist)
  (shasht:write-json* alist :stream nil :alist-as-object t))

(defun unmarshall-convert-type (leaf-ht)
  (let ((type (car (alexandria:hash-table-keys leaf-ht)))
        (value (car (alexandria:hash-table-values leaf-ht))))
    (cond
      ((equal type "N") (read-from-string value))
      ((equal type "BOOL") (if value
                               :true
                               :false))
      ((equal type "M") (unmarshall-as-alist value))
      ((equal type "L")  (unmarshall-vector value))
      ((equal type "SS") (unmarshall-vector value))
      ((equal type "NS") (unmarshall-vector value))
      (t value))))

(defun unmarshall-vector (a-vector)
  (coerce (loop for elt across a-vector
                collect (unmarshall-convert-type elt))
          'vector))

;; (defun unmarshall-hash-table (the-hash-table)
;;   (let ((output (make-hash-table
;;                  :test (hash-table-test the-hash-table)
;;                  :rehash-size (hash-table-rehash-size the-hash-table)
;;                  :rehash-threshold (hash-table-rehash-threshold the-hash-table)
;;                  :size (hash-table-size the-hash-table))))
;;     (loop for key being the hash-key
;;             using (hash-value value) of the-hash-table
;;           do (setf (gethash key output) (unmarshall-convert-type value :map-output :hash-table))
;;           finally (return output))))

(defun unmarshall-as-alist (the-hash-table)
    (loop for key being the hash-key
            using (hash-value value) of the-hash-table
          collect (cons key (unmarshall-convert-type value))))

(defun unmarshall-get-item (parsed-json)
  (alexandria:when-let ((item (gethash "Item" parsed-json)))
    (unmarshall-as-alist item)))

;; (defun marshall-type (value)
;;   (typecase value
;;     (list )
;;     (vector (cons "L" (coerce (loop for elt across value
;;                                      collect (marshall-type elt))
;;                                'vector)))
;;      (cons (cons (typecase

;;                        (string value))
;;      ("")
;;      (number
;;                       (string
;;                        (t

;;   )

;; (defun marshall-alist (input)
;;   (loop for (key . value) in input
;;         collect (cons key (marshall-type value))))
