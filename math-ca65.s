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
@Lp:lda divisorH
    beq @divHZero ; skip high bytes if we're past that
    lda dividendH
    cmp divisorH
    bcs @Mk ; divisorH <= dividend? go do division
    ; otherwise shift dividend and marker right
    lsr divisorH
    ror divisorL
    lsr markerH
    ror markerL ; we'd do a carry check after, but
                ; for 10 we know that only happens
                ; when we're down to low bytes
    jmp @Lp
@Mk:
    ; XXX I think we need to check low bytes here too, first?
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
    jmp @Lp
@divHZero:
    ; with some prep code before, could jump here for an
    ; 8-bit division...
    lda dividendL
    cmp divisorL
    bcs @Mk8 ; divisorL
    ; shift dividend and marker
    lsr divisorL
    lsr markerL
    bcc @divHZero
    ; carry is set - we shifted off the end!
    ; set A and Y according to the result
    lda quotientH
    ldy quotientL
    rts
@Mk8:
    lda dividendL
    sec
    sbc divisorL
    sta dividendL
    lda markerL
    ora quotientL
    sta quotientL
    jmp @divHZero
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
