# File saved with Nlview 7.8.0 2024-04-26 e1825d835c VDI=44 GEI=38 GUI=JA:21.0 threadsafe
# 
# non-default properties - (restore without -noprops)
property -colorscheme classic
property attrcolor #000000
property attrfontsize 8
property autobundle 1
property backgroundcolor #ffffff
property boxcolor0 #000000
property boxcolor1 #000000
property boxcolor2 #000000
property boxinstcolor #000000
property boxpincolor #000000
property buscolor #008000
property closeenough 5
property createnetattrdsp 2048
property decorate 1
property elidetext 40
property fillcolor1 #ffffcc
property fillcolor2 #dfebf8
property fillcolor3 #f0f0f0
property gatecellname 2
property instattrmax 30
property instdrag 15
property instorder 1
property marksize 12
property maxfontsize 12
property maxzoom 5
property netcolor #19b400
property objecthighlight0 #ff00ff
property objecthighlight1 #ffff00
property objecthighlight2 #00ff00
property objecthighlight3 #0095ff
property objecthighlight4 #8000ff
property objecthighlight5 #ffc800
property objecthighlight7 #00ffff
property objecthighlight8 #ff00ff
property objecthighlight9 #ccccff
property objecthighlight10 #0ead00
property objecthighlight11 #cefc00
property objecthighlight12 #9e2dbe
property objecthighlight13 #ba6a29
property objecthighlight14 #fc0188
property objecthighlight15 #02f990
property objecthighlight16 #f1b0fb
property objecthighlight17 #fec004
property objecthighlight18 #149bff
property objecthighlight19 #eb591b
property overlaycolor #19b400
property pbuscolor #000000
property pbusnamecolor #000000
property pinattrmax 20
property pinorder 2
property pinpermute 0
property portcolor #000000
property portnamecolor #000000
property ripindexfontsize 4
property rippercolor #000000
property rubberbandcolor #000000
property rubberbandfontsize 12
property selectattr 0
property selectionappearance 2
property selectioncolor #0000ff
property sheetheight 44
property sheetwidth 68
property showmarks 1
property shownetname 0
property showpagenumbers 1
property showripindex 1
property timelimit 1
#
module new gcd_div work:gcd_div:NOFILE -nosplit
load symbol RTL_MUX2 work MUX pin I0 input.left pin I1 input.left pin I2 input.left pin I3 input.left pin O output.right pinBus S input.bot [1:0] fillcolor 1
load symbol RTL_ROM work GEN pinBus A input.left [31:0] pinBus O output.right [1:0] fillcolor 1
load symbol RTL_MUX1 work MUX pin S input.bot pinBus I0 input.left [1:0] pinBus I1 input.left [1:0] pinBus O output.right [1:0] fillcolor 1
load symbol RTL_MUX0 work MUX pinBus I0 input.left [1:0] pinBus I1 input.left [1:0] pinBus I2 input.left [1:0] pinBus I3 input.left [1:0] pinBus O output.right [1:0] pinBus S input.bot [1:0] fillcolor 1
load symbol RTL_MUX7 work MUX pin S input.bot pinBus I0 input.left [31:0] pinBus I1 input.left [31:0] pinBus O output.right [31:0] fillcolor 1
load symbol RTL_MUX8 work MUX pin I0 input.left pin I1 input.left pin O output.right pin S input.bot fillcolor 1
load symbol RTL_MOD work RTL(%) pinBus I0 input.left [31:0] pinBus I1 input.left [31:0] pinBus O output.right [31:0] fillcolor 1
load symbol RTL_AND work AND pin I0 input pin I1 input pin O output fillcolor 1
load symbol RTL_EQ work RTL(=) pin O output.right pinBus I0 input.left [1:0] pinBus I1 input.left [1:0] fillcolor 1
load symbol RTL_EQ0 work RTL(=) pin O output.right pinBus I0 input.left [31:0] pinBus I1 input.left [31:0] fillcolor 1
load symbol RTL_ROM0 work GEN pin O output.right pinBus A input.left [31:0] fillcolor 1
load symbol RTL_REG_ASYNC__BREG_1 workCLR[31:0]sssww GEN pin C input.clk.left pin CE input.left pin CLR input.neg.top pinBus D input.left [31:0] pinBus Q output.right [31:0] fillcolor 1 sandwich 3 prop @bundle 32
load symbol RTL_REG_ASYNC__BREG_1 workCLR[1:0]sssww GEN pin C input.clk.left pin CE input.left pin CLR input.neg.top pinBus D input.left [1:0] pinBus Q output.right [1:0] fillcolor 1 sandwich 3 prop @bundle 2
load port clk input -pg 1 -lvl 0 -x 0 -y 360
load port done output -pg 1 -lvl 14 -x 3600 -y 340
load port rst_n input -pg 1 -lvl 0 -x 0 -y 380
load port start input -pg 1 -lvl 0 -x 0 -y 500
load portBus a input [31:0] -attr @name a[31:0] -pg 1 -lvl 0 -x 0 -y 90
load portBus b input [31:0] -attr @name b[31:0] -pg 1 -lvl 0 -x 0 -y 400
load portBus result output [31:0] -attr @name result[31:0] -pg 1 -lvl 14 -x 3600 -y 180
load inst done_i RTL_MUX2 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=2'b00 -pinAttr I1 @attr S=2'b01 -pinAttr I2 @attr S=2'b10 -pinAttr I3 @attr S=default -pinBusAttr S @name S[1:0] -pg 1 -lvl 13 -x 3430 -y 340
load inst load_inputs_i RTL_MUX2 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=2'b00 -pinAttr I1 @attr S=2'b01 -pinAttr I2 @attr S=2'b10 -pinAttr I3 @attr S=default -pinBusAttr S @name S[1:0] -pg 1 -lvl 2 -x 270 -y 580
load inst next_state_i RTL_ROM work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[31:0] -pinBusAttr O @name O[1:0] -pg 1 -lvl 8 -x 2070 -y 270
load inst next_state_i__0 RTL_MUX1 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[1:0] -pinBusAttr I0 @attr S=1'b0 -pinBusAttr I1 @name I1[1:0] -pinBusAttr I1 @attr V=B\"10\",\ S=default -pinBusAttr O @name O[1:0] -pg 1 -lvl 8 -x 2070 -y 420
load inst next_state_i__1 RTL_MUX0 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[1:0] -pinBusAttr I0 @attr V=B\"01\",\ S=2'b00 -pinBusAttr I1 @name I1[1:0] -pinBusAttr I1 @attr S=2'b01 -pinBusAttr I2 @name I2[1:0] -pinBusAttr I2 @attr S=2'b10 -pinBusAttr I3 @name I3[1:0] -pinBusAttr I3 @attr S=default -pinBusAttr O @name O[1:0] -pinBusAttr S @name S[1:0] -pg 1 -lvl 9 -x 2450 -y 280
load inst next_state_i__2 RTL_MUX2 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=2'b00 -pinAttr I1 @attr S=2'b01 -pinAttr I2 @attr S=2'b10 -pinAttr I3 @attr S=default -pinBusAttr S @name S[1:0] -pg 1 -lvl 9 -x 2450 -y 490
load inst reg_a_i RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[31:0] -pinBusAttr I0 @attr S=1'b1 -pinBusAttr I1 @name I1[31:0] -pinBusAttr I1 @attr S=default -pinBusAttr O @name O[31:0] -pg 1 -lvl 3 -x 590 -y 100
load inst reg_a_i__0 RTL_MUX8 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 3 -x 590 -y 280
load inst reg_b0_i RTL_MOD work -attr @cell(#000000) RTL_MOD -pinBusAttr I0 @name I0[31:0] -pinBusAttr I1 @name I1[31:0] -pinBusAttr O @name O[31:0] -pg 1 -lvl 5 -x 1110 -y 350
load inst reg_b_i RTL_MUX7 work -attr @cell(#000000) RTL_MUX -pinBusAttr I0 @name I0[31:0] -pinBusAttr I0 @attr S=1'b1 -pinBusAttr I1 @name I1[31:0] -pinBusAttr I1 @attr S=default -pinBusAttr O @name O[31:0] -pg 1 -lvl 6 -x 1460 -y 400
load inst reg_b_i__0 RTL_MUX8 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=1'b1 -pinAttr I1 @attr S=default -pg 1 -lvl 6 -x 1460 -y 260
load inst result0_i RTL_AND work -attr @cell(#000000) RTL_AND -pg 1 -lvl 12 -x 3160 -y 180
load inst result1_i RTL_EQ work -attr @cell(#000000) RTL_EQ -pinBusAttr I0 @name I0[1:0] -pinBusAttr I1 @name I1[1:0] -pinBusAttr I1 @attr V=B\"01\" -pg 1 -lvl 11 -x 2980 -y 100
load inst result1_i__0 RTL_EQ0 work -attr @cell(#000000) RTL_EQ -pinBusAttr I0 @name I0[31:0] -pinBusAttr I1 @name I1[31:0] -pg 1 -lvl 11 -x 2980 -y 190
load inst update_regs_i RTL_ROM0 work -attr @cell(#000000) RTL_ROM -pinBusAttr A @name A[31:0] -pg 1 -lvl 1 -x 50 -y 240
load inst update_regs_i__0 RTL_MUX2 work -attr @cell(#000000) RTL_MUX -pinAttr I0 @attr S=2'b00 -pinAttr I1 @attr S=2'b01 -pinAttr I2 @attr S=2'b10 -pinAttr I3 @attr S=default -pinBusAttr S @name S[1:0] -pg 1 -lvl 2 -x 270 -y 250
load inst result_reg[31:0] RTL_REG_ASYNC__BREG_1 workCLR[31:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 13 -x 3430 -y 180
load inst reg_b_reg[31:0] RTL_REG_ASYNC__BREG_1 workCLR[31:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 7 -x 1690 -y 80
load inst reg_a_reg[31:0] RTL_REG_ASYNC__BREG_1 workCLR[31:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 4 -x 840 -y 80
load inst state_reg[1:0] RTL_REG_ASYNC__BREG_1 workCLR[1:0]sssww -attr @cell(#000000) RTL_REG_ASYNC -pg 1 -lvl 10 -x 2680 -y 100
load net <const0> -ground -pin done_i I0 -pin done_i I1 -pin done_i I3 -pin load_inputs_i I1 -pin load_inputs_i I2 -pin load_inputs_i I3 -pin next_state_i__0 I0[1] -pin next_state_i__0 I0[0] -pin next_state_i__0 I1[0] -pin next_state_i__1 I0[1] -pin next_state_i__1 I3[1] -pin next_state_i__1 I3[0] -pin result1_i I1[1] -pin result1_i__0 I1[31] -pin result1_i__0 I1[30] -pin result1_i__0 I1[29] -pin result1_i__0 I1[28] -pin result1_i__0 I1[27] -pin result1_i__0 I1[26] -pin result1_i__0 I1[25] -pin result1_i__0 I1[24] -pin result1_i__0 I1[23] -pin result1_i__0 I1[22] -pin result1_i__0 I1[21] -pin result1_i__0 I1[20] -pin result1_i__0 I1[19] -pin result1_i__0 I1[18] -pin result1_i__0 I1[17] -pin result1_i__0 I1[16] -pin result1_i__0 I1[15] -pin result1_i__0 I1[14] -pin result1_i__0 I1[13] -pin result1_i__0 I1[12] -pin result1_i__0 I1[11] -pin result1_i__0 I1[10] -pin result1_i__0 I1[9] -pin result1_i__0 I1[8] -pin result1_i__0 I1[7] -pin result1_i__0 I1[6] -pin result1_i__0 I1[5] -pin result1_i__0 I1[4] -pin result1_i__0 I1[3] -pin result1_i__0 I1[2] -pin result1_i__0 I1[1] -pin result1_i__0 I1[0] -pin update_regs_i__0 I0 -pin update_regs_i__0 I2 -pin update_regs_i__0 I3
load net <const1> -power -pin done_i I2 -pin next_state_i__0 I1[1] -pin next_state_i__1 I0[0] -pin next_state_i__2 I1 -pin next_state_i__2 I2 -pin next_state_i__2 I3 -pin reg_a_i__0 I0 -pin reg_b_i__0 I0 -pin result1_i I1[0]
load net a[0] -attr @rip(#000000) a[0] -port a[0] -pin reg_a_i I0[0]
load net a[10] -attr @rip(#000000) a[10] -port a[10] -pin reg_a_i I0[10]
load net a[11] -attr @rip(#000000) a[11] -port a[11] -pin reg_a_i I0[11]
load net a[12] -attr @rip(#000000) a[12] -port a[12] -pin reg_a_i I0[12]
load net a[13] -attr @rip(#000000) a[13] -port a[13] -pin reg_a_i I0[13]
load net a[14] -attr @rip(#000000) a[14] -port a[14] -pin reg_a_i I0[14]
load net a[15] -attr @rip(#000000) a[15] -port a[15] -pin reg_a_i I0[15]
load net a[16] -attr @rip(#000000) a[16] -port a[16] -pin reg_a_i I0[16]
load net a[17] -attr @rip(#000000) a[17] -port a[17] -pin reg_a_i I0[17]
load net a[18] -attr @rip(#000000) a[18] -port a[18] -pin reg_a_i I0[18]
load net a[19] -attr @rip(#000000) a[19] -port a[19] -pin reg_a_i I0[19]
load net a[1] -attr @rip(#000000) a[1] -port a[1] -pin reg_a_i I0[1]
load net a[20] -attr @rip(#000000) a[20] -port a[20] -pin reg_a_i I0[20]
load net a[21] -attr @rip(#000000) a[21] -port a[21] -pin reg_a_i I0[21]
load net a[22] -attr @rip(#000000) a[22] -port a[22] -pin reg_a_i I0[22]
load net a[23] -attr @rip(#000000) a[23] -port a[23] -pin reg_a_i I0[23]
load net a[24] -attr @rip(#000000) a[24] -port a[24] -pin reg_a_i I0[24]
load net a[25] -attr @rip(#000000) a[25] -port a[25] -pin reg_a_i I0[25]
load net a[26] -attr @rip(#000000) a[26] -port a[26] -pin reg_a_i I0[26]
load net a[27] -attr @rip(#000000) a[27] -port a[27] -pin reg_a_i I0[27]
load net a[28] -attr @rip(#000000) a[28] -port a[28] -pin reg_a_i I0[28]
load net a[29] -attr @rip(#000000) a[29] -port a[29] -pin reg_a_i I0[29]
load net a[2] -attr @rip(#000000) a[2] -port a[2] -pin reg_a_i I0[2]
load net a[30] -attr @rip(#000000) a[30] -port a[30] -pin reg_a_i I0[30]
load net a[31] -attr @rip(#000000) a[31] -port a[31] -pin reg_a_i I0[31]
load net a[3] -attr @rip(#000000) a[3] -port a[3] -pin reg_a_i I0[3]
load net a[4] -attr @rip(#000000) a[4] -port a[4] -pin reg_a_i I0[4]
load net a[5] -attr @rip(#000000) a[5] -port a[5] -pin reg_a_i I0[5]
load net a[6] -attr @rip(#000000) a[6] -port a[6] -pin reg_a_i I0[6]
load net a[7] -attr @rip(#000000) a[7] -port a[7] -pin reg_a_i I0[7]
load net a[8] -attr @rip(#000000) a[8] -port a[8] -pin reg_a_i I0[8]
load net a[9] -attr @rip(#000000) a[9] -port a[9] -pin reg_a_i I0[9]
load net b[0] -attr @rip(#000000) b[0] -port b[0] -pin reg_b_i I0[0]
load net b[10] -attr @rip(#000000) b[10] -port b[10] -pin reg_b_i I0[10]
load net b[11] -attr @rip(#000000) b[11] -port b[11] -pin reg_b_i I0[11]
load net b[12] -attr @rip(#000000) b[12] -port b[12] -pin reg_b_i I0[12]
load net b[13] -attr @rip(#000000) b[13] -port b[13] -pin reg_b_i I0[13]
load net b[14] -attr @rip(#000000) b[14] -port b[14] -pin reg_b_i I0[14]
load net b[15] -attr @rip(#000000) b[15] -port b[15] -pin reg_b_i I0[15]
load net b[16] -attr @rip(#000000) b[16] -port b[16] -pin reg_b_i I0[16]
load net b[17] -attr @rip(#000000) b[17] -port b[17] -pin reg_b_i I0[17]
load net b[18] -attr @rip(#000000) b[18] -port b[18] -pin reg_b_i I0[18]
load net b[19] -attr @rip(#000000) b[19] -port b[19] -pin reg_b_i I0[19]
load net b[1] -attr @rip(#000000) b[1] -port b[1] -pin reg_b_i I0[1]
load net b[20] -attr @rip(#000000) b[20] -port b[20] -pin reg_b_i I0[20]
load net b[21] -attr @rip(#000000) b[21] -port b[21] -pin reg_b_i I0[21]
load net b[22] -attr @rip(#000000) b[22] -port b[22] -pin reg_b_i I0[22]
load net b[23] -attr @rip(#000000) b[23] -port b[23] -pin reg_b_i I0[23]
load net b[24] -attr @rip(#000000) b[24] -port b[24] -pin reg_b_i I0[24]
load net b[25] -attr @rip(#000000) b[25] -port b[25] -pin reg_b_i I0[25]
load net b[26] -attr @rip(#000000) b[26] -port b[26] -pin reg_b_i I0[26]
load net b[27] -attr @rip(#000000) b[27] -port b[27] -pin reg_b_i I0[27]
load net b[28] -attr @rip(#000000) b[28] -port b[28] -pin reg_b_i I0[28]
load net b[29] -attr @rip(#000000) b[29] -port b[29] -pin reg_b_i I0[29]
load net b[2] -attr @rip(#000000) b[2] -port b[2] -pin reg_b_i I0[2]
load net b[30] -attr @rip(#000000) b[30] -port b[30] -pin reg_b_i I0[30]
load net b[31] -attr @rip(#000000) b[31] -port b[31] -pin reg_b_i I0[31]
load net b[3] -attr @rip(#000000) b[3] -port b[3] -pin reg_b_i I0[3]
load net b[4] -attr @rip(#000000) b[4] -port b[4] -pin reg_b_i I0[4]
load net b[5] -attr @rip(#000000) b[5] -port b[5] -pin reg_b_i I0[5]
load net b[6] -attr @rip(#000000) b[6] -port b[6] -pin reg_b_i I0[6]
load net b[7] -attr @rip(#000000) b[7] -port b[7] -pin reg_b_i I0[7]
load net b[8] -attr @rip(#000000) b[8] -port b[8] -pin reg_b_i I0[8]
load net b[9] -attr @rip(#000000) b[9] -port b[9] -pin reg_b_i I0[9]
load net clk -port clk -pin reg_a_reg[31:0] C -pin reg_b_reg[31:0] C -pin result_reg[31:0] C -pin state_reg[1:0] C
netloc clk 1 0 13 NJ 360 NJ 360 NJ 360 760 160 NJ 160 NJ 160 1610 160 NJ 160 NJ 160 2580 260 NJ 260 NJ 260 3270J
load net done -port done -pin done_i O
netloc done 1 13 1 NJ 340
load net load_inputs -pin load_inputs_i O -pin reg_a_i S -pin reg_a_i__0 S -pin reg_b_i S -pin reg_b_i__0 S
netloc load_inputs 1 2 4 420 160N 720 220 NJ 220 1270
load net next_state[0] -attr @rip(#000000) O[0] -pin next_state_i__1 O[0] -pin state_reg[1:0] D[0]
load net next_state[1] -attr @rip(#000000) O[1] -pin next_state_i__1 O[1] -pin state_reg[1:0] D[1]
load net next_state_i__0_n_0 -attr @rip(#000000) O[1] -pin next_state_i__0 O[1] -pin next_state_i__1 I2[1]
load net next_state_i__0_n_1 -attr @rip(#000000) O[0] -pin next_state_i__0 O[0] -pin next_state_i__1 I2[0]
load net next_state_i__2_n_0 -pin next_state_i__2 O -pin state_reg[1:0] CE
netloc next_state_i__2_n_0 1 9 1 2600 100n
load net next_state_i_n_0 -attr @rip(#000000) O[1] -pin next_state_i O[1] -pin next_state_i__1 I1[1]
load net next_state_i_n_1 -attr @rip(#000000) O[0] -pin next_state_i O[0] -pin next_state_i__1 I1[0]
load net reg_a[0] -attr @rip(#000000) 0 -pin reg_a_reg[31:0] Q[0] -pin reg_b0_i I0[0] -pin result_reg[31:0] D[0]
load net reg_a[10] -attr @rip(#000000) 10 -pin reg_a_reg[31:0] Q[10] -pin reg_b0_i I0[10] -pin result_reg[31:0] D[10]
load net reg_a[11] -attr @rip(#000000) 11 -pin reg_a_reg[31:0] Q[11] -pin reg_b0_i I0[11] -pin result_reg[31:0] D[11]
load net reg_a[12] -attr @rip(#000000) 12 -pin reg_a_reg[31:0] Q[12] -pin reg_b0_i I0[12] -pin result_reg[31:0] D[12]
load net reg_a[13] -attr @rip(#000000) 13 -pin reg_a_reg[31:0] Q[13] -pin reg_b0_i I0[13] -pin result_reg[31:0] D[13]
load net reg_a[14] -attr @rip(#000000) 14 -pin reg_a_reg[31:0] Q[14] -pin reg_b0_i I0[14] -pin result_reg[31:0] D[14]
load net reg_a[15] -attr @rip(#000000) 15 -pin reg_a_reg[31:0] Q[15] -pin reg_b0_i I0[15] -pin result_reg[31:0] D[15]
load net reg_a[16] -attr @rip(#000000) 16 -pin reg_a_reg[31:0] Q[16] -pin reg_b0_i I0[16] -pin result_reg[31:0] D[16]
load net reg_a[17] -attr @rip(#000000) 17 -pin reg_a_reg[31:0] Q[17] -pin reg_b0_i I0[17] -pin result_reg[31:0] D[17]
load net reg_a[18] -attr @rip(#000000) 18 -pin reg_a_reg[31:0] Q[18] -pin reg_b0_i I0[18] -pin result_reg[31:0] D[18]
load net reg_a[19] -attr @rip(#000000) 19 -pin reg_a_reg[31:0] Q[19] -pin reg_b0_i I0[19] -pin result_reg[31:0] D[19]
load net reg_a[1] -attr @rip(#000000) 1 -pin reg_a_reg[31:0] Q[1] -pin reg_b0_i I0[1] -pin result_reg[31:0] D[1]
load net reg_a[20] -attr @rip(#000000) 20 -pin reg_a_reg[31:0] Q[20] -pin reg_b0_i I0[20] -pin result_reg[31:0] D[20]
load net reg_a[21] -attr @rip(#000000) 21 -pin reg_a_reg[31:0] Q[21] -pin reg_b0_i I0[21] -pin result_reg[31:0] D[21]
load net reg_a[22] -attr @rip(#000000) 22 -pin reg_a_reg[31:0] Q[22] -pin reg_b0_i I0[22] -pin result_reg[31:0] D[22]
load net reg_a[23] -attr @rip(#000000) 23 -pin reg_a_reg[31:0] Q[23] -pin reg_b0_i I0[23] -pin result_reg[31:0] D[23]
load net reg_a[24] -attr @rip(#000000) 24 -pin reg_a_reg[31:0] Q[24] -pin reg_b0_i I0[24] -pin result_reg[31:0] D[24]
load net reg_a[25] -attr @rip(#000000) 25 -pin reg_a_reg[31:0] Q[25] -pin reg_b0_i I0[25] -pin result_reg[31:0] D[25]
load net reg_a[26] -attr @rip(#000000) 26 -pin reg_a_reg[31:0] Q[26] -pin reg_b0_i I0[26] -pin result_reg[31:0] D[26]
load net reg_a[27] -attr @rip(#000000) 27 -pin reg_a_reg[31:0] Q[27] -pin reg_b0_i I0[27] -pin result_reg[31:0] D[27]
load net reg_a[28] -attr @rip(#000000) 28 -pin reg_a_reg[31:0] Q[28] -pin reg_b0_i I0[28] -pin result_reg[31:0] D[28]
load net reg_a[29] -attr @rip(#000000) 29 -pin reg_a_reg[31:0] Q[29] -pin reg_b0_i I0[29] -pin result_reg[31:0] D[29]
load net reg_a[2] -attr @rip(#000000) 2 -pin reg_a_reg[31:0] Q[2] -pin reg_b0_i I0[2] -pin result_reg[31:0] D[2]
load net reg_a[30] -attr @rip(#000000) 30 -pin reg_a_reg[31:0] Q[30] -pin reg_b0_i I0[30] -pin result_reg[31:0] D[30]
load net reg_a[31] -attr @rip(#000000) 31 -pin reg_a_reg[31:0] Q[31] -pin reg_b0_i I0[31] -pin result_reg[31:0] D[31]
load net reg_a[3] -attr @rip(#000000) 3 -pin reg_a_reg[31:0] Q[3] -pin reg_b0_i I0[3] -pin result_reg[31:0] D[3]
load net reg_a[4] -attr @rip(#000000) 4 -pin reg_a_reg[31:0] Q[4] -pin reg_b0_i I0[4] -pin result_reg[31:0] D[4]
load net reg_a[5] -attr @rip(#000000) 5 -pin reg_a_reg[31:0] Q[5] -pin reg_b0_i I0[5] -pin result_reg[31:0] D[5]
load net reg_a[6] -attr @rip(#000000) 6 -pin reg_a_reg[31:0] Q[6] -pin reg_b0_i I0[6] -pin result_reg[31:0] D[6]
load net reg_a[7] -attr @rip(#000000) 7 -pin reg_a_reg[31:0] Q[7] -pin reg_b0_i I0[7] -pin result_reg[31:0] D[7]
load net reg_a[8] -attr @rip(#000000) 8 -pin reg_a_reg[31:0] Q[8] -pin reg_b0_i I0[8] -pin result_reg[31:0] D[8]
load net reg_a[9] -attr @rip(#000000) 9 -pin reg_a_reg[31:0] Q[9] -pin reg_b0_i I0[9] -pin result_reg[31:0] D[9]
load net reg_a__0[0] -attr @rip(#000000) O[0] -pin reg_a_i O[0] -pin reg_a_reg[31:0] D[0]
load net reg_a__0[10] -attr @rip(#000000) O[10] -pin reg_a_i O[10] -pin reg_a_reg[31:0] D[10]
load net reg_a__0[11] -attr @rip(#000000) O[11] -pin reg_a_i O[11] -pin reg_a_reg[31:0] D[11]
load net reg_a__0[12] -attr @rip(#000000) O[12] -pin reg_a_i O[12] -pin reg_a_reg[31:0] D[12]
load net reg_a__0[13] -attr @rip(#000000) O[13] -pin reg_a_i O[13] -pin reg_a_reg[31:0] D[13]
load net reg_a__0[14] -attr @rip(#000000) O[14] -pin reg_a_i O[14] -pin reg_a_reg[31:0] D[14]
load net reg_a__0[15] -attr @rip(#000000) O[15] -pin reg_a_i O[15] -pin reg_a_reg[31:0] D[15]
load net reg_a__0[16] -attr @rip(#000000) O[16] -pin reg_a_i O[16] -pin reg_a_reg[31:0] D[16]
load net reg_a__0[17] -attr @rip(#000000) O[17] -pin reg_a_i O[17] -pin reg_a_reg[31:0] D[17]
load net reg_a__0[18] -attr @rip(#000000) O[18] -pin reg_a_i O[18] -pin reg_a_reg[31:0] D[18]
load net reg_a__0[19] -attr @rip(#000000) O[19] -pin reg_a_i O[19] -pin reg_a_reg[31:0] D[19]
load net reg_a__0[1] -attr @rip(#000000) O[1] -pin reg_a_i O[1] -pin reg_a_reg[31:0] D[1]
load net reg_a__0[20] -attr @rip(#000000) O[20] -pin reg_a_i O[20] -pin reg_a_reg[31:0] D[20]
load net reg_a__0[21] -attr @rip(#000000) O[21] -pin reg_a_i O[21] -pin reg_a_reg[31:0] D[21]
load net reg_a__0[22] -attr @rip(#000000) O[22] -pin reg_a_i O[22] -pin reg_a_reg[31:0] D[22]
load net reg_a__0[23] -attr @rip(#000000) O[23] -pin reg_a_i O[23] -pin reg_a_reg[31:0] D[23]
load net reg_a__0[24] -attr @rip(#000000) O[24] -pin reg_a_i O[24] -pin reg_a_reg[31:0] D[24]
load net reg_a__0[25] -attr @rip(#000000) O[25] -pin reg_a_i O[25] -pin reg_a_reg[31:0] D[25]
load net reg_a__0[26] -attr @rip(#000000) O[26] -pin reg_a_i O[26] -pin reg_a_reg[31:0] D[26]
load net reg_a__0[27] -attr @rip(#000000) O[27] -pin reg_a_i O[27] -pin reg_a_reg[31:0] D[27]
load net reg_a__0[28] -attr @rip(#000000) O[28] -pin reg_a_i O[28] -pin reg_a_reg[31:0] D[28]
load net reg_a__0[29] -attr @rip(#000000) O[29] -pin reg_a_i O[29] -pin reg_a_reg[31:0] D[29]
load net reg_a__0[2] -attr @rip(#000000) O[2] -pin reg_a_i O[2] -pin reg_a_reg[31:0] D[2]
load net reg_a__0[30] -attr @rip(#000000) O[30] -pin reg_a_i O[30] -pin reg_a_reg[31:0] D[30]
load net reg_a__0[31] -attr @rip(#000000) O[31] -pin reg_a_i O[31] -pin reg_a_reg[31:0] D[31]
load net reg_a__0[3] -attr @rip(#000000) O[3] -pin reg_a_i O[3] -pin reg_a_reg[31:0] D[3]
load net reg_a__0[4] -attr @rip(#000000) O[4] -pin reg_a_i O[4] -pin reg_a_reg[31:0] D[4]
load net reg_a__0[5] -attr @rip(#000000) O[5] -pin reg_a_i O[5] -pin reg_a_reg[31:0] D[5]
load net reg_a__0[6] -attr @rip(#000000) O[6] -pin reg_a_i O[6] -pin reg_a_reg[31:0] D[6]
load net reg_a__0[7] -attr @rip(#000000) O[7] -pin reg_a_i O[7] -pin reg_a_reg[31:0] D[7]
load net reg_a__0[8] -attr @rip(#000000) O[8] -pin reg_a_i O[8] -pin reg_a_reg[31:0] D[8]
load net reg_a__0[9] -attr @rip(#000000) O[9] -pin reg_a_i O[9] -pin reg_a_reg[31:0] D[9]
load net reg_a_i__0_n_0 -pin reg_a_i__0 O -pin reg_a_reg[31:0] CE
netloc reg_a_i__0_n_0 1 3 1 780 80n
load net reg_b0[0] -attr @rip(#000000) O[0] -pin reg_b0_i O[0] -pin reg_b_i I1[0]
load net reg_b0[10] -attr @rip(#000000) O[10] -pin reg_b0_i O[10] -pin reg_b_i I1[10]
load net reg_b0[11] -attr @rip(#000000) O[11] -pin reg_b0_i O[11] -pin reg_b_i I1[11]
load net reg_b0[12] -attr @rip(#000000) O[12] -pin reg_b0_i O[12] -pin reg_b_i I1[12]
load net reg_b0[13] -attr @rip(#000000) O[13] -pin reg_b0_i O[13] -pin reg_b_i I1[13]
load net reg_b0[14] -attr @rip(#000000) O[14] -pin reg_b0_i O[14] -pin reg_b_i I1[14]
load net reg_b0[15] -attr @rip(#000000) O[15] -pin reg_b0_i O[15] -pin reg_b_i I1[15]
load net reg_b0[16] -attr @rip(#000000) O[16] -pin reg_b0_i O[16] -pin reg_b_i I1[16]
load net reg_b0[17] -attr @rip(#000000) O[17] -pin reg_b0_i O[17] -pin reg_b_i I1[17]
load net reg_b0[18] -attr @rip(#000000) O[18] -pin reg_b0_i O[18] -pin reg_b_i I1[18]
load net reg_b0[19] -attr @rip(#000000) O[19] -pin reg_b0_i O[19] -pin reg_b_i I1[19]
load net reg_b0[1] -attr @rip(#000000) O[1] -pin reg_b0_i O[1] -pin reg_b_i I1[1]
load net reg_b0[20] -attr @rip(#000000) O[20] -pin reg_b0_i O[20] -pin reg_b_i I1[20]
load net reg_b0[21] -attr @rip(#000000) O[21] -pin reg_b0_i O[21] -pin reg_b_i I1[21]
load net reg_b0[22] -attr @rip(#000000) O[22] -pin reg_b0_i O[22] -pin reg_b_i I1[22]
load net reg_b0[23] -attr @rip(#000000) O[23] -pin reg_b0_i O[23] -pin reg_b_i I1[23]
load net reg_b0[24] -attr @rip(#000000) O[24] -pin reg_b0_i O[24] -pin reg_b_i I1[24]
load net reg_b0[25] -attr @rip(#000000) O[25] -pin reg_b0_i O[25] -pin reg_b_i I1[25]
load net reg_b0[26] -attr @rip(#000000) O[26] -pin reg_b0_i O[26] -pin reg_b_i I1[26]
load net reg_b0[27] -attr @rip(#000000) O[27] -pin reg_b0_i O[27] -pin reg_b_i I1[27]
load net reg_b0[28] -attr @rip(#000000) O[28] -pin reg_b0_i O[28] -pin reg_b_i I1[28]
load net reg_b0[29] -attr @rip(#000000) O[29] -pin reg_b0_i O[29] -pin reg_b_i I1[29]
load net reg_b0[2] -attr @rip(#000000) O[2] -pin reg_b0_i O[2] -pin reg_b_i I1[2]
load net reg_b0[30] -attr @rip(#000000) O[30] -pin reg_b0_i O[30] -pin reg_b_i I1[30]
load net reg_b0[31] -attr @rip(#000000) O[31] -pin reg_b0_i O[31] -pin reg_b_i I1[31]
load net reg_b0[3] -attr @rip(#000000) O[3] -pin reg_b0_i O[3] -pin reg_b_i I1[3]
load net reg_b0[4] -attr @rip(#000000) O[4] -pin reg_b0_i O[4] -pin reg_b_i I1[4]
load net reg_b0[5] -attr @rip(#000000) O[5] -pin reg_b0_i O[5] -pin reg_b_i I1[5]
load net reg_b0[6] -attr @rip(#000000) O[6] -pin reg_b0_i O[6] -pin reg_b_i I1[6]
load net reg_b0[7] -attr @rip(#000000) O[7] -pin reg_b0_i O[7] -pin reg_b_i I1[7]
load net reg_b0[8] -attr @rip(#000000) O[8] -pin reg_b0_i O[8] -pin reg_b_i I1[8]
load net reg_b0[9] -attr @rip(#000000) O[9] -pin reg_b0_i O[9] -pin reg_b_i I1[9]
load net reg_b[0] -attr @rip(#000000) 0 -pin next_state_i A[0] -pin reg_a_i I1[0] -pin reg_b0_i I1[0] -pin reg_b_reg[31:0] Q[0] -pin result1_i__0 I0[0] -pin update_regs_i A[0]
load net reg_b[10] -attr @rip(#000000) 10 -pin next_state_i A[10] -pin reg_a_i I1[10] -pin reg_b0_i I1[10] -pin reg_b_reg[31:0] Q[10] -pin result1_i__0 I0[10] -pin update_regs_i A[10]
load net reg_b[11] -attr @rip(#000000) 11 -pin next_state_i A[11] -pin reg_a_i I1[11] -pin reg_b0_i I1[11] -pin reg_b_reg[31:0] Q[11] -pin result1_i__0 I0[11] -pin update_regs_i A[11]
load net reg_b[12] -attr @rip(#000000) 12 -pin next_state_i A[12] -pin reg_a_i I1[12] -pin reg_b0_i I1[12] -pin reg_b_reg[31:0] Q[12] -pin result1_i__0 I0[12] -pin update_regs_i A[12]
load net reg_b[13] -attr @rip(#000000) 13 -pin next_state_i A[13] -pin reg_a_i I1[13] -pin reg_b0_i I1[13] -pin reg_b_reg[31:0] Q[13] -pin result1_i__0 I0[13] -pin update_regs_i A[13]
load net reg_b[14] -attr @rip(#000000) 14 -pin next_state_i A[14] -pin reg_a_i I1[14] -pin reg_b0_i I1[14] -pin reg_b_reg[31:0] Q[14] -pin result1_i__0 I0[14] -pin update_regs_i A[14]
load net reg_b[15] -attr @rip(#000000) 15 -pin next_state_i A[15] -pin reg_a_i I1[15] -pin reg_b0_i I1[15] -pin reg_b_reg[31:0] Q[15] -pin result1_i__0 I0[15] -pin update_regs_i A[15]
load net reg_b[16] -attr @rip(#000000) 16 -pin next_state_i A[16] -pin reg_a_i I1[16] -pin reg_b0_i I1[16] -pin reg_b_reg[31:0] Q[16] -pin result1_i__0 I0[16] -pin update_regs_i A[16]
load net reg_b[17] -attr @rip(#000000) 17 -pin next_state_i A[17] -pin reg_a_i I1[17] -pin reg_b0_i I1[17] -pin reg_b_reg[31:0] Q[17] -pin result1_i__0 I0[17] -pin update_regs_i A[17]
load net reg_b[18] -attr @rip(#000000) 18 -pin next_state_i A[18] -pin reg_a_i I1[18] -pin reg_b0_i I1[18] -pin reg_b_reg[31:0] Q[18] -pin result1_i__0 I0[18] -pin update_regs_i A[18]
load net reg_b[19] -attr @rip(#000000) 19 -pin next_state_i A[19] -pin reg_a_i I1[19] -pin reg_b0_i I1[19] -pin reg_b_reg[31:0] Q[19] -pin result1_i__0 I0[19] -pin update_regs_i A[19]
load net reg_b[1] -attr @rip(#000000) 1 -pin next_state_i A[1] -pin reg_a_i I1[1] -pin reg_b0_i I1[1] -pin reg_b_reg[31:0] Q[1] -pin result1_i__0 I0[1] -pin update_regs_i A[1]
load net reg_b[20] -attr @rip(#000000) 20 -pin next_state_i A[20] -pin reg_a_i I1[20] -pin reg_b0_i I1[20] -pin reg_b_reg[31:0] Q[20] -pin result1_i__0 I0[20] -pin update_regs_i A[20]
load net reg_b[21] -attr @rip(#000000) 21 -pin next_state_i A[21] -pin reg_a_i I1[21] -pin reg_b0_i I1[21] -pin reg_b_reg[31:0] Q[21] -pin result1_i__0 I0[21] -pin update_regs_i A[21]
load net reg_b[22] -attr @rip(#000000) 22 -pin next_state_i A[22] -pin reg_a_i I1[22] -pin reg_b0_i I1[22] -pin reg_b_reg[31:0] Q[22] -pin result1_i__0 I0[22] -pin update_regs_i A[22]
load net reg_b[23] -attr @rip(#000000) 23 -pin next_state_i A[23] -pin reg_a_i I1[23] -pin reg_b0_i I1[23] -pin reg_b_reg[31:0] Q[23] -pin result1_i__0 I0[23] -pin update_regs_i A[23]
load net reg_b[24] -attr @rip(#000000) 24 -pin next_state_i A[24] -pin reg_a_i I1[24] -pin reg_b0_i I1[24] -pin reg_b_reg[31:0] Q[24] -pin result1_i__0 I0[24] -pin update_regs_i A[24]
load net reg_b[25] -attr @rip(#000000) 25 -pin next_state_i A[25] -pin reg_a_i I1[25] -pin reg_b0_i I1[25] -pin reg_b_reg[31:0] Q[25] -pin result1_i__0 I0[25] -pin update_regs_i A[25]
load net reg_b[26] -attr @rip(#000000) 26 -pin next_state_i A[26] -pin reg_a_i I1[26] -pin reg_b0_i I1[26] -pin reg_b_reg[31:0] Q[26] -pin result1_i__0 I0[26] -pin update_regs_i A[26]
load net reg_b[27] -attr @rip(#000000) 27 -pin next_state_i A[27] -pin reg_a_i I1[27] -pin reg_b0_i I1[27] -pin reg_b_reg[31:0] Q[27] -pin result1_i__0 I0[27] -pin update_regs_i A[27]
load net reg_b[28] -attr @rip(#000000) 28 -pin next_state_i A[28] -pin reg_a_i I1[28] -pin reg_b0_i I1[28] -pin reg_b_reg[31:0] Q[28] -pin result1_i__0 I0[28] -pin update_regs_i A[28]
load net reg_b[29] -attr @rip(#000000) 29 -pin next_state_i A[29] -pin reg_a_i I1[29] -pin reg_b0_i I1[29] -pin reg_b_reg[31:0] Q[29] -pin result1_i__0 I0[29] -pin update_regs_i A[29]
load net reg_b[2] -attr @rip(#000000) 2 -pin next_state_i A[2] -pin reg_a_i I1[2] -pin reg_b0_i I1[2] -pin reg_b_reg[31:0] Q[2] -pin result1_i__0 I0[2] -pin update_regs_i A[2]
load net reg_b[30] -attr @rip(#000000) 30 -pin next_state_i A[30] -pin reg_a_i I1[30] -pin reg_b0_i I1[30] -pin reg_b_reg[31:0] Q[30] -pin result1_i__0 I0[30] -pin update_regs_i A[30]
load net reg_b[31] -attr @rip(#000000) 31 -pin next_state_i A[31] -pin reg_a_i I1[31] -pin reg_b0_i I1[31] -pin reg_b_reg[31:0] Q[31] -pin result1_i__0 I0[31] -pin update_regs_i A[31]
load net reg_b[3] -attr @rip(#000000) 3 -pin next_state_i A[3] -pin reg_a_i I1[3] -pin reg_b0_i I1[3] -pin reg_b_reg[31:0] Q[3] -pin result1_i__0 I0[3] -pin update_regs_i A[3]
load net reg_b[4] -attr @rip(#000000) 4 -pin next_state_i A[4] -pin reg_a_i I1[4] -pin reg_b0_i I1[4] -pin reg_b_reg[31:0] Q[4] -pin result1_i__0 I0[4] -pin update_regs_i A[4]
load net reg_b[5] -attr @rip(#000000) 5 -pin next_state_i A[5] -pin reg_a_i I1[5] -pin reg_b0_i I1[5] -pin reg_b_reg[31:0] Q[5] -pin result1_i__0 I0[5] -pin update_regs_i A[5]
load net reg_b[6] -attr @rip(#000000) 6 -pin next_state_i A[6] -pin reg_a_i I1[6] -pin reg_b0_i I1[6] -pin reg_b_reg[31:0] Q[6] -pin result1_i__0 I0[6] -pin update_regs_i A[6]
load net reg_b[7] -attr @rip(#000000) 7 -pin next_state_i A[7] -pin reg_a_i I1[7] -pin reg_b0_i I1[7] -pin reg_b_reg[31:0] Q[7] -pin result1_i__0 I0[7] -pin update_regs_i A[7]
load net reg_b[8] -attr @rip(#000000) 8 -pin next_state_i A[8] -pin reg_a_i I1[8] -pin reg_b0_i I1[8] -pin reg_b_reg[31:0] Q[8] -pin result1_i__0 I0[8] -pin update_regs_i A[8]
load net reg_b[9] -attr @rip(#000000) 9 -pin next_state_i A[9] -pin reg_a_i I1[9] -pin reg_b0_i I1[9] -pin reg_b_reg[31:0] Q[9] -pin result1_i__0 I0[9] -pin update_regs_i A[9]
load net reg_b__0[0] -attr @rip(#000000) O[0] -pin reg_b_i O[0] -pin reg_b_reg[31:0] D[0]
load net reg_b__0[10] -attr @rip(#000000) O[10] -pin reg_b_i O[10] -pin reg_b_reg[31:0] D[10]
load net reg_b__0[11] -attr @rip(#000000) O[11] -pin reg_b_i O[11] -pin reg_b_reg[31:0] D[11]
load net reg_b__0[12] -attr @rip(#000000) O[12] -pin reg_b_i O[12] -pin reg_b_reg[31:0] D[12]
load net reg_b__0[13] -attr @rip(#000000) O[13] -pin reg_b_i O[13] -pin reg_b_reg[31:0] D[13]
load net reg_b__0[14] -attr @rip(#000000) O[14] -pin reg_b_i O[14] -pin reg_b_reg[31:0] D[14]
load net reg_b__0[15] -attr @rip(#000000) O[15] -pin reg_b_i O[15] -pin reg_b_reg[31:0] D[15]
load net reg_b__0[16] -attr @rip(#000000) O[16] -pin reg_b_i O[16] -pin reg_b_reg[31:0] D[16]
load net reg_b__0[17] -attr @rip(#000000) O[17] -pin reg_b_i O[17] -pin reg_b_reg[31:0] D[17]
load net reg_b__0[18] -attr @rip(#000000) O[18] -pin reg_b_i O[18] -pin reg_b_reg[31:0] D[18]
load net reg_b__0[19] -attr @rip(#000000) O[19] -pin reg_b_i O[19] -pin reg_b_reg[31:0] D[19]
load net reg_b__0[1] -attr @rip(#000000) O[1] -pin reg_b_i O[1] -pin reg_b_reg[31:0] D[1]
load net reg_b__0[20] -attr @rip(#000000) O[20] -pin reg_b_i O[20] -pin reg_b_reg[31:0] D[20]
load net reg_b__0[21] -attr @rip(#000000) O[21] -pin reg_b_i O[21] -pin reg_b_reg[31:0] D[21]
load net reg_b__0[22] -attr @rip(#000000) O[22] -pin reg_b_i O[22] -pin reg_b_reg[31:0] D[22]
load net reg_b__0[23] -attr @rip(#000000) O[23] -pin reg_b_i O[23] -pin reg_b_reg[31:0] D[23]
load net reg_b__0[24] -attr @rip(#000000) O[24] -pin reg_b_i O[24] -pin reg_b_reg[31:0] D[24]
load net reg_b__0[25] -attr @rip(#000000) O[25] -pin reg_b_i O[25] -pin reg_b_reg[31:0] D[25]
load net reg_b__0[26] -attr @rip(#000000) O[26] -pin reg_b_i O[26] -pin reg_b_reg[31:0] D[26]
load net reg_b__0[27] -attr @rip(#000000) O[27] -pin reg_b_i O[27] -pin reg_b_reg[31:0] D[27]
load net reg_b__0[28] -attr @rip(#000000) O[28] -pin reg_b_i O[28] -pin reg_b_reg[31:0] D[28]
load net reg_b__0[29] -attr @rip(#000000) O[29] -pin reg_b_i O[29] -pin reg_b_reg[31:0] D[29]
load net reg_b__0[2] -attr @rip(#000000) O[2] -pin reg_b_i O[2] -pin reg_b_reg[31:0] D[2]
load net reg_b__0[30] -attr @rip(#000000) O[30] -pin reg_b_i O[30] -pin reg_b_reg[31:0] D[30]
load net reg_b__0[31] -attr @rip(#000000) O[31] -pin reg_b_i O[31] -pin reg_b_reg[31:0] D[31]
load net reg_b__0[3] -attr @rip(#000000) O[3] -pin reg_b_i O[3] -pin reg_b_reg[31:0] D[3]
load net reg_b__0[4] -attr @rip(#000000) O[4] -pin reg_b_i O[4] -pin reg_b_reg[31:0] D[4]
load net reg_b__0[5] -attr @rip(#000000) O[5] -pin reg_b_i O[5] -pin reg_b_reg[31:0] D[5]
load net reg_b__0[6] -attr @rip(#000000) O[6] -pin reg_b_i O[6] -pin reg_b_reg[31:0] D[6]
load net reg_b__0[7] -attr @rip(#000000) O[7] -pin reg_b_i O[7] -pin reg_b_reg[31:0] D[7]
load net reg_b__0[8] -attr @rip(#000000) O[8] -pin reg_b_i O[8] -pin reg_b_reg[31:0] D[8]
load net reg_b__0[9] -attr @rip(#000000) O[9] -pin reg_b_i O[9] -pin reg_b_reg[31:0] D[9]
load net reg_b_i__0_n_0 -pin reg_b_i__0 O -pin reg_b_reg[31:0] CE
netloc reg_b_i__0_n_0 1 6 1 1590 80n
load net result0 -pin result0_i O -pin result_reg[31:0] CE
netloc result0 1 12 1 N 180
load net result1 -pin result0_i I0 -pin result1_i O
netloc result1 1 11 1 3110 100n
load net result1_i__0_n_0 -pin result0_i I1 -pin result1_i__0 O
netloc result1_i__0_n_0 1 11 1 NJ 190
load net result[0] -attr @rip(#000000) 0 -port result[0] -pin result_reg[31:0] Q[0]
load net result[10] -attr @rip(#000000) 10 -port result[10] -pin result_reg[31:0] Q[10]
load net result[11] -attr @rip(#000000) 11 -port result[11] -pin result_reg[31:0] Q[11]
load net result[12] -attr @rip(#000000) 12 -port result[12] -pin result_reg[31:0] Q[12]
load net result[13] -attr @rip(#000000) 13 -port result[13] -pin result_reg[31:0] Q[13]
load net result[14] -attr @rip(#000000) 14 -port result[14] -pin result_reg[31:0] Q[14]
load net result[15] -attr @rip(#000000) 15 -port result[15] -pin result_reg[31:0] Q[15]
load net result[16] -attr @rip(#000000) 16 -port result[16] -pin result_reg[31:0] Q[16]
load net result[17] -attr @rip(#000000) 17 -port result[17] -pin result_reg[31:0] Q[17]
load net result[18] -attr @rip(#000000) 18 -port result[18] -pin result_reg[31:0] Q[18]
load net result[19] -attr @rip(#000000) 19 -port result[19] -pin result_reg[31:0] Q[19]
load net result[1] -attr @rip(#000000) 1 -port result[1] -pin result_reg[31:0] Q[1]
load net result[20] -attr @rip(#000000) 20 -port result[20] -pin result_reg[31:0] Q[20]
load net result[21] -attr @rip(#000000) 21 -port result[21] -pin result_reg[31:0] Q[21]
load net result[22] -attr @rip(#000000) 22 -port result[22] -pin result_reg[31:0] Q[22]
load net result[23] -attr @rip(#000000) 23 -port result[23] -pin result_reg[31:0] Q[23]
load net result[24] -attr @rip(#000000) 24 -port result[24] -pin result_reg[31:0] Q[24]
load net result[25] -attr @rip(#000000) 25 -port result[25] -pin result_reg[31:0] Q[25]
load net result[26] -attr @rip(#000000) 26 -port result[26] -pin result_reg[31:0] Q[26]
load net result[27] -attr @rip(#000000) 27 -port result[27] -pin result_reg[31:0] Q[27]
load net result[28] -attr @rip(#000000) 28 -port result[28] -pin result_reg[31:0] Q[28]
load net result[29] -attr @rip(#000000) 29 -port result[29] -pin result_reg[31:0] Q[29]
load net result[2] -attr @rip(#000000) 2 -port result[2] -pin result_reg[31:0] Q[2]
load net result[30] -attr @rip(#000000) 30 -port result[30] -pin result_reg[31:0] Q[30]
load net result[31] -attr @rip(#000000) 31 -port result[31] -pin result_reg[31:0] Q[31]
load net result[3] -attr @rip(#000000) 3 -port result[3] -pin result_reg[31:0] Q[3]
load net result[4] -attr @rip(#000000) 4 -port result[4] -pin result_reg[31:0] Q[4]
load net result[5] -attr @rip(#000000) 5 -port result[5] -pin result_reg[31:0] Q[5]
load net result[6] -attr @rip(#000000) 6 -port result[6] -pin result_reg[31:0] Q[6]
load net result[7] -attr @rip(#000000) 7 -port result[7] -pin result_reg[31:0] Q[7]
load net result[8] -attr @rip(#000000) 8 -port result[8] -pin result_reg[31:0] Q[8]
load net result[9] -attr @rip(#000000) 9 -port result[9] -pin result_reg[31:0] Q[9]
load net rst_n -pin reg_a_reg[31:0] CLR -pin reg_b_reg[31:0] CLR -pin result_reg[31:0] CLR -port rst_n -pin state_reg[1:0] CLR
netloc rst_n 1 0 13 NJ 380 NJ 380 NJ 380 740J 10N NJ 10 NJ 10 N 10N 1900 30 NJ 30 NJ 30N NJ 30 NJ 30 3270
load net start -pin load_inputs_i I0 -pin next_state_i__0 S -pin next_state_i__2 I0 -port start
netloc start 1 0 9 NJ 500 170 500 NJ 500 NJ 500 NJ 500 NJ 500 NJ 500 1880 480N 2270
load net state[0] -attr @rip(#000000) 0 -pin done_i S[0] -pin load_inputs_i S[0] -pin next_state_i__1 S[0] -pin next_state_i__2 S[0] -pin result1_i I0[0] -pin state_reg[1:0] Q[0] -pin update_regs_i__0 S[0]
load net state[1] -attr @rip(#000000) 1 -pin done_i S[1] -pin load_inputs_i S[1] -pin next_state_i__1 S[1] -pin next_state_i__2 S[1] -pin result1_i I0[1] -pin state_reg[1:0] Q[1] -pin update_regs_i__0 S[1]
load net update_regs -pin reg_a_i__0 I1 -pin reg_b_i__0 I1 -pin update_regs_i__0 O
netloc update_regs 1 2 4 440 180 NJ 180 NJ 180 1290
load net update_regs_i_n_0 -pin update_regs_i O -pin update_regs_i__0 I1
netloc update_regs_i_n_0 1 1 1 NJ 240
load netBundle @a 32 a[31] a[30] a[29] a[28] a[27] a[26] a[25] a[24] a[23] a[22] a[21] a[20] a[19] a[18] a[17] a[16] a[15] a[14] a[13] a[12] a[11] a[10] a[9] a[8] a[7] a[6] a[5] a[4] a[3] a[2] a[1] a[0] -autobundled
netbloc @a 1 0 3 NJ 90 NJ 90 NJ
load netBundle @b 32 b[31] b[30] b[29] b[28] b[27] b[26] b[25] b[24] b[23] b[22] b[21] b[20] b[19] b[18] b[17] b[16] b[15] b[14] b[13] b[12] b[11] b[10] b[9] b[8] b[7] b[6] b[5] b[4] b[3] b[2] b[1] b[0] -autobundled
netbloc @b 1 0 6 NJ 400 NJ 400 NJ 400 NJ 400 NJ 400 1230J
load netBundle @result 32 result[31] result[30] result[29] result[28] result[27] result[26] result[25] result[24] result[23] result[22] result[21] result[20] result[19] result[18] result[17] result[16] result[15] result[14] result[13] result[12] result[11] result[10] result[9] result[8] result[7] result[6] result[5] result[4] result[3] result[2] result[1] result[0] -autobundled
netbloc @result 1 13 1 NJ 180
load netBundle @next_state_i_n_ 2 next_state_i_n_0 next_state_i_n_1 -autobundled
netbloc @next_state_i_n_ 1 8 1 NJ 270
load netBundle @next_state_i__0_n_ 2 next_state_i__0_n_0 next_state_i__0_n_1 -autobundled
netbloc @next_state_i__0_n_ 1 8 1 2210 290n
load netBundle @next_state 2 next_state[1] next_state[0] -autobundled
netbloc @next_state 1 9 1 2620 120n
load netBundle @reg_a__0 32 reg_a__0[31] reg_a__0[30] reg_a__0[29] reg_a__0[28] reg_a__0[27] reg_a__0[26] reg_a__0[25] reg_a__0[24] reg_a__0[23] reg_a__0[22] reg_a__0[21] reg_a__0[20] reg_a__0[19] reg_a__0[18] reg_a__0[17] reg_a__0[16] reg_a__0[15] reg_a__0[14] reg_a__0[13] reg_a__0[12] reg_a__0[11] reg_a__0[10] reg_a__0[9] reg_a__0[8] reg_a__0[7] reg_a__0[6] reg_a__0[5] reg_a__0[4] reg_a__0[3] reg_a__0[2] reg_a__0[1] reg_a__0[0] -autobundled
netbloc @reg_a__0 1 3 1 N 100
load netBundle @reg_b0 32 reg_b0[31] reg_b0[30] reg_b0[29] reg_b0[28] reg_b0[27] reg_b0[26] reg_b0[25] reg_b0[24] reg_b0[23] reg_b0[22] reg_b0[21] reg_b0[20] reg_b0[19] reg_b0[18] reg_b0[17] reg_b0[16] reg_b0[15] reg_b0[14] reg_b0[13] reg_b0[12] reg_b0[11] reg_b0[10] reg_b0[9] reg_b0[8] reg_b0[7] reg_b0[6] reg_b0[5] reg_b0[4] reg_b0[3] reg_b0[2] reg_b0[1] reg_b0[0] -autobundled
netbloc @reg_b0 1 5 1 1250 350n
load netBundle @reg_b__0 32 reg_b__0[31] reg_b__0[30] reg_b__0[29] reg_b__0[28] reg_b__0[27] reg_b__0[26] reg_b__0[25] reg_b__0[24] reg_b__0[23] reg_b__0[22] reg_b__0[21] reg_b__0[20] reg_b__0[19] reg_b__0[18] reg_b__0[17] reg_b__0[16] reg_b__0[15] reg_b__0[14] reg_b__0[13] reg_b__0[12] reg_b__0[11] reg_b__0[10] reg_b__0[9] reg_b__0[8] reg_b__0[7] reg_b__0[6] reg_b__0[5] reg_b__0[4] reg_b__0[3] reg_b__0[2] reg_b__0[1] reg_b__0[0] -autobundled
netbloc @reg_b__0 1 6 1 1630 100n
load netBundle @reg_b 32 reg_b[31] reg_b[30] reg_b[29] reg_b[28] reg_b[27] reg_b[26] reg_b[25] reg_b[24] reg_b[23] reg_b[22] reg_b[21] reg_b[20] reg_b[19] reg_b[18] reg_b[17] reg_b[16] reg_b[15] reg_b[14] reg_b[13] reg_b[12] reg_b[11] reg_b[10] reg_b[9] reg_b[8] reg_b[7] reg_b[6] reg_b[5] reg_b[4] reg_b[3] reg_b[2] reg_b[1] reg_b[0] -autobundled
netbloc @reg_b 1 0 11 20 170 NJ 170 400 200 NJ 200 1030 200 1310J 180 NJ 180 1900 180 NJ 180 NJ 180 NJ
load netBundle @reg_a 32 reg_a[31] reg_a[30] reg_a[29] reg_a[28] reg_a[27] reg_a[26] reg_a[25] reg_a[24] reg_a[23] reg_a[22] reg_a[21] reg_a[20] reg_a[19] reg_a[18] reg_a[17] reg_a[16] reg_a[15] reg_a[14] reg_a[13] reg_a[12] reg_a[11] reg_a[10] reg_a[9] reg_a[8] reg_a[7] reg_a[6] reg_a[5] reg_a[4] reg_a[3] reg_a[2] reg_a[1] reg_a[0] -autobundled
netbloc @reg_a 1 4 9 1010 300 1330J 340 NJ 340 NJ 340 2230J 390 NJ 390 NJ 390 NJ 390 3290
load netBundle @state 2 state[1] state[0] -autobundled
netbloc @state 1 2 11 400 480 NJ 480 NJ 480 NJ 480 NJ 480 1860J 510 2250 360N NJ 360 2840 370 NJ 370 3270J
levelinfo -pg 1 0 50 270 590 840 1110 1460 1690 2070 2450 2680 2980 3160 3430 3600
pagesize -pg 1 -db -bbox -sgen -100 0 3720 690
show
fullfit
#
# initialize ictrl to current module gcd_div work:gcd_div:NOFILE
ictrl init topinfo |
