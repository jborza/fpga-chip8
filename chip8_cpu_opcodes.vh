/*
CHIP-8 CPU
sub-operation encoding:

0XXX:
0: E0
1: EE

EXXX:
2: 9E
3: A1

FXXX
4: 07
5: 0A
6: 15
7: 18
8: 1E
9: 29
A: 33
B: 55
B: 65
*/

localparam O_DISP_CLEAR = 4'h0;
localparam O_RETURN = 4'h1;
localparam O_E_KEY = 4'h2;
localparam O_E_KEY_NOT = 4'h3;
localparam O_FX07 = 4'h4;
localparam O_FX0A = 4'h5;
localparam O_FX15 = 4'h6;
localparam O_FX18 = 4'h7;
localparam O_FX1E = 4'h8;
localparam O_FX29 = 4'h9;
localparam O_FX33 = 4'hA;
localparam O_FX55 = 4'hB;
localparam O_FX65 = 4'hC;