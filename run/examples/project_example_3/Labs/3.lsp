;      11. Сформировать список простых множителей заданного числа.
(defun prime_factors_r (x n)
    (if (> n (/ x 2))
        (list x)
        (if (= (rem x n) 0)
            (cons
                n
                (prime_factors_r (/ x n) n)
            )
            (prime_factors_r x (+ n 1))
        )
    )
)

(defun prime_pre_factors (x)
    (if (= (rem x 2 ) 0 )
        (cons
            2
            (prime_pre_factors (/ x 2))
        )
        (prime_factors_r x 3)
    )
)

(defun prime_factors (x)
    (if (numberp x)
        (cond 
            ((not (INTEGERP x)) nil)
            ((zerop x) nil)
            ((= x 1) nil)
            ((= x -1) '(-1))
            ((not (plusp x)) (cons -1 (prime_pre_factors (- x))))
            (T (prime_pre_factors x))
        )
        nil
    )
)


;      12. Реверсировать  элементы  списка  произвольной структуры на
; всех уровнях.
;       Пример-пояснение:  исходный список -  (A (B C) D (E (F G)))
;                   результирующий список -  (((G F) E) D (C B) A)
 
 (defun reverse_list_r (l)
    (if (null (cdr l))
        (if (listp (car l))
            (list (reverse_list_r (car l)))
            l
        )
        (append 
            (reverse_list_r (cdr l))
            (list 
                (if (listp (car l))
                    (reverse_list_r (car l))
                    (car l)
                )
            )
        )
    )
 )

 (defun reverse_list (l)
    (if (and (not (null l)) (listp l))
        (reverse_list_r l)
        nil
    )
 )


;      13. Линеаризовать список произвольной структуры.
;       Пример-пояснение:   исходный список -  (A (B C) D (E (F G)))
;                   результирующий список -  (A B C D E F G)

(defun linearize_list_r (l)
   (if (null (cdr l))
        (if (listp (car l))
            (linearize_list_r (car l))
            l
        )
        (append
            (if (listp (car l))
                (linearize_list_r (car l))
                (list (car l))
            )
            (linearize_list_r (cdr l))
        )
    )
)

(defun linearize_list (l)
    (if (and (not (null l)) (listp l))
        (linearize_list_r l)
        nil
    )
 )


;      14. Сформировать список, являющийся пересечением двух заданных
; линейных списков.  Повторяющиеся в исходных списках элементы должны
; входить в результирующий список не более одного раза.

(defun linep_r (l)
    (cond 
        ((null l) T)
        ((listp (car l)) nil)
        (T (linep_r (cdr l)))
    )
)

(defun linep (l)
    (if (and (not (null l)) (listp l))
        (linep_r l)
        nil
    )
 )

 (defun merge_line_lists_r (l1 l2)
    (if (null l2)
        l1
        (merge_line_lists_r 
            (if (NULL (member (car l2) l1))
                (append
                    l1
                    (list (car l2))
                )
                l1
            )
            (cdr l2)
        )
    )
 )

(defun merge_line_lists (l1 l2)
    (if (and (linep l1) (linep l2))
        (merge_line_lists_r l1 l2)
        nil
    )
 )

;      15. Сформировать список чисел ряда Фибоначчи (см. задание N 5)
; от первого числа до числа с заданным номером включительно.
(defun fib_next (lst)
    (cons (+ (car lst) (cadr lst)) lst)
)

(defun fibs_r (i n)
    (cond
        ((= i 0) '(0))
        ((= i 1) '(1 0))
        (T
            (fib_next (fibs_r (- i 1) n))
        )
    )
)

(defun fibs (n)
    (if (and (numberp n) (>= n 0))
        (reverse (fibs_r n n))
        nil
    )
)
