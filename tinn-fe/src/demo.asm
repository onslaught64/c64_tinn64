.import source "lib.asm"
.import source "const.asm"
// setup jump tables for this local code to work
.var enable_trans = depack + 3
.var disable_trans = depack + 6
.label charset_ptr_lo=$02
.label charset_ptr_hi=$03
.label scroller_ptr_lo=$04
.label scroller_ptr_hi=$05


.macro load(filenameA, filenameB, loadAddress){
    load:
    ldx fna:  #filenameA
    ldy fnb:  #filenameB
    lda fhi:  #>loadAddress
    sta $ff
    lda flo:  #<loadAddress
    sta $fe
    jsr loader_load
}

BasicUpstart2(start)
* = $0810 "Program Start"
start:
    sei
    jsr loader_init
    cli
    lda #$00
    sta $d020
    sta $d021
    jsr $e544 // clear screen
    jsr reset_sprites
    lda#$17
    sta $d018	
    lda#$80
    sta $0291

    sei             
    lda #$7f       // Disable CIA
    sta $dc0d

    lda $d01a      // Enable raster interrupts
    ora #$01
    sta $d01a

    lda $d011      // High bit of raster line cleared, we're
    and #$7f       // only working within single byte ranges
    sta $d011

    lda #$01    // We want an interrupt at the top line
    sta $d012

    lda #<irq    
    sta $0314    
    lda #>irq
    sta $0315
    cli  

    jsr ui_base
    jsr ui_welcome
    jsr press_space
loop:
    jsr ui_base
    jsr ui_menu
    jsr press_menu
stop: jmp loop

keyboard:
.pc=* "keyboard handler"
.import source "keyboard.asm"

/*
	x: source data lo-byte
	y: source data hi-byte
	a: destination page (hi-byte)
*/
.pc=* "ui unpacker"
depack:
    unpacker()

/*
Data
*/
.align $100
.pc=* "sprites"
sprite_base:
.fill $40*8, $00


/*
Interrupt Handler
*/
.pc=* "irq"
irq:
    lda #$ff 
    sta $d019
    jmp $ea31  

/*
Event Handlers
*/

.pc=* "event handlers"
press_space:
    jsr keyboard
    bcs press_space
    cmp #$20
    beq !finish+
    jmp press_space
!finish:
    rts

press_return:
    jsr keyboard
    bcs press_return
    txa
    and #$02 // return is bit 2 on x
    cmp #$02
    beq !finish+
    jmp press_return
!finish:
    rts

press_menu:
    jsr keyboard
    bcs press_menu
    cmp #$01
    beq !a+
    cmp #$02
    beq !b+
    cmp #$03
    beq !c+
    cmp #$07
    beq !g+
    cmp #$0e
    beq !n+
    cmp #$2f
    bne press_menu
    tya
    and #%01010000
    bne !help+
    jmp press_menu
!a:
    jsr menu_numbers
    rts
!b:
    jsr menu_toilets
    rts
!c:
    jsr menu_faces
    rts
!g:
    jsr menu_greets
    rts
!n:
    jsr menu_noter
    rts
!help:
    jsr menu_instructions
    rts

/*
Menu handler functions
*/

menu_numbers:
    jsr ui_loading
    load($30,$33,$2000)
    jsr ui_base
    jsr ui_menu
    jsr ui_draw
    // jsr press_space
    // jsr ui_output
    jsr draw_init
    jsr press_return
    rts

menu_toilets:
    jsr ui_draw
    jsr press_space
    jsr ui_output
    jsr press_return
    rts

menu_faces:
    jsr ui_draw
    jsr press_space
    jsr ui_output
    jsr press_return
    rts

menu_greets:
    jsr ui_loading
    load($30,$31,$2000)
    jsr ui_greets
    jsr greets_init
    jsr press_return
    jsr greets_cleanup
    rts

menu_noter:
    jsr ui_loading
    load($30,$32,$2000)
    jsr noter_init
    jsr press_return
    jsr noter_cleanup
    rts

menu_instructions:
    jsr ui_help
    jsr press_return
    rts

