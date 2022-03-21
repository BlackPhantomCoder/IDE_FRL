; File: COMMON.LSP		06/17/87	  Soft Warehouse, Inc.


; COMMON LISP Library:	This file defines the library functions
; referred to in Chapter 5 of the muLISP-87 Reference Manual.


; Section 5.1:	Selector Functions

(MOVD 'LENGTH 'LIST-LENGTH)


; Section 5.2:	Constructor Functions

(MOVD 'REVERSE 'REVAPPEND)

(SETQ *GENSYM-PREFIX* 'G)
(SETQ *GENSYM-COUNT* 0)

(DEFUN GENSYM (ATM)
; (GENSYM) returns the symbol whose print name consists of *GENSYM-PREFIX*
; concatenated to *GENSYM-COUNT* and increments *GENSYM-COUNT*.
; (GENSYM symbol) sets *GENSYM-PREFIX* to <symbol>.
; (GENSYM integer) sets *GENSYM-COUNT* to <integer>.
  ( ((NULL ATM))
    ((SYMBOLP ATM)
      (SETQ *GENSYM-PREFIX* ATM) )
    ((AND (INTEGERP ATM) (>= ATM 0))
      (SETQ *GENSYM-COUNT* ATM) ) )
  (PROG1 (PACK* *GENSYM-PREFIX* *GENSYM-COUNT*)
	 (INCQ *GENSYM-COUNT*)) )


; Section 5.3:	Modifier Functions

(MOVD 'NREVERSE 'NRECONC)
(MOVD 'SORT 'STABLE-SORT)


; Section 5.4:	Recognizer Functions

(MOVD 'SYMBOLP 'STRINGP)
(MOVD 'NUMBERP 'RATIONALP)


; Section 5.5:	Comparator Functions

(MOVD 'EQUAL 'TREE-EQUAL)


; Section 5.7:	Assignment Functions

(DEFMACRO SETF LST
  ((NULL LST) NIL)
  ((NULL (CDDR LST))
    ((ATOM (CAR LST))
      (CONS 'SETQ LST) )
    (MAKE-SET-FORM (CAR LST) (CADR LST)) )
  (CONS 'PROGN (SETF-AUX LST)) )

(DEFUN SETF-AUX (LST)
  ((NULL LST) NIL)
  ((ATOM (CAR LST))
    (CONS (LIST 'SETQ (CAR LST) (CADR LST)) (SETF-AUX (CDDR LST))) )
  (CONS (MAKE-SET-FORM (CAR LST) (CADR LST)) (SETF-AUX (CDDR LST))) )

(DEFUN MAKE-SET-FORM (PLACE VALUE)
  ((EQ (CAR PLACE) 'CAR)
    (LIST 'CAR (LIST 'RPLACA (CADR PLACE) VALUE)) )
  ((OR (EQ (CAR PLACE) 'CDR) (EQ (CAR PLACE) 'REST))
    (LIST 'CDR (LIST 'RPLACD (CADR PLACE) VALUE)) )
  ((EQ (CAR PLACE) 'NTH)
    (LIST 'CAR (LIST 'RPLACA (CONS 'NTHCDR (CDR PLACE)) VALUE)) )
  ((EQ (CAR PLACE) 'GET)
    (LIST 'PUT (CADR PLACE) (CADDR PLACE) VALUE) )
  ((EQ (CAR PLACE) 'SYMBOL-FUNCTION)
    (LIST 'PUTD (CADR PLACE) VALUE) )
  ((GET (CAR PLACE) 'CAR)  (LIST 'CAR
      (LIST 'RPLACA (LIST (GET (CAR PLACE) 'CAR) (CADR PLACE)) VALUE)) )
  ((GET (CAR PLACE) 'CDR)  (LIST 'CDR
      (LIST 'RPLACD (LIST (GET (CAR PLACE) 'CDR) (CADR PLACE)) VALUE)) )
  ((GET (CAR PLACE) 'NTH)
    (LIST 'CAR (LIST 'RPLACA
		     (LIST 'NTHCDR (GET (CAR PLACE) 'NTH) (CADR PLACE))
		     VALUE)) )
  ((MACRO-FUNCTION-P (CAR PLACE))
    (MAKE-SET-FORM (MACROEXPAND PLACE) VALUE) )
  (BREAK (LIST 'SETF PLACE VALUE) "Invalid Place Form") )

(MAPC '(LAMBDA (PAIR) (PUT (CAR PAIR) 'CAR (CDR PAIR)))
  '((CAAR . CAR) (CADR . CDR)
    (CAAAR . CAAR) (CAADR . CADR) (CADAR . CDAR) (CADDR . CDDR)
    (CAAAAR . CAAAR) (CAAADR . CAADR) (CAADAR . CADAR) (CAADDR . CADDR)
    (CADAAR . CDAAR) (CADADR . CDADR) (CADDAR . CDDAR) (CADDDR . CDDDR)) )

(MAPC '(LAMBDA (PAIR) (PUT (CAR PAIR) 'CDR (CDR PAIR)))
  '((CDAR . CAR) (CDDR . CDR)
    (CDAAR . CAAR) (CDADR . CADR) (CDDAR . CDAR) (CDDDR . CDDR)
    (CDAAAR . CAAAR) (CDAADR . CAADR) (CDADAR . CADAR) (CDADDR . CADDR)
    (CDDAAR . CDAAR) (CDDADR . CDADR) (CDDDAR . CDDAR) (CDDDDR . CDDDR)) )

(MAPC '(LAMBDA (PAIR) (PUT (CAR PAIR) 'NTH (CDR PAIR)))
  '((FIRST . 0) (SECOND . 1) (THIRD . 2) (FOURTH . 3) (FIFTH . 4)
    (SIXTH . 5) (SEVENTH . 6) (EIGHTH . 7) (NINTH . 8) (TENTH . 9)) )

(DEFMACRO PUSHNEW (OBJ SYM TEST)
  (LIST 'SETQ SYM (LIST 'ADJOIN OBJ SYM TEST)) )


; Section 5.10:  Definition Primitives

(MOVD 'REMD 'FMAKUNBOUND)


; Section 5.11.1:  Character Functions

(DEFUN CHAR-CODE (SYM)
  ((SYMBOLP SYM)
    (ASCII SYM) ) )

(DEFUN CODE-CHAR (N)
  ((AND (INTEGERP N) (<= 0 N 255))
    (ASCII N) ) )


; Section 5.11.2:  String Functions

(DEFMACRO STRING-EQUAL (ATM1 ATM2)
  (LIST 'STRING= ATM1 ATM2 T) )

(DEFMACRO STRING-LESSP (ATM1 ATM2)
  (LIST 'STRING< ATM1 ATM2 T) )

(DEFMACRO STRING-GREATERP (ATM1 ATM2)
  (LIST 'STRING> ATM1 ATM2 T) )

(DEFMACRO STRING-NOT-GREATERP (ATM1 ATM2)
  (LIST 'STRING<= ATM1 ATM2 T) )

(DEFMACRO STRING-NOT-LESSP (ATM1 ATM2)
  (LIST 'STRING>= ATM1 ATM2 T) )

(DEFMACRO STRING-NOT-EQUAL (ATM1 ATM2)
  (LIST 'STRING/= ATM1 ATM2 T) )


; Section 5.12:  Arithmetic Functions (see also the file NUMBER.LSP)

(DEFMACRO INCF (PLACE N)
  ((NULL N)
    ((ATOM PLACE)
      (LIST 'INCQ PLACE) )
    (MAKE-SET-FORM PLACE (LIST 'ADD1 PLACE)) )
  ((ATOM PLACE)
    (LIST 'INCQ PLACE N) )
  (MAKE-SET-FORM PLACE (LIST '+ PLACE N)) )

(DEFMACRO DECF (PLACE N)
  ((NULL N)
    ((ATOM PLACE)
      (LIST 'DECQ PLACE) )
    (MAKE-SET-FORM PLACE (LIST 'SUB1 PLACE)) )
  ((ATOM PLACE)
    (LIST 'DECQ PLACE N) )
  (MAKE-SET-FORM PLACE (LIST '- PLACE N)) )

(DEFUN LOGEQV LST
  (REDUCE '(LAMBDA (INT1 INT2) (LOGNOT (LOGXOR INT1 INT2)) )
	  LST -1) )

(DEFUN LOGTEST (N M)
  (NOT (ZEROP (LOGAND N M))) )

(DEFUN LOGBITP (INDEX N)
  (LOGTEST (SHIFT 1 INDEX) N) )

(DEFUN ASH (N COUNT)
  ((OR (>= N 0) (>= COUNT 0))
    (SHIFT N COUNT) )
  (ASH (SHIFT (SUB1 N) -1) (ADD1 COUNT)) )


; Section 5.13.1:  Input Functions

(DEFUN READ-CHAR-NO-HANG (SOURCE EOF-VALUE-P EOF-VALUE)
  ((OR (LISTEN SOURCE) (INPUT-FILE-P SOURCE))
    (ASCII (READ-BYTE SOURCE EOF-VALUE-P EOF-VALUE)) ) )

(DEFUN PARSE-INTEGER (SYM RADIX
    CHAR SIGN N )
  (SETQ *STRING-INDEX* 0)
  (LOOP
    ((NULL (SETQ CHAR (CHAR SYM *STRING-INDEX*))) NIL)
    ((NEQ CHAR '| |)
      (SETQ SIGN 1)
      ( ((EQ CHAR '+)
	  (INCQ *STRING-INDEX*) )
	((EQ CHAR '-)
	  (SETQ SIGN -1)
	  (INCQ *STRING-INDEX*) ) )
      ((SETQ CHAR (CHAR SYM *STRING-INDEX*))
	((SETQ N (DIGIT-CHAR-P CHAR RADIX))
	  (IF (NULL RADIX) (SETQ RADIX 10))
	  (LOOP
	    (INCQ *STRING-INDEX*)
	    ((NULL (SETQ CHAR (CHAR SYM *STRING-INDEX*))))
	    ((NOT (SETQ CHAR (DIGIT-CHAR-P CHAR RADIX))))
	    (SETQ N (+ (* N RADIX) CHAR)) )
	  (* SIGN N) ) ) )
    (INCQ *STRING-INDEX*) ) )


; Section 5.13.2:  Macro Characters

(SETQ *BACKQUOTE-CHAR* '\`)	;Determines the backquote macro character

(SETQ *LPAR* '\()
(SETQ *RPAR* '\))

(DEFUN READ-BACKQUOTE (PAREN-DEPTH
; This backquote facility conforms to the Common LISP standard as
; described in Section 22.1.3 of Common LISP by Steele [1984].
; It was contributed by Fujimasa Kouno of Tokushima, Japan.
    OBJ CHAR FORM-LIST)
  (SETQ CHAR (PEEK-CHAR T))

  ((EQ CHAR *BACKQUOTE-CHAR*)
    ((ZEROP PAREN-DEPTH)
      (READ) )
    (LIST 'LIST (READ)) )

  ((EQ CHAR '\')
    (READ-CHAR)
    ((ZEROP PAREN-DEPTH)
      (LIST 'QUOTE (LIST 'QUOTE (EVAL (READ-BACKQUOTE PAREN-DEPTH)))) )
    (LIST 'LIST (LIST* 'LIST ''QUOTE (CDR (READ-BACKQUOTE PAREN-DEPTH)))) )

  ((EQ CHAR '\.)
    ((ZEROP PAREN-DEPTH)
      (BREAK CHAR "Syntax Error") )
    (READ-CHAR)
    (SETQ CHAR (PEEK-CHAR T))
    ((EQ CHAR '\,)
      (READ-CHAR)
      (SETQ CHAR (PEEK-CHAR))
      ((OR (EQ CHAR '@) (EQ CHAR '\.))
	(BREAK CHAR "Syntax Error") )
      (SETQ OBJ (READ)
	    CHAR (PEEK-CHAR T) )
      ((EQ CHAR *RPAR*) OBJ)
      (BREAK CHAR "Syntax Error") )
    (SETQ OBJ (LIST 'QUOTE (READ))
	  CHAR (PEEK-CHAR T) )
    ((EQ CHAR *RPAR*) OBJ)
    (BREAK CHAR "Syntax Error") )

  ((EQ CHAR '\,)
    (READ-CHAR)
    (SETQ CHAR (PEEK-CHAR))
    ((AND (EQ CHAR '\@) (NEQ PAREN-DEPTH 0))
      (READ-CHAR)
      (SETQ OBJ (READ))
      ((EQ (PEEK-CHAR T) *RPAR*) OBJ)
      (LIST 'COPY-LIST OBJ) )
    ((AND (EQ CHAR '\.) (NEQ PAREN-DEPTH 0))
      (READ-CHAR)
      (READ) )
    ((OR (EQ CHAR '\@) (EQ CHAR '\.))
      (BREAK CHAR "Syntax Error") )
    ((ZEROP PAREN-DEPTH)
      (READ) )
    (LIST 'LIST (READ)) )

  ((EQ CHAR *RPAR*)
    (READ-CHAR)
    NIL)

  ((EQ CHAR *LPAR*)
    (READ-CHAR)
    (LOOP
      ((NULL (SETQ OBJ (READ-BACKQUOTE (ADD1 PAREN-DEPTH))))
	((ZEROP PAREN-DEPTH)
	  (CONS 'NCONC (NREVERSE FORM-LIST)) )
	(LIST 'LIST (CONS 'NCONC (NREVERSE FORM-LIST))) )
      (PUSH OBJ FORM-LIST) ) )

  ((ZEROP PAREN-DEPTH)
    (LIST 'QUOTE (READ)) )
  (LIST 'LIST (LIST 'QUOTE (READ))) )

(SET-MACRO-CHAR *BACKQUOTE-CHAR* '(LAMBDA ()
  (READ-BACKQUOTE 0) ))


; Section 5.16.1:  Evaluation Recognizers

(DEFUN EVAL-FUNCTION-P (SYM)
  (EQ (GETD SYM T) 'LAMBDA) )

(DEFUN NO-EVAL-FUNCTION-P (SYM)
  (EQ (GETD SYM T) 'NLAMBDA) )

(DEFUN MACRO-FUNCTION-P (SYM)
  (EQ (GETD SYM T) 'MACRO) )

(DEFUN SPECIAL-FORM-P (SYM)
  (EQ (GETD SYM T) 'SPECIAL) )

(DEFUN FBOUNDP (SYM)
  (GETD SYM T) )

(DEFUN FUNCTIONP (OBJ)
  ((SYMBOLP OBJ))
  ((ATOM OBJ) NIL)
  (EQ (CAR OBJ) 'LAMBDA) )


; Section 5.16.2:  Evaluation and Function Application

(DEFUN SYMBOL-VALUE (SYM)
  ((SYMBOLP SYM)
    (CAR SYM) ) )

(DEFUN SYMBOL-PLIST (SYM)
  ((SYMBOLP SYM)
    (CDR SYM) ) )

(DEFUN SYMBOL-FUNCTION (SYM)
  ((SYMBOLP SYM)
    ((FBOUNDP SYM)
      (GETD SYM) )
    (BREAK (LIST 'SYMBOL-FUNCTION SYM) "Undefined Function") ) )


; Section 5.16.3:  Macro Expansion Functions

(DEFUN MACRO-FUNCTION (SYM)
  ((MACRO-FUNCTION-P SYM)
    (GETD SYM) ) )


; Section 5.17:  Control Constructs

(DEFMACRO PROG2 (FORM1 . FORMS)
  (LIST 'PROGN FORM1 (CONS 'PROG1 FORMS)) )

(DEFMACRO WHEN (TEST . BODY)
  (LIST 'IF TEST (CONS 'PROGN BODY)) )

(DEFMACRO UNLESS (TEST . BODY)
  (LIST 'IF TEST NIL (CONS 'PROGN BODY)) )

(DEFMACRO CASE (KEYFORM . CASES)
  (LIST (LIST 'LAMBDA
	      '(KEY)
	      (CONS 'COND
		    (MAPCAR '(LAMBDA (CASE) (CONS
			       (IF (MEMBER (CAR CASE) '(T OTHERWISE))
				   T
				   (LIST (IF (ATOM (CAR CASE)) 'EQL 'MEMBER)
					 KEY
					 (LIST 'QUOTE (CAR CASE))) )
			       (OR (CDR CASE) '(NIL))) )
			     CASES)))
	KEYFORM) )

(DEFMACRO LET (LETLIST . BODY)
   (CONS (LIST* 'LAMBDA
		(MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR))) LETLIST)
		BODY)
	 (MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) NIL (CADR VAR))) LETLIST)) )

(DEFMACRO LET* (LETLIST . BODY)
   (CONS (LIST* 'LAMBDA
		(MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR))) LETLIST)
		(CONS 'SETQ
		      (MAPCAN '(LAMBDA (VAR)
				(IF (ATOM VAR)
				    (LIST VAR NIL)
				    (LIST (CAR VAR) (CADR VAR))) )
			      LETLIST))
		BODY)
	 (MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR))) LETLIST)) )

(DEFMACRO DO (LETLIST . BODY)
  (CONS (LIST 'LAMBDA
	      (MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR))) LETLIST)
	      (CONS 'LOOP
		    (APPEND BODY (LIST (CONS 'PSETQ
			(MAPCAN '(LAMBDA (VAR)
				   ((ATOM VAR) NIL)
				   ((CDDR VAR)
				     (LIST (CAR VAR) (CADDR VAR)) ) )
				LETLIST))))))
	(MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) NIL (CADR VAR))) LETLIST)) )

(DEFMACRO DO* (LETLIST . BODY)
  (CONS (LIST 'LAMBDA
	      (MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR)))
		      LETLIST)
	      (CONS 'SETQ
		    (MAPCAN '(LAMBDA (VAR)
				(IF (ATOM VAR)
				   (LIST VAR NIL)
				   (LIST (CAR VAR) (CADR VAR))) )
			    LETLIST))
	      (CONS 'LOOP
		    (APPEND BODY (LIST (CONS 'SETQ
			(MAPCAN '(LAMBDA (VAR)
				   ((ATOM VAR) NIL)
				   ((CDDR VAR)
				     (LIST (CAR VAR) (CADDR VAR)) ) )
				LETLIST))))))
	 (MAPCAR '(LAMBDA (VAR) (IF (ATOM VAR) VAR (CAR VAR))) LETLIST)) )

(DEFMACRO DOLIST ((VAR LISTFORM RSLTFORM) . BODY)
  (LET ((DOLIST (GENSYM)))
    (LIST 'LET
	  (LIST (LIST DOLIST LISTFORM))
	  (LIST* 'LOOP
		 (LIST (LIST 'ATOM DOLIST) RSLTFORM)
		 (LIST 'SETQ VAR (LIST 'POP DOLIST))
		 BODY)) ) )

(DEFMACRO DOTIMES ((VAR COUNTFORM RSLTFORM) . BODY)
  (LET ((DOTIMES (GENSYM)))
    (LIST 'LET
	  (LIST (LIST VAR 0)
		(LIST DOTIMES COUNTFORM))
	  (LIST* 'LOOP
		 (LIST (LIST '>= VAR DOTIMES) RSLTFORM)
		 (APPEND BODY (LIST (LIST 'INCQ VAR))))) ) )


; PROG [var-list, expn1, expn2, ..., expnm]  sets the local variables
; in <var-list> to NIL and sequentially evaluates <expn1> through <expnm>,
; unless the functions GO or RETURN are encountered.  We recommend that
; functions using PROG be translated into equivalent muLISP functions
; using the LOOP construct, since the result will be more efficient.

(DEFUN PROG (NLAMBDA LST$
  (EVAL (LIST (CONS 'LAMBDA (LIST (CAR LST$) (LIST 'PROG-AUX
      '(CDR LST$)))))) ))

(DEFUN PROG-AUX (BDY$
    LST$ GO-LABEL$ ANS$)
  (SETQ LST$ BDY$)
  (LOOP
    ((NULL LST$) ANS$)
    (SETQ ANS$ (EVAL (POP LST$)))
    ( ((NULL GO-LABEL$))
      (SETQ LST$ (CDR (MEMBER GO-LABEL$ BDY$))
	    GO-LABEL$) ) ) )


;GO [label]  if within a PROG, transfers control to the expression in
;the PROG body immediately following <label>.

(DEFUN GO (NLAMBDA (LABEL$)
  (SETQ GO-LABEL$ LABEL$) ))


;(DOS command) executes the MS-DOS <command>, and returns the exit code.

(DEFUN DOS (COMMAND)
  (EXECUTE (GETSET 'COMSPEC) (IF COMMAND (PACK* "/C " COMMAND))) )


; Section 5.19:  User Interface Functions

(DEFUN Y-OR-N-P (MSG
    CHAR )
  ( ((NULL MSG))
    (FRESH-LINE T)
    (WRITE-STRING (PACK* MSG " (Y/N) ") T) )
  (CLEAR-INPUT T)
  (LOOP
    (SETQ CHAR (CHAR-UPCASE (ASCII (READ-BYTE T))))
    ((EQ CHAR 'Y) (WRITE-LINE CHAR T) T)
    ((EQ CHAR 'N) (WRITE-LINE CHAR T) NIL)
    (WRITE-BYTE 7 NIL T) ) )

(DEFUN YES-OR-NO-P (MSG
    LINE )
  (CLEAR-INPUT T)
  (LOOP
    ( ((NULL MSG))
      (FRESH-LINE T)
      (WRITE-STRING (PACK* MSG " (Yes or No) ") T) )
    (WRITE-BYTE 7 NIL T)
    (SETQ LINE (STRING-UPCASE (READ-LINE T)))
    ((EQ LINE 'YES))
    ((EQ LINE 'NO) NIL) ) )
