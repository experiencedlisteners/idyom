(asdf:defsystem ppm-star
  :name "ppm-star"
  :components 
  ((:file "package")
   (:file "ppm-star" :depends-on ("package"))
   (:file "ppm-io" :depends-on ("package" "ppm-star"))
   (:file "daniel" :depends-on ("package" "ppm-star"))))