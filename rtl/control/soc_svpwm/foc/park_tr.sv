
// 模块： park_tr
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// 功能： park 变换器

module park_tr #(
	parameter LM10_WIDTH  = `ENCODER_BIT,
	parameter LM10_COUNTS = `ENCODER_BIT'd6400,
	parameter ADC_BITS = 12
) (
	input  wire               				rstn,
	input  wire               				clk,
	input  wire			 [LM10_WIDTH-1:0]	psi,
	input  wire               				i_en,
	input  wire signed [ADC_BITS+5:0]	i_ialpha, i_ibeta,
	output reg                				o_en,
	output reg  signed [ADC_BITS+5:0] 	o_id, o_iq
);

reg  signed [18:0] sin_psi, cos_psi;  // -1~+1 is mapped to -262143~+262143

reg                en_s1;
reg  signed [ADC_BITS+24:0] alpha_cos, alpha_sin, beta_cos, beta_sin;

wire signed [ADC_BITS+24:0] ide = alpha_cos + beta_sin;
wire signed [ADC_BITS+24:0] iqe = beta_cos  - alpha_sin;

sincos #(
	.LM10_WIDTH  ( LM10_WIDTH  ),  
	.LM10_COUNTS ( LM10_COUNTS )
) sincos_i (
	.rstn        ( rstn        ),
	.clk         ( clk         ),
	.i_en        ( 1'b1        ),
	.i_theta     ( psi         ),
	.o_en        (             ),
	.o_sin       ( sin_psi     ),
	.o_cos       ( cos_psi     )
);

always @ (posedge clk or negedge rstn)
begin
	if (~rstn) begin
		{en_s1, alpha_cos, alpha_sin, beta_cos, beta_sin} <= '0;
	end else begin
		en_s1 <= i_en;
		alpha_cos <= i_ialpha * cos_psi;
		alpha_sin <= i_ialpha * sin_psi;
		beta_cos  <= i_ibeta  * cos_psi;
		beta_sin  <= i_ibeta  * sin_psi;
	end
end

always @ (posedge clk or negedge rstn)
begin
	if (~rstn) begin
		{o_en, o_id, o_iq} <= '0;
	end else begin
		o_en <= en_s1;
		if (en_s1) begin
			o_id <= ide[ADC_BITS+23:18];
			o_iq <= iqe[ADC_BITS+23:18];
		end
	end
end

endmodule
