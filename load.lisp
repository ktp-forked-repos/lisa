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

;;; File: load
;;; Description: Simple-minded loader for use in early development.

;;; $Id: load.lisp,v 1.3 2000/11/07 01:57:49 youngde Exp $

(in-package "USER")

(defvar *lisa-root-pathname*
  (make-pathname :directory
                 (pathname-directory
                  (merge-pathnames *load-truename*
                                   *default-pathname-defaults*))))

(defvar *lisa-source-pathname*
  (make-pathname :directory
                 (append (pathname-directory *lisa-root-pathname*)
                         '("src"))))

(let ((files
       '("packages/pkgdecl" "utils/utils" "utils/compose"
         "engine/macros" "engine/rete" "engine/rete-compiler"
         "engine/fact" "engine/token" "engine/add-token"
         "engine/clear-token" "engine/node"
         "engine/node1" "engine/node1-tect"
         "engine/node1-teq" "engine/node1-rtl"
         "engine/node-test" "engine/node2"
         "engine/test1" "engine/factories"
         "engine/generic-pattern" "engine/defrule"
         "engine/parser" "engine/language")))
  (dolist (file files)
    (load (concatenate 'string
            (directory-namestring *lisa-source-pathname*)
            file))))