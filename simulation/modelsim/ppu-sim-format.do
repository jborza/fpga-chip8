onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ppu_sim/clk
add wave -noupdate /ppu_sim/reset
add wave -noupdate /ppu_sim/we
add wave -noupdate /ppu_sim/write_address
add wave -noupdate /ppu_sim/read_address
add wave -noupdate -radix hexadecimal /ppu_sim/ram_in
add wave -noupdate -radix hexadecimal /ppu_sim/ram_out
add wave -noupdate /ppu_sim/rom_out
add wave -noupdate /ppu_sim/ppu_draw
add wave -noupdate /ppu_sim/ppu_busy
add wave -noupdate /ppu_sim/ppu_collision
add wave -noupdate -radix hexadecimal /ppu_sim/ppu_mem_read_address
add wave -noupdate -radix hexadecimal /ppu_sim/ppu_mem_write_address
add wave -noupdate /ppu_sim/ppu_mem_read_data
add wave -noupdate -radix hexadecimal /ppu_sim/ppu_mem_write_data
add wave -noupdate /ppu_sim/ppu_mem_read_enable
add wave -noupdate /ppu_sim/ppu_mem_write_enable
add wave -noupdate -radix hexadecimal /ppu_sim/vx
add wave -noupdate -radix hexadecimal /ppu_sim/vy
add wave -noupdate -radix hexadecimal /ppu_sim/I
add wave -noupdate -radix hexadecimal /ppu_sim/n
add wave -noupdate -color Gold -radix unsigned /ppu_sim/DUT/current_row
add wave -noupdate -color Gold /ppu_sim/DUT/sprite_row
add wave -noupdate -color Gold /ppu_sim/DUT/draw_right_half
add wave -noupdate -color Gold /ppu_sim/DUT/screen_byte
add wave -noupdate -color Gold -radix unsigned /ppu_sim/DUT/shift
add wave -noupdate -color Gold -radix hexadecimal /ppu_sim/DUT/screen_address
add wave -noupdate -color Gold -radix hexadecimal /ppu_sim/DUT/address_left
add wave -noupdate -color Gold -radix hexadecimal /ppu_sim/DUT/address_right
add wave -noupdate -color Gold -radix hexadecimal /ppu_sim/DUT/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1336 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 178
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {719 ps}
