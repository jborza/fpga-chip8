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
	
	//TODO memory interface
	output reg [11:0] mem_read_address,
	input wire [7:0] mem_read_data,
	output reg mem_read_enable,
	output reg [11:0] mem_write_address,
	output reg [7:0] mem_write_data,
	output reg mem_write_enable
);

// PPU registers
reg [15:0] sprite_row; //shifted to position for left and right byte
reg [3:0] current_row;
reg draw_right_half;
reg [7:0] screen_byte;
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
	STATE_LOAD_SPRITE = 4'h1, 
	STATE_LOAD_LEFT = 4'h2,
	STATE_LOAD_RIGHT_WRITE_LEFT = 4'h3,
	STATE_WRITE_RIGHT = 4'h4;
	
reg [3:0] state = STATE_WAIT;

assign busy = state != STATE_WAIT;

always @(posedge clk) begin
	if(reset) begin
		state <= STATE_WAIT;
	end else begin
		mem_write_enable <= 1'b0;
		mem_read_enable <= 1'b0;
		case(state) 
			STATE_WAIT:
			begin
				if(draw) begin
					$display($time, " ppu: draw $%x (sprite height: %d) at (%x, %x)",
                   address, sprite_height, x, y);
					shift <= x % 8;
					draw_right_half <= (x % 8) != 0;
					collision <= 0;
					current_row <= 0;
					mem_read_address <= address + current_row;
					mem_read_enable <= 1'b1;
					screen_address <= y * SCREEN_WIDTH_BYTES + (x >> 3);
					state <= STATE_LOAD_SPRITE;
				end
			end
			STATE_LOAD_SPRITE:
			begin
				$display($time, " ppu: load sprite row %d at $%x", 
					current_row, address + current_row);
				//store the shifted sprite
				sprite_row <= {mem_read_data, 8'h0} >> shift;
				mem_read_address <= address_left;
				mem_read_enable <= 1'b1;
				state <= STATE_LOAD_LEFT;
			end
			STATE_LOAD_LEFT:
			begin
				$display($time, " ppu: load left byte from $%x", mem_read_address);
				//collision detection by ANDing the data with the sprite and checking if any bits are set
				collision <= collision | |(mem_read_data & sprite_row[15:8]);
				//create the ouput by xoring the pixels
				mem_write_data <= mem_read_data ^ sprite_row[15:8];
				//set up output
				mem_write_address <= address_left;
				mem_write_enable <= 1'b1;
				//prepare for the right pixel
				mem_read_address <= address_right;
				state <= STATE_LOAD_RIGHT_WRITE_LEFT;
			end
			STATE_LOAD_RIGHT_WRITE_LEFT:
			begin
				if(draw_right_half) begin
					$display($time, " ppu: load right byte from $%x", mem_read_address);
					collision <= collision | |(mem_read_data & sprite_row[7:0]);
					mem_write_data <= mem_read_data ^ sprite_row[7:0];
					mem_write_address <= address_right;
					mem_write_data <= screen_address;
					mem_write_enable <= 1'b1;
				end
				state <= STATE_WRITE_RIGHT;
			end
			//we can probably get rid of this state and roll it into the previous one
			STATE_WRITE_RIGHT:
			begin
				if(current_row == sprite_height - 1) begin
					$display($time, " ppu: last row written, finishing");
					state <= STATE_WAIT;
				end else begin
					//next row
					current_row <= current_row + 1;
					mem_read_address <= address + current_row + 1;
					//move the pointer to another row
					screen_address <= screen_address + SCREEN_WIDTH_BYTES;
					state <= STATE_LOAD_SPRITE;
				end
			end
		endcase
	end
end
endmodule