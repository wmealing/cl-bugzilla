(defsystem #:bugzilla
  :version      "0.1.0"
  :description  "Interface to Bugzilla's API"
  :author       "wmealing"
  :serial       t
  :license      "MIT"
  :depends-on   (:quri
                 :dexador
                 :str
                 :cl-json)
  :components   ((:file "bugzilla")))
