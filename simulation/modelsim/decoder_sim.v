
`timescale 1ps / 1ps
module decoder_sim  ; 

  wire  [3:0]  op_sub   ; 
  reg  [11:0]  PC   ; 
  wire  [3:0]  op_main   ; 
  wire  jump   ; 
  wire  [3:0]  x   ; 
  wire  [2:0]  alu_op   ; 
  wire  [3:0]  y   ; 
  reg  [15:0]  opcode   ; 
  wire  [11:0]  nnn   ; 
  wire  [7:0]  nn   ; 
  wire    alu_switchxy   ; 
  wire  [3:0]  n   ; 
  decoder 
   DUT  ( 
       .op_sub (op_sub ) ,
      .PC (PC ) ,
      .op_main (op_main ) ,
      .jump (jump ) ,
      .x (x ) ,
      .alu_op (alu_op ) ,
      .y (y ) ,
      .opcode (opcode ) ,
      .nnn (nnn ) ,
      .nn (nn ) ,
      .alu_switchxy (alu_switchxy ) ,
      .n (n ) ); 



// "Constant Pattern"
// Start Time = 0 ps, End Time = 1 ns, Period = 0 ps
  initial
  begin
	 opcode  = 16'h0000;
	 # 10 ;
	 opcode = 16'h00E0;
	 # 10 ;
	 opcode = 16'h00EE;
	 # 10 ;
	 opcode = 16'h1ABC;
	 # 10 ;
	 opcode = 16'h2ABC;
	 # 10 ;
	 opcode = 16'h3ABC;
	 # 10 ;
	 opcode = 16'h4ABC;
	 # 10 ;
	 opcode = 16'h5AB0;
	 # 10 ;
	 opcode = 16'h6ABC;
	 # 10 ;	 
	 opcode = 16'h7ABC;
	 # 10 ;	 
	 opcode = 16'h8AB0;
 	 # 10 ;	 
	 opcode = 16'h8AB5;
	 # 10 ;	 
	 opcode = 16'h8AB7;
	 # 10 ;	 
	 opcode = 16'h8ABE;
	 # 10 ;	 
	 opcode = 16'h9AB0;
	 # 10 ;	 
	 opcode = 16'hAABC;
	 # 10 ;	 
	 opcode = 16'hBABC;
	 # 10 ;	 
	 opcode = 16'hCABC;
	 # 10 ;	 
	 opcode = 16'hD345;
	 # 10 ;	 
	 opcode = 16'hEA9E;
	 # 10 ;	 
	 opcode = 16'hEAA1;
	 # 10 ;	 
	 opcode  = 16'hFA07;
	 # 10 ;
	 opcode  = 16'hFA0A;
	 # 10 ;
	 opcode  = 16'hFA15;
	 # 10 ;
	 opcode  = 16'hFA18;
	 # 10 ;
	 opcode  = 16'hFA1E;
	 # 10 ;
	 opcode  = 16'hFA29;
	 # 10 ;
	 opcode  = 16'hFA33;
	 # 10 ;
	 opcode  = 16'hFA55;
	 # 10 ;
	 opcode  = 16'hFA65;
	 # 10 ;



	 // dumped values till 1 ns
  end


// "Constant Pattern"
// Start Time = 0 ps, End Time = 1 ns, Period = 0 ps
  initial
  begin
	  PC  = 12'b001000000000  ;
	 # 1000 ;
// dumped values till 1 ns
  end

  initial
	#2000 $stop;
endmodule
