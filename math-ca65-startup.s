.include "a2-monitor.inc"
.include "math-ca65.inc"
.include "forthish.inc"

.segment "SETUP"

.macro print thing
    lda #thing | $80
    jsr Mon_COUT
.endmacro

.macro prCR
    print $0D
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
.endscope
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
    ;
    ;jsr Mon_RDKEY
    ;
    divmul10 576
    divmul10 288
    divmul10 65535
    divmul10 32768
    ;
    lda #$AF
    jsr Mon_PRBYTE
    lda #$CD
    jsr Mon_PRBYTE
    ;
    prCR
    prLine "DONE"

Loop:
    jmp Loop
