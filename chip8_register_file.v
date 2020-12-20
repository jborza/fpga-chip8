//16 x 8-bit registers
//triple-port (1 in, 2 out)
module register_file(
	input wire clk,
	input wire reset,
	input wire write_enable,
	input wire [3:0] select_input,
	input wire [7:0] input_data,
	input wire [3:0] select_output1,
	output wire [7:0] output1_data);

//registers
reg [7:0] regs[15:0]; //V0..VF
integer i; 

initial begin
	for (i = 0; i < 16; i = i + 1) begin
			regs[i] = 8'h0;
	end
end

assign output1_data = regs[select_output1];

always @(posedge clk)
begin
	if(reset) begin
		for (i = 0; i < 16; i = i + 1) begin
			regs[i] = 8'h0;
		end
	end else begin
	
		if(write_enable) begin
			regs[select_input] <= input_data;
		end
	end

end

endmodule