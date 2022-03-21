; File: ARRAY.LSP  (C)		02/19/87	Soft Warehouse, Inc.


;			The muLISP Array Package

; This file provides an array facility patterned after Common LISP
; (see Chapter 17 of Common LISP, The Language Steele [1984]).


(DEFUN ARRAYP (OBJ)
; Returns T if OBJ is an array, otherwise it returns NIL.
  (EQ (CAR OBJ) 'ARRAY) )


(DEFUN MAKE-ARRAY ARGS
; (MAKE-ARRAY DIMENSIONS . OPTIONS) creates an array of dimensions DIMENSIONS
; initialized iaw OPTIONS.
  ((LAMBDA (DIMENSIONS OPTIONS
	OBJ)
      (IF (NOT (LISTP DIMENSIONS))  (SETQ DIMENSIONS (LIST DIMENSIONS)))
      ((SETQ OBJ (MEMBER :INITIAL-CONTENTS OPTIONS))
	(LIST 'ARRAY
	      (MAKE-INITIAL-CONTENTS-ARRAY DIMENSIONS (CADR OBJ))
	      DIMENSIONS) )
      (SETQ OBJ (CADR (MEMBER :INITIAL-ELEMENT OPTIONS)))
      (LIST 'ARRAY (MAKE-INITIAL-ELEMENT-ARRAY DIMENSIONS) DIMENSIONS) )
    (CAR ARGS)
    (CDR ARGS)) )

(DEFUN VECTOR LST
; (VECTOR OBJ1 ... OBJn) creates a vector (a one dimensional array) whose
; whose elements are the objects OBJ1 through OBJn.
  (MAKE-ARRAY (LIST (LENGTH LST)) :INITIAL-CONTENTS LST) )

(DEFUN MAKE-INITIAL-ELEMENT-ARRAY (DIMENSIONS)
; Creates an array structure IAW DIMENSIONS when the :INITIAL-ELEMENT
; option is used.
  ((NULL DIMENSIONS) OBJ)
  (MAPL '(LAMBDA (LST)
	   (RPLACA LST (MAKE-INITIAL-ELEMENT-ARRAY (CDR DIMENSIONS))) )
	(MAKE-LIST (CAR DIMENSIONS))) )

(DEFUN MAKE-INITIAL-CONTENTS-ARRAY (DIMENSIONS OBJ)
; Creates an array structure IAW DIMENSIONS when the :INITIAL-CONTENTS
; option is used.
  ((NULL DIMENSIONS) OBJ)
  ((EQL (CAR DIMENSIONS) (LENGTH OBJ))
    (MAPL '(LAMBDA (LST OBJ)
	     (RPLACA LST (MAKE-INITIAL-CONTENTS-ARRAY (CDR DIMENSIONS)
						      (CAR OBJ))) )
	  (MAKE-LIST (CAR DIMENSIONS))
	  OBJ) )
  (BREAK (CONS 'MAKE-ARRAY ARGS) "Dimension Error") )


(DEFMACRO AREF (ARRAY . SUBSCRIPTS)
; Returns the specifed element of ARRAY.  AREF can also be used in
; conjunction with SETF to set a specified element of ARRAY.
  (SETQ ARRAY (LIST 'CADR ARRAY))
  (LOOP
    ((ATOM SUBSCRIPTS) ARRAY)
    (SETQ ARRAY (LIST 'NTH (POP SUBSCRIPTS) ARRAY)) ) )


(DEFUN ARRAY-RANK (ARRAY)
; Returns the "rank" of ARRAY.
  ((ARRAYP ARRAY)
    (LENGTH (CADDR ARRAY)) ) )

(DEFUN ARRAY-DIMENSION (ARRAY AXISNUMBER)
; Returns the dimension of ARRAY along the AXISNUMBER axis where 0
; is the first axis of any array.
  ((ARRAYP ARRAY)
    (NTH AXISNUMBER (CADDR ARRAY)) ) )

(DEFUN ARRAY-DIMENSIONS (ARRAY)
; Returns the list of dimensions of ARRAY.
  ((ARRAYP ARRAY)
    (CADDR ARRAY) ) )

(DEFUN ARRAY-TOTAL-SIZE (ARRAY)
; Returns the total number of elements in ARRAY.
  ((ARRAYP ARRAY)
    (REDUCE '* (CADDR ARRAY)) ) )


(DEFUN ARRAY-IN-BOUNDS-P ARGS
; (ARRAY-IN-BOUNDS-P ARRAY SUBSCRIPT1 ... SUBSCRIPTn) returns T if SUBSCRIPT1
; through SUBSCRIPTn are valid subscripts for ARRAY, otherwise it returns NIL.
  ((ARRAYP (CAR ARGS))
    (EVERY '(LAMBDA (SUBSCRIPT DIMENSION)
	      (AND (INTEGERP SUBSCRIPT) (< -1 SUBSCRIPT DIMENSION)))
	   (CDR ARGS)
	   (CADDAR ARGS)) ) )
