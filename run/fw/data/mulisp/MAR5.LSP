
;  ������������ ������ ���뭥��� �.

;             � � � � � � � � � � � �   � � � � � �  N 2.

;  1. ��।����  �㭪�� (FIB N),  ��������� N-� �������
;     ��᫥����⥫쭮�� ��������.  ��᫠ ��������  ��।�������
;     ⠪: F�41�0=1, F�42�0=1, F�4n �0=�4 �0F�4n-1 �0+ F�4n-2�0 ��� n�7.�03.

(DEFUN FIB (LAMBDA (K)
   ;���᫥��� K-�� ������� ��᫥����⥫쭭��� ��������
    (COND ( (EQ K 1)  1)
          ( (EQ K 2)  1)
          (  T  (+ (FIB (- K 1))
                   (FIB (- K 2))) )
      )
   ))

   ;�������� �������

 ;  1.(FIB 3)
 ;    2

 ;  2.(FIB 10)
 ;    55
 ; --------------------------------------------------------------------

 ; 2. ������  �㭪�� ��� ���᫥��� �᫠ ��⠭�� �� n
 ;    ������⮢ �� m.

   (DEFUN SOCH (LAMBDA (N M)
      (COND ( (EQ N M ) 1)
            (  T  ( / (FACT N) ( * (FACT (- N M)) (FACT M))))
      )
    ))
 ;----------------------------
   (DEFUN FACT (LAMBDA (X)
      (COND ( (ZEROP X) 1 )
            (  T  (* X (FACT (- X 1))) )
      )
   ))

   ;�������� �������

 ; (SOCH 5 4)
 ; 120
 ; ----------------------------------------------------
