�D��         E                        ��   �  ��   �                  ��� 	�!�5���!&�G
.:u&&�G��t�I���$� 	�!�a� 	�!�L�!.�.�� �  �&��  �  ��$<�؀��@!������Ǳ��
�� 2�3���u�	�G�= u���t	�  �P��@ �2���� t,��?u�`���-u�����0|Ā�9���0�
 ���G�˅�t���u�� �*3���&�>�t���� ��uN뒴����u���p� �q�����p� �q���t�Á� �� �� 3���&�>�u���ߡ��ր�  �
�> t	9������%���!��������t�ډ�����K��6�ȋ����3�� ���t��@&�E��%��3Ҍ�����!���������BR�z�t�t��� 	�!Z� 1�!� �63����0��2 ���&��(�&*���3���&���(��* ���&��0�&2���3���&��  ���&��(�&*�0��2 ���3����(��* ���&��0�&2����
RAM is already reserved by MEMxx
$
Extended Memory is already reserved by MEMxx
$
Memory is just now reserved in RAM
$
Memory is just now reserved in Extended Memory
$MEM69.COM is FORIS TSR-utility for memory reservation.
V.M. 6.2  Copyright 1991 by FrameSoft.  All Rights Reserved.
For HELP use MEMxx ?
$
Usage: MEMxx [-][n]

Where: n is decimal size in Kb of memory to be reserved
       - is sign for Extended Memory reservation

Defaults: n=64 for RAM reservation
          n=<Extended Memory Size> for Extended Memory reservation

Warning: DON'T use MEMxx -[n] simultaneously with other TSR-programs
         which exploit Extended Memory
$    