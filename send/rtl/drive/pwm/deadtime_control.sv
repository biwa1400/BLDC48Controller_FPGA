
// 模块: deadtime_control
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// 功能    : implement deadtime control on pwm outputs

module deadtime_control #(
	parameter DEADTIME_LH = 8,
	parameter DEADTIME_HL = 8
) (
	input  wire 		 rstn,
	input  wire 		 clk,
	input	 wire	[6:0]	 dtc,
	input	 wire [12:0] pwm1_duty, pwm2_duty, pwm3_duty, pwm4_duty, pwm5_duty, pwm6_duty, pwm7_duty, pwm8_duty, pwm9_duty, pwm10_duty, pwm11_duty, pwm12_duty, pwm13_duty, pwm14_duty, pwm15_duty, pwm16_duty, pwm17_duty, pwm18_duty, pwm19_duty, pwm20_duty, pwm21_duty, pwm22_duty,
	output wire 		 o_pwm_1_lo, o_pwm_1_hi, o_pwm_2_lo, o_pwm_2_hi, o_pwm_3_lo, o_pwm_3_hi, o_pwm_4_lo, o_pwm_4_hi, o_pwm_5_lo, o_pwm_5_hi, o_pwm_6_lo, o_pwm_6_hi, o_pwm_7_lo, o_pwm_7_hi, o_pwm_8_lo, o_pwm_8_hi, o_pwm_9_lo, o_pwm_9_hi, o_pwm_10_lo, o_pwm_10_hi, o_pwm_11_lo, o_pwm_11_hi, o_pwm_12_lo, o_pwm_12_hi, o_pwm_13_lo, o_pwm_13_hi, o_pwm_14_lo, o_pwm_14_hi, o_pwm_15_lo, o_pwm_15_hi, o_pwm_16_lo, o_pwm_16_hi, o_pwm_17_lo, o_pwm_17_hi, o_pwm_18_lo, o_pwm_18_hi, o_pwm_19_lo, o_pwm_19_hi, o_pwm_20_lo, o_pwm_20_hi, o_pwm_21_lo, o_pwm_21_hi, o_pwm_22_lo, o_pwm_22_hi
);

localparam SVPWM_CLK_DIV = 14'd13328;
localparam SVPWM_CLK_DIV_QUARTER = 14'd3332;

reg [13:0] svpwm_cnt1 = '0;
reg [13:0] svpwm_cnt2 = '0;
reg [13:0] svpwm_cnt3 = '0;
reg [13:0] svpwm_cnt4 = '0;
reg [13:0] svpwm_cnt5 = '0;
reg [13:0] svpwm_cnt6 = '0;
reg [13:0] svpwm_cnt7 = '0;
reg [13:0] svpwm_cnt8 = '0;
reg [13:0] svpwm_cnt9 = '0;
reg [13:0] svpwm_cnt10 = '0;
reg [13:0] svpwm_cnt11 = '0;
reg [13:0] svpwm_cnt12 = '0;
reg [13:0] svpwm_cnt13 = '0;
reg [13:0] svpwm_cnt14 = '0;
reg [13:0] svpwm_cnt15 = '0;
reg [13:0] svpwm_cnt16 = '0;
reg [13:0] svpwm_cnt17 = '0;
reg [13:0] svpwm_cnt18 = '0;
reg [13:0] svpwm_cnt19 = '0;
reg [13:0] svpwm_cnt20 = '0;
reg [13:0] svpwm_cnt21 = '0;
reg [13:0] svpwm_cnt22 = '0;

reg pwm_1, pwm_2, pwm_3, pwm_4, pwm_5, pwm_6, pwm_7, pwm_8, pwm_9, pwm_10, pwm_11, pwm_12, pwm_13, pwm_14, pwm_15, pwm_16, pwm_17, pwm_18, pwm_19, pwm_20, pwm_21, pwm_22;  // PWM使能信号 pwm_en, 22相PWM信号 pwm_1, pwm_2, pwm_3 ...

reg pwm_1_lo, pwm_1_hi, pwm_2_lo, pwm_2_hi, pwm_3_lo, pwm_3_hi, pwm_4_lo, pwm_4_hi, pwm_5_lo, pwm_5_hi, pwm_6_lo, pwm_6_hi, pwm_7_lo, pwm_7_hi, pwm_8_lo, pwm_8_hi, pwm_9_lo, pwm_9_hi, pwm_10_lo, pwm_10_hi, pwm_11_lo, pwm_11_hi, pwm_12_lo, pwm_12_hi, pwm_13_lo, pwm_13_hi, pwm_14_lo, pwm_14_hi, pwm_15_lo, pwm_15_hi, pwm_16_lo, pwm_16_hi, pwm_17_lo, pwm_17_hi, pwm_18_lo, pwm_18_hi, pwm_19_lo, pwm_19_hi, pwm_20_lo, pwm_20_hi, pwm_21_lo, pwm_21_hi, pwm_22_lo, pwm_22_hi;

