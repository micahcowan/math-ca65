.include "a2-monitor.inc"
.include "math-ca65.inc"
.include "forthish.inc"
.include "division.inc"

.macpack apple2

.segment "SETUP"

.macro print thing
    lda #thing | $80
    jsr Mon_COUT
.endmacro

.macro prCR
    jsr Mon_CROUT
.endmacro

.macro prLine str
    prCR
    .repeat .strlen(str),i
      print {.strat(str,i)}
    .endrepeat
    prCR
.endmacro


.macro divmul10 dividend
.scope
    prLine "DIV/MUL"
    lda #>dividend
    ldy #<dividend
    jsr prBin16_AY
    lda #>dividend
    ldy #<dividend
    jsr prDec16u_AY
    prCR
    lda #>dividend
    ldy #<dividend
    jsr div10w_AY
    ;
    pha
    tya
    pha
    txa
    pha
    rot_
@mk:
    ; stack: x a y (top)
    copy_ 3
    pla
    tay
    pla
    jsr prBin16_AY
    ;rotb_
    pla
    jsr prBin8_A
    ;
    copy_ 2
    pla
    tay
    pla
    jsr prDec16u_AY
    lda #$A0
    jsr Mon_COUT
    rotb_
    pla
    tay
    lda #$00
    jsr prDec16u_AY
    prCR
    ;
    pla
    tay
    pla
    jsr mul10w_AY
    pha
    tya
    pha
    copy_ 2
    pla
    tay
    pla
    ;
    jsr prBin16_AY
    pla
    tay
    pla
    jsr prDec16u_AY
    prCR
@lp:lda @strtmp
    beq @donePr
    jsr Mon_COUT
    inc @lp+1
    bne @lp
    inc @lp+2
    bne @lp ; "always"
@donePr:
    lda #$A0 ; SPC
    jsr Mon_COUT
    lda #<@strtmp
    pha
    lda #>@strtmp
    pha
    jsr rdDec16u
    swap_ ; high byte last
    pla
    tay
    pla
    jsr prDec16u_AY
    prCR
    jmp @end
@strtmp:
    scrcode .string(dividend)
    .byte 0
@end:
.endscope
.endmacro

.macro write32 loca, valu
.repeat 4,i
lda #((valu >> ((3-i) * 8)) & $ff)
sta loca+i
.endrepeat
.endmacro

.macro print32 loca
.repeat 4,i
lda loca+i
jsr prBin8_A
.endrepeat
prCR
.repeat 4,i
lda loca+i
jsr Mon_PRBYTE
.endrepeat
prCR
.endmacro

.macro doDiv32 dividend, divisor
    write32 locDividend, dividend
    write32 locDivisor, divisor
    prLine "DEND"
    print32 locDividend
    prLine "DSOR"
    print32 locDivisor
    jsr div32
    prLine "QUOT"
    print32 locQuotient
    prLine "REM"
    print32 locRemainder
.endmacro

.macro doDiv16 dividend, divisor
    write32 locDividend, (dividend << 16)
    write32 locDivisor, (divisor << 16)
    prLine "DEND"
    print32 locDividend
    prLine "DSOR"
    print32 locDivisor
    jsr div16
    prLine "QUOT"
    print32 locQuotient
    prLine "REM"
    print32 locRemainder
.endmacro

Start:
    ldx #$FF
    txs
    jsr Mon_HOME
    lda #160
    pha
    jsr prBin8_A
    prCR
    ;
    pla
    rol
    tay
    lda #$00
    rol
    jsr prBin16_AY
    prCR
    ;
    divmul10 2560
    divmul10 320
    divmul10 576
    ;
    ;jsr Mon_RDKEY
    ;
    divmul10 288
    divmul10 65535
    divmul10 32768
    ;
    lda #$AF
    jsr Mon_PRBYTE
    lda #$CD
    jsr Mon_PRBYTE
    prCR
    ;
@doDivs:
    prLine "DIV32"
    doDiv32 61363620, 120
    ;jsr Mon_RDKEY
    prCR
    doDiv16 1027, 256
    ;
    prCR
    prLine "DONE"

Loop:
    jmp Loop

div32:
    makeDivisionRoutine 4
div16:
    makeDivisionRoutine 2
    