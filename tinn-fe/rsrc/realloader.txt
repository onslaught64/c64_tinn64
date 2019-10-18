This is a loader ripped from the game Street Gang (as far as I can remember) which I ripped and reused all over the place. 
I have modified different versions of this loader all over the place so I cannot guarantee this is the original...  

1. init (load the irq loader to disk RAM) jsr $cc00

2. load by jsr to $cf00 as follows:

ldy #$ petscii filename char 1
ldx #$ petscii filename char 2
lda #$ hi byte of load address
sta $ff
lda #$ lo byte of load address
sta $fe
jsr $cf00 

This is a blocking call, however it allows IRQ to continue running.
Note that filenames are limited to 2 chars

