#include <xc.h>
// Use PIC32MX460F512L

// can use C-like macro define statements
// #define statements follow here

    /*
Variable: MAC_ACC is a single 32-bit word variable initialized to zero.  
     It is a running sum (i.e. accumulator) within the outer loop of a nested 
     loop structure.
Variables: X[] and Y[] are 20 element array variables of 32-bit words 
     representing integers.  Each array element is referenced by the 
     label plus an offset.
Variable: n is a word variable that is >= 0.  The value will be programmed 
     before assembly.  Note: For n = 0, MAC_ACC = 0.
    */
.global main

.data
// data segment for READ/WRITE data follows here
// stored in volatile RAM memory

MAC_ACC: .word	0
X:	  .word 1,2,3,1,0
Y:	  .word 0,4,5,7,1
N:	  .word 5
    
.text
.set noreorder
// text segment for instructions and CONSTANT READ-ONLY data follows here
// stored in non-volatile flash memory

.ent main
main:
  // instructions go here; main is .text which is READ-ONLY
  la t0, MAC_ACC    //loading the accumulator
  lw s0, 0(t0)	    //this value will persist until the end, when we go and
		    //and jam it off into RAM once we're done accumulating
  
  la s1, X	//load the address of x into a register; note: I went for
		//non-volatile, and why I did that will become apparent shortly
  lw t0, 0(s1)  //pull the value of x at the current index into a register
  
  la s2, Y	//load adrress of Y[] into s2 
  lw t1, 0(s2)  //load word of 
  
  
  //Able to re-use t2 since do not need address of N ever again
  la t2, N	//load address of N array element count == words in array
  lw s3, 0(t2)	//load word N's value into s3 register
 
  
  addi t3, zero, 1	//placing a 1 into t3 as condition control
  addu t4, zero, zero  //t4 the X[] and Y[] indexer starts at 0
 
 
  //After loading new values from arrays; check if either are 0
  beq zero, t0, Decrement_N
  nop
  beq zero, t1, Decrement_N
  nop
  
  
  addu t2, t0, zero	//taking a copy of X[0] val  into t2
  
  //Check if Y[0] == 1; then must skip adding_loop which assumes >2 vals
  beq t1, t3, adding_done // if y == 1; accumulate it only once 
  nop
  
  
adding_loop:
  addu t2,  t2, t0	// x = x + x; t2 = t2 + x
  addiu t1, t1, -1	// y = y - 1
  beq t1, t3, adding_done
  nop
  j adding_loop
  nop
adding_done:
  addu s0, s0, t2 //accumulate t2 (X+X for Y times) into s0 (MAC_ACC)
  
Decrement_N:
  addiu s3, s3, -1
  
  //check if N is now 0 so can be done, otherwise jump back to adding 
  beq zero, s3, mission_complete
  nop
  
  //Now load next elements of X[] into t0 and Y[] into t1
  //then jump back up to adding_loop label
  
  //set offset reg to reg+4
  // XY[n] = add reg + address of array
  // lw $value, XY[n] 
  
  addiu s4, s4, 4 //increment offset by 4; 
  //not sure how address + number is calculated
  //Decimal immediates must work lyke bytes
  
  add s5,  s4, s1 //calc indexerX with index = offset + address
  add s6,  s4, s2 //calc indexerY
  
  
  
  lw t0, 0(s5) //load X[s5] into t0
  lw t1, 0(s6) //load Y[s6] into t1
  
  
  addu t2, t0, zero	//taking a copy of t0 (X[?]) val into t2
  
  //Check if t0 or t1 are == zero; to skip MAC_ACC acuumulayshin
  beq zero, t0, Decrement_N
  nop
  beq zero, t1, Decrement_N
  nop
  
  //Check if Y[N--] == 1; then must skip adding_loop which assumes >2 vals
  beq t1, t3, adding_done // if y == 1; accumulate it only once 
  nop
    
  j adding_loop
  nop
  
mission_complete:
  //should have 23 in the s0 register now; set watch by rightclicking s0
  //	or Window->TargetMemory->CPU Registers
  
  
endless:
  j endless
  nop
  
.end main

  // constants go here



