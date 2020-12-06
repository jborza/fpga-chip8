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
	input [7:0] X,
	input [7:0] Y,
	input [2:0] operation,
	output reg [7:0] out,
	output reg carry_out
);

wire [8:0] add_temp;

//calculate the logic operations
always @* begin
	case (operation)
		3'h0:
			begin
			out = Y;
			carry_out = 1'b0;
			end
		3'h1:
			begin
			out = X | Y;
			carry_out = 1'b0;
			end
		3'h2:
			begin
			out = X & Y;
			carry_out = 1'b0;
			end
		3'h3: 
			begin
			out = X ^ Y;
			carry_out = 1'b0;
			end
		3'h4: begin
			{ carry_out, out} = X + Y;
			end
		3'h5: //x-y
			begin
			carry_out = X > Y ? 1'b1: 1'b0;
			out = X - Y;
			end
		3'h6: begin //store the LSB in carry
			carry_out = X[0];
			out = X >> 1;
			end
		3'h7: begin //store MSB in carry
			carry_out = X[7];
			out = X << 1;
			end
	endcase
end

endmodule