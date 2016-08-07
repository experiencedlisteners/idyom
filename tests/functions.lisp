(cl:in-package #:tests)

(defun run-test-suites ()
  (run! '(music-objects
	      viewpoints
	      inference)))

(defun make-approx-eql-test (&optional (threshold (expt 10 -10)))
  (lambda (x y) (< (abs (- x y)) threshold)))

(defun alist-eql (a b &key (test #'eql) (alist-test #'eql))
  (let ((items-a (mapcar #'car a))
	(items-b (mapcar #'car b)))
    (let ((items (union items-a items-b :test alist-test)))
      (every #'identity (mapcar (lambda (item)
		     (let ((value-a (cdr (assoc item a :test alist-test)))
			   (value-b (cdr (assoc item b :test alist-test))))
		       (apply test (list value-a value-b))))
				items)))))

(defun distributions-eql (distrib-a distrib-b &key (test #'eql) (alist-test #'eql))
  (alist-eql distrib-a distrib-b
	     :test (lambda (a b) (apply test (list (car a) (car b))))
	     :alist-test alist-test))

(defun make-event (composition event-index onset pitch bioi duration barlength pulses)
  (let ((timebase (md:timebase composition))
	(midc (md:midc composition))
	(composition-index (md:get-composition-index (md:get-identifier composition)))
    	(dataset-index (md:get-dataset-index (md:get-identifier composition))))
    (make-instance 'md:music-event
		   :id (md:make-event-id dataset-index composition-index event-index)
		   :description "" :dyn nil
		   :midc midc :timebase timebase
		   :onset onset :bioi bioi
		   :duration duration :barlength barlength
		   :pulses pulses :cpitch pitch
		   :mpitch nil :deltast 0
		   :mode nil :accidental 0
		   :keysig nil :phrase -1
		   :voice 1 :ornament nil
		   :comma nil :articulation nil)))

(defun make-event-in-composition (composition  &key (barlength 96) (pulses 4))
  (lambda (&rest args) (apply #'make-event (append (list composition)
						   args
						   (list barlength pulses)))))

(defun make-composition (description dataset-index composition-index
			 duration
			 &key (timebase 96)
			   (midc 80))
  (make-instance 'md:music-composition
		 :id (md:make-composition-id dataset-index composition-index)
		 :onset 0
		 :duration duration
		 :description description
		 :midc midc
		 :timebase timebase))

(defun always-return (val)
  (lambda (&rest args) (declare (ignorable args)) val))

(defun make-event-data-lists (iois pitches &key (phase 0) (durations nil durations-p))
  (let ((biois (append (list phase) iois))
	(durations (if durations-p durations iois))
	(onsets (apply #'utils:cumsum (cons phase iois)))
	(indices (utils:generate-integers 0 (1- (length iois)))))
    (list indices onsets pitches biois durations)))

(defun create-composition (iois pitches &key (timebase 96) (phase 0)
					  barlength pulses)
  (let* ((duration (+ (apply '+ iois) phase))
	 (composition (make-composition "test" 0 0 duration :timebase timebase))
	 (events (apply #'mapcar (append (list (make-event-in-composition composition
									  :barlength barlength
									  :pulses pulses))
					 (make-event-data-lists iois pitches :phase phase)))))
    (sequence:adjust-sequence composition (length events)
			      :initial-contents events)
    composition))
	
