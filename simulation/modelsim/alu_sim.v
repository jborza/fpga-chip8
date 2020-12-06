
`timescale 1ps / 1ps
module alu_sim  ; 
 
  wire  carry_out   ; 
  wire  [7:0]  out   ; 
  reg  [7:0]  X   ; 
  reg  [2:0]  operation   ; 
  reg  [7:0]  Y   ; 
  ALU  
   DUT  ( 
       .carry_out (carry_out ) ,
      .out (out ) ,
      .X (X ) ,
      .operation (operation ) ,
      .Y (Y ) ); 

   reg [2 : 0] \VARoperation ;


// "Constant Pattern"
// Start Time = 0 ps, End Time = 1 ns, Period = 0 ps
  initial
  begin
	 X = 8'h1;
	 Y = 8'h2;
	 # 160 ;
	 X = 8'h20;
	 Y = 8'h40;
	 # 160;
	 X  = 8'h80;
	 Y = 8'h1F;
	 # 160 ;
	 X  = 8'h80;
	 Y  = 8'h7F;
	 # 160;
	 X = 8'h80;
	 Y = 8'h80;
	 # 160
	 X = 8'h80;
	 Y = 8'h81;
	 # 160
	 X = 8'hFF;
	 Y = 8'hFF;
	 # 160;
	 X = 8'hFF;
	 Y = 8'h01;
	 # 160;
// dumped values till 1 ns
  end



// "Counter Pattern"(Range-Up) : step = 1 Range(000-111)
// Start Time = 0 ps, End Time = 1 ns, Period = 10 ps
  initial
  begin
   repeat(8)
   begin
	\VARoperation = 3'b000 ;
	 operation  = 3'b000  ;
	repeat(7)
	  begin
	  \VARoperation = \VARoperation  + 1 ;
	  #20  operation  = \VARoperation  ;
	  end
	 #20 ;
// 160 ps, repeat pattern in loop.
   end
  end

  initial
	#2000 $stop;
endmodule
