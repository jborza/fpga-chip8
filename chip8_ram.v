//12-bit 4096 cells of 8-bit values
module chip8_ram(
	input wire clk, 
	input wire [11:0] read_address,
	input wire [7:0] d, //input data
	input wire [11:0] write_address,
	output reg [7:0] q, //output data
	input wire  we
);

	reg [7:0] mem [0:4095]; 
	
	initial begin
		$readmemb("ram-chip8.txt", mem);
	end
	
	always @(posedge clk) begin
		if(we) begin
			mem[write_address] <= d;
		end
		q <= mem[read_address];
	end

endmodule