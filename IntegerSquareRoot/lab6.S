#include <xc.h>
/*************************************************************
* Author:		Joseph Fallon
* Filename:		lab6.S
* Date Created:	12/4/2018; finished 12/5
*************************************************************/
/*
    Lab 6 C-string integer square root output to UART
     A hardcoded string 'input:' representing 'n' the input to IntSqrt
     is iterated through to find ascii digits which are converted to binary,
     then the integer square root (NOT inverse square root) is converted back
     to ascii to be displayed in UART window of simulator
     
     Only works in MPLAB X IDE 5.05     XC32 compiler v.1.44 
     on PIC32MX460F512L simulator.
    */

    #undef  DEBUG
    #define DEBUG 1
    //#define DEBUG 0

    
.macro push reg
    addiu sp, sp, -4
    sw \reg, 0(sp)
.endm

.macro pop reg
    lw \reg, 0(sp)
    addiu sp, sp, 4
.endm

.global main

.data
// data segment for READ/WRITE data follows here
// stored in volatile RAM memory
  
string_buffer: .space 11 //used by binary_to_ascii
//newline; with ASCII carriage return '0x0d' then '0x0a'
newline_msg: .asciiz "\r\n"
    
g_is_now_msg: .asciiz "g is now "
c_is_msg: .asciiz "c is "
shenron_msg: .asciiz "integer square root found is:  "

earlyexitZ_msg: .asciiz "Exiting isqrt early,  n  was  0 "
earlyexitW_msg: .asciiz "Exiting isqrt early, n was 1 "
//strings are used to make dealing with UART easier.
    //praise printf!
    
    //used by ascii to binary
input:      .asciiz "10"    // <<<<<<<<<<<<<<<<<< INPUT INPUT INPUT INPUT
//input:      .asciiz "10"    
weight:     .word   1
acc:        .word   0
errno:      .word   0
     // Our errno codes:
errno_1:      .asciiz "input string invalid"
errno_2:      .asciiz "input string is null"    

.text
.set noreorder
// text segment for instructions and CONSTANT READ-ONLY data follows here
// stored in non-volatile flash memory

.ent main
main:
//////////////////////////////////////////////////////////////
// configure UART TX
    la t9, U1MODESET
    li t0, 0x8000
    sw t0, 0(t9)
    la t9, U1STASET
    li t0, 0x1400
    sw t0, 0(t9)
//////////////////////////////////////////////////////////////

    //STACK FRAME (atoi uses main's a$)
    addiu sp, sp, -24
    sw ra, 20(sp)
    sw fp, 16(sp)
    addu fp, sp, zero
    
//    li a0, 3
//    la a1, string_buffer
//    jal binary_to_asciidec
//    nop
    
     
    la t0, errno
    li t1, 0 //reset errno to 0
    sw t1, 0(t0)
    //Convert input string to binary number, $v0
    la a0, input
    jal asciiDec_to_Bin
    nop
  //check errno
    la t0, errno
    lw t1, 0(t0)
  bnez t1, print_error
    nop
    
  //asciiDec_to_Bin sets $v0 to 32bit binary number, could validate it here...
  move a0, v0
  jal intsqrt
  nop

  
  
print_error:
    la t0, errno
    lw t1, 0(t0)
    li t0, 1
    bne t1, t0, check_errno_two
    nop
    //print e1
    la a0, errno_1
    jal output_string
    nop
    nop
    j print_final_newline
    nop
check_errno_two:
    li t0, 2
    bne t1, t0, print_final_newline
    nop
    //print e2
    la a0, errno_2
    jal output_string
    nop
    
    //fallthru
print_final_newline:
    la a0, newline_msg //extra newline at bottom
    jal output_string
    nop

endless: 
    j endless
    nop
//unreachable main stack frame reset
    addu sp, fp, zero
    lw ra, 20(sp)
    lw fp, 16(sp)
    addiu sp, sp, 24    
  
.end main

