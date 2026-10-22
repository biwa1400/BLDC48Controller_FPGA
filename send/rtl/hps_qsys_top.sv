/*********************************************************************************
* Module Name  : hps_qsys_top
* Description  : Top-level wrapper for HPS Qsys system.
*                - Integrates HPS peripherals (SDIO, USB, UART)
*                - Connects DDR3 memory interface
*                - Provides PWM MOSFET high-side and low-side drive signals
*                - Maps internal signals to external IOs via HPS Loan IO
*                - Includes USB 24MHz clock output
*                - Exposes motor LUT Avalon interface from Platform Designer
* Author       : Bin Wang
* Date         : 2025-10-16
*********************************************************************************/

module hps_qsys_top (

    // ------------------------ Clock Inputs ------------------------
    input  logic        clk_50M,
    input  logic        clk_24M,

    // ------------------------ HPS Reset --------------------------
    output logic        hps_0_h2f_reset_n,
    input  logic        hps_cold_reset_n,

    // ------------------------ SDIO Interface ----------------------
    inout  wire         hps_sdio_CMD,
    inout  wire         hps_sdio_D0,
    inout  wire         hps_sdio_D1,
    output logic        hps_sdio_CLK,
    inout  wire         hps_sdio_D2,
    inout  wire         hps_sdio_D3,

    // ------------------------ USB1 ULPI Interface -----------------
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

    // ------------------------ UART0 Interface ---------------------
    input  wire         hps_uart0_RX,
    output logic        hps_uart0_TX,

    // ------------------------ DDR3 Interface ----------------------
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

    // ------------------------ Control Signals ---------------------
    output logic        control_run,

    // ------------------------ Hall Sensor Signals -----------------
    input  logic        hall_en_internal,
    inout  logic        hall_en_external,

    // ------------------------ Internal Console Signals ------------
    output logic        mbl600_vs_rho_a_internal,
    output logic        mbl600_vs_rho_b_internal,
    output logic        mbl600_phase_advance_a_internal,
    output logic        mbl600_DTC_a_internal,
    output logic        mbl600_DTC_b_internal,
    output logic        mbl600_phase_advance_b_internal,

    input  logic        mbl600_vs_rho_power_internal,
    input  logic        mbl600_DTC_power_internal,
    input  logic        mbl600_phase_advance_power_internal,

    // ------------------------ External Console Signals ------------
    inout wire          mbl600_vs_rho_a_external,
    inout wire          mbl600_vs_rho_b_external,
    inout wire          mbl600_phase_advance_a_external,
    inout wire          mbl600_phase_advance_b_external,
    inout wire          mbl600_DTC_a_external,
    inout wire          mbl600_DTC_b_external,
    inout wire          mbl600_vs_rho_power_external,
    inout wire          mbl600_DTC_power_external,
    inout wire          mbl600_phase_advance_power_external,

    // ------------------------ Internal PWM Signals ----------------
    input  logic [21:0] pwm_lo_internal,
    input  logic [21:0] pwm_hi_internal,
    input  logic        mos_power_en_internal,

    // ------------------------ External PWM IOs --------------------
    inout  wire [14:3]  pwm_lo,
    inout  wire [14:3]  pwm_hi,
    inout  wire         mos_power_en,

    // ------------------------ External USB Clock IO ---------------
    inout  wire         usb3300_clk_24MHz,

    // ------------------------ Internal DMA Buffer -----------------
    input  logic [8*108-1:0] frame_sdram_dma_input_array_flat,

    // ------------------------ Motor LUT Interface -----------------
    // HPS / Avalon -> frozen motor-control core
    output logic        motor_lut_wr_en,
    output logic        motor_lut_wr_bank,
    output logic [11:0] motor_lut_wr_addr,
    output logic [12:0] motor_lut_wr_data,
    output logic        motor_lut_commit_req,

    // Frozen motor-control core -> HPS / Avalon
    input  logic        motor_lut_active_bank,
    input  logic        motor_lut_commit_ack,

    // HPS / Avalon -> LUT SRAM verification interface
    output logic        motor_lut_verify_en,
    output logic        motor_lut_verify_bank,
    output logic [11:0] motor_lut_verify_addr,
    output logic        motor_lut_verify_lock,

    // LUT SRAM -> HPS / Avalon verification response
    input  logic [12:0] motor_lut_verify_data,
    input  logic        motor_lut_verify_valid
);


    // ------------------------ HPS Loan IO Signals -----------------
    logic [66:0] hps_0_h2f_loan_io_oe;
    logic [66:0] hps_0_h2f_loan_io_out;
    logic [66:0] hps_0_h2f_loan_io_in;


    // ------------------------ Instantiate Qsys System -------------
    soc_system u0 (

        .clk_clk                           (clk_50M),
        .reset_reset_n                     (1'b1),
        .hps_0_h2f_reset_reset_n           (hps_0_h2f_reset_n),
        .hps_0_f2h_cold_reset_req_reset_n  (hps_cold_reset_n),

        // HPS Peripheral Interfaces
        .hps_0_hps_io_hps_io_sdio_inst_CMD (hps_sdio_CMD),
        .hps_0_hps_io_hps_io_sdio_inst_D0  (hps_sdio_D0),
        .hps_0_hps_io_hps_io_sdio_inst_D1  (hps_sdio_D1),
        .hps_0_hps_io_hps_io_sdio_inst_CLK (hps_sdio_CLK),
        .hps_0_hps_io_hps_io_sdio_inst_D2  (hps_sdio_D2),
        .hps_0_hps_io_hps_io_sdio_inst_D3  (hps_sdio_D3),

        .hps_0_hps_io_hps_io_usb1_inst_D0  (hps_usb1_D0),
        .hps_0_hps_io_hps_io_usb1_inst_D1  (hps_usb1_D1),
        .hps_0_hps_io_hps_io_usb1_inst_D2  (hps_usb1_D2),
        .hps_0_hps_io_hps_io_usb1_inst_D3  (hps_usb1_D3),
        .hps_0_hps_io_hps_io_usb1_inst_D4  (hps_usb1_D4),
        .hps_0_hps_io_hps_io_usb1_inst_D5  (hps_usb1_D5),
        .hps_0_hps_io_hps_io_usb1_inst_D6  (hps_usb1_D6),
        .hps_0_hps_io_hps_io_usb1_inst_D7  (hps_usb1_D7),
        .hps_0_hps_io_hps_io_usb1_inst_CLK (hps_usb1_CLK),
        .hps_0_hps_io_hps_io_usb1_inst_STP (hps_usb1_STP),
        .hps_0_hps_io_hps_io_usb1_inst_DIR (hps_usb1_DIR),
        .hps_0_hps_io_hps_io_usb1_inst_NXT (hps_usb1_NXT),

        .hps_0_hps_io_hps_io_uart0_inst_RX  (hps_uart0_RX),
        .hps_0_hps_io_hps_io_uart0_inst_TX  (hps_uart0_TX),

        // DDR3 Interface
        .memory_mem_a       (memory_mem_a),
        .memory_mem_ba      (memory_mem_ba),
        .memory_mem_ck      (memory_mem_ck),
        .memory_mem_ck_n    (memory_mem_ck_n),
        .memory_mem_cke     (memory_mem_cke),
        .memory_mem_cs_n    (memory_mem_cs_n),
        .memory_mem_ras_n   (memory_mem_ras_n),
        .memory_mem_cas_n   (memory_mem_cas_n),
        .memory_mem_we_n    (memory_mem_we_n),
        .memory_mem_reset_n (memory_mem_reset_n),
        .memory_mem_dq      (memory_mem_dq),
        .memory_mem_dqs     (memory_mem_dqs),
        .memory_mem_dqs_n   (memory_mem_dqs_n),
        .memory_mem_odt     (memory_mem_odt),
        .memory_mem_dm      (memory_mem_dm),
        .memory_oct_rzqin   (memory_oct_rzqin),

        // DMA Buffer
        .frame_sdram_dma_0_frame_input_input_array_flat
            (frame_sdram_dma_input_array_flat),

        // Motor LUT Avalon bridge
        .motor_lut_avalon_slave_0_lut_active_bank
            (motor_lut_active_bank),

        .motor_lut_avalon_slave_0_lut_commit_ack
            (motor_lut_commit_ack),

        .motor_lut_avalon_slave_0_lut_commit_req
            (motor_lut_commit_req),

        .motor_lut_avalon_slave_0_lut_wr_addr
            (motor_lut_wr_addr),

        .motor_lut_avalon_slave_0_lut_wr_bank
            (motor_lut_wr_bank),

        .motor_lut_avalon_slave_0_lut_wr_data
            (motor_lut_wr_data),

        .motor_lut_avalon_slave_0_lut_wr_en
            (motor_lut_wr_en),

        // SRAM verification request and response
        .motor_lut_avalon_slave_0_lut_verify_addr
            (motor_lut_verify_addr),

        .motor_lut_avalon_slave_0_lut_verify_bank
            (motor_lut_verify_bank),

        .motor_lut_avalon_slave_0_lut_verify_data
            (motor_lut_verify_data),

        .motor_lut_avalon_slave_0_lut_verify_en
            (motor_lut_verify_en),

        .motor_lut_avalon_slave_0_lut_verify_lock
            (motor_lut_verify_lock),

        .motor_lut_avalon_slave_0_lut_verify_valid
            (motor_lut_verify_valid),

        // Loan IO Connection
        .hps_0_h2f_loan_io_in
            (hps_0_h2f_loan_io_in),

        .hps_0_h2f_loan_io_out
            (hps_0_h2f_loan_io_out),

        .hps_0_h2f_loan_io_oe
            (hps_0_h2f_loan_io_oe),

        // USB Clock Output
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO25
            (usb3300_clk_24MHz),

        // PWM MOSFET Enable
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO34
            (mos_power_en),

        // PWM MOSFET Drive Signals
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO00 (pwm_hi[6]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO14 (pwm_hi[5]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO15 (pwm_hi[4]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO16 (pwm_lo[6]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO17 (pwm_lo[4]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO18 (pwm_hi[3]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO19 (pwm_hi[8]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO22 (pwm_hi[7]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO23 (pwm_lo[9]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO24 (pwm_lo[8]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO26 (pwm_lo[7]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO27 (pwm_lo[5]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO29 (pwm_hi[9]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO30 (pwm_hi[14]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO31 (pwm_lo[3]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO48 (pwm_lo[10]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO49 (pwm_lo[14]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO50 (pwm_hi[10]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO51 (pwm_lo[12]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO52 (pwm_lo[13]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO53 (pwm_lo[11]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO54 (pwm_hi[13]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO55 (pwm_hi[12]),
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO56 (pwm_hi[11]),

        // Console Signals
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO57
            (mbl600_vs_rho_a_external),

        .hps_0_hps_io_hps_io_gpio_inst_LOANIO58
            (mbl600_vs_rho_b_external),

        .hps_0_hps_io_hps_io_gpio_inst_LOANIO59
            (mbl600_phase_advance_a_external),

        .hps_0_hps_io_hps_io_gpio_inst_LOANIO63
            (mbl600_DTC_a_external),

        .hps_0_hps_io_hps_io_gpio_inst_LOANIO64
            (mbl600_DTC_b_external),

        .hps_0_hps_io_hps_io_gpio_inst_LOANIO65
            (mbl600_phase_advance_b_external),

        .hps_0_hps_io_hps_io_gpio_inst_LOANIO60
            (mbl600_vs_rho_power_external),

        //.hps_0_hps_io_hps_io_gpio_inst_LOANIO61
        //    (mbl600_DTC_power_external),

        .hps_0_hps_io_hps_io_gpio_inst_LOANIO66
            (mbl600_phase_advance_power_external),

        // Hall Power
        .hps_0_hps_io_hps_io_gpio_inst_LOANIO32
            (hall_en_external),

        // Run control
        .register_file_run_name
            (control_run)
    );


    // ------------------------ Loan IO Output Enables --------------
    assign hps_0_h2f_loan_io_oe[25] = 1'b1;
    assign hps_0_h2f_loan_io_oe[34] = 1'b1;

    assign hps_0_h2f_loan_io_oe[0]  = 1'b1;
    assign hps_0_h2f_loan_io_oe[14] = 1'b1;
    assign hps_0_h2f_loan_io_oe[15] = 1'b1;
    assign hps_0_h2f_loan_io_oe[16] = 1'b1;
    assign hps_0_h2f_loan_io_oe[17] = 1'b1;
    assign hps_0_h2f_loan_io_oe[18] = 1'b1;
    assign hps_0_h2f_loan_io_oe[19] = 1'b1;
    assign hps_0_h2f_loan_io_oe[22] = 1'b1;
    assign hps_0_h2f_loan_io_oe[23] = 1'b1;
    assign hps_0_h2f_loan_io_oe[24] = 1'b1;
    assign hps_0_h2f_loan_io_oe[26] = 1'b1;
    assign hps_0_h2f_loan_io_oe[27] = 1'b1;
    assign hps_0_h2f_loan_io_oe[29] = 1'b1;
    assign hps_0_h2f_loan_io_oe[30] = 1'b1;
    assign hps_0_h2f_loan_io_oe[31] = 1'b1;
    assign hps_0_h2f_loan_io_oe[48] = 1'b1;
    assign hps_0_h2f_loan_io_oe[49] = 1'b1;
    assign hps_0_h2f_loan_io_oe[50] = 1'b1;
    assign hps_0_h2f_loan_io_oe[51] = 1'b1;
    assign hps_0_h2f_loan_io_oe[52] = 1'b1;
    assign hps_0_h2f_loan_io_oe[53] = 1'b1;
    assign hps_0_h2f_loan_io_oe[54] = 1'b1;
    assign hps_0_h2f_loan_io_oe[55] = 1'b1;
    assign hps_0_h2f_loan_io_oe[56] = 1'b1;

    // Console output enables
    assign hps_0_h2f_loan_io_oe[60] = 1'b1;
    //assign hps_0_h2f_loan_io_oe[61] = 1'b1;
    assign hps_0_h2f_loan_io_oe[66] = 1'b1;

    // Hall power
    assign hps_0_h2f_loan_io_oe[32] = 1'b1;


    // ------------------------ Loan IO Output Mapping --------------
    assign hps_0_h2f_loan_io_out[25] = clk_24M;
    assign hps_0_h2f_loan_io_out[34] = mos_power_en_internal;

    // PWM MOSFET drive signals
    assign hps_0_h2f_loan_io_out[0]  = pwm_hi_internal[6];
    assign hps_0_h2f_loan_io_out[14] = pwm_hi_internal[5];
    assign hps_0_h2f_loan_io_out[15] = pwm_hi_internal[4];
    assign hps_0_h2f_loan_io_out[16] = pwm_lo_internal[6];
    assign hps_0_h2f_loan_io_out[17] = pwm_lo_internal[4];
    assign hps_0_h2f_loan_io_out[18] = pwm_hi_internal[3];
    assign hps_0_h2f_loan_io_out[19] = pwm_hi_internal[8];
    assign hps_0_h2f_loan_io_out[22] = pwm_hi_internal[7];
    assign hps_0_h2f_loan_io_out[23] = pwm_lo_internal[9];
    assign hps_0_h2f_loan_io_out[24] = pwm_lo_internal[8];
    assign hps_0_h2f_loan_io_out[26] = pwm_lo_internal[7];
    assign hps_0_h2f_loan_io_out[27] = pwm_lo_internal[5];
    assign hps_0_h2f_loan_io_out[29] = pwm_hi_internal[9];
    assign hps_0_h2f_loan_io_out[30] = pwm_hi_internal[14];
    assign hps_0_h2f_loan_io_out[31] = pwm_lo_internal[3];
    assign hps_0_h2f_loan_io_out[48] = pwm_lo_internal[10];
    assign hps_0_h2f_loan_io_out[49] = pwm_lo_internal[14];
    assign hps_0_h2f_loan_io_out[50] = pwm_hi_internal[10];
    assign hps_0_h2f_loan_io_out[51] = pwm_lo_internal[12];
    assign hps_0_h2f_loan_io_out[52] = pwm_lo_internal[13];
    assign hps_0_h2f_loan_io_out[53] = pwm_lo_internal[11];
    assign hps_0_h2f_loan_io_out[54] = pwm_hi_internal[13];
    assign hps_0_h2f_loan_io_out[55] = pwm_hi_internal[12];
    assign hps_0_h2f_loan_io_out[56] = pwm_hi_internal[11];

    // Console outputs
    assign hps_0_h2f_loan_io_out[60] =
        mbl600_vs_rho_power_internal;

    //assign hps_0_h2f_loan_io_out[61] =
    //    mbl600_DTC_power_internal;

    assign hps_0_h2f_loan_io_out[66] =
        mbl600_phase_advance_power_internal;

    // Hall power output
    assign hps_0_h2f_loan_io_out[32] =
        hall_en_internal;


    // ------------------------ Loan IO Input Mapping ---------------
    assign mbl600_vs_rho_a_internal =
        hps_0_h2f_loan_io_in[57];

    assign mbl600_vs_rho_b_internal =
        hps_0_h2f_loan_io_in[58];

    assign mbl600_phase_advance_a_internal =
        hps_0_h2f_loan_io_in[59];

    assign mbl600_DTC_a_internal =
        hps_0_h2f_loan_io_in[63];

    assign mbl600_DTC_b_internal =
        hps_0_h2f_loan_io_in[64];

    assign mbl600_phase_advance_b_internal =
        hps_0_h2f_loan_io_in[65];


endmodule