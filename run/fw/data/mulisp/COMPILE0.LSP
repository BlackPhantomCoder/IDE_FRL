; File: COMPILE0.LSP  (c)	05/20/87	Soft Warehouse, Inc.


;	      The muLISP Incremental Native Code Compiler

; intern several constant symbols "low" in the OBLIST (below the compiler)

(SETQ CONSTANTS!C '(
   K!C1  K!C2  K!C3  K!C4  K!C5  K!C6  K!C7  K!C8  K!C9  K!C10
   K!C11 K!C12 K!C13 K!C14 K!C15 K!C16 K!C17 K!C18 K!C19 K!C20
   K!C21 K!C22 K!C23 K!C24 K!C25 K!C26 K!C27 K!C28 K!C29 K!C30
   K!C31 K!C32 K!C33 K!C34 K!C35 K!C36 K!C37 K!C38 K!C39 K!C40
   K!C41 K!C42 K!C43 K!C44 K!C45 K!C46 K!C47 K!C48 K!C49 K!C50
   K!C51 K!C52 K!C53 K!C54 K!C55 K!C56 K!C57 K!C58 K!C59 K!C60
   K!C61 K!C62 K!C63 K!C64 K!C65 K!C66 K!C67 K!C68 K!C69 K!C70
   K!C71 K!C72 K!C73 K!C74 K!C75 K!C76 K!C77 K!C78 K!C79 K!C80
   K!C81 K!C82 K!C83 K!C84 K!C85 K!C86 K!C87 K!C88 K!C89 K!C90
   K!C91 K!C92 K!C93 K!C94 K!C95 K!C96 K!C97 K!C98 K!C99 K!C100
   K!C101 K!C102 K!C103 K!C104 K!C105 K!C106 K!C107 K!C108 K!C109 K!C110
   K!C111 K!C112 K!C113 K!C114 K!C115 K!C116 K!C117 K!C118 K!C119 K!C120
   K!C121 K!C122 K!C123 K!C124 K!C125 K!C126 K!C127 K!C128 K!C129 K!C130
   K!C131 K!C132 K!C133 K!C134 K!C135 K!C136 K!C137 K!C138 K!C139 K!C140
   K!C141 K!C142 K!C143 K!C144 K!C145 K!C146 K!C147 K!C148 K!C149 K!C150
   K!C151 K!C152 K!C153 K!C154 K!C155 K!C156 K!C157 K!C158 K!C159 K!C160
   K!C161 K!C162 K!C163 K!C164 K!C165 K!C166 K!C167 K!C168 K!C169 K!C170
   K!C171 K!C172 K!C173 K!C174 K!C175 K!C176 K!C177 K!C178 K!C179 K!C180
   K!C181 K!C182 K!C183 K!C184 K!C185 K!C186 K!C187 K!C188 K!C189 K!C190
   K!C191 K!C192 K!C193 K!C194 K!C195 K!C196 K!C197 K!C198 K!C199 K!C200))


; Section 1. TOP LEVEL * * * * * * * * * * * * * * * * * * * * * * * * *

;    This section describes the top level of the compiler, including
; the basic compiler functions and the error handling machinery.

; Section 1.1. Compiler Functions

(DEFUN COMPILE (*FN*!C)
; Translates the definition of *FN*!C into assembly language,
; assembles the resulting instructions into machine code, and
; loads the machine code into the muLISP code segment.	COMPILE
; returns a list consisting of *FN*!C, the number of bytes of
; machine code in *FN*!C's compiled form, and the entry address
; in the muLISP code segment.  Catches errors thrown to 'ERR!C.
  (CATCH 'ERR!C
     (LOAD-FN!C (ASSEMBLE-FN!C (TRANS-FN!C *FN*!C (GETD *FN*!C))))) )

