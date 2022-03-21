; File: ADDRESS.LSP  (C)	05/29/87	Soft Warehouse, Inc.


;	    * * *   The ADDRESS Data Entry Program   * * *

(SETQ *INIT-WINDOW* "Address")
(SETQ *WINDOW-TYPES* (SORT (ADJOIN "Address" *WINDOW-TYPES*) 'STRING<))
(SETQ DRIVER 'WINDOWS)

(DEFUN "Address" (COMMAND
	*FILE-NAME* *RECORD-LIST* *CURRENT-RECORD* *TEXT-DIRTY*
; the top-level command processor for the ADDRESS data entry program.
; *FILE-NAME* is the name of the current data record file.
; *RECORD-LIST* is the list of records making up the data file.
; *CURRENT-RECORD* is the index in *RECORD-LIST* of the displayed record.
; *TEXT-DIRTY* is nonNIL iff the *RECORD-LIST* has been edited in any way.
    *PROMPT-LIST* *FIELDS* *PROMPT-LENGTH* *DISPLAYED-RECORD*
    *DEFAULT-TYPE* *FIND-NAME* *INPUT-FILE* *OUTPUT-FILE*)
  (SETQ *DEFAULT-TYPE* 'DAT
	*FIND-NAME* "")
  ((EQ COMMAND 'CREATE-WINDOW)
    (SETQ *COMMAND-LINE* (STRING-TRIM " " *COMMAND-LINE*))
    ( ((EQ *COMMAND-LINE* ""))
      ((NULL *COMMAND-LINE*)
	(SETQ *COMMAND-LINE* "") )
      ((OPEN-INPUT-FILE (PACK* *COMMAND-LINE* '\. *DEFAULT-TYPE*))
	(SETQ *COMMAND-LINE* (INPUT-FILE)
	      *RECORD-LIST* (READ-DATA-FILE)) )
      (SETQ *COMMAND-LINE* "")
      (ERROR-BEEP) )
    (LIST "Address" *COMMAND-LINE* *RECORD-LIST* 0 NIL) )
  ((EQ COMMAND 'CLOSE-WINDOW)
    (ABANDON-RECORDS) )
  (SETQ *PROMPT-LIST*
		'("Name" "Institution" "Address" "City" "State" "Zip code")
	*FIELDS* (LENGTH *PROMPT-LIST*)
	*PROMPT-LENGTH* (REDUCE '(LAMBDA (NUM PROMPT)
				   (MAX NUM (LENGTH PROMPT)))
				*PROMPT-LIST* 0) )
  ((EQ COMMAND 'UPDATE-WINDOW)
    (UPDATE-ADDRESS) )
  (ADDRESS-STATUS)
  (SETQ *DISPLAYED-RECORD* *CURRENT-RECORD*)
  (UNWIND-PROTECT
    (LOOP
      (DISPLAY-RECORD)
      (EXECUTE-OPTION 'COMMAND *ADDRESS-OPTIONS*) )
    (UPDATE-STATE
	'(*FILE-NAME* *RECORD-LIST* *CURRENT-RECORD* *TEXT-DIRTY*)) ) )

(SETQ *ADDRESS-OPTIONS* '(
; is the ADDRESS program option tree.
	("Add" . ADD-RECORD)
	("Back" . BACK-RECORD)
	("Delete" . DELETE-RECORD)
	("Edit" . EDIT-RECORD)
	("First" . FIRST-RECORD)
	("Last" . LAST-RECORD)
	("Mode" . SET-INSERT)
	("Next" . NEXT-RECORD)
	("Options" OPTIONS (
		("Color" . SET-COLOR)
		("Display" . SET-DISPLAY)
		("Execute" . GO-DOS)
		("Mute" . SET-MUTE) ))
	("Print" . PRINT-DATA-FILE)
	("Quit" . QUIT-PROGRAM)
	("Search" . SEARCH-RECORD)
	("Transfer" TRANSFER (
		("Save" . SAVE-DATA-FILE)
		("Load" . LOAD-DATA-FILE)
		("Merge" . MERGE-DATA-FILE)
		("Clear" . CLEAR-RECORDS)
		("Delete" . DELETE-DATA-FILE) ))
	("Window" . CHANGE-WINDOW) ))

(DEFUN ADD-RECORD (
; allows the user to add new records.
    RECORD)
  (SETQ *OPTIONS*)
  (SHOW-OPTIONS 'COMMAND *ADDRESS-OPTIONS*)
  (SHOW-PROMPT "Enter address, press F10 for another, ESC when finished")
  (LOOP
    (SETQ *CURRENT-RECORD* (LENGTH *RECORD-LIST*))
    (DISPLAY-RECORD)
    (SETQ RECORD (GET-RECORD (MAKE-LIST *FIELDS* "")))
    ((NOT RECORD) NIL)
    (SETQ *RECORD-LIST* (MERGE *RECORD-LIST* (LIST RECORD) 'RECORD<)
	  *CURRENT-RECORD* (POSITION RECORD *RECORD-LIST*)
	  *TEXT-DIRTY* T)
    ((EQ *LINE-TERMINATOR* 27)) ) )

(DEFUN EDIT-RECORD (
; allows the user to edit a single record.
    RECORD)
  (SETQ *OPTIONS*)
  (SHOW-OPTIONS 'COMMAND *ADDRESS-OPTIONS*)
  (SHOW-PROMPT "Edit address, press ESC when finished")
  (SETQ RECORD (IF (= *CURRENT-RECORD* (LENGTH *RECORD-LIST*))
		   (MAKE-LIST *FIELDS* "")
		   (NTH *CURRENT-RECORD* *RECORD-LIST*)))
  ((NOT (SETQ RECORD (GET-RECORD (COPY-LIST RECORD)))) NIL)
  ((EQUAL RECORD (NTH *CURRENT-RECORD* *RECORD-LIST*)))
  (SETQ *RECORD-LIST*
		(MERGE (DELETE-NTH *RECORD-LIST* *CURRENT-RECORD*)
		       (LIST RECORD)
		       'RECORD<)
	*CURRENT-RECORD* (POSITION RECORD *RECORD-LIST*)
	*TEXT-DIRTY* T) )

(DEFUN GET-RECORD (RECORD
; allows the user to edit a record which it returns.
    ROW COL COLS *LOCAL-DEMONS* *LINE-POINT* *LINE-COLUMN*)
  (SETQ ROW 0
	COL (+ *PROMPT-LENGTH* 2)
	COLS (- (WINDOW-COLS) COL 1)
	*DISPLAYED-RECORD* NIL
	*LOCAL-DEMONS* '(
		(5 . UP-FIELD)
		(13 . DOWN-FIELD)
		(24 . DOWN-FIELD)
		(3 . TOP-FIELD)
		(18 . BOTTOM-FIELD)) )
  (LOOP
    (CURRENT-WINDOW)
    (SET-CURSOR ROW COL)
    (CURSOR-ON)
    (RPLACA (NTHCDR ROW RECORD)
	    (STRING-TRIM " "
	       (LINE-EDIT (NTH ROW RECORD) *LINE-POINT* *LINE-COLUMN* COLS)))
    (CURSOR-OFF)
    ((OR (EQ *LINE-TERMINATOR* 27)
	 (EQ *LINE-TERMINATOR* -68))
      ((EQ (CAR RECORD) "") NIL)
      RECORD )
    (DEMON-BYTE *LINE-TERMINATOR*) ) )

(DEFUN DELETE-RECORD ()
; allows the user to delete a record.
  ((= *CURRENT-RECORD* (LENGTH *RECORD-LIST*)))
  ((PROMPT-YN "Delete this record (Y/N)? ")
    (SETQ *RECORD-LIST* (DELETE-NTH *RECORD-LIST* *CURRENT-RECORD*)
	  *DISPLAYED-RECORD* NIL
	  *TEXT-DIRTY* T ) ) )


(DEFUN UP-FIELD ()
; moves the cursor up a row (field).
  ((ZEROP ROW))
  (SETQ ROW (SUB1 ROW)
	*LINE-POINT* NIL
	*LINE-COLUMN*) )

(DEFUN DOWN-FIELD ()
; moves the cursor down a row (field).
  ((EQ (ADD1 ROW) *FIELDS*))
  (SETQ ROW (ADD1 ROW)
	*LINE-POINT* NIL
	*LINE-COLUMN*) )

(DEFUN TOP-FIELD ()
; moves the cursor to the top row (field).
  ((EQ ROW (SUB1 *FIELDS*)))
  (SETQ ROW (SUB1 *FIELDS*)
	*LINE-POINT* NIL
	*LINE-COLUMN*) )

(DEFUN BOTTOM-FIELD ()
; moves the cursor to the bottom row (field).
  ((ZEROP ROW))
  (SETQ ROW 0
	*LINE-POINT* NIL
	*LINE-COLUMN*) )

;		* * *	Record Movement Functions   * * *

(DEFUN BACK-RECORD ()
; changes the display to the previous record.
  ((ZEROP *CURRENT-RECORD*))
  (DECQ *CURRENT-RECORD*) )

(DEFUN NEXT-RECORD ()
; changes the display to the next record.
  ((EQ *CURRENT-RECORD* (LENGTH *RECORD-LIST*)))
  (INCQ *CURRENT-RECORD*) )

(DEFUN FIRST-RECORD ()
; changes the display to the first record.
  (SETQ *CURRENT-RECORD* 0) )

(DEFUN LAST-RECORD ()
; changes the display to the last record.
  ((NULL *RECORD-LIST*))
  (SETQ *CURRENT-RECORD* (SUB1 (LENGTH *RECORD-LIST*))) )

(DEFUN SEARCH-RECORD (
; allows the user to search for particular record.
    NAME INDEX)
  (SETQ NAME *FIND-NAME*)
  (LOOP
    (SETQ NAME (PROMPT-INPUT "Enter name to find" "Name: " NAME))
    ((EQ *LINE-TERMINATOR* 27) NIL)
    ((EQ NAME "") NIL)
    (SETQ INDEX (SUB1 (LENGTH NAME)))
    ((SETQ INDEX (POSITION-IF '(LAMBDA (RECORD)
			(STRING= NAME (SUBSTRING (CAR RECORD) 0 INDEX) T))
		      *RECORD-LIST*))
      (SETQ *FIND-NAME* NAME
	    *CURRENT-RECORD* INDEX) )
    (ERROR-BEEP) ) )

;		* * *	File I/O Operations   * * *

(DEFUN SAVE-DATA-FILE (
; saves the records as a data file named by the user.
    FILE-NAME)
  (SETQ FILE-NAME *FILE-NAME*)
  (LOOP
    (SETQ FILE-NAME (PROMPT-TEXT-FILE "TRANSFER SAVE file: " FILE-NAME))
    ((EQ FILE-NAME "") NIL)
    ((AND (OR (EQ FILE-NAME *FILE-NAME*)
	      (NOT (PROBE-FILE FILE-NAME))
	      (PROMPT-YN "Overwrite existing file (Y/N)? ") )
	  (OPEN-OUTPUT-FILE FILE-NAME))
      (SETQ *FILE-NAME* (OUTPUT-FILE)
	    *OUTPUT-FILE*)
      (ADDRESS-STATUS)
      (SHOW-PROMPT "Saving file...")
      (SETQ *OUTPUT-FILE* T)
      ((CATCH "Disk Full"
	  (MAPC 'WRITE-RECORD *RECORD-LIST*)
	  (WRITE-BYTE 26) )
	(SETQ *TEXT-DIRTY*)
	(CLOSE-OUTPUT-FILE) )
      (FILE-WRITE-POSITION 0)
      (CLOSE-OUTPUT-FILE)
      (SHOW-PROMPT "Disk full; delete some files and retry")
      (ERROR-BEEP) ) ) )

(DEFUN WRITE-RECORD (RECORD)
; writes a single record to a data file.
  (MAPC 'WRITE-LINE RECORD)
  (TERPRI) )


(DEFUN CLEAR-RECORDS ()
; if the user approves, abandons the current records.
  ((ABANDON-RECORDS)
    (SETQ *FILE-NAME* ""
	  *RECORD-LIST* NIL
	  *CURRENT-RECORD* 0
	  *TEXT-DIRTY* NIL)
    (UPDATE-ADDRESS)
    (ADDRESS-STATUS)
    T ) )

(DEFUN ABANDON-RECORDS ()
; returns T if the user approves abandoning the current records.
  ((NOT *TEXT-DIRTY*))
  ((EQ *FILE-NAME* "")
    (PROMPT-YN "Abandon edited records (Y/N)? ") )
  (PROMPT-YN (PACK* "Abandon edited " *FILE-NAME* " (Y/N)? ")) )


(DEFUN DELETE-DATA-FILE (
; deletes the file named by the user.
    FILE-NAME NAME)
  (SETQ FILE-NAME "")
  (LOOP
    (SETQ FILE-NAME (PROMPT-TEXT-FILE "TRANSFER DELETE file: " FILE-NAME))
    ((EQ FILE-NAME "") NIL)
    (SETQ NAME (PACK* FILE-NAME ".DAT"))
    ((AND (NOT (OR (INPUT-FILE-P NAME) (OUTPUT-FILE-P NAME)))
	  (DELETE-FILE NAME)))
    (ERROR-BEEP) ) )


(DEFUN LOAD-DATA-FILE (
; abandons the current records and loads the data file named by the user.
    FILE-NAME)
  (SETQ FILE-NAME *FILE-NAME*)
  (LOOP
    (SETQ FILE-NAME (PROMPT-TEXT-FILE "TRANSFER LOAD file: " FILE-NAME))
    ((EQ FILE-NAME "") NIL)
    ((AND (PROBE-FILE FILE-NAME) (CLEAR-RECORDS) (OPEN-INPUT-FILE FILE-NAME))
      (SETQ *FILE-NAME* (INPUT-FILE))
      (ADDRESS-STATUS)
      (SETQ *RECORD-LIST* (READ-DATA-FILE)
	    *DISPLAYED-RECORD*)
      T )
    (ERROR-BEEP) ) )

(DEFUN MERGE-DATA-FILE (
; merges the data file named by the user with the current records.
    FILE-NAME RECORD)
  (SETQ FILE-NAME "")
  (LOOP
    (SETQ FILE-NAME (PROMPT-TEXT-FILE "TRANSFER MERGE file: " FILE-NAME))
    ((EQ FILE-NAME "") NIL)
    ((OPEN-INPUT-FILE FILE-NAME)
      (SETQ RECORD (NTH *CURRENT-RECORD* *RECORD-LIST*))
      (SETQ *RECORD-LIST* (MERGE *RECORD-LIST* (READ-DATA-FILE) 'RECORD<)
	    *CURRENT-RECORD* (OR (POSITION RECORD *RECORD-LIST*)
				 (LENGTH *RECORD-LIST*))
	    *TEXT-DIRTY* T) )
    (ERROR-BEEP) ) )

(DEFUN READ-DATA-FILE (
; returns a sorted list of the records read from an open data file.
    RECORD-LIST *TAB-EXPAND* *INPUT-ECHO*)
  (SHOW-PROMPT "Loading file...")
  (SETQ *TAB-EXPAND* T)
  (LOOP
    ((NOT (SETQ RECORD (READ-RECORD))))
    (PUSH RECORD RECORD-LIST) )
  (CLOSE-INPUT-FILE)
  (SORT (NREVERSE RECORD-LIST) 'RECORD<) )

(DEFUN READ-RECORD (
; reads a single record form an open data file.
    NUM RECORD)
  (SETQ NUM *FIELDS*)
  (LOOP
    ((NOT (LISTEN)) NIL)
    ((ZEROP NUM)
      (READ-LINE)
      (NREVERSE RECORD) )
    (PUSH (STRING-TRIM " " (READ-LINE)) RECORD)
    (DECQ NUM) ) )

(DEFUN RECORD< (RECORD1 RECORD2)
; returns T if RECORD1 should be ordered before RECORD2.
  (STRING< (CAR RECORD1) (CAR RECORD2) T) )

;		* * *	Printer Output Operations   * * *

(DEFUN PRINT-DATA-FILE (
; print the records in the data file specified by the user.
    FILE-NAME)
  (SETQ FILE-NAME *FILE-NAME*)
  (LOOP
    (SETQ FILE-NAME (PROMPT-TEXT-FILE "PRINT RECORDS file: " FILE-NAME))
    ((EQ FILE-NAME "") NIL)
    ((OPEN-INPUT-FILE FILE-NAME)
      (OPEN-OUTPUT-FILE *PRINTER-DEVICE*)
      (WRITE-STRING *INIT-PRINTER*)
      (UNWIND-PROTECT
	(PRINT-DATA-FILE-AUX FILE-NAME)
	(CLOSE-INPUT-FILE FILE-NAME)
	(WRITE-STRING *STOP-PRINTER*)
	(CLOSE-OUTPUT-FILE *PRINTER-DEVICE*) ) )
    (ERROR-BEEP) ) )

(DEFUN PRINT-DATA-FILE-AUX (FILE-NAME
; print the records in the open data file unless interrupted by the user.
    FILE-DATE PAGE-NUMBER PAGE-LINE COLS *TAB-EXPAND*)
  (SETQ FILE-DATE (DATE-STRING (FILE-DATE FILE-NAME))
	FILE-NAME (SUBSTRING (INPUT-FILE) 2)
	PAGE-NUMBER 1
	PAGE-LINE *INITIAL-LINE*
	COLS (- *PAGE-COLUMNS* *LEFT-MARGIN* (OR *RIGHT-MARGIN* 0))
	*TAB-EXPAND* T)
  (LOOP
    (SHOW-PROMPT "Printing file...")
    (LOOP
      ((LISTEN T)
	(CLEAR-INPUT T)
	((PROMPT-YN "Quit printing file (Y/N)? ")
	  (RETURN) ) )
      ((NOT (SETQ RECORD (READ-RECORD)))
	(PRINT-FOOTER)
	(RETURN T) )
      ( ((EQ PAGE-LINE *INITIAL-LINE*)
	  (SETQ PAGE-LINE *TOP-MARGIN*)
	  (WRITE-BYTE 13)
	  (TERPRI (- *TOP-MARGIN* *INITIAL-LINE*)) ) )
      (INCQ PAGE-LINE (PRINT-RECORD RECORD))
      (IF (>= PAGE-LINE (- *PAGE-LINES* *BOTTOM-MARGIN* 4))
	  (PRINT-FOOTER) ) ) ) )

(DEFUN PRINT-RECORD (RECORD
; print a record to the printer; return the number of rows printed.
    ROW)
  (SETQ ROW 2)
  (WRITE-BYTE 32 (- *LEFT-MARGIN* *INITIAL-COLUMN*))
  (WRITE-LINE (FIRST RECORD))		      ;PRINT NAME
  ( ((EQ (SECOND RECORD) ""))
    (WRITE-BYTE 32 (- *LEFT-MARGIN* *INITIAL-COLUMN*))
    (WRITE-STRING (SECOND RECORD)) )		;PRINT INSTITUTION
  (IF (FRESH-LINE) (INCQ ROW) )
  ( ((EQ (THIRD RECORD) ""))
    (WRITE-BYTE 32 (- *LEFT-MARGIN* *INITIAL-COLUMN*))
    (WRITE-STRING (THIRD RECORD)) )		;PRINT ADDRESS
  (IF (FRESH-LINE) (INCQ ROW) )
  (WRITE-BYTE 32 (- *LEFT-MARGIN* *INITIAL-COLUMN*))
  (WRITE-STRING (PACK-CSZ (FOURTH RECORD) (FIFTH RECORD) (SIXTH RECORD)))
  (IF (FRESH-LINE) (INCQ ROW) )
  (TERPRI)
  ROW )

(DEFUN PRINT-FOOTER (
; prints the file name, page number, and file date at the bottom of the page.
    NUM)
  ((EQ PAGE-LINE *INITIAL-LINE*))
  (TERPRI (SETQ NUM (MAX 0 (- *PAGE-LINES* PAGE-LINE *FOOTER-MARGIN* 1))))
  (WRITE-BYTE 32 (- *LEFT-MARGIN* *INITIAL-COLUMN*))
  (WRITE-STRING FILE-NAME)
  (SPACES (- (TRUNCATE COLS 2) (SPACES) 2))
  (WRITE-STRING (PACK* '- PAGE-NUMBER '-))
  (SPACES (- COLS (SPACES) (LENGTH FILE-DATE) 4))
  (WRITE-LINE FILE-DATE)
  (INCQ PAGE-LINE (ADD1 NUM))
  (IF *USE-FORMFEED*
      (WRITE-BYTE 12)
      (TERPRI (+ (- *PAGE-LINES* PAGE-LINE) *INITIAL-LINE*)) )
  (SETQ PAGE-LINE *INITIAL-LINE*)
  (INCQ PAGE-NUMBER) )

(DEFUN PACK-CSZ (CITY STATE ZIP)
; returns a formatted string of the form CITY, STATE  ZIP.
  ((EQ CITY "")
    ((EQ STATE "") ZIP)
    ((EQ ZIP "") STATE)
    (PACK* STATE "  " ZIP) )
  ((EQ STATE "")
    ((EQ ZIP "") CITY)
    (PACK* CITY "  " ZIP) )
  ((EQ ZIP "")
    (PACK* CITY ", " STATE) )
  (PACK* CITY ", " STATE "  " ZIP) )

(DEFUN DATE-STRING (DATE)
; returns a formatted string of the form mm/dd/yy.
  (PACK* (IF (< (SECOND DATE) 10) 0 "")  (SECOND DATE)	'/
	 (IF (< (THIRD DATE)  10) 0 "")  (THIRD DATE)	'/
	 (SUBSTRG (FIRST DATE) 2)) )

;		* * *	Record Display Functions   * * *

(DEFUN UPDATE-ADDRESS ()
; updates the ADDRESS program's screen display.
  (CURRENT-WINDOW)
  (CLEAR-SCREEN)
  (FOREGROUND-COLOR (LOGAND (FOREGROUND-COLOR) 7))
  (MAPC '(LAMBDA (PROMPT)
	   (SPACES (- *PROMPT-LENGTH* (LENGTH PROMPT)))
	   (WRITE-STRING PROMPT)
	   (WRITE-LINE ":") )
	*PROMPT-LIST*)
  (SETQ *DISPLAYED-RECORD* (LENGTH *RECORD-LIST*))
  (DISPLAY-RECORD) )

(DEFUN DISPLAY-RECORD (
; displays the current record if not already displayed.
    COLS)
  ((EQ *CURRENT-RECORD* *DISPLAYED-RECORD*)
    (CURRENT-WINDOW) )
  (STATUS-WINDOW)
  (SET-CURSOR 0 39)
  (PRIN1 (ADD1 *CURRENT-RECORD*))
  (SPACES 2)
  (CURRENT-WINDOW)
  (MAKE-WINDOW (WINDOW-ROW)
	       (+ (WINDOW-COL) *PROMPT-LENGTH* 1)
	       (ADD1 *FIELDS*)
	       (- (WINDOW-COLS) *PROMPT-LENGTH* 1))
  (CLEAR-SCREEN)
  (SETQ *DISPLAYED-RECORD* *CURRENT-RECORD*
	*CURRENT-AREA*)
  ((EQ *CURRENT-RECORD* (LENGTH *RECORD-LIST*))
    (CURRENT-WINDOW) )
  (SETQ COLS (- (WINDOW-COLS) *PROMPT-LENGTH* 2))
  (MAPC '(LAMBDA (FIELD)
	   (SPACES 1)
	   (WRITE-LINE (SUBSTRING FIELD 0 COLS)))
	(NTH *CURRENT-RECORD* *RECORD-LIST*) )
  (CURRENT-WINDOW) )

(DEFUN ADDRESS-STATUS ()
; updates the ADDRESS program's status line display.
  (CLEAR-STATUS "Address")
  (WRITE-STRING "File: ")
  (WRITE-STRING *FILE-NAME*)
  (SET-CURSOR 0 31)
  (WRITE-STRING "Record: ")
  (PRIN1 (ADD1 *CURRENT-RECORD*)) )

(SETQ *PRINTER-DEVICE*	'PRN)	;Printer device name (e.g. LPT2)
(SETQ *USE-FORMFEED*	NIL)	;Print files using formfeeds

;	* * *	Printer type control variables	 * * *

;Daisy Wheel printers
(SETQ *PAGE-LINES*	66	;Lines per page
      *PAGE-COLUMNS*	85	;Columns across page
      *TOP-MARGIN*	3	;Desired top margin (>= *INITIAL-LINE*)
      *BOTTOM-MARGIN*	5	;Desired bottom margin
      *FOOTER-MARGIN*	2	;Desired footer margin
      *LEFT-MARGIN*	8	;Desired left margin (>= *INITIAL-COLUMN*)
      *RIGHT-MARGIN*	NIL	;Desired right margin (NIL means truncate)
      *INITIAL-LINE*	2	;Initial printer line
      *INITIAL-COLUMN*	3	;Printer column after a RETURN
      *INIT-PRINTER*	""	;Printer initialization string
      *STOP-PRINTER*	"")	;Printer termination string


; automatically load WINDOWS.LSP if not already loaded.
(OR (GETD 'WINDOWS T)
    (LOAD "WINDOWS.LSP")
    (SOME '(LAMBDA (FILE)
	     (SETQ FILE (NREVERSE (UNPACK FILE)))
	     (LOAD (PACK (NREVERSE (OR (MEMBER '\\ FILE) (MEMBER ': FILE))
				   (LIST "WINDOWS.LSP")))) )
	  (INPUT-FILES) )
    (WRITE-LINE "Can't find the file WINDOWS.LSP" T) )
