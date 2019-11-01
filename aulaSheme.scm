;USAR O DR RACKET PARA COMPILAR 

(+ 5 (+ 4 (+ 3(+ 1 2))))
(remainder (+ (* 3 4) (/ 4 2)) 3)
(+ (* 2 5) (sin 3) (cos 12))

;------------------------------------------------------------
(define pi 3.14)
(define raio 24)
(define area (* pi (* raio raio)))
area

;------------------------------------------------------------
(define mais +)
(mais 2 3)

;------------------------------------------------------------
(define a 4)
(define b -12)
(define c 3)
(define delta (- (* b b) (* 4 a c)))
(define raiz (/ (+ (- b) (sqrt delta)) (* 2 a)))
raiz

;------------------------------------------------
(let ((altura 12) (largura 20)) (* altura largura))

;------------------------------------------------
(let ((altura 12)) (let ((largura (* 20 altura))) (* altura largura)))

;------------------------------------------
(let ((pi 3.14)(raio 24))(let ((area (* 4 pi raio raio))) (/ (* area raio) 3)))
