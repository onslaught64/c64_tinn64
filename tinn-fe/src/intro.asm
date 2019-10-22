.import source "lib.asm"
.import source "const.asm"

.label raster_line_1 = $28

.label zp_vsp_fd = $c0
.label zp_vsp_fe = $c1
.label zp_vsp_ff = $c2

/*
Virtual Bitmap Addresses:
Advanced Art Studio
load address: is normally $2000 but we are loading to $8000
$8000 - $9F3F   Bitmap
$9F40 - $a327   Screen RAM
$a328           Border
$a329           Background
$a338 - $a71F   Color RAM
*/


/*
Memory Map:
$0800 - $0fff:      Spindle Code
$1000 - $3fff:      Demo Code
$4000 - $43ff:      Screen RAM
$6000 - $7fff:      Bitmap
$8000 - $a7ff:      OCP LOAD BUFFER
*/


.pc = $1000 "Program"
start:
	:mov #$00: REG_BORCOLOUR
	:mov #$00: REG_BGCOLOUR
    :fill_1K($20, $0400) //remove this later - used for debug
	:fill_1K($00, $d800) //clear color ram
    :fill_8K($00, $4000)
    :fill_8K($00, $6000)
    jsr func_init
	:setupInterrupt(irq1, raster_line_1) // last six chars (with a few raster lines to stabalize raster)
    jmp func_main
    // jsr func_music_enable

func_init:
    //set the bank to #2 with SPINDLE resident
    lda $dd00
    and #%11111100
    ora #%00000010
    sta $dd00 

    //set screen mem to $0000 and bitmap to $2000 (+ bank)
    lda #%00001000 
    sta $d018
    //turn on Multicolor mode
    lda $d016
    ora #%00010000
    sta $d016
    //setup bottom border and bitmap mode
    lda #%00110011 //$13 - border is closed (with bitmap mode set)
    sta $d011
    lda #%00111011 //$1b - border is open (with bitmap mode set)
    sta $d011
    lda #$00
    sta zp_vsp_fd
    sta zp_vsp_fe
    sta zp_vsp_ff
    rts

func_music_enable:
    lda #$00
    jsr $e000
    lda #$01
    sta var_music_enable
    rts

func_play_music:
    lda var_music_enable
    bne !+
    rts
!:
    jsr $e003
    jsr $e006
    jsr $e006
    jsr $e006
    lda #$00
    rts

var_music_enable:
.byte  $00

// func_draw_bitmap:



//     ldx #$00
//     //reset code
//     lda #$00
//     sta bm_src
//     sta bm_des
//     lda #$80
//     sta bm_src + 1
//     lda #$60
//     sta bm_des + 1
//     //now do it
// !:
//     lda bm_src: $8000,x
//     sta bm_des: $6000,x
//     inx
//     bne !-
//     inc bm_des + 1
//     inc bm_src + 1
//     lda bm_src + 1
//     cmp #$a0
//     bne !-
//     rts



irq1:
	:startInterrupt()
	:doubleIRQ(raster_line_1)

    // and #%10111111 //;disable invalid gfx mode
    // sta $d011
    // lda #$18
    // sta $d016

    lda #$2f
waitForRaster:
    cmp $d012
    bne waitForRaster
    bit $d011
    bmi waitForRaster

    nop
    nop

    lda #%01001000		// Prep for VSP
    sta $d011

    // delay a bit for correct raster pos
    bit * 		// 4
    nop 			// 2
    bit $04  		// 3
    
    lda zp_vsp_fe  		// 3
    sta $d016  		// 4

    // delay!	
    lda zp_vsp_ff	
    lsr
    bcs !next+	// waist 1 cycle for odd number offsets
!next:
    tax
    lda #$60		// self modifying rts to the correct position in waitnops sub routine
    sta waitnops,x
    jsr waitnops
    lda #$ea		// self modifying nop to the correct position in waitnops sub routine
    sta waitnops,x
    
    lda #%01111000
    sta $d011		// VSP that shit
    inc zp_vsp_fd
    ldx zp_vsp_fd
    lda ffTab,x
    sta zp_vsp_ff
    lda feTab,x
    sta zp_vsp_fe

//delay to the end of first corrupt row -1
    clc
    lda $d012
    adc #$06

!:
    cmp $d012
    bne !-

//delay into the line
    ldx #$08
!:
    dex
    bne !-

// turn off illegal display mode
    lda $d011
    and #%10111111
    sta $d011 

// wait badline
    lda #$01
    sta $d020
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda #$00
    sta $d020

    //fix the start line
    clc
    lda $d012
    adc #$05    

