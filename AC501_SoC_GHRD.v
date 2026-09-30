//--------------------------------------------------------------
// Top-level Module: AC501_SoC_GHRD
// Description:
//   - Integrates HPS, DDR3, USB, SDIO, ADC, and LM10 encoder.
//   - Provides PWM outputs for MOSFETs (high-side and low-side).
//   - Packs ADC and encoder data into 52-byte DMA buffer for HPS.
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

    // DMA payload buffer (52 bytes total)
    logic [8*56-1:0] dma_sdram_0_registers_bytes;

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
    logic [12:0] drive_pwm_duty [0:21];  // Duty cycles for PWM channels
    logic [21:0] pwm_lo_internal; // Internal low-side PWM signals
    logic [21:0] pwm_hi_internal; // Internal high-side PWM signals
    logic        mos_power_en_internal;  // Internal MOS power enable

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
	 
	 logic init_start;
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

        // External PWM IOs
        .pwm_lo        (pwm_lo_3_to_14),
        .pwm_hi        (pwm_hi_3_to_14),
        .mos_power_en  (mos_power_en),

        // USB Clock
        .usb3300_clk_24MHz      (usb3300_clk_24MHz),

        // DMA buffer
        .dma_sdram_0_registers_bytes (dma_sdram_0_registers_bytes)
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
    // Control Top Module: FOC
    //----------------------------------------------------------	 
	 
	control_top #(
		 // -------- Configurable parameters --------
		 .LM10_WIDTH(LM10_WIDTH),         // Encoder resolution bits
		 .LM10_COUNTS(LM10_COUNTS),       // Encoder total counts
		 .ADC_BITS(ADC_BITS)              // ADC resolution bits
	) control_top_inst (
		 // -------- Input signals --------
		 .clk_50m(clk_50M),               // System clock
		 .phi(LM10_encoder_regout),       // Rotor mechanical angle (0~4095)
		 .rpm(LM10_rpm),                  // Rotor speed in RPM

		 // -------- Voltage & phase outputs --------
		 .vs_rho(vs_rho_value),           // Voltage magnitude
		 .phase_advance(phase_advance_value),  // Phase advance

		 // -------- PWM output array --------
		 .pwm_duty(drive_pwm_duty),       // Array of 22 PWM duties, each 13-bit wide
		 .init_start(init_start),         // Initialization start flag
		 .encoder_ok(LM10_encoder_ref_ready),  // Encoder Z-index found flag
		 .run(run)                        // Run enable flag
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
    // Drive Top Module: PWM Generation
    //----------------------------------------------------------
    drive_top #(
        .DEADTIME_LH (DEADTIME_LH),
        .DEADTIME_HL (DEADTIME_HL)
    ) drive_top_inst (
        .deadtime_control_rstn         (init_start),
        .clk_200MHz   (clk_200M),
        .dtc          (DTC_value),
        .pwm_duty     (drive_pwm_duty),
        .o_pwm_lo     (pwm_lo_internal),
        .o_pwm_hi     (pwm_hi_internal),
        .mos_power_en (mos_power_en_internal)
    );
	 


    //----------------------------------------------------------
    // PWM Top-level Mapping to External Ports
    //----------------------------------------------------------
	 
    assign pwm_lo_0_to_2[2:0]     =    pwm_lo_internal[2:0];
    assign pwm_hi_0_to_2[2:0]     =    pwm_hi_internal[2:0];
    assign pwm_lo_15_to_21[21:15]   =    pwm_lo_internal[21:15];
    assign pwm_hi_15_to_21[21:15]   =    pwm_hi_internal[21:15];
	 

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
    // DMA Data Packing (52+4 bytes)
    //----------------------------------------------------------
		assign dma_sdram_0_registers_bytes = {
	     {{(32-LM10_WIDTH){1'b0}}, LM10_encoder_regout},
		  //{{(32-LM10_WIDTH){1'b0}}, 13'd1234},
		  {9'b000000000, DTC_value},
		  {3'b000, phase_advance_value},
		  {4'b0000, vs_rho_value},
        LM10_rpm,
        adc_value_16bits[21], adc_value_16bits[20], adc_value_16bits[19],
        adc_value_16bits[18], adc_value_16bits[17], adc_value_16bits[16],
        adc_value_16bits[15], adc_value_16bits[14], adc_value_16bits[13],
        adc_value_16bits[12], adc_value_16bits[11], adc_value_16bits[10],
        adc_value_16bits[9],  adc_value_16bits[8],  adc_value_16bits[7],
        adc_value_16bits[6],  adc_value_16bits[5],  adc_value_16bits[4],
        adc_value_16bits[3],  adc_peak_value_16bits[0],  adc_value_filter_16bits[0],
        adc_value_16bits[0]
    };
		
		
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
