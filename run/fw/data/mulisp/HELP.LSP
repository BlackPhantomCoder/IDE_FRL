; File: HELP.LSP  (C)		05/31/87	Soft Warehouse, Inc.

;			muLISP Help Facility

; If this file is loaded and <name> is the name of a function,
; special form, macro, or variable that is defined in the muLISP
; machine language kernel or in a muLISP library file, the command

;		(HELP 'name)

; displays <name>'s arguments or initial value and the page it is
; documented on in the muLISP Reference Manual.

(DEFUN HELP (NAME)
  (LOOP
    (FRESH-LINE T)
    ((GET NAME 'HELP-POINTER)
      ((OR (INPUT-FILE-P *HELP-FILE*) (OPEN-INPUT-FILE *HELP-FILE*))
	(FILE-READ-POSITION (GET NAME 'HELP-POINTER) *HELP-FILE*)
	(WRITE-LINE (READ-LINE *HELP-FILE*) T)
	T )
      (WRITE-LINE (PACK* *HELP-FILE* "not found") T)
      NIL )
    (WRITE-STRING "Enter primitive name: " T)
    (CLEAR-INPUT T)
    (SETQ NAME (STRING-UPCASE (STRING-TRIM '" " (READ-LINE T))))
    ((EQ NAME '||)) ) )

(MOVD 'HELP '?)

(SETQ *HELP-FILE* (CAR (INPUT-FILES)))

((LAMBDA (*TAB-EXPAND*)
(SETQ *TAB-EXPAND* T)
(LOOP
  ((NOT (LISTEN *HELP-FILE*))
    (TERPRI 2 T)
    (WRITE-LINE
      "For help on the muLISP primitive <name>, enter:	(HELP 'name)" T)
    (SETQ *INPUT-FILE*) )
  ((LAMBDA (NUM LINE)
      ((EQ LINE ||))
      (PUT (STRING-RIGHT-TRIM |: | (SUBSTRING LINE 0 (FINDSTRING '| | LINE)))
	   'HELP-POINTER NUM))
    (FILE-READ-POSITION NIL *HELP-FILE*)
    (READ-LINE *HELP-FILE*)) ) ))

ABS [n] 			Numerical	Function	5-141
ABSTRAP [obj1, obj2]		Numerical	Function	5-158
ACONS [key, object, alist]	Constructor	Function	5-36
ACOS [n]			Numerical	Function	5-139
ADD1 [n]			Numerical	Function	5-128
ADJOIN [object, list, test]	Constructor	Function	5-33
ALLOCATE [n]			Memory		Function	5-254
ALPHA-CHAR-P [symbol]		Character	Function	5-91
ALPHANUMERICP [symbol]		Character	Function	5-91
AND [form1, ... formn]		Logical 	Special form	5-67
APPEND [list1, ... listn]	Constructor	Function	5-21
APPLY [function, arg1, ... list]  Evaluator    Function        5-219
AREF [array, subscript1, ...]	Array		Function	6-3
ARRAY-DIMENSION [array, axis]	Array		Function	6-4
ARRAY-DIMENSIONS [array]	Array		Function	6-4
ARRAY-IN-BOUNDS-P [array, sub1, ...]	Array	Function	6-5
ARRAY-RANK [array]		Array		Function	6-4
ARRAY-TOTAL-SIZE [array]	Array		Function	6-4
ARRAYP [object] 		Array		Function	6-5
ASCII [atom]			Character	Function	5-95
ASH [n, count]			Numerical	Function	5-152
ASIN [n]			Numerical	Function	5-139
ASSOC [key, alist, test]	Searcher	Function	5-16
ASSOC-IF [test, alist]		Searcher	Function	5-16
ATAN [n, m]			Numerical	Function	5-139
ATOM [object]			Recognizer	Function	5-57
*AUTO-NEWLINE*: T		Output		Control var.	5-184

BACK [distance] 		Graphics	Function	6-21
BACKGROUND-COLOR [n]		Screen		Function	5-281
BINARY-LOAD [file, offset]	Hardware	Function	5-274
*BLANK-COMPRESS*: NIL		Output		Control var.	5-184
*BLINK*: NIL			Screen		Control var.	5-287
BORDER-COLOR [n]		Screen		Function	5-282
BREAK [object, message] 	User interface	Function	5-260
BREAK				User interface	Variable	5-260
BUTLAST [list, n]		Constructor	Function	5-26
BUTTON-PRESSES [button] 	Mouse		Function	6-27
BUTTON-RELEASES [button]	Mouse		Function	6-27

CAAAAR [object] 		Selector	Function	5-5
CAAADR [object] 		Selector	Function	5-5
CAAAR [object]			Selector	Function	5-5
CAADAR [object] 		Selector	Function	5-5
CAADDR [object] 		Selector	Function	5-5
CAADR [object]			Selector	Function	5-5
CAAR [object]			Selector	Function	5-5
CADAAR [object] 		Selector	Function	5-5
CADADR [object] 		Selector	Function	5-5
CADAR [object]			Selector	Function	5-5
CADDAR [object] 		Selector	Function	5-5
CADDDR [object] 		Selector	Function	5-5
CADDR [object]			Selector	Function	5-5
CADR [object]			Selector	Function	5-5
CAR [object]			Selector	Function	5-3
CASE [key, case1, ...]		Control 	Macro		5-240
CATCH [tag, form1, ...] 	Control 	Special form	5-245
CDAAAR [object] 		Selector	Function	5-5
CDAADR [object] 		Selector	Function	5-5
CDAAR [object]			Selector	Function	5-5
CDADAR [object] 		Selector	Function	5-5
CDADDR [object] 		Selector	Function	5-5
CDADR [object]			Selector	Function	5-5
CDAR [object]			Selector	Function	5-5
CDDAAR [object] 		Selector	Function	5-5
CDDADR [object] 		Selector	Function	5-5
CDDAR [object]			Selector	Function	5-5
CDDDAR [object] 		Selector	Function	5-5
CDDDDR [object] 		Selector	Function	5-5
CDDDR [object]			Selector	Function	5-5
CDDR [object]			Selector	Function	5-5
CDR [object]			Selector	Function	5-4
CEILING [n, m]			Numerical	Function	5-145
CHAR [atom, n]			String		Function	5-101
CHAR-CODE [symbol]		Character	Function	5-96
CHAR-DOWNCASE [symbol]		Character	Function	5-97
CHAR-EQUAL [sym1, ... symn]	Character	Function	5-94
CHAR-GREATERP [sym1, ... symn]	Character	Function	5-94
CHAR-LESSP [sym1, ... symn]	Character	Function	5-94
CHAR-NOT-EQUAL [sym1, ... symn] Character	Function	5-94
CHAR-NOT-GREATERP [sym1, ... ]	Character	Function	5-94
CHAR-NOT-LESSP [sym1, ... symn] Character	Function	5-94
CHAR-UPCASE [symbol]		Character	Function	5-97
CHAR= [symbol1, ... symboln]	Character	Function	5-93
CHAR< [symbol1, ... symboln]	Character	Function	5-93
CHAR> [symbol1, ... symboln]	Character	Function	5-93
CHAR<= [symbol1, ... symboln]	Character	Function	5-93
CHAR>= [symbol1, ... symboln]	Character	Function	5-93
CHAR/= [symbol1, ... symboln]	Character	Function	5-93
CLEAR-INPUT [source]		Input		Function	5-166
CLEAR-SCREEN [] 		Screen		Function	5-280
CLOSE-INPUT-FILE [file] 	File		Function	5-192
CLOSE-OUTPUT-FILE [file]	File		Function	5-200
CLOSURE [varlist, function]	Closures	Function	6-29
CLOSURE-ALIST [closure] 	Closures	Function	6-34
CLOSURE-FUNCTION [closure]	Closures	Function	6-34
CLOSURE-VARIABLES [closure]	Closures	Function	6-34
CLOSUREP [object]		Closures	Function	6-32
CLR []				Graphics	Function	6-20
CODE-CHAR [n]			Character	Function	5-96
COLUMN []			Screen		Function	5-279
COMMENT [comments]		Control 	Special form	5-244
COMPILE [name]			Compiler	Function	8-3
COMPILE-FILE [cfiles, lfiles]	Compiler	Function	8-6
:CONC-NAME [prefix]		Structure	Option		6-7
COND [cond1, ... condn] 	Control 	Special form	5-239
*CONDENSE*: NIL 		Definition	Control var.	5-89
CONS [obj1, obj2]		Constructor	Function	5-18
CONSOLE-BREAK []		Evaluator	Function	5-222
CONSP [object]			Recognizer	Function	5-59
CONSTANTP [object]		Evaluator	Function	5-215
:CONSTRUCTOR [name, arglist]	Structure	Option		6-7
:COPIER [name]			Structure	Option		6-8
COPY-ALIST [alist]		Constructor	Function	5-22
COPY-CHAR-TYPE [chr1, chr2, flg]Input		Function	5-170
COPY-CLOSURE [closure]		Closures	Function	6-32
COPY-LIST [list]		Constructor	Function	5-22
COPY-TREE [object]		Constructor	Function	5-22
COS [n] 			Numerical	Function	5-138
COS-DEG [angle] 		Graphics	Function	6-18
COUNT [object, list, test]	Searcher	Function	5-11
COUNT-IF [test, list]		Searcher	Function	5-11
CSMEMORY [offset, value, flag]	Hardware	Function	5-268
CURSOR-LINES [start, end]	Screen		Function	5-285

DECF [place, n] 		Numerical	Macro		5-130
DECQ [symbol, n]		Numerical	Special form	5-129
DEFAULT-DRIVE [drive]		File		Function	5-208
DEFAULT-PATH [drive, path]	File		Function	5-208
DEFFLAVOR [name, vars, flavors, opt1, ...]  Flavors	Macro	6-12
DEFMACRO [sym, arglist, form1, ...]  Definition Special form	5-88
DEFMETHOD [(flavor type method), args, form1, ...]  Flavors   Macro   6-14
DEFSTRUCT [(name opt1 ...), slot1, ...]  Structure	Macro	6-7
DEFUN [sym, arglist, form1, ...]  Definition	Special form	5-87
DEFWHOPPER [(flavor method), args, form1, ...]	Flavors   Macro   6-15
DELETE [item, list, test]	Modifier	Function	5-44
DELETE-COMPILER []		Compiler	Macro		8-5
DELETE-DUPLICATES [list, test]	Modifier	Function	5-46
DELETE-FILE [file]		File		Function	5-206
DELETE-IF [test, list]		Modifier	Function	5-44
DELETE-LINES [n]		Screen		Function	5-280
DELETE-NTH [list, n]		Modifier	Function	5-45
DENOMINATOR [n] 		Numerical	Function	5-143
DENTRAP [obj1, obj2]		Numerical	Function	5-158
DIGIT-CHAR-P [symbol, radix]	Character	Function	5-92
DIRECTORY [path]		File		Function	5-208
DISPLAY-PAGE [n, active-only]	Screen		Function	5-284
DIVIDE [n, m]			Numerical	Function	5-149
DO [letlist, form1, ... formn]	Control 	Macro		5-242
DO* [letlist, form1, ... formn] Control 	Macro		5-242
DOLIST [(var list result), form1, ...]	Control Macro		5-243
DOS [command]			Control 	Function	5-249
DOT [x, y]			Graphics	Function	6-19
DOTIMES [(var count result), form1, ...]  Control  Macro	5-243
DRIVER [file]			User interface	Function	5-257
DRIVER: 'DRIVER 		User interface	Control var.	5-259
DSMEMORY [offset, value, flag]	Hardware	Function	5-268

EIGHTH [list]			Selector	Function	5-7
ENDP [object]			Recognizer	Function	5-60
EQ [obj1, obj2] 		Comparator	Function	5-61
EQL [obj1, obj2]		Comparator	Function	5-62
EQUAL [obj1, obj2, test]	Comparator	Function	5-63
EVAL [object]			Evaluator	Function	5-217
EVAL-FUNCTION-P [symbol]	Evaluator	Function	5-214
EVENP [object]			Numerical	Function	5-116
EVERY [test, list1, ... listn]	Evaluator	Function	5-230
*EXACT-MODE*: NIL		Numerical	Control var.	5-111
EXECUTE [program, command]	Control 	Function	5-249
EXP [n] 			Numerical	Function	5-134
EXPT [n, m]			Numerical	Function	5-135

FBOUNDP [symbol]		Evaluator	Function	5-214
FIFTH [list]			Selector	Function	5-7
FILE-DATE [file]		File		Function	5-207
FILE-LENGTH [file]		File		Function	5-207
FILE-LINE-LENGTH [n, file]	File		Function	5-205
FILE-READ-POSITION [n, file]	File		Function	5-196
FILE-WRITE-POSITION [n, file]	File		Function	5-204
FILL [list, object]		Modifier	Function	5-40
FIND [object, list, test]	Searcher	Function	5-14
FIND-IF [test, list]		Searcher	Function	5-14
FINDSTRING [atom1, atom2, n]	String		Function	5-107
FIRST [list]			Selector	Function	5-7
FIRSTN [n, list]		Constructor	Function	5-23
FLAG [symbol, attribute]	Flag		Function	5-80
FLAGP [symbol, attribute]	Flag		Function	5-80
FLOOR [n, m]			Numerical	Function	5-144
FMAKUNBOUND [symbol]		Definition	Function	5-86
FOREGROUND-COLOR [n]		Screen		Function	5-281
FORWARD [distance]		Graphics	Function	6-21
FOURTH [list]			Selector	Function	5-7
*FREE-LIST*: NIL		Memory		Variable	5-253
FRESH-LINE [sink]		Output		Function	5-181
FUNCALL [function, arg1, ...]	Evaluator   Function	    5-221
FUNCTIONP [object]		Evaluator	Function	5-215

GCD [n1, n2, ... nm]		Numerical	Function	5-131
GCDTRAP [obj1, obj2]		Numerical	Function	5-158
*GCHOOK*: NIL			Memory		Control var.	5-253
*GCSTAT*: NIL			Memory		Control var.	5-251
GENSYM [atom]			String		Function	5-109
*GENSYM-COUNT*: 0		String		Control var.	5-109
*GENSYM-PREFIX*: G		String		Control var.	5-109
GET [symbol, key]		Property	Function	5-78
GET-BREAK-CHARS []		Input		Function	5-162
GET-DECODED-TIME []		Miscellaneous	Function	5-289
GET-MACRO-CHAR [char, flag]	Input		Function	5-171
GETD [symbol, flag]		Definition	Function	5-83
GETSET [parameter]		Miscellaneous	Function	5-290
:GETTABLE-INSTANCE-VARIABLES	Flavors 	Option		6-12

HIDE-MOUSE []			Mouse		Function	6-24
*HIGH-INTENSITY*: NIL		Screen		Control var.	5-287

IDENTITY [object]		Control 	Function	5-237
IF [testform, thenform, elseform]  Control	Special form	5-238
*IGNORE-CASE*: NIL		Input		Control var.	5-176
INCF [place, n] 		Numerical	Macro		5-130
:INCLUDE [structure]		Structure	Option		6-8
:INCLUDED-FLAVORS [flav1, ...]	Flavors 	Option		6-12
INCQ [symbol, n]		Numerical	Special form	5-129
:INITABLE-INSTANCE-VARIABLES	Flavors 	Option		6-12
:INITIAL-CONTENTS expression	Array		Option		6-2
:INITIAL-ELEMENT expression	Array		Option		6-2
*INPUT-ECHO*: NIL		Input		Control var.	5-175
INPUT-FILE [file]		File		Function	5-193
*INPUT-FILE*: NIL		File		Control var.	5-195
INPUT-FILE-P [file]		File		Function	5-194
INPUT-FILES []			File		Function	5-194
INSERT-LINES [n]		Screen		Function	5-280
*INSERT-MODE*: T		User interface	Control var.	5-265
INSERT-NTH [item, list, n]	Modifier	Function	5-45
INTEGER-LENGTH [n]		Numerical	Function	5-153
INTEGERP [object]		Recognizer	Function	5-56
INTERRUPT [n]			Hardware	Function	5-273
INTERSECTION [list1, list2, test]  Constructor	Function	5-34
ISQRT [n]			Numerical	Function	5-137

LAMBDA				Definition	Keyword 	5-83
LAST [list]			Selector	Function	5-8
LCM [n1, ... nm]		Numerical	Function	5-133
LCMTRAP [obj1, obj2]		Numerical	Function	5-158
LCONC [dotted-pair, list]	Modifier	Function	5-51
LDIFF [list, tail]		Constructor	Function	5-25
LEFT [angle]			Graphics	Function	6-21
*LEFT-BUTTON*			Mouse		Variable	6-26
LENGTH [object] 		Selector	Function	5-10
LET [letlist, form1, ... formn] Control 	Macro		5-241
LET* [letlist, form1, ... formn]Control 	Macro		5-241
LET-CLOSED [letlist, function]	Closures	Macro		6-31
LINE [x1, y1, x2, y2]		Graphics	Function	6-19
*LINE-COLUMN*			User interface	Variable	5-264
LINE-EDIT [text, pnt, col, wdth] User interface Function	5-264
*LINE-POINT*			User interface	Variable	5-264
*LINE-TERMINATOR*		User interface	Variable	5-264
LIST [obj1, ... objn]		Constructor	Function	5-19
LIST* [obj1, ... objn]		Constructor	Function	5-19
LIST-LENGTH [object]		Selector	Function	5-10
LISTEN [source] 		Input		Function	5-165
LISTP [object]			Recognizer	Function	5-59
LN [n]				Numerical	Function	5-136
LOAD [file, display]		Environment	Function	5-211
*LOAD-VERBOSE*: T		Environment	Control var.	5-211
LOCATION [object]		Hardware	Function	5-271
LOG [n, base]			Numerical	Function	5-136
LOGAND [n1, ... nm]		Numerical	Function	5-151
LOGBITP [index, n]		Numerical	Function	5-150
LOGEQV [n1, ... nm]		Numerical	Function	5-151
LOGIOR [n1, ... nm]		Numerical	Function	5-151
LOGNOT [n]			Numerical	Function	5-150
LOGTEST [n, m]			Numerical	Function	5-150
LOGXOR [n1, ... nm]		Numerical	Function	5-151
LOOP [form1, ... formn] 	Control 	Special form	5-235
LOWER-CASE-P [symbol]		Character	Function	5-90

MACRO				Definition	Keyword 	5-83
MACRO-FUNCTION [symbol] 	Evaluator	Function	5-223
MACRO-FUNCTION-P [symbol]	Evaluator	Function	5-214
MACROEXPAND [form]		Evaluator	Function	5-224
MACROEXPAND: 'MACROEXPAND	Evaluator	Control var.	5-225
MACROEXPAND-1 [form]		Evaluator	Function	5-224
MAKE-ARRAY [dims, opt1, ...]	Array		Function	6-2
MAKE-INSTANCE [flavor, vars]	Flavors 	Macro		6-16
MAKE-LIST [n, object, list]	Constructor	Function	5-20
MAKE-RANDOM-STATE [state]	Numerical	Function	5-155
MAKE-WINDOW [row, col, rows, cols]  Screen	Function	5-278
MAPC [function, list1, ...]	Evaluator	Function	5-226
MAPCAN [function, list1, ...]	Evaluator	Function	5-228
MAPCAR [function, list1, ...]	Evaluator	Function	5-227
MAPCON [function, list1, ...]	Evaluator	Function	5-228
MAPL [function, list1, ...]	Evaluator	Function	5-226
MAPLIST [function, list1, ...]	Evaluator	Function	5-227
MAX [n1, ... nm]		Numerical	Function	5-123
MEMBER [object, list, test]	Searcher	Function	5-13
MEMBER-IF [test, list]		Searcher	Function	5-13
MEMORY [address, value, flag]	Hardware	Function	5-266
MERGE [list1, list2, test]	Modifier	Function	5-53
:METHOD-COMBINATION		Flavors 	Option		6-13
MIN [n1, ... nm]		Numerical	Function	5-123
MINUSP [object] 		Numerical	Function	5-115
MISMATCH [list1, list2, test]	Searcher	Function	5-12
MOD [n, m]			Numerical	Function	5-148
MOUSE-BOX [x1, y1, x2, y2]	Mouse		Function	6-28
MOUSE-POSITION [x, y]		Mouse		Function	6-25
MOUSE-RESET []			Mouse		Function	6-23
MOUSE-STATUS [] 		Mouse		Function	6-26
*MOUSE-X*			Mouse		Variable	6-25
*MOUSE-Y*			Mouse		Variable	6-25
MOVD [symbol1, symbol2] 	Definition	Function	5-85

:NAMED				Structure	Option		6-9
NBUTLAST [list, n]		Modifier	Function	5-42
NCONC [list1, ... listn]	Modifier	Function	5-41
NEQ [obj1, obj2]		Comparator	Function	5-61
NEQL [obj1, obj2]		Comparator	Function	5-62
NEW-CODE-SPACE []		Memory		Function	5-255
NIL				Evaluator	Constant	5-197
NINTH [list]			Selector	Function	5-7
NLAMBDA 			Definition	Keyword 	5-83
NO-EVAL-FUNCTION-P [symbol]	Evaluator	Function	5-214
:NO-VANILLA-FLAVOR		Flavors 	Option		6-13
NOT [object]			Logical 	Function	5-66
NOTANY [test, list1, ...]	Evaluator	Function	5-229
NOTEVERY [test, list1, ...]	Evaluator	Function	5-230
NRECONC [list, object]		Modifier	Function	5-43
NREVERSE [list, object] 	Modifier	Function	5-43
NSUBLIS [alist, object, test]	Modifier	Function	5-49
NSUBST [new, old, object, test] Modifier	Function	5-48
NSUBST-IF [new, test, object]	Modifier	Function	5-48
NSUBSTITUTE [new, old, list, test]  Modifier	Function	5-47
NSUBSTITUTE-IF [new, test, list]  Modifier	Function	5-47
NTH [n, list]			Selector	Function	5-9
NTHCDR [n, list]		Selector	Function	5-9
NULL [object]			Recognizer	Function	5-58
NUMBERP [object]		Recognizer	Function	5-56
NUMERATOR [n]			Numerical	Function	5-143
NUMERIC-CHAR-P [symbol] 	Character	Function	5-91
NUMTRAP [obj1, obj2]		Numerical	Function	5-158

OBLIST []			Constructor	Function	5-37
ODDP [object]			Numerical	Function	5-116
OPEN-INPUT-FILE [file]		File		Function	5-191
OPEN-OUTPUT-FILE [file, overwrite]  File	Function	5-198
OR [form1, ... formn]		Logical 	Special form	5-68
ORDERP [object1, object2]	Comparator	Function	5-65
*OUTPUT-ECHO*: NIL		Output		Control var.	5-184
OUTPUT-FILE [file]		File		Function	5-201
*OUTPUT-FILE*: NIL		File		Control var.	5-203
OUTPUT-FILE-P [file]		File		Function	5-202
OUTPUT-FILES [] 		File		Function	5-202

PACK [list]			String		Function	5-99
PACK* [atom1, ... atomn]	String		Function	5-99
PAIRLIS [keys, objects, alist]	Constructor	Function	5-36
PALETTE-COLOR [n]		Screen		Function	5-282
PARSE-INTEGER [string, radix]	Input		Function	5-168
PEEK-CHAR [peek-type, source]	Input		Function	5-164
PENDOWN []			Graphics	Function	6-20
PENUP []			Graphics	Function	6-20
PI []				Numerical	Function	5-140
PLOT-CIRCLE [x, y, r, color]	Screen		Function	5-286
PLOT-DOT [x, y, color]		Screen		Function	5-286
PLOT-LINE [x1, y1, x2, y2, color]  Screen	Function	5-286
PLUSP [object]			Numerical	Function	5-115
POP [symbol]			Assignment	Special form	5-74
PORTIO [port, value, flag]	Hardware	Function	5-270
POSITION [object, list, test]	Searcher	Function	5-15
POSITION-IF [test, list]	Searcher	Function	5-15
PRECISION [n]			Numerical	Function	5-111
:PREDICATE [name]		Structure	Option		6-8
PRIN1 [object, sink]		Output		Function	5-179
PRINC [object, sink]		Output		Function	5-179
PRINT [object, sink]		Output		Function	5-179
*PRINT-BASE*: 10		Output		Control var.	5-187
*PRINT-DOWNCASE*: NIL		Output		Control var.	5-185
*PRINT-ESCAPE*: T		Output		Control var.	5-186
PRINT-LENGTH [atom]		String		Function	5-108
*PRINT-POINT*: 7		Output		Control var.	5-188
*PRINTER-ECHO*: NIL		Output		Control var.	5-185
PROBE-FILE [file]		File		Function	5-206
PROG1 [form1, ... formn]	Control 	Special form	5-236
PROG2 [form1, ... formn]	Control 	Macro		5-236
PROGN [form1, ... formn]	Control 	Special form	5-234
PSETQ [symbol1, form1, ...]	Assignment	Special form	5-72
PUSH [form, symbol]		Assignment	Special form	5-75
PUSHNEW [form, symbol, test]	Assignment	Macro		5-75
PUT [symbol, key, object]	Property	Function	5-77
PUTD [symbol, definition]	Definition	Function	5-84

QUOTE [object]			Control 	Special form	5-233

RANDOM [n, state]		Numerical	Function	5-154
*RANDOM-STATE*			Numerical	Control var.	5-155
RANDOM-STATE-P [object] 	Numerical	Function	5-156
RASSOC [key, alist, test]	Searcher	Function	5-17
RASSOC-IF [test, alist] 	Searcher	Function	5-17
RATIONAL			Numerical	Keyword 	5-112
RATIONALP [object]		Recognizer	Function	5-56
READ [source]			Input		Function	5-160
READ-ATOM [source]		Input		Function	5-161
*READ-BASE*: 10 		Input		Control var.	5-175
READ-BYTE [source]		Input		Function	5-163
READ-CHAR [source]		Input		Function	5-163
READ-DOT [x, y] 		Screen		Function	5-286
READ-FROM-STRING [string]	Input		Function	5-167
READ-LINE [source]		Input		Function	5-163
*READ-STRINGS*			Input		Variable	5-160
*READ-UPCASE*: T		Input		Control var.	5-175
RECLAIM []			Memory		Function	5-250
REDUCE [function, list, init]	Evaluator	Function	5-231
REGISTER [n, m] 		Hardware	Function	5-272
REM [n, m]			Numerical	Function	5-148
REMD [symbol]			Definition	Function	5-86
REMFLAG [symbol, attribute]	Flag		Function	5-81
REMOVE [item, list, test]	Constructor	Function	5-28
REMOVE-DUPLICATES [list, test]	Constructor	Function	5-29
REMOVE-IF [test, list]		Constructor	Function	5-28
REMPROP [symbol, key]		Property	Function	5-79
RENAME-FILE [oldname, newname]	File		Function	5-206
REPLACE [list1, list2]		Modifier	Function	5-40
:REQUIRED-FLAVORS [flav1, ...]	Flavors 	Option		6-12
REST [list]			Selector	Function	5-7
RESTART []			Control 	Function	5-248
RETURN [form]			Control 	Special form	5-247
REVAPPEND [list, object]	Constructor	Function	5-27
REVERSE [list, object]		Constructor	Function	5-27
RIGHT [angle]			Graphics	Function	6-21
*RIGHT-BUTTON*			Mouse		Variable	6-26
ROUND [n, m]			Numerical	Function	5-147
ROW []				Screen		Function	5-279
RPLACA [obj1, obj2]		Modifier	Function	5-38
RPLACD [obj1, obj2]		Modifier	Function	5-39

SAVE [file]			Environment	Function	5-209
SECOND [list]			Selector	Function	5-7
SELF				Flavors 	Variable	6-17
SEND [obj, op, arg1, ...]	Flavors 	Macro		6-17
SET [symbol, object]		Assignment	Function	5-70
SET-BREAK-CHARS [list, flag]	Input		Function	5-162
SET-CURSOR [row, column]	Screen		Function	5-279
SET-DIFFERENCE [list1, list2, test]  Constructor  Function	5-35
SET-EXCLUSIVE-OR [list1, list2, test]  Constructor  Function	5-35
SET-IN-CLOSURE [closure, sym, obj]  Closures	Function	6-33
SET-MACRO-CHAR [char, defn, flg]  Input 	Function	5-171
SETCOLOR [angle]		Graphics	Function	6-20
SETF [place1, form1, ... ]	Assignment	Macro		5-73
SETHEADING [angle]		Graphics	Function	6-20
SETPOS [x, y]			Graphics	Function	6-20
SETQ [symbol1, form1, ...]	Assignment	Special form	5-71
:SETTABLE-INSTANCE-VARIABLES	Flavors 	Option		6-12
SEVENTH [list]			Selector	Function	5-7
SHIFT [n, count]		Numerical	Function	5-152
SHOW-MOUSE []			Mouse		Function	6-24
SIGNUM [n]			Numerical	Function	5-142
SIN [n] 			Numerical	Function	5-138
SIN-DEG [angle] 		Graphics	Function	6-18
SIXTH [list]			Selector	Function	5-7
SNAPSHOT [address, atom]	Hardware	Function	5-275
SOME [test, list1, ... listn]	Evaluator	Function	5-229
SORT [list, test]		Modifier	Function	5-54
SPACES [n, sink]		Output		Function	5-182
SPECIAL 			Definition	Keyword 	5-83
SPECIAL-FORM-P [symbol] 	Evaluator	Function	5-214
SPLIT [list]			Modifier	Function	5-52
SQRT [n]			Numerical	Function	5-137
STABLE-SORT [list, test]	Modifier	Function	5-54
STACK-LIST []			Constructor	Function	5-37
STRING-CAPITALIZE [atom]	String		Function	5-106
STRING-DOWNCASE [atom]		String		Function	5-106
STRING-EQUAL [atom1, atom2]	String		Macro		5-102
STRING-GREATERP [atom1, atom2]	String		Macro		5-104
*STRING-INDEX*			Input		Variable	5-167,8
STRING-LEFT-TRIM [chars, atom]	String		Function	5-105
STRING-LESSP [atom1, atom2]	String		Macro		5-104
STRING-NOT-EQUAL [atom1, atom2] String		Macro		5-104
STRING-NOT-GREATERP [atm1, atm2]  String	Macro		5-104
STRING-NOT-LESSP [atom1, atom2] String		Macro		5-104
STRING-RIGHT-TRIM [chars, atom] String		Function	5-105
STRING-TRIM [chars, atom]	String		Function	5-105
STRING-UPCASE [atom]		String		Function	5-106
STRING=  [atom1, atom2, flag]	String		Function	5-102
STRING<  [atom1, atom2, flag]	String		Function	5-103
STRING>  [atom1, atom2, flag]	String		Function	5-103
STRING<=  [atom1, atom2, flag]	String		Function	5-103
STRING>=  [atom1, atom2, flag]	String		Function	5-103
STRING/=  [atom1, atom2, flag]	String		Function	5-103
STRINGP [object]		Recognizer	Function	5-55
SUB1 [n]			Numerical	Function	5-128
SUBLIS [alist, object, test]	Constructor	Function	5-32
SUBLIST [list, n, m]		Constructor	Function	5-24
SUBSETP [list1, list2, test]	Comparator	Function	5-64
SUBST [new, old, object, test]	Constructor	Function	5-31
SUBST-IF [new, test, object]	Constructor	Function	5-31
SUBSTITUTE [new, old, list, test]  Constructor	Function	5-30
SUBSTITUTE-IF [new, test, list] Constructor	Function	5-30
SUBSTRING [atom, n, m]		String		Function	5-100
SYMBOL-FUNCTION [symbol]	Evaluator	Function	5-216
SYMBOL-PLIST [symbol]		Evaluator	Function	5-216
SYMBOL-VALUE [symbol]		Evaluator	Function	5-216
SYMBOLP [object]		Recognizer	Function	5-55
SYMEVAL-IN-CLOSURE [closure, sym]  Closures	Function	6-33
SYSTEM [n]			Control 	Function	5-248

*TAB-EXPAND*: NIL		Input		Control var.	5-176
TAILP [list1, list2]		Comparator	Function	5-64
TAN [n] 			Numerical	Function	5-138
TCONC [dotted-pair, object]	Modifier	Function	5-50
TENTH [list]			Selector	Function	5-7
TERPRI [n, sink]		Output		Function	5-181
THIRD [list]			Selector	Function	5-7
THROW [tag, form]		Control 	Special form	5-247
*THROW-TAG*			Control 	Variable	5-247
TIME [flag]			Miscellaneous	Function	5-289
TONE [frequency, duration]	Miscellaneous	Function	5-288
TREE-EQUAL [obj1, obj2, test]	Comparator	Function	5-63
TRUNCATE [n, m] 		Numerical	Function	5-146
TURTLE []			Graphics	Function	6-22
TURTLE-WINDOW []		Graphics	Function	6-22
:TYPE [LIST]			Structure	Option		6-9

UNDEFINED [symbol, form1, ...]	Evaluator	Function	5-222
UNDERFLOW [n]			Numerical	Function	5-113
UNION [list1, list2, test]	Constructor	Function	5-34
UNLESS [test, form1, ...]	Control 	Macro		5-238
UNPACK [atom]			String		Function	5-98
UNREAD-CHAR [source]		Input		Function	5-164
UNWIND-PROTECT [form1, ...]	Control 	Special form	5-246
UPPER-CASE-P [symbol]		Character	Function	5-90

VECTOR [obj1, obj2, ...]	Array		Function	6-2
VIDEO-MODE [n]			Screen		Function	5-283

WHEN [testform, form1, ...]	Control 	Macro		5-238
WRITE [object, sink]		Output		Function	5-178
WRITE-BYTE [n, m, sink] 	Output		Function	5-183
WRITE-LINE [symbol, sink]	Output		Function	5-180
WRITE-STRING [symbol, sink]	Output		Function	5-180

Y-OR-N-P [message]		User interface	Function	5-263
YES-OR-NO-P [message]		User interface	Function	5-263

ZEROP [object]			Numerical	Function	5-114

+ [n1, ... nm]			Numerical	Function	5-124
- [n1, ... nm]			Numerical	Function	5-125
* [n1, ... nm]			Numerical	Function	5-126
/ [n1, ... nm]			Numerical	Function	5-127

+TRAP [obj1, obj2]		Numerical	Function	5-157
-TRAP [obj1, obj2]		Numerical	Function	5-157
*TRAP [obj1, obj2]		Numerical	Function	5-157
/TRAP [obj1, obj2]		Numerical	Function	5-157

= [n1, ... nm]			Numerical	Function	5-117
/= [n1, ... nm] 		Numerical	Function	5-118
< [n1, ... nm]			Numerical	Function	5-119
> [n1, ... nm]			Numerical	Function	5-120
<= [n1, ... nm] 		Numerical	Function	5-121
>= [n1, ... nm] 		Numerical	Function	5-122

\  back slash			Input		Escape char.	5-166
|  vertical bar 		Input		Escape char.	5-166

(  left parenthesis		Input		Macro char.	5-172
)  right parenthesis		Input		Macro char.	5-172
]  right square bracket 	Input		Macro char.	5-172
,  comma			Input		Macro char.	5-172

'  single quote 		Input		Macro char.	5-173
"  double quote 		Input		Macro char.	5-173
;  semicolon			Input		Macro char.	5-173
`  back quote			Input		Macro char.	5-174

+				User interface	Variable	5-257
++				User interface	Variable	5-257
+++				User interface	Variable	5-257
*				User interface	Variable	5-257
**				User interface	Variable	5-257
***				User interface	Variable	5-257
-				User interface	Variable	5-257
