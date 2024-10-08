(#%require (only racket random error format current-milliseconds))

(define (make-matrix m n init)
  (let ((outer-vector (make-vector m)))
    (do ((i 0 (+ i 1))) ((= i m) outer-vector)
      (vector-set! outer-vector i
                    (let ((inner-vector (make-vector n)))
                      (do ((j 0 (+ j 1))) ((= j n) inner-vector)
                        (vector-set! inner-vector j (init))))))))

(define (print-vector v max-len)
  (let ((len (vector-length v)))
    (cond
      ((<= len max-len)
       (display v))
      (else
       (let loop ((i 0))
         (when (< i (quotient max-len 2))
           (display (decimal-round (vector-ref v i) 2))
           (display " ")
           (loop (+ i 1))))
       (display "... ")
       (let loop ((i (- len (quotient max-len 2))))
         (when (< i (- len 1))
           (display (decimal-round (vector-ref v i) 2))
           (display " ")
           (loop (+ i 1))))
       (display (decimal-round (vector-ref v (- (vector-length v) 1)) 2))))))

(define (print-matrix v . max-len)
  (let* ((m (vector-length v))
         (default-max-len 10)
         (max-len (if (null? max-len) default-max-len (* (car max-len) 2))))
    (display "matrix")
    (newline)
    (cond
      ((<= m max-len)
       (do ((i 0 (+ i 1)))
         ((= i m))
         (print-vector (vector-ref v i) max-len)
         (newline)))
      (else
       (do ((i 0 (+ i 1)))
         ((= i (quotient max-len 2)))
         (print-vector (vector-ref v i) max-len)
         (newline))
       (display "...\n")
       (do ((i (- m (quotient max-len 2)) (+ i 1)))
         ((= i m))
         (print-vector (vector-ref v i) max-len)
         (newline))))
    (display "Dimensions: ")
    (display m)
    (display "x")
    (display (if (> 0 m) 0 (vector-length (vector-ref v 0))))
    (newline)))


(define (matrix-ref matrix i j)
  (vector-ref (vector-ref matrix i) j))

(define (matrix-set! matrix i j value)
  (vector-set! (vector-ref matrix i) j value))


(define (matrix-dot a b)
  (let* ((rows-a (vector-length a))
         (cols-a (vector-length (vector-ref a 0)))
         (rows-b (vector-length b))
         (cols-b (vector-length (vector-ref b 0))))
    (if (not (= cols-a rows-b))
        (error (format "Incompatible dimensions for matrix dot. Matrix A: ~a x ~a, Matrix B: ~a x ~a" rows-a cols-a rows-b cols-b))
        (let ((result (make-matrix rows-a cols-b (lambda () 0))))
          (do ((i 0 (+ i 1))) ((= i rows-a))
            (do ((j 0 (+ j 1))) ((= j cols-b))
              (let ((sum 0))
                (do ((k 0 (+ k 1))) ((= k cols-a))
                  (set! sum (+ sum (* (matrix-ref a i k) (matrix-ref b k j)))))
                (matrix-set! result i j sum))))
          result))))

(define (matrix-transpose m)
  (let* ((rows (vector-length m))
         (cols (vector-length (vector-ref m 0))))
    (let ((transposed (make-matrix cols rows (lambda () 0))))
      (do ((i 0 (+ i 1))) ((= i rows))
        (do ((j 0 (+ j 1))) ((= j cols))
          (matrix-set! transposed j i (matrix-ref m i j))))
      transposed)))

(define (matrix-sum m axis)
  (let* ((rows (vector-length m))
         (cols (vector-length (vector-ref m 0))))
    (cond ((equal? axis 'rows)
           (let ((sums (make-matrix 1 cols (lambda () 0))))
             (do ((j 0 (+ j 1))) ((= j cols))
               (do ((i 0 (+ i 1))) ((= i rows))
                 (matrix-set! sums 0 j (+ (matrix-ref sums 0 j) (matrix-ref m i j)))))
             sums))
          ((equal? axis 'cols)
           (let ((sums (make-matrix rows 1 (lambda () 0))))
             (do ((i 0 (+ i 1))) ((= i rows))
               (do ((j 0 (+ j 1))) ((= j cols))
                 (matrix-set! sums i 0 (+ (matrix-ref sums i 0) (matrix-ref m i j)))))
             sums))
          (else
           (error "Invalid axis. Must be 'rows' or 'cols'.")))))






(define (matrix-multiply a b)
  (let* ((rows-a (vector-length a))
         (cols-a (vector-length (vector-ref a 0)))
         (rows-b (vector-length b))
         (cols-b (vector-length (vector-ref b 0))))
    (if (not (and (= rows-a rows-b) (= cols-a cols-b)))
        (error (format "Incompatible dimensions for matrix multiplication. Matrix A: ~a x ~a, Matrix B: ~a x ~a" rows-a cols-a rows-b cols-b))
        (let ((result (make-matrix rows-a cols-a (lambda () 0))))
          (do ((i 0 (+ i 1))) ((= i rows-a))
            (do ((j 0 (+ j 1))) ((= j cols-a))
              (matrix-set! result i j (* (matrix-ref a i j) (matrix-ref b i j)))))
          result))))

(define (matrix-scalar-multiply m k)
  (let* ((rows (vector-length m))
         (cols (vector-length (vector-ref m 0)))
         (result (make-matrix rows cols (lambda () 0))))
    (do ((i 0 (+ i 1))) ((= i rows))
      (do ((j 0 (+ j 1))) ((= j cols))
        (matrix-set! result i j (* k (matrix-ref m i j)))))
    result))


(define (matrix-map matrix func)
  (let* ((rows (vector-length matrix))
         (cols (vector-length (vector-ref matrix 0)))
         (result (make-matrix rows cols (lambda () 0))))
    (do ((i 0 (+ i 1))) ((= i rows))
      (do ((j 0 (+ j 1))) ((= j cols))
        (matrix-set! result i j (func (matrix-ref matrix i j)))))
    result))



(define (matrix-add a b)
  (let* ((rows (vector-length a))
         (cols (vector-length (vector-ref a 0)))
         (result (make-matrix rows cols (lambda () 0))))
    (do ((i 0 (+ i 1))) ((= i rows))
      (do ((j 0 (+ j 1))) ((= j cols))
        (matrix-set! result i j (+ (matrix-ref a i j) (matrix-ref b i j)))))
    result))

(define (matrix-subtract a b)
  (let* ((rows (vector-length a))
         (cols (vector-length (vector-ref a 0)))
         (result (make-matrix rows cols (lambda () 0))))
    (do ((i 0 (+ i 1))) ((= i rows))
      (do ((j 0 (+ j 1))) ((= j cols))
        (matrix-set! result i j (- (matrix-ref a i j) (matrix-ref b i j)))))
    result))

(define (strassen-matrix-dot a b)
  (let* ((n (vector-length a)))
    (if (<= n 2)
        (matrix-dot a b) ; Use naive multiplication for small matrices
        (let* ((mid (/ n 2))
               (a11 (matrix-sub a 0 0 mid mid))
               (a12 (matrix-sub a 0 mid mid n))
               (a21 (matrix-sub a mid 0 n mid))
               (a22 (matrix-sub a mid mid n n))
               (b11 (matrix-sub b 0 0 mid mid))
               (b12 (matrix-sub b 0 mid mid n))
               (b21 (matrix-sub b mid 0 n mid))
               (b22 (matrix-sub b mid mid n n))
               (m1 (strassen-matrix-multiply (matrix-add a11 a22) (matrix-add b11 b22)))
               (m2 (strassen-matrix-multiply (matrix-add a21 a22) b11))
               (m3 (strassen-matrix-multiply a11 (matrix-subtract b12 b22)))
               (m4 (strassen-matrix-multiply a22 (matrix-subtract b21 b11)))
               (m5 (strassen-matrix-multiply (matrix-add a11 a12) b22))
               (m6 (strassen-matrix-multiply (matrix-subtract a21 a11) (matrix-add b11 b12)))
               (m7 (strassen-matrix-multiply (matrix-subtract a12 a22) (matrix-add b21 b22)))
               (c11 (matrix-add (matrix-subtract (matrix-add m1 m4) m5) m7))
               (c12 (matrix-add m3 m5))
               (c21 (matrix-add m2 m4))
               (c22 (matrix-add (matrix-subtract (matrix-add m1 m3) m2) m6))
               (result (make-matrix n n (lambda () 0))))
          (matrix-set-sub! result 0 0 mid mid c11)
          (matrix-set-sub! result 0 mid mid n c12)
          (matrix-set-sub! result mid 0 n mid c21)
          (matrix-set-sub! result mid mid n n c22)
          result))))

; Helper function to get a submatrix
(define (matrix-sub m start-row start-col end-row end-col)
  (let* ((rows (- end-row start-row))
         (cols (- end-col start-col))
         (result (make-matrix rows cols (lambda () 0))))
    (do ((i 0 (+ i 1))) ((= i rows))
      (do ((j 0 (+ j 1))) ((= j cols))
        (matrix-set! result i j (matrix-ref m (+ i start-row) (+ j start-col)))))
    result))

; Helper function to set a submatrix
(define (matrix-set-sub! m start-row start-col end-row end-col submatrix)
  (let* ((rows (- end-row start-row))
         (cols (- end-col start-col)))
    (do ((i 0 (+ i 1))) ((= i rows))
      (do ((j 0 (+ j 1))) ((= j cols))
        (matrix-set! m (+ i start-row) (+ j start-col) (matrix-ref submatrix i j)))))
  m)


(define (block-matrix-multiply a b block-size)
  (let* ((n (vector-length a))
         (result (make-matrix n n (lambda () 0))))
    (do ((i 0 (+ i block-size))) ((>= i n))
      (do ((j 0 (+ j block-size))) ((>= j n))
        (do ((k 0 (+ k block-size))) ((>= k n))
          (let* ((i-end (min (+ i block-size) n))
                 (j-end (min (+ j block-size) n))
                 (k-end (min (+ k block-size) n)))
            (do ((ii i (+ ii 1))) ((= ii i-end))
              (do ((jj j (+ jj 1))) ((= jj j-end))
                (do ((kk k (+ kk 1))) ((= kk k-end))
                  (matrix-set! result ii jj (+ (matrix-ref result ii jj)
                                               (* (matrix-ref a ii kk) (matrix-ref b kk jj)))))))))))
    result))


(define (generate-matrix size)
  (let ((m (make-matrix size size (lambda () 0))))
    (do ((i 0 (+ i 1))) ((= i size))
      (do ((j 0 (+ j 1))) ((= j size))
        (matrix-set! m i j (random))))
    m))

(define (benchmark-matrix-multiply size)
  (let ((a (generate-matrix size))
        (b (generate-matrix size)))
    (let ((start (current-milliseconds)))
      (matrix-dot a b)
      (let ((end (current-milliseconds)))
        (- end start)))))

(define (benchmark-strassen-multiply size)
  (let ((a (generate-matrix size))
        (b (generate-matrix size)))
    (let ((start (current-milliseconds)))
      (strassen-matrix-multiply a b)
      (let ((end (current-milliseconds)))
        (- end start)))))

(define (benchmark-block-multiply size)
  (let ((a (generate-matrix size))
        (b (generate-matrix size)))
    (let ((start (current-milliseconds)))
      (block-matrix-multiply a b 16)
      (let ((end (current-milliseconds)))
        (- end start)))))

(define (run-benchmarks sizes)
  (for-each
   (lambda (size)
     (let ((naive-time (benchmark-matrix-multiply size))
           (strassen-time (benchmark-strassen-multiply size))
           (block-time (benchmark-block-multiply size)))
       (display "size :")
       (display size)
       (newline)
       (display "naive-time :")
       (display naive-time)
       (newline)
       (display "strassen-time :")
       (display strassen-time)
       (newline)
       (display "block-time :")
       (display block-time)
       (newline)))
   sizes))



