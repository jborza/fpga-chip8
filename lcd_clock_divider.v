module lcd_clock_divider(
	clk,
	clk_div);
	
input clk;
output reg clk_div;

//localparam clk_div_ticks = 4096 - 1;

reg  [9:0] counter; 

//we want to hit 72 us per display instruction. 
always @(posedge clk) begin
	counter <= counter+1'b1; 
    //10-bit: toggled every 50,000,000 / 2048 = 24,414 Hz ~= 41 us
	//11-bit: clk_display inverted on every overflow of 11-bit counter -> is toggled every 50,000,000 / (2^11*2) = 12 khz -> 82 us
	//12-bit: clk_display inverted on every overflow of 12-bit counter -> is toggled every 50,000,000 / (2^12*2) = 6 khz ~= 163 us
	//13-bit: clk_display inverted on every overflow of 13-bit counter -> is toggled every 50,000,000 / (2^13*2) = 3 khz ~= 327 us
	if(counter == 0) begin										
		clk_div <= ~clk_div; 
	end
end
endmodule