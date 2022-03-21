; File: COMPILE3.LSP  (c)	01/27/87	Soft Warehouse, Inc.

; Section 6.  CODE GENERATION * * * * * * * * * * * * * * * * * * * * * *

;    The result of translating a function with TRANS-FN!C is a list
; of assembly language instructions of the form:
;	(opcode [op1] [op2]).
; This section presents the means by which "raw" machine code for the
; individual assembly language instructions is generated.  The next
; section then describes how the generation of this machine code is
; managed as a part of the overall assembly process.

;    Machine code generation for an individual assembly language
; instruction is driven by a "code generation specification" for the
; opcode of the instruction.  Stored on the property list of the
; opcodes, these specifications define the acceptable operand types
; for the instruction as well as the procedure for generating its
; machine code.

;    Code generation specifications are applied by the function
; GEN-CODE, defined in 6.1.  The code generation specifications used
; by the compiler are presented in 6.2.  They rely on some basic code
; generation functions, operand specifiers, and other supporting code
; generation machinery defined in 6.3-6.5.

; Section 6.1. Machine Code Generation Function

(DEFUN GEN-CODE!C (INST *OPCODE*!C *OP1*!C *OP2*!C
		   cgspecs nopnds cgspec)
; Generates and returns a list of bytes representing the machine code
; for INST, an assembly language instruction of the form:
;	(opcode [op1] [op2]).
; First decomposes INST into its constituent opcode (*OPCODE*!C) and
; operands, if any, (*OP1*!C and *OP2*!C); then accesses the "code
; generation specification" for the opcode, and applies it to the
; instruction, checking for operand type mismatches.
; NOTE: *OPCODE*!C, *OP1*!C, and *OP2*!C are special variables used
;	freely in the code generation specs as well as in the
;	functions they call.
  ; decompose INST into *OPCODE*!C, *OP1*!C, and *OP2*!C
  (SETQ *OPCODE*!C (CAR INST))
  (SETQ *OP1*!C (CADR INST))
  (SETQ *OP2*!C (CADDR INST))
  ; if *OPCODE*!C has a CODE-GEN-SPEC property, cgspecs,
  ((SETQ cgspecs (GET *OPCODE*!C 'CODE-GEN-SPEC!C))
    ; get the number of operands of cgspecs
    (SETQ nopnds (CAR cgspecs))
    ; if the number of operands is 0, then
    ((EQL nopnds 0)
      ; if *OP1*!C and *OP2*!C are both NIL,
      ((AND
	  (NULL *OP1*!C)
	  (NULL *OP2*!C) )
	; evaluate the specification
	(EVAL (CDR cgspecs)) )
      ; INTERNAL-ERR @ GEN-CODE!C: Too many operands in INST
      (INTERNAL-ERR!C 3080 1 *OPCODE*!C *OP1*!C *OP2*!C nopnds) )
    ; if the number of operands is 1, then
    ((EQL nopnds 1)
      ; if *OP2*!C is NIL, then
      ((NULL *OP2*!C)
	; if cgspecs contains a specification, cgspec, for the
	; operand type of *OP1*!C,
	((SETQ cgspec (ASSOC (OPND-TYPE!C *OP1*!C) (CDR cgspecs)))
	  ; evaluate that specification
	  (EVAL (CDR cgspec)) )
	; INTERNAL-ERR @ GEN-CODE!C: Invalid operand for INST
	(INTERNAL-ERR!C 3080 2 *OPCODE*!C *OP1*!C *OP2*!C nopnds) )
      ; INTERNAL-ERR @ GEN-CODE!C: Too many operands in INST
      (INTERNAL-ERR!C 3080 3 *OPCODE*!C *OP1*!C *OP2*!C nopnds) )
    ; if the number of operands is 2, then
    ((EQL nopnds 2)
      ; if cgspecs contains a specification, cgspec, for the
      ; operand types of *OP1*!C and *OP2*!C,
      ((SETQ cgspec (ASSOC (OPND-TYPE!C *OP2*!C)
			   (ASSOC (OPND-TYPE!C *OP1*!C)
				  (CDR cgspecs))))
	; evaluate that specification
	(EVAL (CDR cgspec)) )
      ; INTERNAL-ERR @ GEN-CODE!C: Invalid operands for INST
      (INTERNAL-ERR!C 3080 4 *OPCODE*!C *OP1*!C *OP2*!C nopnds) )
    ; INTERNAL-ERR @ GEN-CODE!C: Invalid CODE-GEN-SPEC for INST
    (INTERNAL-ERR!C 3080 5 *OPCODE*!C *OP1*!C *OP2*!C nopnds cgspecs) )
  ; INTERNAL-ERR @ GEN-CODE!C: No CODE-GEN-SPEC for INST
  (INTERNAL-ERR!C 3080 6 *OPCODE*!C *OP1*!C *OP2*!C) )

; Section 6.2. Code Generation Specifications

;    Code generation specifications are stored as the CODE-GEN-SPEC!C
; property of assembly language opcodes (MOV, ADD, CALL, ...).	Each
; spec has the form:
;	(nopnds . gen-spec)
; where <nopnds> is the number of operands accepted by the
; instruction, and <gen-spec> is a list whose structure depends on
; <nopnds> as follows:
;    *	If <nopnds> is 0, <gen-spec> will be an expression which,
;	when evaluated, will produce the appropriate list of machine
;	code bytes  for the instruction.
;    *	If <nopnds> is 1, <gen-spec> will be an alist whose keys are
;	the operand types acceptable to the instruction, and whose
;	values are expressions which, when evaluated, will produce
;	the appropriate lists of machine code bytes for the
;	instruction.
;    *	If <nopnds> is 2, <gen-spec> will be an alist whose keys are
;	the acceptable operand types for the first operand, and whose
;	values are alists whose keys are the acceptable operand types
;	for the second operand.  The values of these final alists,
;	then, are expressions which, when evaluated, will produce the
;	appropriate list of machine code bytes for the instruction.
;
;    The evaluation of the final code generation expressions is
; performed in the GEN-CODE!C context including the special variables
; *OPCODE*!C, *OP1*!C, and *OP2*!C, bound, respectively, to the
; assembly instruction opcode, the first operand (if any), and the
; second operand (if any), of the instruction.	Thus, code generation
; specifications can and do use these special variable values.

; Section 6.2.1. MOV

(PUT 'MOV 'CODE-GEN-SPEC!C
  '(2 (WORDREG (WORDREG  R/R-OPN!C 139)
	       (IND	 R/M-OPN!C 139 'INDSPEC!C)
	       (VAL	 R/M-MOV!C 1 'VALSPEC!C)
	       (LOC	 R/M-MOV!C 1 'LOCSPEC!C)
	       (INT8	 R/I-MOV!C 1 'WORDSPEC!C)
	       (INT16	 R/I-MOV!C 1 'WORDSPEC!C)
	       (ORD16	 R/I-MOV!C 1 'WORDSPEC!C)
	       (VAR	 R/I-MOV!C 1 'VARSPEC!C) )
      (IND     (WORDREG  M/R-OPN!C 137 'INDSPEC!C)
	       (VAR	 M/I-OPN!C 199 0 'INDSPEC!C 'VARSPEC!C) )
      (VAL     (WORDREG  M/R-MOV!C 1 'VALSPEC!C)
	       (VAR	 M/I-OPN!C 199 0 'VALSPEC!C 'VARSPEC!C) )
      (LOC     (WORDREG  M/R-MOV!C 1 'LOCSPEC!C)
	       (INT8	 M/I-OPN!C 199 0 'LOCSPEC!C 'WORDSPEC!C)
	       (INT16	 M/I-OPN!C 199 0 'LOCSPEC!C 'WORDSPEC!C)
	       (VAR	 M/I-OPN!C 199 0 'LOCSPEC!C 'VARSPEC!C) ) ) )

; Section 6.2.2. XCHG

(PUT 'XCHG 'CODE-GEN-SPEC!C
  '(2 (WORDREG (WORDREG  R/R-OPN!C 135)
	       (IND	 R/M-OPN!C 135 'INDSPEC!C)
	       (VAL	 R/M-OPN!C 135 'VALSPEC!C)
	       (LOC	 R/M-OPN!C 135 'LOCSPEC!C) ) ) )

; Section 6.2.3. CMP

(PUT 'CMP 'CODE-GEN-SPEC!C
  '(2 (WORDREG (WORDREG  R/R-OPN!C 59)
	       (IND	 R/M-OPN!C 59 'INDSPEC!C)
	       (VAL	 R/M-OPN!C 59 'VALSPEC!C)
	       (LOC	 R/M-OPN!C 59 'LOCSPEC!C)
	       (INT8	 R/I-OPN!C 131 7 'BYTESPEC!C)
	       (INT16	 R/I-OPN!C 129 7 'WORDSPEC!C)
	       (VAR	 R/I-OPN!C 129 7 'VARSPEC!C) )
      (IND     (WORDREG  M/R-OPN!C 57 'INDSPEC!C)
	       (VAR	 M/I-OPN!C 129 7 'INDSPEC!C 'VARSPEC!C) )
      (VAL     (WORDREG  M/R-OPN!C 57 'VALSPEC!C)
	       (VAR	 M/I-OPN!C 129 7 'VALSPEC!C 'VARSPEC!C) )
      (LOC     (WORDREG  M/R-OPN!C 57 'LOCSPEC!C)
	       (INT8	 M/I-OPN!C 131 7 'LOCSPEC!C 'BYTESPEC!C)
	       (INT16	 M/I-OPN!C 129 7 'LOCSPEC!C 'WORDSPEC!C)
	       (VAR	 M/I-OPN!C 129 7 'LOCSPEC!C 'VARSPEC!C) ) ) )

; Section 6.2.4. ADD

(PUT 'ADD 'CODE-GEN-SPEC!C
  '(2 (WORDREG (WORDREG  R/R-OPN!C 3)
	       (INT8	 R/I-OPN!C 131 0 'BYTESPEC!C)
	       (INT16	 R/I-OPN!C 129 0 'WORDSPEC!C) ) ) )

; Section 6.2.5. SUB

(PUT 'SUB 'CODE-GEN-SPEC!C
  '(2 (WORDREG (WORDREG  R/R-OPN!C 43)
	       (INT8	 R/I-OPN!C 131 5 'BYTESPEC!C)
	       (INT16	 R/I-OPN!C 129 5 'WORDSPEC!C) ) ) )

; Section 6.2.6. JMP

(PUT 'JMP 'CODE-GEN-SPEC!C
  '(2 (LBL     (JCND  LIST (JMP-CODE!C (INV-JCND!C *OP2*!C))
			   3 233 *OP1*!C *OP1*!C)
	       (OPTNL LIST 233 *OP1*!C *OP1*!C) )
      (WORDREG (OPTNL R-OPN!C 255 4) ) ) )

; Section 6.2.7. SJMP

(PUT 'SJMP 'CODE-GEN-SPEC!C
  '(2 (LBL     (JCND  LIST (JMP-CODE!C *OP2*!C) *OP1*!C)
	       (OPTNL LIST 235 *OP1*!C) ) ) )

; Section 6.2.8. CALL

(PUT 'CALL 'CODE-GEN-SPEC!C
  '(1 (LBL     LIST 144 232 *OP1*!C *OP1*!C)
      (INT8    LIST 144 232 'TGT *OP1*!C)
      (INT16   LIST 144 232 'TGT *OP1*!C)
      (ORD16   LIST 144 232 'TGT *OP1*!C)
      (SVC     LIST 144 232 'TGT (CSMEMORY (CADR *OP1*!C) NIL T))
      (WORDREG CONS 144 (R-OPN!C 255 2)) ) )

; Section 6.2.9. RET

(PUT 'RET 'CODE-GEN-SPEC!C
  '(0 LIST 195) )

; Section 6.2.10. DB

(PUT 'DB 'CODE-GEN-SPEC!C
  '(1 (BYTELIST IDENTITY *OP1*!C) ) )

; Section 6.3. Basic Code Generation Functions

;    The actual generation of machine code bytes is accomplished by
; a relatively small number of "standard" and "optimized" code
; generation functions for the 8086 microprocessor.

; Section 6.3.1. "Standard" Code Generation Functions

;    A great deal of machine code can be generated with "standard"
; functions organized in terms of general operand type (register,
; memory, or immediate).

(DEFUN R-OPN!C (OPCODE SUBCODE)
; Generates a standard 8086 single register operation for *OP1*!C,
; OPCODE and SUBCODE.
  (LIST OPCODE (MOD-REG-R/M!C 3 SUBCODE (REG-CODE!C *OP1*!C))) )

(DEFUN R/R-OPN!C (OPCODE)
; Generates a standard 8086 register-register operation for *OP1*!C,
; *OP2*!C, and OPCODE.
  (LIST OPCODE
	(MOD-REG-R/M!C 3 (REG-CODE!C *OP1*!C) (REG-CODE!C *OP2*!C))) )

(DEFUN R/M-OPN!C (OPCODE MSPECFN)
; Generates a standard 8086 register-memory operation for *OP1*!C,
; *OP2*!C, OPCODE, and the memory specifier function MSPECFN.
  (SEG-OVERRIDE!C *OP2*!C
	   (CONS OPCODE
		 (FUNCALL MSPECFN *OP2*!C (REG-CODE!C *OP1*!C)))) )

(DEFUN R/I-OPN!C (OPCODE SUBCODE ISPECFN)
; Generates a standard 8086 register-immediate operation for *OP1*!C,
; *OP2*!C, OPCODE, SUBCODE, and the immediate specifier function
; ISPECFN.
  (LIST* OPCODE (MOD-REG-R/M!C 3 SUBCODE (REG-CODE!C *OP1*!C))
	 (FUNCALL ISPECFN *OP2*!C)) )

(DEFUN M/R-OPN!C (OPCODE MSPECFN)
; Generates a standard 8086 memory-register operation for *OP1*!C,
; *OP2*!C, OPCODE, and the memory specifier function MSPECFN.
  (SEG-OVERRIDE!C *OP1*!C
	   (CONS OPCODE
		 (FUNCALL MSPECFN *OP1*!C (REG-CODE!C *OP2*!C)))) )

(DEFUN M/I-OPN!C (OPCODE SUBCODE MSPECFN ISPECFN)
; Generates a standard 8086 memory-immediate operation for *OP1*!C,
; *OP2*!C, OPCODE, SUBCODE, the memory specifier function MSPECFN,
; and the immediate specifier function ISPECFN.
  (SEG-OVERRIDE!C *OP1*!C
	   (CONS OPCODE (NCONC (FUNCALL MSPECFN *OP1*!C SUBCODE)
			       (FUNCALL ISPECFN *OP2*!C)))) )

; Section 6.3.2. "Optimized" Code Generation Functions

;    For certain assembly opcodes, machine code faster or shorter
; than the "standard" sequences can be generated.  The compiler
; uses "optimized" code generation functions for the MOV opcode.

(DEFUN R/M-MOV!C (W MSPECFN)
; Generates an optimized 8086 register-memory MOV operation for
; *OP1*!C,*OP2*!C, the byte/word bit W, and the memory specifier
; function MSPECFN.
  ((IS-ACCUM!C *OP1*!C)
    (SEG-OVERRIDE!C *OP2*!C
	     (CONS (+ 160 W) (CDR (FUNCALL MSPECFN *OP2*!C
					   (REG-CODE!C *OP1*!C))))) )
  (R/M-OPN!C (+ 138 W) MSPECFN) )

(DEFUN R/I-MOV!C (W ISPECFN)
; Generates an optimized 8086 register-immediate MOV operation for
; *OP1*!C,*OP2*!C, the byte/word bit W, and the immediate specifier
; function ISPECFN.
  (CONS (+ 176 (* 8 W) (REG-CODE!C *OP1*!C))
	(FUNCALL ISPECFN *OP2*!C) ) )

(DEFUN M/R-MOV!C (W MSPECFN)
; Generates an optimized 8086 memory-register MOV operation for
; *OP1*!C,*OP2*!C, the byte/word bit W, and the memory specifier
; function MSPECFN.
  ((IS-ACCUM!C *OP2*!C)
    (SEG-OVERRIDE!C *OP1*!C
	     (CONS (+ 162 W) (CDR (FUNCALL MSPECFN *OP1*!C
					   (REG-CODE!C *OP2*!C))))) )
  (M/R-OPN!C (+ 136 W) MSPECFN) )

; Section 6.4. Assembly Operand Specifiers

;    The 8086 architecture requires memory and immediate operands
; to be specified in bytes following the basic opcode byte.  The
; following functions generate these bytes for the operands used by
; the compiler.

; Section 6.4.1. Memory Operand Specifiers

(DEFUN INDSPEC!C (OPND COD indreg offset)
; Returns a list of bytes specifying the indirect operand OPND as
; an 8086 memory operand, using COD as the value of the "reg"
; field in the MOD-REG-R/M!C byte.
  ((IS-INDOPND!C OPND)
    (SETQ indreg (IND-REG!C OPND))
    (SETQ offset (IND-OFFSET!C OPND))
    ((NULL offset)
      ((EQ indreg 'BP)
	(LIST (MOD-REG-R/M!C 1 COD (R/M-CODE!C 'BP)) 0) )
      (LIST (MOD-REG-R/M!C 0 COD (R/M-CODE!C indreg))) )
    ((IS-INT8!C offset)
      (LIST (MOD-REG-R/M!C 1 COD (R/M-CODE!C indreg))
	    (TWOS-COMP-BYTE!C offset)) )
    (CONS (MOD-REG-R/M!C 2 COD (R/M-CODE!C indreg))
	  (LO/HI-BYTES!C (TWOS-COMP-WORD!C offset))) )
  ; INTERNAL-ERR @ INDSPEC!C: Invalid indirect operand OPND
  (INTERNAL-ERR!C 3020 1 OPND COD) )

(DEFUN LOCSPEC!C (OPND COD)
; Returns a list of bytes specifying the location operand OPND as
; an 8086 memory operand, using COD as the value of the "reg"
; field in the MOD-REG-R/M!C byte.
  ((IS-LOC!C OPND)
    (CONS (MOD-REG-R/M!C 0 COD 6)
	  (LO/HI-BYTES!C (LOC-OFFSET!C OPND))) )
  ; INTERNAL-ERR @ LOCSPEC!C: Invalid location operand OPND
  (INTERNAL-ERR!C 3030 1 OPND COD) )

(DEFUN VALSPEC!C (OPND COD)
; Returns a list of bytes specifying the value of the symbol OPND
; as an 8086 memory operand, using COD as the value of the "reg"
; field in the MOD-REG-R/M!C byte.
  ((IS-VALOPND!C OPND)
    (CONS (MOD-REG-R/M!C 0 COD 6) (SYM-REF!C (VAL-SYM!C OPND))) )
  ; INTERNAL-ERR @ VALSPEC!C: Invalid value operand OPND
  (INTERNAL-ERR!C 3040 1 OPND COD) )

; Section 6.4.2. Immediate Operand Specifiers

(DEFUN BYTESPEC!C (IMM)
; Returns a list of one byte specifying the value of the byte
; IMM as an immediate operand.
  ((IS-INT8!C IMM)
    (LIST (TWOS-COMP-BYTE!C IMM)) )
  ; INTERNAL-ERR @ BYTESPEC!C: Invalid byte operand IMM
  (INTERNAL-ERR!C 3050 1 IMM) )

(DEFUN WORDSPEC!C (IMM)
; Returns a list of two bytes specifying the value of the word
; IMM as an 8086 immediate operand.
  ((IS-INT16!C IMM)
    (LO/HI-BYTES!C (TWOS-COMP-WORD!C IMM)) )
  ; INTERNAL-ERR @ WORDSPEC!C: Invalid word operand IMM
  (INTERNAL-ERR!C 3060 1 IMM) )

(DEFUN VARSPEC!C (IMM)
; Returns a list of two bytes specifying the offset of the symbol
; IMM as an 8086 immediate operand.
  ((IS-VAROPND!C IMM)
    (SYM-REF!C (VAR-SYM!C IMM)) )
  ; INTERNAL-ERR @ VARSPEC!C: Invalid VAR IMM
  (INTERNAL-ERR!C 3070 1 IMM) )

; Section 6.4.3. Symbol Referencer

(DEFUN SYM-REF!C (SYM)
; Returns a list of two bytes specifying the offset of the symbol
; SYM in the muLISP DS segment;  also pushes SYM onto the list
; *FNSYMS*!C if it is not already there.
; NOTE: *FNSYMS*!C is bound and used in ASSEMBLE-FN!C (see 7.1, below)
  (IF (NOT (MEMBER SYM *FNSYMS*!C)) (PUSH SYM *FNSYMS*!C) )
  (LO/HI-BYTES!C (LOCATION SYM)) )

; Section 6.5. Supporting Code Generation Machinery

(DEFUN OPND-TYPE!C (X)
; Returns the type of X considered as an assembly operand
  ; if symbol, then
  ((SYMBOLP X)
    ; if register, return register type
    ((IS-REG!C X) )
    ; if jump condition, return 'JCND
    ((IS-JCND!C X) 'JCND)
    ; if NIL, return 'OPTNL ("optional")
    ((NULL X) 'OPTNL)
    ; otherwise, return 'LBL ("label")
    'LBL )
  ; if number, then
  ((NUMBERP X)
    ; if 8-bit integer, return 'INT8
    ((IS-INT8!C X) 'INT8)
    ; if 16-bit integer, return 'INT16
    ((IS-INT16!C X) 'INT16)
    ; if 16-bit ordinal, return 'ORD16
    ((IS-ORD16!C X) 'ORD16)
    ; otherwise, return NIL
    NIL )
  ; if indirect operand, return 'IND
  ((IS-INDOPND!C X) 'IND)
  ; if value operand, return 'VAL
  ((IS-VALOPND!C X) 'VAL)
  ; if variable operand, return 'VAR
  ((IS-VAROPND!C X) 'VAR)
  ; if location operand, return 'LOC
  ((IS-LOC!C X) 'LOC)
  ; if service operand, return 'SVC
  ((IS-SVC!C X) 'SVC)
  ; if every element is an 8-bit ordinal, return 'BYTELIST
  ((EVERY '(LAMBDA (N) (AND (NUMBERP N) (<= 0 N 255)) )
	  X)
    'BYTELIST)
  ; otherwise, return NIL
  NIL )

; Section 6.5.2. Numerical Operations

(DEFUN TWOS-COMP-BYTE!C (NUM)
; Returns the 2's complement byte representation of NUM.
  ((<= 0 NUM 127) NUM)
  ((<= -128 NUM -1)
    (+ NUM 256) )
  ; INTERNAL-ERR @ TWOS-COMP-BYTE!C: Invalid NUM
  (INTERNAL-ERR!C 1030 1 NUM) )

(DEFUN TWOS-COMP-WORD!C (NUM)
; Returns the 2's complement word representation of NUM.
  ((<= 0 NUM 32767) NUM)
  ((<= -32768 NUM -1)
    (+ NUM 65535 1) )
  ; INTERNAL-ERR @ TWOS-COMP-WORD!C: Invalid NUM
  (INTERNAL-ERR!C 1040 1 NUM) )

(DEFUN TWOS-COMP-DISP!C (NUM)
; Returns the 2's complement word representation of NUM,
; considered as a DISPLACEMENT!C within a 64K byte segment
; (i.e., "wraparound" is permitted).
  ((<= 0 NUM 65535) NUM)
  ((<= -65535 NUM -1)
    (+ NUM 65535 1) )
  ; INTERNAL-ERR @ TWOS-COMP-DISP!C: Invalid NUM
  (INTERNAL-ERR!C 1130 1 NUM) )

(DEFUN LO/HI-BYTES!C (NUM)
; Returns a list of the low-order and high-order bytes of NUM
; in that order.
  ((<= 0 NUM 65535)
    (LIST (MOD NUM 256) (FLOOR NUM 256)) )
  ; INTERNAL-ERR @ LO/HI-BYTES!C: Invalid NUM
  (INTERNAL-ERR!C 1050 1 NUM) )

; Section 6.5.3. MOD-REG-R/M!C Operation

(DEFUN MOD-REG-R/M!C (MOD COD RM)
; Generates an 8086 "mod reg r/m" addressing mode byte for the MOD,
; COD, and RM arguments.
  ((<= 0 MOD 3)
    ((<= 0 COD 7)
      ((<= 0 RM 7)
	(+ (* MOD 64) (* COD 8) RM) )
      ; INTERNAL-ERR @ MOD-REG-R/M!C: Invalid RM
      (INTERNAL-ERR!C 3010 1 MOD COD RM) )
    ; INTERNAL-ERR @ MOD-REG-R/M!C: Invalid COD
    (INTERNAL-ERR!C 3010 2 MOD COD RM) )
  ; INTERNAL-ERR @ MOD-REG-R/M!C: Invalid MOD
  (INTERNAL-ERR!C 3010 3 MOD COD RM) )

; Section 6.5.4. Segment Override Operation

(DEFUN SEG-OVERRIDE!C (MEM INSTSEQ seg)
; Adds a segment override byte to the machine code instruction
; sequence INSTSEQ if the memory operand MEM indicates a segment
; register other than DS.
  ((CONSP MEM)
    (SETQ seg (IF (IS-SEGREG!C (CAR MEM)) (CAR MEM) 'DS))
    ((EQ seg 'DS) INSTSEQ)
    (CONS (+ 38 (* 8 (SEG-CODE!C seg))) INSTSEQ) )
  ; INTERNAL-ERR @ SEG-OVERRIDE!C: Invalid MEM
  (INTERNAL-ERR!C 3150 1 MEM) )


; Section 7. ASSEMBLY PROCESS  * * * * * * * * * * * * * * * * * * * * * *

;    This section develops the means by which the code generation
; machinery presented in Section 6, above, is managed, and also the
; additional processing needed to convert the resulting machine code
; into a loadable block of machine code.

;    The product of the assembly process is a list representing the
; loadable block of machine code generated.  The length of the list
; must correspond to the number of bytes of machine code generated.
; The first element of this list must be the name of the function
; whose definition it will replace.  Each remaining element of the
; list must either be the symbol "TGT" or a number.  Each TGT element
; must be followed by a number which is an offset in the muLISP code
; segment, and may therefore be any 16-bit ordinal.  Together, each
; TGT-number "chunk" of the list represents a 2-byte displacement
; from that position in the machine code to the indicated offset. All
; other elements of the list must be numbers representing bytes of
; actual machine code.

;    The function ASSEMBLE-FN!C defined in 7.1 is the top-level of the
; overall assembly process.  It operates by producing and processing
; a list of "assembly records".  Machinery to construct, access, and
; modify assembly records is defined in 7.2.  The additional assembly
; processing stages are then defined in 7.3 - 7.7.

; Section 7.1. Basic Assembly Function

(DEFUN ASSEMBLE-FN!C (*FNASM*!C)
; Assembles *FNASM*!C, a list of the form:
;     (FN . assembly-language-instructions),
; returning the list of machine code generated by the assembly. The
; elements of this list may be numbers or the symbol "TGT".  TGT must
; always be followed by a number which is an offset in the muLISP
; code segment, and may therefore be any 16-bit ordinal.  All other
; numbers must be bytes.
  (LET ((obs (OBLIST))
	; = the symbols currently on the oblist -- this temporarily
	;   freezes the oblist to prevent any movement of symbols
	;   during garbage collection/reallocations
	(*FNLBLS*!C (LIST (CAR *FNASM*!C)))
	; = list onto which labels encountered in *FNASM*!C are PUSHed
	;   during code generation (pushing is done by SYM-REF)
	(*FNSYMS*!C NIL)
	; = list onto which muLISP symbols referenced in *FNASM*!C are
	;   PUSHed during code generation
	(*ASMRECS*!C NIL) )
	; = list of assembly records for *FNASM*!C
    ; build the assembly records,
    (SETQ *ASMRECS*!C
	  (BUILD-ASMRECS!C (CAR *FNASM*!C) (CDR *FNASM*!C)))
    ; process the jumps,
    (PROCESS-JMPS!C *ASMRECS*!C)
    ; finalize the positions,
    (FINALIZE-PSNS!C *ASMRECS*!C)
    ; freeze the symbol locations, and
    (FREEZE-SYMBOLS!C *FNSYMS*!C)
    ; collect the code
    (COLLECT-CODE!C *ASMRECS*!C) ) )

; Section 7.2. Basic Assembly Record Operations

;    An "assembly record" is a 4-element list whose elements are used
; uniformly as fields as follows:
;    * INST = the instruction field, containing the assembly language
;	      instruction of the record, or (NIL), if the record
;	      includes multiple instructions.
;	      (NOTE: this MUST be the first field in an assembly
;		     record so that ASSOC can be used to find labels.)
;    * PSN  = the position field, containing the position of the
;	      first machine code byte of the record (starting at 1).
;    * OPS  = the operations field, containing a list of the machine
;	      code of the record.
;    * LEN  = the length field, containing the number of bytes in the
;	      machine code of the record

(DEFMACRO MK-ASMREC!C (INST PSN OPS LEN)
; Constructs assembly record for INST, PSN, OPS, and LEN
  (LIST 'LIST INST PSN OPS LEN) )

(DEFMACRO INST-OF!C (ASMREC)
; Selects INST component of ASMREC
  (LIST 'CAR ASMREC) )

(DEFMACRO PSN-OF!C (ASMREC)
; Selects PSN component of ASMREC
  (LIST 'CADR ASMREC) )

(DEFMACRO OPS-OF!C (ASMREC)
; Selects OPS component of ASMREC
  (LIST 'CADDR ASMREC) )

(DEFMACRO LEN-OF!C (ASMREC)
; Selects LEN component of ASMREC
  (LIST 'CADDDR ASMREC) )

(DEFMACRO mu-PSN!C (ASMREC NEWPSN)
; Mutates PSN component of ASMREC to NEWPSN
  (LIST 'RPLACA (LIST 'CDR ASMREC) NEWPSN) )

(DEFMACRO mu-OPS!C (ASMREC NEWOPS)
; Mutates OPS component of ASMREC to NEWOPS
  (LIST 'RPLACA (LIST 'CDDR ASMREC) NEWOPS) )

(DEFMACRO mu-LEN!C (ASMREC NEWLEN)
; Mutates LEN component of ASMREC to NEWLEN
  (LIST 'RPLACA (LIST 'CDDDR ASMREC) NEWLEN) )

; Section 7.3. Assembly Record Construction

(DEFUN BUILD-ASMRECS!C (FN FNASM asmrecs psn inst ops)
; Builds and returns a list of assembly records for FN, the function
; name, and FNASM, a list of assembly instructions for the function.
  ; initialize asmrecs to collect assembly records built
  (SETQ asmrecs (CONS))
  ; initialize psn to maintain current code position
  (SETQ psn 1)
  ; build and collect an assembly record for FN as a label
  (TCONC asmrecs (MK-ASMREC!C FN psn (CONS FN) 0))
  ; build assembly records for FNASM:
  (LOOP
    ; if no more assembly instructions, return assembly records
    ; built and collected
    ((NULL FNASM)
      (CAR asmrecs) )
    ; otherwise, POP the next instruction from FNASM,
    (SETQ inst (POP FNASM))
    ; and generate assembly for it, depending on its form:
      ; if atom, then
    ( ((ATOM inst)
	; if symbol, treat as a label:
	((SYMBOLP inst)
	  ; if NOT already been encountered as a label,
	  ((NOT (MEMBER inst *FNLBLS*!C))
	    ; add it to *FNLBLS*!C,
	    (PUSH inst *FNLBLS*!C)
	    ; and build and collect an assembly record for the label
	    (TCONC asmrecs (MK-ASMREC!C inst psn NIL 0)) )
	  ; INTERNAL-ERR @ BUILD-ASMRECS!C: Label inst already used
	  (INTERNAL-ERR!C 3100 1 FN FNASM inst) )
	; INTERNAL-ERR @ BUILD-ASMRECS!C: Numeric instruction inst
	(INTERNAL-ERR!C 3100 2 FN FNASM inst) )
      ; if JMP, CALL, or SJMP instruction,
      ((MEMBER (CAR inst) '(JMP CALL SJMP))
	; generate code for it
	(SETQ ops (GEN-CODE!C inst))
	; build and collect an assembly record for the code
	(TCONC asmrecs (MK-ASMREC!C inst psn ops (LENGTH ops)))
	; adjust psn for the length of the code
	(INCQ psn (LENGTH ops)) )
      ; otherwise, generate code up to the next label, or CALL, JMP,
      ; or SJMP assembly instruction
      (SETQ ops (CONS))
      (LOOP
	; generate and collect code for inst
	(LCONC ops (GEN-CODE!C inst))
	; if next instruction is an ATOM or a CALL, JMP, or SJMP,
	((OR (ATOM (CAR FNASM))
	     (MEMBER (CAAR FNASM) '(JMP CALL SJMP)))
	  ; set ops to the code actually collected,
	  (SETQ ops (CAR ops))
	  ; build and collect an assembly record for that code,
	  (TCONC asmrecs (MK-ASMREC!C (CONS) psn ops (LENGTH ops)))
	  ; and adjust psn for the length of the code
	  (INCQ psn (LENGTH ops)) )
	; otherwise, get the next assembly instruction and continue
	; generating code
	(SETQ inst (POP FNASM)) ) ) ) )

; Section 7.4. Jump Processing

(DEFUN PROCESS-JMPS!C (ASMRECS)
; Processes the jumps in ASMRECS three times to convert "long" jumps
; to "short" jumps.
  ; process jumps in ASMRECS once
  (MAPC 'PROCESS-JMP!C ASMRECS)
  ; position ASMRECS
  (PSN-ASMRECS!C ASMRECS)
  ; process jumps in ASMRECS again
  (MAPC 'PROCESS-JMP!C ASMRECS)
  ; position ASMRECS
  (PSN-ASMRECS!C ASMRECS)
  ; process jumps in ASMRECS again
  (MAPC 'PROCESS-JMP!C ASMRECS) )

(DEFUN PROCESS-JMP!C (JREC inst dest)
; Processes assembly record JREC, if its assembly instruction is a
; JMP, by attempting to replace its code with short jump code
  ; if assembly instruction of JREC is a JMP,
  ((EQ (CAR (INST-OF!C JREC)) 'JMP)
    ; get the JMP instruction and its destination
    (SETQ inst (INST-OF!C JREC))
    (SETQ dest (CADR inst))
    ; if the destination is a label, then
    ((EQ (OPND-TYPE!C dest) 'LBL)
      ; if the label was encountered in building assembly records,
      ((MEMBER dest *FNLBLS*!C)
	; if the DISPLACEMENT!C from the record to the destination
	; is an 8-bit integer,
	((IS-INT8!C (DISPLACEMENT!C JREC dest))
	  ; replace the JMP with SJMP (short jump), generate code for
	  ; it, and modify the assembly record accordingly
	  (mu-OPS!C JREC (GEN-CODE!C (RPLACA inst 'SJMP)))
	  (mu-LEN!C JREC (LENGTH (OPS-OF!C JREC))) ) )
      ; INTERNAL-ERR @ PROCESS-JMP!C: Invalid jump inst
      (INTERNAL-ERR!C 3110 1 JREC inst) ) ) )

(DEFUN DISPLACEMENT!C (ASMREC DEST drec)
; Computes the DISPLACEMENT!C in *ASMRECS*!C from ASMREC, an assembly
; record, to DEST, a label
  ; if DEST is the INST element of some assembly record, drec,
  ; in *ASMRECS*!C,
  ((SETQ drec (ASSOC DEST *ASMRECS*!C))
    ; compute and return the DISPLACEMENT!C from the position just
    ; after ASMREC to the destination assembly record
    (- (PSN-OF!C drec) (PSN-OF!C ASMREC) (LEN-OF!C ASMREC)) )
  ; INTERNAL-ERR @ DISPLACEMENT!C: Invalid destination DEST
  (INTERNAL-ERR!C 3090 1 ASMREC DEST) )

(DEFUN PSN-ASMRECS!C (ASMRECS)
; "Positions" ASMRECS, a list of assembly records, by recomputing and
; resetting all PSN components in accordance with the current LEN
; components
  (LET ((psn 1) )
	; = initial position
    ; for each assembly record, asmrec, in ASMRECS
    (MAPC '(LAMBDA (asmrec)
		   ; modify the PSN of asmrec to psn
		   (mu-PSN!C asmrec psn)
		   ; adjust psn for the LEN of asmrec
		   (INCQ psn (LEN-OF!C asmrec)) )
	  ASMRECS) ) )

; Section 7.5. Position Finalization

(DEFUN FINALIZE-PSNS!C (ASMRECS)
; Finalizes the positions of ASMRECS, a list of assembly records,
; by one last "positioning", coupled with an adjustment of all
; CALL instructions to insure that they have ODD return addresses
  (LET ((psn 1) )
	; = initial position
    ; for each assembly record, asmrec, in ASMRECS
    (MAPC '(LAMBDA (asmrec)
		   ; modify asmrec's PSN to psn
		   (mu-PSN!C asmrec psn)
		   ; if asmrec is a CALL, and its return address will
		   ; be EVEN, then
		   ( ((AND
			 (EQ (CAR (INST-OF!C asmrec)) 'CALL)
			 (EVENP (+ psn (LEN-OF!C asmrec))) )
		       ; if asmrec's code starts with 144 (8086 NOP),
		       ((EQL (CAR (OPS-OF!C asmrec)) 144)
			 ; delete the NOP from asmrec's code to make
			 ; the return address ODD
			 (mu-OPS!C asmrec (CDR (OPS-OF!C asmrec)))
			 ; and adjust asmrec's LEN accordingly
			 (mu-LEN!C asmrec
				   (LENGTH (OPS-OF!C asmrec))) )
		       ; INTERNAL-ERR @ FINALIZE-PSNS!C: Invalid CALL
		       (INTERNAL-ERR!C 3120 1 asmrec) ) )
		   ; adjust psn for the LEN of asmrec
		   (INCQ psn (LEN-OF!C asmrec)) )
	  ASMRECS) ) )

; Section 7.6. Symbol Location Freezing

(DEFUN FREEZE-SYMBOLS!C (SYMS)
; "Freezes" the locations of the symbols in SYMS by setting the
; muLISP system variable USENAM at offset 24 in the data segment to
; point just above the symbol in SYMS with the highest location.
  ; if SYMS is NIL, do nothing
  ((NULL SYMS) )
  ; otherwise, set maxloc to the largest symbol LOCATION over SYMS
  (LET ((maxloc (APPLY 'MAX (MAPCAR 'LOCATION SYMS))) )
    ; set USENAM to the larger of its current value or maxloc+2
    (DSMEMORY <USENAM@DS>!C
	      (MAX (DSMEMORY <USENAM@DS>!C NIL T) (+ 2 maxloc))
	      T) ) )

; Section 7.7. Code Collection

(DEFUN COLLECT-CODE!C (ASMRECS asmrec)
; Collects and returns the machine code of ASMRECS, a list of
; assembly records, resolving offsets for any CALL, JMP, or SJMP
; instructions encountered in ASMRECS
  (LET ((fncode (CONS)) )
	; = local to collect the code
    ; for each assembly record, asmrec, in ASMRECS:
    (MAPC '(LAMBDA (asmrec)
		   ; if asmrec is a CALL, JMP, or SJMP,
		   ( ((MEMBER (CAR (INST-OF!C asmrec))
			      '(JMP CALL SJMP))
		       ; resolve its offset
		       (RESOLVE-OFFSET!C asmrec) ) )
		   ; collect a copy of the code of asmrec
		   (LCONC fncode (COPY-LIST (OPS-OF!C asmrec))) )
	  ASMRECS)
    ; return actual code collected
    (CAR fncode) ) )

(DEFUN RESOLVE-OFFSET!C (ASMREC ops dest disp)
; Resolves the offset from ASMREC, a CALL, JMP, or SJMP assembly
; record, to its destination.
  ; get the code of ASMREC, and set dest to the first tail of the
  ; code which begins with a symbol, if any
  (SETQ ops (OPS-OF!C ASMREC))
  (SETQ dest (MEMBER-IF 'SYMBOLP ops))
  ; if dest is NIL, or begins with TGT, exit
  ; (NOTE: TGT destinations are handled during loading in LOAD-CODE)
  ((OR (NULL dest)
       (EQ (CAR dest) 'TGT) ) )
  ; if the CAR of dest is a label,
  ((MEMBER (CAR dest) *FNLBLS*!C)
    ; compute the DISPLACEMENT!C from ASMREC to the label
    (SETQ disp (DISPLACEMENT!C ASMREC (CAR dest)))
    ; if dest has ONE element, then
    ((NULL (CDR dest))
      ; if the DISPLACEMENT!C is an 8-bit integer,
      ((IS-INT8!C disp)
	; install it into the code
	(RPLACA dest (TWOS-COMP-BYTE!C disp)) )
      ; INTERNAL-ERR @ RESOLVE-OFFSET!C: Offset disp will not fit dest
      (INTERNAL-ERR!C 3130 1 ASMREC ops disp dest) )
    ; if dest has TWO elements, then
    ((NULL (CDDR dest))
      ; if the DISPLACEMENT!C is a 16-bit integer,
      ((IS-INT16!C disp)
	; install it into the code
	(SETQ disp (LO/HI-BYTES!C (TWOS-COMP-DISP!C disp)))
	(RPLACA dest (CAR disp))
	(RPLACA (CDR dest) (CADR disp)) )
      ; INTERNAL-ERR @ RESOLVE-OFFSET!C: Invalid offset disp
      (INTERNAL-ERR!C 3130 3 ASMREC ops disp dest) )
    ; INTERNAL-ERR @ RESOLVE-OFFSET!C: Invalid destination dest
    (INTERNAL-ERR!C 3130 4 ASMREC ops disp dest) )
  ; INTERNAL-ERR @ RESOLVE-OFFSET!C: Invalid destination dest
  (INTERNAL-ERR!C 3130 5 ASMREC ops disp dest) )


; Section 8. LOADING PROCESS * * * * * * * * * * * * * * * * * * * * * * *

;    This section develops the process by which the list of machine
; code generated by the assembly process described in Section 7
; is loaded into the muLISP code segment as an executable block of
; machine code, and installed as the definition of the function
; indicated by the CAR of the machine code list.

(DEFUN LOAD-FN!C (FNCOD)
; Loads FNCOD, a list of the form (fn-name . machine code), into
; the muLISP code segment, and defines fn-name to enter the loaded
; machine code when called.
  ; attempt to allocate enough space in the muLISP code segment to
  ; contain FNCOD, and set entry to its code segment offset
  (LET ((entry (ALLOCATE (+ (LENGTH FNCOD) 8))) )
    ; if entry is a number, the space was actually allocated, so:
    ((NUMBERP entry)
      ; increment entry to an odd address,
      (INCQ entry)
      ; load the machine code in FNCOD at entry,
      (LOAD-CODE!C (CDR FNCOD) entry)
      ; set the function definition of the fn-name of FNCOD to entry,
      (PUTD (CAR FNCOD) entry)
      ; and return information about the load
      (LIST (CAR FNCOD) (LENGTH (CDR FNCOD)) entry) )
    ; otherwise, compilation error:
    (COMPILE-ERR!C (LENGTH FNCOD) "Insufficient Code Space") ) )

(DEFUN LOAD-CODE!C (COD PSN item nxt)
; Loads COD, a list of machine code items, starting at PSN, an offset
; in the muLISP code segment.
  (LOOP
    ; if COD is NIL, exit
    ((NULL COD))
    ; otherwise, get the next code item from COD,
    (SETQ item (POP COD))
    ; and load it appropriately, depending on its form:
      ; if number,
    ( ((NUMBERP item)
	; store it as a byte at PSN in the code segment,
	(CSMEMORY PSN item)
	; and advance PSN by 1
	(INCQ PSN 1) )
      ; if TGT, then
      ((EQ item 'TGT)
	; if followed by a number, nxt,
	((NUMBERP (SETQ nxt (POP COD)))
	  ; store the DISPLACEMENT!C to nxt as a word at PSN,
	  (CSMEMORY PSN (TWOS-COMP-DISP!C (- nxt (+ PSN 2))) T)
	  ; and advance PSN by 2
	  (INCQ PSN 2) )
	; INTERNAL-ERR @ LOAD-CODE!C: TGT followed by nxt
	(INTERNAL-ERR!C 4010 1 COD PSN item nxt) )
      ; INTERNAL-ERR @ LOAD-CODE!C: Invalid load item item
      (INTERNAL-ERR!C 4010 2 COD PSN item nxt) ) ) )
