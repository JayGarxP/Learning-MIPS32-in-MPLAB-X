#include <xc.h>

.global output_string
.global is_a_digit
.global binary_to_asciidec 
//The three required functions for lab5: count digits in asciiz string
    
.ent output_string
   
    //Receives address for string in $a0
    //Prints to I/O UART1 Output Window
    //Returns void
output_string:

    //called function stack frame
    addiu sp, sp, -8
    sw ra, 4(sp)
    sw fp, 0(sp)
    sw a0, 8(sp) //inbount a0 parameter, stored in calling function's stack frame
    addu fp, sp, zero

get_byte:
    lb s0, 0(a0)
    beq s0, zero, done //if string address is zero; 'null'
    nop
send:
  // send TX data
    la s2, U1TXREG
    sw s0, 0(s2)
    la s2, U1STA
wait_tx:
    lw s1, 0(s2)
    andi s1, s1, 0x100
    beq s1, zero, wait_tx
    nop
next:
    addu a0, a0, 1
    j get_byte
    nop
done:

    //called function stack frame wind-up
    addu sp, fp, zero
    lw ra, 4(sp)
    lw fp, 0(sp)
    addiu sp, sp, 8
    //now we've restored all we need; time to go
    jr ra
    nop

.end output_string

    
.ent is_a_digit
//int is_a_digit(char x)
    //receives a char byte value in $a0
    // range checks 0 to 9 ascii (0x30 to 0x39) chars (ignores '-')
    //if ascii digit found, returns the binary digit value; '0x30' == 0
    // else if not in range, returns -1 aka 0xffffffff
is_a_digit:
    //stack frame for $a0; use $v0 to return value
    
    
    //0x30 == 48 decimal; 0x39 == 57 decimal BTW
    //See the pseudocode, hex and binary are equivalent reprs below 10
     //if t0 < 0x30, then outside of range;  return -1
    //if 0x39 < t0, then outside of range on the other side; return -1
    //else, then this MUST be a digit,
    //find out whiche one; return binary digit 0-9
    
    //rehydrate stackframe, j ra; nop;
    
    addi v0, zero, 2
    j ra
    nop
    
.end is_a_digit
    
    
.ent binary_to_asciidec
    //Converts count of decimal as binary $a0 into ascii string stored at $a1
    //Receives binary value in $a0
    //Receives address of string buffer in $a1
    //Declares an 11-byte global byte array (for ASCII decimal string)
    //	in the .data segment; allowing for 10digit# + null terminator
    //TO convert the binary value passed in $a0 to an ASCII-decimal
    //	null-terminated string held in a byte array at address provided in $a1
    //returns void
binary_to_asciidec:
    
.end binary_to_asciidec