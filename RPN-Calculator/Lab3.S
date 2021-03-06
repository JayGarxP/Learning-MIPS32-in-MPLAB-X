/*************************************************************
* Author:		Joseph Fallon
* Filename:		Lab3.S
* Date Created:	10/16/2018
* Modifications:	
*		10/18/18 Stack Frame Debugging; ~8 hours
*  		10/19/18 Making RPN_Multiply handle 1,0,
		    and -neg# ~5 hours
*************************************************************
*/
    
/*************************************************************
*
* Lab/Assignment: Lab 3 Stack Manipulation RPN Calculator
* 
* Overview:
*		Lab3.S is an assembly program for PIC32 microcontrollers
*		running inside the simulator inside MPLAB X IDE
*		using the v 1.44 X32 compiler...
*		In the data segment, hard coded words
*		represent a Left to Right Reverse Polish Notation
*		Expression, which is evaluated and the 
*		answer is stored in LAB3_RESULT
* 	
* 	
* Lab Description:
*	Create an RPN calculator that uses a stack to do '+', '-', and '*'
*	operations on an EXPRESSION hardcoded in the .data section.
*     Assume that the EXPRESSION is well-formed and contains no big#'s
*     so, no error handling is necessary; see lab handouts and assignment
*	for help and more information.
*     
*     also the midterm will be VERY similar
*     to this lab; it will be about stack frame manipulation and setup inide
*     of MPLAB X IDE; midterm is open note and internet 
*     so come correct or get wrecked.
*     
*
* Input:
*		Hard code the values into the labels in the .data segment
*	    e.g.    EXPR:   .word 3,4,0x80000000 + '*',5,6
*			    .word 0x80000000 + '-',0x80000000 + '+'
*			    .word 0x80000000 + '=' 
*	    
*	    Use the operator constants from the lab handout, not ascii!
*	    e.g. ADD_OP: .word 0x80000000 + '+'
*
* Output:
*	LAB3_RESULT will have a store word instruction set
*	its value to EXPRESSIONs result, before the program
*	enters an endless loop, so set a watch on the label
*	LAB3_RESULT, and peek at it in debug mode. Sadly,
*	MPLAB X IDE watches cannot display signed decimal, so you
*	will have to convert the hex yourself if you want 
*	to see negative results in decimal.
*
************************************************************/
    #include <xc.h>
    // Use PIC32MX460F512L
    // Use XC32 v 1.44 compiler
    
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
    
    //macros are just runtime text search and replace
   
    .global main

.data
    //Left to Right (postfix) Reverse Polish Notation (RPN)
    EXPR: .word 3,4,0x80000000 + '*',5,6,0x80000000 + '-',0x80000000 + '+',0x80000000 + '='    
    //11 =
    //infix:(3*4) + (5-6) =
    //postfix: 3,4,*,5,6,-,+,= 
	
     //Stored in $s7 for debugging purposes
LAB3_RESULT: .word 0
   
    
.text
.set noreorder
.ent main
main:
    //Stack Frame Preamble
    //made space for ra, fp, and a0-a3
    addiu sp, sp, -24 //6 registers * 4 bytes = 24bytes == 6 words
    sw ra, 20(sp)
    sw fp, 16(sp)
    addu fp, sp, zero
    //end of preamble; 
    /* current state of the stack frame
     /----------------------/
     |          ra          | - 4	positive offset reaches up  (20)
     /----------------------/
     |          fp          | - 8
     /----------------------/ 
     |  room for a3         | -12
     /----------------------/ 
     |  room for a2         | -16
     /----------------------/ 
     |  room for a1         | -20
     /----------------------/ 
     |  room for a0         | -24
     /----------------------/
     --->$fp == $sp now @ -24 offset
    */
    
    la t9, LAB3_RESULT
    lw s7, 0(t9)	   
    
    //$s0 = &EXPR	$s0 == offset; into EXPR[offset]
    la s0, EXPR //pull in pointer to EXPR[0]
    
    //$s2 = MULT_OP 
    la s2, MULT_OP
    lw s2, 0(s2)
    
    //$s3 = ADD_OP 
    la s3, ADD_OP
    lw s3, 0(s3)
    
    //$s4 = SUB_OP 
    la s4, SUB_OP
    lw s4, 0(s4)
    
    //$s5 = EQU_OP 
    la s5, EQU_OP
    lw s5, 0(s5)
    
    //Check the EXPR[i] RPN symbol, if it an operand# then PUSH it onto stack
    //	if symbol is an operator( * + - =) then POP operand(s) off the stack
    //	    and PUSH the result of the operator's function on the stack
    //	if symbol is '=' whatever is POPped off the stack is the answer to EXPR
loop_eval_symbol:
    
    //$s1 = RPN symbol;	    $s1 = EXPR[$s0];
    lw s1, 0(s0)
   
//Check if $s1 is an operator, to branch to an arithmetic function
    beq s1, s5, equals_op_hit
    nop

    ori a2, zero, 2 //MULT == 2; param for RPN_arithmetic_operation()
    beq s1, s2, operator_hit
    nop
    
    ori a2, zero, 0 //ADD == 0; param for RPN_arithemetic_operation()
    beq s1, s3, operator_hit
    nop
    
    ori a2, zero, 1 //SUB == 1; param for RPN_arithemetic_operation()
    beq s1, s4, operator_hit
    nop
   
   //if fall through all the branch on operator checks; 
   //	EXPR[i] stored in $s1 must be operand;
   //	operands should be pushed on stack;
   
    PUSH s1	//push operand in $s1 onto 'stack'
    
    j increment_expr_pointer
    nop
    
    
operator_hit:
    POP a1
    POP a0
    
    jal RPN_arithmetic_operation
    nop
    //push return value from $v0, the product/sum/difference, onto 'stack' 
    PUSH v0

// fall thru to increment_expr_pointer
    
    //EXPR[s0]
    //$s0 = $s0 + 1 word
increment_expr_pointer:
    addiu s0, s0, 4 //four bytes is one 32-bit word in our MIPS
    j loop_eval_symbol //jump to evaluate next symbol
    nop
    
    
    //Store LAB3_RESULT when encounter '=' EQU_OP in switch statement
     //done; what is on stack is answer to LtoR RPN EXPRESSION
equals_op_hit:
    POP t0
    ori s7, t0, 0
    la t9, LAB3_RESULT
    sw s7, 0(t9)
//fall thru to endless loop
endless:
    j endless
    nop

//Make Pointers what they were before preamble, to preserve across calls
    //	    as if this .main was a function in a terrible unfeeling machine.
    addu sp, fp, zero
    lw ra, 20(sp)
    lw fp, 16(sp)
    addiu sp, sp, 24    
    
.end main
    
    //constants from lab handout, edit these at your own peril!
MULT_OP:  .word 0x80000000 + '*'
ADD_OP:   .word 0x80000000 + '+'
SUB_OP:   .word 0x80000000 + '-'
EQU_OP:   .word 0x80000000 + '='    