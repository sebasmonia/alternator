;;;; package.lisp

(defpackage #:alternator
  (:nicknames "alte" :alte)
  (:use #:common-lisp)
  (:import-from :alexandria)
  (:import-from :uiop)
  (:import-from :dexador)
  (:import-from :py-configparser)
  (:import-from :aws-sign4)
  (:import-from :flexi-streams)
  (:export
   #:*default-credentials*
   #:*default-region*
   #:list-tables
   #:credentials-from-envvars
   #:credentials-from-profile))

(in-package #:alternator)
