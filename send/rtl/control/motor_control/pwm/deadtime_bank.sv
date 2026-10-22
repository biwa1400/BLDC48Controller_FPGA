// ============================================================================
// deadtime_bank.sv
//
// BLDC48Controller FPGA
//
// 22-channel complementary gate deadtime bank.
//
// Each raw PWM channel is processed independently.
//
// ============================================================================
//
// DEADTIME CONFIGURATION
//
// To change the deadtime for ALL 22 PWM channels:
//
//     File: rtl/constants_pkg.sv
//
//     Parameter: DEADTIME_CLOCKS
//
// At 200 MHz:
//
//     Deadtime (ns) = DEADTIME_CLOCKS * 5
//
// Current configuration:
//
//     DEADTIME_CLOCKS = 36
//     Deadtime = 180 ns
//
// DO NOT configure deadtime separately in this file.
//
// ============================================================================

module deadtime_bank (

    input  logic        clk_200MHz,
    input  logic        rst_n,

    input  logic [21:0] raw_pwm,

    output logic [21:0] pwm_hi,
    output logic [21:0] pwm_lo

);

    import motor_control_pkg::NUM_PHASES;


    // ========================================================================
    // Generate one deadtime channel for each motor phase
    // ========================================================================

    genvar phase_index;

    generate

        for (
            phase_index = 0;
            phase_index < NUM_PHASES;
            phase_index = phase_index + 1
        ) begin : gen_deadtime_channel

            deadtime_channel #(
                .DEADTIME_CLOCKS(constants_pkg::DEADTIME_CLOCKS)
            ) u_deadtime_channel (

                .clk_200MHz (clk_200MHz),
                .rst_n      (rst_n),

                .raw_pwm    (raw_pwm[phase_index]),

                .pwm_hi     (pwm_hi[phase_index]),
                .pwm_lo     (pwm_lo[phase_index])

            );

        end

    endgenerate

endmodule