;File:	GRAPHICS.LSP  (c)	06/01/87	Soft Warehouse, Inc.


;			The Turtle Graphics Package

; Trigonometric functions

(DEFUN SIN-DEG (ANGLE)
; returns the sine of ANGLE degrees.
  ((MINUSP ANGLE)
    (SETQ ANGLE (DIVIDE (REM (- ANGLE) 360) 45))
    (- (SIN-COS-DEG (CAR ANGLE) (CDR ANGLE))) )
  (SETQ ANGLE (DIVIDE (REM ANGLE 360) 45))
  (SIN-COS-DEG (CAR ANGLE) (CDR ANGLE)) )

(DEFUN COS-DEG (ANGLE)
; returns the cosine of ANGLE degrees.
  (SETQ ANGLE (DIVIDE (REM (ABS ANGLE) 360) 45))
  (SIN-COS-DEG (+ 2 (CAR ANGLE)) (CDR ANGLE)) )

(DEFUN SIN-COS-DEG (N45DEG RESID)
  ((> N45DEG 3)
    (- (SIN-COS-DEG (- N45DEG 4) RESID)) )
  ((ZEROP N45DEG)
    (REDUCED-SIN RESID))
  ((EQ N45DEG 1)
    ((ZEROP RESID) 0.70710678)
    (REDUCED-COS (- 45 RESID)))
  ((EQ N45DEG 2)
    (REDUCED-COS RESID))
  ((ZEROP RESID) 0.70710678)
  (REDUCED-SIN (- 45 RESID)) )

(DEFUN REDUCED-SIN (DEG)
  (/ (* DEG (+ 1324959969 (* (SETQ DEG (* DEG DEG)) (+ -67245 DEG))))
     75914915920) )

(DEFUN REDUCED-COS (DEG)
  (SETQ DEG (* DEG DEG))
  (/ (+ 266153374 (* DEG (+ -40518 DEG)))
     266153374) )


;Turtle graphics primitive commands

