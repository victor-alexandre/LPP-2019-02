;respostas slide 13 do slide 2 de scheme
;1)
(cons 
(cons 1 (cons 2 ( cons 3 '())))
(cons 4
(cons 
(cons 5 '())
'())))


;3)
(cons
 
	(cons (cons 1 '()) '()) 

	(cons 2 
		(cons (cons (cons 3 '()) '()) '())
	)

)


;respostas slide 16
(define L '( (1 2 3) ( (a b c) ) @ (m n o) ))
L

;1)
(car (cdr(cdr L)))

;2)
(car (cdr (car L)))

;3)
(cdr (cdr(cdr L)))
;ou equivalentemente 
(cdddr L)

;4)
(car (car (cdr L)))

;5)
(car (cdr (cdr (car (cdddr L)))))