!:
    cmp $d012
    bne !-


    ldy fldsize: #00
!main:
    lda fldTab,y
    tax
    beq !end+ //Skip if we want 0 lines FLD
!loop:
    lda $d012 //Wait for beginning of next line
!:
    cmp $d012
    beq !-

    clc // Do one line of FLD
    lda $d011
    adc #$01
    and #$07
    ora #$38 //multicolor
    sta $d011


    dex //Decrease counter
    bne !loop-
!end:
//delay to the end of next char

    clc
    lda #$e7
    cmp $d012
    bcc !end+

    clc
    lda $d012
    adc #$08
!:
    cmp $d012
    bne !-

    iny
    jmp !main-
 !end:
    inc fldsize

lda #$f6
!:
cmp $d012
bne !-
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
    lda $d011
    ora #%01001000
    sta $d011 

lda #$f9
!:
cmp $d012
bne !-
    lda $d011
    and #%11110111
    sta $d011 



lda #$01
sta $d021

    lda #$ff
    sta REG_SPRITE_ENABLE

    //jsr func_play_music


    // and #%10111111 //;disable invalid gfx mode
    // sta $d011
    // lda #$18
    // sta $d016

    :mov #$ff: $d019
    :mov #<irq1: $fffe
    :mov #>irq1: $ffff
	:mov #raster_line_1:$d012
	:endInterrupt()


waitnops:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rts



//;precalculated sine-table
.align $100
feTab:
	.fill 256, mod((159 + sin(i/256*3.141592654*2.0)*159),8) | %00010000
ffTab:
	.fill 256, mod((159 + sin(i/256*3.141592654*2.0)*159)/8,40)
fldTab:
	.fill 128, sinus(i, 4, 4, 128)
    .fill 128, 00



func_dissolve_out:
    lda #$00
    sta counter
!:
    jsr func_plot_black
    clc
    lda counter
    adc dissolve
    sta counter
    bne !-
    jsr func_wipe_ocs_colors
    rts

func_dissolve_in:
    jsr func_draw_ocs_colors
    lda #$00
    sta counter
!:
    jsr func_plot_original
    clc
    lda counter
    adc dissolve
    sta counter
    bne !-
    rts

counter:
.byte $00

dissolve:
.byte $39

func_plot_original:
    tay
    and #%00000011
    asl
    tax
    tya
    lsr
    lsr
    tay
    .for(var i=0;i<$80;i++){
        lda $8000 + (i*$40),y
        and OR_BITMASKS,x
        ora $6000 + (i*$40),y        
        sta $6000 + (i*$40),y
    }
    rts

func_plot_black:
    tay
    and #%00000011
    asl
    tax
    tya
    lsr
    lsr
    tay
    .for(var i=0;i<$80;i++){
        lda $6000 + (i*$40),y
        and AND_BITMASKS,x
        sta $6000 + (i*$40),y
    }
    rts    

OR_BITMASKS:
    .byte %11000000, %11000000, %00110000, %00110000, %00001100, %00001100, %00000011, %00000011
AND_BITMASKS:
    .byte %00111111, %00111111, %11001111, %11001111, %11110011, %11110011, %11111100, %11111100

func_draw_ocs_colors:
    ldx #$00
!:
    .for(var i=0;i<4;i++){
        lda $9f40 + (i * $100),x
        sta $4000 + (i * $100),x
        lda $a338 + (i * $100),x
        sta $d800 + (i * $100),x
    }
    inx
    bne !-
    rts

func_wipe_ocs_colors:
    ldx #$00
!:
    .for(var i=0;i<4;i++){
        lda #$00
        sta $4000 + (i * $100),x
        sta $d800 + (i * $100),x
    }
    inx
    bne !-
    rts

func_main:
tempLoop:

    //load bitmap
    ldx #'0'
    ldy #'3'
    lda #$80
    sta $ff
    lda #$00
    sta $fe
    jsr $cf00

dis:
    jsr func_dissolve_in
ldx #$00
ldy #$00
!:
dex
bne !-
dey
bne !-
    jsr func_dissolve_out
    jmp dis


    //load bitmap
    ldx #'0'
    ldy #'4'
    lda #$80
    sta $ff
    lda #$00
    sta $fe
    jsr $cf00

    jsr func_dissolve_out

    jsr func_dissolve_in


inc dissolve
inc dissolve
lda dissolve
sta $c000

jmp tempLoop
    //interrupts and memory are setup, now load music.
    // jsr $0c90
    // _injectMusicReset()
    // lda #$01
    // sta CallMusicFlag //allow interrupts to play music now


loop:
    jmp loop
