
`timescale 1ps / 1ps
module cpu_sim; 
 
  reg clk;
  wire [15:0] keys;
  
  //ram wires
  wire we; //ram write enable
	wire [11:0] write_address;
	wire [11:0] read_address;
	wire [7:0] ram_in;
	wire [7:0] ram_out;
	
  wire [7:0] data_in;
  
  chip8_ram ram(
	.clk(clk),
	.q(ram_out),
	.d(ram_in),
	.write_address(write_address), 
	.read_address(read_address), 
	.we(we)
);

  dummy_rom_fx55 rom(
	 .read_address(read_address),
	 .rom_out(data_in)
  );

	chip8_cpu DUT(
	.clk(clk),
	.reset(1'b0),//(~reset),
	.address_in(read_address),
	.address_out(write_address),
	.data_in(data_in),
	.write_enable(we),
	.data_out(ram_in),
	.keys(keys)
);

	initial begin
		//initialize input
		clk = 0;
	end

   always
	#10 clk=!clk;
	
//  initial
//  begin
//   #100
	
//	#100 data_in = 8'h00E0;
//	#100 data_in = 8'hA22A;
//	#100 data_in = 8'h600C;
//	#100 data_in = 8'h6108;
//	#100 data_in = 8'hD01F;
//	#100 data_in = 8'h7009;
//	#100 data_in = 8'hA239;
//	#100 data_in = 8'hD01F;
//	#100 data_in = 8'hA248;
//	#100 data_in = 8'h7008;
//	#100 data_in = 8'hD01F;
//	#100 data_in = 8'h7004;
//	#100 data_in = 8'hA257;
//	#100 data_in = 8'hD01F;
//	#100 data_in = 8'h7008;
//	#100 data_in = 8'hA266;
//	#100 data_in = 8'hD01F;
//	#100 data_in = 8'h7008;
//	#100 data_in = 8'hA275;
//	#100 data_in = 8'hD01F;
//	#100 data_in = 8'h1228;
//	#100 data_in = 8'h1228;
//	#100 data_in = 8'h1228;
//	#100 data_in = 8'h1228;
//	#100 data_in = 8'h1228;
//	#100 data_in = 8'h1228;
//	#100 data_in = 8'h1228;
//	#100 data_in = 8'h1228;
//  end
  

  initial
	#10000 $stop;
endmodule