/*
UI drawing functions
*/
.pc=* "ui rendering"
ui_base:
    jsr disable_trans
    ldx #<scr_01
    ldy #>scr_01
    lda #$04
    jsr depack
    ldx #<col_01
    ldy #>col_01
    lda #$d8
    jsr depack
    rts

ui_menu:
    lda #$66
    jsr enable_trans
    ldx #<scr_02
    ldy #>scr_02
    lda #$04
    jsr depack
    lda #$0f
    jsr enable_trans
    ldx #<col_02
    ldy #>col_02
    lda #$d8
    jsr depack
    rts

ui_help:
    jsr disable_trans
    ldx #<scr_04
    ldy #>scr_04
    lda #$04
    jsr depack
    ldx #<col_04
    ldy #>col_04
    lda #$d8
    jsr depack
    rts

ui_draw:
    lda #$66
    jsr enable_trans
    ldx #<scr_03
    ldy #>scr_03
    lda #$04
    jsr depack
    lda #$0f
    jsr enable_trans
    ldx #<col_03
    ldy #>col_03
    lda #$d8
    jsr depack
    rts

ui_loading:
    lda #$66
    jsr enable_trans
    ldx #<scr_08
    ldy #>scr_08
    lda #$04
    jsr depack
    lda #$0f
    jsr enable_trans
    ldx #<col_08
    ldy #>col_08
    lda #$d8
    jsr depack
    rts

ui_calculating:
    jsr disable_trans
    ldx #<scr_09
    ldy #>scr_09
    lda #$04
    jsr depack
    lda #$0f
    jsr enable_trans
    ldx #<col_09
    ldy #>col_09
    lda #$d8
    jsr depack
    rts

ui_welcome:
    lda #$66
    jsr enable_trans
    ldx #<scr_10
    ldy #>scr_10
    lda #$04
    jsr depack
    lda #$0f
    jsr enable_trans
    ldx #<col_10
    ldy #>col_10
    lda #$d8
    jsr depack
    rts

ui_output:
    jsr disable_trans
    ldx #<scr_05
    ldy #>scr_05
    lda #$04
    jsr depack
    ldx #<col_05
    ldy #>col_05
    lda #$d8
    jsr depack
    rts

.const zp_sp_init_l=$92
.const zp_sp_init_h=$93
reset_sprites:
    .var sp_max = sprite_base + ($40 * 8) - 1
    lda #$00
    lda #>sprite_base
    sta zp_sp_init_h
    lda #<sprite_base
    sta zp_sp_init_l
    ldy #$00
    lda #$00
!loop:
    sta (zp_sp_init_l),y
    ldx zp_sp_init_l
    cpx #<sp_max
    bne !skip+
    ldx zp_sp_init_h
    cpx #>sp_max
    bne !skip+
    jmp !done+
!skip:
    inc zp_sp_init_l
    bne !loop-
    inc zp_sp_init_h
    bne !loop-
!done:
    .for(var i=0;i<8;i++){
        lda # ((sprite_base / $40) + i)
        sta $07f8 + i
    }
    rts

/*
Packed Screens
transparent text byte: $66
transparent color byte: $0e 
*/
.pc=* "screen 01"
scr_01:
.import c64 "tinn-fe/rsrc/scr01_packed.prg"
.pc=* "colormap 01"
col_01: 
.import c64 "tinn-fe/rsrc/col01_packed.prg"
.pc=* "screen 02"
scr_02:
.import c64 "tinn-fe/rsrc/scr02_packed.prg"
.pc=* "colormap 02"
col_02: 
.import c64 "tinn-fe/rsrc/col02_packed.prg"

.pc=* "screen 04"
scr_04:
.import c64 "tinn-fe/rsrc/scr04_packed.prg"
.pc=* "colormap 04"
col_04: 
.import c64 "tinn-fe/rsrc/col04_packed.prg"

.pc=* "screen 08"
scr_08:
.import c64 "tinn-fe/rsrc/scr08_packed.prg"
.pc=* "colormap 08"
col_08: 
.import c64 "tinn-fe/rsrc/col08_packed.prg"

