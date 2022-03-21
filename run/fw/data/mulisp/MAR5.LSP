
;  ЛАБОРАТОРНЫЕ РАБОТЫ Матыненко Е.

;             Л А Б О Р А Т О Р Н А Я   Р А Б О Т А  N 2.

;  1. Определите  функцию (FIB N),  вычисляющую N-й элемент
;     последовательности Фибоначчи.  Числа Фибоначчи  определяются
;     так: F 41 0=1, F 42 0=1, F 4n  0= 4  0F 4n-1  0+ F 4n-2 0 для n 7. 03.

(DEFUN FIB (LAMBDA (K)
   ;Вычисление K-го элемента последовательнности Фибоначчи
    (COND ( (EQ K 1)  1)
          ( (EQ K 2)  1)
          (  T  (+ (FIB (- K 1))
                   (FIB (- K 2))) )
      )
   ))

   ;ТЕСТОВЫЕ ПРИМЕРЫ

 ;  1.(FIB 3)
 ;    2

 ;  2.(FIB 10)
 ;    55
 ; --------------------------------------------------------------------

 ; 2. Напишите  функцию для вычисления числа сочетаний из n
 ;    элементов по m.

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

   ;ТЕСТОВЫЕ ПРИМЕРЫ

 ; (SOCH 5 4)
 ; 120
 ; ----------------------------------------------------
