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

;;; File: shadow-fact.lisp
;;; Description: This class represents LISA facts that are actually CLOS
;;; instances.

;;; $Id: shadow-fact.lisp,v 1.5 2001/04/18 20:50:54 youngde Exp $

(in-package "LISA")

(defclass shadow-fact (fact)
  ()
  (:documentation
   "This class represents LISA facts that are actually CLOS instances."))

(defmethod initialize-instance :after ((self shadow-fact) &key instance)
  (let ((meta (get-meta-fact self)))
    (maphash #'(lambda (key slot)
                 (declare (ignore key))
                 (if (eq (slot-name-name slot) :object)
                     (initialize-slot-value self slot instance)
                   (set-slot-from-instance self meta instance slot)))
             (get-slots meta))))

(defun set-slot-from-instance (self meta instance slot-name)
  (declare (type shadow-fact self) (type slot-name slot-name))
  (initialize-slot-value
   self slot-name
   (slot-value instance (find-effective-slot meta slot-name))))

(defun instance-of-shadow-fact (self)
  (declare (type shadow-fact self))
  (get-slot-value self (find-meta-slot (get-meta-fact self) :object)))

(defun synchronize-with-instance (self)
  (declare (type shadow-fact self))
  (let ((instance (instance-of-shadow-fact self))
        (meta (get-meta-fact self)))
    (maphash #'(lambda (key slot)
                 (declare (ignore key))
                 (unless (eq (slot-name-name slot) :object)
                   (set-slot-from-instance self meta instance slot)))
             (get-slots meta))
    (values)))

(defmethod set-slot-value :after ((self shadow-fact) slot-name value)
  (let ((meta (get-meta-fact self)))
    (setf (slot-value (instance-of-shadow-fact self)
                      (find-effective-slot meta slot-name))
      value)))

(defun make-shadow-fact (name instance)
  (make-instance 'shadow-fact :name name :instance instance))

