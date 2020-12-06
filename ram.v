module ram(
	clk, 
	read_address,
	d,
	write_address,
	q,
	we
);
	//inputs, outputs
	input wire clk;
	input [9:0] read_address;
	input [7:0] d; //input data
	input [9:0] write_address;
	output reg [7:0] q; //output data
	input  we;

	reg [7:0] mem [1023:0]; //128*64 bits = 8192 bits = 1024 bytes
	
	initial begin
		$readmemb("ram.txt", mem);
	end
	
	always @(posedge clk) begin
		if(we) begin
			mem[write_address] <= d;
		end
		q <= mem[read_address];
	end

endmodule