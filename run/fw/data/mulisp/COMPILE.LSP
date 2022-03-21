; File: COMPILE.LSP  (c)	05/20/87	Soft Warehouse, Inc.


;	      The muLISP Incremental Native Code Compiler

(SETQ *COMPILE-PATH* (FIND "COMPILE.LSP" (INPUT-FILES) 'FINDSTRING)
      *COMPILE-PATH* (SUBSTRING *COMPILE-PATH* 0 (- (LENGTH *COMPILE-PATH*) 5)))

(DEFUN COMPILE-FILE (C-FILES L-FILES
; If <c-files> and <l-files> are file names OR lists of file names,
; (COMPILE-FILE c-files l-files) loads <c-files>, loads <l-files>,
; loads the muLISP compiler, compiles the functions defined
; in <c-files>, and deletes the compiler.
    *CONDENSE* )
  (IF (LISTP C-FILES) NIL (SETQ C-FILES (LIST C-FILES)))
  (IF (LISTP L-FILES) NIL (SETQ L-FILES (LIST L-FILES)))
  (SETQ *CONDENSE*)
  ((NOTEVERY '(LAMBDA (FILE) (LOAD (PACK* FILE ".LSP")))
	     (APPEND C-FILES L-FILES))		;Load source files
    (WRITE-LINE "Source file not found")
    NIL )
  (SETQ *CONDENSE*)
  (LOAD (PACK* *COMPILE-PATH* 0))	;Load compiler
  (LOOP 				;Compile <files> loop
    ((NULL C-FILES)
      (WRITE-LINE "Deleting compiler")
      (DELETE-COMPILER) 		;Delete compiler
      (REMD 'COMPILE-FILE)
      (RECLAIM) )
    (OPEN-INPUT-FILE (PACK* (POP C-FILES) ".LSP"))
    (WRITE-STRING "Compiling ")
    (WRITE-LINE (INPUT-FILE))
    (UNWIND-PROTECT
      (LOOP				;Compile file
	((EQ (SETQ EXPN (READ NIL T 'STOP)) 'STOP))
	( ((EQ (CAR EXPN) 'DEFUN)
	    ((EQ (GETD (CADR EXPN) T) 'LAMBDA)
	      (PRINC (CADR EXPN))
	      (SET-CURSOR (ROW) 25)
	      (PRINT (CDR (COMPILE (CADR EXPN)))) ) ) ) )
      (CLOSE-INPUT-FILE) ) ) )

(TERPRI)
(WRITE-STRING "Use as a File compiler or Incremental compiler (F/I): ")
(CLEAR-INPUT T)
NIL NIL NIL

(IF (EQ (PRINT (STRING-UPCASE (ASCII (READ-BYTE T)))) 'I)
    (LOAD (PACK* *COMPILE-PATH* 0 ".LSP"))
    (RECLAIM) )