.pc=* "screen 09"
scr_09:
.import c64 "tinn-fe/rsrc/scr09_packed.prg"
.pc=* "colormap 09"
col_09: 
.import c64 "tinn-fe/rsrc/col09_packed.prg"

.pc=* "screen 10"
scr_10:
.import c64 "tinn-fe/rsrc/scr10_packed.prg"
.pc=* "colormap 10"
col_10: 
.import c64 "tinn-fe/rsrc/col10_packed.prg"

loader_load:
.import source "loader_load.asm"

.pc=$2000 "Loader init and drivecode"
loader_init:
.import source "loader_init.asm"



/*
-------------------------------------------------------------------------------------
Noter (readme)
-------------------------------------------------------------------------------------
*/
.segment Noter [outPrg="noter.prg"]
.const n_start_zp_l = $97
.const n_start_zp_h = $98
.const n_end_zp_l = $95
.const n_end_zp_h = $96
.const nstep = $94
.const n_scr_zp_h = $93
.const n_scr_zp_l = $92
.const n_top = 04
.const n_bot = 18
.const n_dif = n_bot - n_top
.const n_width = 35
.pc=$2000 "Noter"
noter_init:
    jsr ui_noter
    lda #>noter_text - (1 * n_width)
    sta n_start_zp_h
    lda #<noter_text - (1 * n_width)
    sta n_start_zp_l
    lda #>(noter_text + ((n_dif+1) * n_width))
    sta n_end_zp_h
    lda #<(noter_text + ((n_dif+1) * n_width))
    sta n_end_zp_l
    lda #$00
    sta nstep
    jsr noter_blit_init
    jsr noter_scroll_draw
    jsr noter_loop
    jsr noter_cleanup
    rts   

.pc=* "noter keyboard handler loop"
noter_loop:
    jsr keyboard
    bcs noter_loop
    txa
    and #%00000010
    bne !return+
    tya
    and #%01010000
    bne !shift+
    txa
    and #%10000100
    beq noter_loop
    jsr noter_blit_up
    jsr noter_scroll_draw
    jmp !delay+
!shift:
    txa
    and #%10000100
    beq noter_loop
    jsr noter_blit_down
    jsr noter_scroll_draw
    // jmp !delay+
!delay:
    ldx #$00
    ldy #$80
!loop:
    inx
    bne !loop-
    iny
    bne !loop-
    jmp noter_loop
!return:
    rts


.pc=* "noter ui"
ui_noter:
    jsr disable_trans
    ldx #<scr_07
    ldy #>scr_07
    lda #$04
    jsr depack
    ldx #<col_07
    ldy #>col_07
    lda #$d8
    jsr depack
    rts

.pc=* "noter cleanup"
noter_cleanup:
    lda #$00
    sta $d015
    sei
    lda #<irq    
    sta $0314    
    lda #>irq
    sta $0315
    cli 
    rts

.pc=* "noter irq"
noter_irq:

.pc=* "noter functions"
/*
========================
*/
noter_scroll_draw:
    lda #$0b
    .for(var i=0;i<=n_dif;i++){
        sta $d800 + ((i + n_top) * $28) + n_width + 2
    }
    .var scr_addr = $d800 + (n_top * $28) + n_width + 2
    lda #>scr_addr
    sta n_scr_zp_h
    lda #<scr_addr
    sta n_scr_zp_l
    lda nstep
    // tweak these based on the size of the text to get the scroll ratio correct
    lsr
    lsr
    // lsr
    // lsr
    ldy #$00
    tax
!loop:
    cpx #$00
    beq !draw+
    dex
    clc
    lda n_scr_zp_l
    adc #$28
    sta n_scr_zp_l
    lda n_scr_zp_h
    adc #$00
    sta n_scr_zp_h
    jmp !loop-
!draw:
    lda #$0c
    sta (n_scr_zp_l),y
    rts

