//============================================================
// File       : measure_top.sv
// Description: Top-level module for multi-channel ADC measurement
// Author     : Bin Wang
//============================================================

module measure_top #(
    parameter int ADC_BITS     = 12,    // ADC resolution in bits
    parameter int ADC_CLK_NS   = 20,    // ADC clock period in nanoseconds
    parameter int LM10_WIDTH   = 13,    // LM10 encoder width
    parameter int LM10_COUNTS  = 6400   // LM10 counts per revolution
) (
    //============================================================
    // Clock inputs
    //============================================================
    input  logic clk_50m,      // 50 MHz main clock
    input  logic clk_100m,     // 100 MHz DDR clock

    //============================================================
    // LVDS interface IO
    //============================================================
    input  logic [5:0] lvds_data,    // 6 LVDS data input lines
    output logic [5:0] lvds_clk,     // 6 LVDS clock output lines
    output logic       cnv,          // ADC convert start signal

    //============================================================
    // LM10 encoder IO
    //============================================================
    input  logic LM10_encoder_a,
    input  logic LM10_encoder_b,
    input  logic LM10_encoder_z,
    
    //============================================================
    // LM10 encoder result outputs
    //============================================================
    output logic LM10_encoder_ref_ready,
    output logic [LM10_WIDTH-1:0] LM10_encoder_regout, // LM10 register output
    output logic signed [15:0] LM10_rpm,                      // LM10 RPM output

    //============================================================
    // ADC raw result outputs (22 channels)
    //============================================================
    output logic signed [ADC_BITS:0] adc_value [0:21]
);

    //============================================================
    // Internal signals
    //============================================================
    logic sn_adc;                 // Start conversion pulse
    logic en_adc;                 // Conversion done pulse (1 clock cycle high)
    logic [6:0] cnt_cursamp;      // Sampling counter

    //============================================================
    // LM10 Encoder module instance
    //============================================================
    LM10_encoder_read #(
        .LM10_WIDTH  (LM10_WIDTH),
        .LM10_COUNTS (LM10_COUNTS)
    ) u_LM10_encoder_read (
        .clk       (clk_50m),
        .a         (LM10_encoder_a),
        .b         (LM10_encoder_b),
        .z         (LM10_encoder_z),
        .ref_ready (LM10_encoder_ref_ready),
        .regout    (LM10_encoder_regout),
        .rpm       (LM10_rpm)
    );

    //============================================================
    // Current sensor module instance
    //============================================================
    current_sensor #(
        .ADC_BITS   (ADC_BITS),
        .ADC_CLK_NS (ADC_CLK_NS)
    ) u_current_sensor (
        // Clock inputs
        .clk           (clk_50m),
        .ddr_clk       (clk_100m),

        // LVDS data inputs
        .lvds_data_in1 (lvds_data[0]),
        .lvds_data_in2 (lvds_data[1]),
        .lvds_data_in3 (lvds_data[2]),
        .lvds_data_in4 (lvds_data[3]),
        .lvds_data_in5 (lvds_data[4]),
        .lvds_data_in6 (lvds_data[5]),

        // LVDS clock outputs
        .lvds_clk_out1 (lvds_clk[0]),
        .lvds_clk_out2 (lvds_clk[1]),
        .lvds_clk_out3 (lvds_clk[2]),
        .lvds_clk_out4 (lvds_clk[3]),
        .lvds_clk_out5 (lvds_clk[4]),
        .lvds_clk_out6 (lvds_clk[5]),

        // Conversion control
        .cnv           (cnv),
        .i_sn_adc      (sn_adc),
        .o_en_adc      (en_adc),

        // ADC channel outputs (22 channels)
        .o_adc_value1  (adc_value[0]),
        .o_adc_value2  (adc_value[1]),
        .o_adc_value3  (adc_value[2]),
        .o_adc_value4  (adc_value[3]),
        .o_adc_value5  (adc_value[4]),
        .o_adc_value6  (adc_value[5]),
        .o_adc_value7  (adc_value[6]),
        .o_adc_value8  (adc_value[7]),
        .o_adc_value9  (adc_value[8]),
        .o_adc_value10 (adc_value[9]),
        .o_adc_value11 (adc_value[10]),
        .o_adc_value12 (adc_value[11]),
        .o_adc_value13 (adc_value[12]),
        .o_adc_value14 (adc_value[13]),
        .o_adc_value15 (adc_value[14]),
        .o_adc_value16 (adc_value[15]),
        .o_adc_value17 (adc_value[16]),
        .o_adc_value18 (adc_value[17]),
        .o_adc_value19 (adc_value[18]),
        .o_adc_value20 (adc_value[19]),
        .o_adc_value21 (adc_value[20]),
        .o_adc_value22 (adc_value[21])
    );

    //============================================================
    // Sampling trigger counter instance
    //============================================================
    trig_cursamp_cnt u_trig_cursamp_cnt (
        .clock (clk_50m),
        .q     (cnt_cursamp)
    );

    //============================================================
    // Generate sn_adc pulse when counter reaches 98
    // This triggers the current sensor ADC conversion
    //============================================================
    always_ff @(posedge clk_50m) begin
        sn_adc <= (cnt_cursamp == 7'd98);
    end

endmodule
