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
   #:credentials-from-profile))

(in-package #:alternator)
