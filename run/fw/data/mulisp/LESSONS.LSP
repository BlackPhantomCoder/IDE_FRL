; File:  LESSONS.LSP  (c)	12/26/86	Soft Warehouse, Inc.


;		The muLISP Tutorial System Lesson Driver

(SETQ *LESSON-PATH* '||)

(DEFUN LESSONS (
    NUM LEFT-COLUMN DEFAULT-LESSON )
  (SETQ DEFAULT-LESSON 1)
  (LOOP
    (SETQ *HIGH-INTENSITY* T
	  *AUTO-NEWLINE* T)
    (FOREGROUND-COLOR 7)
    (BACKGROUND-COLOR 0)
    (CLOSE-INPUT-FILE)
    (CLOSE-OUTPUT-FILE)
    (MOVD 'APP# 'APPEND)
    (MOVD 'REV# 'REVERSE)
    (MOVD 'MBR# 'MEMBER)
    (CLEAR-SCREEN)
    (CENTER "m u L I S P - 8 7")
    (TERPRI 2)
    (CENTER "T U T O R I A L   S Y S T E M")
    (SETQ *HIGH-INTENSITY*)
    (SETQ LEFT-COLUMN (MAX 0 (- (TRUNCATE (CADDDR (MAKE-WINDOW)) 2) 22)))
    (SET-CURSOR 5 LEFT-COLUMN)
    (PRINC "Lesson		    Subject")
    (DISPLAY-MENU SUBJECT-LIST 7 LEFT-COLUMN)
    (TERPRI 2)
    (PRINC "When this program asks you to select ")
    (PRINC "from a list of options and you are not ")
    (PRINC "sure which one to choose, press the ")
    (PRINC "SPACE BAR for the best default option.")
    (TERPRI 2)
    (PRINC "Enter desired lesson number or press \"Q\" ")
    (PRINC "to quit: ")
    (SETQ DEFAULT-LESSON (QUERY (LIST* DEFAULT-LESSON 'Q '(1 2 3 4 5 6))))
    ((EQ DEFAULT-LESSON 'Q)
	(SYSTEM) )
    (CATCH NIL (READ-LESSON (PACK* 'MULISP DEFAULT-LESSON)))
    (SETQ DEFAULT-LESSON (IF
      (EQ DEFAULT-LESSON (LENGTH SUBJECT-LIST))
      1
      (ADD1 DEFAULT-LESSON) )) ) )

(SETQ SUBJECT-LIST '(
  "Data objects and primitive functions"
  "Defining functions using recursion"
  "Symbols, numbers, and conses"
  "List processing & iterative functions"
  "Numerical programming techniques"
  "Implementing turtle graphics routines"
))

(DEFUN READ-LESSON (FILE-NAME
    EXPN PTRLST BRKFLG)
  ((EQ (OPEN-INPUT-FILE (PACK* *LESSON-PATH* FILE-NAME ".LES")))
    (TERPRI)
    (PRINC "Enter the path for the drive and ")
    (PRINC "directory that contains the LES ")
    (PRINC "files (e.g. C:\\LISPLES): ")
    (SETQ *LESSON-PATH* (STRING-UPCASE (STRING-TRIM '" " (READ-LINE))))
    ((EQ *LESSON-PATH* '||))
    ((EQ *LESSON-PATH* 'Q))
    ( ((MEMBER (CHAR *LESSON-PATH* (SUB1 (LENGTH *LESSON-PATH*))) '(\\ \:)))
      (SETQ *LESSON-PATH* (PACK* *LESSON-PATH* '\\)) )
    (READ-LESSON FILE-NAME) )
  (LOOP
    ( ((EQ (PEEK-CHAR) '$)
	(READ-CHAR)
	(EVAL (READ)) ) )
    ((EQ (READ-LINE) 'CLRSCRN)) )
  (CLEAR-SCREEN)
  (PUSH (FILE-READ-POSITION) PTRLST)
  (LOOP
    ((NOT (LISTEN)))
    ( ((EQ (PEEK-CHAR) '$)
	(SETQ *INPUT-ECHO* T)
	(PRINC (READ-CHAR))
	(SETQ EXPN (READ)
	      *INPUT-ECHO*)
	((EQ (CAR EXPN) 'DEFUN)
	  (EVAL EXPN) )
	(TERPRI)
	(WRITE (EVAL EXPN)) )
      ((EQ (SETQ EXPN (READ-LINE)) 'CONTINUE)
	( ((EQ (CDR PTRLST))
	    (LBREAK '("Continue lesson" "Abort lesson"))
	    (PUSH (FILE-READ-POSITION) PTRLST) )
	  ((EQ BRKFLG)
	    ((LBREAK '("Continue lesson" "Abort lesson" "Previous screen"))
	      (PUSH (FILE-READ-POSITION) PTRLST) )
	    (POP PTRLST)
	    (FILE-READ-POSITION (CAR PTRLST)) )
	  ((LBREAK '("Continue lesson" "Break lesson" "Abort lesson"
		"Previous screen"))
	    (PUSH (FILE-READ-POSITION) PTRLST) )
	  (POP PTRLST)
	  (FILE-READ-POSITION (CAR PTRLST)) )
	(CLEAR-SCREEN) )
      ((EQ EXPN 'BREAK)
	(SETQ BRKFLG T)
	((LBREAK '("Break lesson" "Continue lesson" "Abort lesson"
		"Previous screen")) )
	(POP PTRLST)
	(FILE-READ-POSITION (CAR PTRLST))
	(CLEAR-SCREEN) )
      ((EQ EXPN 'CLRSCRN)
	(PUSH (FILE-READ-POSITION) PTRLST)
	(CLEAR-SCREEN) )
      (WRITE-LINE EXPN) ) ) )

(DEFUN LBREAK (LST
    CHAR ROW)
  (SETQ ROW (ROW)
	CHAR (OPTIONS LST))
  (WRITE-BYTE 13)
  (SPACES (SUB1 (FOURTH (MAKE-WINDOW))))
  (SET-CURSOR ROW 0)
  ((EQ CHAR 'A)
    (THROW) )
  ((EQ CHAR 'C))
  ((EQ CHAR 'P) NIL)
  ((EQ CHAR 'B)
    (CATCH NIL (DRIVER))
    (INPUT-FILE (PACK* *LESSON-PATH* FILE-NAME ".LES")) )
  ((EQ CHAR 'S)
    (SYSTEM) ) )

(DEFUN OPTIONS (LST1
    LST2 *PRINT-DOWNCASE* )
  (SET-CURSOR (SUB1 (THIRD (MAKE-WINDOW))) 0)
  (LOOP
    (PUSH (CAR (UNPACK (PRINC (POP LST1)))) LST2)
    ((EQ LST1))
    (WRITE-STRING ", ") )
  (WRITE-STRING " (")
  (SETQ LST2 (REV# LST2)
	LST1 LST2)
  (LOOP
    (PRINC (POP LST1))
    ((EQ LST1))
    (PRINC '/) )
  (WRITE-STRING ")? ")
  (QUERY LST2) )

(DEFUN QUERY (LST
    CHAR)
  (CLEAR-INPUT T)
  (LOOP
    (SETQ CHAR (CHAR-UPCASE (ASCII (READ-BYTE T))))
    (IF (<= 48 (ASCII CHAR) 57)
	(SETQ CHAR (- (ASCII CHAR) 48)))
    ((MBR# CHAR LST)
      (PRINC CHAR)
      CHAR )
    ((EQ CHAR '" ")
      (PRINC (CAR LST))
      (CAR LST) )
    ( ((EQ CHAR (ASCII 10)))
      ((EQ BELL))
      (WRITE-BYTE 7) ) ) )

(DEFUN DISPLAY-MENU (OPTION-LIST ROW COLUMN
    NUM )
  (SETQ NUM 0)
  (IF (> (CADDDR (MAKE-WINDOW)) 50)
	(INCQ COLUMN 3) )
  (LOOP
    ((EQ OPTION-LIST))
    (SET-CURSOR (+ ROW NUM) COLUMN)
    (PRINC (INCQ NUM))
    (SPACES 1)
    (IF (> (CADDDR (MAKE-WINDOW)) 50) (SPACES 3))
    (WRITE-LINE (POP OPTION-LIST)) ) )

(DEFUN CENTER (MSG)
  (SET-CURSOR (ROW) (TRUNCATE (- (CADDDR (MAKE-WINDOW)) (LENGTH MSG)) 2))
  (WRITE-STRING MSG) )

(MOVD 'REVERSE 'REV#)
(MOVD 'MEMBER 'MBR#)
(MOVD 'APPEND 'APP#)

(LESSONS)
