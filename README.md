# FPGA-based CHIP-8 implementation

## Opcodes implementation status

| Opcode | Implemented | Tested | Note
| - | - | - | - 
| 0NNN | N/A | N/A
| 00E0 | N | N | TODO clear screen
| 00EE | Y | N
| 1NNN | Y | N
| 2NNN | Y | N
| 3XNN | Y | N
| 4XNN | Y | N
| 5XY0 | Y | N
| 6XNN | Y | N
| 7XNN | Y | N
| 8XYN | Y | N
| 9XY0 | Y | N
| ANNN | Y | N
| BNNN | Y | N
| CXNN | Y | N
| DXYN | Y | N
| EX9E | N | N | TODO handle keypresses
| EXA1 | N | N | TODO handle keypresses
| FX07 | Y | N 
| FX0A | N | N | TODO wait until keypressed
| FX15 | Y | N
| FX18 | Y | N
| FX1E | Y | N
| FX29 | Y | N
| FX33 | N | N | TODO create a BCD test case
| FX55 | Y | N | TODO create a test case
| FX65 | Y | N | TODO create a test case