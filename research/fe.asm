.import source "lib.asm"
.import source "easingLib.asm"
.import source "const.asm"

/*
Default-segment:
  $0801-$080d Basic Upstart
  $0c00-$0cff Unnamed
  $0d00-$0e96 Messages
  $0e97-$0ec7 Help Colours
  $1000-$19ff Music
  $2000-$2206 Keyboard Scan Routine
  $2800-$2d01 Program
  $2d02-$2f6c Datasets
*/

// .var music = LoadSid("../rsrc/Island_Lore.sid")
// _outputMusicInfo()

//Values

.label PLOT_WIDTH = $10
.label PLOT_HEIGHT = $10
.label REAL_WIDTH = $08 //plot width / 2
.label REAL_HEIGHT = $08 //plot height / 2
.label PLOTTER_X_OFFSET = (40-16)/2 //offset of screen from left hand side
.label PLOTTER_Y_OFFSET = 1
.label rasterLine = $10

//Zeropage

.pc = $0801 "Basic Upstart"
:BasicUpstart(start) // 10 sys$0810
.pc =$1a00 "KeyboardHandler"
funcKeys:
	jsr ReadKeyboard
	bcs !NoValidInput+
	jmp !skip+
!NoValidInput:
	lda #$00
	sta LAST_EVENT
	sta LAST_EVENT + 1
	sta LAST_EVENT + 2
	rts
!skip:
	cpx LAST_EVENT
	bne !skip+
	cpy LAST_EVENT + 1
	bne !skip+
	cmp LAST_EVENT + 2
	bne !skip+
	rts
!skip:
	stx LAST_EVENT
	sty LAST_EVENT + 1
	sta LAST_EVENT + 2
    jmp $1a80
.pc = $1a80 "keysTarget"
    jmp keysTarget: $ffff
    rts

.import source "gui.input.keyboard_scan.asm"
.pc = * "Code"
start:
	:mov #$00: $d020
	:mov #$00: $d021
	:fill_1K($0f, $d800)
    :fill_1K($20, $0400) //clear screen with blank chars
    jsr funcInitData

jsr funcInitBackground
jsr funcHelp
!:
jmp !-

nop

	:setupInterrupt(irq, rasterLine) // last six chars (with a few raster lines to stabalize raster)
!loop:
    jsr funcKeys
    jmp !loop-

/********************************************
MAIN INTERRUPT LOOP
*********************************************/

irq:
	:startInterrupt()
	//:doubleIRQ(rasterLine + 1)
    
    inc $d020
//    jsr music.play
    dec $d020
    
    //jsr funcKeys
    // ldy CURSOR_Y
    // ldx CURSOR_X
    // jsr funcPositionCursor
    // jsr funcColorCursor
    // jsr funcDrawHelp


	:mov #<irq: $fffe
    :mov #>irq: $ffff
	:mov #rasterLine:$d012
	:mov #$ff: $d019
	:endInterrupt()

//import the window library
.import source "help.asm"






/********************************************
FUNCTIONS
*********************************************/


/*
--------------------------------------------------------------------------------------------
initialise all data for the program
--------------------------------------------------------------------------------------------
*/
funcInitData:
    ldx #$00
    ldy #$00
    // lda #music.startSong
    // jsr music.init
    //init the screen
    //jsr funcDrawScreen
    lda #$17
    sta $d018
    rts


funcInitCursor:
    lda #$01
    sta REG_SPRITE_ENABLE
    ldx #$00
    ldy #$00
    jsr funcPositionCursor
    lda #$00
    sta REG_SPRITE_MULTICOLOUR
    lda #$30 //
    sta REG_SPRITE_DATA_PTR_0
    rts

/*
Fill the background text and colors
TODO: copy a background petscii background  
*/
funcInitBackground:
    lda #$df
    ldx #$00
!:
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne !-

    lda #$0c
    ldx #$00
!:
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    inx
    bne !-
    rts






/*
--------------------------------------------------------------------------------------------
position the cursor
--------------------------------------------------------------------------------------------
x = x position
y = y position
a = destroyed
*/
funcPositionCursor:
    lda CURSOR_X_LUT,x
    sta REG_SPRITE_X_0
    lda CURSOR_Y_LUT,y
    sta REG_SPRITE_Y_0
    rts

funcColorCursor:
    ldx color_offset: #$00
    lda CURSOR_COLOR_LUT,x
    cmp #$ff
    bne !skip+
    lda #$01
    sta color_offset
    lda CURSOR_COLOR_LUT
!skip:
    sta REG_SPRITE_COLOUR_0
    inc color_offset
    rts

/*
--------------------------------------------------------------------------------------------
draw pixel using plots to buffer (not screen)
--------------------------------------------------------------------------------------------
x = x position
y = y position
a = destroyed
*/
funcDrawPixel:
    txa
    clc
    jmp !calc+