noter_blit_init:
    ldx #$00
    ldy #$02
    !loop:
    .for(var i=n_top;i<=n_bot;i++){
        lda noter_text + (n_width * (i - n_top)),x
        sta $0400 + ($28 * i),y
    }
    inx
    iny
    cpx #n_width
    bne !loop-
    rts

/*
========================
*/
noter_blit_up:
    lda nstep
    cmp # ((noter_text_end - noter_text)/n_width) - (n_dif + 1)
    bne !skip+
    rts
!skip:
    inc nstep
    ldx #$02
    ldy #$00
    !loop:
    .for(var i=n_top;i<n_bot;i++){
        lda $0400 + ($28 * (i+1)),x
        sta $0400 + ($28 * i),x
    }
    lda (n_end_zp_l),y
    sta $0400 + ($28 * (n_bot)),x
    iny
    inx
    cpy #n_width
    bne !loop-
    clc
    lda n_end_zp_l
    adc #n_width
    sta n_end_zp_l
    lda n_end_zp_h
    adc #$00
    sta n_end_zp_h
    clc
    lda n_start_zp_l
    adc #n_width
    sta n_start_zp_l
    lda n_start_zp_h
    adc #$00
    sta n_start_zp_h
    rts

/*
========================
*/
noter_blit_down:
    lda nstep
    cmp #$00
    bne !skip+
    rts
!skip:
    dec nstep
    ldx #$02
    ldy #$00
    !loop:
    .for(var i=n_bot;i>n_top;i--){
        lda $0400 + ($28 * (i - 1)),x
        sta $0400 + ($28 * (i)),x
    }
    lda (n_start_zp_l),y
    sta $0400 + ($28 * n_top),x
    iny
    inx
    cpy #n_width
    bne !loop-
    sec
    lda n_end_zp_l
    sbc #n_width
    sta n_end_zp_l
    lda n_end_zp_h
    sbc #$00
    sta n_end_zp_h
    sec
    lda n_start_zp_l
    sbc #n_width
    sta n_start_zp_l
    lda n_start_zp_h
    sbc #$00
    sta n_start_zp_h
    rts

.pc=* "Noter Packed Charmap and Colormap"
.pc=* "screen 07"
scr_07:
.import c64 "tinn-fe/rsrc/scr07_packed.prg"
.pc=* "colormap 07"
col_07: 
.import c64 "tinn-fe/rsrc/col07_packed.prg"

.pc=* "noter text"
noter_text:
.text "This is a noter test showing you   "
.text "Second line ot the                 "
.text "  c                                "
.text "   d                               "
.text "    e                              "
.text "     f                             "
.text "      g                            "
.text "       h                           "
.text "  c                                "
.text "   d                               "
.text "    e                              "
.text "     f                             "
.text "      g                            "
.text "       h                           "
.text "  c                                "
.text "   d                               "
.text "    e                              "
.text "     f                             "
.text "      g                            "
.text "       h                           "
.text "  c                                "
.text "   d                               "
.text "    e                              "
.text "     f                             "
.text "      g                            "
.text "       h                           "
.text "  c                                "
.text "   d                               "
.text "    e                              "
.text "     f                             "
.text "      g                            "
.text "       h                           "
.text "  c                                "
.text "   d                               "
.text "    e                              "
.text "     f                             "
.text "      g                            "
.text "       h                           "
.text "  c                                "
.text "   d                               "
.text "    e                              "
.text "     f                             "
.text "      g                            "
.text "       h                           "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
.text "                                   "
noter_text_end:
.byte $00



/*
-------------------------------------------------------------------------------------
Greets mini intro
-------------------------------------------------------------------------------------
*/
.segment Greets [outPrg="greets.prg"]
.pc=$2000 "Greets"
.pc=* "greets init"
greets_init:
    jsr ui_greets
    jsr reset_sprites
    lda #%11111111
    sta $d015
    lda #$00
    sta $d017
    sta $d01c
    sta $d01d
    lda #$ff
    sta $d01b
    lda #%10000000
    sta $d010
    lda #$01
    .for(var i=0;i<8;i++){
        sta $d027 + i
    }
    lda #$b8
    .for(var i=0;i<8;i++){
        sta $d001 + (i * 2)
    }
    .for(var i=0;i<8;i++){
        .var x=$58 + (i * 8 * 3)
        lda #< x
        sta $d000 + (i * 2)
    }
    .for(var i=0;i<8;i++){
        lda # ((sprite_base / $40) + i)
        sta $07f8 + i
    }
    lda #> scroll_text
    sta scroller_ptr_hi
    lda #< scroll_text
    sta scroller_ptr_lo
    sei
    lda #<greets_irq    
    sta $0314    
    lda #>greets_irq
    sta $0315
    cli
    rts

