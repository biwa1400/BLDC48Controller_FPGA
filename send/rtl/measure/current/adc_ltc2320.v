
// 模块: adc_ltc2320
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// 功能：通过 LVDS 接口从 LTC2320 (ADC芯片) 中读出 ADC 值。

module adc_ltc2320 #(
	parameter ADC_BITS   = 12,
	parameter ADC_CLK_NS = 20
) (
	input  wire 							 clk,
	input  wire 							 ddr_clk,
	input  wire 							 lvds_data_in,
	output reg  							 lvds_clk_out= 1'b0,
	output reg	 							 cnv = 1'b1,
	input  wire        					 i_sn_adc,    // ADC 转换开始信号，当 i_sn_adc 上出现高电平脉冲时，ADC转换开始
	output reg         					 o_en_adc = 1'b0,    // ADC 转换完成信号，当转换完成时，o_en_adc 产生一个时钟周期的高电平脉冲
	output reg  signed [ADC_BITS:0] o_adc_value1,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH1 的 ADC 转换结果出现在该信号上
	output reg  signed [ADC_BITS:0] o_adc_value2,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH2 的 ADC 转换结果出现在该信号上
	output reg  signed [ADC_BITS:0] o_adc_value3,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH3 的 ADC 转换结果出现在该信号上
	output reg  signed [ADC_BITS:0] o_adc_value4 // 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH4 的 ADC 转换结果出现在该信号上
);

localparam integer
	COUNTER_WIDTH		 = 8,
	SAMPLE_BITS 		 = 128,
	DATA_BITS 			 = 16,
	DATA_CHNS 			 = SAMPLE_BITS / DATA_BITS,
	CONVERT_WAIT_NS    = 460, // LTC2320 needs 450ns of conversion time
	CONVERT_DONE_TIME  = (CONVERT_WAIT_NS - 1) / ADC_CLK_NS + 1,
	ACQUIRE_DONE_TIME  = CONVERT_DONE_TIME + SAMPLE_BITS/2,
	ACQUIRE_START_TIME = SAMPLE_BITS/2;

wire cnv_prior;
reg  acquire_finish = 1'b0;
reg  sck_output 	 = 1'b0;


//assign lvds_clk_out = clk & sck_output;

// counter
wire [COUNTER_WIDTH-1:0]adc_cnt_q;

// data buffer
reg [SAMPLE_BITS-1:0]read_data = '0;

wire [DATA_CHNS-1:0][DATA_BITS-1:0] adc_value = read_data;

lpm_counter	adc_cnt (
	.clock (clk),
	.cnt_en (!cnv_prior),
	.sclr (1'b0),
	.q (adc_cnt_q),
	.aclr (1'b0),
	.aload (1'b0),
	.aset (1'b0),
	.cin (1'b1),
	.clk_en (1'b1),
	.cout (cnv_prior),
	.data (ACQUIRE_DONE_TIME[COUNTER_WIDTH-1:0]),
	.eq (),
	.sload (i_sn_adc),
	.sset (1'b0));
defparam
	adc_cnt.lpm_direction = "DOWN",
	adc_cnt.lpm_type = "LPM_COUNTER",
	adc_cnt.lpm_width = COUNTER_WIDTH;


always @(posedge clk)
//always @(negedge clk)
begin
	if (adc_cnt_q == ACQUIRE_START_TIME[COUNTER_WIDTH-1:0])
		sck_output <= 1'b1;
	else if (cnv_prior)
		sck_output <= 1'b0;
end

always @(posedge clk)
begin
	if (cnv_prior & !cnv)
		acquire_finish <= 1'b1;
	else
		acquire_finish <= 1'b0;
end

always @(posedge ddr_clk)
begin
	if (sck_output)
		read_data <= {read_data[SAMPLE_BITS-2:0],lvds_data_in};
end

always @(posedge ddr_clk)
begin
	if (sck_output)
		lvds_clk_out <= ~lvds_clk_out;
	else
		lvds_clk_out <= 1'b0;
end

always @(posedge clk)
begin
	cnv <= cnv_prior;
end

always @(posedge clk)
begin
	if (acquire_finish) begin
		o_adc_value1 <= $signed(adc_value[6][DATA_BITS-1:DATA_BITS-ADC_BITS-1]) - $signed(adc_value[7][DATA_BITS-1:DATA_BITS-ADC_BITS-1]);
		o_adc_value2 <= $signed(adc_value[4][DATA_BITS-1:DATA_BITS-ADC_BITS-1]) - $signed(adc_value[5][DATA_BITS-1:DATA_BITS-ADC_BITS-1]);
		o_adc_value3 <= $signed(adc_value[2][DATA_BITS-1:DATA_BITS-ADC_BITS-1]) - $signed(adc_value[3][DATA_BITS-1:DATA_BITS-ADC_BITS-1]);
		o_adc_value4 <= $signed(adc_value[0][DATA_BITS-1:DATA_BITS-ADC_BITS-1]) - $signed(adc_value[1][DATA_BITS-1:DATA_BITS-ADC_BITS-1]);
		o_en_adc <= 1'b1;
	end else
		o_en_adc <= 1'b0;
end

endmodule 
