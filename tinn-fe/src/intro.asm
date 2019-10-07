.import source "lib.asm"
.import source "const.asm"

.label raster_line_1 = $28
.label func_spindle = $0c90

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

    jsr func_spindle
    jsr func_music_enable
    jsr func_spindle
    jsr func_draw_bitmap
    jsr func_draw_bm_colors

    //interrupts and memory are setup, now load music.
    // jsr $0c90
    // _injectMusicReset()
    // lda #$01
    // sta CallMusicFlag //allow interrupts to play music now


loop:
    jmp loop

func_init:
    //set the bank to #2 with SPINDLE resident
    lda #$3d
    sta $dd02 
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

func_draw_bitmap:
    ldx #$00
!:
    lda bm_src: $8000,x
    sta bm_des: $6000,x
    inx
    bne !-
    inc bm_des + 1
    inc bm_src + 1
    lda bm_src + 1
    cmp #$a0
    bne !-
    rts

func_draw_bm_colors:
    ldx #$00
    ldy #$00
!loop:
    lda cm_src: $9f40,x
    sta cm_des: $4000,x
    inx
    cpx #$28
    bne !loop-

    ldx #$00
!:
    lda xm_src: $a338,x
    sta xm_des: $d800,x
    inx
    cpx #$28
    bne !-

    clc
    lda cm_src
    adc #$28
    sta cm_src
    lda cm_src + 1
    adc #$00
    sta cm_src + 1

    clc
    lda cm_des
    adc #$28
    sta cm_des
    lda cm_des + 1
    adc #$00
    sta cm_des + 1

    clc
    lda xm_src
    adc #$28
    sta xm_src
    lda xm_src + 1
    adc #$00
    sta xm_src + 1

    clc
    lda xm_des
    adc #$28
    sta xm_des
    lda xm_des + 1
    adc #$00
    sta xm_des + 1

    jsr func_frame_wait

    //loop
    ldx #$00
    iny 
    cpy #25
    bne !loop-
    rts

func_frame_wait:
    //pause
    ldx $d012
    dex
!wait:
    cpx $d012
    bne !wait-
    rts

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

    lda #$00		// Prep for VSP
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

    clc
    lda $d012
    adc #$08
!:
    cmp $d012
    bne !-

    lda $d011
    and #%10111111
    sta $d011

    lda #$ff
    sta REG_SPRITE_ENABLE

    jsr func_play_music
    // lda $d011
    // ora #%00111000 //$1b - border is open (with bitmap mode set)
    // sta $d011




    // and #%10111111 //;disable invalid gfx mode
    // sta $d011
    // lda #$18
    // sta $d016

    :mov #<irq1: $fffe
    :mov #>irq1: $ffff
	:mov #raster_line_1:$d012
	:mov #$ff: $d019
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

