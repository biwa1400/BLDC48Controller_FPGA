//--------------------------------------------------------------
// Top-level Module: AC501_SoC_GHRD
// Description:
//   - Integrates HPS, DDR3, USB, SDIO, ADC, and LM10 encoder.
//   - Provides PWM outputs for MOSFETs (high-side and low-side).
//   - Packs ADC and encoder data into 108-byte DMA buffer for HPS.
//   - Provides 24 MHz clock output for USB3300.
//--------------------------------------------------------------
module AC501_SoC_GHRD (
    input  logic        clk_ext_50m,           // 50 MHz external input clock

    // -------------------- SDIO Interface --------------------
    inout  wire         hps_sdio_CMD,
    inout  wire         hps_sdio_D0,
    inout  wire         hps_sdio_D1,
    output logic        hps_sdio_CLK,
    inout  wire         hps_sdio_D2,
    inout  wire         hps_sdio_D3,

    // -------------------- USB1 ULPI Interface ----------------
    inout  wire         hps_usb1_D0,
    inout  wire         hps_usb1_D1,
    inout  wire         hps_usb1_D2,
    inout  wire         hps_usb1_D3,
    inout  wire         hps_usb1_D4,
    inout  wire         hps_usb1_D5,
    inout  wire         hps_usb1_D6,
    inout  wire         hps_usb1_D7,
    input  wire         hps_usb1_CLK,
    output logic        hps_usb1_STP,
    input  wire         hps_usb1_DIR,
    input  wire         hps_usb1_NXT,

    // -------------------- UART0 Interface --------------------
    input  wire         hps_uart0_RX,
    output logic        hps_uart0_TX,

    // -------------------- DDR3 Interface ---------------------
    output logic [14:0] memory_mem_a,
    output logic [2:0]  memory_mem_ba,
    output logic        memory_mem_ck,
    output logic        memory_mem_ck_n,
    output logic        memory_mem_cke,
    output logic        memory_mem_cs_n,
    output logic        memory_mem_ras_n,
    output logic        memory_mem_cas_n,
    output logic        memory_mem_we_n,
    output logic        memory_mem_reset_n,
    inout  wire [31:0]  memory_mem_dq,
    inout  wire [3:0]   memory_mem_dqs,
    inout  wire [3:0]   memory_mem_dqs_n,
    output logic        memory_mem_odt,
    output logic [3:0]  memory_mem_dm,
    input  wire         memory_oct_rzqin,

    // -------------------- USB3300 Clock ----------------------
    inout  wire         usb3300_clk_24MHz,      // 24 MHz bidirectional clock

    // -------------------- LVDS ADC Interface -----------------
    input  wire [5:0]   lvds_data_in,           // LVDS data inputs from ADC
    output logic [5:0]  lvds_clk_out,           // LVDS clock outputs
    output logic        adc_cnv_out,            // ADC convert start signal

    // -------------------- LM10 Encoder External IO ------------
    input  logic        LM10_encoder_a,         // Encoder channel A
    input  logic        LM10_encoder_b,         // Encoder channel B
    input  logic        LM10_encoder_z,         // Encoder index pulse Z

    // -------------------- PWM Outputs ------------------------
    output logic [2:0]pwm_lo_0_to_2,           // pwm1_lo ~ pwm3_lo
    output logic [2:0]pwm_hi_0_to_2,           // pwm1_hi ~ pwm3_hi
    inout  wire  [14:3]pwm_lo_3_to_14,          // pwm4_lo ~ pwm15_lo
    inout  wire  [14:3]pwm_hi_3_to_14,          // pwm4_hi ~ pwm15_hi
    output logic [21:15]pwm_lo_15_to_21,           // pwm1_lo ~ pwm3_lo
    output logic [21:15]pwm_hi_15_to_21,

    // -------------------- MOS Power Enable ------------------
    inout  wire mos_power_en,                     // External MOSFET power enable

    // -------------------- Console ----------------------------
	 
    inout  wire mbl600_vs_rho_power,
    inout  wire mbl600_vs_rho_a,
    inout  wire mbl600_vs_rho_b,
    inout  wire mbl600_phase_advance_power,
    inout  wire mbl600_phase_advance_a,
    inout  wire mbl600_phase_advance_b,
    //inout  wire mbl600_DTC_power,
    inout  wire mbl600_DTC_a,
    inout  wire mbl600_DTC_b,
	 
	 
    // -------------------- hall power ----------------------------
    inout  wire hall_en
);

    //----------------------------------------------------------
    // Internal Parameters
    //----------------------------------------------------------
    localparam ADC_BITS     = 12;     // ADC resolution (12-bit)
    localparam ADC_CLK_NS   = 20;     // ADC clock period in ns
    localparam LM10_WIDTH   = 13;     // Encoder bit width (≤16)
    localparam LM10_COUNTS  = 6400;   // Encoder counts per revolution
    localparam DEADTIME_LH  = 8;      // Deadtime for low-to-high transitions
    localparam DEADTIME_HL  = 8;      // Deadtime for high-to-low transitions

    //----------------------------------------------------------
    // Internal Signals
    //----------------------------------------------------------
    logic hps_0_h2f_reset_n;
    logic hps_cold_reset_n;
    logic clk_24M, clk_50M, clk_100M, clk_200M;

    // DMA payload buffer (108 bytes total)
    logic [8*108-1:0] frame_sdram_dma_input_array_flat;

    // ADC
    logic signed [ADC_BITS:0] adc_value [0:21]; // raw-bit signed ADC
    logic signed [ADC_BITS:0] adc_peak_value [0:21]; // raw-bit signed ADC	 
    logic [15:0] adc_value_16bits [0:21];                   // Extended to 16-bit
    logic [15:0] adc_peak_value_16bits [0:21];                   // Extended to 16-bit
    logic [15:0] adc_value_filter_16bits [0:21];                   // Extended to 16-bit

    // LM10 encoder internal signals
    logic [LM10_WIDTH-1:0] LM10_encoder_regout;
    logic signed [15:0]    LM10_rpm;
    logic                  LM10_encoder_ref_ready;

    // PWM
    logic [21:0] pwm_lo_internal; // Selected low-side MOSFET outputs
    logic [21:0] pwm_hi_internal; // Selected high-side MOSFET outputs
    logic [21:0] motor_pwm_hi;    // Normal PWM from motor_drive_core
    logic [21:0] motor_pwm_lo;    // Normal PWM from motor_drive_core
    logic        override_enable;
    logic [43:0] override_outputs;
    logic        mos_power_en_internal;  // Internal MOS power enable

    // Frozen motor-control interface
    logic [12:0] motor_encoder;
    logic [12:0] motor_amplitude;
    logic [15:0] motor_phase_advance;
    logic        motor_drive_enable;
    logic [21:0] bootstrap_precharge_lo;
    logic [21:0] bootstrap_precharge_hi;
    logic        bootstrap_normal_enable;
    logic        bootstrap_precharge_active;

    // Motor-control LUT update interface
    logic        motor_lut_wr_en;
    logic        motor_lut_wr_bank;
    logic [11:0] motor_lut_wr_addr;
    logic [12:0] motor_lut_wr_data;
    logic        motor_lut_commit_req;
    logic        motor_lut_active_bank;
    logic        motor_lut_commit_ack;
    // HPS-controlled verification of the inactive LUT bank
    logic        motor_lut_verify_en;
    logic        motor_lut_verify_bank;
    logic [11:0] motor_lut_verify_addr;
    logic        motor_lut_verify_lock;
    logic [12:0] motor_lut_verify_data;
    logic        motor_lut_verify_valid;

    // Console
    logic [6:0]  DTC_value;
    logic [12:0] phase_advance_value;
    logic [11:0] vs_rho_value;

    logic a_dtc;  // Encoder A for DTC
    logic b_dtc;  // Encoder B for DTC

    logic a_phase_advance;  // Encoder A for Phase Advance
    logic b_phase_advance;  // Encoder B for Phase Advance

    logic a_vs_rho;  // Encoder A for VS Rho
    logic b_vs_rho;  // Encoder B for VS Rho

    logic mbl600_vs_rho_power_internal;
    logic mbl600_DTC_power_internal;
    logic mbl600_phase_advance_power_internal;
	 
    logic hall_en_internal;
	 
    logic run; 

    //----------------------------------------------------------
    // PLL Clock Generation
    //----------------------------------------------------------
    pll clock (
        .refclk   (clk_ext_50m),
        .rst      (1'b0),
        .outclk_0 (clk_24M),    // 24 MHz
        .outclk_1 (clk_50M),    // 50 MHz
        .outclk_2 (clk_100M),   // 100 MHz
        .outclk_3 (clk_200M)    // 200 MHz
    );

    //----------------------------------------------------------
    // HPS + Qsys Subsystem
    //----------------------------------------------------------
    hps_qsys_top hps_qsys_top_inst (
        // Clock Inputs
        .clk_50M                (clk_50M),
        .clk_24M                (clk_24M),

        // HPS Reset
        .hps_0_h2f_reset_n      (hps_0_h2f_reset_n),
        .hps_cold_reset_n       (hps_cold_reset_n),

        // SDIO
        .hps_sdio_CMD           (hps_sdio_CMD),
        .hps_sdio_D0            (hps_sdio_D0),
        .hps_sdio_D1            (hps_sdio_D1),
        .hps_sdio_CLK           (hps_sdio_CLK),
        .hps_sdio_D2            (hps_sdio_D2),
        .hps_sdio_D3            (hps_sdio_D3),

        // USB1 ULPI
        .hps_usb1_D0            (hps_usb1_D0),
        .hps_usb1_D1            (hps_usb1_D1),
        .hps_usb1_D2            (hps_usb1_D2),
        .hps_usb1_D3            (hps_usb1_D3),
        .hps_usb1_D4            (hps_usb1_D4),
        .hps_usb1_D5            (hps_usb1_D5),
        .hps_usb1_D6            (hps_usb1_D6),
        .hps_usb1_D7            (hps_usb1_D7),
        .hps_usb1_CLK           (hps_usb1_CLK),
        .hps_usb1_STP           (hps_usb1_STP),
        .hps_usb1_DIR           (hps_usb1_DIR),
        .hps_usb1_NXT           (hps_usb1_NXT),

        // UART0
        .hps_uart0_RX           (hps_uart0_RX),
        .hps_uart0_TX           (hps_uart0_TX),

        // DDR3
        .memory_mem_a           (memory_mem_a),
        .memory_mem_ba          (memory_mem_ba),
        .memory_mem_ck          (memory_mem_ck),
        .memory_mem_ck_n        (memory_mem_ck_n),
        .memory_mem_cke         (memory_mem_cke),
        .memory_mem_cs_n        (memory_mem_cs_n),
        .memory_mem_ras_n       (memory_mem_ras_n),
        .memory_mem_cas_n       (memory_mem_cas_n),
        .memory_mem_we_n        (memory_mem_we_n),
        .memory_mem_reset_n     (memory_mem_reset_n),
        .memory_mem_dq          (memory_mem_dq),
        .memory_mem_dqs         (memory_mem_dqs),
        .memory_mem_dqs_n       (memory_mem_dqs_n),
        .memory_mem_odt         (memory_mem_odt),
        .memory_mem_dm          (memory_mem_dm),
        .memory_oct_rzqin       (memory_oct_rzqin),

        // console internal
        .mbl600_vs_rho_a_internal       (a_vs_rho),
        .mbl600_vs_rho_b_internal       (b_vs_rho),
        .mbl600_phase_advance_a_internal(a_phase_advance),
        .mbl600_DTC_a_internal          (a_dtc),
        .mbl600_DTC_b_internal          (b_dtc),
        .mbl600_phase_advance_b_internal(b_phase_advance),

        .mbl600_vs_rho_power_internal       (mbl600_vs_rho_power),
        .mbl600_DTC_power_internal          (mbl600_DTC_power),
        .mbl600_phase_advance_power_internal(mbl600_phase_advance_power),

        // console external
		  
        .mbl600_vs_rho_a_external       (mbl600_vs_rho_a),
        .mbl600_vs_rho_b_external       (mbl600_vs_rho_b),
        .mbl600_phase_advance_a_external(mbl600_phase_advance_a),
        .mbl600_phase_advance_b_external(mbl600_phase_advance_b),
        .mbl600_DTC_a_external          (mbl600_DTC_a),
        .mbl600_DTC_b_external          (mbl600_DTC_b),

        .mbl600_vs_rho_power_external       (mbl600_vs_rho_power),
        .mbl600_DTC_power_external          (mbl600_DTC_power),
        .mbl600_phase_advance_power_external(mbl600_phase_advance_power),
		  
        // register contron signal  
        .control_run(run),
		  
		  
        //hall power
		  
        .hall_en_internal(hall_en_internal),
        .hall_en_external(hall_en),

        // Internal PWM Signals
        .pwm_lo_internal       (pwm_lo_internal),
        .pwm_hi_internal       (pwm_hi_internal),
        .mos_power_en_internal (mos_power_en_internal),

        // Avalon-MM MOSFET manual override conduit
        .override_enable       (override_enable),
        .override_outputs      (override_outputs),

        // External PWM IOs
        .pwm_lo        (pwm_lo_3_to_14),
        .pwm_hi        (pwm_hi_3_to_14),
        .mos_power_en  (mos_power_en),

        // USB Clock
        .usb3300_clk_24MHz      (usb3300_clk_24MHz),

        // DMA buffer
        .frame_sdram_dma_input_array_flat (frame_sdram_dma_input_array_flat),

        // Motor-control LUT update interface
        .motor_lut_wr_en        (motor_lut_wr_en),
        .motor_lut_wr_bank      (motor_lut_wr_bank),
        .motor_lut_wr_addr      (motor_lut_wr_addr),
        .motor_lut_wr_data      (motor_lut_wr_data),
        .motor_lut_commit_req   (motor_lut_commit_req),
        .motor_lut_active_bank  (motor_lut_active_bank),
        .motor_lut_commit_ack   (motor_lut_commit_ack),
        .motor_lut_verify_en    (motor_lut_verify_en),
        .motor_lut_verify_bank  (motor_lut_verify_bank),
        .motor_lut_verify_addr  (motor_lut_verify_addr),
        .motor_lut_verify_lock  (motor_lut_verify_lock),
        .motor_lut_verify_data  (motor_lut_verify_data),
        .motor_lut_verify_valid (motor_lut_verify_valid)
    );

    //----------------------------------------------------------
    // Measure Top Module: ADC + Encoder
    //----------------------------------------------------------
    measure_top #(
        .ADC_BITS    (ADC_BITS),
        .ADC_CLK_NS  (ADC_CLK_NS),
        .LM10_WIDTH  (LM10_WIDTH),
        .LM10_COUNTS (LM10_COUNTS)
    ) measure_top_inst (
        .clk_50m                 (clk_50M),
        .clk_100m                (clk_100M),
        .lvds_data               (lvds_data_in),
        .lvds_clk                (lvds_clk_out),
        .cnv                     (adc_cnv_out),
        .adc_value               (adc_value),
        .LM10_encoder_a          (LM10_encoder_a),
        .LM10_encoder_b          (LM10_encoder_b),
        .LM10_encoder_z          (LM10_encoder_z),
        .LM10_encoder_ref_ready  (LM10_encoder_ref_ready),
        .LM10_encoder_regout     (LM10_encoder_regout),
        .LM10_rpm                (LM10_rpm)
    );
	 
    //----------------------------------------------------------
    // Motor Control Adapter
    //----------------------------------------------------------
    motor_control_adapter #(
        .VS_RHO_MIN(constants_pkg::VS_RHO_MIN)
    ) motor_control_adapter_inst (
        .encoder_legacy        (LM10_encoder_regout),
        .vs_rho_legacy         (vs_rho_value),
        .phase_advance_legacy  (phase_advance_value),
        .encoder_ref_ready     (LM10_encoder_ref_ready),
        .run                   (run),
        .encoder_core          (motor_encoder),
        .amplitude_core        (motor_amplitude),
        .phase_advance_core    (motor_phase_advance),
        .drive_enable_core     (motor_drive_enable)
    );

    //----------------------------------------------------------
    // Bootstrap capacitor precharge (50 MHz control clock).
    // Precharge is active from startup permission until normal PWM is ready.
    // A loss of permission immediately masks all automatic outputs.
    //----------------------------------------------------------
    bootstrap_precharge #(
        .CLK_HZ(50_000_000),
        .CHANNELS(22)
    ) bootstrap_precharge_inst (
        .clk           (clk_50M),
        .rst_n         (hps_0_h2f_reset_n),
        .start_request (motor_drive_enable),
        .precharge_lo  (bootstrap_precharge_lo),
        .precharge_hi  (bootstrap_precharge_hi),
        .normal_enable (bootstrap_normal_enable)
    );

    assign bootstrap_precharge_active = motor_drive_enable && !bootstrap_normal_enable;

    //----------------------------------------------------------
    // Frozen Motor Drive Core
    //----------------------------------------------------------
    motor_drive_core motor_drive_core_inst (
        .clk_50MHz       (clk_50M),
        .clk_200MHz      (clk_200M),
        .rst_n           (hps_0_h2f_reset_n),
        .drive_enable    (motor_drive_enable),
        .encoder_phi     (motor_encoder),
        .amplitude       (motor_amplitude),
        .phase_advance   (motor_phase_advance),
        .lut_wr_en       (motor_lut_wr_en),
        .lut_wr_bank     (motor_lut_wr_bank),
        .lut_wr_addr     (motor_lut_wr_addr),
        .lut_wr_data     (motor_lut_wr_data),
        .lut_commit_req  (motor_lut_commit_req),
        .lut_active_bank (motor_lut_active_bank),
        .lut_commit_ack  (motor_lut_commit_ack),
        .lut_verify_en    (motor_lut_verify_en),
        .lut_verify_bank  (motor_lut_verify_bank),
        .lut_verify_addr  (motor_lut_verify_addr),
        .lut_verify_lock  (motor_lut_verify_lock),
        .lut_verify_data  (motor_lut_verify_data),
        .lut_verify_valid (motor_lut_verify_valid),
        .pwm_hi          (motor_pwm_hi),
        .pwm_lo          (motor_pwm_lo)
    );

    //----------------------------------------------------------
    // Final MOSFET driver: normal PWM / manual override selection
    //----------------------------------------------------------
    mosfet_driver mosfet_driver_inst (
        .normal_pwm_hi   (motor_pwm_hi),
        .normal_pwm_lo   (motor_pwm_lo),
        .override_enable (override_enable),
        .override_outputs(override_outputs),
        .precharge_active(bootstrap_precharge_active),
        .precharge_lo   (bootstrap_precharge_lo),
        .normal_enable (bootstrap_normal_enable && motor_drive_enable),
        .pwm_hi          (pwm_hi_internal),
        .pwm_lo          (pwm_lo_internal)
    );

    //----------------------------------------------------------
    // Console Encoder Top Module Instance
    //----------------------------------------------------------
    console_top console_top_inst (
        .clk                (clk_50M),

        // Three independent encoder pairs
        .a_dtc              (a_dtc),
        .b_dtc              (b_dtc),

        .a_phase_advance    (a_phase_advance),
        .b_phase_advance    (b_phase_advance),

        .a_vs_rho           (a_vs_rho),
        .b_vs_rho           (b_vs_rho),

        // Internal values (not external IO)
        .DTC_value          (DTC_value),
        .phase_advance_value(phase_advance_value),
        .vs_rho_value       (vs_rho_value)
    );

   
    assign mbl600_vs_rho_power_internal       = 1'b1;
    assign mbl600_DTC_power_internal          = 1'b1;
    assign mbl600_phase_advance_power_internal= 1'b1;
	 
    //----------------------------------------------------------
    // Hall power
    //----------------------------------------------------------
    assign hall_en_internal       = 1'b1;
 
    //----------------------------------------------------------
    // MOS Power Enable
    //----------------------------------------------------------
    assign mos_power_en_internal = 1'b1;

    //----------------------------------------------------------
    // PWM Top-level Mapping to External Ports
    //----------------------------------------------------------
	 
    assign pwm_lo_0_to_2[2:0]       = pwm_lo_internal[2:0];
    assign pwm_hi_0_to_2[2:0]       = pwm_hi_internal[2:0];
    assign pwm_lo_15_to_21[21:15]   = pwm_lo_internal[21:15];
    assign pwm_hi_15_to_21[21:15]   = pwm_hi_internal[21:15];
	 

    //----------------------------------------------------------
    // Extend ADC Values to 16 Bits (Sign Extension)
    //----------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 22; i = i + 1) begin : adc_value_gen
            assign adc_value_16bits[i] = {
                {(16-ADC_BITS-1){adc_value[i][ADC_BITS]}},
                adc_value[i]
            };
        end
    endgenerate
	 
    //----------------------------------------------------------
    // Extend ADC peak value to 16 Bits (Sign Extension)
    //----------------------------------------------------------
	 /*
    generate
        for (i = 0; i < 22; i = i + 1) begin : adc_peak_gen
            assign adc_peak_value_16bits[i] = {
                {(16-ADC_BITS-1){adc_peak_value[i][ADC_BITS]}},
                adc_peak_value[i]
            };
        end
    endgenerate
	 */
	 
	 

    //----------------------------------------------------------
    // DMA Data Packing (108 bytes) - FIXED PATTERN DEBUG
    // IMPORTANT: Restore the commented original assignment after test.
    // Actual data fields = 102 bytes; leading 6 bytes = zero padding.
    // Expected SDRAM byte offsets for low-address-first mapping:
    // Filter 0..43; Peak 44..87; RPM 88..91;
    // VS 92..93; Phase 94..95; DTC 96..97;
    // Encoder 98..101; zero padding 102..107.
    //----------------------------------------------------------
     //ORIGINAL DMA PACKING (RESTORE AFTER DEBUG)
    assign frame_sdram_dma_input_array_flat = {
    48'd0,
    {9'b000000000, DTC_value},
    {3'b000, phase_advance_value},
    {4'b0000, vs_rho_value},
    {{(32-LM10_WIDTH){1'b0}}, LM10_encoder_regout},
    {{16{LM10_rpm[15]}}, LM10_rpm},
    adc_peak_value_16bits[21], adc_peak_value_16bits[20], adc_peak_value_16bits[19],
    adc_peak_value_16bits[18], adc_peak_value_16bits[17], adc_peak_value_16bits[16],
    adc_peak_value_16bits[15], adc_peak_value_16bits[14], adc_peak_value_16bits[13],
    adc_peak_value_16bits[12], adc_peak_value_16bits[11], adc_peak_value_16bits[10],
    adc_peak_value_16bits[9],  adc_peak_value_16bits[8],  adc_peak_value_16bits[7],
    adc_peak_value_16bits[6],  adc_peak_value_16bits[5],  adc_peak_value_16bits[4],
    adc_peak_value_16bits[3],  adc_peak_value_16bits[2],  adc_peak_value_16bits[1],
    adc_peak_value_16bits[0],
    adc_value_filter_16bits[21], adc_value_filter_16bits[20], adc_value_filter_16bits[19],
    adc_value_filter_16bits[18], adc_value_filter_16bits[17], adc_value_filter_16bits[16],
    adc_value_filter_16bits[15], adc_value_filter_16bits[14], adc_value_filter_16bits[13],
    adc_value_filter_16bits[12], adc_value_filter_16bits[11], adc_value_filter_16bits[10],
    adc_value_filter_16bits[9],  adc_value_filter_16bits[8],  adc_value_filter_16bits[7],
    adc_value_filter_16bits[6],  adc_value_filter_16bits[5],  adc_value_filter_16bits[4],
    adc_value_filter_16bits[3],  adc_value_filter_16bits[2],  adc_value_filter_16bits[1],
    adc_value_filter_16bits[0]
};
	 
 
  /*
    assign frame_sdram_dma_input_array_flat = {
        48'h000000000000, // 6-byte leading pad (MSB)
        32'h12345678,     // Encoder
        16'h0123,         // DTC
        16'h0456,         // Phase Advance
        16'h0789,         // VS Rho
        32'h89ABCDEF,     // RPM: intentionally distinct bytes (not sign extension)
        16'h2215, // Peak[21]
        16'h2214, // Peak[20]
        16'h2213, // Peak[19]
        16'h2212, // Peak[18]
        16'h2211, // Peak[17]
        16'h2210, // Peak[16]
        16'h220F, // Peak[15]
        16'h220E, // Peak[14]
        16'h220D, // Peak[13]
        16'h220C, // Peak[12]
        16'h220B, // Peak[11]
        16'h220A, // Peak[10]
        16'h2209, // Peak[9]
        16'h2208, // Peak[8]
        16'h2207, // Peak[7]
        16'h2206, // Peak[6]
        16'h2205, // Peak[5]
        16'h2204, // Peak[4]
        16'h2203, // Peak[3]
        16'h2202, // Peak[2]
        16'h2201, // Peak[1]
        16'h2200, // Peak[0]
        16'h1115, // Filter[21]
        16'h1114, // Filter[20]
        16'h1113, // Filter[19]
        16'h1112, // Filter[18]
        16'h1111, // Filter[17]
        16'h1110, // Filter[16]
        16'h110F, // Filter[15]
        16'h110E, // Filter[14]
        16'h110D, // Filter[13]
        16'h110C, // Filter[12]
        16'h110B, // Filter[11]
        16'h110A, // Filter[10]
        16'h1109, // Filter[9]
        16'h1108, // Filter[8]
        16'h1107, // Filter[7]
        16'h1106, // Filter[6]
        16'h1105, // Filter[5]
        16'h1104, // Filter[4]
        16'h1103, // Filter[3]
        16'h1102, // Filter[2]
        16'h1101, // Filter[1]
        16'h1100  // Filter[0]
    };   */

    FIR_22_drive #(
        .TDM_FACTOR (100),
        .CHANNELS (22)
    ) FIR_22_drive_inst (
        .clk_i(clk_50M),
        .rst_ni(1'b1),
        .val_in(adc_value_16bits),
        .val_out(adc_value_filter_16bits)

    );
	 
	 
	 
	 
	 
	 
    peak_current_detector #(
        .ADC_BITS(16),
        .NUM_CHANNELS(22)
    )peak_current_detector_inst (
        . clk(clk_50M),
        . i_adc_value (adc_value_filter_16bits),
        . o_adc_value (adc_peak_value_16bits)
    );
		
    assign hps_cold_reset_n = 1'b1;
	 
	 

endmodule