(DEFUN DOT (X Y)
; draws a dot at (X,Y) in the turtle coordinate system.
  (PLOT-DOT (+ *X-CENTER* X) (- *Y-CENTER* Y) *COLOR*)
  'NONE )

(DEFUN LINE (X1 Y1 X2 Y2)
; draws a line from (X1,Y1) to (X2,Y2) in the turtle coordinate system.
  (SETQ X1 (+ *X-CENTER* X1)
	Y1 (- *Y-CENTER* Y1)
	X2 (+ *X-CENTER* X2)
	Y2 (- *Y-CENTER* Y2) )
  ( ((MINUSP Y1)
      ((MINUSP Y2)
	(RETURN 'NONE) )
      (SETQ X1 (ROUND (- (* X1 Y2) (* Y1 X2)) (- Y2 Y1))
	    Y1 0) )
    ((MINUSP Y2)
      (SETQ X2 (ROUND (- (* X1 Y2) (* Y1 X2)) (- Y2 Y1))
	    Y2 0) ) )
  ( ((MINUSP X1)
      ((MINUSP X2)
	(RETURN 'NONE) )
      (SETQ Y1 (ROUND (- (* X1 Y2) (* Y1 X2)) (- X1 X2))
	    X1 0) )
    ((MINUSP X2)
      (SETQ Y2 (ROUND (- (* X1 Y2) (* Y1 X2)) (- X1 X2))
	    X2 0) ) )
  (PLOT-LINE X1 Y1 X2 Y2 *COLOR*)
  'NONE )


(DEFUN SETPOS (X Y
; puts the turtle position at (X,Y) in the turtle coordinate system.
    COLOR )
  ((NOT *PENDOWN*)
    (SETQ *X-POS* X
	  *Y-POS* Y) )
  (SETQ COLOR *COLOR*
	*COLOR* 0)
  (DOT *X-POS* *Y-POS*)
  (SETQ *X-POS* X
	*Y-POS* Y
	*COLOR* COLOR)
  (DOT *X-POS* *Y-POS*)
  'NONE )

(MOVD 'SETPOS 'SP)		; Make SP is an abbreviation for SETPOS.

(SETQ *X-POS* 0 *Y-POS* 0)


(DEFUN SETHEADING (ANGLE)
; sets the turtle heading to ANGLE degrees.
  ((NUMBERP ANGLE)
    (SETQ *HEADING* (REM ANGLE 360)) )
  *HEADING* )

(MOVD 'SETHEADING 'SH)

(SETHEADING 0)


(DEFUN SETCOLOR (COLOR
; causes the track of the turtle to colored COLOR.
    MODE)
  ((SETQ MODE (VIDEO-MODE))
    ((<= 4 MODE 5)
      ((SETQ *COLOR* (POSITION COLOR '(BLACK GREEN RED WHITE))))
      (SETCOLOR WHITE) )
    ((= MODE 6)
      ((SETQ *COLOR* (POSITION COLOR '(BLACK WHITE))))
      (SETCOLOR WHITE) )
    ((OR (= MODE 7) (= MODE 15))
      ((SETQ *COLOR* (POSITION COLOR '(BLACK GRAY WHITE))))
      (SETCOLOR WHITE) )
    ((SETQ *COLOR* (POSITION COLOR
		  '(BLACK BLUE GREEN CYAN RED MAGENTA YELLOW WHITE)))
      ((EQ *COLOR* 0))
      (INCQ *COLOR* 8) )
    (SETCOLOR WHITE) ) )

(MOVD 'SETCOLOR 'SC)

(SETCOLOR 'WHITE)


(DEFUN PENDOWN ()
; causes the track of the turtle to be plotted.
  (SETQ *PENDOWN* T)
  'NONE )

(MOVD 'PENDOWN 'PD)

(DEFUN PENUP ()
; causes the track of the turtle not to be plotted.
  (SETQ *PENDOWN* NIL)
  'NONE )

(MOVD 'PENUP 'PU)


(DEFUN CLR ()
; initializes the turtle parameters.
  (PENDOWN)
  (SETHEADING 0)
  (SETCOLOR WHITE)
  (CLEAR-SCREEN)
  (SETPOS 0 0) )


(DEFUN RIGHT (ANGLE)
; turns the turtle right (clockwise) ANGLE degrees.
  ((NUMBERP ANGLE)
    (SETQ *HEADING* (REM (+ *HEADING* ANGLE) 360)) )
  *HEADING* )

(MOVD 'RIGHT 'RT)

(DEFUN LEFT (ANGLE)
; turns the turtle left (counter-clockwise) ANGLE degrees.
  (RIGHT (- ANGLE)) )

(MOVD 'LEFT 'LT)


(DEFUN FORWARD (DISTANCE
; moves the turtle forward DISTANCE pixels.
    X-POS Y-POS )
  (SETQ X-POS *X-POS*
	Y-POS *Y-POS*)
  (INCQ *X-POS* (ROUND (* DISTANCE (SIN-DEG *HEADING*))))
  (INCQ *Y-POS* (ROUND (* DISTANCE (COS-DEG *HEADING*))))
  ((NOT *PENDOWN*))
  (LINE X-POS Y-POS *X-POS* *Y-POS*) )

(MOVD 'FORWARD 'FD)

(DEFUN BACK (DISTANCE)
; moves the turtle backward DISTANCE pixels.
  (FORWARD (- DISTANCE)) )

(MOVD 'BACK 'BK)


;Turtle graphics driver

(SETQ *COMMAND-LINES* 4)

(DEFUN TURTLE (
; implements the turtle graphics read-eval-draw loop.
    COMMAND FULL-WINDOW FIRST-TIME INIT-MODE)
  (SETQ INIT-MODE (VIDEO-MODE)
	FULL-WINDOW (MAKE-WINDOW)
	COMMAND '(CLR)
	FIRST-TIME T
	*X-POS* 0
	*Y-POS* 0)
  ( ((MEMBER INIT-MODE '(0 1))
      (VIDEO-MODE 5) )
    ((MEMBER INIT-MODE '(2 3))
      (VIDEO-MODE 6) ) )
  (UNWIND-PROTECT (LOOP
    ((EQ COMMAND 'QUIT))
    (TURTLE-WINDOW)
    (SETQ COMMAND (CATCH NIL (EVAL COMMAND)))
    (SETPOS *X-POS* *Y-POS*)
    (MAKE-WINDOW (+ (FIRST FULL-WINDOW)
		    (- (THIRD FULL-WINDOW) *COMMAND-LINES*))
		 (SECOND FULL-WINDOW)
		 *COMMAND-LINES* (FOURTH FULL-WINDOW))	;Command window
    (SET-CURSOR (SUB1 *COMMAND-LINES*) 0)
    ( ((NOT FIRST-TIME))
      (CLEAR-SCREEN)
      (WRITE-LINE "Type  QUIT  to return to muLISP.")
      (WRITE-LINE "Try the command  (C-CURVE 8)")
      (SETQ FIRST-TIME NIL) )
    ( ((EQ COMMAND 'NONE))
      (WRITE COMMAND)
      (TERPRI) )
    (WRITE-STRING "Command: ")
    (SETQ COMMAND (READ)) )
  (IF (NEQ INIT-MODE (VIDEO-MODE))
      (VIDEO-MODE INIT-MODE))
  (APPLY 'MAKE-WINDOW FULL-WINDOW) ) )

(DEFUN TURTLE-WINDOW ()
; makes a turtle graphics window.
  (MAKE-WINDOW (FIRST FULL-WINDOW) (SECOND FULL-WINDOW)
	       (- (THIRD FULL-WINDOW) *COMMAND-LINES*) (FOURTH FULL-WINDOW))
  (SCREEN-CENTER) )

(DEFUN SCREEN-CENTER ()
; sets *X-CENTER* and *Y-CENTER* to the center of the screen.
  (SETQ *X-CENTER* (TRUNCATE (FOURTH (MAKE-WINDOW)) 2)
	*Y-CENTER* (TRUNCATE (THIRD (MAKE-WINDOW)) 2))
  ((NOT (VIDEO-MODE)))
  ((OR (<= 4 (VIDEO-MODE) 6) (<= 8 (VIDEO-MODE) 14))
    (SETQ *X-CENTER* (* 8 *X-CENTER*)
	  *Y-CENTER* (* 8 *Y-CENTER*)) )
  ((>= (VIDEO-MODE) 15)
    (SETQ *X-CENTER* (* 8 *X-CENTER*)
	  *Y-CENTER* (* 14 *Y-CENTER*)) ) )

(SCREEN-CENTER)


;Sample turtle graphics functions

(DEFUN POLY (SIDE ANGLE
; draws a polygon.
    TOT-TURN)
  (SETQ TOT-TURN 0)
  (LOOP
    (FORWARD SIDE)
    (RIGHT ANGLE)
    (SETQ TOT-TURN (REM (+ TOT-TURN ANGLE) 360))
    ((ZEROP TOT-TURN)) ) )

(DEFUN CORNER-POLY (SIDE ANGLE
; draws a "corner" polygon.
    TOT-TURN)
  ((> SIDE 1)
    (SETQ TOT-TURN 0)
    (LOOP
      (FORWARD SIDE)
      (CORNER-POLY (SHIFT SIDE -2) (- ANGLE))
      (RIGHT ANGLE)
      (SETQ TOT-TURN (REM (+ TOT-TURN ANGLE) 360))
      ((ZEROP TOT-TURN)) ) ) )

(DEFUN SPIRAL (SIDE ANGLE INCR)
; draws a spiral.
  (LOOP
    ((< SIDE INCR))
    (FORWARD SIDE)
    (RIGHT ANGLE)
    (DECQ SIDE INCR) ) )

(DEFUN SPIROLAT (SIDE ANGLE INCR
; draws a spirolateral.
    TOT-TURN)
  (SETQ TOT-TURN 0)
  (LOOP
     (SPIRAL SIDE ANGLE INCR)
     (SETQ TOT-TURN (REM (+ TOT-TURN (* ANGLE (TRUNCATE SIDE INCR))) 360))
     ((ZEROP TOT-TURN)) ) )

(SETQ *LENGTH* 3)

(DEFUN C-CURVE (DEPTH)
; draws a "C" curve.
  ((ZEROP DEPTH)
    (FORWARD *LENGTH*) )
  (RIGHT 45)
  (C-CURVE (SUB1 DEPTH))
  (RIGHT -90)
  (C-CURVE (SUB1 DEPTH))
  (RIGHT 45) )

(DEFUN D-CURVE (DEPTH FLAG)
; draws a "Dragon" curve.
  ((ZEROP DEPTH)
    (FORWARD *LENGTH*) )
  (IF FLAG (RIGHT 45) (RIGHT -45))
  (D-CURVE (SUB1 DEPTH) T)
  (IF FLAG (RIGHT -90) (RIGHT 90))
  (D-CURVE (SUB1 DEPTH) NIL)
  (IF FLAG (RIGHT 45) (RIGHT -45)) )

(TERPRI)
(WRITE-LINE "To run turtle graphics enter:  (TURTLE)")
