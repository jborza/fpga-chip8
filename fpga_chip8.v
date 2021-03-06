module fpga_chip8(
	input wire clk,
	input wire reset, //active low
	output reg led,
	output wire rs, rw, en, //LCD control pins
	output wire [7:0] dat, //LCD data
	output wire vga_h_sync, 
	output wire vga_v_sync, 
	output wire [2:0] vga_rgb,
	output wire [7:0] leds
);

reg [31:0] timer;                  
localparam  TIMER_LIMIT = 25_000_000;



// memory wires

// ram
wire we; //ram write enable
wire [11:0] write_address;
wire [11:0] read_address;
wire [7:0] ram_in;
wire [7:0] ram_out;

wire [7:0] ascii_scan_data;

wire [15:0] keys; //TODO wire to the debounced keypad
//reg [9:0] current_address = 6'h0;

////////////
// LCD 
///////////
// framebuffer
//reg fb_we; //ram write enable
//reg [9:0] fb_write_address;
//wire [9:0] fb_read_address;
//reg [7:0] fb_ram_in;
//wire [7:0] fb_ram_out;
//
//// display controller
//LCD12864 lcd(
//		.clk(clk),
//		.rs(rs), 
//		.rw(rw), 
//		.en(en), 
//		.dat(dat),
//		.address_out(fb_read_address),
//		.data_in(fb_ram_out)
//);
//
//// LCD display pixel buffer
//ram framebuffer(
//   .clk(clk),
//	.q(fb_ram_out), 
//	.d(fb_ram_in), 
//	.write_address(fb_write_address), 
//	.read_address(fb_read_address), 
//	.we(fb_we)
//);


//lfsr lfsr_top(
//	.clk(clk),
//	.enable(1'b1),
//	.out(lfsr_out)
//);
//
//// pseudorandom generator output
//wire [7:0] lfsr_out;

//always @(posedge clk)
//begin
//	fb_write_address <= fb_write_address + 1;
//	fb_ram_in <= fb_write_address;
//	fb_we <= 1'b1;
//end

reg renderer_start;

//renderer renderer_inst
//(
//	.clk(clk) ,	// input  clk_sig
//	.fb_write_address(fb_write_address) ,	// output [9:0] fb_write_address_sig
//	.fb_write_enable(fb_we) ,	// output  fb_write_enable_sig
//	.fb_ram_in(fb_ram_in) ,	// output [7:0] fb_ram_in_sig
//	.main_ram_read_address(read_address) ,	// output [11:0] cpu_ram_read_address_sig
//	.main_ram_out(ram_out) ,	// input [7:0] cpu_ram_out_sig
//	.start_signal(renderer_start) ,	// input  start_signal_sig
//	.finished_signal(finished_signal_sig) 	// output  finished_signal_sig
//);

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

chip8_ram ram(
	.clk(clk),
	.q(ram_out),
	.d(ram_in),
	.write_address(write_address), 
	.read_address(read_address), 
	.we(we)
);

wire [7:0] rom_out;

//dummy_rom rom(
//	.read_address(read_address_rom),
//	.rom_out(rom_out)
//);

example_rom example_rom (
	.address(read_address_rom),
	.clock(clk),
	.q(rom_out));


chip8_cpu cpu(
	.clk(clk),
	.reset(~reset),//(~reset),
	.address_in(read_address_rom),
	.address_out(write_address),
//	.data_in(ram_out),
	.data_in(rom_out),
	.write_enable(we),
	.data_out(ram_in),
	.keys(keys),
	.state_out(leds)
);





///////////////
//     VGA
//////////////

//25 mhz pixel clock
//reg pixel_tick;
//
//// 25 mhz pixel clock
//always @(posedge clk)
//begin
//	pixel_tick <= ~pixel_tick;
//end
//
//wire in_display_area;
//wire [9:0] pixel_x;
//wire [9:0] pixel_y;
//wire [6:0] pixel_x_10;
//wire [6:0] pixel_y_10;
//
//hvsync_generator syncgen(.clk(pixel_tick), 
//	.vga_h_sync(vga_h_sync), 
//	.vga_v_sync(vga_v_sync),
//	.in_display_area(in_display_area), 
//	.counter_x(pixel_x), 
//	.counter_y(pixel_y),
//	.counter_x_10(pixel_x_10),
//	.counter_y_10(pixel_y_10));
//	
//pixel_generator pixgen(
//	.clk(pixel_tick),
//	.video_on(in_display_area),
//	.pixel_x(pixel_x),
//	.pixel_y(pixel_y),
//	.rgb(vga_rgb),
//	.address_out(read_address),
//	.data_in(ram_out),
//	.pixel_x_10(pixel_x_10),
//	.pixel_y_10(pixel_y_10)
//);



endmodule