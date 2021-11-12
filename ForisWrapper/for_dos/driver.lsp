(DEFUN DRIVER2 (**driver-buf**)
    (defun read (**result**)
        (**clear** |F:\inacc.lsp|)
        (**wait** |F:\inacc.lsp| T)
        (setq  **result** (**read_from_file** |F:\in.lsp| **read** nil))
        ;(princ |>> |)
        ;(**print** **result**)
        **result**
    )
    (defun print (**x** **result**)
        (**wait** |F:\oacc.lsp| T)
        (setq  **result** (**out_to_file** |F:\out.lsp| **print** **x**))
        (**clear** |F:\oacc.lsp|)
        (**delay** 51)
        **result**
    )
    (CATCH 'RETURN 
        (LOOP 
            (CATCH nil
                (CATCH 'DRIVER
                    ;(PRINC "> ")
                    (setq **driver-buf** (EVAL (READ)))
                    (PRINT  **driver-buf**)
                )
            )
        )
    )
)

(movd print **print**)
(movd read **read**)

(defun **func_under_file** (**rds** **file** **func** **arg** **result** **buf**)
    (cond 
        ((eval **rds**) (setq **buf** rds) (rds **file**))
        (T (setq **buf** wrs) (wrs **file**))
    )
    (setq **result** (funcall **func** **arg**))
    ;(if (eval **rds**) (rds  **buf*) (wrs  **buf*))
    (if (eval **rds**) (rds) (wrs))
    **result**
)

(defun **read_from_file** (**file** **func** **arg**)
    ;(**print** (list read from **file** (list **func** **arg**)))
    (**func_under_file** T **file** **func** **arg**)
)

(defun **out_to_file** (**file** **func** **arg**)
    ;(**print** (list write to **file** (list **func** **arg**)))
    (**func_under_file** nil **file** **func** **arg**)
)

(defun **clear** (**file**)
    ;(**print** (list clear **file**))
    (**out_to_file** **file** **print** 0)
)

(defun **delay** (**time** **buf**)
    (setq **buf** (+ (time) (CEILING (/ **time** 10))))
    (LOOP
        ((>= (time) **buf**) nil)
    )
)

(defun **wait** (**file** **for_delete** **buf**)
    (LOOP
        ;(**print** (list wait for **file** **for_delete**))
        (setq **buf** (rds **file**))
        ((and (not **buf**) **for_delete**) nil)
        ((and **buf** (not **for_delete**)) (rds))
        (if (eval **buf**) (rds))
        (**delay** 50)
    )
)


(DRIVER2)