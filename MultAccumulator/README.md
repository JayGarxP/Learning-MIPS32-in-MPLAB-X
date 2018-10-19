Lab 2 – Multiplication Accumulation of
		   two same-size arrays with MIPS 32
 ### Overview:
		Lab2.S is a MIPS-32 1 assembly program 
		for PIC32 microcontrollers
		running inside the simulator inside MPLAB X IDE
		using the X32 compiler...
		In the data segment, hard coded words are used
		to roughly simulate an integer Multiply/Accumulate unit,
   		the program terminates in an endless loop, use debugger
  		to see the output.The MUL instruction is NOT allowed.
 	
 	
 Lab Description:
  "Variable: MAC_ACC is a single 32-bit word 
      variable initialized to zero.  
      It is a running sum (i.e. accumulator) within the 
      outer loop of a nested loop structure.
      
   Variables: X[] and Y[] are 20 element array variables of 32-bit words 
     representing integers.  Each array element is referenced by the 
     label plus an offset.
   Variable: n is a word variable that is >= 0.  
     The value will be programmed 
     before assembly.  Note: For n = 0, MAC_ACC = 0."-Lab2 Handout
    
 	

 Input:
		Hard code the values into the labels in the .data segment
       e.g.    X: .word 4,5, ... ,# ...#
 	

 Output:
		MAC_ACC will be set to register s0 and will contain
       the running accumulated total of X[N]*Y[N] 's
       the value being 101 for this unaltered program.
       See s0 value by running in debug mode and setting
       a watch on the s0 register by right-clicking it or
       opening the CPU registers window.




### PSEUDOCODE
	Accumulated Value = X[0] * Y[0] + X[1] * Y[1] ... for N times
	All values are ints, N >= 0; Not allowed to use MUL instruction
