#include <xc.h>

.global RPN_arithmetic_operation

.data   
.text
.set noreorder

.ent RPN_arithmetic_operation
RPN_arithmetic_operation:
  //creating stack frame
  addiu sp, sp, -8  //making room for two words; $ra and $fp ;
		    // downwards into lower memory addresses ;
		 //$sp is now two words lower than it was before this function.
		    
  sw ra, 4(sp)	    //store $ra value into $sp+one word;
		    // backup into higher memory addresses with positive offset.
  sw fp, 0(sp)	    //store caller $fp at bottom of our stack.
  //local variables would be allocated here;
  //	you would need to increase the $sp offset for each word variable above,
  //	and when this function exits, need to snap $sp back by the same offset
  addu fp, sp, zero //sets the bottom of our frame. $fp = new $sp

  //Store param registers already-allocated in main's stack frame
  sw a0, 8(fp)  //x
  sw a1, 12(fp) //y
  sw a2, 16(fp) //function op code; *, +, -
  
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
 
 //Now arithemetic functions will return to here
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
  addi t3, zero, 1	//placing a 1 into t3 as a conditional control
  addu t2, a0, zero	//taking a copy of x; let's call it temp
  
  //Also can't handle negative numbers at all...
  //Still has bugs if either is 0 AND the bug where is y <=one loop is endless
mult_loop:

  addu t2, t2, a0	// temp = temp + x
  addiu a1, a1, -1	// y = y - 1
  beq a1, t3, operation_done
  nop
  j mult_loop
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