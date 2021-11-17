;;;; package.lisp

(defpackage #:alternator
  (:nicknames "alte" :alte)
  (:use #:common-lisp)
  (:import-from :alexandria)
  (:import-from :uiop)
  (:import-from :dexador)
  (:import-from :py-configparser)
  (:import-from :aws-sign4)
  (:import-from :shasht)
  (:import-from :flexi-streams)
  (:export
   #:*default-credentials*
   #:*default-region*
   #:list-tables
   #:get-item
   #:credentials-from-envvars
   #:credentials-from-profile))

(in-package #:alternator)
