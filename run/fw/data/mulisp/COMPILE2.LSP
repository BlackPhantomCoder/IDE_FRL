; File: COMPILE2.LSP  (c)	01/29/87	Soft Warehouse, Inc.

; Section 5. SPECIAL TRANSLATORS * * * * * * * * * * * * * * * * * * * * *

;    The basic translation process developed in Section 4, above,
; enables the use of "special translator functions" to handle the
; translation of particular muLISP constructions. (See the functions
; TRANS-FORM, TRANS-TEST, and TRANS-EVAL.)  This section develops
; special translator functions which generate "in-line" assembly
; language for some muLISP primitive functions and special forms.

;    Corresponding to the basic translation functions which check for
; and use them, there are three types of special translators. Each
; type is called with a particular set of arguments reflecting the
; translation context information which can be used to optimize the
; translation.

;    * Form Translators:  A form translator for FN is stored as the
;      TRANS-FORM!C property of FN, and translates (FN . B) in BOTH
;      form AND evaluation contexts.  The form translator is
;      called with three arguments in the following order:
;	  (1) FFN   = the form function itself (FN in (FN . B));
;	  (2) BODY  = the "body" (= CDR) of the form (B in (FN . B));
;	  (3) RVFLG = indicator of whether or not the form must
;		      return a value.

;    * Test Translators:  A test translator for FN is stored as the
;      TRANS-TEST!C property of FN, and translates (FN . A) in BOTH
;      test AND evaluation contexts.  The test translator is
;      called with six arguments in the following order:
;	  (1) FLABEL  = the label to which the test should exit
;			if it fails (i.e., returns NIL);
;	  (2) RVF     = indicator of whether or not the test must
;			return the false (NULL) value on failure;
;	  (3) RVT     = indicator of whether or not the test must
;			return a true (NONNULL) value on success.
;	  (4) NEGATEF = indicator of whether the test should be
;			negated (i.e., have its logic inverted);
;	  (5) TFN     = the test function itself (FN in (FN . A));
;	  (6) TARGS   = the argument list (= CDR) of the test
;			(A in (FN . A)).

;    * Evaluation Translators:	An evaluation translator for FN is
;      stored as the TRANS-EVAL!C property of FN, and translates
;      (FN . A) in evaluation contexts.  The evaluation translator is
;      called with two arguments in the following order:
;	  (1) EFN    = the evaluation function itself (FN in
;		       (FN . A));
;	  (2) EARGS  = the argument list (= CDR) of the evaluation
;		       (A in (FN . A)).

; NOTE: Various other special translator functions could be added to
;	generate in-line assembly for other muLISP primitives or even
;	for other functions (e.g., MACRO constructions like LET,
;	etc.), or for other purposes completely.

; Section 5.1. Recognizer Function Translators

; Section 5.1.1. SYMBOLP

