.include "atari2600.inc"

; RAM Variables
FRAME_COUNT = $80
LINE_NUM   = $81
FILL_COLOR = $82

; Constants

.org $1000
.segment "STARTUP"

Reset:
   ldx #0
   lda #0
Clear:
   sta 0,x
   inx
   bne Clear

   ; Initialize
   stx FRAME_COUNT

   ; Initialize graphics
   lda #0
   sta COLUBK

   lda #60
   sta LINE_NUM

; Intro Screen
Intro:
; Start of vertical blank processing
   lda #0
   sta VBLANK

   lda #2
   sta VSYNC

; 3 scanlines of VSYNCH signal...
   sta WSYNC

   ldx #$0E
   stx COLUBK  ; background = white
   lda #0
   sta CTRLPF  ; repeat playfield

   ldx #5      ; players = double size
   stx NUSIZ0
   stx NUSIZ1

   sta WSYNC
   sta WSYNC

   sta VSYNC

; 37 scanlines of vertical blank...

   ldx #36
@vblank_loop:
   sta WSYNC
   dex
   bne @vblank_loop

   sta WSYNC
   ldx #2
@p0_hpos_loop:
   nop
   dex
   bne @p0_hpos_loop
   sta RESP0 ; set player 0 horizontal position (left side of slithy tove)
   nop
   nop
   nop
   sta RESP1 ; set player 1 horizontal position (right side of slithy tove)


; 192 scanlines of picture...
   ldx #51
@top_margin:
   sta WSYNC
   dex
   bne @top_margin

@print_intro:
   ldx #0
   ldy #0
@intro_loop:
   sta WSYNC
   sty PF0
   lda intro_pf_color,x
   sta COLUPF
   lda intro_pf1_left,x
   sta PF1
   lda intro_pf2_left,x
   sta PF2
   lda p0_tove_color,x
   sta COLUP0
   lda p1_tove_color,x
   sta COLUP1
   lda intro_pf0_right,x
   sta PF0
   lda intro_pf1_right,x
   sta PF1
   lda intro_pf2_right,x
   sta PF2
   sta WSYNC
   sty PF0
   lda intro_pf_color,x
   sta COLUPF
   lda intro_pf1_left,x
   sta PF1
   lda intro_pf2_left,x
   sta PF2
   lda p0_tove,x
   sta GRP0
   lda p1_tove,x
   sta GRP1
   lda intro_pf0_right,x
   sta PF0
   lda intro_pf1_right,x
   sta PF1
   lda intro_pf2_right,x
   sta PF2
   inx
   cpx #47
   beq @end_pf
   jmp @intro_loop
@end_pf:
   sty PF0
   sty PF1
   sty PF2
   sty GRP0
   sty GRP1

   ldx #51
@bottom_margin:
   sta WSYNC
   dex
   bne @bottom_margin

   lda #%01000010
   sta VBLANK                     ; end of screen - enter blanking


   ; 30 scanlines of overscan...
Intro_Overscan:

   sta WSYNC
   inc FRAME_COUNT
   ldx #29
@oscan_loop:
   sta WSYNC
   dex
   bne @oscan_loop
   lda FRAME_COUNT
   cmp #0
   beq Title
   jmp Intro

Title:

; Start of vertical blank processing
   lda #0
   sta VBLANK

   lda #2
   sta VSYNC

; 3 scanlines of VSYNCH signal...
   sta WSYNC

   ldx #$F0
   stx PF2     ; playfield2 = center foreground

   ldx #0
   stx COLUBK  ; background = black
   stx COLUPF  ; playfield = black

   inx
   stx CTRLPF  ; mirror playfield
   sta WSYNC

   lda #$9E    ; players = light blue
   sta COLUP0
   sta COLUP1

   lda #7   ; players = quad size
   sta NUSIZ0
   sta NUSIZ1

   sta WSYNC


   lda #0
   sta VSYNC

; 37 scanlines of vertical blank...

   ldx #36
@vblank_loop:
   sta WSYNC
   dex
   bne @vblank_loop

   sta WSYNC
   ldx #4
@p0_hpos_loop:
   nop
   dex
   bne @p0_hpos_loop
   nop
   nop
   sta RESP0 ; set player 0 horizontal position (left side of mug)
   nop
   nop
   sta RESP1 ; set player 1 horizontal position (right side of mug)


; 192 scanlines of picture...
Title_Picture:
   ldx #25
@top_margin:
   sta WSYNC
   dex
   bne @top_margin

@fill_loop:
   sta WSYNC
   lda p0_mug_shape,x
   sta GRP0
   lda p1_mug_shape,x
   sta GRP1
   txa
   cmp LINE_NUM
   bmi @next_fill
   cmp #60
   bpl @black_fill
   lsr
   lsr
   tay
   lda fill_colors,y
   sta COLUPF
   jmp @next_fill
@black_fill:
   lda #0
   sta COLUPF
