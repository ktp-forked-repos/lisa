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

;;; File: sample.lisp
;;; Description: Some simple classes useful in early Lisa testing.

;;; $Id: sample.lisp,v 1.24 2000/12/13 18:02:28 youngde Exp $

(in-package :lisa)

(defclass rocky ()
  ((name :initarg :name
         :initform nil
         :reader get-name)))

(defclass boris ()
  ((name :initarg :name
         :initform nil
         :reader get-name)))

(defclass natasha ()
  ((name :initarg :name
         :initform nil
         :reader get-name)
   (nemesis :initarg :nemesis
            :initform nil
            :reader get-nemesis)))

(defun make-rocky (name)
  (make-instance 'rocky :name name))

(defun make-boris (name)
  (make-instance 'boris :name name))

(defun make-natasha (name nemesis)
  (make-instance 'natasha :name name :nemesis nemesis))

(defimport rocky lisa::rocky)
(defimport boris lisa::boris)
(defimport natasha lisa::natasha)

#+ignore
(defrule nemesis
  (natasha (name "natasha") (nemesis ?nemesis "rocky"))
  (rocky (name ?nemesis))
  =>
  (format t "nemesis fired! Value of ?nemesis is ~S~%" ?nemesis)
  (assert (boris (name ?nemesis))))

#+ignore
(defrule boris
  (?fact (boris (name ?name "rocky")))
  =>
  (format t "boris fired!~%")
  (modify ?fact (name ?name))
  (retract ?fact))

#+ignore
(defrule multiple-references
  (natasha (name ?name "natasha") (nemesis ?name))
  =>
  (format t "multiple-references fired! Value of ?name is ~S~%" ?name))

(defrule schtum
  (?f-1 (rocky (name "rocky")))
  =>
  (format t "schtum fired (?f-1 = ~S).~%" ?f-1)
  (modify ?f-1 (name "boris")))

(defrule rocky-boris
  (?f-1 (rocky (name ?name "boris")))
  =>
  (format t "rocky-boris fired (name =  ~S).~%" ?name)
  (retract ?f-1))

(defrule not-pattern
  (not (rocky (name "rocky")))
  =>
  (format t "not-pattern fired.~%"))

#+ignore
(defrule no-patterns
    =>
  (format t "no-patterns fired!~%"))
