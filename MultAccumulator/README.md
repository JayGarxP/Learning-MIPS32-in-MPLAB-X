/*************************************************************
*
* Lab/Assignment: Lab 2 – Multiplication Accumulation of
						  two same-size arrays with MIPS 32
* 
* Overview:
*		Lab2.S is a MIPS-32 1 assembly program 
*		for PIC32 microcontrollers
*		running inside the simulator inside MPLAB X IDE
*		using the X32 compiler...
*		In the data segment, hard coded words are used
*		to roughly simulate an integer Multiply/Accumulate unit,
*       the program terminates in an endless loop, use debugger
*  		to see the output.The MUL instruction is NOT allowed.
* 	
* 	
* Lab Description:
*  "Variable: MAC_ACC is a single 32-bit word 
*      variable initialized to zero.  
*      It is a running sum (i.e. accumulator) within the 
*      outer loop of a nested loop structure.
*      
*   Variables: X[] and Y[] are 20 element array variables of 32-bit words 
*     representing integers.  Each array element is referenced by the 
*     label plus an offset.
*   Variable: n is a word variable that is >= 0.  
*     The value will be programmed 
*     before assembly.  Note: For n = 0, MAC_ACC = 0."-Lab2 Handout
*    
* 	
*
* Input:
*		Hard code the values into the labels in the .data segment
*       e.g.    X: .word 4,5, ... ,# ...#
* 	
*
* Output:
*		MAC_ACC will be set to register s0 and will contain
*       the running accumulated total of X[N]*Y[N] 's
*       the value being 101 for this unaltered program.
*       See s0 value by running in debug mode and setting
*       a watch on the s0 register by right-clicking it or
*       opening the CPU registers window.
*
************************************************************/

//Adding Function Documentation
/**********************************************************************	
* Purpose: This leaf-function performs repeated addition
*
* Param-Registers:
*			a0	initial value of addend, also used to accumulate sum
*			a2  addend to repeatedly add to a0
*           a1  # of times to repeat addition
*           t3  used as loop counter; t3 must == 1
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
*	in the MAC_ACC variable, by doing (MAC_ACC += repeated-addition-function result)
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