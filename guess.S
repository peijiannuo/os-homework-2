.code16                     # Use 16-ibt assembly
.globl start                # Tell link where to start executing

start:
    movb $0x00, %ah         # Set video mode
    movb $0x03, %al         # Set 80x25 text mode
    int $0x10               # Call into the BIOS
    call random_gen         # Store the random digit in BL

input_loop:
    movw $msg_one, %si      # Load the offset of msg_one into si
    call print_char         # Print "What number am I thinking of (0-9)? "
    call input_char         # Store the keyboard input in CL
    call print_crlf         # Print new line
    cmp %bl, %cl            # Compare input with random digit
    jne wrong               # Go to "wrong" label if not equal
    jmp right               # Go to "right" label if equal
	
random_gen:
    movb $0x00, %al         # Set mode: current second in BCD
    outb %al, $0x70         # CMOS RAM index register port
    inb $0x71, %al          # CMOS RAM data port
    and $0x0F, %al          # Mask to get only ones digit of BCD
    add $0x30, %al          # Add 48 to get ASCII 0-9
    movb %al, %bl           # Store the random number in BL
    ret

print_char:
    lodsb                   # Loads a single byte from [si] into al and increments si
    testb %al, %al          # Checks to see if the byte is 0
    jz print_char_done      # If so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E, %ah         # Print the single character
    int $0x10               # Call into the BIOS
    jmp print_char          # Go back to "print_char" label
print_char_done:
    ret

print_crlf:
    movb $0x0D, %al         # Load '\r'
    movb $0x0E, %ah         # Print the single character
    int $0x10               # Call into the BIOS
    movb $0x0A, %al         # Load '\n'
    movb $0x0E, %ah         # Print the single character
    int $0x10               # Call into the BIOS
    ret

input_char:
    movb $0x00, %ah         # Set AH to 0 and store result in AL
    int $0x16               # Call into the BIOS - read a character 
    movb $0x0E, %ah         # Print the single character
    int $0x10               # Call into the BIOS
    movb %al, %cl           # Store the input in CL
    ret

wrong:
    movw $msg_two, %si      # Load the offset of msg_two into si
    call print_char         # Print "Wrong!"
    call print_crlf         # Print new line
    jmp input_loop          # Go back to "input_loop" label

right:
    movw $msg_three, %si    # Load the offset of msg_three into si
    call print_char         # Print "Right! Congratulations."
    call print_crlf         # Print new line
    
done:
    jmp done                # Loop forever

# Pre-defined strings
msg_one:
    .string		"What number am I thinking of (0-9)? "

msg_two:
    .string		"Wrong!"

msg_three:
    .string		"Right! Congratulations."

# Make sure the file is of the correct size
# What does a file of this end with?

# This pads out the rest of the 512 byte sector and then
# puts the magic ex55AA that the BIOS expects at the end
.fill 510 -(. -start), 1, 0

# Now we can put our magic bytes
.byte 0x55
.byte 0xAA