.ent is_a_digit
is_a_digit:
    //stand up the stack frame
    addiu sp, sp, -8
    sw ra, 4(sp)
    sw fp, 0(sp)
    addu fp, sp, zero
    // this function relies on some 'test value' coming in as
    // a value in a0.
    addu t0, a0, zero
    li t1, 0x30 //ascii '0'
    //SLT RD, RS, RT | RD = (RS± < RT±) ? 1 : 0
    //variable = condition ? value_if_true : value_if_false
    slt t2, t0, t1
    //if slt == 1, rs < rt
    //BNEZ RS, OFF18 IF RS ? 0, PC += OFF18±
    //if t0 < 0x30, then outside of range - branch to move forward
    bnez t2, not_a_digit
    nop
    li t1, 0x39 //ascii '9'
    //if 0x39 < t0, then outside of range on the other side; branch to move forward
    slt t2, t1, t0
    bnez t2, not_a_digit
    nop
    //if these things weren't true, then this MUST be a digit - figure
    //out which one, iterate the local variable and fall through to move forward
    addi v0, t0, -0x30	//convert the ascii digit to it's decimal eq.
    j done_here
    nop
not_a_digit:
    li v0, 0xffffffff
done_here:
    //unwind the stack frame
    addu sp, fp, zero
    lw ra, 4(sp)
    lw fp, 0(sp)
    addiu sp, sp, 8
    j ra
    nop
.end is_a_digit
    
.ent asciiDec_to_Bin //atoi
     //(Instructor handout code, THANKS!)
     //Convert asciiz decimal string in $a0
    //to returned value 32bit binary out $v0
    // if conversion fails sets global errno to 1, skip Isqrt in main
    //errno is set in main data segment, errno is set to zero b4 each subroutine
asciiDec_to_Bin:    
    //stand up the stack frame
    addiu sp, sp, -24
    sw ra, 20(sp)
    sw fp, 16(sp)
    sw a0, 24(sp)
    addu fp, sp, zero   
    addu s0, a0, zero
    lb t0, 0(s0)  //check, just for safety, to see if a0 is null. 
                  //if so, error out with a 2
    beqz t0, null_string_error
    nop
    li t0, 0xffffffff //place a 0xffffffff into the stack to tell 
                      //us when to stop with the popping.
    push t0
read_asciiDec_to_bin:
    lb a0, 0(s0)
    beqz a0, done_parsing //this happens when we hit the end of the asciiz
    nop
    jal is_a_digit    //call is a digit with a0
    nop
    li t0, 0xffffffff //if we return 'the bad value', we error out with a 1
    beq v0, t0, bad_string_error
    nop
      push v0                   //if we got here, then push v0 onto the stack
    addiu s0, s0, 1           //move the pointer onto the next element
    j read_asciiDec_to_bin    //jump back to load byte
    nop
bad_string_error:
    la t0, errno
    li t1, 1
    sw t1, 0(t0) //setting errorno = 1 "BADSTRING"
    j done_asciiDec_bin
    nop
null_string_error:
    la t0, errno
    li t1, 2
    sw t1, 0(t0)  //setting errorno = 2 "NULLSTRING"
    j done_asciiDec_bin
    nop
done_parsing:
      pop t0
    li t1, 0xffffffff   //check for 0xffffffff, if true, then 
                          //jump to done_asciiDec_bin
    beq t0, t1, done_asciiDec_bin
    nop
    la t2, weight       //load weight
    lw t2, 0(t2)        //load weight value
    mul t3, t0, t2      //(value * weight)
    la t5, acc          //load accumulator
    lw t4, 0(t5)        //load accumulator value
    addu t4, t4, t3     //add (value * weight) to current accumulator value
    sw t4, 0(t5)        //store the accumulated value
    li t5, 10           //time to make weight more of that
    mul t2, t2, t5      //weight = weight * 10
    la t1, weight       //load weight
    sw t2, 0(t1)        //store new weight
    j done_parsing      //rinse, repeat.
    nop
done_asciiDec_bin:
    la t0, acc
    lw v0, 0(t0)
      //unwind the stack frame
    addu sp, fp, zero
    lw ra, 20(sp)
    lw fp, 16(sp)
    addiu sp, sp, 24

    j ra
    nop
