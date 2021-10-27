;;;; alternator.asd

(asdf:defsystem #:alternator
  :description "DynamoDB client for Common LIsp"
  :author "Sebastián Monía <smonia@outlook.com>"
  :license  "MIT"
  :version "0.0.1"
  :serial t
  :depends-on (#:alexandria
               #:uiop
               #:dexador
               #:py-configparser
               #:aws-sign4
               #:flexi-streams)
  :components ((:file "package")
               (:file "request")
               (:file "credentials")
               (:file "alternator")))