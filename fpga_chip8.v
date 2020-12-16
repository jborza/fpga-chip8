module fpga_chip8(
	input wire clk,
	input wire reset, //active low
	output reg led,
	output wire rs, rw, en, //LCD control pins
	output wire [7:0] dat //LCD data
);

reg [31:0] timer;                  
localparam  TIMER_LIMIT = 25_000_000;



// memory wires
// framebuffer
wire fb_we; //ram write enable
wire [9:0] fb_write_address;
wire [9:0] fb_read_address;
wire [7:0] fb_ram_in;
wire [7:0] fb_ram_out;
// ram
wire we; //ram write enable
wire [11:0] write_address;
wire [11:0] read_address;
wire [7:0] ram_in;
wire [7:0] ram_out;

wire [7:0] ascii_scan_data;

wire [15:0] keys; //TODO wire to the debounced keypad
//reg [9:0] current_address = 6'h0;

// display pixel buffer
ram framebuffer(
   .clk(clk),
	.q(fb_ram_out), 
	.d(fb_ram_in), 
	.write_address(fb_write_address), 
	.read_address(fb_read_address), 
	.we(fb_we)
);

chip8_ram ram(
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
		.address_out(fb_read_address),
		.data_in(fb_ram_out)
);

chip8_cpu cpu(
	.clk(clk),
	.reset(~reset),
	//.address_out(write_address),
	.address_out(read_address),
	.data_in(ram_out),
	.write_enable(we),
	.data_out(ram_in),
	.keys(keys)
);

reg renderer_start;

renderer renderer_inst
(
	.clk(clk) ,	// input  clk_sig
	.fb_write_address(fb_write_address) ,	// output [9:0] fb_write_address_sig
	.fb_write_enable(fb_we) ,	// output  fb_write_enable_sig
	.fb_ram_in(fb_ram_in_sig) ,	// output [7:0] fb_ram_in_sig
	.cpu_ram_read_address(read_address) ,	// output [11:0] cpu_ram_read_address_sig
	.cpu_ram_out(ram_out) ,	// input [7:0] cpu_ram_out_sig
	.start_signal(renderer_start) ,	// input  start_signal_sig
	.finished_signal(finished_signal_sig) 	// output  finished_signal_sig
);


always@(posedge clk) begin
	if (timer == TIMER_LIMIT) begin    
		timer <= 0;                       
		led <= ~led;	
		renderer_start <= 1'b1;
   end else begin
	   timer <= timer + 1'b1;
		renderer_start <= 1'b0;
	end
end

endmodule