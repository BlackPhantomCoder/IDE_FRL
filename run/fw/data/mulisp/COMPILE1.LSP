; File: COMPILE1.LSP  (c)	01/29/87	Soft Warehouse, Inc.

; Section 4. TRANSLATION PROCESS * * * * * * * * * * * * * * * * * * * * *

;    This section develops the process by which muLISP functions are
; translated into assembly language instructions.  Building on the
; translation machinery developed in Section 3, the translation
; process involves functions to translate: muLISP functions (4.1),
; sequences of muLISP forms (4.2), muLISP forms themselves (4.3),
; muLISP tests (4.4), muLISP evaluations (4.5), and loads (4.6).

;    As will be seen, these various types of translators reflect the
; the different contexts in which muLISP expressions are encountered
; during translation, and also provide opportunities for special
; treatment and optimization based on information about that context.

; Section 4.1. Function Translator

;    The function translator is the top level of the translation
; process, considered as the first step in compilation.

(DEFUN TRANS-FN!C (*FN*!C *DEFN*!C)
; Translates *FN*!C with definition *DEFN*!C into a list of assembly
; language instructions which is returned.
  ; if *FN*!C has a special function translator,
  (IF (GET *FN*!C 'TRANS-FN!C)
      ; set *DEFN*!C to the form "(LAMBDA NIL)" to force the
      ; values of *ARGSPEC*!C, *ARGLIST*!C, and *VARSTACK*!C
      ; to be NIL
      (SETQ *DEFN*!C (LIST 'LAMBDA NIL)) )
  ; if *DEFN*!C is an atom, or a list whose CAR is NOT LAMBDA,
  ((OR (ATOM *DEFN*!C)
       (NEQ (CAR *DEFN*!C) 'LAMBDA) )
    ; compilation error:
    (COMPILE-ERR!C *FN*!C "Non-eval Function") )
  ; Set up translation context and generate assembly for *DEFN*!C
  (LET* ((*ARGSPEC*!C (CADR *DEFN*!C))
	 ; = argument specification of *FN*!C from *DEFN*!C
	 (*ARGLIST*!C (IF (LISTP *ARGSPEC*!C) *ARGSPEC*!C
					  (LIST *ARGSPEC*!C)))
	 ; = LIST of arguments in *ARGSPEC*!C
	 (*VARSTACK*!C (REVERSE *ARGLIST*!C))
	 ; = variable stack contents during function execution
	 (*LBLINDEX*!C 0)
	 ; = numerical index of last assembly label
	 (*EXIT-LABEL*!C (MK-LABEL!C))
	 ; = label for function exit
	 (*FNASM*!C (TCONC (CONS) *FN*!C)) )
	 ; = variable for collecting assembly instructions
    ; if *FN*!C has a special function translator,
    ((GET *FN*!C 'TRANS-FN!C)
      ; use it to translate *FN*!C in the context established
      (FUNCALL (GET *FN*!C 'TRANS-FN!C) *FN*!C)
      ; return the assembly instructions collected
      (CAR *FNASM*!C) )
    ; compose standard entry to the function
    (COMPOSE-FN-ENTRY!C)
    ; translate the forms in the body of *DEFN*!C as a sequence
    ; which exits to *EXIT-LABEL*!C, and which must return a value.
    (TRANS-SEQ!C (CDDR *DEFN*!C) *EXIT-LABEL*!C T)
    ; compose standard exit from the function
    (COMPOSE-FN-EXIT!C)
    ; return the assembly instructions collected
    (CAR *FNASM*!C) ) )

; Section 4.1.1. Function Entry Composer

(DEFUN COMPOSE-FN-ENTRY!C NIL
; Generates standard assembly language sequence to enter *FN*!C
  ; if LAMBDA/Spread function,
  ((LISTP *ARGSPEC*!C)
    ; MOV 2*(# arguments) to AX
    (ASM-MOV!C 'AX (* 2 (LENGTH *ARGLIST*!C)))
    ; call LAMBDA/Spread entry service
    (ASM-CALL!C <E-L/S-SVC>!C)
    ; bind all arguments
    (MAPC 'ASM-BINDVAR!C *ARGLIST*!C) )
  ; otherwise, call LAMBDA/No-spread entry service
  (ASM-CALL!C <E-L/NS-SVC>!C)
  ; bind single argument
  (ASM-BINDVAR!C *ARGSPEC*!C) )

; Section 4.1.2. Function Exit Composer

(DEFUN COMPOSE-FN-EXIT!C NIL
; Generates standard assembly language sequence to exit *FN*!C
  ; if *VARSTACK*!C is still compatible with *ARGLIST*!C,
  ((EQUAL *ARGLIST*!C (REVERSE *VARSTACK*!C))
    ; place the *EXIT-LABEL*!C
    (ASM-LBL!C *EXIT-LABEL*!C)
    ; unbind all arguments
    (MAPC 'ASM-UNBINDVAR!C *ARGLIST*!C)
    ; drop the stacked arguments
    (ASM-SUB!C 'BP (* 2 (LENGTH *VARSTACK*!C)))
    ; assemble the RETurn from the function
    (ASM-RET!C) )
  ; INTERNAL-ERR @ COMPOSE-FN-EXIT!C: incompatible *VARSTACK*!C
  (INTERNAL-ERR!C 2010 1 *VARSTACK*!C *ARGLIST*!C) )

; Section 4.2. Sequence Translator

;    The sequence translator handles lists of muLISP expressions
; encountered as the body of an implicit or explicit PROGN, as the
; actions of an implicit or explicit COND, as the body of a LOOP or
; other primitive muLISP control construct, and so forth.  In these
; contexts, there will be a label to which forms in the sequence
; should exit, and an indication of whether the sequence must return
; a value.  The translation of the sequence and its component forms
; can be optimized based on this information.

(DEFUN TRANS-SEQ!C (SEQ ENDLABEL RVFLG)
; Generates assembly to evaluate SEQ as a sequence of muLISP forms
; which should exit to ENDLABEL.  RVFLG indicates whether the
; sequence must return a value in DI.
  (LOOP
    ; if (CAR SEQ) is the last form in the sequence,
    ((NULL (CDR SEQ))
      ; translate as a form which exits to ENDLABEL, and which must
      ; return a value per RVFLG whether or not it exits
      (TRANS-FORM!C (POP SEQ) ENDLABEL RVFLG RVFLG) )
    ; otherwise, translate as form which exits to ENDLABEL, and which
    ; must return a value per RVFLG ONLY if it exits
    (TRANS-FORM!C (POP SEQ) ENDLABEL NIL RVFLG) ) )

; Section 4.3. Form Translators

;    The form translators handle muLISP expressions encountered as
; members of sequences.  Such expressions may be atoms, function
; applications, LAMBDA body applications, implicit CONDs, or implicit
; PROGNs.  In the context of a sequence, there will always be a label
; to which the form may possibly exit, and indications of whether the
; form itself, or the sequence of which it is a part, should return
; a value.  The translation of the form can be optimized based on
; this information.

(DEFUN TRANS-FORM!C (FORM ENDLABEL RVFORM RVSEQ cfn)
; Generates assembly to evaluate FORM as a muLISP form which should
; exit to ENDLABEL.  RVFORM and RVSEQ indicate, respectively, whether
; the form, or the sequence of which it is a part, must return a
; value in DI.
  ; if FORM is an atom,
  ((ATOM FORM)
    ; translate as an evaluation
    (TRANS-EVAL-TO-DI!C FORM) )
  ; if (CAR FORM) is an atom, then
  ((ATOM (CAR FORM))
    ; if (CAR FORM) has a special form-translator, cfn,
    ((SETQ cfn (GET (CAR FORM) 'TRANS-FORM!C))
      ; use cfn to translate FORM
      (FUNCALL cfn (CAR FORM) (CDR FORM) RVFORM) )
    ; otherwise, translate as an evaluation
    (TRANS-EVAL-TO-DI!C FORM) )
  ; if (CAAR FORM) is an atom, then
  ((ATOM (CAAR FORM))
    ; if (CAR FORM) is a LAMBDA body,
    ((MEMBER (CAAR FORM) <LAMBDA-TYPES>!C)
      ; translate as an evaluation
      (TRANS-EVAL-TO-DI!C FORM) )
    ; otherwise, translate as an implicit COND clause
    (TRANS-CLAUSE!C FORM ENDLABEL RVFORM RVSEQ) )
  ; if (CAAR FORM) is a LAMBDA body,
  ((MEMBER (CAAAR FORM) <LAMBDA-TYPES>!C)
    ; translate as an implicit COND clause
    (TRANS-CLAUSE!C FORM ENDLABEL RVFORM RVSEQ) )
  ; otherwise, translate as an implicit PROGN
  (TRANS-IMPLICIT-PROGN!C FORM RVFORM) )

(DEFUN TRANS-CLAUSE!C (CLSE TLABEL RVTEST RVACNS)
; Generates assembly to evaluate CLSE as a COND clause consisting of
; a test and sequence of actions (possibly null).  TLABEL is the label
; to which control should transfer after CLSE's test is found to be
; non-null, and its sequence of actions (if any) is executed.  RVTEST
; and RVACNS indicate, respectively, whether CLSE's test or sequence
; of actions must return a value in DI.
  (LET ((flabel (MK-LABEL!C)) )
	; = local label for fail case
    ; if CLSE has a test but no actions,
    ( ((NULL (CDR CLSE))
	; translate the test to return false/true values according to
	; RVTEST and RVACNS
	(TRANS-TEST!C (CAR CLSE) flabel RVTEST RVACNS) )
      ; otherwise, translate the test and the sequence of actions
      (TRANS-TEST!C (CAR CLSE) flabel RVTEST NIL)
      (TRANS-SEQ!C (CDR CLSE) TLABEL RVACNS) )
    ; assemble a jump to TLABEL
    (ASM-JMP!C TLABEL)
    ; place the local flabel
    (ASM-LBL!C flabel) ) )

(DEFUN TRANS-IMPLICIT-PROGN!C (PGN RVFLG)
; Generates assembly to evaluate PGN as a muLISP implicit PROGN.
; RVFLG indicates whether the implicit PROGN must return a value
; in DI.
  (LET ((endlabel (MK-LABEL!C)) )
	; = local label for end of implicit PROGN
    ; translate PGN as a sequence which exits to endlabel, and
    ; returns a value in accordance with RVFLG
    (TRANS-SEQ!C PGN endlabel RVFLG)
    ; assemble local endlabel
    (ASM-LBL!C endlabel) ) )

; Section 4.4. Test Translators

;    The test translator handles muLISP expressions encountered as the
; CAR of an implicit or explicit COND or IF.  In this context, there
; will always be a label to which the test should exit if it fails
; (i.e., returns NIL), indications of whether the test must return
; false (NULL) or true (NONNULL) values, and an indication of whether
; the test is negated.	The translation of tests can be optimized
; based on this information.

(DEFUN TRANS-TEST!C (TEST FLABEL RVF RVT NEGATEF cfn)
; Generates assembly to evaluate TEST as a test which should exit to
; FLABEL if it fails.  RVF and RVT indicate, respectively, whether the
; test should return false or true values in DI.  NEGATEF indicates
; whether the test is negated (and thus should have its logic
; inverted).
  ; if TEST is an atom,
  ((ATOM TEST)
    ; translate as a basic test
    (TRANS-BASIC-TEST!C TEST FLABEL RVF RVT NEGATEF) )
  ; if (CAR TEST) is an atom, then
  ((ATOM (CAR TEST))
    ; if (CAR TEST) has a special test-translator, cfn,
    ((SETQ cfn (GET (CAR TEST) 'TRANS-TEST!C))
      ; use cfn to translate TEST
      (FUNCALL cfn FLABEL RVF RVT NEGATEF (CAR TEST) (CDR TEST)) )
    ; if (CAR TEST) is a MACRO,
    ((IS-MACRO!C (CAR TEST))
      ; translate the expansion of TEST as a test
      (TRANS-TEST!C (MACROEXPAND TEST) FLABEL RVF RVT NEGATEF) )
    ; otherwise, translate as a basic test
    (TRANS-BASIC-TEST!C TEST FLABEL RVF RVT NEGATEF) )
  ; if (CAR TEST) is a LAMBDA body,
  ((MEMBER (CAAR TEST) <LAMBDA-TYPES>!C)
    ; translate as a basic test
    (TRANS-BASIC-TEST!C TEST FLABEL RVF RVT NEGATEF) )
  ; otherwise, compilation error:
  (COMPILE-ERR!C TEST "Undefined Function Call") )

(DEFUN TRANS-BASIC-TEST!C (TEST FLABEL RVF RVT NEGATEF)
; Auxilliary function to translate basic tests.
  ; translate TEST as an evaluation
  (TRANS-EVAL-TO-DI!C TEST)
  ; compose standard test "tail"
  (COMPOSE-TEST-TAIL!C FLABEL RVF RVT NEGATEF) )

(DEFUN COMPOSE-TEST-TAIL!C (FLABEL RVF RVT NEGATEF)
; Composes a "standard test tail" to return values and transfer
; control, given a test result in DI.  Optimizes the assembly for the
; particular values to be returned in accordance with RVF and RVT.
  ; if values need NOT be returned in the false case,
  ((NOT RVF)
    ; compare value in DI to NIL, and jump to FLABEL if NOT EQ
    (ASM-CMP!C 'DI (VAR!C NIL))
    (ASM-JMP!C FLABEL 'E NEGATEF) )
  ; if values need NOT be returned in the true case,
  ((NOT RVT)
    ; compare value in DI to NIL, load DI with NIL, and jump
    ; to FLABEL if DI was NOT NIL
    (ASM-CMP!C 'DI (VAR!C NIL))
    (ASM-MOV!C 'DI (VAR!C NIL))
    (ASM-JMP!C FLABEL 'E NEGATEF) )
  ; otherwise, move test result from DI to AX, load DI with NIL,
  ; compare AX to DI (= NIL), jump to FLABEL if NOT NIL, and move AX
  ; back to DI to return it
  (ASM-MOV!C 'AX 'DI)
  (ASM-MOV!C 'DI (VAR!C NIL))
  (ASM-CMP!C 'AX 'DI)
  (ASM-JMP!C FLABEL 'E NEGATEF)
  (ASM-MOV!C 'DI 'AX) )

; Section 4.5. Evaluation Translators

;    The evaluation translators handle muLISP expressions encountered
; in evaluation contexts.  This includes the evaluation of atoms,
; function applications, and LAMBDA body applications in just about
; any context.	Most of the more specialized translators introduced
; above rely on evaluation translators except in some specialized
; cases based on translation context information.   Because of their
; breadth, evaluation translators cannot count on using particular
; translation context information for optimization.

; Section 4.5.1. Translate Evaluation to DI

(DEFUN TRANS-EVAL-TO-DI!C (EXPR cfn)
; Generates assembly to evaluate EXPR, returning the value in DI.
  ; if EXPR is an atom, then
  ((ATOM EXPR)
    ; if EXPR is a symbol,
    ((SYMBOLP EXPR)
      ; move its value to DI
      (ASM-MOV!C 'DI (SYMBOL-SRC-OPND!C EXPR)) )
    ; otherwise, EXPR is a number, so install a compiler constant
    ; symbol for it, and move the value of that symbol to DI
    (ASM-MOV!C 'DI (VAL!C (INSTALL-CONST!C EXPR))) )
  ; if (CAR EXPR) is an atom, then
  ((ATOM (CAR EXPR))
    ; if (CAR EXPR) is a CXR function (i.e., CAR, CDR, ..., CDDDDR),
    ((IS-CXRFN!C (CAR EXPR))
      ; translate as a CXR
      (TRANS-CXR-TO-DI!C (CAR EXPR) (CDR EXPR)) )
    ; if (CAR EXPR) has a special evaluation-translator, cfn,
    ((SETQ cfn (GET (CAR EXPR) 'TRANS-EVAL!C))
      ; use cfn to translate EXPR
      (FUNCALL cfn (CAR EXPR) (CDR EXPR)) )
    ; if (CAR EXPR) has a special test-translator, cfn,
    ((SETQ cfn (GET (CAR EXPR) 'TRANS-TEST!C))
      (LET ((lbl (MK-LABEL!C)) )
	    ; = local label for fail case
	; use cfn to translate EXPR as a test which returns a value
	; in all cases, and fails to lbl,
	(FUNCALL cfn lbl T T NIL (CAR EXPR) (CDR EXPR))
	; and place the local fail label
	(ASM-LBL!C lbl) ) )
    ; if (CAR EXPR) has a special form-translator, cfn,
    ((SETQ cfn (GET (CAR EXPR) 'TRANS-FORM!C))
      ; use it to translate EXPR as a form which returns a value
      (FUNCALL cfn (CAR EXPR) (CDR EXPR) T) )
    ; if (CAR EXPR) is a MACRO,
    ((IS-MACRO!C (CAR EXPR))
      ; translate its expansion as an evaluation
      (TRANS-EVAL-TO-DI!C (MACROEXPAND EXPR)) )
    ; otherwise, translate as a function application
    (TRANS-APPL-TO-DI!C (CAR EXPR) (CDR EXPR)) )
  ; if (CAR EXPR) is a LAMBDA body,
  ((MEMBER (CAAR EXPR) <LAMBDA-TYPES>!C)
    ; translate as a LAMBDA application
    (TRANS-LAMBDA-APPL!C EXPR *VARSTACK*!C) )
  ; otherwise, compilation error
  (COMPILE-ERR!C EXPR "Undefined Function Call") )

; Section 4.5.1.1. Translate CXR Evaluation to DI

(DEFUN TRANS-CXR-TO-DI!C (CXR ARGS)
; Generates assembly to evaluate a CXR expression (i.e., a call
; to CAR, CDR, ..., CDDDDR), returning the value in DI.
  ; if no arguments, translate to return NIL
  ((NULL ARGS)
    (ASM-MOV!C 'DI (VAR!C NIL)) )
  ; translate the first argument to DI
  (TRANS-EVAL-TO-DI!C (CAR ARGS))
  ; translate extra arguments, if any, for effect
  (TRANS-EVALS-TO-DI!C (CDR ARGS) '(DI))
  ; translate the CXR operations
  (MAPC 'TRANS-ONE-CXR!C (GET CXR 'CXR!C)) )

(DEFUN TRANS-ONE-CXR!C (CXRELEM)
; Translates one CXR element -- A or D -- into a CAR or CDR fetch
; from DI to DI.
  ; if CAR fetch,
  ((EQ CXRELEM 'A)
    ; DI <-- [DI]
    (ASM-MOV!C 'DI (IND!C 'DI)) )
  ; if CDR fetch,
  ((EQ CXRELEM 'D)
    ; DI <-- ES:[DI]
    (ASM-MOV!C 'DI (IND!C 'ES 'DI)) )
  ; INTERNAL-ERR @ TRANS-ONE-CXR!C: CXRELEM is neither 'A nor 'D
  (INTERNAL-ERR!C 2020 1 CXRELEM) )

; Section 4.5.1.2. Translate Function Application Evaluation to DI

(DEFUN TRANS-APPL-TO-DI!C (FN ARGS)
; Generates assembly to evaluate an application of function FN to
; arguments ARGS, returning the resulting value in DI.
  ; if FN is itself the function being translated,
  ((EQ FN *FN*!C)
    ; evaluate and spread the arguments,
    (SPREAD-EVALED-ARGS-FOR-FN!C ARGS *VARSTACK*!C)
    ; and call FN directly
    (ASM-CALL!C FN) )
  ; otherwise, get the type of FN, and
  (LET ((fntype (GETD FN T)) )
    ; if FN is a primitive muLISP function,
    ((IS-PRIMFN!C FN)
      ; if FN is a primitive LAMBDA,
      ((EQ fntype 'LAMBDA)
	; evaluate and spread the arguments,
	(SPREAD-EVALED-ARGS-FOR-FN!C ARGS *VARSTACK*!C)
	; move the entry point of FN to AX,
	(ASM-MOV!C 'AX (GETD FN))
	; and call it through the PJMPAX service
	(ASM-CALL!C <PJMPAXSVC>!C) )
      ; if FN is a primitive special form,
      ((EQ fntype 'SPECIAL)
	; collect the unevaluated arguments,
	(COLLECT-UNEVALED-ARGS-FOR-FN!C ARGS)
	; move the entry point of the "SEXPR" version of FN to AX,
	(ASM-MOV!C 'AX (CSMEMORY (+ (GETD FN) 2) NIL T))
	; and call it through the PJMPAX service
	(ASM-CALL!C <PJMPAXSVC>!C) )
      ; INTERNAL-ERR @ TRANS-APPL-TO-DI!C: Invalid primitive FN
      (INTERNAL-ERR!C 2030 1 FN ARGS) )
    ; otherwise, FN is NOT a primitive function, so:
    ; if FN is a nonprimitive LAMBDA,
    ((EQ fntype 'LAMBDA)
      ; translate as an INDIRECT application: (FUNCALL FN . ARGS)
      (TRANS-APPL-TO-DI!C 'FUNCALL (CONS (LIST 'QUOTE FN) ARGS)) )
    ; if FN is a nonprimitive NLAMBDA,
    ((EQ fntype 'NLAMBDA)
      ; translate as an INDIRECT application: (APPLY FN  ARGS)
      (TRANS-APPL-TO-DI!C 'APPLY (LIST (LIST 'QUOTE FN)
	  (LIST 'QUOTE ARGS))) )
    ; otherwise, compilation error
    (COMPILE-ERR!C (CONS FN ARGS) "Undefined Function Call") ) )

(DEFUN SPREAD-EVALED-ARGS-FOR-FN!C (ARGS *VARSTACK*!C)
; Generates assembly to evaluate the arguments in the list ARGS in
; parallel, and "spread" them to the stack for a function call.
; NOTE: *VARSTACK*!C MUST be bound coming into this function so
;	that it can be locally revised for the arguments in ARGS,
;	and then automatically restored upon exit.
  ; translate the evaluation of all arguments in ARGS to the stack
  ; in parallel WITHOUT adjusting the stack pointer
  (TRANS-EVALS-TO-STK!C ARGS (LENGTH ARGS) NIL)
  ; load CX with 2 * the number of arguments
  (ASM-MOV!C 'CX (* 2 (LENGTH ARGS))) )

(DEFUN COLLECT-UNEVALED-ARGS-FOR-FN!C (ARGS)
; Generates assembly to load the list ARGS into SI without any
; evaluation of its elements.
  (TRANS-LOAD-TO-REG!C 'SI ARGS) )

; Section 4.5.1.3. Translate LAMBDA/NLAMBDA Application Evaluation to DI

(DEFUN TRANS-LAMBDA-APPL!C (LAPPL *VARSTACK*!C)
; Generates assembly to evaluate the LAMBDA/NLAMBDA application
; LAPPL, returning the resulting value in DI.
; NOTE: *VARSTACK*!C MUST be bound coming into this function so
;	that it can be locally revised for the arguments of the
;	LAMBDA body, and then automatically restored upon exit.
  (LET* ((ltyp (CAAR LAPPL))
	 ; = the type of the LAMBDA body (LAMBDA or NLAMBDA)
	 (largspec (CADAR LAPPL))
	 ; = the argument specification of the LAMBDA body
	 (larglist (IF (LISTP largspec) largspec (LIST largspec)))
	 ; = the LIST of arguments of the LAMBDA body
	 (lforms (CDDAR LAPPL))
	 ; = the forms in the LAMBDA body
	 (largs (CDR LAPPL))
	 ; = the list of actual arguments to which the LAMBDA body
	 ;   is being applied
	 (endlabel (MK-LABEL!C)) )
	 ; = local label for the end of the LAMBDA body
    ; translate the actual arguments of the LAMBDA application
    (TRANS-ARGS-FOR-LAMBDA-APPL!C ltyp largspec largs *VARSTACK*!C)
    ; revise *VARSTACK*!C to include the LAMBDA body arguments
    (SETQ *VARSTACK*!C (REVERSE larglist *VARSTACK*!C))
    ; bind all LAMBDA body arguments
    (MAPC 'ASM-BINDVAR!C larglist)
    ; translate the forms in the LAMBDA body as a sequence which
    ; exits to endlabel, and which must return a value in DI.
    (TRANS-SEQ!C lforms endlabel T)
    ; place the local end label
    (ASM-LBL!C endlabel)
    ; unbind all LAMBDA body arguments
    (MAPC 'ASM-UNBINDVAR!C larglist)
    ; drop the stacked arguments
    (ASM-SUB!C 'BP (* 2 (LENGTH larglist))) ) )

(DEFUN TRANS-ARGS-FOR-LAMBDA-APPL!C (LTYP LARGSPEC LARGS *VARSTACK*!C)
; Generates assembly to push the arguments in the list LARGS onto
; the variable stack in accordance with the argument structure and
; type of the LAMBDA application (i.e., LARGSPEC and LTYP).
; NOTE: *VARSTACK*!C MUST ALSO be bound coming into THIS function
;	since it may be altered during the evaluation and stacking
;	of the actual arguments, but must be restored before it is
;	revised in TRANS-LAMBDA-APPL
  ; if the type is LAMBDA, then
  ((EQ LTYP 'LAMBDA)
    ; if the argument specification is a list (i.e., "spread"),
    ((LISTP LARGSPEC)
      ; translate the evaluation of the first (LENGTH LARGSPEC)
      ; arguments in ARGS to the stack in parallel, adjusting
      ; the stack pointer to include them on the stack
      (TRANS-EVALS-TO-STK!C LARGS (LENGTH LARGSPEC) T)
      ; evaluate extra arguments, if any, for effect
      (MAPC 'TRANS-EVAL-TO-DI!C (NTHCDR (LENGTH LARGSPEC) LARGS)) )
    ; otherwise, no-spread, so:
    ; evaluate and collect all arguments in ARGS,
    (TRANS-EVAL-TO-DI!C (CONS 'LIST LARGS))
    ; and push the resulting list onto the stack
    (ASM-PUSHVAR!C 'DI) )
  ; otherwise, NLAMBDA, so:
  ; if the argument specification is a list (i.e., "spread"),
  ((LISTP LARGSPEC)
    ; translate the first (LENGTH LARGSPEC) arguments in ARGS to the
    ; stack WITHOUT evaluation, adjusting the stack pointer to
    ; include them on the stack
    (TRANS-LOADS-TO-STK!C LARGS (LENGTH LARGSPEC) T) )
  ; otherwise, no-spread, so:
  ; load the list of actual arguments to AX unevaluated,
  (TRANS-LOAD-TO-REG!C 'AX LARGS)
  ; and push the list onto the stack
  (ASM-PUSHVAR!C 'AX) )

; Section 4.5.2. Translate Evaluation to (BP n)

(DEFUN TRANS-EVAL-TO-BPN!C (N EXPR)
; Generates assembly to evaluate EXPR and store the resulting value
; at an offset of N from the current variable stack pointer (BP).
  ; if N is a 16-bit integer,
  ((IS-INT16!C N)
    ; if EXPR is an atom, then
    ((ATOM EXPR)
      ; if EXPR is a symbol, then
      ((SYMBOLP EXPR)
      ; if EXPR always evaluates to itself,
	((CONSTANTP EXPR)
	  ; move DIRECTLY to (BP N) as a VARiable (i.e., immediate)
	  (ASM-MOV!C (IND!C 'BP N) (VAR!C EXPR)) )
	; otherwise, move its value to (BP N) through AX
	(ASM-MOV!C 'AX (SYMBOL-SRC-OPND!C EXPR))
	(ASM-MOV!C (IND!C 'BP N) 'AX) )
      ; otherwise, EXPR is a number, so:
      ; install a compiler constant symbol for it, and move the value
      ; of that symbol to (BP N) through AX
      (ASM-MOV!C 'AX (VAL!C (INSTALL-CONST!C EXPR)))
      (ASM-MOV!C (IND!C 'BP N) 'AX) )
    ; otherwise, EXPR is a CONSP, so:
    ; translates it as an evaluation, and move the resulting value to
    ; (BP N) through DI
    (TRANS-EVAL-TO-DI!C EXPR)
    (ASM-MOV!C (IND!C 'BP N) 'DI) )
  ; INTERNAL-ERR @ TRANS-EVAL-TO-BPN!C: Invalid BP offset N
  (INTERNAL-ERR!C 2040 1 N EXPR) )

; Section 4.5.3. Translate Evaluations to DI

(DEFUN TRANS-EVALS-TO-DI!C (EXPRS SVREGS)
; Generates assembly to save all registers in the list SVREGS on the
; variable stack, consecutively evaluate all expressions in the list
; EXPRS to DI, and then to restore the registers stacked.  (Often
; used to evaluate "extra" arguments for effect.)
  ; if no expressions, do nothing
  ((NULL EXPRS) )
  ; push all registers to be saved
  (MAPC 'ASM-PUSHVAR!C SVREGS)
  ; evaluate all expressions to DI (for effect)
  (MAPC 'TRANS-EVAL-TO-DI!C EXPRS)
  ; restore all registers saved
  (MAPC 'ASM-POPVAR!C (REVERSE SVREGS)) )

; Section 4.5.4. Translate Evaluations to Stack

(DEFUN TRANS-EVALS-TO-STK!C (EXPRS NEXPRS STKF)
; Generates assembly to evaluate and then put NEXPR expressions from
; the list EXPRS onto the variable stack.  If EXPRS has fewer than
; NEXPR expressions, NIL's will be pushed to make up the difference;
; however, if EXPRS has more than NEXPRS expressions, the excess will
; be ignored.  STKF indicates whether or not the pushed values should
; be left "stacked" (i.e., whether the variable stack pointer (BP)
; should be adjusted to point just above the last expression pushed
; or restored to its original position).
; NOTE: This function is somewhat intricate, but it permits some
;	optimization of the bookkeeping of the stack pointer
  (LET ((bpn 0)
	; = offset from BP at which next expression should be stored
	(nexprs*2 (* 2 NEXPRS)) )
	; = 2 * original value of NEXPRS
    (LOOP
      ; if NEXPRS = 0, then
      ((ZEROP NEXPRS)
	; if the expressions are to be stacked,
	((IDENTITY STKF)
	  ; move BP up by bpn to include them
	  (ASM-ADD!C 'BP bpn) )
	; otherwise, the expressions are NOT to be stacked, so:
	; move BP down by [(2 * NEXPRS) - bpn]
	(ASM-SUB!C 'BP (- nexprs*2 bpn)) )
      ; otherwise, set up to evaluate the next expression
	; if the next expression is simple, do nothing
      ( ((IS-SIMPLE!C (CAR EXPRS)) )
	; otherwise, stack the expressions evaluated so far by
	; moving BP up by bpn,
	(ASM-ADD!C 'BP bpn)
	; and adjusting *VARSTACK*!C and bpn accordingly
	(LOOP
	  ((ZEROP bpn) )
	  (PUSH <ARBVAL>!C *VARSTACK*!C)
	  (DECQ bpn 2) ) )
      ; translate the next expression to (BP bpn)
      (TRANS-EVAL-TO-BPN!C bpn (POP EXPRS))
      ; adjust bpn and NEXPRS
      (INCQ bpn 2)
      (DECQ NEXPRS) ) ) )

; Section 4.6. Load Translators

;    The load translators handle muLISP expressions encountered in
; NO-evaluation contexts such as quoted expressions or NLAMBDA
; arguments.  Translation in such contexts is very simple, and does
; not exploit any translation context information for optimization.

; Section 4.6.1. Translate Load to Register

(DEFUN TRANS-LOAD-TO-REG!C (REG EXPR)
; Generates assembly to place EXPR itself (i.e., unevaluated) in
; register REG.
  ; if EXPR is a symbol,
  ((SYMBOLP EXPR)
    ; move it to REG as a VARiable (i.e., immediate)
    (ASM-MOV!C REG (VAR!C EXPR)) )
  ; otherwise, install a compiler constant symbol for EXPR, and
  ; move the value of that symbol to REG
  (ASM-MOV!C REG (VAL!C (INSTALL-CONST!C EXPR))) )

; Section 4.6.2. Translate Load to (BP n)

(DEFUN TRANS-LOAD-TO-BPN!C (N EXPR)
; Generates assembly to place EXPR itself (unevaluated) at an
; offset of N from the current variable stack pointer (BP).
  ; if N is a 16-bit integer,
  ((IS-INT16!C N)
    ; if EXPR is a symbol,
    ((SYMBOLP EXPR)
      ; move it directly to (BP N) as a VARiable (i.e., immediate)
      (ASM-MOV!C (IND!C 'BP N) (VAR!C EXPR)) )
    ; otherwise, load EXPR to (BP N) through AX
    (TRANS-LOAD-TO-REG!C 'AX EXPR)
    (ASM-MOV!C (IND!C 'BP N) 'AX) )
  ; INTERNAL-ERR @ TRANS-LOAD-TO-BPN!C: Invalid BP offset N
  (INTERNAL-ERR!C 2050 1 N EXPR) )

; Section 4.6.3. Translate Loads to Stack

(DEFUN TRANS-LOADS-TO-STK!C (EXPRS NEXPRS STKF)
; Generates assembly to load NEXPR expressions from the list EXPRS
; onto the variable stack without evaluation.  If EXPRS has fewer
; than NEXPR expressions, NIL's will be added and pushed; however, if
; EXPRS has more than NEXPRS expressions, the excess will be ignored.
; STKF indicates whether or not the pushed expressions should be left
; "stacked" (i.e., whether the variable stack pointer (BP) should be
; adjusted to point just above the last expression pushed, or reset
; to its original position.
; NOTE: Like TRANS-EVALS-TO-STK!C, this function is rather intricate,
;	but it permits some optimization of the bookkeeping of the
;	stack pointer
  (LET ((bpn 0)
	; = offset from BP at which next expression should be stored
	(nexprs*2 (* 2 NEXPRS)) )
	; = 2 * original value of NEXPRS
    (LOOP
      ; if NEXPRS = 0, then
      ((ZEROP NEXPRS)
	; if the expressions are to be stacked,
	((IDENTITY STKF)
	  ; move BP up by bpn to include them
	  (ASM-ADD!C 'BP bpn) )
	; otherwise, the expressions are NOT to be stacked, so:
	; move BP down by [(2 * NEXPRS) - bpn]
	(ASM-SUB!C 'BP (- nexprs*2 bpn)) )
      ; load the next expression to (BP bpn)
      (TRANS-LOAD-TO-BPN!C bpn (POP EXPRS))
      ; adjust bpn and NEXPRS
      (INCQ bpn 2)
      (DECQ NEXPRS) ) ) )
