;;; This file is part of LISA, the Lisp-based Intelligent Software
;;; Agents platform.

;;; Copyright (C) 2000 David E. Young (de.young@computer.org)

;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License
;;; as published by the Free Software Foundation; either version 2
;;; of the License, or (at your option) any later version.

;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.

;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

;;; File: test2-eval.lisp
;;; Description: This class contains a function-call test performed by
;;; two-input nodes.

;;; $Id: test2-eval.lisp,v 1.2 2001/01/08 16:40:05 youngde Exp $

(in-package :lisa)

(defclass test2-eval (test)
  ((predicate :initarg :predicate))
  (:documentation
   "This class contains a function-call test performed by two-input nodes."))

(defmethod do-test ((self test2-eval) left-token right-fact)
  (format t "evaluating test2-eval: ~S~%" (get-predicate self))
  (evaluate (get-predicate self) left-token))

(defmethod equals ((self test2-eval) (obj test2-eval))
  (equals (get-predicate self) (get-predicate obj)))

(defun make-test2-eval (pred)
  (make-instance 'test2-eval :predicate pred))
