; File: STRUCTUR.LSP  (C)	02/13/87	Soft Warehouse, Inc.


;			The muLISP Structure Package

; COMMON.LSP must be loaded to use the facilities provided by this file.

; This file provides a structure facility patterned after Common LISP
; (see Chapter 19 of Common LISP, The Language Steele [1984]).


(DEFMACRO DEFSTRUCT (STRUCTSPEC . SLOTSPECS)
; Creates a new structure.
  (LIST 'DEFSTRUCT-AUX
	(LIST 'QUOTE STRUCTSPEC)
	(LIST 'QUOTE SLOTSPECS)) )

(DEFUN DEFSTRUCT-AUX (STRUCTSPEC SLOTSPECS)
  (LET* ((name (GET-STRUCT-NAME STRUCTSPEC))
	 (options (GET-STRUCT-OPTIONS name STRUCTSPEC))
	 (slotnams (GET-STRUCT-SLOT-NAMES name SLOTSPECS))
	 (slotvals (GET-STRUCT-SLOT-VALUES name SLOTSPECS))
	 (named? (OR (ASSOC ':NAMED options)
		     (NOT (ASSOC ':TYPE options))) ) )
    (LET ((istruct (ASSOC ':INCLUDE options)) )
      ((CHECK-INCLUDED-STRUCT name istruct named?)
	(SETQ slotnams
	      (APPEND (GET (CADR istruct) 'STRUCT-SLOTNAMES)
		      slotnams))
	(SETQ slotvals
	      (MAPCAR '(LAMBDA (SNAM SVAL)
			   ((CADR (ASSOC SNAM (CDDR istruct))) )
			   SVAL)
		      slotnams
		      (APPEND (GET (CADR istruct) 'STRUCT-SLOTVALS)
			      slotvals))) ) )
    (PUTSTRUCT name options slotnams slotvals named?
	(CHECK-STRUCT-MACDEFS name
	    (APPEND (FORM-STRUCT-CONSTRUCTORS name options slotnams
					      slotvals named?)
		    (FORM-STRUCT-ACCESSORS name options slotnams
					   named?)
		    (FORM-STRUCT-PREDICATE name options named?)
		    (FORM-STRUCT-COPIER name options)))) ) )


(DEFUN GET-STRUCT-NAME (STRUCTSPEC)
; Extracts and returns the structure name specification from STRUCTSPEC,
; verifying that it is a symbol.
  (LET ((stnam (IF (CONSP STRUCTSPEC) (CAR STRUCTSPEC) STRUCTSPEC) ) )
    ((SYMBOLP stnam) stnam)
    (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS) "Nonsymbolic Argument") ) )

(DEFUN GET-STRUCT-OPTIONS (NAME STRUCTSPEC)
; Extracts the structure option specifications from STRUCTSPEC, verifying
; that each is a supported option.  Collects and returns the options in
; a uniform "a-list" format.
  ((ATOM STRUCTSPEC) NIL)
  (MAPCAR '(LAMBDA (OPT)
	       (LET ((optnam (IF (CONSP OPT) (CAR OPT) OPT) ) )
		 ((AND (SYMBOLP optnam)
		       (MEMBER optnam '(:CONC-NAME :CONSTRUCTOR :COPIER
				 :PREDICATE :INCLUDE :TYPE :NAMED)) )
		   (CONS optnam (IF (CONSP OPT) (CDR OPT))) )
		 (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
			"Unsupported Option") ) )
	  (CDR STRUCTSPEC)) )

(DEFUN GET-STRUCT-SLOT-NAMES (NAME SLOTSPECS)
; Extracts the structure slot names from SLOTSPECS, verifying that each
; is a symbol.	Returns a list of the slot names.
  (MAPCAR '(LAMBDA (SLOT)
	       (LET ((snam (IF (CONSP SLOT) (CAR SLOT) SLOT)) )
		 ((SYMBOLP snam) snam)
		 (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
			"Nonsymbolic Argument") ) )
	  SLOTSPECS) )

(DEFUN GET-STRUCT-SLOT-VALUES (NAME SLOTSPECS)
; Extracts the structure slot values from SLOTSPECS, supplying NIL as
; the value for any slot without a specified value.  Returns a list of
; the slot values.
  (MAPCAR '(LAMBDA (SLOT) (IF (CONSP SLOT) (CADR SLOT)))
	  SLOTSPECS) )


(DEFUN CHECK-INCLUDED-STRUCT (NAME ISTRUCT NAMED?)
; Checks that the (:INCLUDE ...) option ISTRUCT (if any) specifies a
; valid, previously defined structure which is compatible with the
; structure being defined.
  ((NULL ISTRUCT) NIL)
  (LET ((iname (CADR ISTRUCT)) )
    ((GET iname 'STRUCT-MACROS)
      ((GET iname 'NAMED-STRUCT)
	((IDENTITY NAMED?) T)
	(BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	       "Include Error") )
      ((NOT NAMED?) T)
      (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	     "Include Error") )
    (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	   "Undefined Structure") ) )

(DEFUN CHECK-STRUCT-MACDEFS (NAME MACDEFS)
; Checks that each MACRO (<name> . <definition>) pair in the list
; MACDEFS will NOT cause an incompatible redefinition of an existing
; function.
  (MAPCAR '(LAMBDA (MACDEF)
	       ((OR (NULL (GETD (CAR MACDEF) T))
		    (EQUAL (GETD (CAR MACDEF)) (CDR MACDEF)) )
		  MACDEF)
	       (IF (NULL (GET (CAR MACDEF) 'STRUCTS))
		   (PUT (CAR MACDEF) 'STRUCTS (CONS)) )
	       ((NULL (REMOVE NAME (GET (CAR MACDEF) 'STRUCTS)))
		  MACDEF)
	       (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
		      "Incompatible Definition") )
	MACDEFS) )


(DEFUN FORM-STRUCT-CONSTRUCTORS (NAME OPTIONS SLOTNAMS SLOTVALS NAMED?)
; Formulates constructor functions as MACROs for the structure NAME in
; accordance with OPTIONS, SLOTNAMS, SLOTVALS, and NAMED?.  Returns a
; list of constructor function (<name> . <definition>) pairs (or NIL
; if no constructor functions were desired).
  (LET ((consopt (ASSOC ':CONSTRUCTOR OPTIONS)) )
    ((NULL consopt)
      (LIST (CONS (PACK* 'MAKE- NAME)
		  (STRUCT-KEYWORD-CONSTRUCTOR NAME SLOTNAMS SLOTVALS
			NAMED?))) )
    (MAPCAN '(LAMBDA (OPT)
		 ((EQ (CAR OPT) ':CONSTRUCTOR)
		   ((NULL (CDR OPT))
		     (LIST (CONS (PACK* 'MAKE- NAME)
				 (STRUCT-KEYWORD-CONSTRUCTOR NAME
				       SLOTNAMS SLOTVALS NAMED?))) )
		   ((NULL (CADR OPT)) )
		   ((NULL (CDDR OPT))
		     (LIST (CONS (CADR OPT)
				 (STRUCT-KEYWORD-CONSTRUCTOR NAME
				       SLOTNAMS SLOTVALS NAMED?))) )
		   (LIST (CONS (CADR OPT)
			       (STRUCT-POSITIONAL-CONSTRUCTOR NAME
				     SLOTNAMS SLOTVALS (CADDR OPT)
				     NAMED?))) ) )
	    OPTIONS) ) )

(DEFUN STRUCT-KEYWORD-CONSTRUCTOR (NAME SLOTNAMS SLOTVALS NAMED?)
; Formulates a keyword constructor function as a MACRO for the structure
; NAME in accordance with SLOTNAMS, SLOTVALS, and NAMED?.  Returns the
; definition for the constructor.
  (LIST 'MACRO
	'SLOTSPECS
	(APPEND '(LIST* 'LIST)
		(IF NAMED? (LIST (LIST 'QUOTE (LIST 'QUOTE NAME))))
		(LIST (LIST 'MAPCAR
			    ''(LAMBDA (SNAM SVAL)
				  (LET ((spec (MEMBER (PACK* '":" SNAM)
						      SLOTSPECS)) )
				    ((NULL spec) SVAL)
				    (CADR spec) ) )
			    (LIST 'QUOTE SLOTNAMS)
			    (LIST 'QUOTE SLOTVALS) ) ) ) ) )

(DEFUN STRUCT-POSITIONAL-CONSTRUCTOR (NAME SLOTNAMS SLOTVALS ARGS NAMED?)
; Formulates a positional constructor as a MACRO for the structure NAME
; in accordance with SLOTNAMS, SLOTVALS, ARGS, and NAMED?.  Returns the
; definition for the constructor.
  (LIST 'MACRO
	'BODY
	(APPEND '(LIST 'LIST)
		(IF NAMED? (LIST (LIST 'QUOTE (LIST 'QUOTE NAME))))
		(MAPCAR '(LAMBDA (SNAM SVAL)
			     ((MEMBER SNAM ARGS)
			       (LIST 'NTH
				     (ADD1 (POSITION SNAM ARGS))
				     'BODY) )
			     SVAL)
			SLOTNAMS
			SLOTVALS) ) ) )

(DEFUN FORM-STRUCT-ACCESSORS (NAME OPTIONS SLOTNAMS NAMED?)
; Formulates accessor functions as MACROs for the structure NAME in
; accordance with OPTIONS, SLOTNAMS, and NAMED?.  Returns a list of
; accessor function  (<name> . <definition>) pairs.
  (LET ((namopt (ASSOC ':CONC-NAME OPTIONS)) )
    (LET ((prefix (COND ((OR (NULL namopt)
			     (NULL (CDR namopt)) )
			  (PACK* NAME '"-") )
			((NULL (CADR namopt)) '"")
			((CADR namopt)) ) )
	  (slotpsn (IF NAMED? 1 0)) )
      (MAPCAR '(LAMBDA (SNAM)
		  (CONS (PACK* prefix SNAM)
			(LIST 'MACRO 'BODY
			      (LIST 'LIST ''NTH slotpsn (LIST 'CADR 'BODY)))
			(INCQ slotpsn)) )
	      SLOTNAMS) ) ) )

(DEFUN FORM-STRUCT-PREDICATE (NAME OPTIONS NAMED?)
; Formulates a predicate function as a MACRO for the structure NAME in
; accordance with OPTIONS and NAMED?.  Returns a list consisting of the
; predicate function (<name> . <definition>) pair (or NIL if no predicate
; function was desired).
  (LET ((predopt (ASSOC ':PREDICATE OPTIONS)) )
    ((NOT NAMED?)
      ((OR (NULL predopt)
	   (AND (CDR predopt)
		(NULL (CADR predopt)) ) ) )
      (BREAK (LIST* 'DEFSTRUCT STRUCTSPEC SLOTSPECS)
	     "Unnamed Structure") )
    ((OR (NULL predopt)
	 (NULL (CDR predopt))
	 (CADR predopt))
      (LIST (CONS (IF (OR (NULL predopt) (NULL (CDR predopt)))
		      (PACK* NAME '"-P")
		      (CADR predopt) )
		  (LIST 'MACRO
			'BODY
			(LIST 'LIST
			      ''EQ
			      (LIST 'LIST
				    ''CAR
				    (LIST 'CADR 'BODY))
			      (LIST 'QUOTE (LIST 'QUOTE NAME)))) ) ) ) ) )

(DEFUN FORM-STRUCT-COPIER (NAME OPTIONS)
; Formulates a copier function as a MACRO for the structure NAME in
; accordance with OPTIONS.  Returns a list consisting of the copier
; function (<name> . <definition>) pair (or NIL if no copier function
; was desired).
  (LET ((copyopt (ASSOC ':COPIER OPTIONS)) )
    ((OR (NULL copyopt)
	 (NULL (CDR copyopt))
	 (CADR copyopt))
      (LIST (CONS (IF (OR (NULL copyopt) (NULL (CDR copyopt)))
		      (PACK* 'COPY- NAME)
		      (CADR copyopt) )
		  (LIST 'MACRO
			'BODY
			(LIST 'LIST
			      ''COPY-LIST
			      (LIST 'CADR 'BODY)) ) ) ) ) ) )


(DEFUN PUTSTRUCT (NAME OPTIONS SLOTNAMS SLOTVALS NAMED? MACDEFS)
; Installs the structure NAME.
  (IF (GET NAME 'STRUCT-MACROS) (REMSTRUCT NAME) )
  (PUT NAME 'STRUCT-OPTIONS OPTIONS)
  (PUT NAME 'STRUCT-SLOTNAMES SLOTNAMS)
  (PUT NAME 'STRUCT-SLOTVALS SLOTVALS)
  (PUT NAME 'NAMED-STRUCT NAMED?)
  (PUT NAME 'STRUCT-MACROS
       (MAPCAR '(LAMBDA (MACDEF)
		    (PUT (CAR MACDEF) 'STRUCTS
			 (CONS NAME (GET (CAR MACDEF) 'STRUCTS)))
		    (PUTD (CAR MACDEF) (CDR MACDEF)) )
	       MACDEFS))
  NAME )

(DEFUN REMSTRUCT (NAME)
; Removes the structure NAME.
  (REMPROP NAME 'STRUCT-OPTIONS)
  (REMPROP NAME 'STRUCT-SLOTNAMES)
  (REMPROP NAME 'STRUCT-SLOTVALS)
  (REMPROP NAME 'NAMED-STRUCT)
  (MAPC '(LAMBDA (MACDEF)
	     (LET ((sts (REMOVE NAME (GET MACDEF 'STRUCTS))) )
	       ((NULL sts)
		 (REMPROP MACDEF 'STRUCTS)
		 (REMD MACDEF) )
	       (PUT MACDEF 'STRUCTS sts) ) )
	(GET NAME 'STRUCT-MACROS) )
  (REMPROP NAME 'STRUCT-MACROS) )
