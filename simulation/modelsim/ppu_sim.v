
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

  task assert_true;
    input x;
    begin
      if (!x) begin
        $error($time, " Assertion failed");
        $finish_and_return(1);
      end
    end
  endtask
  
 task assert_equal;
    input [31:0] x;
    input [31:0] y;
    begin
      if (x != y) begin
        $error($time, " %x != %x", x, y);
        $stop;
      end
    end
  endtask

	initial begin
		//initialize clock input
		clk = 0;
	end
	
	initial begin
		# 10 
		reset = 1;
		ppu_draw = 0;
		vx = 'h0;
		vx = 'h0;
		# 40
		reset = 0;
		# 20
		ppu_draw = 1;
		vx = 'hc;
		vy = 'h8;
		n = 'hf;
		I = 'h22A;		
		# 20
		//reset 
		ppu_draw = 0;
		
	end

   always
	#10 clk=!clk;
	
	//stop the simulation after the PPU stops working
  	initial begin
		//give PPU some time to process
		#500 ;
		while (ppu_busy == 1 || ppu_draw == 1) 
		begin
			#10 ;
		end
			//validate whether the logo is at the correct location!
			assert_equal(ppu_collision, 0);
			assert_equal(ram.mem['h141], 'h0f);
			assert_equal(ram.mem['h142], 'hf0);
			//2nd row - zeroes
			assert_equal(ram.mem['h149], 'h00);
			assert_equal(ram.mem['h14A], 'h00);
			//3rd row - 0f f0
			assert_equal(ram.mem['h151], 'h0f);
			assert_equal(ram.mem['h152], 'h0f);
			//4th row - zeroes
			assert_equal(ram.mem['h159], 'h00);
			assert_equal(ram.mem['h15A], 'h01);
			//5th row - 03 c0
			assert_equal(ram.mem['h161], 'h03);
			assert_equal(ram.mem['h162], 'hc0);
			//6th row - 00 00
			assert_equal(ram.mem['h169], 'h0f);
			assert_equal(ram.mem['h16A], 'h0f);

			$stop;
	end

  initial
	#2000 $stop;
endmodule