reg pwm_1_prev  = '0;
reg pwm_2_prev  = '0;
reg pwm_3_prev  = '0;
reg pwm_4_prev  = '0;
reg pwm_5_prev  = '0;
reg pwm_6_prev  = '0;
reg pwm_7_prev  = '0;
reg pwm_8_prev  = '0;
reg pwm_9_prev  = '0;
reg pwm_10_prev = '0;
reg pwm_11_prev = '0;
reg pwm_12_prev = '0;
reg pwm_13_prev = '0;
reg pwm_14_prev = '0;
reg pwm_15_prev = '0;
reg pwm_16_prev = '0;
reg pwm_17_prev = '0;
reg pwm_18_prev = '0;
reg pwm_19_prev = '0;
reg pwm_20_prev = '0;
reg pwm_21_prev = '0;
reg pwm_22_prev = '0;

reg [5:0] pwm_1_set_cnt = '0;
reg [5:0] pwm_2_set_cnt = '0;
reg [5:0] pwm_3_set_cnt = '0;
reg [5:0] pwm_4_set_cnt = '0;
reg [5:0] pwm_5_set_cnt = '0;
reg [5:0] pwm_6_set_cnt = '0;
reg [5:0] pwm_7_set_cnt = '0;
reg [5:0] pwm_8_set_cnt = '0;
reg [5:0] pwm_9_set_cnt = '0;
reg [5:0] pwm_10_set_cnt = '0;
reg [5:0] pwm_11_set_cnt = '0;
reg [5:0] pwm_12_set_cnt = '0;
reg [5:0] pwm_13_set_cnt = '0;
reg [5:0] pwm_14_set_cnt = '0;
reg [5:0] pwm_15_set_cnt = '0;
reg [5:0] pwm_16_set_cnt = '0;
reg [5:0] pwm_17_set_cnt = '0;
reg [5:0] pwm_18_set_cnt = '0;
reg [5:0] pwm_19_set_cnt = '0;
reg [5:0] pwm_20_set_cnt = '0;
reg [5:0] pwm_21_set_cnt = '0;
reg [5:0] pwm_22_set_cnt = '0;
reg [5:0] pwm_1_clr_cnt = '0;
reg [5:0] pwm_2_clr_cnt = '0;
reg [5:0] pwm_3_clr_cnt = '0;
reg [5:0] pwm_4_clr_cnt = '0;
reg [5:0] pwm_5_clr_cnt = '0;
reg [5:0] pwm_6_clr_cnt = '0;
reg [5:0] pwm_7_clr_cnt = '0;
reg [5:0] pwm_8_clr_cnt = '0;
reg [5:0] pwm_9_clr_cnt = '0;
reg [5:0] pwm_10_clr_cnt = '0;
reg [5:0] pwm_11_clr_cnt = '0;
reg [5:0] pwm_12_clr_cnt = '0;
reg [5:0] pwm_13_clr_cnt = '0;
reg [5:0] pwm_14_clr_cnt = '0;
reg [5:0] pwm_15_clr_cnt = '0;
reg [5:0] pwm_16_clr_cnt = '0;
reg [5:0] pwm_17_clr_cnt = '0;
reg [5:0] pwm_18_clr_cnt = '0;
reg [5:0] pwm_19_clr_cnt = '0;
reg [5:0] pwm_20_clr_cnt = '0;
reg [5:0] pwm_21_clr_cnt = '0;
reg [5:0] pwm_22_clr_cnt = '0;


