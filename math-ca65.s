;#resource "math-ca65.cfg"
;#define CFGFILE math-ca65.cfg
;#link "math-ca65-startup.s"
;#link "forthish.s"

.include "forthish.inc"
.include "a2-monitor.inc"
MATH_CA65_NO_IMPORT=1
.include "math-ca65.inc"

.export prBin8_A
prBin8_A:
    ldx #$8
@Lp:asl
    pha
    bcs @On ; print '1' if set, '0' if not
@Ze:lda #$B0
    bne @Pr ; always
@On:lda #$B1
@Pr:jsr Mon_COUT1
    pla
    dex
    bne @Lp
    lda #$A0    ; SPC
    jsr Mon_COUT1
    rts

;; High byte in A, low byte in Y
.export prBin16_AY
prBin16_AY:
    jsr prBin8_A
    tya
    jsr prBin8_A
    rts

;; High byte in A, low byte in Y
;;  Remainder will be placed in X register
DEBUG=0
.export div10w_AY
div10w_AY:
    ; initialize vars
    sta dividendH
    sty dividendL
    lda #0
    sta quotientL
    sta quotientH
    sta markerL
    sta divisorL
    lda #$A0
    sta divisorH
    lda #$10
    sta markerH
@Lp:
    .if DEBUG
      jsr print_state_div10w_AY
    .endif
    lda dividendH
    bne @NotZero
    lda divisorH
    beq @divHZero ; skip high bytes if we're past that
    lda dividendH
@NotZero:
    cmp divisorH
    beq @CheckLow ; divisorH == dividendH? check low byte too
    bcs @Mk       ; divisorH < dividendH? divide!
    ; otherwise shift dividend and marker right and try again
@shiftR:
    lsr divisorH
    ror divisorL
    lsr markerH
    ror markerL ; we'd do a carry check after, but
                ; for 10 we know that only happens
                ; when we're down to low bytes
    jmp @Lp
    ; We need to check divisorL <= dividendL too
@CheckLow:
    lda dividendL
    cmp divisorL
    bcc @shiftR
@Mk:
    lda dividendL
    sec
    sbc divisorL
    sta dividendL
    lda dividendH
    sbc divisorH
    sta dividendH
    lda markerH
    ora quotientH
    sta quotientH
    lda markerL
    ora quotientL
    sta quotientL
    jmp @shiftR
@divHZero:
    .if DEBUG
      jsr print_state_div10w_AY
    .endif
    ; with some prep code before, could jump here for an
    ; 8-bit division...
    lda dividendL
    cmp divisorL
    bcs @Mk8 ; divisorL
    ; shift dividend and marker
@shiftR8:
    lsr divisorL
    lsr markerL
    bcc @divHZero
    ; carry is set - we shifted off the end!
    ; set A and Y according to the result
    lda quotientH
    ldy quotientL
    ldx dividendL ; remainder/modulus
    .if DEBUG
      jmp print_state_cleanup_div10w_AY
    .endif
    rts
@Mk8:
    lda dividendL
    sec
    sbc divisorL
    sta dividendL
    lda markerL
    ora quotientL
    sta quotientL
    jmp @shiftR8
dividendL:
    .byte $00
dividendH:
    .byte $00
quotientL:
    .byte $FF
quotientH:
    .byte $FF
markerL:
    .byte $FF
markerH:
    .byte $FF
divisorL:
    .byte $FF
divisorH:
    .byte $FF

.ifdef DEBUG
.macro prstate code, name
    lda #.strat(code,0) | $80
    jsr Mon_COUT1
    lda #$BA	; ':'
    jsr Mon_COUT1
    lda #$A0	; SPC
    jsr Mon_COUT1
    lda .ident(.concat(.string(name),"H"))
    ldy .ident(.concat(.string(name),"L"))
    jsr prBin16_AY
    lda #$8D    ; CR
    jsr Mon_COUT1
.endmacro

print_state_div10w_AY:
    lda Mon_CH ; save char pos
    pha
    lda #$00
    sta Mon_CH
    ; print various states of division
    prstate "X", dividend
    prstate "Y", divisor
    prstate "M", marker
    prstate "Q", quotient
    
    lda Mon_CV
    sec
    sbc #4
    sta Mon_CV
    jsr Mon_BASCALC
    pla
    sta Mon_CH
    rts

print_state_cleanup_div10w_AY:
    pha
    tya
    pha
    txa
    pha
    lda Mon_CH ; save current char pos
    pha
    ; clean up screen
    lda #$0
    sta Mon_CH
    .repeat 4
      jsr Mon_CLREOL
      inc Mon_CV
      jsr Mon_VTAB
    .endrepeat
    ; jump back to the line we were at
    ;
    lda Mon_CV
    sec
    sbc #4
    sta Mon_CV
    jsr Mon_BASCALC
    pla
    sta Mon_CH
    pla
    tax
    pla
    tay
    pla
    rts
.endif ; DEBUG

prDec16uw_AY:
    rts
