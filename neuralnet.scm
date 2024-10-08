
;layers is a list
(define-class (FFNN layers error-obj)
  (layers! (lambda (new-val) (set! layers new-val)))
  (error-func! (lambda (new-val) (set! error-obj new-val)))

  (forward (lambda (X)
             (let ((output X))
               (for-each (lambda (layer)
                           (set! output (layer 'activation-forward output)))
                         layers)
               output)))
               
  (backward (lambda (loss-gradient) 
              (let ((loss-gradient loss-gradient))
                (for-each (lambda (layer)
                            (let ((DA ((layer 'activation) 'activation-function-derivative))
                                  (Z (layer 'Z))
                                  (A-prev (layer 'A-prev))
                                  (weights (layer 'weights))
                                  (biases (layer 'biases)))

                              (set! loss-gradient (matrix-multiply (matrix-map Z DA) loss-gradient))
                              (layer 'dW! (matrix-dot (matrix-transpose A-prev) loss-gradient))
                              (layer 'weights! (matrix-subtract weights (matrix-scalar-multiply (layer 'dW) 0.1)))
                              (layer 'db! (matrix-sum loss-gradient 'rows))
                              (layer 'biases! (matrix-subtract biases (matrix-scalar-multiply (layer 'db) 0.1)))

                              (set! loss-gradient (matrix-dot loss-gradient (matrix-transpose weights)))))
                          (reverse layers)))))

  (train (lambda (dataset epochs)
           (let ((error-function (error-obj 'error-function))
                 (error-function-derivative (error-obj 'error-function-derivative)))
             (for-each (lambda (iterator)
                       (for-each (lambda (data-pair)
                                   (let* ((input (car data-pair))
                                          (target (cdr data-pair))
                                          (predicted (network 'forward (vector input)))
                                          (error (error-function predicted (vector target)))
                                          (delta (error-function-derivative predicted (vector target))))
                                     (network 'backward delta))) 
                                 dataset))    
                       (vector->list (make-vector epochs))))))
  
  )


(define (create-FFNN layers error-func)
  (let* ((network (FFNN)))
    (network 'layers! layers)
    (network 'error-func! error-func)
    network))
