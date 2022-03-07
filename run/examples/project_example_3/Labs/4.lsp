;      16. Посчитать  с  заданной  точностью сумму бесконечного ряда,
; каждый член которого задается формулой:
; X^k   /   k ! , где k изменяется
; от 1 до бесконечности, а значение Х задано.

;применение предиката к каждому элементу листа, если на каком-либо элементе nil - результат nil, иначе T
(defun listp_func (pred lst)
    (if (and (not (null lst)) (listp lst))
        (loop 
            ((null (funcall pred (car lst))) nil)
            ((null (cdr lst)) T)
            (setq lst (cdr lst))
        )
        nil
    )
 )

(defun inf_sum_i (x k result i xk)
    (setq xk x)
    (setq result xk)
    (setq i 1)
    (loop ((= i k) result)
        (incq i)
        (setq xk (* xk (/ x i)))
        (setq result (+ result xk))
    )
)

(defun inf_sum (x k)
   (cond 
        ((not (numberp x)) nil)
        ((not (numberp k)) nil)
        ((not (integerp k)) nil)
        ((not (plusp k)) nil)
        (T (inf_sum_i x k))
   )
)


;      17. Найти последний элемент линейного списка.
(defun last_el_i (lst)
    (loop ((null (cdr lst)) (car lst))
        (setq lst (cdr lst))
    )
)

(defun last_el (lst)
    (if (not (listp_func '(lambda (lst) (not (listp lst))) lst))
        nil
        (last_el_i lst)
    )
)

;      18. Реализовать с помощью LOOP задание N 12 из 1.1.3.

; (     12. Реверсировать  элементы  списка  произвольной структуры на
; всех уровнях.
;       Пример-пояснение:  исходный список -  (A (B C) D (E (F G)))
;                   результирующий список -  (((G F) E) D (C B) A)
; )

(defun reverse_list_i_push_front_result (result pair)
    (list (car pair) (append (list result) (cadr pair)))
)

(defun reverse_list_i (lst result stack)
    (setq result nil)
    (setq stack nil)
    (loop 
        (if (listp (car lst))
            (progn
                (push (list (cdr lst) result) stack)
                (setq result nil)
                (setq lst (car lst))
            )
            (progn
                (setq
                    result
                    (cons (car lst) result)
                )
                (setq lst (cdr lst))
            )
        )

        (
            (and 
                (null lst)
                (if (null stack)
                    T
                    (progn
                        (loop 
                            (setq 
                                lst 
                                (reverse_list_i_push_front_result result (pop stack))
                            )
                            (setq result (cadr lst))
                            (setq lst (car lst))
                            ((or (not (null lst)) (null stack))
                                (and (null stack) (null lst))
                            )
                        )
                    )
                )
            )
            result
        )
    )
)

(defun reverse_list (lst)
    (if (and (listp lst) (not (null lst)))
        (reverse_list_i lst)
        nil
    )
)


;      19. Удалить  из  числового  линейного списка все элементы,  не
; входящие в заданный интервал значений.
(defun remove_over_i (lst a b result)
    (setq result nil)
    (loop ((null lst) result)
        (if (and (>= (car lst) a) (<= (car lst) b))
            (setq result (append result (list (car lst))))
        )
        (setq lst (cdr lst))
    )
)

 (defun remove_over (lst a b)
    (cond 
        ((not (listp_func 'numberp lst)) nil)
        ((not (numberp a)) nil)
        ((not (numberp b)) nil)
        ((> a b) nil)
        (T (remove_over_i lst a b))
    )
 )

;      20. Задан список символьных атомов.  Заменить во  всех  атомах
; заданный символ на другой заданный символ, но не более чем заданное
; число раз вхождений в каждом атоме.
 (defun replace_lst_with_i (lst what val k result)
    (setq result nil)
    (loop ((null lst) result)
        (setq
            result
            (append
                result
                (if (eq (car lst) what)
                    (progn
                        (decq k)
                        (list val)
                    )
                    (list (car lst))
                )
            )
        )
        (if (= k 0)
            (progn
                (setq result (append result (cdr lst)))
                (setq lst nil)
            )
            (setq lst (cdr lst))
        )
    )
 )

(defun replace_with_i (lst what val k result)
    (setq result nil)
    (loop ((null lst) result)
        (setq
                result
                (append
                    result
                    (list (PACK (replace_lst_with_i (UNPACK (car lst)) what val k)))
                )
        )
        (setq lst (cdr lst))
    )
)

(defun replace_with (lst what val k)
    (cond
        ((not (listp_func 'symbolp lst)) nil)
        ((not (symbolp what)) nil)
        ((not (symbolp val)) nil)
        ((not (integerp k) nil))
        ((minusp k) nil)
        ((= k 0) lst)
        (T (replace_with_i lst what val k))
    )
)