
import sys

with open(sys.argv[1],"rb") as f:
    bytes_read = f.read()
for byte in bytes_read:
    print(f'{byte:08b}')