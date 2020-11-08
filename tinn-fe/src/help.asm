.importonce 
.import source "windows.asm"
/*
--------------------------------------------------------------------------------------------
Draw Help Window
--------------------------------------------------------------------------------------------
*/

/*
Entry point of the Help Dialog
*/
funcHelp:
    jsr funcHelpHookKeyboard //patch keyboard handler for this dialog
    jsr funcHelpDrawPage1
    jsr funcHelpWaitNext
    jsr funcHelpDrawPage2
    jsr funcHelpWaitNext
    jsr funcHelpDrawPage3
    jsr funcHelpWaitNext
    jsr funcHelpDrawPage4
    jsr funcHelpWaitClose
    rts

funcButtonWait:
    lda #$0d
    sta win_color
    jsr funcDrawButton
!:
    jsr KeyboardScanner
    lda help_progress
    beq !-
    //reset the button wait flag
    lda #$00
    sta help_progress
    rts

funcHelpWaitNext:
    lda #<txt_helpNextButton
    sta win_text
    lda #>txt_helpNextButton
    sta win_text + 1
    lda #9
    sta win_x
    lda #17
    sta win_y
    jsr funcButtonWait
    rts

funcHelpWaitClose:
    lda #<txt_helpCloseButton
    sta win_text
    lda #>txt_helpCloseButton
    sta win_text + 1
    lda #10
    sta win_x
    lda #17
    sta win_y
    jsr funcButtonWait
    rts

help_progress:
    .byte $00

funcHelpHookKeyboard:
    lda #>funcHelpKeyboardHandler
    sta KEYBOARD_HANDLER_HOOK + 1
    lda #<funcHelpKeyboardHandler
    sta KEYBOARD_HANDLER_HOOK 
    rts

funcHelpKeyboardHandler:
    cmp #$20
    bne !+
    inc help_progress
!:    
    rts

funcHelpDrawPage1:
    lda #<txt_helpDialog_1
    sta win_text
    lda #>txt_helpDialog_1
    sta win_text + 1
    jsr funcHelpRenderDialog
    rts

funcHelpDrawPage2:
    lda #<txt_helpDialog_2
    sta win_text
    lda #>txt_helpDialog_2
    sta win_text + 1
    jsr funcHelpRenderDialog
    rts

funcHelpDrawPage3:
    lda #<txt_helpDialog_3
    sta win_text
    lda #>txt_helpDialog_3
    sta win_text + 1
    jsr funcHelpRenderDialog
    rts

funcHelpDrawPage4:
    lda #<txt_helpDialog_4
    sta win_text
    lda #>txt_helpDialog_4
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

txt_helpDialog_1:
//     -----------------------------
.text "Welcome to Quick! Draw! 64!"
.byte $00
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63,$63,$63,$63,$63
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
.text "More on the next page..."
.byte $00, $00, $00, $00, $00, $00, $00, $00

txt_helpDialog_2:
//     -----------------------------
.text "How Does This Demo Work?"
.byte $00
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63,$63,$63
.byte $00
.text "You can draw a little sketch"
.byte $00
.text "and this neural network can "
.byte $00
.text "classify it!"
.byte $00
.byte $00
.byte $00
.text "More on the next page..."
.byte $00, $00, $00, $00, $00, $00, $00, $00

txt_helpDialog_3:
//     -----------------------------
.text "How Does This Demo Work?"
.byte $00
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63,$63,$63
.byte $00
.text "Select the kernel you want to"
.byte $00
.text "use and draw a little picture."
.byte $00
.byte $00
.byte $00
.byte $00
.text "More on the next page..."
.byte $00, $00, $00, $00, $00, $00, $00, $00

txt_helpDialog_4:
//     -----------------------------
.text "Then What Happens Next?"
.byte $00
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
.byte $63,$63,$63
.byte $00
.text "This miracle of modern 8-bit"
.byte $00
.text "technology will tell you what"
.byte $00
.text "you have drawn with a spot of"
.byte $00
.text "humor..."
.byte $00
.byte $00
.byte $00
.text "Have fun!"
.byte $00
.text "Zig/DEFAME"
.byte $00, $00, $00, $00, $00, $00, $00, $00


txt_helpNextButton:
.text "Hit Space for Next >"
.byte $00
txt_helpCloseButton:
.text "Hit Space to Close"
.byte $00


