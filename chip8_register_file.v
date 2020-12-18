//16 x 8-bit registers
//triple-port (1 in, 2 out)
module register_file(
	input wire clk,
	input wire reset,
	input wire write_enable,
	input wire [3:0] select_input,
	input wire [7:0] input_data,
	input wire [3:0] select_output1,
	input wire [3:0] select_output2,
	output reg [7:0] output1_data,
	output reg [7:0] output2_data
);

//registers
reg [7:0] regs[15:0]; //V0..VF
integer i; 

always @(posedge clk)
begin
	if(reset) begin
		for (i = 0; i < 16; i = i + 1) begin
			regs[i] = 'h0;
		end
	end else begin
		output1_data <= regs[select_output1];
		output2_data <= regs[select_output1];
	
		if(write_enable) begin
			regs[select_input] <= input_data;
		end
	end

end

endmodule