// VGA h/v sync generator for 640x480 @ 60 Hz

module hvsync_generator(
    input clk,
	 input reset,
    output vga_h_sync,
    output vga_v_sync,
    output reg in_display_area,
    output reg [9:0] counter_x,
    output reg [9:0] counter_y,
	 output reg [5:0] counter_x_10, //x counter divided by 10
	 output reg [5:0] counter_y_10 //y counter divided by 10
  );
  
	 //pixel scaling counters
	 reg [3:0] pixel_scaler_x = 0;
	 reg [3:0] pixel_scaler_y = 0;
	 

    //hsync and vsync buffers
    reg vga_HS, vga_VS;

    //640x480 constants
    localparam H_DISPLAY = 640;
    localparam H_LEFT_BORDER = 48;
    localparam H_RIGHT_BORDER = 16;
    localparam H_RETRACE = 96;

    localparam V_DISPLAY = 480;
    localparam V_TOP_BORDER = 10;
    localparam V_BOTTOM_BORDER = 33;
    localparam V_RETRACE = 2;

    wire counter_x_maxed = (counter_x == H_DISPLAY + H_LEFT_BORDER + H_RETRACE + H_RIGHT_BORDER); // 16 + 48 + 96 + 640
    wire counter_y_maxed = (counter_y == V_DISPLAY + V_TOP_BORDER + V_RETRACE + V_BOTTOM_BORDER); // 10 + 2 + 33 + 480

    //x counter
    always @(posedge clk) begin
		 if (counter_x_maxed || reset) begin
			  counter_x <= 0;
			  counter_x_10 <= 0;
			  pixel_scaler_x <= 0;
		 end else begin
			  counter_x <= counter_x + 1;
			  
			  if(pixel_scaler_x == 4'd9) begin //wrap around
					counter_x_10 <= counter_x_10 + 1;
					pixel_scaler_x <= 0;
			  end else
					pixel_scaler_x <= pixel_scaler_x + 1;			  
		end
	 end

    always @(posedge clk) begin
        if (counter_x_maxed || reset)
        begin
			  if(counter_y_maxed || reset)
			  begin
					counter_y <= 0;
					counter_y_10 <= 0;
					pixel_scaler_y <= 0;
			  end else begin
					counter_y <= counter_y + 1;
					
					if(pixel_scaler_y == 4'd9) begin //wrap around
						counter_y_10 <= counter_y_10 + 1;
						pixel_scaler_y <= 0;
					end else
						pixel_scaler_y <= pixel_scaler_y + 1;					
			  end
        end
    end

    always @(posedge clk)
    begin
        vga_HS <= (counter_x > (H_DISPLAY + H_RIGHT_BORDER) && (counter_x < (H_DISPLAY + H_RIGHT_BORDER + H_RETRACE)));   // active for 96 clocks
        vga_VS <= (counter_y > (V_DISPLAY + V_TOP_BORDER) && (counter_y < (V_DISPLAY + V_TOP_BORDER + V_RETRACE)));   // active for 2 clocks
    end

    always @(posedge clk)
    begin
        in_display_area <= (counter_x < H_DISPLAY) && (counter_y < V_DISPLAY);
    end

    // invert the hsync and vsync
    assign vga_h_sync = ~vga_HS;
    assign vga_v_sync = ~vga_VS;

endmodule
