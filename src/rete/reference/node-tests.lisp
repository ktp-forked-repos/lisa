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

;;; File: node-tests.lisp
;;; Description:

;;; $Id: node-tests.lisp,v 1.7 2002/09/05 01:58:53 youngde Exp $

(in-package "LISA")

(let ((*node-test-table*
       (make-hash-table :test #'equal)))

  (defun find-test (key constructor)
    (let ((test (gethash key *node-test-table*)))
      (when (null test)
        (setf test
          (setf (gethash key *node-test-table*)
            (funcall constructor))))
      test)))

(defun make-class-test (class)
  (find-test class
             #'(lambda ()
                 (function
                  (lambda (token)
                    (eq class (fact-name (token-top-fact token))))))))

(defun make-simple-slot-test (slot-name value)
  (find-test 
   `(,slot-name ,value)
   #'(lambda ()
       (function
        (lambda (token)
          (equal value
                 (get-slot-value
                  (token-top-fact token)
                  slot-name)))))))

(defun make-inter-pattern-test (slot-name binding)
  (function
   (lambda (tokens)
     (equal (get-slot-value (token-top-fact tokens) slot-name)
            (get-slot-value 
             (token-find-fact tokens (binding-address binding))
             (binding-slot-name binding))))))

(defun make-predicate-test (forms bindings)
  (let* ((special-vars
          (mapcar #'binding-variable bindings))
         (body
          (if (consp (first forms)) 
              forms
            (list forms)))
         (predicate
          (compile nil `(lambda ()
                          (declare (special ,@special-vars))
                          ,@body))))
    (function
     (lambda (tokens)
       (progv
           `(,@special-vars)
           `(,@(mapcar #'(lambda (binding)
                           (get-slot-value
                            (token-find-fact 
                             tokens (binding-address binding))
                            (binding-slot-name binding)))
                       bindings))
         (funcall predicate))))))
         