;             Л А Б О Р А Т О Р Н А Я   Р А Б О Т А  N 3.

 ; 3. Функция ищет в списке атомов такой атом, который встреча-
 ;    ется непосредственно перед заданным атомом.

   (DEFUN PATOM (LAMBDA (X LST)
      (NTH (- (NATOM X LST) 1) LST)
   ))
 ; ----------------------
   (DEFUN NTH (LAMBDA (N LST)
 ;   Функция возвращает N-й элемент списка LST %
       (COND ( (EQ N 1) (CAR LST) )
             (    T     (NTH (- N 1) (CDR LST)) )
       )
   ))
 ;  ------------------------
   (DEFUN NATOM (LAMBDA (X LST)
 ;   Функция возвращает позицию заданного элемента %
      (COND ( (NULL LST) 0)
            ( (EQ X (CAR LST)) 1)
            ( (MEMBER X LST) (+ 1 (NATOM X (CDR LST))) )
      )
   ))


   ;ТЕСТОВЫЕ ПРИМЕРЫ

  ; $ (PATOM 5 '(2 3 2 5 5 3))
  ; 2
  ; $ (PATOM 2 '(4 8 2 5 2 3))
  ; 8

 ; ----------------------------------------------------


 ;  4. Напишите функцию, "обрывающую" список, если он состо-
 ;     ит более чем из N элементов.

   (DEFUN FIRSTN (LAMBDA (LST N)
      (COND ( (EQ N 1) (LIST (CAR LST)) )
            ( ( < (LENGTH LST) N) LST)
            (   T  (CONS (CAR LST)
                        (FIRSTN (CDR LST) (- N 1))))
      )
   ))
  ;--------------------


 ; ТЕСТОВЫЕ ПРИМЕРЫ

 ;$ (FIRSTN '(2 3 4)1)
 ; (2)
 ;$ (FIRSTN '(2 3 4)2)
 ; (2 3)
 ;$ (FIRSTN '(2 3 4)4)
 ; (2 3 4)

;-----------------------------------------------------------------
;  5. Напишите функцию, зависящую от трех аргументов X, N и
; V, добавляющую X на N-е место в список V.


  (DEFUN INSERT ( LAMBDA (X N V)

    ( COND ((NULL V)(CONS X V))
           ((EQ N 1)(CONS X V))
           ( T (CONS (CAR V)
                      (INSERT X (- N 1)(CDR V))))
     )
   ))



   ;ТЕСТОВЫЕ ПРИМЕРЫ

; (INSERT 2 3 '(1 2 3 4))
;   (1 2 2 3 4)

;---------------------------------------------
; 6.Написать программу ,которая выдает последние N элементов списка.

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
;             Л А Б О Р А Т О Р Н А Я   Р А Б О Т А  N 4.

; 7.Написать алгоритмы замены в слове Х всех букв "а" на сочетание "ку".

   (DEFUN REPLACE (LAMBDA ( WORD)
      (PACK (DELETE1 A KU (UNPACK WORD)))
   ))
   ;---------------------------
   (DEFUN DELETE1 (LAMBDA(X Y LST)
   ;В списке LST происходит замена элемента X на элемент Y .
      (COND ( (NULL LST) NIL)
            ( (EQ (CAR LST) X)
                  (CONS Y (DELETE1 X Y (CDR LST)) ) )
            ( T   (CONS (CAR LST) (DELETE1 X Y (CDR LST)) ) )
       )
    ))

  ;------------------------------------------------------------------
  ;  8.Функция, позволяющая вычеркнуть из  слова  X  все  буквы,
  ;  стоящие на четных местах после буквы "а".

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

;             Л А Б О Р А Т О Р Н А Я   Р А Б О Т А  N 5.

;  9.Дан ассоциативный список А.Опредилить ,сколько в нем различных
;    точечных пар.

  (DEFUN SUM1 (LAMBDA (AL)
; Функция вычисляет длину списка
     (LENGTH (LIST-SET AL))
  ))
;--------------
  (DEFUN LIST-SET (LAMBDA (LST)
; Функция преобразует список в множество
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
;Функция проверяет вхождение точечной пары в список
     (COND ( (NULL AL) NIL)
           ( (EQUAL (CAR AL) X) AL)
           ( T ( MEMBER X (CDR AL)) )
     )
 ))

;-----------------------------------------------
.

; 10.Написать функцию для проверки ,совпадают ли первая точ.пара А-спи-
;    ска X и последняя точ.пара A-спика Y.

  (DEFUN LIST (LAMBDA (LST1 LST2)
; Функция выясняет равенство первых точечных пар списков  X и Y
     (COND ( (OR (NULL LST1)
                 (NULL LST2)  NIL)
           ( (EQUAL (CAR LST1)
                    (CAR (REV LST2)) )
                       ДА  )
           ( T     НЕТ  )
     )
  ))
;--------------
  (DEFUN REV (LAMBDA (AL)
     (REVERSE  AL)
  ))

;-------------------------------------

;12.Опредилить,имеется ли в данном А-списке две одинаковые пары

   (DEFUN SRAVAL (LAMBDA (ALIST) 
; Выяснясним, есть ли в ассоциативном списке  две одинаковых паpы 
        (COND ((NULL ALIST)     НЕТ)
              ((NULL CDR ALIST) NIL)
              ((MEMBER (CAR ALIST)( CDR ALIST)) ДА)
              ( T    (SRAVAL (CDR ALIST)))
        )
    ))
  (DEFUN MEMBER (LAMBDA (X AL)
;Функция проверяет вхождение точечной пары в список
     (COND ( (NULL AL) NIL)
           ( (EQUAL (CAR AL) X) AL)
           ( T ( MEMBER X (CDR AL)) )
     )
 ))


;----------------------------------------------------
;             Л А Б О Р А Т О Р Н А Я   Р А Б О Т А  N 6.


12. Напишите функцию, возвращающую последний элемент спис-
    ка свойств заданного атома.

(DEFUN DEMO_2 (LAMBDA NIL
      (PRINT "Построение списка свойств данного атома:")
      (PRINT "Введите имя атома:") (SETQ ATM (READ))
      (LOOP
         (PRINT "Введите имя свойства (окончание ввода - !:")
         (SETQ PROPNAME (READ))
         ( (EQ PROPNAME '!) )
         (PRINT "Введите значение свойства:")
         (SETQ PROPVAL (READ))
         (PUT ATM PROPNAME PROPVAL)
      )
      ;  2Взглянем на список свойств
      (PRINT "Список свойств атома:") (PRINT (CDR ATM))
   ))
;---------------------
(DEFUN DOS (LAMBDA (AL)
     (COND ( (NULL AL) NIL)
           (   (CAR (REVERSE AL
                                 )) )
     )
 ))
;-------------------------------------------
; 12. Напишите функцию, "обрывающую" список свойств заданно-
;го атома, если он состоит более чем из N точечных пар.

(DEFUN FIRSTN (LAMBDA (LST N)
      (COND ( (EQ N 1) (LIST (CAR LST)) )
            ( (EQ N 0) 0)
            ( ( < (LENGTH LST) N) LST)
            (   T  (CONS (CAR LST)
                        (FIRSTN (CDR LST) (- N 1))))
      )
   ))
  ;-------------------------------------------
  13. Даны два атома. Проверьте, есть ли в их списках свойс-
тв одинаковые свойства (одинаковые элементы).


(DEFUN VCHOD (LAMBDA (LST1 LST2)
     (COND ( (OR (NULL LST1)
                 (NULL LST2))  НЕТ)
           ( (MEMBER (CAR LST1) LST2) ДА)
           ( T ( VCHOD (CDR LST1) LST2) )
              
     )
 ))
;-------------------
  (DEFUN MEMBER (LAMBDA (X AL)
;Функция проверяет вхождение точечной пары в список
     (COND ( (NULL AL) NIL)
           ( (EQUAL (CAR AL) X) AL)
           ( T ( MEMBER X (CDR AL)) )
     )
 ))

;-----------------------------------------------
;             Л А Б О Р А Т О Р Н А Я   Р А Б О Т А  N 7.
; 14. Описать функцию,  которая подсчитывает число вершин на
N-ом уровне непустого дерева T (корень считать вершиной 0-го
уровня).

   (DEFUN VERSH (LAMBDA (N TREE)
      ;Считает количество веpшин на n-ом уpовне
      (COND ((EQ N 0) 1)
            ((< (TOP TREE) N) 0)
            (T 
                (LENGTH (POSP (SEE N TREE))))
      )
   ))
;------------------------------------------------------------------;

   (DEFUN TOP (LAMBDA (TREE)
      ;  Функция TOP возвращает число уровней в дереве TREE
      ;     (корень дерева расположен на нулевом уровне)
      (COND ( (NULL TREE) -1 )
            (  T  (+ 1 (MAX (TOP (LEFT  TREE))
                            (TOP (RIGHT TREE)))) ))
   ))
;-----------------------------------------------------------------;

   (DEFUN MAX (LAMBDA (M N)
      ;  Функция MAX возвращает большее из чисел M и N
      (COND ( (> M N) M )
            ( T  N ))
   ))
;-----------------------------------------------------------------;

   (DEFUN SEE (LAMBDA (N TREE)
      ;  Обход дерева TREE в "ширину" и создание "грязного"
      ;   списка, содержащего вершины N-го уровня дерева
      (COND ( (EQ N 0) (CAR TREE) )
            ( (EQ N 1)
                 (LIST (CAR (CADR TREE)) (CAR (CADDR TREE)))
            )
            (  T  (LIST (SEE (- N 1) (CADR  TREE))
                        (SEE (- N 1) (CADDR TREE))) ))
   ))
;----------------------------------------------------------------;

    (DEFUN LEFT (LAMBDA (TREE)
       ;Возвpащает левое поддеpево деpева
       (CADR TREE)
    ))
;---------------------------------------------------------------;

    (DEFUN RIGHT (LAMBDA (TREE)
       ;Возвpащает пpавое поддеpево деpева
       (CADDR TREE)
    ))
;---------------------------------------------------------------;

    (DEFUN POSP (LAMBDA (L)
       ;Создает список,состоящий из одних атомаpных элементов
       (COND ((NULL L) NIL)
             ((EQUAL (CAR L) NIL) (POSP (CDR L)))
             ((ATOM (CAR L)) (CONS (CAR L) (POSP (CDR L))))
             (T 
                (APPEND (POSP (CAR L)) (POSP (CDR L))))
       )
    ))
;--------------------------------------------------------------;
;   15. Написать функцию,  которая определяет число  вхождений
элемента E в информационные поля вершин левого поддерева де-
рева T.


(DEFUN KOL (LAMBDA (M TREE)

      (COND
         ( (NULL TREE) 0)
         (  T (KOL1 M (LISTATOMS(LEFT TREE))) )
      )
   ))
   % ---------------------- %
   (DEFUN KOL1 (LAMBDA (M L)
;Считает число вхождений элементов в список
      (COND
         ( (NULL L) 0)
         ( (EQ (CAR L) M)
               (+ 1 (KOL1 M (CDR L))) )
         (  T (KOL1 M (CDR L)))
      )
   ))
   % ---------------------- %
   (DEFUN LEFT (LAMBDA (TREE)
   ;  2Функция возвращает левое поддерево дерева TREE
      (CADR TREE)
   ))
   ; -------------------------
    (DEFUN LISTATOMS (LAMBDA (TREE)
       ;Возвpащает список,состоящий из элементов (включая 
       ; NIL),входящих в деpево
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
   ;  2Обход дерева TREE слева направо и
   ;  2создание "грязного" списка
      (COND ( (ATOM TREE) TREE )
            (  T  (LIST (CAR TREE) (SEE1 (CADR  TREE))
                  ))
      )
    ))
;-------------------------------
   (DEFUN TEST (LAMBDA NIL
      (PRINT "Построение дерева:") (SETQ TREE NIL)
      (LOOP
         (PRINT "Введите очередной элемент дерева:")
         (SETQ A (READ)) ( (EQ A '!) )
         (PRINT (SETQ TREE (ADDTREE A TREE)))
      )
      (PRINT "─────────────────────────────")
      (PRIN1 "Корень дерева:               ")
         (PRINT (ROOT TREE))
      (PRIN1 "Левое поддерево:             ")
         (PRINT (LEFT TREE))
      (PRIN1 "Правое поддерево:            ")
         (PRINT (RIGHT TREE))
     (KOL 2 TREE)
   ))
   ; -----------------------------
   (DEFUN ADDTREE (LAMBDA (A TREE)
   ;  2Функция ADDTREE добавляет в дерево поиска TREE элемент A
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
   ;  2Функция ROOT возвращает корень дерева TREE
      (CAR TREE)
   ))
   ; ------------------------
   (DEFUN LEFT (LAMBDA (TREE)
   ;  2Функция возвращает левое поддерево дерева TREE
      (CADR TREE)
   ))
   ; -------------------------
   (DEFUN RIGHT (LAMBDA (TREE)
   ;  2Функция возвращает правое поддерево дерева TREE
      (CADDR TREE)
   ))
   ; -----------------------------

(rds)



;   16. Написать функцию,  которая вычисляет среднее арифмети-
ческое всех элементов непустого дерева T (информационное по-
ле вершины дерева содержит вещественные числа).
;
     (DEFUN SREDNEE (LAMBDA (TREE)
        ;Вычисляет сpеднее аpифметическое всех элементов
        ;  деpева
        (COND ((NULL TREE) 0)
              (T 
                 (/ (SUMMA (POSP (LISTATOMS TREE)))
                    (LENGTH (POSP (LISTATOMS TREE))))
              )
        )
     ))
;--------------------------------------------------------------;
    (DEFUN LISTATOMS (LAMBDA (TREE)
       ;Возвpащает список,состоящий из элементов (включая 
       ; NIL),входящих в деpево
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
       ;Считает сумму всех элементов списка
       (COND ((NULL L) 0)
             ((EQ (LENGTH L) 1) (CAR L))
             (T 
                (+ (CAR L) (SUMMA (CDR L))) )
       )
    ))
;-------------------------------------------------------------;
;   17. Написать функцию,  которая находит в непустом дереве T
длину  (число  ветвей)  пути от корня до ближайшей вершины с
элементом E.
;
    (DEFUN KOLVETV (LAMBDA (A TREE)
       ;Выдает длину пути (число ветвей) по деpеву до
       ; данного элемента 
       (COND ((NULL TREE) 0)
             (T 
                (- (LENGTH (PRTREE A TREE)) 1))
       )
    ))
;------------------------------------------------------------;

    (DEFUN PRTREE (LAMBDA (A TREE)
       ;Выделяет в список все узлы из данного
       ; деpева,пpедшествующие данному элементу
       (COND ((NULL TREE) NIL)
             ((EQ (CAR TREE) A) (LIST A))
             ((< (CAR TREE) A) (CONS (CAR TREE)
                                     (PRTREE A (CADDR TREE))))
             (T
                (CONS (CAR TREE) (PRTREE A (CADR TREE))))
       )
    ))
;------------------------------------------------------------;


;   18. Определить высоту дерева T,  используя функцию опреде-
ления пути от корня до данной вершины.

   (DEFUN TEST (LAMBDA NIL
      (PRINT "Построение дерева:") (SETQ TREE NIL)
      (LOOP
         (PRINT "Введите очередной элемент дерева:")
         (SETQ A (READ)) ( (EQ A '!) )
         (PRINT (SETQ TREE (ADDTREE A TREE)))
      )
      (PRINT "─────────────────────────────")
      (PRIN1 "Корень дерева:               ")
         (PRINT (ROOT TREE))
      (PRIN1 "Левое поддерево:             ")
         (PRINT (LEFT TREE))
      (PRIN1 "Правое поддерево:            ")
         (PRINT (RIGHT TREE))
     ( FFF TREE)
   ))
   ; -----------------------------
   (DEFUN FFF (LAMBDA (TREE)
     (MAXIM (TOPTOP TREE (POSP(SEE1 TREE))))
   ))

   (DEFUN SEE1 (LAMBDA (TREE)
   ;  2Обход дерева TREE слева направо и
   ;  2создание "грязного" списка
      (COND ( (ATOM TREE) TREE )
            (  T  (LIST (CAR TREE) (SEE1 (CADR  TREE))
                                   (SEE1 (CADDR TREE))) ))
   ))
   ; -----------------------------
   (DEFUN TOPTOP (LAMBDA (TREE LST)
;Создает список из расстояний от корня дерева TREE до каждого элемента
;списка LST
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






