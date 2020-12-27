// 1024 x 8-bit framebuffer
module ram(
	input wire clk, 
	input wire [9:0] read_address,
	input wire [7:0] d, //input data
	input wire [9:0] write_address,
	output reg [7:0] q, //output data
	input wire  we
);

	reg [7:0] mem [1023:0]; //128*64 bits = 8192 bits = 1024 bytes
	
	initial begin
		$readmemb("ram-fb.txt", mem);
	end
	
	always @(posedge clk) begin
		if(we) begin
			mem[write_address] <= d;
		end
		q <= mem[read_address];
	end

endmodule