module dummy_rom_fx55(
	input wire [11:0] read_address,
	output reg [7:0] rom_out
);

always @* begin
	case (read_address)
 12'h200: rom_out <= 8'h60;
 12'h201: rom_out <= 8'hEA;
 12'h202: rom_out <= 8'h61;
 12'h203: rom_out <= 8'hAC;
 12'h204: rom_out <= 8'h62;
 12'h205: rom_out <= 8'hAA;
 12'h206: rom_out <= 8'h63;
 12'h207: rom_out <= 8'hE9;
 12'h208: rom_out <= 8'hA0;
 12'h209: rom_out <= 8'h00;
 12'h20A: rom_out <= 8'hF3;
 12'h20B: rom_out <= 8'h55;
 12'h20C: rom_out <= 8'hA0;
 12'h20D: rom_out <= 8'h00;
 12'h20E: rom_out <= 8'h60;
 12'h20F: rom_out <= 8'h00;
 12'h210: rom_out <= 8'hD0;
 12'h211: rom_out <= 8'h04;
  default: rom_out <= 8'h00;
	
	endcase
end

endmodule