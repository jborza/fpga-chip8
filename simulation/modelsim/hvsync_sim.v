
`timescale 1ns / 1ns
module hvsync_sim  ; 


  wire  [5:0]  counter_y_10   ; 
  wire  [9:0]  counter_y   ; 
  wire   in_display_area   ; 
  wire    vga_h_sync   ; 
  reg    clk   ; 
  wire  [5:0]  counter_x_10   ; 
  wire  [9:0]  counter_x   ; 
  wire    vga_v_sync   ; 
  reg reset;

  hvsync_generator   
   DUT  ( 
		.clk (clk ) ,
		.reset(reset),
       .counter_y_10 (counter_y_10 ) ,
      .counter_y (counter_y ) ,
      .in_display_area (in_display_area ) ,
      .vga_h_sync (vga_h_sync ) ,
      
      .counter_x_10 (counter_x_10 ) ,
      .counter_x (counter_x ) ,
      .vga_v_sync (vga_v_sync ) ); 

	initial begin
		//initialize input
		clk = 0;
		reset = 0;
	end
	
	//reset and register settling
	initial begin
		reset = 1;
		#100;
		reset = 0;
	end


   always
	#10 clk=!clk;
 
   initial begin
	    $display("\t\ttime,\tclk,\tx,\ty,\tx_10,\ty_10,\thsync,\tvsync,\tin_disp");		 
//	    $monitor("%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d",
//	             $time,clk,counter_x,counter_y,counter_x_10,counter_y_10,vga_h_sync,vga_v_sync,in_display_area);
	end


  initial
	#10000000 $stop;
endmodule
