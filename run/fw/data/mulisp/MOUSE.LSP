; File:  MOUSE.LSP		02/17/87	Soft Warehouse, Inc.


;		   The muLISP Mouse Interface Package

; This file requires that the Microsoft Mouse hardware and software be
; properly installed.  The mouse status functions automatically update
; the following global variables:

; *MOUSE-X*	    the vertical mouse position
; *MOUSE-Y*	    the horizontal mouse position
; *LEFT-BUTTON*     T if and only if left button pressed
; *RIGHT-BUTTON*    T if and only if right button pressed


(DEFUN MOUSE-RESET ()
; resets mouse parameters and returns T if mouse is properly installed.
  (REGISTER 0 0)
  (INTERRUPT 51)
  ((ZEROP (REGISTER 0)) NIL)
  (SETQ *MOUSE-X* 320
	*MOUSE-Y* 100)
  'T )


(DEFUN SHOW-MOUSE ()
; displays mouse cursor.
  (REGISTER 0 1)
  (INTERRUPT 51) )

(DEFUN HIDE-MOUSE ()
; hides mouse cursor.
  (REGISTER 0 2)
  (INTERRUPT 51) )


(DEFUN MOUSE-POSITION (X Y)
; returns or sets current mouse cursor position.
  ((AND (INTEGERP X) (>= X 0)
	(INTEGERP Y) (>= Y 0))
    (REGISTER 0 4)
    (REGISTER 2 X)
    (REGISTER 3 Y)
    (INTERRUPT 51) )
  (REGISTER 0 3)
  (INTERRUPT 51)
  (SETQ *MOUSE-X* (REGISTER 2)
	*MOUSE-Y* (REGISTER 3)) )


(DEFUN MOUSE-STATUS ()
; returns current button status.
  (REGISTER 0 3)
  (INTERRUPT 51)
  (SETQ *LEFT-BUTTON* (ODDP (REGISTER 1))
	*RIGHT-BUTTON* (ODDP (SHIFT (REGISTER 1) -1))) )


(DEFUN BUTTON-PRESSES (BUTTON)
; returns button presses since last called.
  (BUTTON-INFO 5) )

(DEFUN BUTTON-RELEASES (BUTTON)
; returns button releases since last called.
  (BUTTON-INFO 6) )

(DEFUN BUTTON-INFO (NUM)
  (REGISTER 0 NUM)
  (REGISTER 1 (IF (EQ BUTTON 'LEFT) 0 1))
  (INTERRUPT 51)
  (SETQ *LEFT-BUTTON* (ODDP (REGISTER 0))
	*RIGHT-BUTTON* (ODDP (SHIFT (REGISTER 0) -1))
	*MOUSE-ROW* (REGISTER 3)
	*MOUSE-COL* (REGISTER 2))
  (REGISTER 1) )


(DEFUN MOUSE-BOX (X1 Y1 X2 Y2)
; limits the mouse cursor to the box (X1,Y1) by (X2,Y2).
  (REGISTER 0 7)
  (REGISTER 2 X1)
  (REGISTER 3 X2)
  (INTERRUPT 51)
  (REGISTER 0 8)
  (REGISTER 2 Y1)
  (REGISTER 3 Y2)
  (INTERRUPT 51) )