.pc=* "greets ui"
ui_greets:
    jsr disable_trans
    ldx #<scr_06
    ldy #>scr_06
    lda #$04
    jsr depack
    ldx #<col_06
    ldy #>col_06
    lda #$d8
    jsr depack
    rts

.pc=* "greets cleanup"
greets_cleanup:
    lda #$00
    sta $d015
    sei
    lda #<irq    
    sta $0314    
    lda #>irq
    sta $0315
    cli 
    rts

.pc=* "greets irq"
greets_irq:
    lda #$ff 
    sta $d019
    inc $d020
    .for(var j=0;j<21;j++){
        asl char_column + j
        .for(var i=7;i>=0;i--){
            rol sprite_base + ($40 * i) + 2 + (j * 3)
            rol sprite_base + ($40 * i) + 1 + (j * 3)
            rol sprite_base + ($40 * i) + 0 + (j * 3)
        }
    }
    .for(var i=0;i<8;i++){
        asl char_buffer + i
    }
    inc char_scroll_idx
    lda char_scroll_idx
    cmp #$08
    bne !skip+
    lda #$00
    sta char_scroll_idx
    jsr greets_char
!skip:
    lda effect_select
    cmp #$ff
    beq effect_0j
    cmp #$fe
    beq effect_1j
    cmp #$fd
    beq effect_2j
    cmp #$fc
    beq effect_3j
effect_return:
    jsr greets_colors
    dec $d020
    jmp $ea31  

effect_0j:
    jmp effect_0
effect_1j:
    jmp effect_1
effect_2j:
    jmp effect_2
effect_3j:
    jmp effect_3

effect_0:
    lda #$00
    .for(var i=0;i<8;i++){
        sta char_column+(i*2) 
    }
    .for(var i=0;i<5;i++){
        sta char_column + i + 16
    }
    .for(var i=0;i<8;i++){
        lda char_buffer+i
        sta char_column + i + 8
    }
    jmp effect_return

effect_1:
    lda #$00
    sta char_column
    sta char_column + 1
    sta char_column + 18
    sta char_column + 19
    sta char_column + 20
    .for(var i=0;i<8;i++){
        lda char_buffer+i
        sta char_column+(i*2) + 2
        sta char_column+(i*2) + 1 + 2
    }
    jmp effect_return

effect_2:
    lda #$00
    sta char_column
    sta char_column + 1
    sta char_column + 18
    sta char_column + 19
    sta char_column + 20
    .for(var i=0;i<8;i++){
        sta char_column+(i*2) + 1 + 2
    }
    .for(var i=0;i<8;i++){
        lda char_buffer+i
        sta char_column+(i*2) + 2
    }
    jmp effect_return

effect_3:
    lda #$00
    .for(var i=0;i<21;i++){
        sta char_column + i
    }
    inc effect_counter
    ldx effect_counter
    lda effect_curve,x
    tax
    .for(var i=0;i<8;i++){
        lda char_buffer + i
        sta char_column,x
        inx
    }
    jmp effect_return

greets_char:
    ldy #$00
    sty charset_ptr_hi
    lda (scroller_ptr_lo),y
    cmp #$00
    bne !skip+
    lda #> scroll_text
    sta scroller_ptr_hi
    lda #< scroll_text
    sta scroller_ptr_lo
    lda #$20 //space
    jmp !scroll+
!skip:
    cmp #$ff
    bne !skip+
    sta effect_select
    lda #$20
    jmp !scroll+
