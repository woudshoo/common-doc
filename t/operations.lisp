(in-package :cl-user)
(defpackage common-doc-test.ops
  (:use :cl :fiveam :common-doc)
  (:import-from :common-doc.ops
                :with-document-traversal
                :collect-figures
                :collect-tables
                :collect-external-links
                :node-equal)
  (:export :operations))
(in-package :common-doc-test.ops)

(def-suite operations
  :description "common-doc operations tests.")
(in-suite operations)

(test traverse
  (let ((document (make-document
                   "test"
                   :children
                   (list
                    (make-bold
                     (list
                      (make-italic
                       (list
                        (make-underline nil))))))))
        (document-depth)
        (bold-depth)
        (italic-depth)
        (underline-depth))
    (finishes
      (with-document-traversal (document node depth)
        (typecase node
          (document
           (setf document-depth depth))
          (bold
           (setf bold-depth depth))
          (italic
           (setf italic-depth depth))
          (underline
           (setf underline-depth depth)))))
    (is
     (equal document-depth 0))
    (is
     (equal bold-depth 1))
    (is
     (equal italic-depth 2))
    (is
     (equal underline-depth 3))))

(test figures
  (let ((document)
        (figs))
    (finishes
      (setf document
            (make-document
             "test"
             :children
             (list
              (make-section
               (list (make-text "Section 1"))
               :children
               (list
                (make-figure
                 (make-image "fig1.jpg")
                 (list
                  (make-text "Fig 1")))))
              (make-section
               (list (make-text "Section 2"))
               :children
               (list
                (make-figure
                 (make-image "fig2.jpg")
                 (list
                  (make-text "Fig 2")))))))))
    (finishes
      (setf figs (collect-figures document)))
    (let* ((first-fig (first figs))
           (second-fig (second figs))
           (first-img (image first-fig))
           (second-img (image second-fig)))
      (is
       (equal (source first-img) "fig1.jpg"))
      (is
       (equal (source second-img) "fig2.jpg")))))

(test tables
  (let ((document
          (make-document
           "test"
           :children
           (list
            (make-table
             (list
              (make-row (list (make-cell nil)))))
            (make-table
             (list
              (make-row (list (make-cell nil))))))))
        (tables))
    (finishes
      (setf tables (collect-tables document)))
    (is
     (equal (length tables) 2))))

(test links
  (let ((document
          (make-document
           "test"
           :children
           (list
            (make-paragraph
             (list
              (make-web-link "http://example.com/" nil))))))
        (links))
    (finishes
      (setf links (collect-external-links document)))
    (is
     (equal (length links) 1))))

(test unique-ref
  (let ((doc (make-document
              "test"
              :children
              (list
               (make-section
                (list (make-text "Section 1"))
                :children (list
                           (make-content
                            (list
                             (make-content
                              (list
                               (make-section (list (make-text "Section 1.1"))
                                             :reference "sec11")))))))
               (make-section
                (list (make-text "Section 2")))))))
    (finishes
      (common-doc.ops:fill-unique-refs doc))
    (is
     (equal (reference (first (children doc)))
            "section-1"))
    (is
     (equal (reference (first (children
                               (first (children
                                       (first (children
                                               (first (children doc)))))))))
            "sec11"))
    (is
     (equal (reference (second (children doc)))
            "section-2"))))


(test toc
  (let* ((doc (make-document
               "test"
               :children
               (list
                (make-section
                 (list (make-text "Section 1"))
                 :reference "sec1"
                 :children
                 (list
                  (make-content
                   (list
                    (make-content
                     (list
                      (make-section
                       (list (make-text "Section 1.1"))
                       :reference "sec11")))))))
                (make-section
                 (list (make-text "Section 2"))
                 :reference "sec2"))))
         (toc (common-doc.ops:table-of-contents doc)))
    (is-true (typep toc 'ordered-list))
    (is
     (equal (length (children toc))
            2))
    (let ((list-item (first (children toc))))
      (is-true (typep list-item 'list-item)))
    (let ((list-item (second (children toc))))
      (is-true (typep list-item 'list-item))
      (let ((link (first (children list-item))))
        (is
         (equal (common-doc.ops:collect-all-text link)
                "Section 2"))))))
