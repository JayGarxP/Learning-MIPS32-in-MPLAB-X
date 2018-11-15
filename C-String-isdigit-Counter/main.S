#include <xc.h>
#include "lab05defines.h"

.global main
 
.data
string: .asciiz "There are 10 kinds of people in the world, those who understand binary and those who don't. The rest of the 0-9 digits are 2, 3, 4, 5, 6, 7, 8, 9."
number_of_msg: .asciiz "Number of Xs: " //replace X@byte 10 with your number char
total_number_msg: .asciiz "Total number of digits: "
//10 char + nullterminator '0x00' char array used as $a1 in binary_to_asciidec  
string_buffer: .space 11
//newline; with ASCII carriage return '0x0d' then '0x0a'
newline_msg: .asciiz "\r\n"
    
.text
.set noreorder

.ent main
main:
    //main - stack frame intro
    addiu sp, sp, -68
    sw ra, 64(sp)
    sw fp, 60(sp)
    addu fp, sp, zero

//////////////////////////////////////////////////////////////
// configure UART TX
    la t9, U1MODESET
    li t0,0x8000
    sw t0, 0(t9)
    la t9, U1STASET
    li t0, 0x1400
    sw t0, 0(t9)
//////////////////////////////////////////////////////////////
//TODO: initialize all counts to zero
    
    la s0, string //$s0 address of asciiz string containing digimon
    move s1, s0
    addi s1, s1, -1 //start index at negative 1 byte, -char
    
    load_next_string_byte:
    addi s1, s1, 1 //increment address stored at $s1
    lb t0, 0(s1)	//take a byte
    //is it zero (NULL)
    beq t0, zero, done_parsing
    nop
    
    //copy byte of string into $a0
    move a0, t0
    //save byte of string in $a0 onto main's stack after entering function
    //sw a0, 0(fp) //this is done inside the function
    
    //Call int is_a_digit(char x)
    jal is_a_digit
    nop
    
    //if is_a_digit returns -1 in $v0; jump to next_string_byte
    //else jump to increment_digit_counts
    
    addi t1, zero, -1 //load negative one into t1
    beq v0, t1, load_next_string_byte
    nop
    move t2, v0 //make copy of return value in t2
    //fall
    //thru
increment_digit_counts:

    //multiply return value by 4 to get pointer offset $t3
    mul t3, t2, 4
    // add pointer offset to 0_count stack frame pointer
    la t4, count_0
    add t4, t4, t3 //offset from count_0 address by pointer offset value
    lw t5, 0(t4)    // load the count value found at pointer+offset address
    addi t5, t5, 1 //increment count value
    sw t5, 0(t4)   //store incremented t5 count value
    //load that address; load value; increment value should be zero to start
    //simulator appears to zero out memory for us, but it is bad practice
    // to assume it will work everytime.

    //now increment total digits found
    la t4, count_total
    lw t5, 0(t4)
    addi t5, t5, 1
    sw t5, 0(t4)
    
    j load_next_string_byte
    nop
    
done_parsing:
    //need to start printing things now.
    //load address of number_of_msg
    //load byte of 10(number_of_msg address)
    //set load byte to loop count + 0x30
    //print 'number of message'
    //load address of count store
    //load word of count store
    // call b_to_a function $a0=loadWordCountStore $a1 = string buffer address
    //print string buffer
    //print newline
    //repeat 9 more times
    
    la s0, number_of_msg
    
    //re-enter loop here
    addi t1, zero, 0x30 //add loop count to ASCII digit offset
    sb t1, 10(s0) //store $t1 ASCII loop index to tenth char in number_of_msg
  
    //Print "Number of #s: "
    move a0, s0 
     jal output_string
    nop
    
    //Prep to Print the digit count
    la t0, count_0 //load address of current count stack var
    lw t0, 0(t0)
    
    move a0, t0 // $a0 = $t0 binary digit count
    la a1, string_buffer //load address of char[11] into $a1

    //void binary_to_asciidec(binary #, char* buffer)
    jal binary_to_asciidec
    nop
    
    //Print count value
    move a0, a1 //$a0 param for output_string = $a1 string buffer 
     jal output_string
    nop
    
    //Print newline; with ASCII carriage return '0x0d' then '0x0a'
    la a0, newline_msg
     jal output_string
    nop
    
    //How to print what's in $a0, just call output_string; boom done
   // jal output_string
 // nop
 
 //TODO: print end transimission after printing everything + newline

endless:
    j endless
    nop

//stack frame windup, theoretical
    addu sp, fp, zero
    sw ra, 64(sp)
    sw fp, 60(sp)
    addiu sp, sp, 68
    //Return to next main or endless loop in parent theoretically
    //j ra
    //nop
    
    
.end main

