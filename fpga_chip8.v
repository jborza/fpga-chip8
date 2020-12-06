module fpga_chip8(
	input wire clk,
	input wire reset, //active low
	output reg led,
	output wire rs, rw, en, //LCD control pins
	output wire [7:0] dat //LCD data
);

reg [31:0] timer;                  
localparam  TIMER_LIMIT = 5_000_000;

always@(posedge clk) begin
	if (timer == TIMER_LIMIT) begin    
		timer <= 0;                       
		led <= ~led;	
   end else
	   timer <= timer + 1'b1;
end

// memory wires
reg we; //ram write enable
reg [9:0] write_address;
wire [9:0] read_address;
reg [7:0] ram_in;
wire [7:0] ram_out;
wire [7:0] ascii_scan_data;
reg [9:0] current_address = 6'h0;

// display pixel buffer
ram ram(
   .clk(clk),
	.q(ram_out), 
	.d(ram_in), 
	.write_address(write_address), 
	.read_address(read_address), 
	.we(we)
);

// display controller
LCD12864 lcd(
		.clk(clk),
		.rs(rs), 
		.rw(rw), 
		.en(en), 
		.dat(dat),
		.address_out(read_address),
		.data_in(ram_out)
);

chip8_cpu cpu(
	.clk(clk),
	.reset(~reset)
);

endmodule