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

;;; File: token.lisp
;;; Description:

;;; $Id: token.lisp,v 1.2 2002/08/27 17:58:06 youngde Exp $

(in-package "LISA")

(defun make-token (fact)
  (let ((token
         (make-array 1 :adjustable t :fill-pointer t)))
    (setf (aref token 0) fact)
    token))

(defun get-fact-from-token (token address)
  (aref token address))

(defun get-top-fact-from-token (token)
  (aref token (1- (length token))))

(defun push-fact-on-token (token fact)
  (vector-push-extend token fact))