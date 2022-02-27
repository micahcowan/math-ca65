.include "a2-monitor.inc"
.include "math-ca65.inc"
.include "forthish.inc"

.segment "SETUP"

.macro print thing
    lda #thing | $80
    jsr Mon_COUT1
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
    pla
    tay
    pla
    jsr prBin16_AY
    ;rotb_
    pla
    jsr prBin8_A
    
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
    jsr Mon_RDKEY
    ;
    div10 576;$0240
    lda #0
    jsr prBin8_A
    lda #57
    jsr prBin8_A
    prCR
    ;
    div10 288;$0120
    lda #0
    jsr prBin8_A
    lda #28
    jsr prBin8_A
    prCR
    ;
    div10 65535
    lda #>6553
    ldy #<6553
    jsr prBin16_AY
    prCR
    ;
    div10 32768
    lda #>3276
    ldy #<3276
    jsr prBin16_AY
    prCR
    ;
    prLine "DONE"

Loop:
    jmp Loop
