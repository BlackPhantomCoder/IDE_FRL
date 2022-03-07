; (defun l_n (lst n)
;     (cond 
;         ((= n 1) 
;             (car lst)
;         )
;         (T 
;             (l_n (cdr lst) (- n 1))
;         )
;     )
; )

(defun max (x y)
    (if (> x y)
        x
        y
    )
)


;   6. Определить  предикат,  распознающий списки,  имеющие четное
; (нечетное) количество элементов.
(defun l_count (lst)
    (cond 
        ((NULL lst)
            0
        )
        (T 
            (+ (l_count (cdr lst)) 1)
        )
    )
)

;чет
(defun l_ch (lst)
    (= (mod (l_count lst) 2) 0)
)

;нечет
(defun l_nch (lst)
    (= (mod (l_count lst) 2) 1)
)


;      7. Подсчитать сумму всех числовых атомов в списке произвольной структуры.
(defun count_l (lst)
    (if (NULL lst)
        0
        (if (NUMBERP (car lst))
            (+ (car lst) (count_l (cdr lst)))
            (+
                (if (LISTP (car lst))
                    (count_l (car lst))
                    0
                )
                (count_l (cdr lst))
            )
        )
    )
)


;      8. Определить  максимальную глубину списка произвольной структуры.
(defun max_deep_l (lst)
    (if (NULL lst)
        0
        (max
            (if (LISTP (car lst))
                (+ (max_deep_l (car lst)) 1)
                1
            )
            (max_deep_l (cdr lst))
        )
    )
)

(defun test_max_deep_l ()
    (print "lst :")
    (print (SETQ lst '(1 (2 (3 (4 (5)))) 6 7 (a (b c(e f k) d)))))
    (max_deep_l lst)
)


;      9. Найти  максимальный  элемент в числовом списке произвольной структуры.
(defun l_max_el (lst)
    (if (NULL lst)
        Nil
        (cond 
            ((NULL (car lst))
                (l_max_el (cdr lst))
            )
            ((NULL (cdr lst))
                (if (LISTP (car lst))
                    (l_max_el (car lst))
                    (car lst)
                )
            )
            (T 
                (max
                    (if (LISTP (car lst))
                        (l_max_el (car lst))
                        (car lst)
                    )
                    (l_max_el (cdr lst))
                )
            )
        )
    )
)

(defun test_l_max_el ()
    (print "lst :")
    (print (SETQ lst '(1 (2 (3 (4 (5)))) 6 7 (100 (500 -1 (-500 900 6) -10000000)))))
    (print (l_max_el lst))

    (print "lst 2:")
    (print (SETQ lst '(-1 (-2 (-3 (-4 (-5)))) -6 -7 (-100 (-500 1 (500 -900 -6) 10000000)))))
    (l_max_el lst)
)


;      10. Написать  функцию,  выполняющую  вычисление арифметических
; выражений, заданных в виде списка. Используемые операции - умножить
; (*), разделить (/), сложить (+), вычесть (-). При вычислении учиты-
; вать приоритет операций и скобочные выражения.
;       Пример-пояснение: (eval-expr '(4 + (-2 + 4) * 3)) => 10
(defun atom_or_solve (a)
    (if (LISTP a)
        (eval-expr a)
        a
    )
)

(defun solve_part_two (l_arg op r_arg)
    (cond 
        ( (eq op +) (+ (atom_or_solve l_arg) (atom_or_solve r_arg)))
        ( (eq op -) (- (atom_or_solve l_arg) (atom_or_solve r_arg)))
        ( (eq op *) (* (atom_or_solve l_arg) (atom_or_solve r_arg)))
        ( T         (/ (atom_or_solve l_arg) (atom_or_solve r_arg)))
    )
)


(defun solve_part_one (first_arg right)
    (if (NULL right)
        first_arg
        (if 
            (or 
                (eq (car right) +) 
                (eq (car right) -)
            )
            (solve_part_two first_arg (car right) (cdr right))
            (solve_part_one
                (solve_part_two first_arg (car right) (cadr right))
                (cddr right)
            )
        )
    )
)

(defun eval-expr (equation)
    (if (NULL equation) 
        nil
        (if (NULL (cdr equation))
            (if (LISTP (car equation))
                (solve (car equation))
                (car equation)
            )
            (solve_part_one (car equation) (cdr equation))
        )
    )
)

(defun test_solve ()
    (print "equation 1:")
    (print (SETQ equation '(16 / 2 / 2 / 2 / 2 + (1 * 2 * 3 * 4 * 5) - 121)))
    (print (eval-expr equation))

    (print "equation 2:")
    (print  (SETQ equation '(((((((1) + 1) + 1) + 1) + 1) + 1) + 1)))
    (eval-expr equation)
)