/*************************************************************
* Author:		Joseph Fallon
* Filename:		Lab2.S
* Date Created:	10/3/2018
* Modifications:	
*		10/5/18 ? N counting functionality; ~5 hours
*  		10/9/18 ? Making Adding function, 
			  handling edge cases, etc; ~5 hours
*************************************************************
*/
    
/*************************************************************
*
* Lab/Assignment: Lab 2 ? Multiplication Accumulation of
				two same-size arrays
* 
* Overview:
*		Lab2.S is an assembly program for PIC32 microcontrollers
*		running inside the simulator inside MPLAB X IDE
*		using the X32 compiler...
*		In the data segment, hard coded words are used
*		to roughly simulate an integer Multiply/Accumulate unit
*		the program terminates in an endless loop, use debugger
*  		to see the output.
* 	
* 	
* Lab Description:
*    ""Variable: MAC_ACC is a single 32-bit word 
*	variable initialized to zero.  
*	It is a running sum (i.e. accumulator) within the 
*	outer loop of a nested loop structure.
*      
*     Variables: X[] and Y[] are 20 element array variables of 32-bit words 
*	representing integers.  Each array element is referenced by the 
*	label plus an offset.
*     Variable: n is a word variable that is >= 0.  
*	The value will be programmed 
*	before assembly.  
*      Note: For n = 0, MAC_ACC = 0.""
*		-Lab2 Handout
*    
* 	
*
* Input:
*		Hard code the values into the labels in the .data segment
*	    e.g.    X: .word 4,5, ... ,# ...#
* 	
*
* Output:
*	MAC_ACC will be set to register s0 and will contain
*       the running accumulated total of X[N]*Y[N] 's
*       the value being 101 for this unaltered program.
*       See s0 value by running in debug mode and setting
*       a watch on the s0 register by right-clicking it or
*       opening the CPU registers window.
*
************************************************************/
    #include <xc.h>
// Use PIC32MX460F512L

// can use C-like macro define statements
// #define statements follow here


.global main

.data
// data segment for READ/WRITE data follows here
// stored in volatile RAM memory

MAC_ACC: .word	0
X:	  .word 4,5,4,4,5,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0
Y:	  .word 5,4,5,5,4,1,0,0,1,0,1,2,3,4,5,6,7,8,9,10
N:	  .word 20
    
    
.text
.set noreorder
// text segment for instructions and CONSTANT READ-ONLY data follows here
// stored in non-volatile flash memory

    
.ent main
main:
  // instructions go here; main is .text which is READ-ONLY
    la t0, MAC_ACC    //loading the accumulator
    lw s0, 0(t0)	//this value will persist until the end, when we go and
		    //and jam it off into RAM once we're done accumulating
  
    la s1, X	//load the address of X[] into a register; zero-th word 
    la s2, Y	//load adrress of Y[] into s2 
  
  //Able to re-use t2 since do not need address of N ever again
    la t2, N	//load address of N array element count == words in array
    lw s3, 0(t2)	//load word N's value into s3 register
    //check if N is 0 or less so can quit early 
    blez s3, mission_complete
    nop
 
    addi t3, zero, 1	//placing a 1 into t3 as condition control
    addiu s4, zero, -4  //s4 the X[] and Y[] indexer starts at -4
			//this is done to make LoadNextElements code simpler,
			// otherwise, the first address/value in the XY arrays
			//would have to be processed seperately 
 
LoadNextElement:
    
    addiu s4, s4, 4 //increment offset by 4; 
  //Decimal immediates must work lyke bytes
  
    add s5,  s4, s1 //calc indexerX with index = offset + address
    add s6,  s4, s2 //calc indexerY
  
    lw t0, 0(s5) //load X[s5] into t0
    lw t1, 0(s6) //load Y[s6] into t1
  
    addu a0, t0, zero	//taking a copy of t0 (X[?]) val into a0
    addu v0, t0, zero  //also copying t0 into v0 makin accumulate logic simpler
  
  //Check if t0 or t1 are == zero; to skip MAC_ACC acuumulayshin
    beq zero, t0, Decrement_N
    nop
    beq zero, t1, Decrement_N
    nop
  
  //Check if Y[N--] == 1; then must skip adding_loop which assumes >2 vals
    beq t1, t3, accumulate // if y == 1; accumulate it only once 
    nop
    
    addu a1, t1, zero	//taking a copy of Y[0] val  into a1
    addu a2, a0, zero    //making a copy of X[0] into a2

    jal AddingFunction //jal with label underneath breaks with W0011-CORE:
			//Access attempt to unimplemented RAM memory;
			//nop here and after `jr ra` prevents this
    nop

