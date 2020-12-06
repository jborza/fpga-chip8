//let's have a module that displays data off 64-byte RAM
// connected to a [7:0] ram[63:0]
	module LCD12864 (clk, rs, rw, en, dat, address_out, data_in);  
 input clk;  
 output rs,rw,en;
 output [7:0] dat; //display data pins
 output reg [9:0] address_out; //goes to the RAM
 input [7:0] data_in;      //comes from the RAM
 
 reg [7:0] dat; 
 reg rs;   
 reg [5:0] current, next = 6'h0; //state machine states
 wire clk_display; 
 
 //display coordinates
 reg [3:0] x; //0..15 (0..127)
 reg [5:0] y; //0..63
 
 wire [7:0] y_out;
 wire [7:0] x_out;
 
 
 // state machine states
 parameter  set0=6'h0; 
 parameter  set1=6'h1; 
 parameter  set2=6'h2; 
 parameter  set3=6'h3; 

 parameter  nul=6'h3F;  
 
 // end of state machine states
 
 // line offsets
 localparam line0=8'h80;
 localparam line1=8'h90;
 localparam line2=8'h88;
 localparam line3=8'h98;
 
 // ST7920 display instructions
 localparam SET_8BIT_BASIC_INSTR = 8'b00110000;
 localparam SET_DISP_ON_CURSOR_OFF_BLINK_OFF = 8'b00001100;
 localparam SET_CURSOR_POS = 8'b00000110;
 localparam CLEAR = 8'h1;
 localparam STANDBY = 8'b00000000;
 localparam HOME = 8'b00000010;
 
 parameter y_initial = 8'b10000000;
 parameter x_initial = 8'b10000000;
 
 parameter SET_MODE_8BIT = 8'b00110000;
 parameter SET_MODE_GRAPHIC = 8'b00110110;
 parameter DISPLAY_ON_CURSOR_OFF_BLINK_OFF = 8'b00001100;
 
 localparam address_vertical = 7, address_horizontal=8;
 localparam data_address_vertical=6'd9, data_address_horizontal=6'd10, data2=6'd11, data3=6'd12;
 
 lcd_clock_divider divider(
	.clk(clk),
	.clk_div(clk_display)
 );
 

 task command;
	input [7:0] data;
	input [5:0] next_state;
	
	begin
		rs <= 0;
		dat <= data;
		next <= next_state;
	end
 endtask

always @(posedge clk_display) 
begin 
 //if(clk_display) begin
  current<=next; 
  case(next) 
    set0: begin command(SET_MODE_8BIT, set1); y <= 0; /*pattern <= 0;*/ end // 8-bit interface   
	 set1: begin command(DISPLAY_ON_CURSOR_OFF_BLINK_OFF, set2); end  // display on       
	 set2: begin command(SET_MODE_GRAPHIC, set3); end // extended instruction set
	 set3: begin command(SET_MODE_GRAPHIC, data_address_vertical); x <= 0; address_out <= 0; end //graphic mode on
	 
	 //GDRAM address is set by writing 2 consecutive bytes for vertical address and horizontal address. 
	 //Two-bytes data write to GDRAM for one address. Address counter will automatically increase by one for the next two-byte  data.
	 	 
	 data_address_vertical: begin command(y + y_initial, data_address_horizontal); end //address_vertical
	 data_address_horizontal: begin command(x + x_initial, data2); end //address_horizontal
	 data2: begin
		//first 8 pixels
		rs <= 1;
		dat <= data_in;
		address_out <= address_out + 1;
		//don't increment x as one coordinate refers to 16 bits / pixels
		next <= data3;
	 end
	 data3: begin
		//next 8 pixels
		rs <= 1;
		dat <= data_in;
		address_out <= address_out + 1;
		x <= x + 1;
		if (x == 15) begin
			y <= y + 1; 
			x <= 0; //x wraps around, we shouldn't need this
			next <= data_address_vertical;
		end else begin
			next <= data2;
		end
		if(x == 15 && y == 31) begin //test for first N rows
			y <= 0;
			address_out <= 0;
		end
	 end	 		

   default:   next=set0; 
    endcase 
  //end
 end 

assign en=clk_display; 
assign rw=0; 
endmodule  