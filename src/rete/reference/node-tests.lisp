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

;;; $Id: node-tests.lisp,v 1.3 2002/09/03 15:48:11 youngde Exp $

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
                    (eq class (fact-name (token-fact token))))))))

(defun make-simple-slot-test (slot-name value)
  (find-test 
   `(,slot-name ,value)
   #'(lambda ()
       (function
        (lambda (token)
          (equal value
                 (get-slot-value
                  (token-fact token)
                  slot-name)))))))

(defun make-inter-pattern-test (slot-name binding)
  (function
   (lambda (token)
     (equal (get-slot-value (token-fact token) slot-name)
            (get-slot-value 
             (token-find-fact token (binding-address binding))
             (binding-slot-name binding))))))