!loop:
    adc #PLOT_WIDTH - 1
    dey
!calc:
    cpy #$00
    bne !loop-
    tax
    lda SCREEN_BUFFER,x 
    eor #$01
    sta SCREEN_BUFFER,x 
    rts


/*
--------------------------------------------------------------------------------------------
Draw Screen (plots)
--------------------------------------------------------------------------------------------
x,y,a = destroyed

*/
funcDrawScreen:
    //top and bottom border
    ldx #$00
!loop:
    lda #160
    sta BASE_CHAR_RAM + ((PLOTTER_Y_OFFSET-1) * SCREEN_WIDTH) + (PLOTTER_X_OFFSET - 1) ,x
    sta BASE_CHAR_RAM + ((PLOTTER_Y_OFFSET + REAL_HEIGHT) * SCREEN_WIDTH) + (PLOTTER_X_OFFSET - 1) ,x
    lda #$0c
    sta BASE_COLOUR_RAM + ((PLOTTER_Y_OFFSET-1) * SCREEN_WIDTH) + (PLOTTER_X_OFFSET - 1) ,x
    sta BASE_COLOUR_RAM + ((PLOTTER_Y_OFFSET + REAL_HEIGHT) * SCREEN_WIDTH) + (PLOTTER_X_OFFSET - 1) ,x
    inx
    cpx #REAL_WIDTH + 2 
    bne !loop-


    .for(var i=0;i<REAL_HEIGHT;i++){
        //side border
        lda #160
        sta BASE_CHAR_RAM + (PLOTTER_Y_OFFSET * SCREEN_WIDTH) + (i * SCREEN_WIDTH) + (PLOTTER_X_OFFSET - 1)
        sta BASE_CHAR_RAM + (PLOTTER_Y_OFFSET * SCREEN_WIDTH) + (i * SCREEN_WIDTH) + (PLOTTER_X_OFFSET + REAL_WIDTH)
        lda #$0c
        sta BASE_COLOUR_RAM + (PLOTTER_Y_OFFSET * SCREEN_WIDTH) + (i * SCREEN_WIDTH) + (PLOTTER_X_OFFSET - 1)
        sta BASE_COLOUR_RAM + (PLOTTER_Y_OFFSET * SCREEN_WIDTH) + (i * SCREEN_WIDTH) + (PLOTTER_X_OFFSET + REAL_WIDTH)

        //plot the row
        lda #PLOT_WIDTH * i * 2
        sta fds_index //screen buffer index (x)
        ldy #$00
!loop:
        lda #$00
        sta fds_buffer //reset the quad buffer
        clc
        ldx fds_index: #$00
        lda SCREEN_BUFFER,x
        lsr
        rol fds_buffer //set top left bit
        inx
        clc
        lda SCREEN_BUFFER,x
        lsr
        rol fds_buffer //set top right bit
        txa
        inx //update the index for next iteration in the loop
        stx fds_index //update the index for next iteration in the loop
        clc
        adc #PLOT_WIDTH - 1 //skip ahead a line - 1 in the screen buffer 
        tax
        clc
        lda SCREEN_BUFFER,x 
        lsr
        rol fds_buffer //set bottom left bit
        inx
        clc
        lda SCREEN_BUFFER,x
        lsr
        rol fds_buffer //set bottom right bit
        lda fds_buffer: #$00 //quad buffer 
        tax
        lda PIXEL_LUT,x
        sta BASE_CHAR_RAM + (PLOTTER_Y_OFFSET * SCREEN_WIDTH) + (i * SCREEN_WIDTH) + PLOTTER_X_OFFSET,y
        iny
        cpy #REAL_WIDTH
        bne !loop-
    }
    rts




funcHandleDrawKeys:
	cpx #%10000000
	beq !updown+
	cpx #%00000100
	beq !rightleft+
	cpx #%00000010
	beq !return+
    cmp #$20
    beq !space+
	rts
!updown:
    cpy #%01000000
    beq !up+
    cpy #%00010000
    beq !up+
    //go down
    lda CURSOR_Y
    cmp #PLOT_HEIGHT-1
    beq !skip+
    inc CURSOR_Y
!skip:
    rts
!up:
    //go up
    lda CURSOR_Y
    cmp #$00
    beq !skip+
    dec CURSOR_Y
!skip:
	rts
!rightleft:
    cpy #%01000000
    beq !left+
    cpy #%00010000
    beq !left+
    //go right
    lda CURSOR_X
    cmp #PLOT_WIDTH-1
    beq !skip+
    inc CURSOR_X
!skip:
    rts
!left:
    //go left
    lda CURSOR_X
    cmp #$00
    beq !skip+
    dec CURSOR_X
!skip:
	rts
!return:
    //send to AI
    inc $d020
    jsr nnFProp
    dec $d020
    
    sta $c000

!skip:
	rts