@next_fill:
   inx
   cpx #64
   bne @fill_loop

   ldx #0
   sta WSYNC
   stx GRP0    ; player 0 sprite = clear
   stx GRP1    ; player 1 sprite = clear
   stx CTRLPF  ; normal playfield
   stx PF2     ; Playfield2 = clear

   sta WSYNC
   lda #$1E
   sta COLUPF  ; Playfield = yellow
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta WSYNC

   inx
   cpx LINE_NUM
   beq @print_title
   ldx #97
   jmp @bottom_margin

@print_title:
   ldx #0
   ldy #0
@title_loop:
.repeat 2
   sta WSYNC
   sty PF0
   lda title_pf1_left,x
   sta PF1
   lda title_pf2,x
   sta PF2
   lda title_pf0,x
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   sta PF0
   lda title_pf1_right,x
   nop
   sta PF1
   nop
   sty PF2
.endrepeat
   inx
   cpx #34
   bne @title_loop
   sty PF0
   sty PF1

   sta WSYNC
   sta WSYNC
   sta WSYNC

   ; print 2600 in rainbow
   ldx #0
@number_loop:
.repeat 2
   sta WSYNC
   sty PF0
   sty PF1
   lda num_pf2,x
   sta PF2
   lda fill_colors,x
   sta COLUPF
   lda num_pf0,x
   nop
   nop
   nop
   nop
   nop
   sta PF0
   lda num_pf1,x
   nop
   sta PF1
   nop
   sty PF2
.endrepeat
   inx
   cpx #12
   bne @number_loop
   sty PF0
   sty PF1


   ldx #2
@bottom_margin:
   sta WSYNC
   dex
   bne @bottom_margin

   lda #%01000010
   sta VBLANK                     ; end of screen - enter blanking


   ; 30 scanlines of overscan...
Title_Overscan:

   sta WSYNC
   inc FRAME_COUNT
   lda FRAME_COUNT
   and #$04
   cmp #$04
   bne @next_frame
   dec LINE_NUM
   bne @next_frame
   inc LINE_NUM



@next_frame:
   ldx #29
@oscan_loop:
   sta WSYNC
   dex
   bne @oscan_loop
   jmp Title

; Pattern Data
fill_colors:
.byte $44,$36,$2E,$FE,$1E,$EE,$DC,$CA,$B8,$A6,$96,$86,$78,$6A,$5C

p0_tove:
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000001
.byte %00000011
.byte %00001111
.byte %00001111
.byte %00001111
.byte %00001111
.byte %00011111
.byte %00111111
.byte %01111111
.byte %11011111
.byte %00011111
.byte %00001111
.byte %00001111
.byte %00000111
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000001
.repeat 22
.byte 0
.endrepeat

p0_tove_color:
.byte $F6,$F6,$F6,$F6,$F6,$F6,$F6,$F6,$F4,$F4,$F0,$F6,$F6
.byte $26,$F0,$F0,$F0,$F6,$F8,$FC,$E4,$F4,$F4,$F4,$F4
.repeat 22
.byte $0E
.endrepeat

p1_tove:
.byte %00000001
.byte %00000011
.byte %00001110
.byte %00001000
.byte %00111000
.byte %01100000
.byte %01100000
.byte %11000000
.byte %10000000
.byte %10000000
.byte %00000000
.byte %00000000
.byte %00000011
.byte %10000010
.byte %10000110
.byte %10001100
.byte %10001000
.byte %10001100
.byte %11000100
.byte %11111100
.byte %11111000
.byte %01110000
.byte %01100000
.byte %01100000
.byte %11000000
.repeat 22
.byte 0
.endrepeat


p1_tove_color:
.byte $0A,$0A,$0A,$F8,$F8,$F8,$F8,$F6,$F6,$F6,$0A,$0A,$0A
.byte $0A,$04,$04,$04,$F0,$F2,$E4,$E4,$F0,$F0,$E4,$E4
.repeat 22
.byte $0E
.endrepeat

intro_pf1_left:
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000001
.byte %00000011
.byte %00000010
.byte %00000010
.byte %00000011
.byte %00000001
.byte %00000000
.byte %00000010
.byte %00000011
.byte %00000001
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00001100
.byte %00011110
.byte %00110010
.byte %00100000
.byte %00100000
.byte %00101110
.byte %00101110
.byte %00100010
.byte %00100010
.byte %00110010
.byte %00011110
.byte %00001100
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %11001100
.byte %10101010
.byte %10101010
.byte %11001100
.byte %10001010
.byte %10001010
.byte %10001010

intro_pf2_left:
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %01000100
.byte %01000110
.byte %01010100
.byte %01010100
.byte %01000100
.byte %11000100
.byte %11010101
.byte %01010101
.byte %01010100
.byte %01010100
.byte %01010101
.byte %01010101
.byte %01010101
.byte %11010101
.byte %10010100
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %01000100
.byte %01001110
.byte %11001110
.byte %11001010
.byte %11011011
.byte %01010001
.byte %01010001
.byte %01011111
.byte %01011111
.byte %01010001
.byte %01010001
.byte %01010001
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00100111
.byte %01010001
.byte %00010001
.byte %00100011
.byte %01000001
.byte %01010001
.byte %00100111

