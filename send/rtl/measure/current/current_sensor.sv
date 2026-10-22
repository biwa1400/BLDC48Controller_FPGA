
// 模块: current_sensor
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// 功能： read all 22 phase currents

module current_sensor #(
	parameter ADC_BITS   = 12,
	parameter ADC_CLK_NS = 20
) (
	input  wire clk,
	input  wire ddr_clk,
	input  wire lvds_data_in1,
	input  wire lvds_data_in2,
	input  wire lvds_data_in3,
	input  wire lvds_data_in4,
	input  wire lvds_data_in5,
	input  wire lvds_data_in6,
	output wire lvds_clk_out1,
	output wire lvds_clk_out2,
	output wire lvds_clk_out3,
	output wire lvds_clk_out4,
	output wire lvds_clk_out5,
	output wire lvds_clk_out6,
	output wire cnv,
	// -------------------- 用户逻辑接口  ------------------------------------------------------------------------------------
	input  wire        					 i_sn_adc,    // ADC 转换开始信号，当 i_sn_adc 上出现高电平脉冲时，ADC转换开始
	output wire         					 o_en_adc,    // ADC 转换完成信号，当转换完成时，o_en_adc 产生一个时钟周期的高电平脉冲
	output wire signed [ADC_BITS:0] o_adc_value1,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH1 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value2,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH2 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value3,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH3 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value4,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH4 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value5,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH5 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value6,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH6 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value7,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH7 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value8,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH8 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value9,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH9 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value10,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH10 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value11,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH11 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value12,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH12 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value13,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH13 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value14,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH14 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value15,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH15 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value16,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH16 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value17,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH17 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value18,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH18 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value19,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH19 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value20,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH20 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value21,// 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH21 的 ADC 转换结果出现在该信号上
	output wire signed [ADC_BITS:0] o_adc_value22 // 当 o_en_adc 产生一个时钟周期的高电平脉冲时，CH22 的 ADC 转换结果出现在该信号上
);

adc_ltc2320 #(
	.ADC_BITS		( ADC_BITS		  ),
	.ADC_CLK_NS		( ADC_CLK_NS	  )
) adc_ltc2320_1 (
	.clk				( clk					),
	.ddr_clk			( ddr_clk		   ),
	.lvds_data_in	( lvds_data_in1	),
	.lvds_clk_out	( lvds_clk_out1	),
	.cnv				( cnv					),
	.i_sn_adc		( i_sn_adc			),
	.o_en_adc		( o_en_adc			),
	.o_adc_value1	( o_adc_value4		),
	.o_adc_value2	( o_adc_value5		),
	.o_adc_value3	( o_adc_value6		),
	.o_adc_value4	( 						)
);

adc_ltc2320 #(
	.ADC_BITS		( ADC_BITS		  ),
	.ADC_CLK_NS		( ADC_CLK_NS	  )
) adc_ltc2320_2 (
	.clk				( clk					),
	.ddr_clk			( ddr_clk		   ),
	.lvds_data_in	( lvds_data_in2	),
	.lvds_clk_out	( lvds_clk_out2	),
	.cnv				( 						),
	.i_sn_adc		( i_sn_adc			),
	.o_en_adc		( 						),
	.o_adc_value1	( o_adc_value1		),
	.o_adc_value2	( o_adc_value2		),
	.o_adc_value3	( o_adc_value3		),
	.o_adc_value4	( 						)
);

adc_ltc2320 #(
	.ADC_BITS		( ADC_BITS		  ),
	.ADC_CLK_NS		( ADC_CLK_NS	  )
) adc_ltc2320_3 (
	.clk				( clk					),
	.ddr_clk			( ddr_clk		   ),
	.lvds_data_in	( lvds_data_in3	),
	.lvds_clk_out	( lvds_clk_out3	),
	.cnv				( 						),
	.i_sn_adc		( i_sn_adc			),
	.o_en_adc		( 						),
	.o_adc_value1	( o_adc_value7		),
	.o_adc_value2	( o_adc_value8		),
	.o_adc_value3	( o_adc_value9		),
	.o_adc_value4	( o_adc_value10	)
);

adc_ltc2320 #(
	.ADC_BITS		( ADC_BITS		  ),
	.ADC_CLK_NS		( ADC_CLK_NS	  )
) adc_ltc2320_4 (
	.clk				( clk					),
	.ddr_clk			( ddr_clk		   ),
	.lvds_data_in	( lvds_data_in4	),
	.lvds_clk_out	( lvds_clk_out4	),
	.cnv				( 						),
	.i_sn_adc		( i_sn_adc			),
	.o_en_adc		( 						),
	.o_adc_value1	( o_adc_value11	),
	.o_adc_value2	( o_adc_value12	),
	.o_adc_value3	( o_adc_value13	),
	.o_adc_value4	( o_adc_value14	)
);

adc_ltc2320 #(
	.ADC_BITS		( ADC_BITS		  ),
	.ADC_CLK_NS		( ADC_CLK_NS	  )
) adc_ltc2320_5 (
	.clk				( clk					),
	.ddr_clk			( ddr_clk		   ),
	.lvds_data_in	( lvds_data_in5	),
	.lvds_clk_out	( lvds_clk_out5	),
	.cnv				( 						),
	.i_sn_adc		( i_sn_adc			),
	.o_en_adc		( 						),
	.o_adc_value1	( o_adc_value19	),
	.o_adc_value2	( o_adc_value20	),
	.o_adc_value3	( o_adc_value21	),
	.o_adc_value4	( o_adc_value22	)
);

adc_ltc2320 #(
	.ADC_BITS		( ADC_BITS		  ),
	.ADC_CLK_NS		( ADC_CLK_NS	  )
) adc_ltc2320_6 (
	.clk				( clk					),
	.ddr_clk			( ddr_clk		   ),
	.lvds_data_in	( lvds_data_in6	),
	.lvds_clk_out	( lvds_clk_out6	),
	.cnv				( 						),
	.i_sn_adc		( i_sn_adc			),
	.o_en_adc		( 						),
	.o_adc_value1	( o_adc_value15	),
	.o_adc_value2	( o_adc_value16	),
	.o_adc_value3	( o_adc_value17	),
	.o_adc_value4	( o_adc_value18	)
);
	
endmodule 
