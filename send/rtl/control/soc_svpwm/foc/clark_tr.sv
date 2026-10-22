
// clark_tr 
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// 功能： clark 变换

module clark_tr #(
	parameter ADC_BITS = 12
) (
	input  wire               			 rstn,
	input  wire               			 clk,
	input  wire               			 i_en,
	input  wire signed [ADC_BITS+1:0] i_i1, i_i2, i_i3, i_i4, i_i5, i_i6, i_i7, i_i8, i_i9, i_i10, i_i11,   // range -8192 ~ 8190
	output reg                			 o_en,
	output reg  signed [ADC_BITS+5:0] o_ialpha, o_ibeta
);

// registers for pipeline stage 1
reg               		 	en_s1;
reg signed [ADC_BITS+1:0]	i1_s1;
reg signed [ADC_BITS+2:0]	i2pi11_s1, i3pi10_s1, i4pi9_s1, i5pi8_s1, i6pi7_s1;
reg signed [ADC_BITS+2:0]	i2mi11_s1, i3mi10_s1, i4mi9_s1, i5mi8_s1, i6mi7_s1;

// registers for pipeline stage 2
reg               		   en_s2;
reg signed [ADC_BITS+20:0] i2pi11_s2, i3pi10_s2, i4pi9_s2, i5pi8_s2, i6pi7_s2;
reg signed [ADC_BITS+20:0] i2mi11_s2, i3mi10_s2, i4mi9_s2, i5mi8_s2, i6mi7_s2;

reg signed [ADC_BITS+23:0]	o_ialpha_temp;
reg signed [ADC_BITS+23:0]	o_ibeta_temp;

assign o_ialpha = o_ialpha_temp[ADC_BITS+22:17];
assign o_ibeta = o_ibeta_temp[ADC_BITS+22:17];

// pipeline stage 1
always @ (posedge clk or negedge rstn)
begin
	if (~rstn) begin
		{en_s1, i1_s1} <= '0;
		{i2pi11_s1, i3pi10_s1, i4pi9_s1, i5pi8_s1, i6pi7_s1} <= '0;
		{i2mi11_s1, i3mi10_s1, i4mi9_s1, i5mi8_s1, i6mi7_s1} <= '0;
	end else begin
		en_s1 <= i_en;
		i1_s1 <= i_i1;
		i2pi11_s1 <= 15'(i_i2 + i_i11);
		i3pi10_s1 <= 15'(i_i3 + i_i10);
		i4pi9_s1  <= 15'(i_i4 + i_i9);
		i5pi8_s1  <= 15'(i_i5 + i_i8);
		i6pi7_s1  <= 15'(i_i6 + i_i7);
		i2mi11_s1 <= 15'(i_i2 - i_i11);
		i3mi10_s1 <= 15'(i_i3 - i_i10);
		i4mi9_s1  <= 15'(i_i4 - i_i9);
		i5mi8_s1  <= 15'(i_i5 - i_i8);
		i6mi7_s1  <= 15'(i_i6 - i_i7);
	end
end

// pipeline stage 2
always @ (posedge clk or negedge rstn)
begin
	if (~rstn) begin
		en_s2 <= '0;
		{i2pi11_s2, i3pi10_s2, i4pi9_s2, i5pi8_s2, i6pi7_s2} <= '0;
		{i2mi11_s2, i3mi10_s2, i4mi9_s2, i5mi8_s2, i6mi7_s2} <= '0;
	end else begin
		en_s2 <= en_s1;
		// multiply decimal number 0.841253532831181 in 18bit fixed point
		i2pi11_s2 <= i2pi11_s1 * 19'sd220530;
		// multiply decimal number 0.415415013001886 in 18bit fixed point
		i3pi10_s2 <= i3pi10_s1 * 19'sd108899;
		// multiply decimal number 0.142314838273285 in 18bit fixed point
		i4pi9_s2  <= i4pi9_s1  * 19'sd37307;
		// multiply decimal number 0.654860733945285 in 18bit fixed point
		i5pi8_s2  <= i5pi8_s1  * 19'sd171668;
		// multiply decimal number 0.959492973614497 in 18bit fixed point
		i6pi7_s2  <= i6pi7_s1  * 19'sd251525;
		
		// multiply decimal number 0.540640817455598 in 18bit fixed point
		i2mi11_s2 <= i2mi11_s1 * 19'sd141726;
		// multiply decimal number 0.909631995354518 in 18bit fixed point
		i3mi10_s2 <= i3mi10_s1 * 19'sd238455;
		// multiply decimal number 0.989821441880933 in 18bit fixed point
		i4mi9_s2  <= i4mi9_s1  * 19'sd259476;
		// multiply decimal number 0.755749574354258 in 18bit fixed point
		i5mi8_s2  <= i5mi8_s1  * 19'sd198115;
		// multiply decimal number 0.281732556841430 in 18bit fixed point
		i6mi7_s2  <= i6mi7_s1  * 19'sd73854;
	end
end

// pipeline stage output
always @ (posedge clk or negedge rstn)
begin
	if (~rstn) begin
		o_en <= 1'b0;
		o_ialpha_temp <= '0;
		o_ibeta_temp <= '0;
	end else begin
		o_en <= en_s2;
		o_ialpha_temp <= ($signed({i1_s1, 18'b0}) + i2pi11_s2) + (i3pi10_s2 - i4pi9_s2) - (i5pi8_s2 + i6pi7_s2);
		o_ibeta_temp <= (i2mi11_s2 + i3mi10_s2) + (i4mi9_s2 + i5mi8_s2) + i6mi7_s2;
	end
end

endmodule

