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

;;; File: synchronizable.lisp
;;; Description: A mixin that adds synchronization (or mutex) capabilities to
;;; a class.

;;; $Id: synchronizable.lisp,v 1.1 2001/05/09 19:04:33 youngde Exp $

(in-package "LISA")

(defclass synchronizable ()
  ((lock :initform (lmp:make-lock)
         :reader get-lock))
  (:documentation
   "A mixin that adds synchronization (or mutex) capabilities to a class."))

(defmacro with-synchronization ((self) &body body)
  `(lmp:with-lock ((get-lock ,self)) ,@body))