!skip:
    cmp #$fe
    bne !skip+
    sta effect_select
    lda #$20
    jmp !scroll+
!skip:
    cmp #$fd
    bne !skip+
    sta effect_select
    lda #$20
    jmp !scroll+
!skip:
    cmp #$fc
    bne !skip+
    sta effect_select
    lda #$20
    jmp !scroll+
!skip:
!scroll:
    inc scroller_ptr_lo
    bne !skip+
    inc scroller_ptr_hi
!skip:
    sta charset_ptr_lo
    clc
    rol charset_ptr_lo
    rol charset_ptr_hi
    clc
    rol charset_ptr_lo
    rol charset_ptr_hi
    clc
    rol charset_ptr_lo
    rol charset_ptr_hi
    clc
    lda charset_ptr_hi
    adc #$d8
    sta charset_ptr_hi
    lda #$33
    sta $01
    lda (charset_ptr_lo),y
    sta char_buffer + 0
    iny
    lda (charset_ptr_lo),y
    sta char_buffer + 1
    iny
    lda (charset_ptr_lo),y
    sta char_buffer + 2
    iny
    lda (charset_ptr_lo),y
    sta char_buffer + 3
    iny
    lda (charset_ptr_lo),y
    sta char_buffer + 4
    iny
    lda (charset_ptr_lo),y
    sta char_buffer + 5
    iny
    lda (charset_ptr_lo),y
    sta char_buffer + 6
    iny
    lda (charset_ptr_lo),y
    sta char_buffer + 7
    lda #$37
    sta $01
    rts

greets_colors:
    inc scroll_colors_delay
    lda scroll_colors_delay
    cmp #$05
    beq !skip+
    rts
!skip:
    lda #$00
    sta scroll_colors_delay
    .for(var i=0;i<8;i++){
        ldx scroll_colors_index + i
        lda scroll_colors,x
        sta $d027 + i
        inc scroll_colors_index + i
        lda scroll_colors_index + i
        cmp #$05
        bne !skip+
        lda #$00
        sta scroll_colors_index + i
!skip:
    }
    rts

char_column:
.fill 21, $00
char_buffer:
.fill 8, $00
char_scroll_idx:
.byte $00
effect_select:
.byte $ff
effect_counter:
.byte $00
scroll_text:
.text "  "
.byte $ff
.text " Hello, this is a special little greets scroller for a special little demo! "
.byte $fc
.text " I have spent a long time working on this idea of machine learning on my favorite computer. "
.byte $fd
.text " Artificial intelligence? Yes! "
.byte $fe
.text " Shoutouts to Defame "
.byte $00
.align $100
effect_curve:
.fill 256, round(((21-8)/2) + (((21-8)/2) * cos(toRadians(i*360/256))))
scroll_colors:
.byte $06, $0e, $03, $01, $03, $0e
scroll_colors_index:
.byte $04, $03, $02, $01, $00, $04, $03, $02
scroll_colors_delay:
.byte $00

.pc=* "Greets Packed Charmap and Colormap"
.pc=* "screen 06"
scr_06:
.import c64 "tinn-fe/rsrc/scr06_packed.prg"
.pc=* "colormap 06"
col_06: 
.import c64 "tinn-fe/rsrc/col06_packed.prg"


/*
-------------------------------------------------------------------------------------
Draw Your Things
-------------------------------------------------------------------------------------
*/
.segment Draw [outPrg="draw.prg"]
.pc=$2000 "Draw"

.label PLOT_WIDTH = $10
.label PLOT_HEIGHT = $10
.label REAL_WIDTH = $08 //plot width / 2
.label REAL_HEIGHT = $08 //plot height / 2
.label PLOTTER_X_OFFSET = ((40-16)/2)-3 //offset of screen from left hand side
.label PLOTTER_Y_OFFSET = 12


.pc=* "draw init"
draw_init:
    sei
    lda #<draw_irq    
    sta $0314    
    lda #>draw_irq
    sta $0315
    cli
    jsr draw_init_cursor
    lda #$00
    sta quit_flag + 1
    ldx #$00
