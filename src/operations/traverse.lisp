(in-package :common-doc.ops)

(defgeneric traverse-document (node function &optional depth)
  (:documentation "Apply a side-effectful function recursively to every element
  in the document. Depth-first.")

  (:method ((doc document) function &optional (depth 0))
    (funcall function doc depth)
    (loop for child in (children doc) do
      (traverse-document child function (1+ depth))))

  (:method ((cnode content-node) function &optional (depth 0))
    (funcall function cnode depth)
    (loop for child in (children cnode) do
      (traverse-document child function (1+ depth))))

  (:method ((dnode document-node) function &optional (depth 0))
    (funcall function dnode depth)))

(defmacro with-document-traversal ((doc node &optional (depth 'depth)) &rest body)
  "Execute body in each node of the document."
  `(traverse-document ,doc
                      #'(lambda (,node ,depth)
                          ,(if (eql depth 'depth)
                             `(declare (ignore depth)))
                          ,@body)))
