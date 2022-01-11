(in-package #:alternator)

(defun format-key-values (key-value-pairs)
  (loop for (k . v) in key-value-pairs
        collect (cons k (list (marshall-convert-type v)))))

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
      ((equal type "M") (unmarshall-hash-table value))
      ((equal type "L")  (unmarshall-vector value))
      ;; Binary data is sent as b64 encoded strings
      ((equal type "B") (with-input-from-string (base64-from-dynamo value)
                          (s-base64:decode-base64-bytes base64-from-dynamo)))
      ;; TODO: add binary set conversion
      ;; The "default" value covers handling NS (number set) and SS (string set) as
      ;; vectors with values of the same type
      (t value))))

(defun unmarshall-vector (a-vector)
  (coerce (loop for elt across a-vector
                collect (unmarshall-convert-type elt))
          'vector))

(defun unmarshall-hash-table (the-hash-table)
  (let ((output (make-hash-table
                 :test (hash-table-test the-hash-table)
                 :rehash-size (hash-table-rehash-size the-hash-table)
                 :rehash-threshold (hash-table-rehash-threshold the-hash-table)
                 :size (hash-table-size the-hash-table))))
    (loop for key being the hash-key
            using (hash-value value) of the-hash-table
          do (setf (gethash key output) (unmarshall-convert-type value))
          finally (return output))))

(defun unmarshall-get-item (parsed-json)
  (alexandria:when-let ((item (gethash "Item" parsed-json)))
    (unmarshall-hash-table item)))

(defun marshall-convert-type (value)
  (typecase value
    (string (cons "S" value))
    ;; problem: how to differentiate Number Set from a Byte Array?
    (vector (cond ((every #'numberp value) (cons "NS" value))
                  ((every #'stringp value) (cons "SS" value))
                  (t (cons "L" (coerce (loop for elt across value
                                             collect (marshall-convert-type elt))
                                       'vector)))))
    (number (cons "N" (write-to-string value)))
    (hash-table (list (cons "M" (marshall-hash-table value))))
    ;; :true or :false -- keep as is, shasht will convert them
    (keyword (cons "BOOL" value))
    ;; I know this will fail, so if I hit this value, it means I need
    ;; to add a new conversion
    ;; TODO: add binary conversion
    (t (cons "ERROR" value))
  ))

(defun marshall-hash-table (element)
  ;; instead of creating a hash-table to hold "s" : "string" or "m" = {a vector}
  ;; let's use an alist and send that to shasht. seems much less wasteful :)
  (loop for key being the hash-key
          using (hash-value value) of element
        collect (list key (marshall-convert-type value))))
