#include <xc.h>
#include "lab05defines.h"

.global main

.data
string: .asciiz "There are 10 kinds of people in the world, those who understand binary and those who don't. The rest of the 0-9 digits are 2, 3, 4, 5, 6, 7, 8, 9."

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

