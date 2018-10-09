
    #include <xc.h>
// Use PIC32MX460F512L
.global main
.data
MAC_ACC: .word	0
X:	  .word 4,5,4,4,5,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0
Y:	  .word 5,4,5,5,4,1,0,0,1,0,1,2,3,4,5,6,7,8,9,10
N:	  .word 20
    
.text
.set noreorder
  
.ent main
main:
    la t0, MAC_ACC    //loading the accumulator
    lw s0, 0(t0)	
  
    la s1, X	//load the address of X[] into a register; zero-th word 
    la s2, Y	//load adrress of Y[] into s2 
  
    la t2, N	//load address of N array element count == words in array
    lw s3, 0(t2)	//load word N's value into s3 register
   
    blez s3, mission_complete
    nop
 
    addi t3, zero, 1	//placing a 1 into t3 as condition control
    addiu s4, zero, -4  //s4 the X[] and Y[] indexer starts at -4
 
LoadNextElement:
    
    addiu s4, s4, 4 //increment offset by 4; 
  
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

    jal AddingFunction
    nop

//Actually increase the MAC_ACC stored in s0
accumulate: 
  addu s0, s0, v0 //Adding Function returns X[Nth] * Y[Nth]
  
Decrement_N:
    addiu s3, s3, -1 //N = N - 1;
  
  //check if N is now 0 so can be done, otherwise jump back to adding 
    beq zero, s3, mission_complete
    nop
  
    j LoadNextElement
    nop
  
mission_complete:  
endless:
    j endless
    nop
    .end main

AddingFunction:
 nop 
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