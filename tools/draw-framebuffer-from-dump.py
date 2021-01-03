# generate the dump in ModelSim with: 
# mem save -format binary -noaddress -startaddress 256 -endaddress 511 -wordsperline 1 -outfile ram-framebuffer-dump.bin ram

from PIL import Image

rows = 64
columns = 32

row = 0
column = 0

im = Image.new(mode="1", size=(64,32))


#read lines, skip comments
with open('ram-framebuffer-dump.bin', 'r') as f:
    lines = [line.strip() for line in f.readlines() if line.startswith('//') == False]
    for line in lines:
        #draw 8 pixels from a bitstring such as 00001111
        for offset in range(0,8):
            im.putpixel((row + offset, column), int(line[offset]))
        row += 8
        if(row >= rows):
            row = 0
            column += 1

im.save('framebuffer-dump.png')
im.show()
