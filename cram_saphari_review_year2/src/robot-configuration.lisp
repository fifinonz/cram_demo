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

(in-package :cram-saphari-review-year2)

(defvar *arm* nil
  "Variable holding the interface to the Beasty controller of the arm.")
(defvar *collision-fluent* nil
  "Fluent indicating whether a collision was signalled from the arm.")

(defparameter *beasty-action-name* "/BEASTY"
  "ROS name of the Beasty action server for the arm.")
(defparameter *simulation-flag* t
  "Flag indicating whether the LWR is a simulated arm.")
(defparameter *tool-weight* 0.47
  "Weight of the tool mounted to the LWR in kg.")
(defparameter *tool-com* (cl-transforms:make-3d-vector -0.04 -0.04 0.0)
  "Center of mass of tool mounted on the arm.")
(defparameter *arm-tool*
  (make-instance 'beasty-tool :mass *tool-weight* :com *tool-com*)
  "Modelling of tool mounted on LWR.")
(defparameter *gravity-vector* #(0 0 9.81 0 0 0)
  "_NEGATIV_ 6D acceleration vector indicating in which direction gravity is acting on the
  arm. NOTE: Is expressed w.r.t. to the base-frame of the left arm. First translational
 (x,y,z), then rotational (x,y,z) acceleration.")  
(defparameter *arm-base-config*
  (make-instance 'beasty-base :base-acceleration *gravity-vector*)
  "Modelling of mounting of LWR to the table.")
(defparameter *arm-config*
  (make-instance 'beasty-robot 
                 :simulation-flag *simulation-flag* 
                 :tool-configuration *arm-tool* 
                 :base-configuration *arm-base-config*)
  "Modelling of entire initial configuration of the LWR.")

(defun init-arm ()
  "Inits connection to beasty controller of LWR arm."
  (unless *arm* 
    (setf *arm* (make-beasty-interface *beasty-action-name* *arm-config*)))
  (when *arm*
    (setf *collision-fluent* (fl-funcall #'get-strongest-collision (state *arm*)))))

(defun cleanup-arm ()
  "Stops LWR arm, and closes connection to beasty action server."
  (when *arm*
    (cleanup-beasty-interface *arm*)
    (setf *arm* nil))
  (when *collision-fluent*
    (setf *collision-fluent* nil)))