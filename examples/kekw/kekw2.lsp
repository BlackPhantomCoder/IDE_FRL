(defun POSITION (object list test) 
	(if (null test) (setq test 'equal) )
	(cond 
		((null list) nil)
		((funcall test object (car list)) (length list))
		(T (- (length list) (POSITION object (cdr list) test)) )
	) 
)

(defun FIND-IF (test elem_list) 
	(cond 
		( (null elem_list) NIL)
		( (funcall test (car elem_list) ) (car elem_list) )
		(T (FIND-IF test (cdr elem_list)) )
	) 
)


;Iteration method
(defun PRINTBLNK_IT (elem_list space_list iter_list) 
	(setq iter_list space_list)
	(LOOP       
		(if (null iter_list) (setq iter_list space_list))
		( (null  (cdr elem_list) ) 
			(spaces (car iter_list) )
			(car elem_list) 
		)      
		(spaces (car iter_list)  )
		(princ  (car elem_list) )    
		(setq elem_list (cdr elem_list))    
		(setq iter_list (cdr iter_list))
    )
	
)

;Recursion method
(defun PRINTBLNK_REC (elem_list space_list iter_list) 
	(if (null iter_list) (setq iter_list space_list))
	(cond
		( (null  (cdr elem_list) ) 
			(spaces (car iter_list) ) 
			(car elem_list)   
		)   
		(T  
			(spaces (car iter_list) )
			(princ  (car elem_list) )
			(PRINTBLNK_REC (cdr elem_list) space_list (cdr iter_list)  ) 
		)
	)	
)

;функционал
(defun print_prnblnk (elem space) 
	(spaces space) 
	(princ elem)
)

(defun corr_size (el_len space_list iter_list)
	(if (null iter_list) (setq iter_list space_list))
	(cond
		( (= el_len (length space_list) ) space_list )
		( (> el_len (length space_list) ) 
			(setq space_list (reverse space_list) )
			(push (car iter_list) space_list)
			(setq space_list (reverse space_list) )
			(corr_size el_len space_list (cdr iter_list) )
		)
		( (< el_len (length space_list) )
			(setq space_list (reverse space_list) )
			(setq space_list (cdr space_list) )
			(setq space_list (reverse space_list) )
			(corr_size el_len space_list iter_list)
		)
	)
)

(defun PRINTBLNK_FC (elem_list space_list) 
	(setq space_list (corr_size (length elem_list)  space_list) )
	(setq last_elem (car (reverse elem_list) ) )
	(setq last_spac (car (reverse space_list) ) )
	(setq elem_list (reverse (cdr (reverse elem_list )) ) )
	;Вызов функционала
	(mapc print_prnblnk elem_list space_list)
	(spaces last_spac)
	last_elem
)
