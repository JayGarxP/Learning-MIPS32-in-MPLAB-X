#include <xc.h>

.global RPN_arithmetic_operation

.data   
.text
.set noreorder

.ent RPN_arithmetic_operation
RPN_arithmetic_operation:
//  //creating stack frame; error here was off by one word in the hardcoded offset
//  // memory addresses are inclusive on one side exclusive on the other;
//  //	negative offset switches this. This is why every textbook has different
//  //	diagrams in them as to where a pointer actually points.
//  addiu sp, sp, -8  //making room for two words; $ra and $fp ;
//		    // downwards into lower memory addresses ;
//		 //$sp is now two words lower than it was before this function.
//		    
//  sw ra, 4(sp)	    //store $ra value into $sp+one word;
//		    // backup into higher memory addresses with positive offset.
//  sw fp, 0(sp)	    //store caller $fp at bottom of our stack.
//  //local variables would be allocated here;
//  //	you would need to increase the $sp offset for each word variable above,
//  //	and when this function exits, need to snap $sp back by the same offset
//  addu fp, sp, zero //sets the bottom of our frame. $fp = new $sp
//
//  //Store param registers already-allocated in main's stack frame
//  sw a0, 12(fp)  //x   //NOT 8 which is what you would think...
//  sw a1, 16(fp) //y
//  sw a2, 20(fp) //function op code; *, +, -
//  
//  //end of stack frame construction
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
//     |  room for a0         |  0   $sp on enter; $fp on enter.      (12)
//     /----------------------/
//     |  RPN $ra	            |  -4                                   (8)
//     /----------------------/
//     |  RPN $fp	            |  -8 //-8 exclusive to -4 inclusive    (4)
//     /----------------------/
//     ---------->$sp and $fp
//     |  next 'open' mem space| -12				    (0)
//     /----------------------/
//     
//    */
 
    //This is working; changing the $fp early ruins everything; can't even 
    // debug this horrible mistake...
  addiu sp, sp, -8  //making room for two things!
  sw ra, 4(sp)
  sw fp, 0(sp)
  //oh look! parameters! better save em!
  //important note: I saved the a register parameters before moving the
  //frame pointer, because there's no telling how much motion the stack
  //pointer saw before entering execution into this function
  sw a0, 0(fp)
  sw a1, 4(fp) //a1 is actually ruined in the multiply label
  sw a2, 8(fp) //no reason to actually do this; just for learning.
  //that's right. I just reached OUT of my frame, and saved off some data
  addu fp, sp, zero //sets the bottom of our frame
  //end of stack frame construction
    
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
  
  //Checky if a1, y, is == 1; to skip repeated addition
  beq a1, t3, y_param_one
  nop
  
  //Also can't handle negative numbers at all...
  //Still has bugs if either is 0 AND the bug where is y <=one loop is endless
mult_loop:
  addu t2, t2, a0	// temp = temp + x
  addiu a1, a1, -1	// y = y - 1
  beq a1, t3, operation_done
  nop
  j mult_loop
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