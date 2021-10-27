;;;; request.lisp

(in-package #:alternator)

(defun run-request (aws-credentials region action body)
  (let* ((host (format nil "dynamodb.~a.amazonaws.com" region))
         (aws-sign4:*aws-credentials* (lambda ()
                                        (values (credentials-access-key-id aws-credentials)
                                                (credentials-secret-access-key aws-credentials))))
         (target (format nil "DynamoDB_20120810.~a" action))
         (token (credentials-session-token aws-credentials)))
    (multiple-value-bind (aws-sign4-authz aws-sign4-date)
        (aws-sign4:aws-sign4 :region region
                             :service :dynamodb
                             :method :post
                             :host host
                             :path "/"
                             :headers `((:x-amz-target . ,target)
                                        (:content-type .  "application/x-amz-json-1.0"))
                             :payload body)
    (handler-bind ((dex:http-request-failed (lambda (c)
                                              (declare (ignore c))
                                              (invoke-restart 'dex:ignore-and-continue))))
      (dex:post (format nil "https://~a/" host)
                :headers `((:host . ,host)
                           (:content-length . ,(length body))
                           (:authorization . ,aws-sign4-authz)
                           (:x-amz-date . ,aws-sign4-date)
                           (:x-amz-target . ,target)
                           ,(when token (cons :x-amz-security-token token))
                           (:content-type .  "application/x-amz-json-1.0"))
                :content body)))))
