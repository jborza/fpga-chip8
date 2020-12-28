
`timescale 1ps / 1ps
module ppu_sim  ; 

reg clk;
reg reset;
 
wire we; //ram write enable
wire [11:0] write_address;
wire [11:0] read_address;
wire [7:0] ram_in;
wire [7:0] ram_out;
	
wire [7:0] rom_out;

reg ppu_draw;
wire ppu_busy;
wire ppu_collision;
wire [11:0] ppu_mem_read_address;
wire [11:0] ppu_mem_write_address;
wire [7:0] ppu_mem_read_data;
wire [7:0] ppu_mem_write_data;
wire ppu_mem_read_enable;
wire ppu_mem_write_enable;

reg [7:0] vx;
reg [7:0] vy;
reg [11:0] I;
reg [3:0] n;
  
  chip8_ram ram(
	.clk(clk),
	.q(ram_out),
	.d(ram_in),
	.write_address(write_address), 
	.read_address(read_address), 
	.we(we)
);

ppu DUT(
	.clk(clk),
	.reset(reset),
	.draw(ppu_draw),
	.address(I),
	.sprite_height(n),
	.x(vx),
	.y(vy),
	.busy(ppu_busy),
	.collision(ppu_collision),
	.mem_read_address(read_address),
	.mem_read_data(ram_out),
	.mem_read_enable(ppu_mem_read_enable),
	.mem_write_address(write_address),
	.mem_write_data(ram_in),
	.mem_write_enable(we)
);

	initial begin
		//initialize clock input
		clk = 0;
	end
	
	initial begin
		reset = 1;
		# 100
		reset = 0;
		# 20
		ppu_draw = 1;
		vx = 'hc;
		vy = 'h8;
		n = 'hf;
		I = 'hA22A;		
		# 20
		//reset 
		ppu_draw = 0;
		
	end

   always
	#10 clk=!clk;
	
	//stop the simulation after the PPU stops working
	always begin
		#1000
		if(ppu_busy == 0 && ppu_draw == 0) 
		begin
			#100
			$stop;
		end
	end

  initial
	#10000 $stop;
endmodule
