.import source "lib.asm"
.import source "const.asm"

.label raster_line_1 = $2f
.label func_spindle = $0c90
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
    inc $d020
    jsr $e003
    inc $d020
    jsr $e006
    inc $d020
    jsr $e006
    inc $d020
    jsr $e006
    lda #$00
    sta $d020
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

var_initial_yscroll:
.byte $00

var_char_lines_to_crunch:
.byte $00

irq1:
	:startInterrupt()
	:doubleIRQ(raster_line_1)

    lda $d012
    cmp $d012 //;last cycle of CMP reads data from $d012
    beq !+ //;add extra cycle if still the same line
!:
    ldx #9
!: 
    dex
    bne !-
    //;this is the part that actually performs the linecrunch
    clc
    lda var_initial_yscroll
    ldx var_char_lines_to_crunch
!crunchloop:
    adc #%00000001
    and #%00000111
    ora #%00110010
    sta $d011
    ldy #8 //;notice that there is lots of time left in the rasterline for more effects!
!:
    dey
    bne !-
    nop
    nop
    nop
    nop
    nop
    nop
    dex
    bpl !crunchloop-
    and #%10111111 //;disable invalid gfx mode
    sta $d011
    lda #8
    sta $d016





    lda #$01
    sta $d020

    lda #$00
    sta $d020

    lda #$ff
    sta REG_SPRITE_ENABLE

    jsr func_play_music

    inc sin_index
    ldy sin_index
    ldx sintbl,y
    txa
    lsr
    lsr
    lsr
    sta char_lines_to_crunch
    txa
    and #7
    eor #7  //;linecrunch scrolls up, but increasing the yscroll scrolls down
            //;therefore we must flip the yscroll to make it match
    sta initial_yscroll
    clc
    adc #$30-3 //;before linecrunching takes 3 rasterlines
    sta $d012
    lda initial_yscroll
    ora #$50
    sta $d011
    lda #$18 //;use the invalid textmode to "cover up" the linecrunch bug area
    sta $d016

    :mov #<irq1: $fffe
    :mov #>irq1: $ffff
	//:mov #raster_line_1:$d012
	:mov #$ff: $d019
	:endInterrupt()

//;precalculated sine-table
.align $100

sin_index:
    .byte $00

char_lines_to_crunch:
    .byte $00

initial_yscroll:
    .byte $00

sintbl:      
    .byte 100,102,105,107,110,112,115,117,120,122,124,127,129,131,134,136,138,141,143,145,147,149,151,153,156,158,160,162,163,165,167,169,171,172,174,176,177,179,180,182,183,184,186,187,188,189,190,191,192,193,194,195,196,196,197,198,198,199,199,199,200,200,200,200,200,200,200,200,200,199,199,199,198,198,197,196,196,195,194,193,192,191,190,189,188,187,186,184,183,182,180,179,177,176,174,172,171,169,167,165,163,162,160,158,156,153,151,149,147,145,143,141,138,136,134,131,129,127,124,122,120,117,115,112,110,107,105,102,100,98,95,93,90,88,85,83,80,78,76,73,71,69,66,64,62,59,57,55,53,51,49,47,44,42,40,38,37,35,33,31,29,28,26,24,23,21,20,18,17,16,14,13,12,11,10,9,8,7,6,5,4,4,3,2,2,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,2,2,3,4,4,5,6,7,8,9,10,11,12,13,14,16,17,18,20,21,23,24,26,28,29,31,33,35,37,38,40,42,44,47,49,51,53,55,57,59,62,64,66,69,71,73,76,78,80,83,85,88,90,93,95,98

