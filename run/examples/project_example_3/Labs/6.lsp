;      26. Извлечь из ассоциативного списка элементы,  ключи  которых
; удовлетворяют заданным условиям.

;lambda x  ; x == (fnc args) ;-> (lambda x (apply 'fnc (append args x))
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

;func (fnc1 fnc2) -> (lambda x 
;                       (if (null x)
;                           (funcall 'fnc1 (funcall 'fnc2))
;                           (funcall 'fnc2 (apply 'fnc2 x))
;                        )
;                     )
(defun func (fnc1 fnc2)
    (list 'lambda 'x
        (list 'if '(null x)
            (list 'funcall (list 'quote fnc1) (list 'funcall (list 'quote fnc2)))
            (list 'funcall (list 'quote fnc1) (list 'apply (list 'quote fnc2) 'x))
        )
    )
)

; (null(x)) ? nil : (list (x))
(defun list_or_nil (x)
    (if (null x) nil (list x))
)

; (pred(car(elem))) ? elem : nil
(defun pred_car (pred elem)
    (if (funcall pred (car elem)) elem nil)
)

(defun dotpairp (pair)
    (if (not (listp pair))
        nil
        (not (listp (cdr pair)))
    )
)

;(lst = nil) -> true
(defun alistp (lst)
    (reduce 'and (mapcar 'dotpairp lst) T)
)

(defun extract_by (lst pred)
    (if (or (null lst) (not (alistp lst)))
        nil
        (mapcan (func 'list_or_nil (capture 'pred_car pred)) lst)
    )
)

