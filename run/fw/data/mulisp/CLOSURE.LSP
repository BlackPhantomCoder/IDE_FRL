; File: CLOSURE.LSP  (c)	03/30/87	Soft Warehouse, Inc.


;			The muLISP Closure Package

; This package was written by Pete Ohler of Boulder Creek, CA, USA.

(SETQ *DYNAMIC-CLOSURES*)
;This is alist of all the variable lists used by the dynamic closures.

(DEFUN CLOSURE (VAR-LIST FUNCTION
; Creates a dynamic closure of FUNCTION over the variables in VAR-LIST.
; The closure is implemented as a lambda expression that binds the variables
; in VAR-LIST to their closure values, applies FUNCTION to the variables,
; saves the new values of the closure variables, restores the variables
; to their original values, and returns the value of the function
; application.	The lambda maintains the values of its closure variables
; as a list, the elements of which it modifies using RPLACA.
    VARS)
  (SETQ VARS (MAPCAR 'EVAL VAR-LIST))
  (PUSH VARS *DYNAMIC-CLOSURES*)
  (LIST 'LAMBDA
	'VARS!
	(CONS (LIST 'LAMBDA
		    VAR-LIST
		    (LIST 'PROG1
			  (LIST 'APPLY (LIST 'QUOTE FUNCTION) 'VARS!)
			  (LIST 'MAPL
				'(QUOTE (LAMBDA (LST!C VARS!C)
				   (RPLACA LST!C (EVAL (CAR VARS!C)))))
				(LIST 'QUOTE VARS)
				(LIST 'QUOTE VAR-LIST))))
	      VARS)) )

(DEFMACRO LET-CLOSED (LETLIST FUNC)
; Creates a temporary list of the variables (VARS) and then creates a list of
; a lambda expression that has VARS as the arguments and the values in the
; LETLIST as the last part of the list.  The list is evaluated and the lambda
; expression binds the values of LETLIST to the VARS and then calls the
; function 'CLOSURE with VARS and a quoted list of FUNC.
  (LIST 'LET-CLOSED-AUX (LIST 'QUOTE LETLIST) FUNC) )

(DEFUN LET-CLOSED-AUX (LETLIST FUNC
    VARS)
  (SETQ VARS (MAPCAR '(LAMBDA (X) (IF (ATOM X) X (CAR X))) LETLIST))
  (EVAL (CONS (LIST 'LAMBDA VARS
		    (LIST 'CLOSURE (LIST 'QUOTE VARS) (LIST 'QUOTE FUNC)))
	      (MAPCAR 'CADR LETLIST))) )

; To understand the locatives for the VARs, FUNCTION, and values in closures
; a printout of an example closure would be helpful as all the CARs and CDRs
; can become confusing.

(DEFUN COPY-CLOSURE (CLOSURE
; Creates and returns a copy of CLOSURE.
; To copy a closure the values of the VARS must be maintained but the VARS
; can not be the same list as the original.  Since the same (as in EQ) list
; appears in two places a simple COPY-TREE will not work and COPY-LIST or
; COPY-ALIST will use the original VAR list (as in EQ).  Instead a copy of
; the internal lambda expression of the closure is used to set the VARS and
; the function CLOSURE is called with the originals VARS and FUNCTION.
    TEMP)
  ((CLOSUREP CLOSURE)
    (SETQ TEMP (COPY-TREE (CADDR CLOSURE)))
    (RPLACA (CDDAR TEMP)
	    (LIST 'CLOSURE (LIST 'QUOTE (CADR (CAADDR CLOSURE)))
		  (CADAR (CDADDR (CAADDR CLOSURE)))))
    (EVAL TEMP) )
  (BREAK (LIST 'COPY-CLOSURE CLOSURE) "Nonclosure Argument") )

(DEFUN CLOSUREP (OBJECT)
; Returns T if OBJECT is a dynamic closure, otherwise it returns NIL.
  ((MEMBER (CDADDR OBJECT) *DYNAMIC-CLOSURES*) 'T) )

(DEFUN SYMEVAL-IN-CLOSURE (CLOSURE SYMBOL
; Returns the value of SYMBOL in CLOSURE.  If SYMBOL is not a closure
; variable of CLOSURE, it returns the current value of SYMBOL.
    NUM)
  ((CLOSUREP CLOSURE)
    ((SYMBOLP SYMBOL)
      ((SETQ NUM (POSITION SYMBOL (CADR (CAADDR CLOSURE))))
	(NTH NUM (CDADDR CLOSURE)) )
      (EVAL SYMBOL) )
    (BREAK (LIST 'SYMEVAL-IN-CLOSURE CLOSURE SYMBOL) "Nonsymbolic argument") )
  (BREAK (LIST 'SYMEVAL-IN-CLOSURE CLOSURE SYMBOL) "Nonclosure Argument") )

(DEFUN SET-IN-CLOSURE (CLOSURE SYMBOL OBJECT
; Binds the closure variable SYMBOL in CLOSURE to OBJECT and returns OBJECT.
; If SYMBOL is not a closure variable of CLOSURE, it binds SYMBOL to OBJECT.
    NUM)
  ((CLOSUREP CLOSURE)
    ((SYMBOLP SYMBOL)
      ((SETQ NUM (POSITION SYMBOL (CADR (CAADDR CLOSURE))))
	(RPLACA (NTHCDR NUM (CDADDR CLOSURE)) OBJECT)
	OBJECT )
      (SET SYMBOL OBJECT) )
    (BREAK (LIST 'SET-IN-CLOSURE CLOSURE SYMBOL OBJECT) "Nonsymbolic argument") )
  (BREAK (LIST 'SET-IN-CLOSURE CLOSURE SYMBOL OBJECT) "Nonclosure Argument") )

(DEFUN CLOSURE-ALIST (CLOSURE)
; Creates and returns an alist of the closure variables of CLOSURE paired
; with their closure values.
  ((CLOSUREP CLOSURE)
    (PAIRLIS (CADR (CAADDR CLOSURE)) (CDADDR CLOSURE)) )
  (BREAK (LIST 'CLOSURE-ALIST CLOSURE) "Nonclosure Argument") )

(DEFUN CLOSURE-FUNCTION (CLOSURE)
; Returns the closure function of CLOSURE.
  ((CLOSUREP CLOSURE)
    (CAR (CDADAR (CDADDR (CAADDR CLOSURE)))) )
  (BREAK (LIST 'CLOSURE-FUNCTION CLOSURE) "Nonclosure Argument") )

(DEFUN CLOSURE-VARIABLES (CLOSURE)
; Returns the closure variables of CLOSURE.
  ((CLOSUREP CLOSURE)
    (CADR (CAADDR CLOSURE)) )
  (BREAK (LIST 'CLOSURE-VARIABLES CLOSURE) "Nonclosure Argument") )
