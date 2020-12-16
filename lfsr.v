module lfsr(
	 input clk, 
	 input enable,
	 output reg [7:0] out = 255
);

//8,6,5,4 - https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Some_polynomials_for_maximal_LFSRs
wire linear_feedback;
assign linear_feedback = (out[7] ^ out[5] ^ out[4] ^ out[3]);

always @(posedge clk) begin
	if(enable)
		out <= { out[6] , out[5], out[4], out[3], out[2], out[1], out[0], linear_feedback};

end

endmodule