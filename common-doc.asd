(defsystem common-doc
  :author "Fernando Borretti <eudoxiahp@gmail.com>"
  :maintainer "Fernando Borretti <eudoxiahp@gmail.com>"
  :license "MIT"
  :version "0.1"
  :depends-on (:trivial-types
               :local-time
               :quri
               :anaphora
               :alexandria)
  :components ((:module "src"
                :serial t
                :components
                ((:file "packages")
                 (:file "define")
                 (:file "classes")
                 (:file "operations")
                 (:file "error")
                 (:file "macros")
                 (:file "format")
                 (:file "util"))))
  :description "A framework for representing and manipulating documents as CLOS
  objects."
  :long-description
  #.(uiop:read-file-string
     (uiop:subpathname *load-pathname* "README.md"))
  :in-order-to ((test-op (test-op common-doc-test))))
