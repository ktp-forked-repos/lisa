;;; This file is part of LISA, the Lisp-based Intelligent Software
;;; Agents platform.

;;; Copyright (C) 2000 David E. Young (de.young@computer.org)

;;; This library is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU Lesser General Public License
;;; as published by the Free Software Foundation; either version 2.1
;;; of the License, or (at your option) any later version.

;;; This library is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.

;;; You should have received a copy of the GNU Lesser General Public License
;;; along with this library; if not, write to the Free Software
;;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;;; File: parser.lisp
;;; Description: The LISA programming language parser. Basic parsing and
;;; validation is done here, but it isn't comprehensive. Additional parsing
;;; work (and error discovery) for some constructs (such as defrule, assert,
;;; modify) is performed elsewhere as these constructs undergo additional
;;; transformations.
;;;
;;; $Id: parser.lisp,v 1.62 2001/04/09 20:32:14 youngde Exp $

(in-package "LISA")

(defconstant *rule-separator* '=>)

(defmacro with-slot-components (((name field constraint) slot) &body body)
  `(destructuring-bind (,name ,field &optional ,constraint) ,slot
     ,@body))

(defmacro with-rule-components (((doc-string decls lhs rhs) rule-form) &body body)
  (let ((remains (gensym)))
    `(multiple-value-bind (,doc-string ,decls ,remains)
         (extract-rule-headers ,rule-form)
       (multiple-value-bind (,lhs ,rhs)
           (parse-rulebody ,remains)
         ,@body))))

(defun redefine-defrule (name body)
  (flet ((redefine-rule ()
           (with-rule-components ((doc-string decls lhs rhs) body)
             (let ((rule (make-rule name (current-engine)
                                    :doc-string doc-string 
                                    :directives decls
                                    :source body)))
               (finalize-rule-definition rule lhs rhs)
               (add-rule (current-engine) rule)))))
    (handler-case
        (redefine-rule)
      (syntactical-error (condition)
        (rule-structure-error name condition)))))

