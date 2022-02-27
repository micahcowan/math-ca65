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


.macro div10 dividend
.scope
    prLine "DIV"
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
    pla
    tay
    pla
    jsr prDec16u_AY
    lda #$A0
    jsr Mon_COUT
    pla
    tay
    lda #$00
    jsr prDec16u_AY
    prCR
.endscope
.endmacro

Start:
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
    div10 2560
    div10 320
    ;
    ;jsr Mon_RDKEY
    ;
    div10 576
    div10 288
    div10 65535
    div10 32768
    ;
    prLine "DONE"

Loop:
    jmp Loop
