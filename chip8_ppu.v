`default_nettype none

module ppu(
	input wire clk,
	input wire reset,
	input wire draw,
	input wire [11:0] address,
	input wire [3:0] sprite_height,
	input wire [5:0] x,
	input wire [4:0] y,
	
	output wire busy,
	output reg collision,
	
	//memory interface
	output reg [11:0] mem_read_address,
	input wire [7:0] mem_read_data,
	output reg mem_read_enable,
	output reg [11:0] mem_write_address,
	output reg [7:0] mem_write_data,
	output reg mem_write_enable,
	
	output reg [3:0] state_out,
	output wire [7:0] state_out2,
	output reg [7:0] mem_actually_read
);

// PPU registers
reg [15:0] sprite_row; //shifted to position for left and right byte
reg [3:0] current_row = 4'h0;
reg draw_right_half;
reg [3:0] shift;
reg [7:0] screen_address;

wire [11:0] address_left;
wire [11:0] address_right;

localparam [11:0] SCREEN_RAM_OFFSET = 12'h100;
localparam SCREEN_WIDTH_BYTES = 8;

assign address_left = screen_address + SCREEN_RAM_OFFSET;
//wrapping the last 3 bits
assign address_right = {screen_address[7:3], screen_address[2:0] + 1'b1} + SCREEN_RAM_OFFSET;

localparam [3:0] 
	STATE_WAIT = 4'h0,
	STATE_FETCH_SPRITE = 4'h1, 
	STATE_FETCH_LEFT = 4'h2,
	STATE_FETCH_RIGHT = 4'h3,
	STATE_WRITE_LEFT = 4'h4,
	STATE_WRITE_RIGHT = 4'h5;
	
reg [3:0] state = STATE_WAIT;

assign busy = state != STATE_WAIT;

//memory process
always @(posedge clk) begin
	if(reset) begin
		state <= STATE_WAIT;
	end else begin
		
		mem_read_enable = 0;
		mem_write_enable = 0;
		mem_read_address = 0;
		mem_write_address = 0;
		mem_write_data = 0;
		case (state) 
			STATE_WAIT:
			begin
				if(draw) begin				
						$display($time, " ppu: draw $%x (sprite height: %d) at (%x, %x)",
							 address, sprite_height, x, y);
						shift <= x % 8;
						draw_right_half <= (x % 8) != 0;
						collision <= 0;
						current_row <= 0;
						screen_address <= y * SCREEN_WIDTH_BYTES + (x >> 3);
						state <= STATE_FETCH_SPRITE;
				end
			end
			STATE_FETCH_SPRITE:
			begin
				//sprite address is originally I + row index
				mem_read_address <= address + current_row;
				mem_read_enable <= 1;
				$display($time, " ppu mem: reading sprite from $%x", mem_read_address);
				state <= STATE_FETCH_LEFT;
			end
			STATE_FETCH_LEFT:
			begin
				mem_read_address <= address_left;
				mem_read_enable <= 1;
				$display($time, " ppu mem: reading left from $%x", mem_read_address);
				state <= STATE_FETCH_RIGHT;
			end
			STATE_FETCH_RIGHT:
			begin
				if(draw_right_half) begin
					mem_read_address <= address_right;
					mem_read_enable <= 1;
					$display($time, " ppu mem: reading right from $%x", mem_read_address);
				end
				//save the sprite row
				$display($time, " ppu: save sprite row %d at $%x, data: %x", 
					current_row, address + current_row, mem_read_data);
				sprite_row <= {mem_read_data, 8'h0} >> shift;
				state <= STATE_WRITE_LEFT;
				//write left
				//create the ouput by xoring the pixels
				
			end
			STATE_WRITE_LEFT:
			begin
				$display($time, " ppu: load left byte from $%x, data: %x", mem_read_address, mem_read_data);
				mem_write_data <= mem_read_data ^ sprite_row[15:8];
				mem_write_address <= address_left;
				mem_write_enable <= 1;
				collision <= collision | |(mem_read_data & sprite_row[15:8]);
				$display($time, " ppu mem: write left $%x = %x", address_left, mem_write_data);		
				state <= STATE_WRITE_RIGHT;
			end
			STATE_WRITE_RIGHT:
			begin
				if(draw_right_half) begin
					//write right
					mem_write_data <= mem_read_data ^ sprite_row[7:0];
					mem_write_address <= address_right;
					mem_write_enable <= 1;
					$display($time, " ppu: load right byte from $%x, data: %x", mem_read_address, mem_read_data);
					collision <= collision | |(mem_read_data & sprite_row[7:0]);
					$display($time, " ppu mem: write right $%x = %x", address_right, mem_write_data); 
				end
				if(current_row == sprite_height - 1) begin
					$display($time, " ppu: last row written, finishing");
					state <= STATE_WAIT;
					current_row = 4'h0;
				end else begin
					state <= STATE_FETCH_SPRITE;
					//move the pointer to another row
					screen_address <= screen_address + SCREEN_WIDTH_BYTES;
					current_row <= current_row + 1;
				end
				//
			end
		endcase
		state_out <= state;
	end
end

endmodule