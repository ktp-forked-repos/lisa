
(in-package "LISA")

(use-default-engine)

(deftemplate frodo ()
  (slot name)
  (slot has-ring)
  (slot age))

(deftemplate bilbo ()
  (slot name)
  (slot relative)
  (slot age))

(deftemplate gandalf ()
  (slot name)
  (slot age))

(deftemplate saruman ()
  (slot name))

(deftemplate samwise ()
  (slot friend)
  (slot age))

#+ignore
(defrule simple-rule ()
  (frodo (name frodo))
  (bilbo (name bilbo))
  (gandalf (name gandalf) (age 100))
  =>
  (format t "simple-rule fired.~%"))

#+ignore
(defrule variable-rule ()
  (frodo (name ?name))
  (not (gandalf))
  (samwise (friend ?name))
  =>
  )

(defrule test-rule ()
  (frodo (name ?name))
  (samwise (friend ?name) (age ?age))
  (test (eq ?age 100))
  (not (gandalf (age ?age)))
  =>
  )

(defparameter *frodo* (assert (frodo (name frodo))))
(defparameter *bilbo* (assert (bilbo (name bilbo))))
(defparameter *samwise* (assert (samwise (friend frodo) (age 100))))
(defparameter *gandalf* (assert (gandalf (name gandalf) (age 200))))