(PUT 'SYMBOLP 'TRANS-TEST!C 'TRANS-SYMBOLP-TEST!C )

(DEFUN TRANS-SYMBOLP-TEST!C (FLABEL RVF RVT NEGATEF TFN TARGS)
; Generates assembly to evaluate expression (SYMBOLP . TARGS)
; as a test.
  ; translate argument as an evaluation
  (TRANS-EVAL-TO-DI!C (CAR TARGS))
  ; translate extra arguments, if any, for effect
  (TRANS-EVALS-TO-DI!C (CDR TARGS) '(DI))
  ; assemble comparison of argument value to muLISP system
  ; variable ENDSYM
  (ASM-CMP!C 'DI <ENDSYMLOC>!C)
  ; if must return a value in false case, load DI with NIL
  (IF RVF (ASM-MOV!C 'DI (VAR!C NIL)))
  ; assemble conditional jump to FLABEL if value was ABOVE ENDSYM
  (ASM-JMP!C FLABEL 'NB NEGATEF)
  ; if must return a value in true case, load DI with T
  (IF RVT (ASM-MOV!C 'DI (VAR!C 'T))) )

; Section 5.1.2. ATOM

(PUT 'ATOM 'TRANS-TEST!C 'TRANS-ATOM-TEST!C )

(DEFUN TRANS-ATOM-TEST!C (FLABEL RVF RVT NEGATEF TFN TARGS)
; Generates assembly to evaluate expression (ATOM . TARGS) as a test.
  ; translate argument as an evaluation
  (TRANS-EVAL-TO-DI!C (CAR TARGS))
  ; translate extra arguments, if any, for effect
  (TRANS-EVALS-TO-DI!C (CDR TARGS) '(DI))
  ; assemble comparison of argument value to register DX, containing
  ; the current value of the muLISP system variable ENDATM
  (ASM-CMP!C 'DI 'DX)
  ; if must return a value in false case, load DI with NIL
  (IF RVF (ASM-MOV!C 'DI (VAR!C NIL)))
  ; assemble conditional jump to FLABEL if value was ABOVE DX
  (ASM-JMP!C FLABEL 'NB NEGATEF)
  ; if must return a value in true case, load DI with T
  (IF RVT (ASM-MOV!C 'DI (VAR!C 'T))) )

; Section 5.1.3. CONSP

(PUT 'CONSP 'TRANS-TEST!C 'TRANS-CONSP-TEST!C )

(DEFUN TRANS-CONSP-TEST!C (FLABEL RVF RVT NEGATEF TFN TARGS)
; Generates assembly to evaluate expression (CONSP . TARGS) as a
; test.
  ; translate as (NOT (CONSP . TARGS))
  (TRANS-ATOM-TEST!C FLABEL RVF RVT (NOT NEGATEF) TFN TARGS) )

; Section 5.1.4. NULL

(PUT 'NULL 'TRANS-TEST!C 'TRANS-NULL-TEST!C )

(DEFUN TRANS-NULL-TEST!C (FLABEL RVF RVT NEGATEF TFN TARGS)
; Generates assembly to evaluate expression (NULL . TARGS) as a test.
  ; if no extra arguments,
  ((NULL (CDR TARGS))
    ; translate as a NEGATED test of the argument ITSELF, and NOT
    ; returning a value if true
    (TRANS-TEST!C (CAR TARGS) FLABEL RVF NIL (NOT NEGATEF))
    ; if must return a value in true case, load DI with T
    (IF RVT (ASM-MOV!C 'DI (VAR!C 'T))) )
  ; otherwise, extra arguments, so:
  ; translate as an application of NULL,
  (TRANS-APPL-TO-DI!C TFN TARGS)
  ; followed by a standard test tail
  (COMPOSE-TEST-TAIL!C FLABEL RVF RVT NEGATEF) )

; Section 5.2. Comparator Function Translators

; Section 5.2.1. EQ

(PUT 'EQ 'TRANS-TEST!C 'TRANS-EQ-TEST!C )

(DEFUN TRANS-EQ-TEST!C (FLABEL RVF RVT NEGATEF TFN TARGS)
; Generates assembly to evaluate expression (EQ . TARGS) as a test.
  ; translate first argument as an evaluation
  (TRANS-EVAL-TO-DI!C (CAR TARGS))
  ; push the resulting value onto the variable stack
  (ASM-PUSHVAR!C 'DI)
  ; translate second argument as an evaluation
  (TRANS-EVAL-TO-DI!C (CADR TARGS))
  ; translate extra arguments, if any, for effect
  (TRANS-EVALS-TO-DI!C (CDDR TARGS) '(DI))
  ; assemble pop of first argument value to register SI
  (ASM-POPVAR!C 'SI)
  ; assemble comparison of the argument values
  (ASM-CMP!C 'SI 'DI)
  ; if must return a value in false case, load DI with NIL
  (IF RVF (ASM-MOV!C 'DI (VAR!C NIL)))
  ; assemble conditional jump to FLABEL if values were NOT EQ
  (ASM-JMP!C FLABEL 'NE NEGATEF)
  ; if must return a value in true case, load DI with T
  (IF RVT (ASM-MOV!C 'DI (VAR!C 'T))) )

; Section 5.2.2. NEQ

(PUT 'NEQ 'TRANS-TEST!C 'TRANS-NEQ-TEST!C )

(DEFUN TRANS-NEQ-TEST!C (FLABEL RVF RVT NEGATEF TFN TARGS)
; Generates assembly to evaluate expression (NEQ . TARGS) as a test.
  ; translate as (NOT (EQ . TARGS))
  (TRANS-EQ-TEST!C FLABEL RVF RVT (NOT NEGATEF) TFN TARGS) )

; Section 5.3. Logical Function Translators

; Section 5.3.1. NOT

(PUT 'NOT 'TRANS-TEST!C 'TRANS-NULL-TEST!C )

; Section 5.3.2. AND

(PUT 'AND 'TRANS-EVAL!C 'TRANS-AND!C )

(DEFUN TRANS-AND!C (EFN CONJS)
; Generates assembly to evaluate expression (AND . CONJS) to DI.
  ; if no conjuncts, assemble return of T
  ((NULL CONJS)
    (ASM-MOV!C 'DI (VAR!C 'T)) )
  ; otherwise, at least one conjunct, so:
  (LET ((lbl (MK-LABEL!C)) )
	; = local label for end of AND
    (LOOP
      ; if last conjunct,
      ((NULL (CDR CONJS))
	; translate it as an evaluation, and place the end label
	(TRANS-EVAL-TO-DI!C (CAR CONJS))
	(ASM-LBL!C lbl) )
      ; otherwise, translate next conjunct as an evaluation
      (TRANS-EVAL-TO-DI!C (POP CONJS))
      ; assemble compare of resulting value to NIL
      (ASM-CMP!C 'DI (VAR!C NIL))
      ; assemble conditional jump to end if EQ to NIL
      (ASM-JMP!C lbl 'E) ) ) )

; Section 5.3.3. OR

(PUT 'OR 'TRANS-EVAL!C 'TRANS-OR!C )

(DEFUN TRANS-OR!C (EFN DISJS)
; Generates assembly to evaluate expression (OR . DISJS) to DI.
  ; if no disjuncts, assemble return of NIL
  ((NULL DISJS)
    (ASM-MOV!C 'DI (VAR!C NIL)) )
  ; otherwise, at least one disjunct
  (LET ((lbl (MK-LABEL!C)) )
	; = local label for end of OR
    (LOOP
      ; if last disjunct,
      ((NULL (CDR DISJS))
	; translate as an evaluation, and place the end label
	(TRANS-EVAL-TO-DI!C (CAR DISJS))
	(ASM-LBL!C lbl) )
      ; otherwise, translate next disjunct as an evaluation
      (TRANS-EVAL-TO-DI!C (POP DISJS))
      ; assemble compare of resulting value to NIL
      (ASM-CMP!C 'DI (VAR!C NIL))
      ; assemble conditional jump to end if NOT EQ to NIL
      (ASM-JMP!C lbl 'NE) ) ) )

; Section 5.4. Assignment Function Translators

; Section 5.4.1. SETQ

(PUT 'SETQ 'TRANS-EVAL!C 'TRANS-SETQ!C )

(DEFUN TRANS-SETQ!C (EFN *SETARGS*!C)
; Generates assembly to evaluate expression (SETQ . *SETARGS*!C)
; to DI.  (*SETARGS*!C is a special variable so it can be accessed
; in TRANS-SETQ-AUX!C for reference in a compilation error message.)
  (LET ((endlabel (MK-LABEL!C)))
	; = local label for end of SETQ
    ; translate the SETQ and place the end label
    (TRANS-SETQ-AUX!C *SETARGS*!C endlabel)
    (ASM-LBL!C endlabel) ) )

(DEFUN TRANS-SETQ-AUX!C (VELIST ENDLABEL)
; Performs the SETQ translation of the variable-expression list,
; VELIST, for TRANS-SETQ
  ; if the VELIST is NIL, do nothing
  ((NULL VELIST) )
  ; if (CAR VELIST) is a symbol,
  ((SYMBOLP (CAR VELIST))
    ; translate (CADR VELIST) as an evaluation
    (TRANS-EVAL-TO-DI!C (CADR VELIST))
    ; if (CAR VELIST) is NOT NIL,
    ((IDENTITY (CAR VELIST))
      ; assemble check of throw flag
      (ASM-CMP!C <THRFLGLOC>!C 0)
      ; assemble conditional jump to ENDLABEL if active throw
      (ASM-JMP!C ENDLABEL 'NE)
      ; assemble assignment of (CAR VELIST) to the value in DI,
      (ASM-MOV!C (SYMBOL-DEST-OPND!C (CAR VELIST)) 'DI)
      ; and translate the rest of the SETQ
      (TRANS-SETQ-AUX!C (CDDR VELIST) ENDLABEL) )
    ; otherwise, (CAR VELIST) is NIL, so:
    ; make no assignment, but translate the rest of the SETQ
    ; (NOTE: (CADR VELIST) HAS been evaluated for effect here)
    (TRANS-SETQ-AUX!C (CDDR VELIST) ENDLABEL) )
  ; otherwise, compilation error:
  (COMPILE-ERR!C (CONS 'SETQ *SETARGS*!C) "Nonsymbolic Argument") )

; Section 5.4.2. PSETQ

(PUT 'PSETQ 'TRANS-EVAL!C 'TRANS-PSETQ!C )

(DEFUN TRANS-PSETQ!C (EFN *SETARGS*!C)
; Generates assembly to evaluate expression (PSETQ . *SETARGS*!C)
; to DI.  (*SETARGS*!C is a special variable so it can be accessed
; in TRANS-PSETQ-AUX!C for reference in a compilation error message.)
  (LET ((endlabel (MK-LABEL!C)))
	; = local label for end of PSETQ
    ; translate the PSETQ and place the end label
    (TRANS-PSETQ-AUX!C *SETARGS*!C 0 endlabel)
    (ASM-LBL!C endlabel) ) )

(DEFUN TRANS-PSETQ-AUX!C (VELIST NPSETQS ENDLABEL)
; Performs the PSETQ translation of the variable-expression list,
; VELIST, for TRANS-PSETQ
  ; if the VELIST is NIL,
  ((NULL VELIST)
    (LET ((setlabel (MK-LABEL!C)))
	  ; = local label for jump-around
      ; assemble check of throw flag
      (ASM-CMP!C <THRFLGLOC>!C 0)
      ; assemble conditional jump-around to setlabel if NO
      ; active throw
      (ASM-JMP!C setlabel 'E)
      ; assemble BP adjustment to DROP PSETQ values from stack
      (ASM-SUB!C 'BP (* 2 NPSETQS))
      ; assemble jump to ENDLABEL to skip assignments
      (ASM-JMP!C ENDLABEL)
      ; place local setlabel
      (ASM-LBL!C setlabel) ) )
  ; if (CAR VELIST) is a symbol,
  ((SYMBOLP (CAR VELIST))
    ; translate (CADR VELIST) as an evaluation
    (TRANS-EVAL-TO-DI!C (CADR VELIST))
    ; if (CAR VELIST) is NOT NIL,
    ((IDENTITY (CAR VELIST))
      ; assemble push of resulting value onto stack
      (ASM-PUSHVAR!C 'DI)
      ; translate rest of PSETQ evaluations
      (TRANS-PSETQ-AUX!C (CDDR VELIST) (ADD1 NPSETQS) ENDLABEL)
      ; assemble pop of previously computed value into SI
      (ASM-POPVAR!C 'SI)
      ; assemble assignment of (CAR VELIST) to that value
      (ASM-MOV!C (SYMBOL-DEST-OPND!C (CAR VELIST)) 'SI) )
    ; otherwise, (CAR VELIST) is NIL, so:
    ; make no assignment, but translate the rest of the PSETQ
    ; (NOTE: (CADR VELIST) HAS been evaluated for effect here)
    (TRANS-PSETQ-AUX!C (CDDR VELIST) NPSETQS ENDLABEL) )
  ; otherwise, compilation error:
  (COMPILE-ERR!C (CONS 'PSETQ *SETARGS*!C) "Nonsymbolic Argument") )

; Section 5.4.3. POP

(PUT 'POP 'TRANS-EVAL!C 'TRANS-POP!C )

(DEFUN TRANS-POP!C (EFN EARGS)
; Generates assembly to evaluate expression (POP . EARGS) to DI.
  ; if (CAR EARGS) is symbol,
  ((SYMBOLP (CAR EARGS))
    ; if (CAR EARGS) is NOT NIL,
    ((IDENTITY (CAR EARGS))
      ; load (CAR EARGS) to SI UNevaluated
      (TRANS-LOAD-TO-REG!C 'SI (CAR EARGS))
      ; assemble call of DPOP1 service through PJMPAX service
      (ASM-MOV!C 'AX (CSMEMORY (SVC-ADDR!C <DPOP1SVC>!C) NIL T))
      (ASM-CALL!C <PJMPAXSVC>!C) )
    ; otherwise, (CAR EARGS) is NIL, so assemble return of NIL
    (ASM-MOV!C 'DI (VAR!C NIL)) )
  ; otherwise, compilation error
  (COMPILE-ERR!C (CONS 'POP EARGS) "Nonsymbolic Argument") )

; Section 5.4.4. PUSH

(PUT 'PUSH 'TRANS-EVAL!C 'TRANS-PUSH!C )

(DEFUN TRANS-PUSH!C (EFN EARGS)
; Generates assembly to evaluate expression (PUSH . EARGS) to DI.
  ; if (CADR EARGS) is symbol,
  ((SYMBOLP (CADR EARGS))
    ; if (CADR EARGS) is NOT NIL,
    ((IDENTITY (CADR EARGS))
      ; translate (CAR EARGS) as an evaluation
      (TRANS-EVAL-TO-DI!C (CAR EARGS))
      ; assemble move of resulting value to SI
      (ASM-MOV!C 'SI 'DI)
      ; load (CADR EARGS) to DI UNevaluated
      (TRANS-LOAD-TO-REG!C 'DI (CADR EARGS))
      ; assemble call to SPUSH1 service
      (ASM-CALL!C <SPUSH1SVC>!C) )
    ; otherwise, (CADR EARGS) is NIL, so assemble return of NIL
    (ASM-MOV!C 'DI (VAR!C NIL)) )
  ; otherwise, compilation error
  (COMPILE-ERR!C (CONS 'PUSH EARGS) "Nonsymbolic Argument") )

; Section 5.5. Numerical Function Translators

; Section 5.5.1. INCQ

(PUT 'INCQ 'TRANS-EVAL!C 'TRANS-INCQ!C )

(DEFUN TRANS-INCQ!C (EFN EARGS)
; Generates assembly to evaluate expression (INCQ . EARGS) to DI.
  ; if NO increment supplied,
  ((NULL (CADR EARGS))
    ; translate with default increment of 1
    (TRANS-INCQ!C EFN (LIST (CAR EARGS) 1)) )
  ; if (CAR EARGS) is symbol,
  ((SYMBOLP (CAR EARGS))
    ; translate (CADR EARGS), the increment, as an evaluation
    (TRANS-EVAL-TO-DI!C (CADR EARGS))
    ; load (CAR EARGS) to SI UNevaluated
    (TRANS-LOAD-TO-REG!C 'SI (CAR EARGS))
    ; load AX with the entry point to +
    (ASM-MOV!C 'AX (GETD '+))
    ; call the SINCQ1 service
    (ASM-CALL!C <SINCQ1SVC>!C) )
  ; otherwise, compilation error:
  (COMPILE-ERR!C (CONS 'INCQ EARGS) "Nonsymbolic Argument") )

; Section 5.5.2. DECQ

(PUT 'DECQ 'TRANS-EVAL!C 'TRANS-DECQ!C )

(DEFUN TRANS-DECQ!C (EFN EARGS)
; Generates assembly to evaluate expression (DECQ . EARGS) to DI.
  ; if NO decrement supplied,
  ((NULL (CADR EARGS))
    ; translate with default decrement of 1
    (TRANS-DECQ!C EFN (LIST (CAR EARGS) 1)) )
  ; if (CAR EARGS) is symbol,
  ((SYMBOLP (CAR EARGS))
    ; translate (CADR EARGS), the decrement, as an evaluation
    (TRANS-EVAL-TO-DI!C (CADR EARGS))
    ; load (CAR EARGS) to SI UNevaluated
    (TRANS-LOAD-TO-REG!C 'SI (CAR EARGS))
    ; load AX with the entry point to -
    (ASM-MOV!C 'AX (GETD '-))
    ; call the SINCQ1 service
    (ASM-CALL!C <SINCQ1SVC>!C) )
  ; otherwise, compilation error:
  (COMPILE-ERR!C (CONS 'DECQ EARGS) "Nonsymbolic Argument") )

; Section 5.6. Control Construct Translators

; Section 5.6.1. QUOTE

(PUT 'QUOTE 'TRANS-EVAL!C 'TRANS-QUOTE!C )

(DEFUN TRANS-QUOTE!C (EFN EARGS)
; Generates assembly to evaluate expression (QUOTE . EARGS) to DI.
  ; translate as load of first argument to DI, ignoring any extra
  ; arguments
  (TRANS-LOAD-TO-REG!C 'DI (CAR EARGS)) )

; Section 5.6.2. PROGN

(PUT 'PROGN 'TRANS-FORM!C 'TRANS-PROGN!C )

(DEFUN TRANS-PROGN!C (FFN FORMS RVFLG)
; Generates assembly to evaluate expression (PROGN . FORMS)
; as a form.
  (TRANS-IMPLICIT-PROGN!C FORMS RVFLG) )

; Section 5.6.3. LOOP

(PUT 'LOOP 'TRANS-FORM!C 'TRANS-LOOP!C )

(DEFUN TRANS-LOOP!C (FFN LOOPBODY RVFLG)
; Generates assembly to evaluate expression (LOOP . LOOPBODY)
; as a form.
  (LET ((looplabel (MK-LABEL!C))
	; = local label for start of loop
	(exitlabel (MK-LABEL!C)) )
	; = local label for end of loop
    ; place local start label
    (ASM-LBL!C looplabel)
    ; assemble check for active throw
    (ASM-CMP!C <THRFLGLOC>!C 0)
    ; assemble conditional jump to exitlabel if active throw
    (ASM-JMP!C exitlabel 'NE)
    ; translate the forms in LOOPBODY as a sequence which
    ; exits to exitlabel, and which returns a value in DI in
    ; accordance with RVFLG
    (TRANS-SEQ!C LOOPBODY exitlabel RVFLG)
    ; assemble jump to start of loop
    (ASM-JMP!C looplabel)
    ; place local end label
    (ASM-LBL!C exitlabel) ) )

; Section 5.6.4. PROG1

(PUT 'PROG1 'TRANS-FORM!C 'TRANS-PROG1!C )

(DEFUN TRANS-PROG1!C (FFN FORMS RVFLG)
; Generates assembly to evaluate expression (PROG1 . FORMS)
; as a form.
  (LET ((endlabel (MK-LABEL!C)) )
	; = local label for end of PROG1
    ; translate the first form in the PROG1 body as a form
    ; which exits to endlabel, and which must return a value
    (TRANS-FORM!C (CAR FORMS) endlabel T T)
    ; assemble a push of the resulting value
    (ASM-PUSHVAR!C 'DI)
    ; translate the other forms in the PROG1 body, if any, as a
    ; sequence which exits to endlabel, and which need NOT return
    ; a value in DI
    (IF (CDR FORMS) (TRANS-SEQ!C (CDR FORMS) endlabel NIL) )
    ; place the local endlabel
    (ASM-LBL!C endlabel)
    ; assemble a pop of the value of the first form
    (ASM-POPVAR!C 'DI) ) )

; Section 5.6.5. IDENTITY

(PUT 'IDENTITY 'TRANS-EVAL!C 'TRANS-IDENTITY!C )

(DEFUN TRANS-IDENTITY!C (EFN EARGS)
; Generates assembly to evaluate expression (IDENTITY . EARGS) to DI.
  ; if no extra arguments,
  ((NULL (CDR EARGS))
    ; translate as an evaluation of the single argument
    (TRANS-EVAL-TO-DI!C (CAR EARGS)) )
  ; otherwise, extra arguments, so:
  ; translate as an application of IDENTITY
  (TRANS-APPL-TO-DI!C EFN EARGS) )

; Section 5.6.6. IF

(PUT 'IF 'TRANS-FORM!C 'TRANS-IF!C )

(DEFUN TRANS-IF!C (FFN BODY RVFLG)
; Generates assembly to evaluate expression (IF . BODY) as a form.
  ; if BODY is NIL, assemble return of NIL
  ((NULL BODY)
    (ASM-MOV!C 'DI (VAR!C NIL)) )
  ; if test, but no actions,
  ((NULL (CDR BODY))
    ; translate test as an evaluation for effect,
    (TRANS-EVAL-TO-DI!C (CAR BODY))
    ; and assemble return of NIL
    (ASM-MOV!C 'DI (VAR!C NIL)) )
  ; otherwise, at least a test and a true action, so convert to
  ; muLISP implicit COND form and translate as an implicit PROGN
  (LET ((ifbody (FIRSTN 3 BODY))
	(test (CAR BODY)) )
    (IF (ATOM test) (SETQ test (LIST 'IDENTITY test)))
    (TRANS-IMPLICIT-PROGN!C (CONS (LIST test (CADR ifbody))
		       (CDDR ifbody))
		 RVFLG) ) )

; Section 5.6.7. COND

(PUT 'COND 'TRANS-FORM!C 'TRANS-COND!C )

(DEFUN TRANS-COND!C (FFN CONDS RVFLG)
; Generates assembly to evaluate expression (COND . CONDS)
; as a form.
  (LET ((endlabel (MK-LABEL!C)) )
	; = local label for end of COND
    ; if no clauses, assemble return on NIL, and place endlabel
    ((NULL CONDS)
      (ASM-MOV!C 'DI (VAR!C NIL))
      (ASM-LBL!C endlabel) )
    ; otherwise, loop through the clauses
    (LOOP
      ; if at last clause,
      ((NULL (CDR CONDS))
	; translate last clause to exit to endlabel, and
	; return a value per RVFLG, whether true or false
	(TRANS-CLAUSE!C (CAR CONDS) endlabel RVFLG RVFLG) )
      ; otherwise, translate next clause to exit to endlabel, and
      ; return a value per RVFLG ONLY if true
      (TRANS-CLAUSE!C (POP CONDS) endlabel NIL RVFLG) )
    ; place local endlabel
    (ASM-LBL!C endlabel) ) )

; Section 5.6.8. COMMENT

(PUT 'COMMENT 'TRANS-EVAL!C 'TRANS-COMMENT!C )

(DEFUN TRANS-COMMENT!C (EFN CMTS)
; Generates assembly to return the value NIL in DI.  For comments
; of the form (COMMENT CHECK-CONSOLE), first generates assembly
; to invoke the console interrupt trap service.
  ; check for special comments:
    ; if first comment is a symbol, then
  ( ((SYMBOLP (CAR CMTS))
      ; if the symbol is "CHECK-CONSOLE",
      ((EQ (STRING-UPCASE (CAR CMTS)) 'CHECK-CONSOLE)
	; assemble call to interrupt trap check service, through
	; PJMPAX for throw protection
	(ASM-MOV!C 'AX (CSMEMORY (SVC-ADDR!C <ITRTRPSVC>!C) NIL T))
	(ASM-CALL!C <PJMPAXSVC>!C) ) ) )
  ; assemble a return of NIL
  (ASM-MOV!C 'DI (VAR!C NIL)) )

; Section 5.6.9. RETURN

(PUT 'RETURN 'TRANS-EVAL!C 'TRANS-RETURN!C )

(DEFUN TRANS-RETURN!C (EFN EARGS)
; Generates assembly to evaluate expression (RETURN . EARGS) to DI.
  ; translate first argument as evaluation
  (TRANS-EVAL-TO-DI!C (CAR EARGS))
  ; translate extra arguments, if any, for effect
  (TRANS-EVALS-TO-DI!C (CDR EARGS) '(DI))
  ; prepare the stack for exiting the function
  (LET ((vstk *VARSTACK*!C)
	; = local version of *VARSTACK*!C which can be modified
	;   WITHOUT affecting *VARSTACK*!C
	(nargs (LENGTH *ARGLIST*!C))
	; = number of arguments of *FN*!C
	(npops 0) )
	; = number of POPs of vstk so far
    (LOOP
      ; if vstk now has LENGTH nargs,
      ((EQL (LENGTH vstk) nargs)
	; adjust BP for the number of POPs so far
	(ASM-SUB!C 'BP (* 2 npops)) )
      ; if (CAR vstk) is a symbol, (i.e., NOT <ARBVAL>!C)
      (IF (SYMBOLP (CAR vstk))
	  ; unbind it
	  (ASM-UNBINDVAR!C (CAR vstk)) )
      ; POP vstk and increment npops
      (POP vstk)
      (INCQ npops) ) )
  ; assemble jump to *FN*!C's exit label
  (ASM-JMP!C *EXIT-LABEL*!C) )