(DEFMACRO DELETE-COMPILER NIL
; Deletes the compiler by removing the values, properties, and
; definitions of compiler symbols.
; NOTE: SHOULD NOT remove the values of compiler constant symbols,
;	**COMP-CONST-LIST**!C, or **COMP-CONST-INDEX**!C.
  ; remove CXR properties
  (MAPC '(LAMBDA (X)  (REMPROP X 'CXR!C) )
	'(CAR CDR  CAAR CADR CDAR CDDR
	  CAAAR CAADR CADAR CADDR CDAAR CDADR CDDAR CDDDR
	  CAAAAR CAAADR CAADAR CAADDR CADAAR CADADR CADDAR CADDDR
	  CDAAAR CDAADR CDADAR CDADDR CDDAAR CDDADR CDDDAR CDDDDR) )
  ; remove TRANS-FORM!C properties
  (MAPC '(LAMBDA (X)  (REMPROP X 'TRANS-FORM!C) )
	'(PROGN LOOP PROG1 IF COND) )
  ; remove TRANS-TEST!C properties
  (MAPC '(LAMBDA (X)  (REMPROP X 'TRANS-TEST!C) )
	'(SYMBOLP ATOM CONSP NULL EQ NOT) )
  ; remove TRANS-EXPR properties
  (MAPC '(LAMBDA (X)  (REMPROP X 'TRANS-EVAL!C) )
	'(AND OR SETQ PSETQ POP PUSH INCQ DECQ QUOTE IDENTITY COMMENT
	  RETURN) )
  ; remove compiler properties from untagged compiler symbols
  (MAPC '(LAMBDA (X)  (MAPC '(LAMBDA (I) (REMPROP X I) )
			    '(CODE-GEN-SPEC!C CXR!C INV-JCND!C
			      JCND!C JMP-CODE!C R/M-CODE!C
			      REG-CODE!C REGPROPS!C REGTYPE!C
			      SEG-CODE!C TRANS-EVAL!C TRANS-FORM!C
			      TRANS-TEST!C) ) )
	'(A ADD AX B BP BX C CALL CMP CS CX DI DS DX E ES G GE JMP L
	  LE MOV NA NB NC NE RET SI SJMP SP SS SUB XCHG) )
  ; clear the value, property list, and function definition of each
  ; tagged compiler symbol
  (MAPC '(LAMBDA (X)  (SET X X)
		      (RPLACD X NIL)
		      (REMD X) )
	 (DELETE '**COMP-CONST-LIST**!C
	  (DELETE '**COMP-CONST-INDEX**!C
		  (MAPCAN '(LAMBDA (X)
			       ((AND (FINDSTRING '"!C" X)
				     (NEQ '"K!C" (SUBSTRING X 0 2)))
				 (LIST X) ) )
			  (OBLIST) ) ) ) )
  (REMD 'COMPILE)
  (LIST 'REMD (LIST 'QUOTE 'DELETE-COMPILER)) )


; Section 1.2. Compiler Error Handling

(DEFUN COMPILE-ERR!C (EXPN ERRMSG)	; Compile error break
  (BREAK EXPN ERRMSG)
  (THROW 'ERR!C) )

(DEFUN INTERNAL-ERR!C ERRMSG		; Internal compiler error break
  (BREAK (CDDR ERRMSG) (PACK* "Internal Compiler Error #"
		(CAR ERRMSG) '":" (CADR ERRMSG)))
  (THROW 'ERR!C) )


; Section 2. CONSTANTS, GLOBALS, SPECIALS AND UTILITIES  * * * * * * * * *

;    This section describes the constants, global variables, special
; variables, and muLISP level utilities used by the compiler.

; Section 2.1. Constants Used by the Compiler

;    Constants used by the compiler have names of the form "<...>!C".
; Several constants are used.  They are introduced and initialized
; in the following:

; Section 2.1.1. muLISP System Addresses

(SETQ <ENDMCD@CS>!C 1034		; initialize address of ENDMCD in CS
      <USENAM@DS>!C 24 )		; initialize address of USENAM in DS

; Section 2.1.2. muLISP System Locations
;    (see 3.6.6 for more on "locations")

(SETQ <ENDSYMLOC>!C '(DS 0)		; initialize location of ENDSYM in DS
      <THRFLGLOC>!C '(DS 56) )		; initialize location of THRFLG in DS

; Section 2.1.3. muLISP System Service Addresses
;    (see 3.6.7 for more on "services")

(SETQ <STKTRPSVC>!C '(SVC 1024) 	; initialize STKTRP in CS
      <ITRTRPSVC>!C '(SVC 1026) 	; initialize ITRTRP in CS
      <DPOP1SVC>!C  '(SVC 1036) 	; initialize DPOP1 in CS
      <SPUSH1SVC>!C '(SVC 1038) 	; initialize SPUSH1 in CS
      <SINCQ1SVC>!C '(SVC 1040) 	; initialize SINCQ1 in CS
      <PJMPAXSVC>!C '(SVC 1046) )	; initialize PJMPAX in CS

; initialize E-L/S (enter LAMBDA/spread) service address in muLISP
; code segment
(SETQ <E-L/S-SVC>!C '(SVC 1048) )

; initialize E-L/NS (Enter LAMBDA/no-spread) service address in
; muLISP code segment
(SETQ <E-L/NS-SVC>!C '(SVC 1050) )

; Section 2.1.4. Miscellaneous Constants

; initialize <ARBVAL>!C constant used as place holder in *VARSTACK*!C
; (see 3.1, below, for more on <ARBVAL>!C)
(SETQ <ARBVAL>!C '(NIL))

; initialize <LAMBDA-TYPES>!C constant
(SETQ <LAMBDA-TYPES>!C '(LAMBDA NLAMBDA))

; initialize <START-PRIMFNS>!C constant, the lowest address for muLISP
; primitive function entry points
(SETQ <START-PRIMFNS>!C 428)

; initialize <END-PRIMFNS>!C constant, the highest address for muLISP
; primitive function entry points
(SETQ <END-PRIMFNS>!C (CSMEMORY <ENDMCD@CS>!C NIL T))

; Section 2.2. Global Variables Used by the Compiler

;    Global variables used by the compiler have names of the form
; "**...**!C".	Only two global variables are used:
;	**COMP-CONST-LIST**!C
;	**COMP-CONST-INDEX**!C.
; (See 3.2, below, for the use of these globals in managing compiler
; constant symbols.)

; Section 2.3. Special Variables Used by the Compiler

;    Special variables used by the compiler have the form "*...*!C".
; Several special variables are used, bound, set, and sometimes
; rebound in various compiler functions.

; Section 2.4. Utilities Used by the Compiler

(DEFMACRO LET (LETLIST . BODY)
   (CONS (LIST* 'LAMBDA
		(MAPCAR 'CAR LETLIST)
		BODY)
	 (MAPCAR 'CADR LETLIST)) )

(DEFMACRO LET* (LETLIST . BODY)
   (LIST (LIST* 'LAMBDA
		(MAPCAR 'CAR LETLIST)
		(CONS 'SETQ
		      (MAPCAN '(LAMBDA (LST)
				       (LIST (CAR LST) (CADR LST)))
			      LETLIST))
		BODY)) )


; Section 3. TRANSLATION MACHINERY * * * * * * * * * * * * * * * * * * * *

;    This section develops a variety of machinery used throughout
; translation, the first step of compilation:
;    3.1 introduces the means by which the muLISP variable stack is
;	 represented and managed during the translation process.
;    3.2 provides machinery to generate and install the "compiler
;	 constant symbols" through which compiled code can access
;	 numbers and  quoted lists.
;    3.3 defines recognizers for some distinguished types of muLISP
;	 functions which are handled specially during translation.
;    3.4 defines a recognizer for "simple" muLISP expressions which
;	 can be given special treatment in compiled code.
;    3.5 provides a set of assembly generation functions which
;	 systematize the process of creating assembly language
;	 instructions during translation.
;    3.6 introduces the means by which the varied types of assembly
;	 language operands which arise during translation are
;	 represented and manipulated.
;    3.7 develops two functions to generate assembly operands for
;	 muLISP symbols.

; Section 3.1. Stack Variable Management

;    During execution of compiled functions, various values will
; reside on the muLISP variable (BP) stack.  During translation, the
; special variable *VARSTACK*!C keeps track of the contents of the BP
; stack as a list from the top (just below the current value of [BP])
; down.  Symbols in *VARSTACK*!C  represent function or LAMBDA body
; arguments which have been bound; the constant <ARBVAL>!C = (NIL)
; represents other values temporarily pushed onto the stack.  Several
; of the translation functions bind, rebind, set, PUSH, POP, and
; otherwise manipulate *VARSTACK*!C.

(DEFMACRO IS-STKVAR!C (X)
; Recognizes stack variables
  (LIST 'MEMBER X '*VARSTACK*!C) )

(DEFUN VAR-OFFSET!C (VAR)
; Returns the BP addressing offset of VAR in the current *VARSTACK*!C
  ((IS-STKVAR!C VAR)
    (* -2 (ADD1 (POSITION VAR *VARSTACK*!C))) )
  ; INTERNAL-ERR @ VAR-OFFSET!C: VAR is not on variable stack
  (INTERNAL-ERR!C 1010 1 VAR) )

; Section 3.2. Compiler Constant Symbols

;    Compiler constant symbols are generated during translation so
; that machine code can access a number or list as the value of a
; muLISP symbol.  Constant symbols have the form K!C1, ... , K!Cn.
; They are managed through **COMP-CONST-LIST**!C, a list of
; (constant-value . constant-symbol) pairs representing constants
; installed so far, and **COMP-CONST-INDEX**!C, the integer index
; of the last constant installed.
;    Care must be taken in initializing the global variables
; **COMP-CONST-LIST**!C and **COMP-CONST-INDEX**!C to insure that
; existing values are not destroyed if the compiler is REloaded;
; in such a case, constants referenced in previously compiled
; functions could be changed with unpredictable results.

; if **COMP-CONST-LIST**!C is NOT already set, initialize it
(IF (NOT (LISTP **COMP-CONST-LIST**!C))
    (SETQ **COMP-CONST-LIST**!C NIL) )

; if **COMP-CONST-INDEX**!C is NOT already set, initialize it
(IF (NOT (NUMBERP **COMP-CONST-INDEX**!C))
    (SETQ **COMP-CONST-INDEX**!C 0) )

(DEFMACRO IS-CONST!C (CVAL)
; Recognizes compiler constants
  (LIST 'ASSOC CVAL '**COMP-CONST-LIST**!C ''EQUAL) )

(DEFUN INSTALL-CONST!C (CVAL)
; Installs CVAL, a number or list, as a compiler constant, and
; returns a constant symbol through which CVAL can be referenced.
  ; if there is already a constant symbol for CVAL, return it.
  ((CDR (IS-CONST!C CVAL)) )
  ; if CVAL is NOT a symbol,
  ((NOT (SYMBOLP CVAL))
    (LET ((csym (PACK* '"K!C" (INCQ **COMP-CONST-INDEX**!C))) )
	  ; = a new compiler constant symbol for CVAL
      ; if csym has NO COMP-CONST-VAL!C property,
      ((NOT (GET csym 'COMP-CONST-VAL!C))
	; install csym as a compiler constant symbol for CVAL
	(PUSH (CONS CVAL csym) **COMP-CONST-LIST**!C)
	(PUT csym 'COMP-CONST-VAL!C CVAL)
	(SET csym CVAL)
	; and return csym
	csym )
      ; INTERNAL-ERR @ INSTALL-CONST!C: csym already has value
      (INTERNAL-ERR!C 1020 1 CVAL) ) )
  ; INTERNAL-ERR @ INSTALL-CONST!C: CVAL is a symbol
  (INTERNAL-ERR!C 1020 2 CVAL) )

; Section 3.3. muLISP Function Recognizers

;    Various types of muLISP functions need to recognized during
; translation.	These include: MACROs, primitive muLISP functions,
; and "CXRs" (i.e., CAR, CDR, ..., CDDDDR).

(DEFUN IS-MACRO!C (FN)
; Recognizes MACROs
  (EQ (GETD FN T) 'MACRO) )

(DEFUN IS-PRIMFN!C (X)
; Recognizes primitive muLISP functions
  ((NUMBERP (GETD X))
    (<= <START-PRIMFNS>!C (GETD X) <END-PRIMFNS>!C) ) )

(DEFMACRO IS-CXRFN!C (X)
; Recognizes CXR functions (CAR, CDR, ..., CDDDDR)
  (LIST 'GET X ''CXR!C) )

; Initialize basic property data for the CXR functions:
;   * under 'CXR!C: the list of A's and D's of the function's name
(MAPC '(LAMBDA (X)
	 (APPLY '(LAMBDA (CXR CXRSEQ)
		   (PUT CXR 'CXR!C (REVERSE CXRSEQ)) )
		X))
      '((CAR (A)) (CDR (D))
	(CAAR (A A)) (CADR (A D)) (CDAR (D A)) (CDDR (D D))
	(CAAAR (A A A)) (CAADR (A A D)) (CADAR (A D A))
	(CADDR (A D D)) (CDAAR (D A A)) (CDADR (D A D))
	(CDDAR (D D A)) (CDDDR (D D D))
	(CAAAAR (A A A A)) (CAAADR (A A A D)) (CAADAR (A A D A))
	(CAADDR (A A D D)) (CADAAR (A D A A)) (CADADR (A D A D))
	(CADDAR (A D D A)) (CADDDR (A D D D)) (CDAAAR (D A A A))
	(CDAADR (D A A D)) (CDADAR (D A D A)) (CDADDR (D A D D))
	(CDDAAR (D D A A)) (CDDADR (D D A D)) (CDDDAR (D D D A))
	(CDDDDR (D D D D)) ) )

; Section 3.4. "Simple" Expression Recognizer

;    "Simple" expressions are those which cause NO side effects
; at the assembly level (e.g., no garbage collection, register
; changes, etc.).  They can be given special, "simple" treatment
; during translation, resulting in faster compiled functions.

(DEFUN IS-SIMPLE!C (X)
; Recognizes "simple" muLISP expressions
  ; atoms are simple
  ((ATOM X))
  ; quoted expressions are simple
  ((EQ (CAR X) 'QUOTE) )
  ; CXRs are simple if,
  ((IS-CXRFN!C (CAR X))
    ; they have a single argument,
    ((NULL (CDDR X))
      ; which is itself simple
      (IS-SIMPLE!C (CADR X)) ) ) )

; Section 3.5. Assembly Language Generators

;    During translation, assembly language is generated in the form
; of lists of 8086 opcode mnemonics and operands.  These correspond
; to lines of assembly code, and are collected by TCONCing onto the
; special variable *FNASM*!C.  The following functions systematize
; the generation process, and also do some simple optimizations.

; Section 3.5.1. Basic 8086 Assembly Instruction Generators

(DEFUN ASM-MOV!C (DEST SRC)
; Generates a MOV instruction in the form (MOV DEST SRC),
; unless DEST = SRC.
  ((EQUAL DEST SRC))
  (TCONC *FNASM*!C (LIST 'MOV DEST SRC)) )

(DEFUN ASM-XCHG!C (OP1 OP2)
; Generates an XCHG instruction in the form (XCHG OP1 OP2).
  (TCONC *FNASM*!C (LIST 'XCHG OP1 OP2)) )

(DEFUN ASM-CMP!C (OP1 OP2)
; Generates a CMP instruction in the form (CMP OP1 OP2).
  (TCONC *FNASM*!C (LIST 'CMP OP1 OP2)) )

(DEFUN ASM-ADD!C (OP1 OP2)
; Generates an ADD instruction in the form (ADD OP1 OP2),
; unless OP2 = 0.
  ((EQL OP2 0) )
  (TCONC *FNASM*!C (LIST 'ADD OP1 OP2)) )

(DEFUN ASM-SUB!C (OP1 OP2)
; Generates a SUB instruction in the form (SUB OP1 OP2),
; unless OP2 = 0.
  ((EQL OP2 0) )
  (TCONC *FNASM*!C (LIST 'SUB OP1 OP2)) )

(DEFUN ASM-JMP!C (LBL JCND INVF)
; Generates a JMP instruction in the form (JMP LBL [JCND]).
; If INVF is nonnull, the jump condition JCND is transformed
; into its inverse (i.e., negated)
  ((NULL JCND)
    (TCONC *FNASM*!C (LIST 'JMP LBL)) )
  ((NULL INVF)
    (TCONC *FNASM*!C (LIST 'JMP LBL JCND)) )
  (TCONC *FNASM*!C (LIST 'JMP LBL (INV-JCND!C JCND))) )

(DEFUN ASM-CALL!C (DEST)
; Generates a CALL instruction in the form (CALL DEST).
  (TCONC *FNASM*!C (LIST 'CALL DEST)) )

(DEFUN ASM-RET!C NIL
; Generates a RET instruction in the form (RET).
  (TCONC *FNASM*!C (LIST 'RET)) )

; Section 3.5.2. Assembly Label Generator

(DEFUN ASM-LBL!C (LBL)
; Places LBL into the assembly.
  (TCONC *FNASM*!C LBL) )

; Section 3.5.3. muLISP Variable Stack Operation Generators

(DEFUN ASM-PUSHVAR!C (OP)
; Generates assembly to push OP onto the variable stack
  ; move OP to the variable stack
  (ASM-MOV!C (IND!C 'BP 0) OP)
  ; increment the variable stack pointer
  (ASM-ADD!C 'BP 2)
  ; push <ARBVAL>!C on *VARSTACK*!C as anonymous place holder for OP
  (PUSH <ARBVAL>!C *VARSTACK*!C) )

(DEFUN ASM-POPVAR!C (REG)
; Generates assembly to pop the variable stack into register REG
  ; decrement the variable stack pointer
  (ASM-SUB!C 'BP 2)
  ; move the former top of the stack into REG
  (ASM-MOV!C REG (IND!C 'BP 0))
  ; drop the top element of *VARSTACK*!C
  (POP *VARSTACK*!C) )

; Section 3.5.4. muLISP Variable Binding Operation Generators

(DEFUN ASM-BINDVAR!C (VAR)
; Generates assembly to bind the muLISP variable VAR to a value
; already on the variable stack (hence, VAR must be in *VARSTACK*!C).
  ; get the current value of VAR
  (ASM-MOV!C 'AX (VAL!C VAR))
  ; exchange it with the new stacked value for VAR
  (ASM-XCHG!C 'AX (IND!C 'BP (VAR-OFFSET!C VAR)))
  ; set VAR to the new value
  (ASM-MOV!C (VAL!C VAR) 'AX) )

(DEFUN ASM-UNBINDVAR!C (VAR)
; Generates assembly to unbind the muLISP variable VAR from the
; variable stack (hence, VAR must be in *VARSTACK*!C).
  ; get the stacked value for VAR
  (ASM-MOV!C 'AX (IND!C 'BP (VAR-OFFSET!C VAR)))
  ; set VAR to the stacked value
  (ASM-MOV!C (VAL!C VAR) 'AX) )

; Section 3.5.5. Define Byte Assembly Operation

(DEFUN ASM-DB!C BYTELIST
; Generates a DB instruction for the bytes in BYTELIST in the form
; (DB BYTELIST) unless BYTELIST is NIL.  Can be used to incorporate
; assembly code which is not supported by the above assembly language
; operations.
; NOTE: This DB operation should be used VERY CAREFULLY.  Insure
;	that all muLISP assembly conventions and constraints are met,
;	and test very thoroughly; for example, CALLs should NOT be
;	included, since in a DB bytelist, they CANNOT be forced to
;	a proper address.
  ((NULL BYTELIST) )
  (TCONC *FNASM*!C (LIST 'DB BYTELIST)) )

; Section 3.6. Assembly Operands

;    The assembly operands used in translation include: registers,
; numbers, indirect operands, "value" operands, "variable" operands,
; locations, services, labels, and jump conditions.  Machinery to
; construct, recognize, and manipulate these operands is developed
; in the following subsections.

; Section 3.6.1. Registers

;    Register operands have the form: AX, BX, CX, DX, BP, SP, SI, DI,
; CS, SS, DS, or ES (no byte registers are needed).  Register types
; and attributes are stored on each register's property list as
; follows:
;    * under 'REGTYPE!C:  register type indicator (WORDREG or SEGREG)
;    * under 'REGPROPS!C: list of special properties of the register:
;			  * ACCUM -- accumulator (AX)
;			  * IND   -- indirect (BX, BP, SI, DI))
;			  * STACK -- stack (SP)
;    * under 'REG-CODE!C: 8086 "reg" code for the register
;    * under 'R/M-CODE!C: 8086 "r/m" code for the register
;    * under 'SEG-CODE!C: 8086 segment override code for the register

; Initialize basic property data for 8086 registers:
(MAPC '(LAMBDA (REGSPEC)
	 (APPLY '(LAMBDA (REG TYP PROPS COD1 COD2)
		   (PUT REG 'REGTYPE!C TYP)
		   (IF PROPS (PUT REG 'REGPROPS!C PROPS))
		   ((EQ TYP 'SEGREG)
		     (PUT REG 'SEG-CODE!C COD1) )
		   (PUT REG 'REG-CODE!C COD1)
		   (IF COD2 (PUT REG 'R/M-CODE!C COD2)) )
		REGSPEC))
      '((AX WORDREG (ACCUM)  0	)    (BX WORDREG (IND)	  3 7)
	(CX WORDREG NIL      1	)    (DX WORDREG NIL	  2  )
	(SP WORDREG (STACK)  4	)    (BP WORDREG (IND)	  5 6)
	(SI WORDREG (IND)    6 4)    (DI WORDREG (IND)	  7 5)
	(CS SEGREG NIL	     1	)    (SS SEGREG NIL	  2  )
	(DS SEGREG NIL	     3	)    (ES SEGREG NIL	  0  )) )

(DEFMACRO IS-REG!C (X)
; Recognizes registers
  (LIST 'GET X ''REGTYPE!C) )

(DEFUN IS-SEGREG!C (X)
; Recognizes segment registers
  (EQ 'SEGREG (GET X 'REGTYPE!C)) )

(DEFUN IS-ACCUM!C (X)
; Recognizes accumulator registers
  (MEMBER 'ACCUM (GET X 'REGPROPS!C)) )

(DEFUN IS-INDREG!C (X)
; Recognizes indirect registers
  (MEMBER 'IND (GET X 'REGPROPS!C)) )

(DEFUN REG-CODE!C (REG code)
; Returns 8086 "reg" code of REG
  (SETQ code (GET REG 'REG-CODE!C))
  ((<= 0 code 7) code)
  ; INTERNAL-ERR @ REG-CODE!C: REG has invalid REG-CODE!C
  (INTERNAL-ERR!C 1060 1 REG code) )

(DEFUN R/M-CODE!C (REG code)
; Returns 8086 "r/m" code of REG
  (SETQ code (GET REG 'R/M-CODE!C))
  ((<= 2 code 7) code)
  ; INTERNAL-ERR @ R/M-CODE!C: REG has invalid R/M-CODE!C
  (INTERNAL-ERR!C 1070 1 REG code) )

(DEFUN SEG-CODE!C (SEGREG code)
; Returns 8086 "seg" code of SEGREG
  (SETQ code (GET SEGREG 'SEG-CODE!C))
  ((<= 0 code 3) code)
  ; INTERNAL-ERR @ SEG-CODE!C: SEGREG has invalid SEG-CODE!C
  (INTERNAL-ERR!C 1080 1 SEGREG code) )

; Section 3.6.2. Numbers

;    Three kinds of numbers are used: 8-bit and 16-bit integers,
; and 16-bit ordinals.

(DEFUN IS-INT8!C (X)
; Recognizes 8-bit integers
  ((NUMBERP X)
    (<= -128 X 127) ) )

(DEFUN IS-INT16!C (X)
; Recognizes 16-bit integers
  ((NUMBERP X)
    (<= -32768 X 32767) ) )

(DEFUN IS-ORD16!C (X)
; Recognizes 16-bit ordinals
  ((NUMBERP X)
    (<= 0 X 65535) ) )

; Section 3.6.3. Indirect operands

;    Indirect operands have the form:
;	([segment-register] indirect-register [int16-offset]).
; They refer to contents of the memory word at the indicated
; location.

(DEFUN IS-INDOPND!C (X)
; Recognizes indirect operands
  ((CONSP X)
    (IF (IS-SEGREG!C (CAR X)) (POP X))
    ((IS-INDREG!C (POP X))
      (IF (IS-INT16!C (CAR X)) (POP X))
      (NULL X) ) ) )

(DEFUN IND!C X
; Constructs indirect operand
  X )

(DEFUN IND-SEG!C (IND)
; Selects segment of IND (DS if none)
  ((IS-SEGREG!C (CAR IND))
    (CAR IND) )
  'DS )

(DEFUN IND-REG!C (IND)
; Selects indirect register of IND
  ((IS-SEGREG!C (CAR IND))
    (CADR IND) )
  (CAR IND) )

(DEFUN IND-OFFSET!C (IND ofst)
; Selects offset of IND (NIL if none)
  (SETQ ofst (CAR (LAST IND)))
  ((NUMBERP ofst) ofst) )

; Section 3.6.4. Value operands

;    Value operands have the form: (VAL muLISP-symbol).  They refer
; to the contents of the value cell of their muLISP-symbol, and are
; used to fetch and store symbol values.

(DEFUN IS-VALOPND!C (X)
; Recognizes value operands
  ((CONSP X)
    ((EQ (POP X) 'VAL)
       ((SYMBOLP (POP X))
	  (NULL X) ) ) ) )

(DEFUN VAL!C ELEMS
; Constructs value operand
  (CONS 'VAL ELEMS) )

(DEFMACRO VAL-SYM!C (VAL)
; Selects symbol of VAL
  (LIST 'CADR VAL) )

; Section 3.6.5. Variable operands

;    Variable operands have the form: (VAR muLISP-symbol).  They
; refer to the address of their muLISP-symbol (i.e., the value of
; (LOCATION muLISP-symbol)), and are used to fetch and store symbols
; themselves.

(DEFUN IS-VAROPND!C (X)
; Recognizes variable operands
  ((CONSP X)
    ((EQ (POP X) 'VAR)
       ((SYMBOLP (POP X))
	  (NULL X) ) ) ) )

(DEFUN VAR!C ELEMS
; Constructs variable operand
  (CONS 'VAR ELEMS) )

(DEFMACRO VAR-SYM!C (VAR)
; Selects symbol of VAR
  (LIST 'CADR VAR) )

; Section 3.6.6. Locations

;    Location operands have the form: (seg-register int16-offset).
; They refer to the contents of the memory word located at the
; int16-offset from the current value of seg-register. They are
; used to fetch and store values of muLISP system variables.

(DEFUN IS-LOC!C (X)
; Recognizes location operands
  ((CONSP X)
    ((IS-SEGREG!C (POP X))
      ((IS-INT16!C (POP X))
	(NULL X) ) ) ) )

(DEFMACRO LOC-SEG!C (LOC)
; Selects segment of LOC
  (LIST 'CAR LOC) )

(DEFMACRO LOC-OFFSET!C (LOC)
; Selects offset of LOC
  (LIST 'CADR LOC) )

; Section 3.6.7. Service operands

;    Service operands have the form: (SVC int16).  They refer to a
; muLISP system service routine whose entry point is stored at the
; address int16 in the muLISP code segment.

(DEFUN IS-SVC!C (X)
; Recognizes service operands
  ((CONSP X)
    ((EQ (POP X) 'SVC)
       ((IS-ORD16!C (POP X))
	  (NULL X) ) ) ) )

(DEFMACRO SVC-ADDR!C (SVC)
; Selects address of SVC
  (LIST 'CADR SVC) )

; Section 3.6.8. Labels

;    Labels provide destinations for JMP and CALL assembly language
; instructions.  The translator generates its own labels in the
; form: !C<n>, for some integer <n>.

(DEFUN MK-LABEL!C NIL
; Returns a new label constructed by packing "!C" onto the
; current value of the special variable *LBLINDEX*!C
  (PACK* '"!C" (INCQ *LBLINDEX*!C)) )

; Section 3.6.9. Jump conditions

;    The assembly of a JMP instruction may include a condition on
; the jump.  The 8086 jump conditions E, A, B, C, G, GE, L, LE, and
; their negations, may be used.  Jump condition attributes are stored
; on their property lists as follows:
;    * under 'JCND!C:	  jump condition indicator (T)
;    * under 'INV-JCND!C: associated inverse (negated) jump condition
;    * under 'JMP-CODE!C: 8086 code for the jump condition

; Initialize basic property data for 8086 jump conditions:
(MAPC '(LAMBDA (JSPEC)
	 (APPLY '(LAMBDA (JC INVJC JCOD)
		   (PUT JC 'JCND!C T)
		   (PUT JC 'INV-JCND!C INVJC)
		   (PUT JC 'JMP-CODE!C JCOD) )
		JSPEC))
      '((E NE 116)  (NE E 117)	(A NA 119)  (NA A 118)
	(B NB 114)  (NB B 115)	(C NC 114)  (NC C 115)
	(G LE 127)  (GE L 125)	(L GE 124)  (LE G 126) ) )

(DEFMACRO IS-JCND!C (X)
; Recognizes jump conditions
  (LIST 'GET X ''JCND!C) )

(DEFUN INV-JCND!C (JC)
; Returns inverse jump condition of JC
  ((GET JC 'INV-JCND!C) )
  ; INTERNAL-ERR @ INV-JCND!C: JC has no INV-JCND!C property
  (INTERNAL-ERR!C 1090 1 JC) )

(DEFUN JMP-CODE!C (JC)
; Returns 8086 jump code of JC
  ((GET JC 'JMP-CODE!C) )
  ; INTERNAL-ERR @ JMP-CODE!C: JC has no JMP-CODE!C property
  (INTERNAL-ERR!C 1100 1 JC) )

; Section 3.7. Symbol Source/Destination Operand Constructors

;    The following operand constructors systematize the generation
; of source and destination operands for muLISP symbols.  They
; should be used in lieu of explicit (VAL symbol) constructions.

(DEFUN SYMBOL-SRC-OPND!C (SYM)
; Returns an operand for the symbol SYM which can be used
; as a source in an 8086 assembly language instruction
; (i.e., in fetching SYM's current value).
  ; if SYM is a symbol,
  ((SYMBOLP SYM)
    ; if SYM always evaluates to itself,
    ((CONSTANTP SYM)
      ; return variable operand (immediate)
      (VAR!C SYM) )
    ; otherwise, return as value operand
    (VAL!C SYM) )
  ; INTERNAL-ERR @ SYMBOL-SRC-OPND!C: SYM is not a symbol
  (INTERNAL-ERR!C 1110 1 SYM) )

(DEFUN SYMBOL-DEST-OPND!C (SYM)
; Returns an operand for the symbol SYM which can be used
; as a destination in an 8086 assembly language instruction
; (i.e., in storing a new value for SYM).
  ; if SYM is a symbol,
  ((SYMBOLP SYM)
    ; if SYM always evaluates to itself,
    ((CONSTANTP SYM)
      ; INTERNAL-ERR @ SYMBOL-DEST-OPND!C: SYM is a CONSTANTP
      (INTERNAL-ERR!C 1120 1 SYM) )
    ; otherwise, return as value operand
    (VAL!C SYM) )
  ; INTERNAL-ERR @ SYMBOL-DEST-OPND!C: SYM is not a symbol
  (INTERNAL-ERR!C 1120 2 SYM) )

((LAMBDA (FILE)
  (SETQ FILE (FIND "COMPILE0.LSP" (INPUT-FILES) 'FINDSTRING)
	FILE (SUBSTRING FILE 0 (- (LENGTH FILE) 6)))
  (LOAD (PACK* FILE 1 ".LSP"))
  (LOAD (PACK* FILE 2 ".LSP"))
  (LOAD (PACK* FILE 3 ".LSP")) ) )
