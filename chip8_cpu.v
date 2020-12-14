module chip8_cpu(
	input wire clk,
	input wire reset,
	output reg[11:0] out_address,
	input wire [7:0] in_data
);

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

reg [15:0] reg_I;
reg [11:0] PC; //should be 12-bit only
reg [7:0] reg_V[3:0]; //V0..VF
reg [15:0] stack[3:0]; //16-word stack
reg [7:0] delay_timer;
reg [7:0] sound_timer;
	

//divide the clock to 540 ticks per second and 60 timer ticks per second

localparam CPU_TICKS_PER_SECOND = 540;
localparam CLOCKS_PER_CPU_TICK = 50_000_000 / CPU_TICKS_PER_SECOND;
localparam CPU_TICKS_PER_TIMER_TICK = 9; //540/60

reg[31:0] tick_counter;

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

//CPU states
localparam [7:0] 
	state_fetch_1 = 7'h0,
	state_fetch_2 = 7'h1,
	state_fetch_end = 7'h2,
	state_decode = 7'h3;
	
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
	.X(alu_x),
	.Y(alu_y),
	.operation(alu_op),
	.out(alu_out),
	.carry_out(alu_carry)
);

//    case 0xA000:
//        //set index register to NNN
//        state->I = opcode & 0x0FFF;
//        break;
//		  
//	    case 0x1000:
//        //jump to NNN
//        state->PC = opcode & 0x0FFF;
//        break;

//always @* begin
//	vx = opcode[11:8];
//	vy = opcode[7:4];
//	nnn = opcode[11:0];
//end

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
			delay_timer <= delay_timer - 1;
		if(sound_timer > 0)
			sound_timer <= sound_timer - 1;
	end
end

//TODO see https://github.com/asinghani/pifive-cpu/blob/main/cpu/rtl/decode/decode.sv
always @(posedge clk) begin 
	if(cpu_tick) begin
	
		//fetch, decode, execute
		//fetch byte 1
		case(state)
				state_fetch_1:
				begin
					//MAR = PC
					out_address <= PC;
					state <= state_fetch_2;
					PC <= PC + 1;
				end
				state_fetch_2: 
				begin
					out_address <= PC;
					PC <= PC + 1;
					//store first half of opcode 
					opcode[15:8] <= in_data;
				end
				state_fetch_end: 
				begin
					//store second half of opcode
					opcode [7:0] = in_data;										
				end
				state_decode:
				begin
					//retrieve vx, vy
					vx <= reg_V[x];
					vy <= reg_V[y];
				end
					//determine next state based on the opcode
//				default:
//				
		endcase
		
	end
end

endmodule