//Actually increase the MAC_ACC stored in s0
accumulate: 
  addu s0, s0, v0 //Adding Function returns X[Nth] * Y[Nth]
		   // MAC_ACC is s0;  AddingFunction.return == v0
		   // s0 = (s0 + v0)
		   // MAC_ACC = (MAC_ACC + X[Nth] * Y[Nth]) 
  
Decrement_N:
    addiu s3, s3, -1 //N = N - 1;
  
  //check if N is now 0 so can be done, otherwise jump back to adding 
    beq zero, s3, mission_complete
    nop
  
    j LoadNextElement
    nop
  
mission_complete:
  //should have X[N++]*Y[N+1] in the s0 register now; default total = 101
  //set watch by rightclicking s0
  //	or Window->TargetMemory->CPU Registers
  
  
endless:
    j endless
    nop
    .end main


//Adding Function Documentation
/**********************************************************************	
* Purpose: This leaf-function performs repeated addition
*
* Param-Registers:
*			a0 initial value of addend, also used to accumulate sum
*			a2  addend to repeatedly add to a0
*			a1  # of times to repeat addition
*			t3  used as loop counter; t3 must == 1
*			(can replace t3 with a3 later if needed)
*
* Return-Registers:
*			v0  the final accumulated sum of repeated addition
*
* Precondition: 
* 		Register t3 must == 1
*		Register a1 must be >= 2
*     
*
* Postcondition: 
*      t3 remains == 1
*      a2 remains == entry value
*      a1 == 1 now
*      a0 == final accumulated sum
*      v0 == a0 == final accumulated sum
*      
*      `jr ra` will return to the line after where the program was called
*        (don't forget `nop` after all jumps!)
*
************************************************************************/
AddingFunction:
 nop //bad to have back-to-back labels like a caveman?
adding_loop:
    addu a0,  a0, a2	// x = x + x; a0 = a0 + x
    addiu a1, a1, -1	// y = y - 1
    beq a1, t3, adding_done // if y == 1; finish looping
    nop
    j adding_loop
    nop

adding_done:
    addu v0, a0, zero    //save x + x into v0
    jr ra  //return 
    nop //VERY IMPORTANT to have nop after jumps; especially `jr ra`
    
    
/* PSEUDOCODE
*	Accumulated Value = X[0] * Y[0] + X[1] * Y[1] ... for N times
*	All values are ints, N >= 0; Not allowed to use MUL instruction
*
*
*
*  .data
*  Allocate words (32 bit == 4 byte) for the X array (X[]), Y[]
*  and the element count N
*  
*  .text
*  load the addresses of the X&Y arrays, N, and the MAC_ACC label
*  load the first word of the N address
*
*  Check if N == 0; if it is we can skip the whole program and exit,
*  MAC_ACC is zero already.
*
*  Store an offset, increment it by one byte (the immediate 4) each time
*  you need to index into the arrays.
*  since memory addresses and instructions and values are ALL 32 bits,
*  we can index into arrays by adding the arrays ARRAY[0] zero-th byte
*  aka the arrays address, and use an add instruction to move an amount
*  of bytes into the array; since X[] and Y[] have elements of an entire
*  word size, adding 4 bytes to the 'indexer' will get the next value in
*  the array.
*  
*  ARRAY INDEXING LOOP:
*  increase offset by + 4 bytes (one word)
*  load the value at X[offset]
*  load the value at Y[offset]
*  
*		REPEATED-ADDITION-FUNCTION
*		  for Y[offset] times:
*		  add X[offset] + X[offset]
*		
*	When done, store the repeated-addition-functions result
*	in the MAC_ACC variable, by doing 
*	(MAC_ACC += repeated-addition-function result)
*    
*  Now, decrement N (N--;) then check if N equals zero
*  if N is zero, the arrays have been fully multiplied and accumulated.
*  
*  Display output (MPLAB does not make this easy)
*/
    
    
    
/* MEMORY-MAP
* Used registers:
* 	t0,t1,t2,t3,t4
*   s0,s1,s2,s3,s4,s5,s6
* 
* Possible to optimize away t3, s3, s4, s5, s6
*    by using immediates, but it makes debugging much harder.
*/

/* WHAT'S NEXT?
* Array iteration function;
* I/O to avoid hardcoding and display the results using UART bus,
* or c code that can use printf() correctly in MPLAB X IDE;
* Stack to handle big numbers and/or nested functions
*/