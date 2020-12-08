/*
CHIP-8 ALU
operation encoding:
0: y
1: x|y
2: x&y
3: x^y
4: x+y with carry
5: x-y with borrow 
6: x>>1
7: x<<1
*/
localparam ALU_Y = 3'h0;
localparam ALU_OR = 3'h1;
localparam ALU_AND = 3'h2;
localparam ALU_XOR = 3'h3;
localparam ALU_PLUS = 3'h4;
localparam ALU_MINUS = 3'h5;
localparam ALU_SHIFT_RIGHT = 3'h6;
localparam ALU_SHIFT_LEFT = 3'h7;