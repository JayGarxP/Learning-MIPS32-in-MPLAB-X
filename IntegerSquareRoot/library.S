#include <xc.h>

.global output_string

.ent output_string
output_string:

    //called function stack frame
    addiu sp, sp, -8
    sw ra, 4(sp)
    sw fp, 0(sp)
    sw a0, 8(sp) //inbount a0 parameter, stored in calling function's stack frame
    addu fp, sp, zero

get_byte:
  lb s0, 0(a0)
  beq s0, zero, done
  nop
send:
  // send TX data
  la s2, U1TXREG
  sw s0, 0(s2)
  la s2, U1STA
wait_tx:
  lw s1, 0(s2)
  andi s1, s1, 0x100
  beq s1, zero, wait_tx
  nop
next:
  addu a0, a0, 1
  j get_byte
  nop
done:

    //called function stack frame wind-up
    addu sp, fp, zero
    lw ra, 4(sp)
    lw fp, 0(sp)
    addiu sp, sp, 8
    //now we've restored all we need; time to go
    jr ra
    nop

.end output_string

