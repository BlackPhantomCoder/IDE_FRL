�*��         E                              �� 	�!�5���!&�G
.:u&&�G��t�����^� 	�!��� 	�!�L�!.�.�� �  �&��  �  � C�/<�u��C�/����$<�؀��@!������Ǳ��
�� 2�3���u�	�G�= u���t	�  �P��@ �� 2���� t,��?u�E���-u�����0|Ā�9���0�
 ���G�˅�t���u� �u�� ��uH롴���t3�> t	9}��д	R�Hu�����
X��X3����À�> t9~����%���!��������t�ډ�����K��6�ȋ����3�� ���t��@&�E��%��3Ҍ�����!���������BR���t�t��� 	�!Z� 1�!��
RAM is already reserved by FSMEM
$
Extended Memory is already reserved by FSMEM
$
Memory is just now reserved in RAM
$
Memory is just now reserved in Extended Memory
$FSMEM.COM is FORIS TSR-utility for memory reservation.
V.M. 7.1  Copyright 1992 by FrameSoft.  All Rights Reserved.
For HELP use FSMEM ?
$
Usage: FSMEM [-][n]

Where: n is decimal size in Kb of memory to be reserved
       - is sign for Extended Memory reservation using HIMEM

Defaults: n=64 for RAM reservation
          n=<Extended Memory Size> for Extended Memory reservation

Warning: DON'T use MEMxx -[n] simultaneously with other TSR-programs
         which exploit Extended Memory
$    