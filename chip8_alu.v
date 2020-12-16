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


module ALU(
	input wire [7:0] X,
	input wire [7:0] Y,
	input wire [2:0] operation,
	output reg [7:0] out,
	output reg carry_out
);

`include "alu_params.vh"

//calculate the logic operations
always @* begin
	case (operation)
		ALU_Y:
			begin
			out = Y;
			carry_out = 1'b0;
			end
		ALU_OR:
			begin
			out = X | Y;
			carry_out = 1'b0;
			end
		ALU_AND:
			begin
			out = X & Y;
			carry_out = 1'b0;
			end
		ALU_XOR: 
			begin
			out = X ^ Y;
			carry_out = 1'b0;
			end
		ALU_PLUS: begin
			{ carry_out, out} = X + Y;
			end
		ALU_MINUS: //x-y
			begin
			carry_out = X > Y ? 1'b1: 1'b0;
			out = X - Y;
			end
		ALU_SHIFT_RIGHT: begin //store the LSB in carry, shift right
			carry_out = X[0];
			out = X >> 1;
			end
		ALU_SHIFT_LEFT: begin //store MSB in carry, shift right
			carry_out = X[7];
			out = X << 1;
			end
	endcase
end

endmodule