;;;; request.lisp

(in-package #:alternator)

(defvar *api-version* "DynamoDB_20120810" "The version of the DynamoDB API to use.")

(defun run-request (aws-credentials region action body)
  "Run a request using AWS-CREDENTIALS to sign the request. ACTION is the operation to execute in
the API. BODY is the string expected by the operation (most likely a JSON string). REGION is self
explanatory."
  (let* ((host (format nil "dynamodb.~a.amazonaws.com" region))
         (aws-sign4:*aws-credentials* (lambda ()
                                        (values (credentials-access-key-id aws-credentials)
                                                (credentials-secret-access-key aws-credentials))))
         (target (format nil "~a.~a" *api-version* action))
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