;             � � � � � � � � � � � �   � � � � � �  N 3.

 ; 3. �㭪�� ��� � ᯨ᪥ �⮬�� ⠪�� �⮬, ����� �����-
 ;    ���� �����।�⢥��� ��। ������� �⮬��.

   (DEFUN PATOM (LAMBDA (X LST)
      (NTH (- (NATOM X LST) 1) LST)
   ))
 ; ----------------------
   (DEFUN NTH (LAMBDA (N LST)
 ;   �㭪�� �����頥� N-� ������� ᯨ᪠ LST %
       (COND ( (EQ N 1) (CAR LST) )
             (    T     (NTH (- N 1) (CDR LST)) )
       )
   ))
 ;  ------------------------
   (DEFUN NATOM (LAMBDA (X LST)
 ;   �㭪�� �����頥� ������ ��������� ������� %
      (COND ( (NULL LST) 0)
            ( (EQ X (CAR LST)) 1)
            ( (MEMBER X LST) (+ 1 (NATOM X (CDR LST))) )
      )
   ))


   ;�������� �������

  ; $ (PATOM 5 '(2 3 2 5 5 3))
  ; 2
  ; $ (PATOM 2 '(4 8 2 5 2 3))
  ; 8

 ; ----------------------------------------------------


 ;  4. ������ �㭪��, "���뢠����" ᯨ᮪, �᫨ �� ���-
 ;     �� ����� 祬 �� N ������⮢.

   (DEFUN FIRSTN (LAMBDA (LST N)
      (COND ( (EQ N 1) (LIST (CAR LST)) )
            ( ( < (LENGTH LST) N) LST)
            (   T  (CONS (CAR LST)
                        (FIRSTN (CDR LST) (- N 1))))
      )
   ))
  ;--------------------


 ; �������� �������

 ;$ (FIRSTN '(2 3 4)1)
 ; (2)
 ;$ (FIRSTN '(2 3 4)2)
 ; (2 3)
 ;$ (FIRSTN '(2 3 4)4)
 ; (2 3 4)

;-----------------------------------------------------------------
;  5. ������ �㭪��, ��������� �� ��� ��㬥�⮢ X, N �
; V, ����������� X �� N-� ���� � ᯨ᮪ V.


  (DEFUN INSERT ( LAMBDA (X N V)

    ( COND ((NULL V)(CONS X V))
           ((EQ N 1)(CONS X V))
           ( T (CONS (CAR V)
                      (INSERT X (- N 1)(CDR V))))
     )
   ))



   ;�������� �������

; (INSERT 2 3 '(1 2 3 4))
;   (1 2 2 3 4)

;---------------------------------------------
; 6.������� �ணࠬ�� ,����� �뤠�� ��᫥���� N ������⮢ ᯨ᪠.

   (DEFUN REVE (LAMBDA (LST N)
      (REVERSE (FIRSTN (REVERSE LST) N))
   ))
 ;-------------------------
   (DEFUN FIRSTN (LAMBDA (LST N)
      (COND ( (EQ N 1) (LIST (CAR LST)) )
            ( ( < (LENGTH LST) N) LST)
            (   T  (CONS (CAR LST)
                        (FIRSTN (CDR LST) (- N 1))))
      )
   ))
  ;--------------------
;             � � � � � � � � � � � �   � � � � � �  N 4.

; 7.������� ������� ������ � ᫮�� � ��� �㪢 "�" �� ��⠭�� "��".

   (DEFUN REPLACE (LAMBDA ( WORD)
      (PACK (DELETE1 A KU (UNPACK WORD)))
   ))
   ;---------------------------
   (DEFUN DELETE1 (LAMBDA(X Y LST)
   ;� ᯨ᪥ LST �ந�室�� ������ ������� X �� ������� Y .
      (COND ( (NULL LST) NIL)
            ( (EQ (CAR LST) X)
                  (CONS Y (DELETE1 X Y (CDR LST)) ) )
            ( T   (CONS (CAR LST) (DELETE1 X Y (CDR LST)) ) )
       )
    ))

  ;------------------------------------------------------------------
  ;  8.�㭪��, ���������� ���ભ��� ��  ᫮��  X  ��  �㪢�,
  ;  ���騥 �� ���� ����� ��᫥ �㪢� "�".

   (DEFUN PACDEL (LAMBDA (X)
      (PACK (DELAP_A (UNPACK X)))
   ))
   ; ---------------------- 
 
   (DEFUN DELAP_A (LAMBDA (X)
      (COND ( (NULL X) NIL)
            ( (EQ (CAR X) A)
                   (CONS
                       (CAR X)
                       (DELAP_A (CDDR X))
                   )
            )
            (  T  (CONS
                      (CAR X)
                      (CONS (CADR X)
                            (DELAP_A (CDDR X)))
                  )
            )
       )
   ))
     (rds)
;---------------------------------------------------------------

;             � � � � � � � � � � � �   � � � � � �  N 5.

;  9.��� ���樠⨢�� ᯨ᮪ �.��।����� ,᪮�쪮 � ��� ࠧ�����
;    ����� ���.

  (DEFUN SUM1 (LAMBDA (AL)
; �㭪�� ������ ����� ᯨ᪠
     (LENGTH (LIST-SET AL))
  ))
;--------------
  (DEFUN LIST-SET (LAMBDA (LST)
; �㭪�� �८�ࠧ�� ᯨ᮪ � ������⢮
     (COND ( (NULL LST)  NIL)
           ( (MEMBER (CAR LST)(CDR LST))
             (LIST-SET (CDR LST)) )
           ( T (CONS  (CAR LST)
                      (LIST-SET (CDR LST))
               )
           )
     )
  ))
;--------------
  (DEFUN MEMBER (LAMBDA (X AL)
;�㭪�� �஢���� �宦����� ��筮� ���� � ᯨ᮪
     (COND ( (NULL AL) NIL)
           ( (EQUAL (CAR AL) X) AL)
           ( T ( MEMBER X (CDR AL)) )
     )
 ))

;-----------------------------------------------
.

; 10.������� �㭪�� ��� �஢�ન ,ᮢ������ �� ��ࢠ� ��.��� �-ᯨ-
;    ᪠ X � ��᫥���� ��.��� A-ᯨ�� Y.

  (DEFUN LIST (LAMBDA (LST1 LST2)
; �㭪�� ������ ࠢ���⢮ ����� ����� ��� ᯨ᪮�  X � Y
     (COND ( (OR (NULL LST1)
                 (NULL LST2)  NIL)
           ( (EQUAL (CAR LST1)
                    (CAR (REV LST2)) )
                       ��  )
           ( T     ���  )
     )
  ))
;--------------
  (DEFUN REV (LAMBDA (AL)
     (REVERSE  AL)
  ))

;-------------------------------------

;12.��।�����,������� �� � ������ �-ᯨ᪥ ��� ��������� ����

   (DEFUN SRAVAL (LAMBDA (ALIST) 
; �����᭨�, ���� �� � ���樠⨢��� ᯨ᪥  ��� ���������� ��p� 
        (COND ((NULL ALIST)     ���)
              ((NULL CDR ALIST) NIL)
              ((MEMBER (CAR ALIST)( CDR ALIST)) ��)
              ( T    (SRAVAL (CDR ALIST)))
        )
    ))
  (DEFUN MEMBER (LAMBDA (X AL)
;�㭪�� �஢���� �宦����� ��筮� ���� � ᯨ᮪
     (COND ( (NULL AL) NIL)
           ( (EQUAL (CAR AL) X) AL)
           ( T ( MEMBER X (CDR AL)) )
     )
 ))


;----------------------------------------------------
;             � � � � � � � � � � � �   � � � � � �  N 6.


12. ������ �㭪��, ���������� ��᫥���� ������� ᯨ�-
    �� ᢮��� ��������� �⮬�.

(DEFUN DEMO_2 (LAMBDA NIL
      (PRINT "����஥��� ᯨ᪠ ᢮��� ������� �⮬�:")
      (PRINT "������ ��� �⮬�:") (SETQ ATM (READ))
      (LOOP
         (PRINT "������ ��� ᢮��⢠ (����砭�� ����� - !:")
         (SETQ PROPNAME (READ))
         ( (EQ PROPNAME '!) )
         (PRINT "������ ���祭�� ᢮��⢠:")
         (SETQ PROPVAL (READ))
         (PUT ATM PROPNAME PROPVAL)
      )
      ; �2����ﭥ� �� ᯨ᮪ ᢮���
      (PRINT "���᮪ ᢮��� �⮬�:") (PRINT (CDR ATM))
   ))
;---------------------
(DEFUN DOS (LAMBDA (AL)
     (COND ( (NULL AL) NIL)
           (   (CAR (REVERSE AL
                                 )) )
     )
 ))
;-------------------------------------------
; 12. ������ �㭪��, "���뢠����" ᯨ᮪ ᢮��� �������-
;�� �⮬�, �᫨ �� ��⮨� ����� 祬 �� N ����� ���.

(DEFUN FIRSTN (LAMBDA (LST N)
      (COND ( (EQ N 1) (LIST (CAR LST)) )
            ( (EQ N 0) 0)
            ( ( < (LENGTH LST) N) LST)
            (   T  (CONS (CAR LST)
                        (FIRSTN (CDR LST) (- N 1))))
      )
   ))
  ;-------------------------------------------
  13. ���� ��� �⮬�. �஢����, ���� �� � �� ᯨ᪠� ᢮��-
� ��������� ᢮��⢠ (��������� ��������).


(DEFUN VCHOD (LAMBDA (LST1 LST2)
     (COND ( (OR (NULL LST1)
                 (NULL LST2))  ���)
           ( (MEMBER (CAR LST1) LST2) ��)
           ( T ( VCHOD (CDR LST1) LST2) )
              
     )
 ))
;-------------------
  (DEFUN MEMBER (LAMBDA (X AL)
;�㭪�� �஢���� �宦����� ��筮� ���� � ᯨ᮪
     (COND ( (NULL AL) NIL)
           ( (EQUAL (CAR AL) X) AL)
           ( T ( MEMBER X (CDR AL)) )
     )
 ))

;-----------------------------------------------
;             � � � � � � � � � � � �   � � � � � �  N 7.
; 14. ������ �㭪��,  ����� ������뢠�� �᫮ ���設 ��
N-�� �஢�� �����⮣� ��ॢ� T (��७� ����� ���設�� 0-��
�஢��).

   (DEFUN VERSH (LAMBDA (N TREE)
      ;��⠥� ������⢮ ��p設 �� n-�� �p����
      (COND ((EQ N 0) 1)
            ((< (TOP TREE) N) 0)
            (T 
                (LENGTH (POSP (SEE N TREE))))
      )
   ))
;------------------------------------------------------------------;

   (DEFUN TOP (LAMBDA (TREE)
      ; ��㭪�� TOP �����頥� �᫮ �஢��� � ��ॢ� TREE
      ; �   (��७� ��ॢ� �ᯮ����� �� �㫥��� �஢��)
      (COND ( (NULL TREE) -1 )
            (  T  (+ 1 (MAX (TOP (LEFT  TREE))
                            (TOP (RIGHT TREE)))) ))
   ))
;-----------------------------------------------------------------;

   (DEFUN MAX (LAMBDA (M N)
      ; ��㭪�� MAX �����頥� ����襥 �� �ᥫ M � N
      (COND ( (> M N) M )
            ( T  N ))
   ))
;-----------------------------------------------------------------;

   (DEFUN SEE (LAMBDA (N TREE)
      ; ���室 ��ॢ� TREE � "�ਭ�" � ᮧ����� "��吝���"
      ; � ᯨ᪠, ᮤ�ঠ饣� ���設� N-�� �஢�� ��ॢ�
      (COND ( (EQ N 0) (CAR TREE) )
            ( (EQ N 1)
                 (LIST (CAR (CADR TREE)) (CAR (CADDR TREE)))
            )
            (  T  (LIST (SEE (- N 1) (CADR  TREE))
                        (SEE (- N 1) (CADDR TREE))) ))
   ))
;----------------------------------------------------------------;

    (DEFUN LEFT (LAMBDA (TREE)
       ;����p�頥� ����� �����p��� ��p���
       (CADR TREE)
    ))
;---------------------------------------------------------------;

    (DEFUN RIGHT (LAMBDA (TREE)
       ;����p�頥� �p���� �����p��� ��p���
       (CADDR TREE)
    ))
;---------------------------------------------------------------;

    (DEFUN POSP (LAMBDA (L)
       ;������� ᯨ᮪,����騩 �� ����� �⮬�p��� ������⮢
       (COND ((NULL L) NIL)
             ((EQUAL (CAR L) NIL) (POSP (CDR L)))
             ((ATOM (CAR L)) (CONS (CAR L) (POSP (CDR L))))
             (T 
                (APPEND (POSP (CAR L)) (POSP (CDR L))))
       )
    ))
;--------------------------------------------------------------;
;   15. ������� �㭪��,  ����� ��।���� �᫮  �宦�����
������� E � ���ଠ樮��� ���� ���設 ������ �����ॢ� ��-
ॢ� T.


(DEFUN KOL (LAMBDA (M TREE)

      (COND
         ( (NULL TREE) 0)
         (  T (KOL1 M (LISTATOMS(LEFT TREE))) )
      )
   ))
   % ---------------------- %
   (DEFUN KOL1 (LAMBDA (M L)
;��⠥� �᫮ �宦����� ������⮢ � ᯨ᮪
      (COND
         ( (NULL L) 0)
         ( (EQ (CAR L) M)
               (+ 1 (KOL1 M (CDR L))) )
         (  T (KOL1 M (CDR L)))
      )
   ))
   % ---------------------- %
   (DEFUN LEFT (LAMBDA (TREE)
   ; �2�㭪�� �����頥� ����� �����ॢ� ��ॢ� TREE
      (CADR TREE)
   ))
   ; -------------------------
    (DEFUN LISTATOMS (LAMBDA (TREE)
       ;����p�頥� ᯨ᮪,����騩 �� ������⮢ (������ 
       ; NIL),�室��� � ��p���
       (COND ((NULL TREE) NIL)
             ((ATOM (CAR TREE)) (CONS (CAR TREE)
                                      (LISTATOMS (CDR TREE))))
             (T 
                (APPEND (LISTATOMS (CAR TREE))
                        (LISTATOMS (CDR TREE))))
        )
    ))
;------------------------------------------------------------;
   (DEFUN SEE1 (LAMBDA (TREE)
   ; �2��室 ��ॢ� TREE ᫥�� ���ࠢ� �
   ; �2ᮧ����� "��吝���" ᯨ᪠
      (COND ( (ATOM TREE) TREE )
            (  T  (LIST (CAR TREE) (SEE1 (CADR  TREE))
                  ))
      )
    ))
;-------------------------------
   (DEFUN TEST (LAMBDA NIL
      (PRINT "����஥��� ��ॢ�:") (SETQ TREE NIL)
      (LOOP
         (PRINT "������ ��।��� ������� ��ॢ�:")
         (SETQ A (READ)) ( (EQ A '!) )
         (PRINT (SETQ TREE (ADDTREE A TREE)))
      )
      (PRINT "�����������������������������")
      (PRIN1 "��७� ��ॢ�:               ")
         (PRINT (ROOT TREE))
      (PRIN1 "����� �����ॢ�:             ")
         (PRINT (LEFT TREE))
      (PRIN1 "�ࠢ�� �����ॢ�:            ")
         (PRINT (RIGHT TREE))
     (KOL 2 TREE)
   ))
   ; -----------------------------
   (DEFUN ADDTREE (LAMBDA (A TREE)
   ; �2�㭪�� ADDTREE �������� � ��ॢ� ���᪠ TREE ������� A
      (COND ( (NULL TREE) (LIST A NIL NIL) )
            ( (<= A (CAR TREE))
                    (LIST (CAR TREE) (ADDTREE A (CADR TREE))
                          (CADDR TREE)) )
            (   T   (LIST (CAR TREE) (CADR TREE)
                          (ADDTREE A (CADDR TREE))) )
      )
   ))
   ; ------------------------
   (DEFUN ROOT (LAMBDA (TREE)
   ; �2�㭪�� ROOT �����頥� ��७� ��ॢ� TREE
      (CAR TREE)
   ))
   ; ------------------------
   (DEFUN LEFT (LAMBDA (TREE)
   ; �2�㭪�� �����頥� ����� �����ॢ� ��ॢ� TREE
      (CADR TREE)
   ))
   ; -------------------------
   (DEFUN RIGHT (LAMBDA (TREE)
   ; �2�㭪�� �����頥� �ࠢ�� �����ॢ� ��ॢ� TREE
      (CADDR TREE)
   ))
   ; -----------------------------

(rds)



;   16. ������� �㭪��,  ����� ������ �।��� ��䬥�-
�᪮� ��� ������⮢ �����⮣� ��ॢ� T (���ଠ樮���� ��-
�� ���設� ��ॢ� ᮤ�ন� ����⢥��� �᫠).
;
     (DEFUN SREDNEE (LAMBDA (TREE)
        ;������ �p����� �p�䬥��᪮� ��� ������⮢
        ;  ��p���
        (COND ((NULL TREE) 0)
              (T 
                 (/ (SUMMA (POSP (LISTATOMS TREE)))
                    (LENGTH (POSP (LISTATOMS TREE))))
              )
        )
     ))
;--------------------------------------------------------------;
    (DEFUN LISTATOMS (LAMBDA (TREE)
       ;����p�頥� ᯨ᮪,����騩 �� ������⮢ (������ 
       ; NIL),�室��� � ��p���
       (COND ((NULL TREE) NIL)
             ((ATOM (CAR TREE)) (CONS (CAR TREE)
                                      (LISTATOMS (CDR TREE))))
             (T 
                (APPEND (LISTATOMS (CAR TREE))
                        (LISTATOMS (CDR TREE))))
        )
    ))
;------------------------------------------------------------;

    (DEFUN SUMMA (LAMBDA (L)
       ;��⠥� �㬬� ��� ������⮢ ᯨ᪠
       (COND ((NULL L) 0)
             ((EQ (LENGTH L) 1) (CAR L))
             (T 
                (+ (CAR L) (SUMMA (CDR L))) )
       )
    ))
;-------------------------------------------------------------;
;   17. ������� �㭪��,  ����� ��室�� � �����⮬ ��ॢ� T
�����  (�᫮  ��⢥�)  ��� �� ���� �� ������襩 ���設� �
������⮬ E.
;
    (DEFUN KOLVETV (LAMBDA (A TREE)
       ;�뤠�� ����� ��� (�᫮ ��⢥�) �� ��p��� ��
       ; ������� ������� 
       (COND ((NULL TREE) 0)
             (T 
                (- (LENGTH (PRTREE A TREE)) 1))
       )
    ))
;------------------------------------------------------------;

    (DEFUN PRTREE (LAMBDA (A TREE)
       ;�뤥��� � ᯨ᮪ �� 㧫� �� �������
       ; ��p���,�p�������騥 ������� ��������
       (COND ((NULL TREE) NIL)
             ((EQ (CAR TREE) A) (LIST A))
             ((< (CAR TREE) A) (CONS (CAR TREE)
                                     (PRTREE A (CADDR TREE))))
             (T
                (CONS (CAR TREE) (PRTREE A (CADR TREE))))
       )
    ))
;------------------------------------------------------------;


;   18. ��।����� ����� ��ॢ� T,  �ᯮ���� �㭪�� ��।�-
����� ��� �� ���� �� ������ ���設�.

   (DEFUN TEST (LAMBDA NIL
      (PRINT "����஥��� ��ॢ�:") (SETQ TREE NIL)
      (LOOP
         (PRINT "������ ��।��� ������� ��ॢ�:")
         (SETQ A (READ)) ( (EQ A '!) )
         (PRINT (SETQ TREE (ADDTREE A TREE)))
      )
      (PRINT "�����������������������������")
      (PRIN1 "��७� ��ॢ�:               ")
         (PRINT (ROOT TREE))
      (PRIN1 "����� �����ॢ�:             ")
         (PRINT (LEFT TREE))
      (PRIN1 "�ࠢ�� �����ॢ�:            ")
         (PRINT (RIGHT TREE))
     ( FFF TREE)
   ))
   ; -----------------------------
   (DEFUN FFF (LAMBDA (TREE)
     (MAXIM (TOPTOP TREE (POSP(SEE1 TREE))))
   ))

   (DEFUN SEE1 (LAMBDA (TREE)
   ; �2��室 ��ॢ� TREE ᫥�� ���ࠢ� �
   ; �2ᮧ����� "��吝���" ᯨ᪠
      (COND ( (ATOM TREE) TREE )
            (  T  (LIST (CAR TREE) (SEE1 (CADR  TREE))
                                   (SEE1 (CADDR TREE))) ))
   ))
   ; -----------------------------
   (DEFUN TOPTOP (LAMBDA (TREE LST)
;������� ᯨ᮪ �� ����ﭨ� �� ���� ��ॢ� TREE �� ������� �������
;ᯨ᪠ LST
    (COND ((NULL LST) 0)
          ( T (CONS (KOLVETV (CAR LST) TREE )
                    (TOPTOP  TREE (CDR LST)) ))
    ) 
   ))
;----------------------------------

   (DEFUN MAXIM (LAMBDA (LST)
      (COND
         ( (NULL LST) NIL                        )
         ( (EQ (LENGTH LST) 1)  (CAR LST)        )
         (  T (MAX2 (CAR LST) (MAXIM (CDR LST))) )
      )
  ))
;   % --------------------- %
   (DEFUN MAX2 (LAMBDA (X Y)
     (COND
            ( (> X Y) X )
            (  T      Y )
      )
   ))
(RDS)