always @ (posedge clk)
begin
	svpwm_cnt1 <= svpwm_cnt1 + 14'd1;
	if (svpwm_cnt1 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt1 <= '0;
	svpwm_cnt2 <= svpwm_cnt2 + 14'd1;
	if (svpwm_cnt2 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt2 <= '0;
	svpwm_cnt3 <= svpwm_cnt3 + 14'd1;
	if (svpwm_cnt3 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt3 <= '0;
	svpwm_cnt4 <= svpwm_cnt4 + 14'd1;
	if (svpwm_cnt4 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt4 <= '0;
	svpwm_cnt5 <= svpwm_cnt5 + 14'd1;
	if (svpwm_cnt5 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt5 <= '0;
	svpwm_cnt6 <= svpwm_cnt6 + 14'd1;
	if (svpwm_cnt6 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt6 <= '0;
	svpwm_cnt7 <= svpwm_cnt7 + 14'd1;
	if (svpwm_cnt7 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt7 <= '0;
	svpwm_cnt8 <= svpwm_cnt8 + 14'd1;
	if (svpwm_cnt8 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt8 <= '0;
	svpwm_cnt9 <= svpwm_cnt9 + 14'd1;
	if (svpwm_cnt9 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt9 <= '0;
	svpwm_cnt10 <= svpwm_cnt10 + 14'd1;
	if (svpwm_cnt10 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt10 <= '0;
	svpwm_cnt11 <= svpwm_cnt11 + 14'd1;
	if (svpwm_cnt11 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt11 <= '0;
	svpwm_cnt12 <= svpwm_cnt12 + 14'd1;
	if (svpwm_cnt12 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt12 <= '0;
	svpwm_cnt13 <= svpwm_cnt13 + 14'd1;
	if (svpwm_cnt13 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt13 <= '0;
	svpwm_cnt14 <= svpwm_cnt14 + 14'd1;
	if (svpwm_cnt14 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt14 <= '0;
	svpwm_cnt15 <= svpwm_cnt15 + 14'd1;
	if (svpwm_cnt15 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt15 <= '0;
	svpwm_cnt16 <= svpwm_cnt16 + 14'd1;
	if (svpwm_cnt16 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt16 <= '0;
	svpwm_cnt17 <= svpwm_cnt17 + 14'd1;
	if (svpwm_cnt17 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt17 <= '0;
	svpwm_cnt18 <= svpwm_cnt18 + 14'd1;
	if (svpwm_cnt18 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt18 <= '0;
	svpwm_cnt19 <= svpwm_cnt19 + 14'd1;
	if (svpwm_cnt19 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt19 <= '0;
	svpwm_cnt20 <= svpwm_cnt20 + 14'd1;
	if (svpwm_cnt20 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt20 <= '0;
	svpwm_cnt21 <= svpwm_cnt21 + 14'd1;
	if (svpwm_cnt21 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt21 <= '0;
	svpwm_cnt22 <= svpwm_cnt22 + 14'd1;
	if (svpwm_cnt22 == SVPWM_CLK_DIV - 14'd1)
		svpwm_cnt22 <= '0;
end


always @ (posedge clk)
begin
	pwm_1  <= pwm1_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt1<={1'b0, pwm1_duty + dtc}  || svpwm_cnt1>SVPWM_CLK_DIV - {1'b0, pwm1_duty + dtc} : svpwm_cnt1<={1'b0, pwm1_duty - dtc}  || svpwm_cnt1>SVPWM_CLK_DIV - {1'b0, pwm1_duty - dtc};
	pwm_2  <= pwm2_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt2<={1'b0, pwm2_duty + dtc}  || svpwm_cnt2>SVPWM_CLK_DIV - {1'b0, pwm2_duty + dtc} : svpwm_cnt2<={1'b0, pwm2_duty - dtc}  || svpwm_cnt2>SVPWM_CLK_DIV - {1'b0, pwm2_duty - dtc};
	pwm_3  <= pwm3_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt3<={1'b0, pwm3_duty + dtc}  || svpwm_cnt3>SVPWM_CLK_DIV - {1'b0, pwm3_duty + dtc} : svpwm_cnt3<={1'b0, pwm3_duty - dtc}  || svpwm_cnt3>SVPWM_CLK_DIV - {1'b0, pwm3_duty - dtc};
	pwm_4  <= pwm4_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt4<={1'b0, pwm4_duty + dtc}  || svpwm_cnt4>SVPWM_CLK_DIV - {1'b0, pwm4_duty + dtc} : svpwm_cnt4<={1'b0, pwm4_duty - dtc}  || svpwm_cnt4>SVPWM_CLK_DIV - {1'b0, pwm4_duty - dtc};
	pwm_5  <= pwm5_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt5<={1'b0, pwm5_duty + dtc}  || svpwm_cnt5>SVPWM_CLK_DIV - {1'b0, pwm5_duty + dtc} : svpwm_cnt5<={1'b0, pwm5_duty - dtc}  || svpwm_cnt5>SVPWM_CLK_DIV - {1'b0, pwm5_duty - dtc};
	pwm_6  <= pwm6_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt6<={1'b0, pwm6_duty + dtc}  || svpwm_cnt6>SVPWM_CLK_DIV - {1'b0, pwm6_duty + dtc} : svpwm_cnt6<={1'b0, pwm6_duty - dtc}  || svpwm_cnt6>SVPWM_CLK_DIV - {1'b0, pwm6_duty - dtc};
	pwm_7  <= pwm7_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt7<={1'b0, pwm7_duty + dtc}  || svpwm_cnt7>SVPWM_CLK_DIV - {1'b0, pwm7_duty + dtc} : svpwm_cnt7<={1'b0, pwm7_duty - dtc}  || svpwm_cnt7>SVPWM_CLK_DIV - {1'b0, pwm7_duty - dtc};
	pwm_8  <= pwm8_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt8<={1'b0, pwm8_duty + dtc}  || svpwm_cnt8>SVPWM_CLK_DIV - {1'b0, pwm8_duty + dtc} : svpwm_cnt8<={1'b0, pwm8_duty - dtc}  || svpwm_cnt8>SVPWM_CLK_DIV - {1'b0, pwm8_duty - dtc};
	pwm_9  <= pwm9_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt9<={1'b0, pwm9_duty + dtc}  || svpwm_cnt9>SVPWM_CLK_DIV - {1'b0, pwm9_duty + dtc} : svpwm_cnt9<={1'b0, pwm9_duty - dtc}  || svpwm_cnt9>SVPWM_CLK_DIV - {1'b0, pwm9_duty - dtc};
	pwm_10 <= pwm10_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt10<={1'b0, pwm10_duty + dtc} || svpwm_cnt10>SVPWM_CLK_DIV - {1'b0, pwm10_duty + dtc} : svpwm_cnt10<={1'b0, pwm10_duty - dtc} || svpwm_cnt10>SVPWM_CLK_DIV - {1'b0, pwm10_duty - dtc};
	pwm_11 <= pwm11_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt11<={1'b0, pwm11_duty + dtc} || svpwm_cnt11>SVPWM_CLK_DIV - {1'b0, pwm11_duty + dtc} : svpwm_cnt11<={1'b0, pwm11_duty - dtc} || svpwm_cnt11>SVPWM_CLK_DIV - {1'b0, pwm11_duty - dtc};
	pwm_12 <= pwm12_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt12<={1'b0, pwm12_duty + dtc} || svpwm_cnt12>SVPWM_CLK_DIV - {1'b0, pwm12_duty + dtc} : svpwm_cnt12<={1'b0, pwm12_duty - dtc} || svpwm_cnt12>SVPWM_CLK_DIV - {1'b0, pwm12_duty - dtc};
	pwm_13 <= pwm13_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt13<={1'b0, pwm13_duty + dtc} || svpwm_cnt13>SVPWM_CLK_DIV - {1'b0, pwm13_duty + dtc} : svpwm_cnt13<={1'b0, pwm13_duty - dtc} || svpwm_cnt13>SVPWM_CLK_DIV - {1'b0, pwm13_duty - dtc};
	pwm_14 <= pwm14_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt14<={1'b0, pwm14_duty + dtc} || svpwm_cnt14>SVPWM_CLK_DIV - {1'b0, pwm14_duty + dtc} : svpwm_cnt14<={1'b0, pwm14_duty - dtc} || svpwm_cnt14>SVPWM_CLK_DIV - {1'b0, pwm14_duty - dtc};
	pwm_15 <= pwm15_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt15<={1'b0, pwm15_duty + dtc} || svpwm_cnt15>SVPWM_CLK_DIV - {1'b0, pwm15_duty + dtc} : svpwm_cnt15<={1'b0, pwm15_duty - dtc} || svpwm_cnt15>SVPWM_CLK_DIV - {1'b0, pwm15_duty - dtc};
	pwm_16 <= pwm16_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt16<={1'b0, pwm16_duty + dtc} || svpwm_cnt16>SVPWM_CLK_DIV - {1'b0, pwm16_duty + dtc} : svpwm_cnt16<={1'b0, pwm16_duty - dtc} || svpwm_cnt16>SVPWM_CLK_DIV - {1'b0, pwm16_duty - dtc};
	pwm_17 <= pwm17_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt17<={1'b0, pwm17_duty + dtc} || svpwm_cnt17>SVPWM_CLK_DIV - {1'b0, pwm17_duty + dtc} : svpwm_cnt17<={1'b0, pwm17_duty - dtc} || svpwm_cnt17>SVPWM_CLK_DIV - {1'b0, pwm17_duty - dtc};
	pwm_18 <= pwm18_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt18<={1'b0, pwm18_duty + dtc} || svpwm_cnt18>SVPWM_CLK_DIV - {1'b0, pwm18_duty + dtc} : svpwm_cnt18<={1'b0, pwm18_duty - dtc} || svpwm_cnt18>SVPWM_CLK_DIV - {1'b0, pwm18_duty - dtc};
	pwm_19 <= pwm19_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt19<={1'b0, pwm19_duty + dtc} || svpwm_cnt19>SVPWM_CLK_DIV - {1'b0, pwm19_duty + dtc} : svpwm_cnt19<={1'b0, pwm19_duty - dtc} || svpwm_cnt19>SVPWM_CLK_DIV - {1'b0, pwm19_duty - dtc};
	pwm_20 <= pwm20_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt20<={1'b0, pwm20_duty + dtc} || svpwm_cnt20>SVPWM_CLK_DIV - {1'b0, pwm20_duty + dtc} : svpwm_cnt20<={1'b0, pwm20_duty - dtc} || svpwm_cnt20>SVPWM_CLK_DIV - {1'b0, pwm20_duty - dtc};
	pwm_21 <= pwm21_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt21<={1'b0, pwm21_duty + dtc} || svpwm_cnt21>SVPWM_CLK_DIV - {1'b0, pwm21_duty + dtc} : svpwm_cnt21<={1'b0, pwm21_duty - dtc} || svpwm_cnt21>SVPWM_CLK_DIV - {1'b0, pwm21_duty - dtc};
	pwm_22 <= pwm22_duty>SVPWM_CLK_DIV_QUARTER ? svpwm_cnt22<={1'b0, pwm22_duty + dtc} || svpwm_cnt22>SVPWM_CLK_DIV - {1'b0, pwm22_duty + dtc} : svpwm_cnt22<={1'b0, pwm22_duty - dtc} || svpwm_cnt22>SVPWM_CLK_DIV - {1'b0, pwm22_duty - dtc};
end


wire pwm_1_set  =  pwm_1  & ~pwm_1_prev;
wire pwm_1_clr  = ~pwm_1  &  pwm_1_prev;
wire pwm_2_set  =  pwm_2  & ~pwm_2_prev;
wire pwm_2_clr  = ~pwm_2  &  pwm_2_prev;
wire pwm_3_set  =  pwm_3  & ~pwm_3_prev;
wire pwm_3_clr  = ~pwm_3  &  pwm_3_prev;
wire pwm_4_set  =  pwm_4  & ~pwm_4_prev;
wire pwm_4_clr  = ~pwm_4  &  pwm_4_prev;
wire pwm_5_set  =  pwm_5  & ~pwm_5_prev;
wire pwm_5_clr  = ~pwm_5  &  pwm_5_prev;
wire pwm_6_set  =  pwm_6  & ~pwm_6_prev;
wire pwm_6_clr  = ~pwm_6  &  pwm_6_prev;
wire pwm_7_set  =  pwm_7  & ~pwm_7_prev;
wire pwm_7_clr  = ~pwm_7  &  pwm_7_prev;
wire pwm_8_set  =  pwm_8  & ~pwm_8_prev;
wire pwm_8_clr  = ~pwm_8  &  pwm_8_prev;
wire pwm_9_set  =  pwm_9  & ~pwm_9_prev;
wire pwm_9_clr  = ~pwm_9  &  pwm_9_prev;
wire pwm_10_set =  pwm_10 & ~pwm_10_prev;
wire pwm_10_clr = ~pwm_10 &  pwm_10_prev;
wire pwm_11_set =  pwm_11 & ~pwm_11_prev;
wire pwm_11_clr = ~pwm_11 &  pwm_11_prev;
wire pwm_12_set =  pwm_12 & ~pwm_12_prev;
wire pwm_12_clr = ~pwm_12 &  pwm_12_prev;
wire pwm_13_set =  pwm_13 & ~pwm_13_prev;
wire pwm_13_clr = ~pwm_13 &  pwm_13_prev;
wire pwm_14_set =  pwm_14 & ~pwm_14_prev;
wire pwm_14_clr = ~pwm_14 &  pwm_14_prev;
wire pwm_15_set =  pwm_15 & ~pwm_15_prev;
wire pwm_15_clr = ~pwm_15 &  pwm_15_prev;
wire pwm_16_set =  pwm_16 & ~pwm_16_prev;
wire pwm_16_clr = ~pwm_16 &  pwm_16_prev;
wire pwm_17_set =  pwm_17 & ~pwm_17_prev;
wire pwm_17_clr = ~pwm_17 &  pwm_17_prev;
wire pwm_18_set =  pwm_18 & ~pwm_18_prev;
wire pwm_18_clr = ~pwm_18 &  pwm_18_prev;
wire pwm_19_set =  pwm_19 & ~pwm_19_prev;
wire pwm_19_clr = ~pwm_19 &  pwm_19_prev;
wire pwm_20_set =  pwm_20 & ~pwm_20_prev;
wire pwm_20_clr = ~pwm_20 &  pwm_20_prev;
wire pwm_21_set =  pwm_21 & ~pwm_21_prev;
wire pwm_21_clr = ~pwm_21 &  pwm_21_prev;
wire pwm_22_set =  pwm_22 & ~pwm_22_prev;
wire pwm_22_clr = ~pwm_22 &  pwm_22_prev;

assign o_pwm_1_lo = rstn & pwm_1_lo;
assign o_pwm_1_hi = rstn & pwm_1_hi;
assign o_pwm_2_lo = rstn & pwm_2_lo;
assign o_pwm_2_hi = rstn & pwm_2_hi;
assign o_pwm_3_lo = rstn & pwm_3_lo;
assign o_pwm_3_hi = rstn & pwm_3_hi;
assign o_pwm_4_lo = rstn & pwm_4_lo;
assign o_pwm_4_hi = rstn & pwm_4_hi;
assign o_pwm_5_lo = rstn & pwm_5_lo;
assign o_pwm_5_hi = rstn & pwm_5_hi;
assign o_pwm_6_lo = rstn & pwm_6_lo;
assign o_pwm_6_hi = rstn & pwm_6_hi;
assign o_pwm_7_lo = rstn & pwm_7_lo;
assign o_pwm_7_hi = rstn & pwm_7_hi;
assign o_pwm_8_lo = rstn & pwm_8_lo;
assign o_pwm_8_hi = rstn & pwm_8_hi;
assign o_pwm_9_lo = rstn & pwm_9_lo;
assign o_pwm_9_hi = rstn & pwm_9_hi;
assign o_pwm_10_lo = rstn & pwm_10_lo;
assign o_pwm_10_hi = rstn & pwm_10_hi;
assign o_pwm_11_lo = rstn & pwm_11_lo;
assign o_pwm_11_hi = rstn & pwm_11_hi;
assign o_pwm_12_lo = rstn & pwm_12_lo;
assign o_pwm_12_hi = rstn & pwm_12_hi;
assign o_pwm_13_lo = rstn & pwm_13_lo;
assign o_pwm_13_hi = rstn & pwm_13_hi;
assign o_pwm_14_lo = rstn & pwm_14_lo;
assign o_pwm_14_hi = rstn & pwm_14_hi;
assign o_pwm_15_lo = rstn & pwm_15_lo;
assign o_pwm_15_hi = rstn & pwm_15_hi;
assign o_pwm_16_lo = rstn & pwm_16_lo;
assign o_pwm_16_hi = rstn & pwm_16_hi;
assign o_pwm_17_lo = rstn & pwm_17_lo;
assign o_pwm_17_hi = rstn & pwm_17_hi;
assign o_pwm_18_lo = rstn & pwm_18_lo;
assign o_pwm_18_hi = rstn & pwm_18_hi;
assign o_pwm_19_lo = rstn & pwm_19_lo;
assign o_pwm_19_hi = rstn & pwm_19_hi;
assign o_pwm_20_lo = rstn & pwm_20_lo;
assign o_pwm_20_hi = rstn & pwm_20_hi;
assign o_pwm_21_lo = rstn & pwm_21_lo;
assign o_pwm_21_hi = rstn & pwm_21_hi;
assign o_pwm_22_lo = rstn & pwm_22_lo;
assign o_pwm_22_hi = rstn & pwm_22_hi;

always @ (posedge clk)
begin
	if (pwm_1_set) pwm_1_set_cnt <= DEADTIME_LH;
	if (pwm_1_clr) pwm_1_clr_cnt <= DEADTIME_HL;
	if (pwm_1_set_cnt > 6'd0) pwm_1_set_cnt <= pwm_1_set_cnt - 6'd1;
	if (pwm_1_clr_cnt > 6'd0) pwm_1_clr_cnt <= pwm_1_clr_cnt - 6'd1;
	pwm_1_lo <= ~pwm_1_prev ^ (pwm_1_clr_cnt > 6'd0);
	pwm_1_hi <= pwm_1_prev ^ (pwm_1_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_2_set) pwm_2_set_cnt <= DEADTIME_LH;
	if (pwm_2_clr) pwm_2_clr_cnt <= DEADTIME_HL;
	if (pwm_2_set_cnt > 6'd0) pwm_2_set_cnt <= pwm_2_set_cnt - 6'd1;
	if (pwm_2_clr_cnt > 6'd0) pwm_2_clr_cnt <= pwm_2_clr_cnt - 6'd1;
	pwm_2_lo <= ~pwm_2_prev ^ (pwm_2_clr_cnt > 6'd0);
	pwm_2_hi <= pwm_2_prev ^ (pwm_2_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_3_set) pwm_3_set_cnt <= DEADTIME_LH;
	if (pwm_3_clr) pwm_3_clr_cnt <= DEADTIME_HL;
	if (pwm_3_set_cnt > 6'd0) pwm_3_set_cnt <= pwm_3_set_cnt - 6'd1;
	if (pwm_3_clr_cnt > 6'd0) pwm_3_clr_cnt <= pwm_3_clr_cnt - 6'd1;
	pwm_3_lo <= ~pwm_3_prev ^ (pwm_3_clr_cnt > 6'd0);
	pwm_3_hi <= pwm_3_prev ^ (pwm_3_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_4_set) pwm_4_set_cnt <= DEADTIME_LH;
	if (pwm_4_clr) pwm_4_clr_cnt <= DEADTIME_HL;
	if (pwm_4_set_cnt > 6'd0) pwm_4_set_cnt <= pwm_4_set_cnt - 6'd1;
	if (pwm_4_clr_cnt > 6'd0) pwm_4_clr_cnt <= pwm_4_clr_cnt - 6'd1;
	pwm_4_lo <= ~pwm_4_prev ^ (pwm_4_clr_cnt > 6'd0);
	pwm_4_hi <= pwm_4_prev ^ (pwm_4_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_5_set) pwm_5_set_cnt <= DEADTIME_LH;
	if (pwm_5_clr) pwm_5_clr_cnt <= DEADTIME_HL;
	if (pwm_5_set_cnt > 6'd0) pwm_5_set_cnt <= pwm_5_set_cnt - 6'd1;
	if (pwm_5_clr_cnt > 6'd0) pwm_5_clr_cnt <= pwm_5_clr_cnt - 6'd1;
	pwm_5_lo <= ~pwm_5_prev ^ (pwm_5_clr_cnt > 6'd0);
	pwm_5_hi <= pwm_5_prev ^ (pwm_5_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_6_set) pwm_6_set_cnt <= DEADTIME_LH;
	if (pwm_6_clr) pwm_6_clr_cnt <= DEADTIME_HL;
	if (pwm_6_set_cnt > 6'd0) pwm_6_set_cnt <= pwm_6_set_cnt - 6'd1;
	if (pwm_6_clr_cnt > 6'd0) pwm_6_clr_cnt <= pwm_6_clr_cnt - 6'd1;
	pwm_6_lo <= ~pwm_6_prev ^ (pwm_6_clr_cnt > 6'd0);
	pwm_6_hi <= pwm_6_prev ^ (pwm_6_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_7_set) pwm_7_set_cnt <= DEADTIME_LH;
	if (pwm_7_clr) pwm_7_clr_cnt <= DEADTIME_HL;
	if (pwm_7_set_cnt > 6'd0) pwm_7_set_cnt <= pwm_7_set_cnt - 6'd1;
	if (pwm_7_clr_cnt > 6'd0) pwm_7_clr_cnt <= pwm_7_clr_cnt - 6'd1;
	pwm_7_lo <= ~pwm_7_prev ^ (pwm_7_clr_cnt > 6'd0);
	pwm_7_hi <= pwm_7_prev ^ (pwm_7_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_8_set) pwm_8_set_cnt <= DEADTIME_LH;
	if (pwm_8_clr) pwm_8_clr_cnt <= DEADTIME_HL;
	if (pwm_8_set_cnt > 6'd0) pwm_8_set_cnt <= pwm_8_set_cnt - 6'd1;
	if (pwm_8_clr_cnt > 6'd0) pwm_8_clr_cnt <= pwm_8_clr_cnt - 6'd1;
	pwm_8_lo <= ~pwm_8_prev ^ (pwm_8_clr_cnt > 6'd0);
	pwm_8_hi <= pwm_8_prev ^ (pwm_8_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_9_set) pwm_9_set_cnt <= DEADTIME_LH;
	if (pwm_9_clr) pwm_9_clr_cnt <= DEADTIME_HL;
	if (pwm_9_set_cnt > 6'd0) pwm_9_set_cnt <= pwm_9_set_cnt - 6'd1;
	if (pwm_9_clr_cnt > 6'd0) pwm_9_clr_cnt <= pwm_9_clr_cnt - 6'd1;
	pwm_9_lo <= ~pwm_9_prev ^ (pwm_9_clr_cnt > 6'd0);
	pwm_9_hi <= pwm_9_prev ^ (pwm_9_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_10_set) pwm_10_set_cnt <= DEADTIME_LH;
	if (pwm_10_clr) pwm_10_clr_cnt <= DEADTIME_HL;
	if (pwm_10_set_cnt > 6'd0) pwm_10_set_cnt <= pwm_10_set_cnt - 6'd1;
	if (pwm_10_clr_cnt > 6'd0) pwm_10_clr_cnt <= pwm_10_clr_cnt - 6'd1;
	pwm_10_lo <= ~pwm_10_prev ^ (pwm_10_clr_cnt > 6'd0);
	pwm_10_hi <= pwm_10_prev ^ (pwm_10_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_11_set) pwm_11_set_cnt <= DEADTIME_LH;
	if (pwm_11_clr) pwm_11_clr_cnt <= DEADTIME_HL;
	if (pwm_11_set_cnt > 6'd0) pwm_11_set_cnt <= pwm_11_set_cnt - 6'd1;
	if (pwm_11_clr_cnt > 6'd0) pwm_11_clr_cnt <= pwm_11_clr_cnt - 6'd1;
	pwm_11_lo <= ~pwm_11_prev ^ (pwm_11_clr_cnt > 6'd0);
	pwm_11_hi <= pwm_11_prev ^ (pwm_11_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_12_set) pwm_12_set_cnt <= DEADTIME_LH;
	if (pwm_12_clr) pwm_12_clr_cnt <= DEADTIME_HL;
	if (pwm_12_set_cnt > 6'd0) pwm_12_set_cnt <= pwm_12_set_cnt - 6'd1;
	if (pwm_12_clr_cnt > 6'd0) pwm_12_clr_cnt <= pwm_12_clr_cnt - 6'd1;
	pwm_12_lo <= ~pwm_12_prev ^ (pwm_12_clr_cnt > 6'd0);
	pwm_12_hi <= pwm_12_prev ^ (pwm_12_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_13_set) pwm_13_set_cnt <= DEADTIME_LH;
	if (pwm_13_clr) pwm_13_clr_cnt <= DEADTIME_HL;
	if (pwm_13_set_cnt > 6'd0) pwm_13_set_cnt <= pwm_13_set_cnt - 6'd1;
	if (pwm_13_clr_cnt > 6'd0) pwm_13_clr_cnt <= pwm_13_clr_cnt - 6'd1;
	pwm_13_lo <= ~pwm_13_prev ^ (pwm_13_clr_cnt > 6'd0);
	pwm_13_hi <= pwm_13_prev ^ (pwm_13_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_14_set) pwm_14_set_cnt <= DEADTIME_LH;
	if (pwm_14_clr) pwm_14_clr_cnt <= DEADTIME_HL;
	if (pwm_14_set_cnt > 6'd0) pwm_14_set_cnt <= pwm_14_set_cnt - 6'd1;
	if (pwm_14_clr_cnt > 6'd0) pwm_14_clr_cnt <= pwm_14_clr_cnt - 6'd1;
	pwm_14_lo <= ~pwm_14_prev ^ (pwm_14_clr_cnt > 6'd0);
	pwm_14_hi <= pwm_14_prev ^ (pwm_14_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_15_set) pwm_15_set_cnt <= DEADTIME_LH;
	if (pwm_15_clr) pwm_15_clr_cnt <= DEADTIME_HL;
	if (pwm_15_set_cnt > 6'd0) pwm_15_set_cnt <= pwm_15_set_cnt - 6'd1;
	if (pwm_15_clr_cnt > 6'd0) pwm_15_clr_cnt <= pwm_15_clr_cnt - 6'd1;
	pwm_15_lo <= ~pwm_15_prev ^ (pwm_15_clr_cnt > 6'd0);
	pwm_15_hi <= pwm_15_prev ^ (pwm_15_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_16_set) pwm_16_set_cnt <= DEADTIME_LH;
	if (pwm_16_clr) pwm_16_clr_cnt <= DEADTIME_HL;
	if (pwm_16_set_cnt > 6'd0) pwm_16_set_cnt <= pwm_16_set_cnt - 6'd1;
	if (pwm_16_clr_cnt > 6'd0) pwm_16_clr_cnt <= pwm_16_clr_cnt - 6'd1;
	pwm_16_lo <= ~pwm_16_prev ^ (pwm_16_clr_cnt > 6'd0);
	pwm_16_hi <= pwm_16_prev ^ (pwm_16_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_17_set) pwm_17_set_cnt <= DEADTIME_LH;
	if (pwm_17_clr) pwm_17_clr_cnt <= DEADTIME_HL;
	if (pwm_17_set_cnt > 6'd0) pwm_17_set_cnt <= pwm_17_set_cnt - 6'd1;
	if (pwm_17_clr_cnt > 6'd0) pwm_17_clr_cnt <= pwm_17_clr_cnt - 6'd1;
	pwm_17_lo <= ~pwm_17_prev ^ (pwm_17_clr_cnt > 6'd0);
	pwm_17_hi <= pwm_17_prev ^ (pwm_17_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_18_set) pwm_18_set_cnt <= DEADTIME_LH;
	if (pwm_18_clr) pwm_18_clr_cnt <= DEADTIME_HL;
	if (pwm_18_set_cnt > 6'd0) pwm_18_set_cnt <= pwm_18_set_cnt - 6'd1;
	if (pwm_18_clr_cnt > 6'd0) pwm_18_clr_cnt <= pwm_18_clr_cnt - 6'd1;
	pwm_18_lo <= ~pwm_18_prev ^ (pwm_18_clr_cnt > 6'd0);
	pwm_18_hi <= pwm_18_prev ^ (pwm_18_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_19_set) pwm_19_set_cnt <= DEADTIME_LH;
	if (pwm_19_clr) pwm_19_clr_cnt <= DEADTIME_HL;
	if (pwm_19_set_cnt > 6'd0) pwm_19_set_cnt <= pwm_19_set_cnt - 6'd1;
	if (pwm_19_clr_cnt > 6'd0) pwm_19_clr_cnt <= pwm_19_clr_cnt - 6'd1;
	pwm_19_lo <= ~pwm_19_prev ^ (pwm_19_clr_cnt > 6'd0);
	pwm_19_hi <= pwm_19_prev ^ (pwm_19_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_20_set) pwm_20_set_cnt <= DEADTIME_LH;
	if (pwm_20_clr) pwm_20_clr_cnt <= DEADTIME_HL;
	if (pwm_20_set_cnt > 6'd0) pwm_20_set_cnt <= pwm_20_set_cnt - 6'd1;
	if (pwm_20_clr_cnt > 6'd0) pwm_20_clr_cnt <= pwm_20_clr_cnt - 6'd1;
	pwm_20_lo <= ~pwm_20_prev ^ (pwm_20_clr_cnt > 6'd0);
	pwm_20_hi <= pwm_20_prev ^ (pwm_20_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_21_set) pwm_21_set_cnt <= DEADTIME_LH;
	if (pwm_21_clr) pwm_21_clr_cnt <= DEADTIME_HL;
	if (pwm_21_set_cnt > 6'd0) pwm_21_set_cnt <= pwm_21_set_cnt - 6'd1;
	if (pwm_21_clr_cnt > 6'd0) pwm_21_clr_cnt <= pwm_21_clr_cnt - 6'd1;
	pwm_21_lo <= ~pwm_21_prev ^ (pwm_21_clr_cnt > 6'd0);
	pwm_21_hi <= pwm_21_prev ^ (pwm_21_set_cnt > 6'd0);
end

always @ (posedge clk)
begin
	if (pwm_22_set) pwm_22_set_cnt <= DEADTIME_LH;
	if (pwm_22_clr) pwm_22_clr_cnt <= DEADTIME_HL;
	if (pwm_22_set_cnt > 6'd0) pwm_22_set_cnt <= pwm_22_set_cnt - 6'd1;
	if (pwm_22_clr_cnt > 6'd0) pwm_22_clr_cnt <= pwm_22_clr_cnt - 6'd1;
	pwm_22_lo <= ~pwm_22_prev ^ (pwm_22_clr_cnt > 6'd0);
	pwm_22_hi <= pwm_22_prev ^ (pwm_22_set_cnt > 6'd0);
end

always @(posedge clk)
begin
	pwm_1_prev  <= pwm_1;
	pwm_2_prev  <= pwm_2;
	pwm_3_prev  <= pwm_3;
	pwm_4_prev  <= pwm_4;
	pwm_5_prev  <= pwm_5;
	pwm_6_prev  <= pwm_6;
	pwm_7_prev  <= pwm_7;
	pwm_8_prev  <= pwm_8;
	pwm_9_prev  <= pwm_9;
	pwm_10_prev <= pwm_10;
	pwm_11_prev <= pwm_11;
	pwm_12_prev <= pwm_12;
	pwm_13_prev <= pwm_13;
	pwm_14_prev <= pwm_14;
	pwm_15_prev <= pwm_15;
	pwm_16_prev <= pwm_16;
	pwm_17_prev <= pwm_17;
	pwm_18_prev <= pwm_18;
	pwm_19_prev <= pwm_19;
	pwm_20_prev <= pwm_20;
	pwm_21_prev <= pwm_21;
	pwm_22_prev <= pwm_22;
end

endmodule
