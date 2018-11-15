#include <xc.h>

    //stack pointer down; lower address
    .macro PUSH reg
    addiu sp, sp, -4
    sw \reg, 0(sp)
    .endm
    
    //stack pointer up; higher address
    .macro POP reg
    lw \reg, 0(sp)
    addiu sp, sp, 4
    .endm
    
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
    addiu sp, sp, -20
    sw ra, 16(sp)
    sw fp, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)
    sw a0, 20(sp) //inbount a0 parameter, stored in calling function's stack frame
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
    lw ra, 16(sp)
    lw fp, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addiu sp, sp, 20
   
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
    //stack frame for $a0 char byte; use $v0 to return binary digit value
    addiu sp, sp, -8
    sw ra, 4(sp)
    sw fp, 0(sp)
    sw a0, 8(sp) //inbound a0 parameter, stored bottom of main's stack frame
    addu fp, sp, zero
    
    //0x30 == 48 decimal; 0x39 == 57 decimal BTW
    //See the pseudocode, hex and binary are equivalent reprs below 10
     //if a0 < 0x30, then outside of range;  return -1
    //if 0x39 < a0, then outside of range on the other side; return -1
    //else, then this MUST be a digit,
    //find out whiche one; return binary digit 0-9
    
    addi t0, zero, 0x30 //load ASCII '0' into $t0
    blt a0, t0, is_not_digit //if $a0 byte < ASCII '0'
    nop
    addi t1, zero, 0x39
    blt t1, a0, is_not_digit //if ASCII '9' < $a0 byte 
    nop
    sub v0, a0, t0 //return binary value for ASCII; x - 0x30
    j return_is_a_digit
    nop
    
    is_not_digit:
    addi v0, zero, -1
    //fall
    //thru
    return_is_a_digit:
    //rehydrate stackframe, j ra; nop;
    addu sp, fp, zero
    lw ra, 4(sp)
    lw fp, 0(sp)
    addiu sp, sp, 8
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
    //see link for more information; if algo in lab handout is wonky
    //https://www.electronics-tutorials.ws/binary/bin_2.html
    //But know that divu is doing the work for us
binary_to_asciidec:
    //stack frame, reaches into main to store params
    addiu sp, sp, -8
    sw ra, 4(sp)
    sw fp, 0(sp)
    sw a0, 8(sp) //inbound a0 parameter, stored bottom of main's stack frame
    sw a1, 12(sp)
    addu fp, sp, zero
    
    //divu until no quotient left
    move t0, a0 //copy binary number into $t0
    addi t1, zero, 10 //$t1 = 10
    move t9, zero //$t9 is stack size; starts at 0 
    
    divide_by_ten:
    divu t0, t1
    //push remainder onto stack
    //repeat division with quotient / 10
    mflo t2 //$t2 = quotient
    mfhi t3 //$t3 = remainder
    
    addi t3, t3, 0x30 //add ASCII offset to mod10 remainder
    // push $t3 remainder to stack!
    PUSH t3
    //increment stack size count $t9
    addi t9, t9, 1
    
    //branch to write_to_buffer if divu quotient == 0
    beq t2, zero, write_to_buffer
    nop
    //Otherwise, divide by ten again UNLESS # is too big 9 digits+
    addi t8, t8, 9 //$t8 = 9
    beq t9, t8, write_to_buffer
    nop
    // set dividend to quotient
    move t0, t2
    j divide_by_ten
    nop
    
    write_to_buffer:
    //write to a1 buffer
    move t0, a1 //$t0 is copy of a1 str_buf address
    
    store_stack_byte:
    POP t2
    //decrement stack size
    addi t9, t9, -1
    
    //write to string buffer popped stack value $t2 at offset $t0 
    sb t2, 0(t0)
    
    //increment byte-offset $t0 into $a1 str_buf
    addi t0, t0, 1
    
    //check stack size; if empty append null and return, else write next char
    beq t9, zero, binary_to_ascii_return
    nop
    //else
    // store the next digit as ASCII
    j store_stack_byte
    nop

    
    binary_to_ascii_return:
    sb zero, 0(t0) //append null '0x00'
    
     //rehydrate stackframe, j ra; nop;
    addu sp, fp, zero
    lw ra, 4(sp)
    lw fp, 0(sp)
    addiu sp, sp, 8
    j ra
    nop
    
    
.end binary_to_asciidec