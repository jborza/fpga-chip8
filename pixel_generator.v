module pixel_generator(
	input wire clk,
	input wire video_on,
	input wire [9:0] pixel_x, //0 to 640
	input wire [9:0] pixel_y, //0 to 480
	output reg [2:0] rgb,
	output reg [13:0] address_out,
	input wire [7:0] data_in,
	input wire [5:0] pixel_x_10,
	input wire [5:0] pixel_y_10
);


reg[2:0] address_bit_previous;
wire[2:0] address_bit;
wire[13:0] address_byte;

wire rgb_data = data_in[address_bit_previous];
assign address_byte = {pixel_y_10[5:0], pixel_x_10[5:3]};
assign address_bit = ~pixel_x_10[2:0];

always @(posedge clk) begin
	if(~video_on) begin
		rgb <= 3'b000; //blank
	end else begin
		// set the address of the byte we want to read on the next clock cycle
		address_out <= address_byte + 'h100; //add base address where the data starts in the CHIP-8 memory
		// remember the bit number we want to use on the next clock cycle
		address_bit_previous <= address_bit;
		if(pixel_y < 'd320) 
			rgb <= {rgb_data, rgb_data, rgb_data};
		else
			rgb <= 3'b100;
	end

end

endmodule