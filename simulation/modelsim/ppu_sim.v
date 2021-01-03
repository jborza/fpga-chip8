
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

 task draw;
	input [11:0] sprite_addr;
	input [7:0] draw_x, draw_y;
	input [3:0] height;
	begin
		#20;
		I = sprite_addr;
		vx = draw_x;
		vy = draw_y;
		n = height;
		ppu_draw = 1;
		# 20;
		ppu_draw = 0;
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
		
		// draw the first character
		draw('h22A, 'hc, 'h8, 15); //I

		
		#10 wait (!ppu_busy)
		assert_equal(ppu_collision, 0);
		assert_equal(ram.mem['h141], 'h0f);
		assert_equal(ram.mem['h142], 'hf0);
		//2nd row - zeroes
		assert_equal(ram.mem['h149], 'h00);
		assert_equal(ram.mem['h14A], 'h00);
		//3rd row - 0f f0
		assert_equal(ram.mem['h151], 'h0f);
		assert_equal(ram.mem['h152], 'hf0);
		//4th row - zeroes
		assert_equal(ram.mem['h159], 'h00);
		assert_equal(ram.mem['h15A], 'h00);
		//5th row - 03 c0
		assert_equal(ram.mem['h161], 'h03);
		assert_equal(ram.mem['h162], 'hc0);
		//6th row - 00 00
		assert_equal(ram.mem['h169], 'h00);
		assert_equal(ram.mem['h16A], 'h00);
		
		// draw the second character
		draw('h239, 'h15, 'h8, 15); // B1
		
		#10 wait (!ppu_busy)
		
		assert_equal(ppu_collision, 0);
		assert_equal(ram.mem['h142], 'b11110111);
		assert_equal(ram.mem['h143], 'b11111000);
		
		//
		draw('h248, 'h1D, 'h8, 15); //B2
		
		#10 wait (!ppu_busy)   
		
		//assert_equal(ppu_collision, 0);
		//assert_equal(ram.mem['h142], 'b11110111);
		//assert_equal(ram.mem['h143], 'b11111000);
		
		draw('h257, 'h21, 'h8, 15);  //M1
		
		#10 wait (!ppu_busy)
		
//		assert_equal(ppu_collision, 0);
//		assert_equal(ram.mem['h142], 'b11110111);
//		assert_equal(ram.mem['h143], 'b11111000);
		
		draw('h266, 'h29, 'h8, 15);  //M2
		
		#10 wait (!ppu_busy)
		
//		assert_equal(ppu_collision, 0);
//		assert_equal(ram.mem['h142], 'b11110111);
//		assert_equal(ram.mem['h143], 'b11111000);
		
		draw('h275, 'h31, 'h8, 15);  //M3
		
		#10 wait (!ppu_busy);
		
//		assert_equal(ppu_collision, 0);
//		assert_equal(ram.mem['h142], 'b11110111);
//		assert_equal(ram.mem['h143], 'b11111000);
		
	end

   always
	#10 clk=!clk;
	


  initial
	#10000 $stop;
endmodule
