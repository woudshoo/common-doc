(in-package :common-doc)

;;; Basic classes

(defclass <document-node> ()
  ((metadata :accessor metadata
             :initarg :metadata
             :type (or null hash-table)
             :initform nil
             :documentation "Node metadata."))
  (:documentation "The base class of all document classes."))

(defclass <content-node> (<document-node>)
  ((children :accessor children
             :initarg :children
             :type (proper-list <document-node>)
             :documentation "The node's children."))
  (:documentation "A node with children. This is the base class of all nodes
  that have a `children` slot (Except `<document>`, since this class inherits
  from <document-node>) and can also be used as a way to represent a generic
  grouping of elements. This is useful when building a CommonDoc document by
  parsing some input language."))

(defclass <text-node> (<document-node>)
  ((text :accessor text
         :initarg :text
         :type string
         :documentation "The node's text."))
  (:documentation "A node representing a bare string of text."))

(defclass <paragraph> (<content-node>)
  ()
  (:documentation "A paragraph."))

;;; Markup

(defclass <markup> (<content-node>)
  ()
  (:documentation "The superclass of all inline markup elements."))

(defclass <bold> (<markup>)
  ()
  (:documentation "Text in this element is bold."))

(defclass <italic> (<markup>)
  ()
  (:documentation "Text in this element is italicized."))

(defclass <underline> (<markup>)
  ()
  (:documentation "Text in this element is underlined."))

(defclass <strikethrough> (<markup>)
  ()
  (:documentation "Text in this element is striked out."))

(defclass <code> (<markup>)
  ()
  (:documentation "Text in this element is monospaced or otherwise marked as
  code or computer output."))

(defclass <superscript> (<markup>)
  ()
  (:documentation "Text in this element is superscripted relative to containing
  elements."))

(defclass <subscript> (<markup>)
  ()
  (:documentation "Text in this element is subscripted relative to containing
  elements."))

;;; Code

(defclass <code-block> (<content-node>)
  ((language :accessor language
             :initarg :language
             :type string
             :documentation "The language of the code block's contents."))
  (:documentation "A block of code."))

;;; Quotes

(defclass <quote> (<content-node>)
  ()
  (:documentation "The base class of all quotes."))

(defclass <inline-quote> (<quote>)
  ()
  (:documentation "A quote that occurs inside a paragraph in the document."))

(defclass <block-quote> (<quote>)
  ()
  (:documentation "A block quote."))

;;; Links

(defclass <link> (<content-node>)
  ()
  (:documentation "The base class for all links, internal and external."))

(defclass <internal-link> (<link>)
  ((section-reference :accessor section-reference
                      :initarg :section-reference
                      :type string
                      :documentation "A reference key for the linked section."))
  (:documentation "A link to a section of this document."))

(defclass <external-link> (<link>)
  ((document-reference :accessor document-reference
                      :initarg :document-reference
                      :type string
                      :documentation "A reference key for the linked document.")
   (section-reference :accessor section-reference
                      :initarg :section-reference
                      :type string
                      :documentation "A reference key for the linked section."))
  (:documentation "A link to another document (See `reference` slot in the
  `<document>` class), and optionally a section within that document."))

(defclass <web-link> (<link>)
  ((uri :accessor uri
        :initarg :uri
        :type quri:uri
        :documentation "The URI of the external resource."))
  (:documentation "An external link."))

;;; Lists

(defclass <list> (<document-node>)
  ()
  (:documentation "The base class of all lists."))

(defclass <list-item> (<content-node>)
  ()
  (:documentation "The item in a non-definition list."))

(defclass <definition> (<document-node>)
  ((term :accessor term
         :initarg :term
         :type <document-node>
         :documentation "The definition term.")
   (definition :accessor definition
               :initarg :definition
               :type <document-node>
               :documentation "Defines the term."))
  (:documentation "An item in a definition list."))

(defclass <unordered-list> (<list>)
  ((items :accessor items
          :initarg :items
          :type (proper-list <list-item>)
          :documentation "The list of `<list-item>` instances."))
  (:documentation "A list where the elements are unordered."))

(defclass <ordered-list> (<list>)
  ((items :accessor items
          :initarg :items
          :type (proper-list <list-item>)
          :documentation "The list of `<list-item>` instances."))
  (:documentation "A list where the elements are ordered."))

(defclass <definition-list> (<list>)
  ((items :accessor items
          :initarg :items
          :type (proper-list <definition>)
          :documentation "The list of `<definition>` instances."))
  (:documentation "A list of definitions."))

;;; Figures

(defclass <image> (<document-node>)
  ((source :accessor source
           :initarg :source
           :type string
           :documentation "The source where the image is stored.")
   (description :accessor description
                :initarg :description
                :type string
                :documentation "A plain text description of the image."))
  (:documentation "An image."))

(defclass <figure> (<document-node>)
  ((image :accessor image
          :initarg :image
          :type <image>
          :documentation "The figure's image.")
   (description :accessor description
                :initarg :description
                :type (proper-list <document-node>)
                :documentation "A description of the image."))
  (:documentation "A figure, an image plus an annotation."))

;;; Tables

(defclass <table> (<document-node>)
  ((rows :accessor rows
         :initarg :rows
         :type (proper-list <row>)
         :documentation "The list of rows in a table."))
  (:documentation "A table."))

(defclass <row> (<document-node>)
  ((header :accessor header
           :initarg :header
           :type (proper-list <document-node>)
           :documentation "The row header.")
   (footer :accessor footer
           :initarg :footer
           :type (proper-list <document-node>)
           :documentation "The row footer.")
   (cells :accessor cells
          :initarg :cells
          :type (proper-list <cell>)
          :documentation "The cells in the row."))
  (:documentation "A row in a table."))

(defclass <cell> (<content-node>)
  ()
  (:documentation "A cell in a table."))

;;; Large-scale structure

(defclass <section> (<content-node>)
  ((title :accessor title
          :initarg :title
          :type <document-node>
          :documentation "The section title.")
   (reference :accessor reference
              :initarg :reference
              :initform nil
              :type string
              :documentation "A reference key for this section."))
  (:documentation "Represents a section in the document. Unlike HTML, where a
  section is just another element, sections in CommonDoc contain their contents."))

(defclass <document> ()
  ((children :accessor children
             :initarg :children
             :type (proper-list <document-node>)
             :documentation "The document's children nodes.")
   ;;; Metadata, mostly based on Dublin Core[1] and the OpenDocument[2] format.
   ;;;
   ;;; [1]: https://en.wikipedia.org/wiki/Dublin_Core
   ;;; [2]: https://en.wikipedia.org/wiki/OpenDocument_technical_specification#Metadata
   (title :accessor title
          :initarg :title
          :type string
          :documentation "The document's title.")
   (creator :accessor creator
            :initarg :creator
            :type string
            :documentation "The creator of the document.")
   (publisher :accessor publisher
              :initarg :publisher
              :type string
              :documentation "The document's publisher.")
   (subject :accessor subject
            :initarg :subject
            :type string
            :documentation "The subject the document deals with.")
   (description :accessor description
            :initarg :description
            :type string
            :documentation "A description of the document.")
   (keywords :accessor keywords
             :initarg :keywords
             :type (proper-list string)
             :documentation "A list of strings, each being a keyword for the document.")
   (reference :accessor reference
              :initarg :reference
              :type string
              :documentation "A reference string to uniquely identify the
              document within a certain context.")
   (language :accessor language
            :initarg :language
             :type string
             :documentation "An [RFC4646](http://www.ietf.org/rfc/rfc4646.txt) string denoting the language the document is written in.")
   (rights :accessor rights
           :initarg :rights
           :type string
           :documentation "Information on the document's copyright.")
   (version :accessor version
            :initarg :version
            :type string
            :documentation "The document version.")
   (created-on :accessor created-on
               :initarg :created-on
               :type local-time:timestamp
               :initform (local-time:now)
               :documentation "The date and time when the document was
               created. By default, this is the date and time at instance
               creation."))
  (:documentation "A document."))
