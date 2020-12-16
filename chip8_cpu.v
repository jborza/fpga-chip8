module chip8_cpu(
	input wire clk,
	input wire reset,
	output reg[11:0] address_out,
	input wire [7:0] data_in,
	output reg write_enable,
	output reg [7:0] data_out,
	input wire [15:0] keys
);

`include "chip8_cpu_opcodes.vh"

//display RAM (
//chip-8 RAM
//V0..VF registers
//I register
//stack
//delay timer
//sound timer
//keypad states

//////////////////
// CPU register file

reg [15:0] I;
reg [15:0] PC = 12'h200; //could be 12-bit only
reg [7:0] reg_V[15:0]; //V0..VF
reg [15:0] stack[15:0]; //16-word stack
reg [3:0] SP; //stack pointer
reg [7:0] delay_timer;
reg [7:0] sound_timer;
	

//divide the clock to 540 ticks per second and 60 timer ticks per second

localparam CPU_TICKS_PER_SECOND = 540;
localparam CLOCKS_PER_CPU_TICK = 50_000_000 / CPU_TICKS_PER_SECOND;
localparam CPU_TICKS_PER_TIMER_TICK = 9; //540/60

reg [31:0] tick_counter;

reg [7:0] vx;
reg [7:0] vy;

//instruction decode results
reg [15:0] opcode;

wire [3:0] x;
wire [3:0] y;
wire [11:0] nnn; 
wire [7:0] nn; 
wire [3:0] n; 
wire alu_switchxy;
wire jump;
wire [2:0] alu_op;
reg cpu_tick;
wire [3:0] op_main;
wire [3:0] op_sub;
wire [7:0] alu_out;
wire [7:0] alu_carry;

// pseudorandom generator output
wire [7:0] lfsr_out;

//CPU states
localparam [7:0] 
	state_fetch_1 = 7'h0,
	state_fetch_2 = 7'h1,
	state_fetch_end = 7'h2,
	state_decode = 7'h3,
	state_execute = 7'h4;
	
reg [7:0] state;

decoder decoder(
	.opcode(opcode),
	.op_main(op_main), 
	.op_sub(op_sub), 
	.x(x),
	.y(y),
	.nnn(nnn),
	.nn(nn),
	.n(n),
	.alu_switchxy(alu_switchxy),
	.alu_op(alu_op)
);

ALU alu(
	.X(vx),
	.Y(vy),
	.operation(alu_op),
	.out(alu_out),
	.carry_out(alu_carry)
);

lfsr lfsr(
	.clk(clk),
	.enable(1'b1),
	.out(lfsr_out)
);

//TODO reset the registers on reset signal


//cpu tick enabler
always @(posedge clk) begin
	//TODO reset
	if(tick_counter == 0) begin
		tick_counter = CLOCKS_PER_CPU_TICK;
		cpu_tick <= 1'b1;
	end else begin
		tick_counter <= tick_counter - 1;	
		cpu_tick <= 1'b0;
	end
end

//timer countdown
always @(posedge clk) begin
	if(cpu_tick) begin
		if(delay_timer > 0)
			delay_timer <= delay_timer - 1'b1;
		if(sound_timer > 0)
			sound_timer <= sound_timer - 1'b1;
	end
end

//TODO see https://github.com/asinghani/pifive-cpu/blob/main/cpu/rtl/decode/decode.sv
always @(posedge clk) begin 
	if(cpu_tick) begin
		write_enable <= 1'b1;
		//fetch, decode, execute
		//fetch byte 1
		case(state)
				state_fetch_1:
				begin
					//MAR = PC
					address_out <= PC;
					state <= state_fetch_2;
					PC <= PC + 1'b1;
				end
				state_fetch_2: 
				begin
					address_out <= PC;
					PC <= PC + 1'b1;
					//store first half of opcode 
					opcode[15:8] <= data_in;
					state <= state_fetch_end;
				end
				state_fetch_end: 
				begin
					//store second half of opcode
					opcode [7:0] = data_in;	
					state <= state_decode;
				end
				state_decode:
				begin
					//retrieve vx, vy
					vx = reg_V[x];
					vy = reg_V[y];
					state <= state_execute;
					//do stuff based on the main and sub opcode
				end
				state_execute:
				begin
					case (op_main)
						4'h8: //ALU
							begin
							reg_V[x] <= alu_out;
							reg_V[15] <= alu_carry;
							end
						4'h0: // display / flow
							case (op_sub)
								4'h0: begin
									//TODO clear screen
								end
								4'h1: // return from subroutine
								begin
									PC <= stack[SP-1'b1];
									SP <= SP - 1'b1;
								end							
							endcase
						4'h1: //goto NNN
							PC <= nnn;
						4'h2: //call NNN
						begin
							// call subroutine
							stack[SP] <= PC;
							SP <= SP + 1'b1;
							PC <= nnn;
						end
						4'h3: //condition - if(vx==NN) skip next
						begin
							if(vx==nn) begin
								PC <= PC + 2'd2;
							end
						end
						4'h4: // if(vx != NN)
						begin
							if(vx!=nn) begin
								PC <= PC + 2'd2;
							end
						end
						4'h5: // if(vx == vy)
						begin
							if(vx==vy) begin
								PC <= PC + 2'd2;
							end
						end
						4'h6: // vx = nn
							reg_V[x] <= nn;
						4'h7: // vx += nn
							reg_V[x] <= reg_V[x] + nn;
						4'hA:
							I <= nnn;
						4'hB:
							PC <= reg_V[0] + nnn;
						4'hC: // random & NN
							reg_V[0] <= lfsr_out & nn;
						//TODO 4'hD draw
						4'hD:
							reg_V[3] <= I; //DUMMY assignment
						//TODO 4'hE
						4'hE:
							case (op_sub)
								O_E_KEY: //if(key()==Vx)
								begin
									PC <= PC + 2'd2;
								end
								O_E_KEY_NOT: //if(key()!=Vx)
								begin
									PC <= PC + 2'd2;
								end
							endcase
						4'hF:
							case (op_sub)
								O_FX07:
									reg_V[x] <= delay_timer;
								O_FX0A:
									//TODO get key, also don't advance PC if it's not pressed
									reg_V[x] <= 8'hFF;
								O_FX15:
									//TODO delay timer - avoid clash with delay timer decrementer
//									delay_timer <= vx;
								O_FX18:
									sound_timer <= vx;
								O_FX1E: // I += Vx
									I <= I + vx;
								O_FX29: //TODO sprites
									I <= 8'hFF;
								O_FX33: //TODO BCD - 3/4 step FSM
									begin
									address_out <= I;
									data_out <= 8'hFF;
									write_enable <= 1'b1;
									end
								O_FX55: //reg_dump - FSM
									begin
									address_out <= I;
									write_enable <= 1'b0;
									data_out <= reg_V[x]; //0 to X
									end
								O_FX65: //reg load - FSM
									begin
									address_out <= I;
									//TODO increase offset
									reg_V[x] <= data_in; //0 to X
									end
							endcase
							
					endcase
				end
					//determine next state based on the opcode
//				default:
//				
		endcase
		
	end
end

endmodule