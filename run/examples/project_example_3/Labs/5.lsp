; Часть 1. Реализовать задания N 21 - 25 из 1.1.5.

;    21. Сформировать список,  содержащий номера позиций  элементов
; исходного списка, удовлетворяющих заданному условию.
(defun list_numbersp_func_r (pred lst n)
    (if (null lst)
        nil
        (append 
            (if (funcall pred (car lst))
                (list n)
                nil
            )
            (list_numbersp_func_r pred (cdr lst) (+ n 1))
        )
    )
)

(defun list_numbersp_func (pred lst)
    (if (or (not (listp lst)) (null lst))
        nil
        (list_numbersp_func_r pred lst 0)
    )
)

;      22. Задан линейный числовой список.  Сформировать список  сумм
; подмножеств элементов исходного списка таким образом, что на первом
; месте должна стоять сумма всех элементов списка,  на втором - сумма
; элементов без первого, на третьем - сумма элементов без первых двух
; и т.д.
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

 (defun subset_sum (lst)
    (if (not (listp_func 'numberp lst))
        nil
        (funcall
            'maplist
            '(lambda (lst) (apply '+ lst)) 
            lst
        )
    )
 )

;      23. Удалить из исходного линейного списка все вхождения задан-
; ного элемента.

;некий аналог замыканию
;создаёт s-выражение с лямбдой, которая вызывает переданную в capture функцию с переданными в capture аргументами + аргументами лямбды
(defun capture
    (lambda x
        (list
            'lambda 
            'x 
            (list 
                'apply 
                (list 'quote (car x))
                (list 
                    'append 
                    (list 'quote (cdr x))
                    'x
                )
            )
        )
    )
)

(defun remove_elem (lst elem)
    (if (not (listp_func '(lambda (lst) (not (listp lst))) lst))
        nil
        (mapcan 
            (capture 
                '(lambda (elem list_elem)
                    (if (eq elem list_elem) 
                        nil 
                        (list list_elem)
                    )
                )
                elem
            )
            lst
        )
    )
)

;      24. Оставить  в исходном линейном списке не более одного вхож-
; дения каждого элемента.

(defun remove_duplicates_glob (lst)
    (if (not (listp_func '(lambda (lst) (not (listp lst))) lst))
        nil
        (progn
            (setq remove_duplicates_1_global_parametr nil) 
            (mapc 
                '(lambda (elem)
                    (if (null (member elem remove_duplicates_1_global_parametr))
                        (setq remove_duplicates_1_global_parametr (append remove_duplicates_1_global_parametr (list elem)))
                        nil
                    )
                )
                lst
            )
            remove_duplicates_1_global_parametr
        )
    )
)

(defun remove_duplicates_r (lst)
    (if (null lst)
        nil
        ( 
            (lambda (elem lst)  
                (if (member elem lst) 
                    lst
                    (append lst (list elem))
                )
            )
            (car lst) (remove_duplicates_r (cdr lst))
        )
    )
)

(defun remove_duplicates (lst)
    (if (not (listp_func '(lambda (lst) (not (listp lst))) lst))
        nil
        (reverse (remove_duplicates_r lst))
    )
)


;      25. Даны два исходных списка одинакового размера. Сформировать
; из неравных друг другу элементов с одинаковыми порядковыми номерами
; точечные пары, объединив их в один результирующий список.
(defun not_equal_pairs (l_lst r_lst)
    (cond 
        ((or (null l_lst) (null r_lst)) nil)
        ((not (and (listp l_lst) (listp r_lst))) nil)
        ((not (= (length l_lst) (length r_lst))) nil)
        (T (mapcan '(lambda (elem1 elem2) (if (not(equal elem1 elem2)) (list (cons elem1 elem2)) nil)) l_lst r_lst))
    )
)


; Часть 2.  Входной  файл  на внешнем носителе содержит исходные
; данные в виде множества допустимых в ЛИСП структур данных.  Рассор-
; тировать его  и записать на внешний носитель в виде четырех файлов,
; каждый из которых содержит либо  числовые  атомы,  либо  символьные
; атомы, либо точечные пары, либо списки.

(defun sort_from_i_input (fin s lnums lsymbols ldotpairs llists)
    (setq s nil)
    (setq lnums nil)
    (setq lsymbols nil)
    (setq ldotpairs nil)
    (setq llists nil)
    (open-input-file fin)
    (loop
        (setq s (read fin T 'eof))
        ((equal s 'eof) nil)
        (cond
            ((and (not (null (cdr s))) (not (listp (cdr s)))) (setq ldotpairs (append ldotpairs (list s))))
            ((listp s) (setq llists (append llists (list s))))
            ((numberp s) (setq lnums (append lnums (list s))))
            (T (setq lsymbols (append lsymbols (list s))))
        )
    )
    (close-input-file fin)
    (list lnums lsymbols ldotpairs llists)
)

(defun reverse_write (file s)
    (write s file)
    (terpri 1 file)
)

(defun sort_from_i_write (struct file)
    (open-output-file file)
    (mapc (capture 'reverse_write file) struct)
    (close-output-file file)
)

(defun sort_from_i_output (structs files)
    (mapc 'sort_from_i_write structs files)
)

(defun sort_from_i (fin files)
    (sort_from_i_output (sort_from_i_input fin) files)
)

(defun sort_from (fin fnums fsymbols fdotpairs flists) ; F1,F2-входные файлы,
     (sort_from_i fin (list fnums fsymbols fdotpairs flists))
)

(defun sort_from_to_dir (fin dir)
    (sort_from fin (pack* dir '\\fnums.lsp) (pack* dir '\\fsymbols.lsp) (pack* dir '\\fdotpairs.lsp) (pack* dir '\\flists.lsp))
)

(defun test_ ()
    (sort_from_to_dir 'd:data.lsp 'd:)
)