(defun extract-rule-headers (body)
  (flet ((create-directives (spec)
           (make-directive (first spec) (rest spec))))
    (let ((doc nil)
          (decls nil)
          (remains body))
      (when (stringp (first remains))
        (setf doc (first remains))
        (setf remains (rest remains)))
      (setf decls (first remains))
      (cond ((and (consp decls)
                  (eq (first decls) 'declare))
             (setf decls 
               (mapcar #'create-directives (rest decls)))
             (setf remains (rest remains)))
            (t (setf decls nil)))
      (values doc decls remains))))

#+ignore
(defun extract-rule-headers (body)
  (labels ((extract-headers (headers doc)
             (let ((obj (first headers)))
               (cond ((stringp obj)
                      (if (null doc)
                          (extract-headers (rest headers) obj)
                        (parsing-error
                         "Too many documentation strings: ~S." obj)))
                     ((consp obj)
                      (let ((decl (first obj)))
                        (if (and (symbolp decl)
                                 (eq decl 'declare))
                            (values doc obj (rest headers))
                          (values doc nil headers))))
                     (t (values doc nil headers))))))
    (extract-headers body nil)))

(defun parse-rulebody (body)
  (labels ((parse-lhs (body patterns)
             (let ((pattern (first body)))
               (cond ((consp pattern)
                      (parse-lhs (rest body)
                                 (nconc patterns
                                        (make-rule-pattern pattern))))
                     ((null pattern)
                      (values patterns))
                     (t
                      (pattern-error pattern "Incorrect structure.")))))
           (parse-rhs (actions)
             (values actions)))
    (multiple-value-bind (lhs remains)
        (find-before *rule-separator* body :test #'eq)
      (if (not (null remains))
          (values (parse-lhs lhs nil)
                  (parse-rhs (find-after *rule-separator* remains :test #'eq)))
        (parsing-error "Missing rule separator.")))))

(defun make-rule-pattern (template)
  (labels ((parse-pattern (p binding)
             (let ((head (first p)))
               (if (symbolp head)
                   (cond ((eq head 'test)
                          (make-test-pattern (rest p)))
                         ((eq head 'not)
                          (make-parsed-pattern
                           :pattern (make-default-pattern (second p))
                           :type :negated))
                         ((variablep head)
                          (if (null binding)
                              (parse-pattern (first (rest p)) head)
                            (pattern-error
                             template "Too many pattern variables: ~S." head)))
                         (t
                          (make-parsed-pattern
                           :pattern (make-default-pattern p)
                           :binding binding
                           :type :generic)))
                 (pattern-error
                  template "Patterns must begin with a symbol.")))))
    `(,(parse-pattern template nil))))

(defun parse-default-pattern (pattern)
  (let* ((head (first pattern))
         (meta (find-meta-class head nil)))
    (when (null meta)
      (pattern-error
       pattern "This pattern is not supported by any known class."))
    (labels ((parse-slot (slot)
               (with-slot-components ((name field constraint) slot)
                 (cond ((and (symbolp name)
                             (slot-valuep field)
                             (constraintp constraint))
                        (if (has-meta-slot-p meta name)
                            `(,name ,field ,constraint)
                          (pattern-error
                           pattern
                           "This slot is not a recognized member: ~S." name)))
                       (t
                        (pattern-error
                         pattern
                         "There are type problems with this slot: ~S." slot)))))
             (parse-pattern-body (body slots)
               (let ((slot (first body)))
                 (cond ((consp slot)
                        (parse-pattern-body (rest body)
                                            (nconc slots
                                                   `(,(parse-slot slot)))))
                       ((null slot)
                        (values slots))
                       (t
                        (pattern-error
                         pattern "Found one or more structural problems."))))))
    `(,head ,(parse-pattern-body (rest pattern) nil)))))

(defun make-default-pattern (p)
  (parse-default-pattern p))

(defun normalize-slots (slots)
  (flet ((normalize (slot)
           (let ((slot-name (first slot))
                 (slot-value (second slot)))
             (cond ((and (symbolp slot-name)
                         (or (literalp slot-value)
                             (variablep slot-value)))
                    (if (quotablep slot-value)
                        ``(,',slot-name ,',slot-value)
                      ``(,',slot-name ,,slot-value)))
                   (t
                    (parsing-error
                     "There's a type problem in this slot: ~S." slot))))))
    `(list ,@(mapcar #'normalize slots))))

(defun canonicalize-slot-names (meta-class slots)
  (mapcar #'(lambda (slot)
              `(,(find-meta-slot meta-class (first slot))
                ,(second slot)))
          slots))

(defun parse-and-insert-fact (body)
  (let ((head (first body))
        (slots (rest body)))
    (cond ((symbolp head)
           (let ((meta-class (gensym)))
             `(let ((,meta-class (find-meta-class ',head)))
               (assert-fact (current-engine)
                (make-fact ',head
                 (canonicalize-slot-names
                  ,meta-class (,@(normalize-slots slots))))))))
          (t
           (parsing-error
            "A fact must begin with a symbol: ~S." head)))))

(defun parse-and-modify-fact (fact body)
  (flet ((generate-modify ()
           (let ((meta-class (gensym)))
             `(let ((,meta-class (find-meta-class (fact-name ,fact))))
               (modify-fact (current-engine) ,fact
                (canonicalize-slot-names ,meta-class
                 (,@(normalize-slots body))))))))
    (handler-case
        (generate-modify)
      (lisa-error (condition)
        (command-structure-error 'modify-fact condition)))))

(defun redefine-deftemplate (name body)
  (labels ((extract-slot (slot)
             (cond ((or (not (consp slot))
                        (not (eql (first slot) 'slot))
                        (not (= (length slot) 2)))
                    (parsing-error
                     "This slot has a structural problem: ~S." slot))
                   (t (second slot))))
           (define-template ()
               (create-class-template name (mapcar #'extract-slot body))))
    (handler-case
        (define-template)
      (lisa-error (condition)
        (command-structure-error 'deftemplate condition)))))

(defun redefine-defimport (symbolic-name class-name slot-specs)
  (flet ((check-slot-spec (slot)
           (unless (and (consp slot)
                        (= (length slot) 2)
                        (symbolp (first slot))
                        (symbolp (second slot)))
             (syntactical-error
              'defimport
              "The format of this slot specification is wrong: ~S." slot))))
    (unless (symbolp symbolic-name)
      (syntactical-error 
       'defimport "The symbolic name must be a symbol: ~S." symbolic-name))
    (unless (find-class class-name nil)
      (syntactical-error
       'defimport "The symbol ~S does not identify a class." class-name))
    (if (consp slot-specs)
        (mapc #'check-slot-spec slot-specs)
      (syntactical-error
       'defimport "The slot specification must be a list: ~S."
       slot-specs))
    `(import-class ',symbolic-name ',class-name ',slot-specs)))
             
                       
