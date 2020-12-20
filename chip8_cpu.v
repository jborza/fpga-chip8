module chip8_cpu(
	input wire clk,
	input wire reset,
	output reg[11:0] address_in,
	input wire [7:0] data_in,
	output reg write_enable,
	output reg[11:0] address_out,
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
//reg [7:0] reg_V[15:0]; //V0..VF

reg [15:0] I;
reg [15:0] PC = 12'h200; //could be 12-bit only
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
wire [2:0] alu_op;
reg cpu_tick;
wire [3:0] op_main;
wire [3:0] op_sub;
wire [7:0] alu_out;
wire alu_carry;

// pseudorandom generator output
wire [7:0] lfsr_out;

reg store_v;
reg store_carry;

//CPU states
localparam [7:0] 
	state_fetch_1 = 7'h0,
	state_fetch_2 = 7'h1,
	state_fetch_end = 7'h2,
	state_decode = 7'h3,
	state_execute = 7'h4,
	state_store_v = 7'h5,
	state_store_carry = 7'h6,
	state_store_vx = 7'h7,
	state_store_vy = 7'h8,
	state_instr_b = 7'h9,
	state_save_registers = 7'ha,
	state_load_registers = 7'hb,
	state_draw = 7'hc;
	
reg [7:0] state = state_fetch_1;

reg [7:0] next_carry;

reg register_write_enable;
reg [3:0] register_read_1;
//reg [3:0] register_read_2;
reg [3:0] register_write;
reg [7:0] register_write_data;
wire [7:0] register_read_1_data;
//wire [7:0] register_read_2_data;

register_file register_file_inst
(
	.clk(clk) ,	// input  clk_sig
	.reset(reset) ,	// input  reset_sig
	.write_enable(register_write_enable) ,	// input  write_enable_sig
	.select_input(register_write) ,	// input [3:0] select_input_sig
	.input_data(register_write_data) ,	// input [7:0] input_data_sig
	.select_output1(register_read_1) ,	// input [3:0] select_output1_sig
//	.select_output2(register_read_2) ,	// input [3:0] select_output2_sig
	.output1_data(register_read_1_data)	// output [7:0] output1_data_sig
//	.output2_data(register_read_2_data) 	// output [7:0] output2_data_sig
);

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

//timer countdown - TODO @ 60 Hz
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
	//if(cpu_tick) begin
		write_enable <= 1'b0; //TODO is there a better way to reset the flags?
		register_write_enable <= 1'b0; //TODO is there a better way to reset the flags?
		//fetch, decode, execute
		//fetch byte 1
		case(state)
				state_fetch_1:
				begin
					//MAR = PC
					address_in <= PC;
					PC <= PC + 1'b1;
					state <= state_fetch_2;
				end
				state_fetch_2: 
				begin
					address_in <= PC;
					PC <= PC + 1'b1;
					//store first half of opcode 
					opcode[15:8] <= data_in;
					state <= state_fetch_end;
				end
				state_fetch_end: 
				begin
					//store second half of opcode
					opcode [7:0] <= data_in;	
					state <= state_decode;					
				end
				state_decode: //decoder now decoded x,y
				begin
					//retrieve vx, then vy
					register_read_1 <= x;
					state <= state_store_vx;
				end
				state_store_vx:
				begin
					//store vx, retrieve vy
					vx <= register_read_1_data;
					register_read_1 <= y;
					state <= state_store_vy;
				end
				state_store_vy:
				begin
					vy <= register_read_1_data;
					state <= state_execute;
				end
				state_store_v: //store reg[vx] and potentially reg[15] with the carry flag
				begin
					if(store_v) begin
						register_write <= x;
						register_write_data <= vx;
						register_write_enable <= 1'b1;
						store_v <= 1'b0;
					end
					if(store_carry) begin
						state <= state_store_carry;
					end
					else
						state <= state_fetch_1;
				end
				state_store_carry:
				begin
					register_write_enable <= 1'b1;
					register_write_data <= next_carry;
					register_write <= 15;
					store_carry <= 1'b0;
					state <= state_fetch_1;
				end
				state_instr_b:
				begin //we requested data into register_read_1
					PC <= register_read_1_data + nnn;
				end
				state_save_registers:
				begin
					//fill memory at I to I+x (inclusive!) with values of v0 to vx
					if(register_read_1 <= x) begin
						write_enable <= 1'b1;
						//set output value to I + i
						address_out <= I + register_read_1;
						//set output data to V[i]
						data_out <= register_read_1_data; //register file output now contains i-1						
						//increment i
						register_read_1 <= register_read_1 + 1;
					end else
						state <= state_fetch_1;
				end
				
				state_load_registers:
				begin
					// TODO implement
				end
				
				state_execute:
				begin
					state <= state_fetch_1;
					case (op_main)						
						4'h0: // display / flow
							case (op_sub)
								O_DISP_CLEAR: begin
									//TODO clear screen
								end
								O_RETURN: // return from subroutine
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
							begin
							vx <= nn;
							store_v <= 1'b1;
							state <= state_store_v;
							end
						4'h7: // vx += nn
						begin
							vx <= vx + nn;
							store_v <= 1'b1;							
							state <= state_store_v;
						end
						4'h8: //ALU
							begin
							vx <= alu_out;
							store_v <= 1'b1;
							next_carry <= alu_carry;
							store_carry <= 1'b1;
							end
						4'h9: //if(vx != vy)
							begin
								if(vx!=vy) begin
									PC <= PC + 2'd2;
								end
							end
						4'hA:
							I <= nnn;
						4'hB:
							// one more cycle to fetch V[0];
							begin
							state <= state_instr_b;
							register_read_1 <= 0;
							end
						4'hC: // random & NN
						begin
							vx <= lfsr_out & nn;
							store_v <= 1'b1;
						end
						//TODO 4'hD draw
						4'hD:
							vx <= I; //DUMMY assignment
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
									begin
									vx <= delay_timer;
									store_v <= 1'b1;
									end
								O_FX0A:
									//TODO get key, also don't advance PC if it's not pressed
									begin
									vx <= 8'hFF;
									store_v <= 1'b1;
									end
								//O_FX15:
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
								O_FX55: //TODO reg_dump - FSM
									begin
									register_read_1 <= 0;
									state <= state_save_registers;
									end
								O_FX65: //TODO reg load - FSM
									begin
									address_in <= I;
									//TODO increase offset
									vx <= data_in; //0 to X
									state <= state_load_registers;
									end
							endcase
							
					endcase
				end
					//determine next state based on the opcode
//				default:
//				
		endcase
		
	//end
end

endmodule