intro_pf0_right:
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %11000000
.byte %11100000
.byte %00100000
.byte %00100000
.byte %00100000
.byte %01100000
.byte %11100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %01000000
.byte %01000000
.byte %01100000
.byte %01100000
.byte %01110000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %01000000
.byte %01000000
.byte %01000000
.byte %01000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %01110000
.byte %00010000
.byte %00010000
.byte %00110000
.byte %00010000
.byte %00010000
.byte %01110000

intro_pf1_right:
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %00110000
.byte %00010000
.byte %00010000
.byte %01110000
.byte %01100000
.byte %00000000
.byte %11110011
.byte %11110111
.byte %10000100
.byte %10000100
.byte %10000100
.byte %11100111
.byte %11100011
.byte %10000000
.byte %10000000
.byte %10000100
.byte %11110111
.byte %11110011
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %10010111
.byte %11010010
.byte %11010010
.byte %10110010
.byte %10110010
.byte %10010010
.byte %10010010

intro_pf2_right:
.repeat 25
.byte %00000000
.endrepeat
.byte %00000001
.byte %00000001
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000100
.byte %00001010
.byte %00000010
.byte %00000100
.byte %00001000
.byte %00001010
.byte %00000100

intro_pf_color:
.repeat 23
.byte $C8
.endrepeat
.repeat 13
.byte $00
.endrepeat
.repeat 11
.byte $42
.endrepeat

p0_mug_shape:
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %10001000
.byte %10011000
.byte %11111000
.byte %11111000
.byte %11111000
.byte %11101000
.byte %11001000
.byte %11001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %10001000
.byte %11001000
.byte %11001000
.byte %11001000
.byte %11101000
.byte %01111000
.byte %01111000
.byte %00111000
.byte %00011000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001000
.byte %00001100
.byte %00001111
.byte %00001111
.byte %00001111
.byte %00000111

p1_mug_shape:
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000011
.byte %11111111
.byte %11111111
.byte %11111111
.byte %11111110

title_pf1_left:
.byte %00000011
.byte %00000011
.byte %00000010
.byte %00000010
.byte %00000011
.byte %00000011
.byte %00000011
.byte %00000010
.byte %00000010
.byte %00000010
.byte %00000000
.byte %00000000
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000001
.byte %00000000
.byte %00000000
.byte %00000101
.byte %00000101
.byte %00000101
.byte %00000101
.byte %00000111
.byte %00000111
.byte %00000101
.byte %00000101
.byte %00000101
.byte %00000101

title_pf2:
.byte %11011100
.byte %11011101
.byte %10000101
.byte %10000101
.byte %10001101
.byte %10001100
.byte %10000101
.byte %10000101
.byte %10011101
.byte %10011101
.byte %00000000
.byte %00000000
.byte %10011001
.byte %10111011
.byte %10101010
.byte %10101011
.byte %10111001
.byte %10011011
.byte %10111010
.byte %10101010
.byte %10101011
.byte %10101001
.byte %00000000
.byte %00000000
.byte %01001100
.byte %01011110
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %11011110
.byte %10001100

title_pf0:
.byte %11010000
.byte %11010000
.byte %01000000
.byte %01000000
.byte %11000000
.byte %11000000
.byte %11000000
.byte %01000000
.byte %01000000
.byte %01000000
.byte %00000000
.byte %00000000
.byte %10110000
.byte %10110000
.byte %10000000
.byte %10000000
.byte %10010000
.byte %10010000
.byte %10000000
.byte %00000000
.byte %00110000
.byte %00110000
.byte %00000000
.byte %00000000
.byte %00100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %00100000
.byte %00100000
.byte %00100000
.byte %10110000
.byte %10010000

title_pf1_right:
.byte %00011000
.byte %10111100
.byte %10100100
.byte %10100100
.byte %10100100
.byte %00100100
.byte %10100100
.byte %10100100
.byte %10111100
.byte %10011000
.byte %00000000
.byte %00000000
.byte %00010000
.byte %00010000
.byte %00010000
.byte %01010000
.byte %01010000
.byte %11110000
.byte %11110000
.byte %10100000
.byte %10100000
.byte %10100000
.byte %00000000
.byte %00000000
.byte %11101110
.byte %11101110
.byte %00001000
.byte %00001000
.byte %11001100
.byte %11101100
.byte %00101000
.byte %00101000
.byte %11101110
.byte %11001110

num_pf2:
.byte %11000110
.byte %11101111
.byte %00101001
.byte %00101001
.byte %00101100
.byte %11101100
.byte %11100110
.byte %00100010
.byte %00100011
.byte %00101111
.byte %11101111
.byte %11001111

num_pf0:
.byte %10000000
.byte %11010000
.byte %01010000
.byte %01000000
.byte %01000000
.byte %01000000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %01010000
.byte %11010000
.byte %10000000

num_pf1:
.byte %10001100
.byte %11011110
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %01010010
.byte %11011110
.byte %10001100


.org $1FFA
.segment "VECTORS"

.word Reset          ; NMI
.word Reset          ; RESET
.word Reset          ; IRQ