(defun test_ ()
    (put 'my_pl 'a 'b)
    (put 'my_pl 'b 'c)
    (put 'my_pl 'd 'e)
    (put 'my_pl 'f 'd)
    (put 'my_pl '1 '2)
    (cdr my_pl)
)

(defun test_2 ()
    (flag 'my_pl2 'a)
    (flag 'my_pl2 'b)
    (flag 'my_pl2 'd)
    (flag 'my_pl2 'f)
    (flag 'my_pl2 '1)
    (cdr my_pl2)
)

(defun test_extract ()
    (test_ )
    (extract_by (cdr 'my_pl) 'symbolp)
)

;      27. Исходный список содержит имена  объектов,  списки  свойств
; которых содержат некоторую информацию.  Определить для каждого объ-
; екта количество пар <ключ-значение>.

(defun bool_to_num (bool) 
    (if (null bool) 0 1)
)

(defun prop_count (elem)
    (if (null (cdr elem))
        0
        (apply '+ (mapcar (func 'bool_to_num 'dotpairp) (cdr elem)))
    )
)

(defun prop_count_lst (lst)
    (cond 
        ( (not (listp lst)) nil)
        ( (null lst) nil)
        ( (not (apply 'and (mapcar 'symbolp lst))) nil)
        (T (mapcar 'prop_count lst))
    )
)

(defun test_prop_count_lst ()
    (put 'a '1 a1)

    (put 'b '1 b1)
    (put 'b '2 b)

    (put 'c '1 c1)
    (put 'c '2 c1)
    (put 'c '3 c3)
)

;      28. Исходный список содержит имена  объектов,  списки  свойств
; которых содержат некоторую информацию. Другой список содержит неко-
; торое количество ( больше 1 ) флагов. Сформировать список объектов,
; содержащих не менее двух флагов из заданного списка.

(defun find_2_or_gr_flag_i (lst props c)
    (setq c 0)
    (loop 
        ((null props) nil)
        ((= 2 c) nil)
        (if (member (car props) lst)  
            (incq c)
        )
        (setq props (cdr props))
    )
    (= 2 c)
)

(defun pred_cdr (pred elem)
    (if (funcall pred (cdr elem)) elem nil)
)

(defun find_2_or_gr_flag (symbols lst)
    (cond 
        ( (not (listp lst)) nil)
        ( (null lst) nil)
        ( (null (cdr lst)) nil)
        ( (not (apply 'and (mapcar 'atom lst))) nil)
        ( (not (apply 'and (mapcar 'symbolp symbols))) nil)
        (T 
            ; list_or_nil(pred_cdr ( find_2_or_gr_flag_i(lst, x) , x))
            (mapcan 
                (func 
                    'list_or_nil
                    (capture 
                        'pred_cdr
                        (capture 'find_2_or_gr_flag_i lst)
                    )
                ) 
                symbols
            )
        )
    )
)

(defun test_find_2_or_gr_flag ()
    (flag 'a '1)

    (flag 'b '1 )
    (flag 'b '2)

    (flag 'c '1 )
    (flag 'c '2 )
    (flag 'c '3 )

    (print (list 'a_b_c_d_1_2: (find_2_or_gr_flag '(a b c d) '(1 2))))
)
;      29. Пусть в списке свойств атома может быть специальное свойс-
; тво с ключом ISA,  значение которого является именем другого списка
; свойств, называемого списком-прототипом, из которого могут наследо-
; ваться недостающие свойства.  Написать функцию  (GET-ISA  <имя списка
;  свойств>  <имя  свойства> ),  которая  в  случае отсутствия искомого
; свойства в исходном списке выдает значение первого найденного тако-
; го же свойства среди всех ISA-прототипов данного списка свойств.

(defun find_prop_w_isa (symb prop)
    (if (get symb prop)
        (get symb prop)
        (if (get symb 'ISA)
            (find_prop_w_isa (get symb 'ISA) prop)
            nil
        )
    )
)

(defun GET-ISA (symb prop)
    (cond 
        ( (not (atom prop)) nil)
        ( (not (symbolp symb)) nil)
        (T 
            (find_prop_w_isa symb prop)
        )
    )
)

(defun test_get ()
    (put 'a 'a_prop a1)

    (put 'b 'b_prop b1)
    (put 'b 'isa a)

    (put 'c 'c_prop c1)
    (put 'c 'isa d)
    (put 'c 'isa b)

    (print (list 'a_b_c_d_1_2: (find_2_or_gr_flag '(a b c d) '(1 2))))
)
;      30. На  складе имеется несколько видов продукции.  Ассортимент
; каждого вида продукции представлен также несколькими  наименования-
; ми. Задать информацию о имеющихся на складе товарах и их количестве
; с помощью списков свойств. Определить функции, позволяющие получать
; информацию о  наличии  некоторого товара на складе и корректирующие
; информацию о наличии при завозе и вывозе заданного количества това-
; ра.
(defun pred_ (pred elem)
    (if (funcall pred elem) elem nil)
)

(defun props_to_list (props)
    (mapcar '(lambda (prop) (car prop)) props)
)

;Виды
(defun types (storage)
    (cond 
        ((not (symbolp storage))  nil)
        ; list_or_nil (pred_ ( not ( listp (x) ),  x) )
        (T (mapcan (func 'list_or_nil (capture pred_ (func 'not 'listp))) (cdr storage)))
    )
)

;Добавить вид
(defun add_type (storage type_)
     (cond 
        ((not (symbolp storage))  nil)
        ((not (symbolp type_))  nil)
        (T (flag storage type_))
     )
)

;Удалить вид
(defun del_type (storage type_)
     (cond 
        ((not (symbolp storage))  nil)
        ((not (symbolp type_))  nil)
        (T 
            (if (flagp storage type_)
                (loop 
                    (
                        (null (remprop type_ (caadr type_)))
                        nil
                    )
                )
            )
            (remflag storage type_)
        )
     )
)

;Список товаров вида
(defun products (storage type_)
    (cond 
        ((not (symbolp storage))  nil)
        ((not (symbolp type_))  nil)
        ((null (flagp storage type_)) nil)
        (T (props_to_list (cdr type_)))
    )
)

(defun product_count_i (types product buf result)
    (setq buf nil)
    (setq result nil)
    (loop
        (setq result (get (car types) product))
        (setq types (cdr types))
        ((not (null result)) result)
        ((null types) nil)
    )
    result
)

;К-во товаров
(defun product_count (storage type_ product)
    (cond 
        ((not (symbolp storage))  nil)
        ((not (symbolp type_))  nil)
        ((not (symbolp product))  nil)
        ((null (flagp storage type_)) nil)
        (T (get type_ product))
    )
)

;Добавить товаров 
(defun add_product (storage type_ product c)
    (cond 
        ((not (symbolp storage))  nil)
        ((not (symbolp type_))  nil)
        ((not (symbolp product))  nil)
        ((not (or (plusp c) (zerop c)))  nil)
        ((flagp storage type_)
            (put
                type_ 
                product 
                (if (get type_ product) (+ (get type_ product) c) c)
            )
        )
        (T
            (flag storage type_)
            (put type_ product c)
        )
    )
)

;Убавить товаров 
(defun dec_product (storage type_ product c)
   (cond 
        ((not (symbolp storage))  nil)
        ((not (symbolp type_))  nil)
        ((not (symbolp product))  nil)
        ((not (or (plusp c) (zerop c)))  nil)
        ((not (flagp storage type_)) nil)
        ((not (get type_ product)) nil)
        ( (> c (get type_ product)) nil)
        (T
            (put
                type_
                product
                (if (get type_ product) 
                    (- (get type_ product) c)
                    c
                )
            )
        )
    )
)

;Удалить товар 
(defun del_product (storage type_ product)
    (cond
        ((not (symbolp storage))  nil)
        ((not (symbolp type_))  nil)
        ((not (flag storage type_))  nil)
        ((not (symbolp product))  nil)
        (T (remprop type_ product))
    )
)


(defun test_4 ()
    (print (test_3 ))
    (del_type 'my_pl3 'table)
    (print (types 'my_pl3))
    (print (products 'my_pl3 'table))
)

(defun test_3 ()
    (flag 'my_pl3 'carpet)
    (flag 'my_pl3 'table)
    (flag 'my_pl3 'tool)

    (put 'carpet 'ordinary 1)

    (put 'table 'wood 2)
    (put 'table 'stone 100)

    (put 'tool 'axe 3)
    (put 'tool 'pickaxe 10)
    (put 'tool 'hammer 0)

    'my_pl3
)
