module decoder(
	input wire [15:0] opcode,
	input wire [11:0] PC,
	output wire [3:0] op_main,
	output reg [3:0] op_sub,
	output reg [3:0] x,
	output reg [3:0] y,
	output reg [11:0] nnn,
	output reg [7:0] nn,
	output reg [3:0] n,
	output reg [2:0] alu_op,
	output wire alu_switchxy, //swap x and y if asserted
	output reg jump
//	output reg loadstore;
);

`include "alu_params.vh"
`include "chip8_cpu_opcodes.vh"

//wire [3:0] op0 = opcode[15:12];
//
always @* begin
	x = opcode[11:8];
	y = opcode[7:4];
	nnn = opcode[11:0];
	nn = opcode [7:0];
	n = opcode[3:0];
	op_main = opcode[15:12];
end

//generate sub-command
//relevant: 0, E, F
always @* begin
	case(opcode[15:12])
		4'h0: 
			case(opcode[7:0])
				8'hE0:
					op_sub = O_DISP_CLEAR;
				8'hEE:
					op_sub = O_RETURN;
				default:
					op_sub = 3'hx;
			endcase
		4'hE:
			case(opcode[7:0])
				8'h9E:
					op_sub = O_E_KEY;
				8'hA1:
					op_sub = O_E_KEY_NOT;
				default:
					op_sub = 3'hx;
			endcase
		default:
			op_sub = 3'hx;
	endcase
end

//ALU operations
always @* begin
	if(opcode[15:12] == 4'h8) 
	begin
		case (opcode[3:0])
				4'h0:
					alu_op = ALU_Y;
				4'h1:
					alu_op = ALU_OR;
				4'h2:
					alu_op = ALU_AND;
				4'h3:
					alu_op = ALU_XOR;
				4'h4:
					alu_op = ALU_PLUS;
				4'h5:
					alu_op = ALU_MINUS;
				4'h6:
					alu_op = ALU_SHIFT_RIGHT;
				4'h7:
					alu_op = ALU_MINUS;
				4'he:
					alu_op = ALU_SHIFT_LEFT;					
				default:
					alu_op = 3'hx; //don't care
			endcase
	end else begin
		alu_op = 3'hx; //don't care
	end
end

assign alu_switchxy = opcode[15:12] == 4'h8 && opcode[3:0] == 4'h7 ? 1'b1 : 1'b0;
assign op_main = opcode[15:12];

endmodule