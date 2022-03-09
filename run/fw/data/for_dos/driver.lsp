
|;?????????? ??? ?????? ????? ??? ??????|
(if (equal **translate_disks** '**translate_disks**)       (setq **translate_disks** nil))
(if (equal **translate_disks_to** '**translate_disks_to**) (setq **translate_disks_to** nil))

|;?????????? ????? ??? ?????? ??? ??????|
(DEFUN **add_translate_disk** (**x** **y**) 
    (setq **translate_disks** (append **translate_disks**  (list **x**)))
    (setq **translate_disks_to** (append **translate_disks_to**  (list **y**)))
)

|;??????? ??? ?????? ????? ??? ??????|
(defun **compare** (**a** **b** **a1** **b1** **len1** **len2**)
    (setq **a1**  (unpack **a** ))
    (setq **b1** (unpack  **b**))
    (setq **len1** (length **a1** ))
    (setq **len2** (length **b1**))
    ((or (= **len1** 0) (> **len1** **len2**)) nil)
    ((equal **a** (pack (sublist **b1** 0 (- **len1** 1)))) (nthcdr **len1** **b1**))
    nil
)

(movd 'rds '**rds1**)

(DEFUN RDS (**x** **right** **now_disk** **disks** **j**) 
    (setq **disks** **translate_disks**)
    (setq **j** 0)
    (**rds1**
        (if
            (loop 
                ((null **disks** ) nil)
                (setq **now_disk** (car **disks**))
                (setq **disks** (cdr **disks**))
                (setq **right** (**compare** **now_disk** **x**))
                ((not (null **right**)) T)
                (setq **j** (+ **j** 1))
            )
            (pack (append (unpack (nth **j** **translate_disks_to**)) **right**))
            **x**
        )
    )
)

|;????? ?????????????|
(SETQ **sinc_file**         |S:SINC.LSP|)
(SETQ **buf_file**          |S:BUF.LSP|)

(SETQ **sinc_read_file**    |S:SR.LSP|)
(SETQ **sinc_print_file**   |S:SP.LSP|)


|;??????????? ???????/???????? ?????|
(setq **cof** wrs)
(if (equal **cof** 'wrs) (setq **cof** nil))
(movd 'wrs '**wrs2**)

(defun wrs (**x**)  (setq **cof** (**wrs2** **x**)))

(setq **cif** rds)
(if (equal **cif** 'rds) (setq **cif** nil))
(movd 'rds '**rds2**)

(defun rds (**x**)  (setq **cif** (**rds2** **x**)))


|;??????? ??? ?????????? ??? **_s_** = nil|
(DEFUN **under-nil-s** (**_s_** **_x_** **_m_**)
    (setq **_m_** (eval **_s_**))
    (set **_s_** nil)
    (UNWIND-PROTECT
        (setq  **_x_** (apply 'progn **_x_**))
       (set **_s_** **_m_**)
    )
    **_x_**
)

|;??????? ??? ?????????? ??? wrs = nil|
(defun **under-nil-wrs** 
    (nlambda **x**
       (**under-nil-s** 'wrs **x**)
    )
)

|;??????? ??? ?????????? ??? rds = nil|
(defun **under-nil-rds** 
    (nlambda **x**
       (**under-nil-s** 'rds **x**)
    )
)

|;???????? ?????????? ??????? (???? ?? ????? ? **name**)|
(DEFUN **bi_func_name** (**fnc**)
    (PACK (APPEND (LIST '* '*) (UNPACK **fnc**) (LIST '* '*)))
)

(DEFUN **save_bi_funcs** (**lst** **buf**) 
    (loop 
        ((null **lst**) nil)
        (setq **buf** (car **lst**))
        (setq **lst** (cdr **lst**))
        
        (funcall 'movd **buf** (**bi_func_name** **buf**))
    )
)

(**save_bi_funcs** (list 'print 'princ 'write-string 'TERPRI 'READ 'read-char 'driver))

(REMD **save_bi_funcs**)



|;?????? ??? ?????????????|
(DEFUN **func_under_file** (**rds_mode** **file** **func** **arglist** **result** **buf** **s**)
    |;((null nil) (apply **func** **arglist**))|
    
    (if **rds_mode** 
        (progn (setq **s** **cif**) (setq **rds_mode** 'rds))
        (progn (setq **s** **cof**) (setq **rds_mode** 'wrs))
    )
    (setq **buf** (eval **rds_mode**))
    (if (or (NULL **buf**) (NULL **s**))
        (progn
            (funcall **rds_mode** **file**)
            (UNWIND-PROTECT 
                (setq **result** (apply **func** **arglist**)) 
                (progn 
                    (funcall **rds_mode**)
                    (funcall **rds_mode** **s**)
                    (set **rds_mode** **buf**)
                )
            )
        )
        (setq **result** (apply **func** **arglist**))
    )
    **result**
)

(DEFUN **read_from_file** (**file** **func** **arglist**)
    (**func_under_file** T **file** **func** **arglist**)
)

(DEFUN **out_to_file** (**file** **func** **arglist**)
    (**func_under_file** nil **file** **func** **arglist**)
)

(DEFUN **clear** (**file**)
    (**under-nil-wrs** (**out_to_file** **file** **TERPRI** (list 1)))
)

(DEFUN **delay** (**time** **buf**)
    (setq **buf** (+ (time) (CEILING (/ **time** 10))))
    (LOOP
        ((>= (time) **buf**) nil)
    )
)

(DEFUN **wait** (**file** **for_delete** **buf** **s**)
    (LOOP
        (**under-nil-rds** 
            (setq **s** **cif**)
            (rds **file**)
            (setq **buf** rds)
            (if **buf** (rds))
            (if **s** (rds **s**))
            (setq rds nil)
        )
        ((and (not **buf**) **for_delete**) nil)
        ((and **buf** (not **for_delete**)) )
        (**delay** 50)
    )
)


(DEFUN **apply_write_under_file_w_arglist** (**fnc** **arglist** **result**)
    (**wait**  **sinc_print_file** T)
    (**clear** **sinc_file**)
    (setq  **result** (**out_to_file**  **sinc_file** (**bi_func_name** **fnc**) **arglist**))
    (**clear**  **sinc_print_file**)
    (**delay** 51)
    **result**
)

(DEFUN **apply_read_under_file_w_arglist** (**fnc** **arglist** **result** **catched**)
    (if (or (NULL rds) (NULL **cif**))
        (progn  
            (MOVD **BREAK-THROW** BREAK)
            (UNWIND-PROTECT
                (loop
                    (**clear** **sinc_read_file**)
                    (**wait**  **sinc_read_file** T)
                    (setq  **catched** T)
                    (CATCH 'BREAK-THROW 
                        (setq  **result** (**read_from_file**  **sinc_file** (**bi_func_name** **fnc**) **arglist**))
                        (setq **catched** nil)
                    )
                    ((NULL  **catched**) 'BREAK-THROW)
                    (princ "#input error, please try again#")
                    (TERPRI 1)
                )
                (MOVD **BREAK** BREAK)
            )
        )
    )
    (setq  **result** (**read_from_file**  **sinc_file** (**bi_func_name** **fnc**) **arglist**))
    **result**
)


|;???????? ??????????|
(defun **load** **x**
    (movd break !!break!!)

    (DEFUN BREAK
        (nlambda (**f** **msg**)
            (THROW 'BREAK-THROW)
        )
    )

    (UNWIND-PROTECT
        ((lambda (**lst** **x**)
            (loop
                ((null **lst**) T)
                (setq **x** (car **lst**))
                (setq **lst** (cdr **lst**))
                (princ |loading |)
                (print **x**)
                ((null (rds **x**)) (princ |load error|) (TERPRI 1) nil)
                (UNWIND-PROTECT
                    (CATCH 'BREAK-THROW 
                        (loop (print (eval (read))))
                    )
                    (rds)
                )
            )
        ) **x**)
        (progn
            (MOVD !!BREAK!! BREAK)
            (REMD !!BREAK!!)
        )
    )
)



(DEFUN **apply_write_under_file_w_1_arg** (**fnc** **arg**)
    (**apply_write_under_file_w_arglist** **fnc** (list **arg**))
)

(DEFUN **apply_read_under_file_w_1_arg** (**fnc** **arg**)
    (**apply_read_under_file_w_arglist** **fnc** (list **arg**))
)


|;???????? break|
(DEFUN BREAK 
    (nlambda (**f** **msg** **buf** **result**) 
        (**under-nil-wrs** 
            (write-string "break ")
            (princ (eval **msg**))
            (princ " ")
            (princ **f**)
            (TERPRI 1)
            |;...|
            |;(READ-CHAR)|
            (loop
                (write-string |Continue, Break, Abort, Top-level? |)
                (SETQ **buf** (**under-nil-rds** (READ-CHAR)))
                (TERPRI 1)
                ((or (eq **buf** \C) (eq **buf** \c)) (setq **result** '(return **f**)))
                ((or (eq **buf** \B) (eq **buf** \b)) (setq **result** '(progn (SETQ BREAK **f**) (DRIVER))))
                ((or (eq **buf** \A) (eq **buf** \a)) (setq **result** '(return **f**)))
                ((or (eq **buf** \T) (eq **buf** \t)) (setq **result** '(throw 'TOP-LEVEL)))
                |;((or (eq **buf** \S) (eq **buf** \s)) (system))|
                |;((or (eq **buf** \R) (eq **buf** \r)) (restart))|
            )
        )
        (eval **result**)
    )
)
(movd break **break**)

|;??????????? break ? ???????????|
(DEFUN **BREAK-THROW** 
    (nlambda (**f** **msg**)
        (THROW 'BREAK-THROW)
    )
)


|;??????? ??????????????? ????????|
(defun RESTART () ((WRITE-STRING "ForisWrapper do not support restart") (TERPRI 1)))
(defun SYSTEM () ((WRITE-STRING "ForisWrapper do not support system") (TERPRI 1)))


|;???????|
(DEFUN DRIVER (**driver-buf** **result**)
    (setq **result**
        (CATCH 'RETURN
            (CATCH 'DRIVER
                (loop
                    (**under-nil-wrs** (PRINC ">>> "))
                    (SETQ + '+)
                    (SETQ ++ '++)
                    (SETQ +++ '+++)
                    (SETQ **driver-buf** (EVAL (**under-nil-rds** (READ))))
                    (PRINT  **driver-buf**)
                )
            )
        )
    )
    **result**
)

|;??????? ???????? ??????|
(defun **top-level** (**catched** **tcatched**) 
    (DEFUN print        (**arg**) (**apply_write_under_file_w_1_arg** 'print **arg**))
    (DEFUN write-string (**arg**) (**apply_write_under_file_w_1_arg** 'write-string **arg**))
    (DEFUN TERPRI       (**arg**) (**apply_write_under_file_w_1_arg** 'TERPRI **arg**))


    (DEFUN princ        (**arg**) (**apply_write_under_file_w_1_arg** 'princ **arg**))


    (DEFUN READ  () (**apply_read_under_file_w_arglist** 'READ nil))
    (DEFUN read-char **arg_lst** (**apply_read_under_file_w_arglist** 'read-char **arg_lst**))

    (LOOP
        (SETQ **catched** T)
        (SETQ RDS NIL)
        (SETQ WRS NIL)

        |;(SETQ READ-CHAR 'READ-CHAR)|
        (SETQ **exception_object** (CATCH 'NIL  (CATCH 'TOP-LEVEL (FUNCALL DRIVER) (setq **tcatched** nil)) (setq **catched** nil)))
        (cond 
            ((and (NULL **catched**) **tcatched**) nil)
            (**catched**
                (write-string  "uncatched exception ")
                (print **exception_object**)
            )
            (T nil)
        )
    )
)