!space:
    ldx CURSOR_X
    ldy CURSOR_Y
    jsr funcDrawPixel
    jsr funcDrawScreen
!skip:
	rts

LAST_EVENT:
.byte $00, $00, $00

TOGGLE_STATE:
.byte $00
//00 everything
//ff nothing


//import neural net!!!
.align $100
.pc = * "Neural Net"
.import source "./nn.asm"




/********************************************
DATASETS
*********************************************/
.pc = * "Datasets"
PIXEL_LUT:
.byte 32  //0000 
// 00
// 00

.byte 108 //1000
// 00
// 01

.byte 123 //0100
// 00
// 10

.byte 98  //1100
// 00
// 11

.byte 124 //0010
// 01
// 00

.byte 225 //1010
// 01
// 01

.byte 255 //0110
// 01
// 10

.byte 254 //1110
// 01
// 11

.byte 126 //0001
// 10
// 00

.byte 127 //1001
// 10
// 01

.byte 97  //0101
// 10
// 10

.byte 252 //1101
// 10
// 11

.byte 226 //0011
// 11
// 00

.byte 251 //1011
// 11
// 01

.byte 236 //0111
// 11
// 10

.byte 160 //1111
// 11
// 11



.align $100
.label base_cursor_x = $18 + (PLOTTER_X_OFFSET * 8)
CURSOR_X_LUT:
.for (var i=0;i<PLOT_WIDTH+1;i++) {
    .byte base_cursor_x + ($04 * i)
}

.label base_cursor_y = $32 + (PLOTTER_Y_OFFSET * 8) 
CURSOR_Y_LUT:
.for (var i=0;i<PLOT_HEIGHT+1;i++) {
    .byte base_cursor_y + ($04 * i)
}

CURSOR_X:
    .byte $00

CURSOR_Y:
    .byte $00

CURSOR_COLOR_LUT:
    .byte $06, $0b, $06, $0b, $06, $0b, $06, $0b
    .byte $06, $06, $06, $06, $06, $06, $06, $06
    .byte $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
    .byte $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
    .byte $03, $0f, $03, $0f, $03, $0f, $03, $0f
    .byte $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
    .byte $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
    .byte $06, $06, $06, $06, $06, $06, $06, $06
    .byte $06, $0b, $06, $06, $0b, $06, $0b, $06
    .byte $ff



//MUSIC INJECTION
// .pc=music.location "Music"
// .fill music.size, music.getData(i)

//SPRITE CURSOR
.pc=$0c00 "Sprite Cursor"
.byte %11110000, %00000000, %00000000
.byte %10010000, %00000000, %00000000
.byte %10010000, %00000000, %00000000
.byte %11110000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000

.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000

.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000
.byte %00000000, %00000000, %00000000

.align $100
.pc = * "Messages"
INSTRUCTIONS:
.text "                                        "
.text "neural network demo                     "
.text "                     by ziggy of defame "
.text "use arrow keys to move the cursor       "
.text "press space to draw / erase             "
.text "press return to use image recognition   "
.text "this demo uses a hidden layer neural net"
.text "to perform real-time image recognition  "
.text "the training engine is based on tinn    "
.text "                                        "
.byte $00, $00, $00, $00, $00, $00, $00

.pc = * "Help Colours"
HELP_COLORS:
.byte 2, 2, 2, 10, 10, 10, 7, 7, 7, 10, 10, 10, 2, 2, 2, 0, 0 ,0, 0, 0
.byte 6, 6, 6, 14, 14, 14, 3, 3, 3, 14, 14, 14, 6, 6, 6, 0, 0, 0, 0, 0
.byte 0, 0, 0, 0, 0, 0, 0, 0, 0

// .label black = 0
// .label white = 1
// .label red = 2
// .label cyan = 3
// .label purple = 4
// .label green = 5
// .label blue = 6
// .label yellow = 7
// .label orange = 8
// .label brown = 9
// .label pink = 10
// .label dgrey = 11
// .label grey = 12
// .label lgreen = 13
// .label lblue = 14
// .label lgrey = 15

/********************************************
MACROS
*********************************************/

// .macro _outputMusicInfo(){
//     //----------------------------------------------------------
// // Print the music info while assembling
// .print ""
// .print "SID Data"
// .print "--------"
// .print "location=$"+toHexString(music.location)
// .print "init=$"+toHexString(music.init)
// .print "play=$"+toHexString(music.play)
// .print "songs="+music.songs
// .print "startSong="+music.startSong
// .print "size=$"+toHexString(music.size)
// .print "name="+music.name
// .print "author="+music.author
// .print "copyright="+music.copyright
// .print ""
// .print "Additional tech data"
// .print "--------------------"
// .print "header="+music.header
// .print "header version="+music.version
// .print "flags="+toBinaryString(music.flags)
// .print "speed="+toBinaryString(music.speed)
// .print "startpage="+music.startpage
// .print "pagelength="+music.pagelength
// }



