;4-16
;��������� � �������� ��������� ����� ������������ ����, ������ ���� �������� ������� �������� X^k/k!,
;��� k ���������� �� 1 �� �������������, � �������� X ������. ��������� SG.
;
(DEFUN FACT (X) 
 (COND ((= X 0) 1)
       (T (* X (FACT (- X 1))) 
)
)
)
(DEFUN F1 (X K) (/ 1 (FACT K)))
(DEFUN SG (X EPS)
 (SETQ X1 (F1 X 1))
 (SETQ SIGM X1)
 (SETQ K 1)
 (LOOP
     (SETQ K (+ K 1))     
     (SETQ X2 (F1 X K))    
     ((< (ABS (- X2 X1)) EPS) SIGM)
     (SETQ SIGM (+ SIGM X2))
     (SETQ X1 X2)
 )
)
;
;4-17
;����� ��������� ������� ��������� ������. ��������� le.
;
;Last Elem of Lin Spisoc
;
(DEFUN le (L)
 (COND ((NULL L) 0)
  (T
    (LOOP
      ((NULL (CDR L)) (CAR L))
      (SETQ L (CDR L)) 
    )
  ) 
 )
 )
;
;4-18
;����������� � ������� LOOP ������� � 12 (������ ������). ��������� iv.
;
(DEFUN INVERT1 (L)
 (COND ((NULL L) '())
             ((ATOM (CAR L))
              (APPEND (INVERT1 ( CDR L)) (LIST (CAR L)))
             )
            ((LISTP (CAR L))
              (APPEND (INVERT1 ( CDR L)) (LIST (INVERT1 (CAR L))))
             )             
 )
 )
;
(DEFUN iv (L KSP)
 (SETQ KSP '())
 (COND ((NULL L) KSP)
 (T
  (LOOP 
      ((NULL (CAR L)) KSP)
      (COND 
        ((ATOM (CAR L)) 
         (SETQ KSP (CONS (CAR L) KSP)))
        (T (SETQ KSP (CONS (iv (CAR L) '()) KSP)))) 
      (SETQ L (CDR L))  
  )
 )
 )
)
;
;4-19
;������� �� ��������� ��������� ������ ��� ��������, �� �������� � �������� �������� ��������.
;��������� di.
;
(DEFUN INVERT1 (L)
 (COND ((NULL L) '())
             ((ATOM (CAR L))
              (APPEND (INVERT1 ( CDR L)) (LIST (CAR L)))
             )
            ((LISTP (CAR L))
              (APPEND (INVERT1 ( CDR L)) (LIST (INVERT1 (CAR L))))
             )             
 )
 )
;
;�������� ����� �� �� ���������
;
(DEFUN DelnotIn (L A B KSP)
 (PRINT A)
 (PRINT B)
    (LOOP
      ((NULL (CAR L)) KSP)
      (IF (AND (>= (CAR L) A) (<= (CAR L) B))
      (SETQ KSP (CONS (CAR L) KSP)))
      (SETQ L (CDR L))
    )
 )

(DEFUN di (L A B)
    (SETQ KSP '())
    (DelNotIn L A B KSP)
    (INVERT1 KSP)
)
;
;4-20
;����� ������ ���������� ������. �������� �� ���� ������ �������� ������ �� ������ �������� ������, �� �� �����,
;��� �������� ����� ��������� � ������ �����. ��������� es. 
;
(DEFUN ChangeInList (L A B C)
 (SETQ KS '())
 (LOOP
  ((NULL L) KS)
  (COND ((EQ (CAR L) A)      
         (COND ((= C 0) (SETQ KS (APPEND KS (LIST (CAR L)))))
               (T (SETQ C (- C 1)) (SETQ KS (APPEND KS (LIST B)))) 
         ))
        (T (SETQ KS (APPEND KS (LIST (CAR L)))))
  )
  (SETQ L (CDR L))
 )
)

(DEFUN es (L A B C)
 (SETQ KS1 '())
 (LOOP
  ((NULL L) KS1) 
  (SETQ KS1 (APPEND KS1 (LIST (PACK (CHANGEINLIST (UNPACK (CAR L)) A B C)))))
  (SETQ L (CDR L))
 )
)
;