.end asciiDec_to_Bin   
    
    .ent binary_to_asciidec
    //Converts count of decimal as binary $a0 into ascii string stored at $a1
    //Receives binary value in $a0
    //Receives address of string buffer in $a1
    //4294967295  or 4,294,967,295  MAX uint val is only 9 digts
    //Declares an 11-byte global byte array (for ASCII decimal string)
    //	in the .data segment; allowing for ~10digit# + null terminator
    //TO convert the binary value passed in $a0 to an ASCII-decimal
    //	null-terminated string held in a byte array at address provided in $a1
    //returns void
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
    push t3
    //increment stack size count $t9
    addi t9, t9, 1
    
    //branch to write_to_buffer if divu quotient == 0
    beq t2, zero, write_to_buffer
    nop
    //Otherwise, divide by ten again UNLESS # is too big 32 digits+
    addi t8, t8, 9 //$t8 = 9 ///////////////////////XXXXXXXXXXXXXXXXXXX
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
    pop t2
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
    
      /* newton approx. stolen from wikipedia; optimal for n>32
   unsigned int sqrt32(unsigned long n)  
    {  
        unsigned int c = 0x8000;  //decimal 32768
        unsigned int g = 0x8000;  
      
        for(;;) {  
            if(g*g > n)  
                g ^= c;  
            c >>= 1;  	
            if(c == 0)  
                return g;  
            g |= c;  		
        }  
    }  
  */
.ent intsqrt
   //$a0 32-bit unsigned int IN, input number
   //$v0 32bit unsigned int OUT, integer square root of input number (floored)
   //prints debug to UART if #debug = 1
   //Algo used is above. Also have some pre-checks before using main algo.
intsqrt:
    //intsqrt STACK FRAME
    addiu sp, sp, -36
    sw ra, 32(sp)
    sw fp, 28(sp)
    sw s7, 24(sp)
    sw s6, 20(sp)
    sw s5, 16(sp)
    addu fp, sp, zero
    
    //set s7 to a0 IN
    move s7, a0
    
    //Check if s7 == 0 or 1 to exit early. (should do for all <32)
    bnez s7, checkIfOne
    nop
    li v0, 0
     #if DEBUG
	la a0, earlyexitZ_msg
	jal output_string
	nop
	
    #endif
    j shenronCorp
    nop
    checkIfOne:
    li t0, 1
    bne t0, s7, getIntSquareRoot
    nop
    li v0, 1
     #if DEBUG
	la a0, earlyexitW_msg
	jal output_string
	nop
    #endif
    j shenronCorp
    nop
    
    getIntSquareRoot:
    li s5, 0x8000
    li s6, 0x8000
    
    CthuluFor:
    //t2 = g*g
    mul t2, s6, s6
    //if(g*g > n)
    slt t4, t2, s7 //if $t2 > $a0 input; t4 == 0
    bnez t4, shiftCright
    nop
    //g ^= c;  //t1 = t1 XOR t0
    XOR s6, s6, s5
    shiftCright: //c >>= 1; 
    sra s5, s5, 1
    
     #if DEBUG
     //PRINT g is now: 
	la a0, g_is_now_msg
	jal output_string
	nop
	
	move a0, s6
	la a1, string_buffer
	jal binary_to_asciidec
	nop
	
	la a0, string_buffer
	jal output_string
	nop
	
	la a0, newline_msg //newline
    jal output_string
    nop
    
    //PRINT C is:
	la a0, c_is_msg
	jal output_string
	nop
	
	move a0, s5
	la a1, string_buffer
	jal binary_to_asciidec
	nop
	
	la a0, string_buffer
	jal output_string
	nop
	
	
    la a0, newline_msg //newline
    jal output_string
    nop
    #endif
    
    bnez s5, ggORc
    nop
    //return g;
    move v0, s6
    j shenronCorp
    nop
    ggORc: //g |= c; 
    OR s6, s6, s5
    j CthuluFor
    nop

    shenronCorp:
     #if DEBUG
    //print final message + newline
	la a0, shenron_msg
	jal output_string
	nop	
    
	 move a0, v0
	la a1, string_buffer
	jal binary_to_asciidec
	nop
	
	la a0, string_buffer
	jal output_string
	nop 
	
   la a0, newline_msg //extra newline at bottom
   jal output_string
   nop
   #endif
    
    //unwind the stack frame
    addu sp, fp, zero
    lw ra, 32(sp)
    lw fp, 28(sp)
    lw s7, 24(sp)
    lw s6, 20(sp)
    lw s5, 16(sp)
    addiu sp, sp, 36
   
   j ra
   nop
.end intsqrt

