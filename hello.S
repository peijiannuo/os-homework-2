.code16                     # Use 16-ibt assembly
.globl start                # This tells the link where we want to start executing

start:
    movw $message, %si      # Load the offset of our message into si
    movb $0x00, %ah         # 0x00 - set video mode
    movb $0x03, %al         # 0x03 -80x25 text mode
    int $0x10               # Call into the BIOS
    
print_char:
    lodsb                   # Loads a single byte from [si] into al and increments si
    testb %al, %al          # Checks to see if the byte is 0
    jz done                 # If so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E, %ah         # OX0E is the BIOS code to print the single character
    int $0x10               # Call into the BIOS using a software interrupt
    jmp print_char          # Go back to "print_char" label

done:
    jmp done                # Loop forever

# The .string command inserts an ASCII string with a null terminator
message:
    .string     "Hello World"

# This pads out the rest of the 512 byte sector and then
# puts the magic ex55AA that the BIOS expects at the end
.fill 510 -(. -start), 1, 0

# Now we can put our magic bytes
.byte 0x55
.byte 0xAA