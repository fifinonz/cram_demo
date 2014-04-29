;;; Copyright (c) 2014, Georg Bartels <georg.bartels@cs.uni-bremen.de>
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;;
;;; * Redistributions of source code must retain the above copyright
;;; notice, this list of conditions and the following disclaimer.
;;; * Redistributions in binary form must reproduce the above copyright
;;; notice, this list of conditions and the following disclaimer in the
;;; documentation and/or other materials provided with the distribution.
;;; * Neither the name of the Institute for Artificial Intelligence/
;;; Universitaet Bremen nor the names of its contributors may be used to
;;; endorse or promote products derived from this software without specific
;;; prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(in-package :controller-experiments)

(defmethod add-associations ((description hash-table) &rest rest)
  (when (/= (rem (length rest) 2) 0)
    (error "You called add-associations with an odd number of rest-arguments."))
  (if (= (length rest) 0)
      description
      (destructuring-bind (key value &rest remainder) rest
        (setf (gethash key description) value)
        (apply #'add-associations description remainder))))

(defmethod remove-associations ((description hash-table) &rest rest)
  (if (= (length rest) 0)
      description
      (destructuring-bind (key &rest remainder) rest
        (remhash key description)
        (apply #'remove-associations description remainder))))

(defmethod find-association ((description hash-table) key)
  (gethash key description))

(defmethod get-association ((description hash-table) key)
  (multiple-value-bind (value value-present-p) (find-association description key)
    (declare (ignore value-present-p))
    value))

(defmethod contains-association-p ((description hash-table) key)
  (multiple-value-bind (value value-present-p) (find-association description key)
    (declare (ignore value))
    value-present-p))

;;;
;;; GENERIC SETUP OF HASHED CONTROLLER CONFIGURATIONS
;;;
;;; The idea is to provide a configuration with a hash-table inside
;;; which fully specifies which controller to create and with which
;;; values to fill it. My intention is to instantiate controllers at
;;; runtime from data without a need to directly depending on the lib.
;;;
;;; EXAMPLE: P-CONTROLLER
;;;   Hash-table in slot 'content' is expected to have the following
;;;   key-value pairs:
;;;     :controller-name --> "P-CONTROLLER"
;;;     :package-name --> "CL-ROBOT-CONTROLLERS"
;;;     :p-gain --> 2.5
;;;
;;;   Calling make-controller with such a configuration `config'
;;;   and specifying that the controller-type is :unknown:
;;;     CL-USER > (make-controller config :unknown)
;;;     CL-USER > #<P-CONTROLLER {...}>
;;;