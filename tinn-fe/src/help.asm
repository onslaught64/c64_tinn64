.importonce 
.import source "windows.asm"
/*
--------------------------------------------------------------------------------------------
Draw Help Window
--------------------------------------------------------------------------------------------
*/
.label help_keyboardHandler = $1a00
.label help_keyboardHook = $1a80

/*
Entry point of the Help Dialog
*/
funcHelp:
    jsr funcHelpHookKeyboard //patch keyboard handler for this dialog
    jsr funcHelpDrawPage1
    lda #<txt_helpNextButton
    sta win_text
    lda #>txt_helpNextButton
    sta win_text + 1
    jsr funcHelpWaitNext
    rts

funcHelpWaitNext:
!:
    jsr funcHelpButton
    jsr help_keyboardHandler
    lda help_progress
    beq !-
    lda #$00
    sta help_progress
    rts

help_progress:
    .byte $00

funcHelpHookKeyboard:
    lda #>funcHelpKeyboardHandler
    sta help_keyboardHook + 2
    lda #<funcHelpKeyboardHandler
    sta help_keyboardHook + 1
    rts

funcHelpKeyboardHandler:
    cmp #$20
    bne !+
    inc help_progress
!:    
    rts

funcHelpDrawPage1:
    lda #<txt_helpDialog
    sta win_text
    lda #>txt_helpDialog
    sta win_text + 1
    jsr funcHelpRenderDialog
    rts

funcHelpRenderDialog:
    lda #31
    sta win_width
    lda #15
    sta win_height
    lda #4
    sta win_x
    lda #4
    sta win_y
    lda #5
    sta win_color
    jsr funcDrawWindow
    rts 

funcHelpButton:
    lda #18
    sta win_x
    lda #17
    sta win_y
    ldy helpCounter
    lda helpButtonColors,y
    sta win_color
    iny
    cpy #$08
    bne !+
    ldy #$00
!:
    sty helpCounter
    jsr funcDrawButton
    rts
helpCounter:
    .byte $00

helpButtonColors:
    .byte $0b, $0c, $0f, $01, $0f, $0c, $0b, $00

txt_helpDialog:
//     -----------------------------
.text "Welcome to Quick! Draw! 64!"
.byte $00
.byte $00
.text "This is the world's first"
.byte $00
.text "implementation of a real"
.byte $00
.text "neural network for the"
.byte $00
.text "Commodore 64."
.byte $00
.byte $00
.text "Brought to you by the"
.byte $00
.text "Zig/DEFAME."
.byte $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

txt_helpNextButton:
.text "Hit Space"
.byte $00
txt_helpCloseButton:
.text "Done"
.byte $00


