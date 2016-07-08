(cl:in-package #:viewpoints)

(defun calculate-metrical-position (onset interpretation)
  (let ((barlength (md:barlength interpretation))
	(phase (md:interpretation-phase interpretation)))
      (mod (- onset phase) barlength)))

; A derived viewpoint that calculates metrical position under an interpretation as a proportion of the time signature's period
(define-metrical-viewpoint (metrical-onset-position metrical (onset))
    ((events md:melodic-sequence)
     (interpretation md:metrical-interpretation) element)
  :function (let ((onset (onset events)))
	      (calculate-metrical-position onset interpretation)))

(defun calculate-metrical-accent (onset interpretation)
    (let ((pulses (md:pulses interpretation))
	  (barlength (md:barlength interpretation))
	  (phase (md:interpretation-phase interpretation))
	  (timebase (md:timebase interpretation)))
	(+ (metrical-accent-multiple 
	    (- onset phase) pulses barlength timebase)
	   (metrical-accent-division (- onset phase) pulses barlength))))

(define-metrical-viewpoint (metrical-onset-accent metrical (onset))
    ((events md:melodic-sequence) 
     (interpretation md:metrical-interpretation) element)
  :function (let ((event (last events))
		  (onset (onset events)))
              (if (null event) +undefined+
		  (calculate-metrical-accent onset interpretation))))
