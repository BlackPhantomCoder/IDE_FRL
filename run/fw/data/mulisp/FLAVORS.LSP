; File: FLAVORS.LSP (c) 	06/03/87	Soft Warehouse, Inc.


;			The muLISP Flavors Package

; This package was written by Peter Ohler of Boulder Creek, CA, USA.

; This flavors package allows multiple inherited methods and instance
; variables.  Before and after demons are supported and created objects
; get recompiled flavor methods but not instance variables.  The flavors
; package found on LISP machines is followed as close as possible.  All
; flavor instance variables are initable by default and :BEFORE :INIT
; and :AFTER :INIT messages are supported.  Instance variables can be
; referenced directly in method definitions and can be set with a SETQ.

; Methods and default instance-variables are stored on the property list of
; the flavors.	Instance-variables and inherited flavors are stored on the
; property lists of the objects.  The inherited-flavors list is constructed
; using a breadth first algorithm starting with the parent flavor of the
; object.

(SETQ *ALL-FLAVOR-NAMES*)	;list of all the flavor names defined
(SETQ *INSTANCE-COUNT* 0)	;flavor instance counter


(DEFMACRO DEFFLAVOR (FLAV VARS INH-FLAVS . OPTIONS)
; creates a flavor and puts the default instance-variables on the property
; list of the flavor.  It makes the :GET and :SET methods if the key words
; :GETTABLE-INSTANCE-VARIABLES or :SETTABLE-INSTANCE-VARIABLES are included.
; Other options are included according to the members of the options list.
  ( ((OR INH-FLAVS (MEMBER ':NO-VANILLA-FLAVOR OPTIONS))
      (PUT FLAV 'INH-FLAVS INH-FLAVS)
      (PUT FLAV ':INIT '(LAMBDA (SELF) SELF)) )
    (PUT FLAV 'INH-FLAVS (LIST VANILLA-FLAVOR)) )

; Set VARS to a list of the default instance-variables from VARS.
  (SETQ VARS (MAPCAR '(LAMBDA (VAR)
			((ATOM VAR)
			  (CONS VAR) )
			(CONS (CAR VAR) (EVAL (CADR VAR))) )
		     VARS))
  (PUT FLAV 'INST-VARS VARS)

; For each gettable instance variable, put on FLAV's property list the
; lambda expression that GETS the value of the variable when the variable
; is passed to FLAV as the first argument.
  (MAPC '(LAMBDA (VAR)
	   (PUT FLAV
		(PACK* '\: (CAR VAR))
		(LIST 'LAMBDA
		      '(SELF)
		      (LIST 'GET 'SELF (LIST 'QUOTE (CAR VAR))))) )
	(APPEND (IF (MEMBER ':GETTABLE-INSTANCE-VARIABLES OPTIONS) VARS)
		(CDR (ASSOC ':GETTABLE-INSTANCE-VARIABLES OPTIONS))))

; For each settable instance variable, put on FLAV's property list the
; lambda expression that SETS the value of the variable value when the
; variable is passed to an object as the first argument and the value is
; passed as the second argument.  The new value replaces the old
; instance-variable on FLAV's property list.
  (MAPC '(LAMBDA (VAR)
	   (PUT FLAV
		(PACK* '\:SET- (CAR VAR))
		(LIST 'LAMBDA
		      '(SELF VALUE)
		      (LIST 'PUT 'SELF (LIST 'QUOTE (CAR VAR)) 'VALUE))) )
	(APPEND (IF (MEMBER ':SETTABLE-INSTANCE-VARIABLES OPTIONS) VARS)
		(CDR (ASSOC ':SETTABLE-INSTANCE-VARIABLES OPTIONS))))

; For each method in the method combinations, put on FLAV's property list
; the appropriate method combination for that method.
  (MAPC '(LAMBDA (ARG)
	   (MAPC '(LAMBDA (METH)
		    (PUT FLAV (PACK* METH '-COMB) (FIRSTN 2 ARG)) )
		 (CDDR ARG)) )
	(CDR (ASSOC ':METHOD-COMBINATION OPTIONS)))

  (PUT FLAV 'INC-FLAVS (CDR (ASSOC ':INCLUDED-FLAVORS OPTIONS)))
  (PUT FLAV 'REQ-FLAVS (CDR (ASSOC ':REQUIRED-FLAVORS OPTIONS)))
  (SETQ *ALL-FLAVOR-NAMES* (ADJOIN FLAV *ALL-FLAVOR-NAMES*))
  (LIST 'QUOTE FLAV) )


(DEFMACRO SEND (OBJ METH . VARS)
; passes messages or methods to objects.  All the :AROUND methods
; (WHOPPERS) are found by FIND-METHOD!F and wrapped around the primary
; method combination which is formed by METHOD-COMB!F.	The combination
; returned is a lambda expression that is consed onto a list of the object
; itself (SELF) and the variables.
  (LIST 'SEND!F OBJ (LIST 'QUOTE METH) (LIST 'QUOTE VARS)))

(DEFUN SEND!F (OBJ METH VARS)
  (EVAL
    (LIST*
      (REDUCE 'WHOP-SUBST!F (REVERSE
	(APPEND (FIND-METHOD!F (GET OBJ 'PARENT-FLAVORS) (LIST ':AROUND METH))
		(LIST (METHOD-COMB!F OBJ METH)))))
      (LIST 'QUOTE OBJ)
      VARS)) )


(DEFUN WHOP-SUBST!F (FUNC WHOP)
; takes two lambda expressions and imbeds the first lambda expression in
; the second one to form a single lambda expression.  The substitutions
; are done wherever the keyword CONTINUE-WHOPPER is found.
  ((ATOM WHOP) WHOP)
  ((EQL (CAR WHOP) 'QUOTE) WHOP)
  ((EQL (CAR WHOP) 'CONTINUE-WHOPPER)
    (LIST* FUNC 'SELF (WHOP-SUBST!F FUNC (CDR WHOP))) )
  (MAPCAR '(LAMBDA (X) (WHOP-SUBST!F FUNC X)) WHOP) )

(DEFUN METHOD-COMB!F (OBJ METH
; forms the primary method combination.  It finds the method combination
; for the method and uses it to determine how the lambda expressions
; returned by FIND-METHOD!F will be put together to form a larger lambda
; expression.
    VARS PRIME COMB BEFORE AFTER)
  (SETQ FLAVS (GET OBJ 'PARENT-FLAVORS)
	PRIME (FIND-METHOD!F FLAVS METH)
    COMB (OR (SOME '(LAMBDA (FLAV) (GET FLAV (PACK* METH '-COMB))) FLAVS)
		 ':DAEMON))
  ( ((EQL ':DAEMON COMB)    ;only need :BEFORE and :AFTER if comb is :DAEMON
      (SETQ BEFORE (FIND-METHOD!F FLAVS (LIST ':BEFORE METH))
	    AFTER  (FIND-METHOD!F FLAVS (LIST ':AFTER METH))) ) )
  ((NOT (OR PRIME BEFORE AFTER))   ;If no methods are found, signal a break.
    (BREAK (LIST OBJ METH) "Unclaimed Message") )
  (SETQ VARS (CADAR (APPEND PRIME BEFORE AFTER)))
  ((EQL ':DAEMON COMB)
    (LIST* 'LAMBDA VARS
	   (APPEND (MAP-METHOD!F VARS BEFORE)
		   (LIST (CONS 'PROG1
			       (APPEND (MAP-METHOD!F VARS (FIRSTN 1 PRIME))
				       (MAP-METHOD!F VARS AFTER)))))) )
  ((EQL ':AND (CAR COMB))
    (LIST 'LAMBDA VARS
	  (CONS 'AND
		(MAP-METHOD!F VARS (COND
			((EQL ':BASE-FLAVOR-LAST (CADR COMB)) PRIME)
			((EQL ':BASE-FLAVOR-FIRST (CADR COMB))
			  (REVERSE PRIME) ) )))) )
  ((EQL ':OR (CAR COMB))
    (LIST 'LAMBDA VARS
	  (CONS 'OR
		(MAP-METHOD!F VARS (COND
			((EQL ':BASE-FLAVOR-LAST (CADR COMB)) PRIME)
			((EQL ':BASE-FLAVOR-FIRST (CADR COMB))
			  (REVERSE PRIME) ) )))) ) )

(DEFUN FIND-METHOD!F (FLAVS METH)
; returns a list of all the methods for FLAVS that match METH.
  (DELETE NIL (MAPCAR '(LAMBDA (FLAV) (GET FLAV METH)) FLAVS)) )

(DEFUN MAP-METHOD!F (VARS FUNCS)
; creates the cons of a lambda expression onto VARS.
   (MAPCAR '(LAMBDA (FUNC) (LIST* FUNC VARS)) FUNCS) )


(DEFMACRO DEFMETHOD ((FLAV . METH) ARGS . BODY)
; puts the lambda expression of args and body onto the property list of
; the flavor under the method name.  SELF is always added to the argument
; list of the method and all references to the instance-variables for
; the inherited, included, and required flavors are replaced with
; direct references to the objects property list.
; SETQs are turned into PUTs and the variables are turned into GETs.
; (NOTE: Variables can be changed while in a function by some other call
; so a direct reference is required so as to use the most current value of
; the variable.)
  (PUT FLAV
       (IF (CDR METH) METH (CAR METH))
       (LIST* 'LAMBDA
	      (CONS 'SELF ARGS)
	      (VAR-SUBST!F (INH-VARS!F (REQ-FLAVS!F (INH-INC-FLAVS!F FLAV)))
			   BODY)))
  (LIST* 'LIST ':METHOD (LIST 'QUOTE FLAV) METH) )

(DEFMACRO DEFWHOPPER ((FLAV . METH) ARGS . BODY)
; puts the lambda expression of args and body onto the property list of
; the flavor under the list of :AROUND and the method name.  In every
; other way it is like DEFMETHOD.
  (PUT FLAV
       (LIST ':AROUND (CAR METH))
       (LIST* 'LAMBDA
	      (CONS 'SELF ARGS)
	      (VAR-SUBST!F (INH-VARS!F (REQ-FLAVS!F (INH-INC-FLAVS!F FLAV)))
			   BODY)))
  (LIST 'LIST ':METHOD (LIST 'QUOTE FLAV) ':AROUND (CAR METH)) )

(DEFUN VAR-SUBST!F (VARS BODY)
; substitutes the variables and calls PARSE-SETQ!F when SETQ is encountered.
  ((NULL BODY) NIL)
  (LOOP
    ((NULL VARS) BODY)
    (SETQ BODY
	  (COND ((NULL BODY) NIL)
		((EQ BODY (CAAR VARS))
		  (LIST 'GET 'SELF (LIST 'QUOTE (CAAR VARS))) )
		((LISTP BODY)
		  ((EQ 'QUOTE (CAR BODY)) BODY)
		  ((EQ 'SETQ (CAR BODY))
		    (PARSE-SETQ!F (CAAR VARS) BODY) )
		  (MAPCAR '(LAMBDA (X) (VAR-SUBST!F (LIST (CAR VARS)) X))
			  BODY) )
		(BODY) ))
    (POP VARS)))

(DEFUN PARSE-SETQ!F (VAR B1
; breaks apart a SETQ and creates a PROGN of SETQs and PUTs if the SETQ
; changes more than one variable and references the variable VAR handed to it.
    B2 TST)
  (POP B1)
  (SETQ TST NIL B2)
  ((LOOP
     ((NULL B1) TST)
     (IF (EQ VAR (CAR B1)) (SETQ TST 'T))
     (SETQ B2 (CONS (POP B1) B2)
	   B2 (CONS (VAR-SUBST!F (LIST (LIST VAR)) (POP B1)) B2)))
    (LOOP
      ((NULL B2)
	((= 1 (LENGTH B1))
	  (CAR B1) )
	(CONS 'PROGN B1) )
      (SETQ B1 (CONS (IF (EQ VAR (CADR B2))
			 (LIST 'PUT 'SELF (LIST 'QUOTE VAR) (CAR B2))
			 (LIST 'SETQ (CADR B2) (CAR B2)))
		     B1)
	    B2 (CDDR B2)) ) )
  (CONS 'SETQ (REVERSE B2)) )

(DEFMACRO UNDEFMETHOD ((FLAV . METH))
; removes a method from the flavors property list using REMPROP.
  (REMPROP FLAV (IF (CDR METH) METH (CAR METH)))
  'T)

(DEFMACRO MAKE-INSTANCE (FLAV . VARS)
; creates an instance of a flavor and returns it as an object.
; First it creates a new name for the object by packing the flavor's name
; with the incremented value of the variable *INSTANCE-COUNT*.
; Next it puts the instance-variable values on the object's property list
; along with a list of inherited flavors that include all the included
; flavors.  If a required flavor is not included on the list, an error is
; signaled.
; Note that MAKE-INSTANCE is defined using an in-line lambda expression
; that is passed arguments provided at the end of its definition.
  ((LAMBDA (NAME VARS INH-FLAV	  DEF)
      ((SET-DIFFERENCE (REQ-FLAVS!F INH-FLAV) INH-FLAV)
	(BREAK (LIST (EVAL FLAV)
		     (SET-DIFFERENCE (REQ-FLAVS!F INH-FLAV) INH-FLAV))
	       "Missing Required Flavor") )
      (SETQ DEF (INH-VARS!F INH-FLAV))
      (PUT NAME 'PARENT-FLAVORS INH-FLAV)
      ( ((SET-DIFFERENCE VARS DEF 'CAR-EQUAL)
	  (BREAK (LIST (EVAL FLAV)
		       (MAPCAR 'CAR (SET-DIFFERENCE VARS DEF 'CAR-EQUAL)))
		 "Keyword Not Handled") )
	(MAPCAR '(LAMBDA (X) (PUT NAME (CAR X) (CDR X)))
		(UNION DEF VARS 'CAR-EQUAL)) )
      (LIST 'SEND NAME ':INIT) )
    (PACK* (EVAL FLAV) "-I" (INCQ *INSTANCE-COUNT*))
    (PAIRUP!F VARS)
    (INH-INC-FLAVS!F (EVAL FLAV)) ) )


(DEFUN INH-VARS!F (FLAVS)
; returns a list of all the default variables for each flavor in FLAVS.
  (DELETE-DUPLICATES
    (NREVERSE (MAPCAN '(LAMBDA (FLAV) (COPY-LIST (GET FLAV 'INST-VARS)))
		      FLAVS))
    'CAR-EQUAL) )

(DEFUN INH-INC-FLAVS!F (FLAV
; returns a properly ordered list of all the inherited and included flavors
; in the flavor FLAV.  If they are not already in the list, included flavors
; are inserted in the list after the last flavor that specifies that they
; must be included.
    FLAVS NFLAVS)
  (SETQ FLAVS (DELETE-DUPLICATES (NREVERSE (INH-FLAVS!F (LIST FLAV)))))
  (LOOP
    ((NULL FLAVS) NFLAVS)
    ( ((SET-DIFFERENCE (GET (CAR FLAVS) 'INC-FLAVS) (APPEND NFLAVS FLAVS))
	(SETQ FLAVS (UNION (GET (CAR FLAVS) 'INC-FLAVS) FLAVS)) )
      (PUSH (POP FLAVS) NFLAVS) ) ) )

(DEFUN INH-FLAVS!F (FLAVS)
; returns a list of all the inherited flavors for each flavor in FLAVS.
   (MAPCAN '(LAMBDA (FLAV) (CONS FLAV (INH-FLAVS!F (GET FLAV 'INH-FLAVS))))
	   FLAVS) )


(DEFUN REQ-FLAVS!F (FLAVS)
; finds all the required flavors of each flavor in FLAVS and merges them
; with the flavors already specified.
  (UNION (MAPCAN '(LAMBDA (FLAV) (COPY-LIST (GET FLAV 'REQ-FLAVS))) FLAVS)
	 FLAVS) )

(DEFUN PAIRUP!F (VARS
; makes pairs from a list of alternating variable names and
; variable values after putting a colon in front of each variable name.
    NVARS)
  (LOOP
    ((NULL VARS) NVARS)
    (SETQ NVARS (CONS (CONS (IF (CHAR= (CAR VARS) '\:)
				(SUBSTRING (CAR VARS) 1)
				(CAR VARS))
			    (EVAL (CADR VARS)))
		      NVARS)
	  VARS (CDDR VARS))) )

(DEFUN CAR-EQUAL (X Y)		     ;are the CARs of two lists equal
  (EQUAL (CAR X) (CAR Y)))


;		* * *	The Vanilla Flavor   * * *

; Note:  All the VANILLA-FLAVOR methods are inherited by all other flavors
;	 unless specifically told not to in DEFFLAVOR.

; This is the basic :INIT method that is called when an instance of an
; object is created.  It simply returns itself.
(PUT VANILLA-FLAVOR ':INIT '(LAMBDA (SELF) SELF))

(DEFMETHOD (VANILLA-FLAVOR :DESCRIBE) ()
; :DESCRIBE displays a list of all an object's instance variables and their
; associated values, and returns NIL.
  (PRIN1 SELF)
  (WRITE-LINE 
        (PACK* ", an object of flavor " (CAR (GET SELF 'PARENT-FLAVORS))))
  (WRITE-LINE "has instance variable values:")
  (MAPC '(LAMBDA (X) (WRITE-STRING (PACK* "  " (CAR X) ":"))
		     (SPACES (- 24 (SPACES)))
		     (PRINT (CDR X)) )
	(REMOVE 'PARENT-FLAVORS (CDR SELF) 'CAR-EQUAL))
  NIL )

(DEFMETHOD (VANILLA-FLAVOR :WHICH-OPERATIONS) ()
; :WHICH-OPERATIONS returns a list of all an object's methods.
  (DELETE-DUPLICATES
    (REDUCE '(LAMBDA (X Y) (DELETE Y X))
	    '(INST-VARS INH-FLAVS REQ-FLAVS INC-FLAVS)
	     (DELETE-IF 'LISTP
			(MAPCAN '(LAMBDA (X) (MAPCAR 'CAR (CDR X)))
				 (GET SELF 'PARENT-FLAVORS))))) )

(IF (OR (NOT *FLAVOR-DEMO*)
	(PROGN
	  (WRITE-STRING " -- Run window system demo? (Y/N) " T)
	  ((LAMBDA (DEMO)
	      (WRITE-STRING (IF DEMO 'Y 'N) T)
	      (NOT DEMO) )
	    (< (LOOP ((POSITION (READ-BYTE T) '(89 121 78 110)))) 2) ) ) )
    (CLOSE-INPUT-FILE (FIND "FLAVORS.LSP" (INPUT-FILES) 'FINDSTRING)) )


;	      * * *   A Flavors Based Window System   * * *

; The remainder of this file is optional.  It illustrates how to use
; the muLISP Flavors Package to implement a simple windowing system.
; The code is not necessarily meant to be highly efficient or elegant.

(setq *all-windows*)

; This is the basic flavor for a window
(defflavor window (top			; top of the window in rows
		   left 		; left edge of window in columns
		   height		; height in columns
		   width		; width in rows
		   (current-row 0)	; cursor position [row]
		   (current-col 0)	; cursor position [col]
		   (exposedp nil)	; is the window exposed [visible]
		   (border 1)		; width of border around window
		   (border-color 7)	; color of border
		   (foreground 15)	; foreground color of window
		   (background 0))	; background color window
		  ()
		  :gettable-instance-variables
		  :settable-instance-variables)

; After a window is created, add its name to the list of windows
(defmethod (window :after :init) () (push self *all-windows*))

; To expose a window make a window with the edges of the window object and
; set the cursor position to the proper row and column if the window is
; already exposed, otherwise refresh the window.
(defmethod (window :expose) ()
  ((send self :exposedp)
   (make-window (+ top border)
	       (+ left border)
	       (- height (* 2 border))
	       (- width (* 2 border)))
   (set-cursor current-row current-col))
  (send self :refresh))

; This method makes a window of the proper color with a clear screen and
; sets the exposedp variable to true.
(defmethod (window :refresh) ()
  (background-color border-color)
  (foreground-color 0)
  (make-window top left height width)
  (clear-screen)
  (background-color background)
  (foreground-color foreground)
  (make-window (+ top border)
	       (+ left border)
	       (- height (* 2 border))
	       (- width (* 2 border)))
  (clear-screen)
  (setq current-row 0 current-col 0)
  (setq exposedp 't))

; After a window is sent a refresh message check all other windows and if
; they are covered by the new window then deexpose them.
(defmethod (window :after :refresh) (windows)
  (setq windows (remove self *all-windows*))
  (loop
    ((null windows))
    ( ((no-overlap top left height width (car windows))
       (pop windows))
      (send (car windows) :set-exposedp nil)
      (pop windows))))

; Before you can print to a window it must be exposed
(defmethod (window :before :print) (str row column)
  (send self :expose))

; Before you can print to a window it must be exposed
(defmethod (window :before :princ) (str row column)
  (send self :expose))

; Print the str to the row and column of the window
(defmethod (window :print) (str row column)
  (if (and (integerp row) (integerp column))
      (set-cursor row column))
  (print str)
  (setq current-row (row) current-col (column)))   ;reset row and column

; Same as :PRINT
(defmethod (window :princ) (str row column)
  (if (and (integerp row) (integerp column))
      (set-cursor row column))
  (princ str)
  (setq current-row (row) current-col (column)))

; We want to return to the current window after we print out to another
; window so we find the current window dimensions and then reset them
; after we do the :PRINT or :PRINC methods.
(defwhopper (window :print) (str row column   w1 w2 w3 w4 r c)
  (setq r (make-window) w1 (pop r) w2 (pop r) w3 (pop r) w4 (pop r))
  (setq r (row) c (column))
  (if (no-overlap w1 w2 w3 w4 self)
   (continue-whopper str row column))
  (make-window w1 w2 w3 w4)
  (set-cursor r c))

(defwhopper (window :princ) (str row column   w1 w2 w3 w4 r c)
  (setq r (make-window) w1 (pop r) w2 (pop r) w3 (pop r) w4 (pop r))
  (setq r (row) c (column))
  (if (no-overlap w1 w2 w3 w4 self)
   (continue-whopper str row column))
  (make-window w1 w2 w3 w4)
  (set-cursor r c))

; Does a window overlap the box formed by top1 left1 height1 width1
(defun no-overlap (top1 left1 height1 width1 window2)
  ((lambda (top2 left2 height2 width2	 bottom1 bottom2 right1 right2)
	   (setq bottom1 (+ top1 height1) bottom2 (+ top2 height2)
		 right1 (+ left1 width1) right2 (+ left2 width2))
	   ((or (<= top1 top2 bottom1)
		(<= top1 bottom2 bottom1)
		(<= top2 bottom1 bottom2))
	    ((or (<= left1 left2 right1)
		 (<= left1 right2 right1)
		 (<= left2 right1 right2)) nil))
	   't)
  (send window2 :top)
  (send window2 :left)
  (send window2 :height)
  (send window2 :width)))


;---------------------------------------------------------------------------
; Make instances of the WINDOW flavor
(setq small (make-instance 'window
			   :top 2
			   :left 10
			   :height 8
			   :width 60))

(setq tiny (make-instance 'window
			   :top 3
			   :left 30
			   :height 8
			   :width 20
			   :border 2))

(setq main (make-instance 'window
			  :top 12
			  :left 0
			  :height 12
			  :width 80))


(send main :expose)		; Expose the window MAIN

(write-line
   "Try the command (SEND SMALL :PRINC 'HELLO 2 2) or send messages to TINY.")
