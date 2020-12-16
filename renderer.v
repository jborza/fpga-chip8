/* copies area 0x100 to 0x1ff while doing pixel doubling */
// v0.1 just does 64x32 px
module renderer(
	input wire clk,
	output reg[9:0] fb_write_address,
	output reg fb_write_enable,
	output reg[7:0] fb_ram_in,
	output reg[11:0] cpu_ram_read_address,
	input wire[7:0] cpu_ram_out,
	input wire start_signal,
	output reg finished_signal
);

reg running;
reg [9:0] write_address;
reg [11:0] read_address;

always @(posedge clk)
begin
	if(start_signal)
	begin
		running <= 'b1;
		read_address <= 'h100;
		write_address <= 'h0;
	end
	else if(running)
	begin
		finished_signal <= 'b0;
		
		read_address <= read_address + 'b1;
		write_address <= write_address + 'b1;
		
		fb_ram_in <= cpu_ram_out;
		fb_write_enable <= 'b1;
		cpu_ram_read_address <= read_address;
		fb_write_address <= {write_address[7:3], 2'b00 ,  write_address[2:0]};		
		if(read_address == 'h1ff) //'h1ff)
		begin
			running <= 'b0;
			finished_signal <= 'b1; 
		end
	end
end

//finished signal deactivator
//always @(posedge clk)
//begin
//	if(finished_signal)
//		
//end

endmodule