!loop:
    sta SCREEN_BUFFER,x
    inx
    bne !loop-
    jsr draw_buffer_to_screen
!loop:
    jsr draw_input_handler
quit_flag: lda #$00
    cmp #$00
    beq !loop-
    rts


.pc=* "draw cleanup"
draw_cleanup:
    lda #$00
    sta $d015
    sei
    lda #<irq    
    sta $0314    
    lda #>irq
    sta $0315
    cli 
    rts


.pc=* "draw irq"
draw_irq:
    lda #$ff 
    sta $d019
    jsr draw_color_cursor
    ldx CURSOR_X
    ldy CURSOR_Y
    jsr draw_position_cursor
    jmp $ea31  



draw_init_cursor:
    lda #%00000001
    sta $d015
    lda #$00
    sta $d017
    sta $d01c
    sta $d01d
    sta $d01b
    sta $d010
    lda #$01
    .for(var i=0;i<8;i++){
        sta $d027 + i
    }
    jsr reset_sprites
    ldx #$00
!loop:
    lda SPRITE_CURSOR,X
    sta sprite_base,x
    inx
    cpx #10
    bne !loop-
    ldx #$00
    ldy #$00
    jsr draw_position_cursor
    rts

/*
x = x position
y = y position
a = destroyed
*/
draw_position_cursor:
    lda CURSOR_X_LUT,x
    sta $d000
    lda CURSOR_Y_LUT,y
    sta $d001
    rts

draw_color_cursor:
    ldx color_offset: #$00
    lda CURSOR_COLOR_LUT,x
    cmp #$ff
    bne !skip+
    lda #$01
    sta color_offset
    lda CURSOR_COLOR_LUT
!skip:
    sta $d027
    inc color_offset
    rts

/*
x = x position
y = y position
a = destroyed
*/
draw_pixel_buffer:
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
x,y,a = destroyed
*/
draw_buffer_to_screen:
    //top and bottom border
    ldx #$00
    .for(var i=0;i<REAL_HEIGHT;i++){
        //side border
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

draw_input_handler:
    jsr keyboard
    bcs !skip+
	cpx #%10000000
	beq !updown+
	cpx #%00000100
	beq !rightleft+
	cpx #%00000010
	beq !return+
    cmp #$20
    beq !space+
!skip:
    clc
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
	jmp !delay+

!up:
    //go up
    lda CURSOR_Y
    cmp #$00
    beq !skip+
    dec CURSOR_Y
!skip:
	jmp !delay+

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
    jmp !delay+

!left:
    //go left
    lda CURSOR_X
    cmp #$00
    beq !skip+
    dec CURSOR_X
!skip:
	jmp !delay+

!return:
    //send to AI
    jmp nnFProp

!space:
    ldx CURSOR_X
    ldy CURSOR_Y
    jsr draw_pixel_buffer
    jsr draw_buffer_to_screen
!skip:
!delay:
    ldx #$00
    ldy #$80
!delay:
    dex
    bne !delay-
    dey
    bne !delay-
    rts

nnFProp:
    jsr ui_calculating
    ldx #$00
    ldy #$00
!loop:
    inc $d020
    bne !loop-
    inx
    cpx #$00
    bne !loop-
    iny 
    cpy #$00
    bne !loop-
    jsr draw_cleanup
    jsr ui_output
    jsr press_return
    lda #$01
    sta quit_flag + 1
    rts

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

//SPRITE CURSOR
.pc=* "Sprite Cursor"
SPRITE_CURSOR:
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

SCREEN_BUFFER:
.fill $100, $00

.pc=* "screen 03"
scr_03:
.import c64 "tinn-fe/rsrc/scr03_packed.prg"
.pc=* "colormap 03"
col_03: 
.import c64 "tinn-fe/rsrc/col03_packed.prg"

.pc=* "screen 05"
scr_05:
.import c64 "tinn-fe/rsrc/scr05_packed.prg"
.pc=* "colormap 05"
col_05: 
.import c64 "tinn-fe/rsrc/col05_packed.prg"
