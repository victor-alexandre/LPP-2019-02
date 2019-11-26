(define soma
 (lambda (L)
 (if (null? L)
 0
 (+ (car L) (soma (cdr L))))))


(soma '(3 5 0 2 0 7))
(soma '(3 5 1 2 4 7))
;--------------------------------------------------------------------------------------------------

(define contazero
 (lambda (L)
 (if (null? L)
     0
     (if (zero? (car L))
         (+ 1 (contazero (cdr L)))
         (contazero (cdr L))
     )
   )
 )
)

(contazero '(3 5 0 2 0 7 9 0 4))
(contazero '(3 5 1 2 4 7 9 6 4))

;--------------------------------------------------------------------------------------------------
(define fat
  (lambda (n)
    (if (zero? n)
        1
        (* n (fat (- n 1)) )
    )
  )
)

(define soma-fat
 (lambda (n)
 (if (= 1 n)
     1
     (+ (fat n)(soma-fat(- n 1)))
     )
   )
)

(soma-fat 5)
(soma-fat 10) 

;--------------------------------------------------------------------------------------------------
(define concatena
 (lambda (L1 L2)
 (if (null? L1)
    L2
    (cons (car L1) (concatena (cdr L1) L2)))))

(concatena '(a b c d) '())
(concatena '() '(a b c d))
(concatena '(a b c d) '(e f)) 
