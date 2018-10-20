/*************************************************************
* Author:		Joseph Fallon
* Filename:		RPN_arithmetic_functions.S
* Date Created:	10/16/2018
* Modifications:	
*		10/18/18 Refactoring Prof. Bartholomew code
*			    to be one big function
*  		10/19/18 Making RPN_Multiply handle 1,0,
*		    and -neg# ~5 hours
*************************************************************
*/
#include <xc.h>

.global RPN_arithmetic_operation

.data   
.text
.set noreorder

.ent RPN_arithmetic_operation
    /**********************************************************************	
* Purpose: `RPN_arithmetic_operation` is a leaf-function 
*    that performs Reverse Polish Notation arithmetic operations $a2{+,-,*} 
*    on two operands $a0,$a1{signed#} and returns the result $v0{signed#}
*
*
* Param-Registers:
*			a0 'x', left hand number
*			a1 'y', right hand number
*			a2 Operation: 0 == ADD; 1 == SUB; 2 == MULT
*
* Return-Registers:
*			v0  the result of the operation
*
* Precondition: 
* 		Caller function MUST have 12 bytes above $fp reserved
*		for storing $a0,a1,a2 inside.
*		Params are assumed to be well formed.
*     
*
* Postcondition: 
*		$a0,a1,a2 are preserved in Caller stack frame
*		$v0 is set to operation result
*		`jr ra` instruction returns
*
************************************************************************/
RPN_arithmetic_operation:
  addiu sp, sp, -8  //move stack pointer down by 2 words, 8 bytes; 
		    // to lower addresses, 0 inclusive to -8 exclusive
  sw ra, 4(sp)
  sw fp, 0(sp)
  //save main's register parameters before moving the frame pointer
  //	to simplify indirect addressing offset math.
  sw a0, 0(fp) //use enter value of $fp to save param reg in main's stack frame
  sw a1, 4(fp) //a1 is actually ruined in the multiply label, need to save
  sw a2, 8(fp) //no reason to actually save a2; just for learning.
  //that's right. I just reached OUT of my frame, and saved off some data
  addu fp, sp, zero //sets the bottom of our frame
  //end of stack frame construction

  //  
//  /* current state of the stack frame
//     /----------------------/
//     |          ra          | 20
//     /----------------------/
//     |          fp          | 16
//     /----------------------/ 
//     |  room for a3         | 12
//     /----------------------/ 
//     |  room for a2         |  8 //8 INclusive to 12 EXclusive
//     /----------------------/ 
//     |  room for a1         |  4
//     /----------------------/ 
//     |  room for a0         |  0   $sp on enter; $fp on enter.	(12)
//     /-- ->>>old $fp--------/
//     |  RPN $ra	      |  -4					(8)
//     /----------------------/
//     |  RPN $fp	      |  -8 //-8 exclusive to -4 inclusive	(4)
//     /----------------------/
//     ---------->$sp and $fp	    new $sp and $fp after setting a#s
//     |  next 'open' mem space| -12					(0)
//     /----------------------/
//     
//    */

  
 //Branch to correct function depending on $t7 value
 ori t0, zero, 2  // $t0 == MULT == 2
 ori t1, zero, 1  // $t1 == SUB == 1
	          // $zero == ADD == 0

 beq a2, t0, RPN_multiply //$v0 = x * y
 nop
 beq a2, t1, RPN_subtract //$v0 = x - y
 nop
 beq a2, zero, RPN_add //$v0 = x + y
 nop
 
 //Now arithemetic functions will return to here; 
 //	copying $t2 into $v0 to make future error checking easier. 
operation_done:
  addu v0, t2, zero
  
  //Return stack frame to former glory
  addu sp, fp, zero	//snap the sp back to the bottom of the frame
  lw fp, 0(sp)          //restore the fp of the calling function
  lw ra, 4(sp)          //restore the ra of the calling function
  addiu sp, sp, 8      //move the stack pointer back to *wherever* it was
  
  jr ra
  nop
  


RPN_multiply:
  //Check if a0 or a1 are == zero; to skip repeated addition
    beq zero, a0, zero_param
    nop
    beq zero, a1, zero_param
    nop
    
  addi t3, zero, 1	//placing a 1 into t3 as a conditional control
  addu t2, a0, zero	//taking a copy of x; let's call it temp
  
  //Check if a1, y, is == 1; to skip repeated addition
  beq a1, t3, y_param_one
  nop
  
  //reset $t4 negative param 'flag'
  move t4, zero
  //Check if a1, y, is <0; to cast it to absolute value, then make product -neg
  bgtz a1, mult_loop
  nop
  abs a1, a1 // `abs` pseudoinstruction is valid mips, but shows in wrong color
  ori t4, zero, 808 //put 808 flag into
  //fall-thru to mult_loop
  
mult_loop:
  addu t2, t2, a0	// temp = temp + x
  addiu a1, a1, -1	// y = y - 1
  beq a1, t3, mult_operation_done
  nop
  j mult_loop
  nop
  
  mult_operation_done:
    //set $t5 flag to 808 to check $t4
    ori t5, zero, 808
    bne t4, t5, operation_done
    nop
    
    //negative param y, subtract $t2 from 0 to make $t2 -neg 
    sub t2, zero, t2
    
    
    j operation_done
    nop
  
  //x or y was a 0, so just set t2 to zero and leave
  zero_param:
    move t2, zero
    j operation_done
    nop
    
    y_param_one:
    move t2, a0	    //$t2 == x
    j operation_done
    nop
  
//end RPN_multiply
  
  
RPN_add:
  //$v0 = x + y ;;; keep x on left hand side for subtraction as well
  add t2, a0, a1
  
  j operation_done
  nop
  //end RPN_add
  
RPN_subtract:
//$v0 = x - y ;;; keep x on left hand side for subtraction
  sub t2, a0, a1
    
  j operation_done
  nop
  //end RPN_subtract
  

.end RPN_arithmetic_operation