
;Exercícios do slide 3 de scheme

(define area (lambda (altura baseMaior baseMenor)(/ (* altura (+ baseMaior baseMenor))2)))
(area 2 4 6)

;---------------------------------------------------------------------------------------------------------------------------

(define delta (lambda (a b c)(- (* b b) (* 4 a c))))
(delta 1 4 4)

(define raizPos (lambda (a b c) (/ (+ (- b) (sqrt(delta a b c)) (* 2 a)))))
(define raizNeg (lambda (a b c) (/ (- (- b) (sqrt(delta a b c)) (* 2 a)))))
(raizPos 1 4 4)

;---------------------------------------------------------------------------------------------------------------------------

(define media (lambda (a b c) (cond
                                ((>= (/ (+ a b c) 3) 6) "Aprovado")
                                ((>= (/ (+ a b c) 3) 4) "Reforço")
                                ((< (/ (+ a b c) 3) 4) "Reprovado")
                                )
                ))

(define media2 (lambda (a b c) (if (>= (/ (+ a b c) 3) 6) "Aprovado") (if (>= (/ (+ a b c) 3) 4) "Reforço" "Reprovado") ))

(media2 2 4 4)

(media 2 4 4)

(define mediaProf (lambda (a b c) (/ (+ a b c) 3)))

(define selecao (lambda (a b c)
                  (if (>= (mediaProf a b c) 6) "Aprovado")
                      (if (>= (mediaProf a b c) 4) "Reforço" "Reprovado")
                   ))
(selecao 2 4 4)

;---------------------------------------------------------------------------------------------------------------------------

(define terceiro (lambda (L) (car (cdr (cdr L)))))

(terceiro '(a b c d e))

(define soma4 (lambda (L) (+ (cadddr L)(caddr L)(cadr L)(car L) )))

(soma4 '(4 5 1 3 4 5 6 2 8 7))

;---------------------------------------------------------------------------------------------------------------------------

(define insere (lambda (n L) ( cons (car L)(cons n (cdddr L)))))

(insere 8 '(a b c d e f g))
;---------------------------------------------------------------------------------------------------------------------------


;------------------------------------------------------
;PARA USAR O CODIGO ABAIXO TEM QUE MUDAR A LINGUAGEM DO RACKET PARA O SOURCE. Isso é por causa das funções map e filter

#lang racket

(define aprovados (lambda (L) (>= (cadr L) 6)))

(define Alunos '(("A" 6.0)("B" 2.5)("C" 3.5)("D" 8)))

(define segundo (lambda(L)(car L)))

(map segundo (filter aprovados Alunos))
