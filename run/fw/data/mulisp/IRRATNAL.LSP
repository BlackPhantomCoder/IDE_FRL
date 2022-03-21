; File: IRRATNAL.LSP  (C)	03/09/87	Soft Warehouse, Inc.


(DEFUN ROUND/ (NMB1 NMB2
    *EXACT-MODE* )
  (/ NMB1 NMB2) )

; Section 5.12.5:  Irrational and Transcendental Functions

(SETQ *GRAPHING* NIL)
(SETQ *PRECISION* 16)

;(GET-CONSTANT symbol form) returns the approximate value of the constant
;<symbol> accurate to the current precision.

(DEFUN GET-CONSTANT (CONSTANT FORM)
  ((EQL (PRECISION) (GET CONSTANT 'PRECISION))
    (EVAL CONSTANT) )
  (SET CONSTANT
	(IF (AND (GET CONSTANT 'PRECISION)
		 (< (PRECISION) (GET CONSTANT 'PRECISION)))
	    (ROUND/ (NUMERATOR (EVAL CONSTANT)) (DENOMINATOR (EVAL CONSTANT)))
	    (EVAL FORM) ))
  (PUT CONSTANT 'PRECISION (PRECISION))
  (EVAL CONSTANT) )


;If N is a number, (EXP N) returns e^N accurate to the current precision.

(DEFUN EXP (N
    Q)
  ((NUMBERP N)
    ((ZEROP N) 1)
    ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
      ((MINUSP N)
	(/ 1 (EXP (- N))) )
      ((= N 1)
	(GET-CONSTANT '*E* '(EXP-AUX 1)) )
      ((> N 1)
	(SETQ Q (DIVIDE (NUMERATOR N) (DENOMINATOR N)))
	(* (EXPT (GET-CONSTANT '*E* '(EXP-AUX 1)) (CAR Q))
	   (EXP-AUX (/ (CDR Q) (DENOMINATOR N)))) )
      (EXP-AUX N) )
    (EXPTRAP N "Exact Mode") )
  (EXPTRAP N "Nonnumeric Argument") )

(PROGN
  ((GETD 'EXPTRAP T))
  (DEFUN EXPTRAP (N MSG)
    (BREAK (LIST 'EXP N) MSG) ) )


;If 0 < N <= 1, (EXP-AUX N) returns e^N accurate to the current precision.
;Basis:  e^(p/q) = ((...(((q+p)2q+p^2)3q+p^3)4q+...+p^(m-1))mq + p^m)/(m! q^m)

(DEFUN EXP-AUX (N
    P Q M TERM NUMR DENR PRECISION BITS)
  (SETQ PRECISION (+ (* *PRECISION* (PRECISION)) 12) ;(12=accurate, 7=fast)
	M 1
	P (NUMERATOR N)
	Q (DENOMINATOR N)
	TERM P
	NUMR (+ P Q)
	DENR Q)
  (LOOP
    (INCQ M)
    (SETQ TERM (* P TERM)
	  NUMR (+ TERM (* Q NUMR M))
	  DENR (* Q DENR M)
	  BITS (- PRECISION (INTEGER-LENGTH DENR)))
    ( ((MINUSP BITS)
	(SETQ TERM (SHIFT TERM BITS)
	      DENR (SHIFT DENR BITS)
	      NUMR (SHIFT NUMR BITS)) ) )
    ((ZEROP TERM)
      (ROUND/ NUMR DENR) ) ) )


;If M and N are integers, M > 0, and N > 1, (IROOT M N) returns M^(1/N)
;rounded to the nearest integer.

(DEFUN IROOT (M N
    NM1 SHIFT PWR INC UPBND ANS)
  (SETQ ANS 1
	INC 1
	NM1 (- N 1)
	UPBND M
	SHIFT (* (- (TRUNCATE (SUB1 (INTEGER-LENGTH M)) N)) N))
  (LOOP 			;Newton's method with 1-bit precision
    ((ZEROP SHIFT))
    (SETQ ANS (SHIFT ANS INC)
	  SHIFT (+ SHIFT (* N INC))
	  PWR (EXPT-AUX ANS NM1)
	  ANS (+ ANS (FLOOR (- (SHIFT M SHIFT) (* PWR ANS)) (* N PWR)))
	  INC (MIN (SHIFT INC 1) (TRUNCATE (- SHIFT) N))) )
  (LOOP 			;Newton's method at full precision
    (SETQ PWR (EXPT-AUX ANS NM1)
	  INC (FLOOR (- M (* PWR ANS)) (* N PWR)))
    ((OR (ZEROP INC) (< N 4))
      (+ ANS INC) )		;Square & cube roots already converged
    ( ((PLUSP INC)
	(SETQ SHIFT ANS) )
      (SETQ UPBND ANS) )
    ((<= UPBND (SETQ ANS (+ ANS INC)))
      (ROUND (+ UPBND SHIFT) 2) )
    ((<= ANS SHIFT)
      (ROUND (+ UPBND SHIFT) 2) ) ) )


;If M and N are integers, M > 0, and N > 1, (RROOT M N) returns M^(1/N)
;accurate to the current precision.

(DEFUN RROOT (M N
    PRECISION)
  (SETQ PRECISION (MAX 0 (- (+ (* *PRECISION* (PRECISION)) 7) ;7=acc, 5=fast
			    (TRUNCATE (INTEGER-LENGTH M) N))))
  (ROUND/ (IROOT (SHIFT M (* N PRECISION)) N) (SHIFT 1 PRECISION)) )


;If M and N are numbers, (EXPT M N) returns M^N accurate to current precision.

(DEFUN EXPT (M N)
  ((EQ M 1) 1)
  ((NUMBERP N)
    ((ZEROP N) 1)
    ((= N 1) M)
    ((MINUSP N)
      (/ 1 (EXPT M (- N))) )
    ((NUMBERP M)
      ((ZEROP M) 0)
      (EXPT-AUX M N) )
    (EXPTTRAP M N "Nonnumeric Argument") )
  (EXPTTRAP M N "Nonnumeric Argument") )


;If N > 0, (EXPT-AUX M N) returns M^N.	If N is a ratio the result may
;be only an approximation to M^N accurate to the current precision.

(SETQ ^NUMBER 15)				;???

(DEFUN EXPT-AUX (M N
    NUM DEN ANS NUMR DENR PRECISION BITS)
  ((ZEROP M) 0) 				;???
  ((INTEGERP N)
    ((MINUSP M)
      ((= M -1)
	((EVENP N) 1)
	-1 )
      (* (EXPT-AUX -1 N) (EXPT-AUX (- M) N)) )
    ((INTEGERP M)
      (SETQ ANS 1)
      (LOOP
	( ((ODDP N)
	    (SETQ ANS (* M ANS)) ) )
	((ZEROP (SETQ N (SHIFT N -1))) ANS)
	(SETQ M (* M M)) ) )
    ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
      ((< (NUMERATOR M) (DENOMINATOR M))
	(/ 1 (EXPT-AUX (/ 1 M) N)) )
      (SETQ NUM (NUMERATOR M)
	    DEN (DENOMINATOR M)
	    NUMR 1
	    DENR 1
	    PRECISION (+ (* *PRECISION* (PRECISION)) 18));18=accurate,13=fast
      (LOOP		;Binary method with intermediate shift rounding.
	( ((ODDP N)
	    (SETQ NUMR (* NUM NUMR)
		  DENR (* DEN DENR)
		  BITS (- PRECISION (INTEGER-LENGTH DENR)))
	    ((MINUSP BITS)
	      (SETQ DENR (SHIFT DENR BITS)
		    NUMR (SHIFT NUMR BITS)) ) ) )
	((ZEROP (SETQ N (SHIFT N -1)))
	  (ROUND/ NUMR DENR) )
	(SETQ NUM (* NUM NUM)
	      DEN (* DEN DEN)
	      BITS (- PRECISION (INTEGER-LENGTH DEN)))
	( ((MINUSP BITS)
	    (SETQ NUM (SHIFT NUM BITS)
		  DEN (SHIFT DEN BITS)) ) ) ) )
    (/ (EXPT-AUX (NUMERATOR M) N) (EXPT-AUX (DENOMINATOR M) N)) )
  ((> N 1)
    (* (EXPT-AUX M (CAR (SETQ BITS (DIVIDE (NUMERATOR N) (DENOMINATOR N)))))
       (EXPT-AUX M (/ (CDR BITS) (DENOMINATOR N)))) )
  ((MINUSP M)
    ((AND (ODDP (DENOMINATOR N))
	  (= (SETQ BITS (EXPT-AUX (- (NUMERATOR M)) (NUMERATOR N)))
	     (EXPT-AUX (SETQ NUMR (IROOT BITS (DENOMINATOR N)))
		       (DENOMINATOR N)))
	  (= (SETQ BITS (EXPT-AUX (DENOMINATOR M) (NUMERATOR N)))
	     (EXPT-AUX (SETQ DENR (IROOT BITS (DENOMINATOR N)))
		       (DENOMINATOR N))))
      (/ (* (EXPT-AUX -1 (NUMERATOR N)) NUMR) DENR) )
    ((IDENTITY *GRAPHING*)
      (THROW "Invalid Argument") )
    (EXPTTRAP M N "Invalid Argument") )
  ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
    ((> N (/ 1 2))
      (/ M (EXPT-AUX M (- 1 N))) )
    ((> (+ (SHIFT (NUMERATOR N) 1) (DENOMINATOR N)) ^NUMBER)
      (EXP (* N (LN M))) )
    ((INTEGERP M)
      (RROOT (EXPT-AUX M (NUMERATOR N)) (DENOMINATOR N)) )
    (/ (RROOT (EXPT-AUX (NUMERATOR M) (NUMERATOR N)) (DENOMINATOR N))
       (RROOT (EXPT-AUX (DENOMINATOR M) (NUMERATOR N)) (DENOMINATOR N))) )
  ((AND (= (SETQ BITS (EXPT-AUX (NUMERATOR M) (NUMERATOR N)))
	   (EXPT-AUX (SETQ NUMR (IROOT BITS (DENOMINATOR N)))
		     (DENOMINATOR N)))
	(= (SETQ BITS (EXPT-AUX (DENOMINATOR M) (NUMERATOR N)))
	   (EXPT-AUX (SETQ DENR (IROOT BITS (DENOMINATOR N)))
		     (DENOMINATOR N))))
    (/ NUMR DENR) )
  (EXPTTRAP M N "Exact Mode") )

(PROGN
  ((GETD EXPTTRAP T))
  (DEFUN EXPTTRAP (N M MSG)
    (BREAK (LIST 'EXPT N M) MSG) ) )


;If M and N are positive numbers, (LOG M N) returns the log of M to base N.
;N defaults to e, the base of the natural logarithms.

(DEFUN LOG (M N)
  (SETQ M (LN M))
  ((NULL N) M)
  ((ZEROP N) 0)
  (/ M (LN N)) )


;If N is a positive number, (LN N) returns the natural log of N.

(DEFUN LN (N)
  ((NUMBERP N)
    ((PLUSP N)
      ((= N 1) 0)
      ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
	((= N 2)
	  (GET-CONSTANT '*LN2* '(LN-AUX 2)) )
	(LN-AUX N) )
      (LNTRAP N "Exact Mode") )
    ((IDENTITY *GRAPHING*)
      (THROW "Invalid Argument") )
    (LNTRAP N "Invalid Argument") )
  (LNTRAP N "Nonnumeric Argument") )

(PROGN
  ((GETD 'LNTRAP T))
  (DEFUN LNTRAP (N MSG)
    (BREAK (LIST 'LN N) MSG) ) )


;If N > 0, (LN-AUX N) returns ln N accurate to the current precision.
;Basis:  If p/q = (x-1)/(x+1) = u, then
;  ln x = 2 (u + u^3/3 + u^5/5 + ... + u^m/m)
;	= (...(((6pq^2 + 2p^3)5q^2 + 2 3p^5)7q^2 + 2 3 5p^7)9q^2 +
;		... + 2 3 5 ... (m-2)p^m) / (3 5 ... m q^m)

(DEFUN LN-AUX (N
    P Q PLEN QLEN SHIFT M TERM NUMR DENR PRECISION BITS)
  ((< (NUMERATOR N) (DENOMINATOR N))
    (- (LN-AUX (/ 1 N))) )
  (SETQ PRECISION (+ (* *PRECISION* (PRECISION)) 12) ;12=accurate,10=fast
	SHIFT 0)
  ( ((= N 2))
    (SETQ P (NUMERATOR N)
	  Q (DENOMINATOR N)
	  PLEN (INTEGER-LENGTH P)
	  QLEN (INTEGER-LENGTH Q))
    ((> PLEN QLEN)			;Make  3/4 < N <= 3/2
      ((> (SHIFT P 1) (* 3 Q))
	(SETQ SHIFT (- PLEN QLEN))
	((> PLEN PRECISION)
	  (SETQ P (SHIFT P (- PRECISION PLEN))
		Q (SHIFT Q (- PRECISION QLEN)))
	  ((> (SHIFT P 1) (* 3 Q))
	    (SETQ SHIFT (ADD1 SHIFT)
		  N (/ P (SHIFT Q 1))) )
	  ((< (SHIFT P 2) (* 3 Q))
	    (SETQ SHIFT (SUB1 SHIFT)
		  N (/ P (SHIFT Q -1))) )
	  (SETQ N (/ P Q)) )
	((> (SHIFT P 1) (* 3 (SETQ Q (SHIFT Q SHIFT))))
	  (SETQ SHIFT (ADD1 SHIFT)
		N (/ P (SHIFT Q 1))) )
	((< (SHIFT P 2) (* 3 Q))
	  (SETQ SHIFT (SUB1 SHIFT)
		N (/ P (SHIFT Q -1))) )
	(SETQ N (/ P Q)) ) )
    ((> (SHIFT P 1) (* 3 Q))
      (SETQ SHIFT 1
	    N (/ P (SHIFT Q 1))) ) )
  (SETQ N (/ (- (NUMERATOR N) (DENOMINATOR N))
	     (+ (NUMERATOR N) (DENOMINATOR N)))
	PLEN (* N N)
	P (NUMERATOR PLEN)
	Q (DENOMINATOR PLEN)
	NUMR (SHIFT (NUMERATOR N) 1)
	TERM NUMR
	DENR (DENOMINATOR N)
	PRECISION (- PRECISION (INTEGER-LENGTH SHIFT))
	M 1)
  (LOOP
    (SETQ TERM (* M TERM P)
	  M (+ M 2)
	  NUMR (+ TERM (* NUMR Q M))
	  DENR (* M Q DENR)
	  BITS (- PRECISION (INTEGER-LENGTH NUMR)))
    ( ((MINUSP BITS)
	(SETQ TERM (SHIFT TERM BITS)
	      NUMR (SHIFT NUMR BITS)
	      DENR (SHIFT DENR BITS)) ) )
    ((ZEROP TERM)
      ((ZEROP SHIFT)
	(ROUND/ NUMR DENR) )
      (+ (* SHIFT (GET-CONSTANT '*LN2* '(LN-AUX 2))) (ROUND/ NUMR DENR)) ) ) )


;If n is positive, (SQRT n) returns square root of n.

(DEFUN SQRT (N)
  (EXPT N 1/2) )


;If n is a nonnegative integer, (ISQRT n) returns the greatest integer
;less than or equal to the positive square root of n.

(DEFUN ISQRT (N)
  ((INTEGERP N)
    ((>= N 0)
      ((ZEROP N) 0)
      (ISQRT-AUX N) )
    ((IDENTITY *GRAPHING*)
      (THROW "Invalid Argument") )
    (ISQRTTRAP N "Invalid Argument") )
  (ISQRTTRAP N "Noninteger Argument") )

(PROGN
  ((GETD 'ISQRTTRAP T))
  (DEFUN ISQRTTRAP (N MSG)
    (BREAK (LIST 'ISQRT N) MSG) ) )


;If n is a positive integer, (ISQRT-AUX n) returns the greatest integer
;less than or equal to n^(1/2).  ISQRT-AUX uses Newton's method.

(DEFUN ISQRT-AUX (N
    SHIFT INC ANS)
  (SETQ ANS 1
	INC 1
	SHIFT (* (- (TRUNCATE (SUB1 (INTEGER-LENGTH N)) 2)) 2))
  (LOOP 	;Start with 1-bit precision & repeatedly doubling
    ((ZEROP SHIFT))
    (SETQ ANS (SHIFT ANS INC)
	  SHIFT (+ SHIFT (SHIFT INC 1))
	  ANS (+ ANS (FLOOR (- (SHIFT N SHIFT) (* ANS ANS)) (* 2 ANS)))
	  INC (MIN (SHIFT INC 1) (TRUNCATE (- SHIFT) 2))) )
  ((<= (* ANS ANS) N) ANS)
  (SUB1 ANS) )


;(PI) returns pi, accurate to the current precision.

(DEFUN PI ()
  ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
    (GET-CONSTANT '*PI* '(PI-AUX)) )
  (PITRAP "Exact Mode") )

(PROGN
  ((GETD 'PITRAP T))
  (DEFUN PITRAP (MSG)
    (BREAK (LIST 'PI) MSG) ) )


;(PI-AUX) returns pi accurate to the current precision.
;Basis:  4/pi = SIGMA ((-1)^m (1123 + 21460 m) (1 3 ...(2m-1)) (1 3 ...(4m-1))
;			/ ((882^(2m+1) 32^m (m!)^3), m, 0, PINF)
;rearranged over a common denominator.
;Ref: Ramanujan, Quart. J. Pure & Appl. Math. 45, p. 350, 1914.

(DEFUN PI-AUX (
    N M TERM NUMR DENR PRECISION BITS)
  (SETQ PRECISION (* *PRECISION* (PRECISION))
	M 0
	N 1123
	TERM 1
	NUMR 3528
	DENR N)
  (LOOP
    (SETQ M (ADD1 M)
	  N (+ N 21460)
	  TERM (* TERM (SUB1 (+ M M)) (- 1 (* 4 M)) (- (* 4 M) 3))
	  BITS (* M M M 24893568)
	  NUMR (* NUMR BITS)
	  DENR (+ (* DENR BITS) (* N TERM))
	  BITS (- (+ PRECISION (INTEGER-LENGTH N)) (INTEGER-LENGTH DENR)))
    ( ((MINUSP BITS)
	(SETQ TERM (SHIFT TERM BITS)
	      DENR (SHIFT DENR BITS)
	      NUMR (SHIFT NUMR BITS)) ) )
    ((ZEROP TERM)
      (ROUND/ NUMR DENR) ) ) )


; (SIN n) returns the sine of n radians.

(DEFUN SIN (N
    Q)
  ((NUMBERP N)
    ((ZEROP N) 0)
    ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
      (SETQ Q (/ N (/ (PI) 4))
	    N (DIVIDE (NUMERATOR Q) (DENOMINATOR Q)))
      (SINCOS (MOD (CAR N) 8) (/ (CDR N) (DENOMINATOR Q))) )
    (SINTRAP N "Exact Mode") )
  (SINTRAP N "Nonnumeric Argument") )

(PROGN
  ((GETD 'SINTRAP T))
  (DEFUN SINTRAP (N MSG)
    (BREAK (LIST 'SIN N) MSG) ) )


; (COS n) returns the cosine of n radians.

(DEFUN COS (N
    Q)
  ((NUMBERP N)
    ((ZEROP N) 1)
    ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
      (SETQ Q (/ N (/ (PI) 4))
	    N (DIVIDE (NUMERATOR Q) (DENOMINATOR Q)))
      (SINCOS (MOD (+ 2 (CAR N)) 8) (/ (CDR N) (DENOMINATOR Q))) )
    (COSTRAP N "Exact Mode") )
  (COSTRAP N "Nonnumeric Argument") )

(PROGN
  ((GETD 'COSTRAP T))
  (DEFUN COSTRAP (N MSG)
    (BREAK (LIST 'COS N) MSG) ) )


;(TAN n) returns the tangent of n radians.

(DEFUN TAN (N)
  (/ (SIN N) (COS N)) )


;(SINCOS n q) returns the sine or cosine of an appropriately reduced angle.

(DEFUN SINCOS (N Q)
  ((> N 3)
    (- (SINCOS (- N 4) Q)) )
  ((ZEROP N)
    (SETQ Q (/ (* Q (PI)) 4))
    (SINCOS-AUX Q 1 (NUMERATOR Q) (DENOMINATOR Q)) )
  ((= N 1)
    (SINCOS-AUX (/ (* (- 1 Q) (PI)) 4) 0 1 1) )
  ((= N 2)
    (SINCOS-AUX (/ (* Q (PI)) 4) 0 1 1) )
  (SETQ Q (/ (* (- 1 Q) (PI)) 4))
  (SINCOS-AUX Q 1 (NUMERATOR Q) (DENOMINATOR Q)) )


; (SIN1 n) returns the sine of n radians, where 0 <= n <= pi/4 radians.
; SIN (x=p/q) ~= x - x^3/3! + x^5/5! - ... +|- x^n/n! =
; ((...((2*3pq^2 - p^3)4*5q^2 + p^5)6*7q^2 - ...)(n-1)nq^2 +|- p^n) / (n! q^n)
; (COS1 n) returns the cosine of n radians, where 0 <= n <= pi/4 radians.
; COS (x=p/q) ~= 1 - x^2/2! + x^3/3! - ... +|- x^n/n! =
; ((...((2q^2 - p^2)3*4q^2 + p^4)5*6q^2 - ...)(n-1)nq^2 +|- p^n) / (n! q^n)

(DEFUN SINCOS-AUX (ARG N NUMR DENR
    MNARGSQ DARGSQ TERM PRECISION BITS)
  (SETQ PRECISION (+ (* *PRECISION* (PRECISION)) 14) ;14=accurate, 8=fast
	DARGSQ (* ARG ARG)
	MNARGSQ (- (NUMERATOR DARGSQ))
	DARGSQ (DENOMINATOR DARGSQ)
	TERM NUMR)
  (LOOP
    (SETQ N (+ N 2)
	  ARG (* (SUB1 N) N)
	  DENR (* ARG DARGSQ DENR)
	  TERM (* MNARGSQ TERM)
	  NUMR (+ (* ARG DARGSQ NUMR) TERM)
	  BITS (- PRECISION (INTEGER-LENGTH NUMR)))
    ( ((MINUSP BITS)
	(SETQ TERM (SHIFT TERM BITS)
	      NUMR (SHIFT NUMR BITS)
	      DENR (SHIFT DENR BITS)) ) )
    ((ZEROP TERM)
      (ROUND/ NUMR DENR) ) ) )


; (ASIN n) returns the inverse sine of n in radians.
; Note that for all -1 <= n <= 1, -pi/2 <= (ASIN n) <= pi/2.

(DEFUN ASIN (N)
  ((NUMBERP N)
    ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
      ((MINUSP N)
	(- (ASIN (- N))) )
      ((= N 1)
	(/ (PI) 2) )
      ((< N 1)
	(ATAN (NUMERATOR N)
	      (SQRT (* (- (DENOMINATOR N) (NUMERATOR N))
		       (+ (DENOMINATOR N) (NUMERATOR N))))) )
      ((IDENTITY *GRAPHING*)
	(THROW "Invalid Argument") )
      (ASINTRAP N "Invalid Argument") )
    (ASINTRAP N "Exact Mode") )
  (ASINTRAP N "Nonnumeric Argument") )

(PROGN
  ((GETD 'ASINTRAP T))
  (DEFUN ASINTRAP (N MSG)
    (BREAK (LIST 'ASIN N) MSG) ) )


; (ACOS n) returns the inverse cosine of n in radians.
; Note that for all -1 <= n <= 1, 0 <= (ACOS n) <= pi.

(DEFUN ACOS (N)
  ((NUMBERP N)
    ((= N 1) 0)
    ((= N -1)
      (PI) )
    ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
      ((< -1 N 1)
	(ATAN (SQRT (* (- (DENOMINATOR N) (NUMERATOR N))
		       (+ (DENOMINATOR N) (NUMERATOR N))))
	      (NUMERATOR N)) )
      ((IDENTITY *GRAPHING*)
	(THROW "Invalid Argument") )
      (ACOSTRAP N "Invalid Argument") )
    (ACOSTRAP N "Exact Mode") )
  (ACOSTRAP N "Nonnumeric Argument") )

(PROGN
  ((GETD 'ACOSTRAP T))
  (DEFUN ACOSTRAP (N MSG)
    (BREAK (LIST 'ACOS N) MSG) ) )


; (ATAN n m) returns in radians the angle corresponding to the vector
; whose opposite component is n and whose adjacent component is m.
; m defaults to 1.  Note that for all n and m, -pi < (ATAN n m) <= pi.
; With v = x/(1+x^2) = r/s,  u = xv = p/q,  ATAN (x) ~=
; (1 + 2u/3 + 2 4u^2/(3 5) +...+ 2 4 ...(2n)u^n/(3 5 ...(2n+1))) v =
; ((...((3rq + 2rp)5q + 2 4rp^2)7q +...)(2n+1)q + 2 4 ...(2n)rp^n)
; / (3 5 ...(2n+1)sq^n)

(DEFUN ATAN (N M
    INDX NUMR TERM DENR NARG DARG PRECISION BITS)
  ((OR (NOT *EXACT-MODE*) (EQ 'RATIONAL *EXACT-MODE*))
    ((NUMBERP N)
      ((NUMBERP M)	;Reduce two-argument case to one argument
	((PLUSP M)
	  (ATAN (/ N M)) )
	((ZEROP M)
	  ((PLUSP N)
	    (/ (PI) 2) )
	  ((MINUSP N)
	    (/ (PI) -2) )
	  ((IDENTITY *GRAPHING*)
	    (THROW "Invalid Argument") )
	  (ATANTRAP N M "Invalid Argument") )
	((ZEROP N)
	  (PI) )
	((MINUSP N)
	  (- (/ (- (PI)) 2) (ATAN (/ M N))) )
	(+ (/ (PI) 2) (ATAN (/ (- M) N))) )
      ((NULL M)
	((MINUSP N)
	  (- (ATAN (- N))) )
	((> N 1)
	  (- (/ (PI) 2) (ATAN (/ 1 N))) )
	(SETQ PRECISION (+ (* *PRECISION* (PRECISION)) 14);14=acc, 11=fast
	      M (/ N (ADD1 (* N N)))
	      N (* N M)
	      NARG (NUMERATOR N)
	      DARG (DENOMINATOR N)
	      INDX 1
	      NUMR (NUMERATOR M)
	      TERM NUMR
	      DENR (DENOMINATOR M))
	(LOOP
	  (SETQ INDX (+ INDX 2)
		TERM (* (SUB1 INDX) NARG TERM)
		NUMR (+ TERM (* INDX DARG NUMR))
		DENR (* INDX DARG DENR)
		BITS (- PRECISION (INTEGER-LENGTH NUMR)))
	  ( ((MINUSP BITS)
	      (SETQ NUMR (SHIFT NUMR BITS)
		    DENR (SHIFT DENR BITS)
		    TERM (SHIFT TERM BITS)) ) )
	  ((ZEROP TERM)
	    (ROUND/ NUMR DENR) ) ) )
      (ATANTRAP N M "Nonnumeric Argument") )
    (ATANTRAP N M "Nonnumeric Argument") )
  (ATANTRAP N M "Exact Mode") )

(PROGN
  ((GETD ATANTRAP T))
  (DEFUN ATANTRAP (N M MSG)
    (BREAK (LIST 'ATAN N M) MSG) ) )


; Section 5.12.8:  Random Numbers

(DEFUN RANDOM (N STATE
    BL COUNT ANS)
  (IF (RANDOM-STATE-P STATE)
      (SETQ *RANDOM-STATE* STATE) )
  (SETQ *RANDOM-STATE*
		(LOGAND (ADD1 (* 3141592653 *RANDOM-STATE*)) 4294967295))
  ((AND (INTEGERP N) (PLUSP N))
    (SETQ ANS *RANDOM-STATE*
	  BL (- -10 (INTEGER-LENGTH N))
	  COUNT 0)
    (LOOP			; concatenate 32-bit random integers
      ((> BL (DECQ COUNT 32))
	(SHIFT (* N ANS) COUNT) )
      (SETQ *RANDOM-STATE*
	      (LOGAND (ADD1 (* 3141592653 *RANDOM-STATE*)) 4294967295)
	    ANS (+ (SHIFT ANS 32) *RANDOM-STATE*)) ) )
  ((NUMBERP N)
    (SETQ ANS (SHIFT 1 (- (* 16 (ADD1 (MAX (PRECISION) 1))) 10)))
    (/ (* (ABS N) (RANDOM ANS)) ANS) ) )

(DEFUN MAKE-RANDOM-STATE (STATE)
  ((NULL STATE) *RANDOM-STATE*)
  ((EQ STATE 'T)
    (TIME) )
  ((RANDOM-STATE-P STATE) STATE) )

(SETQ *RANDOM-STATE* (MAKE-RANDOM-STATE 'T))

(DEFUN RANDOM-STATE-P (OBJ)
  (AND (INTEGERP OBJ) (>= OBJ 0)) )
