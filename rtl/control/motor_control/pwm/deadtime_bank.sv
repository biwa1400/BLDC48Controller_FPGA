// ============================================================================
// deadtime_bank.sv
//
// BLDC48Controller FPGA
//
// 22-channel complementary gate deadtime bank.
//
// Each raw PWM channel is processed by one independent deadtime_channel:
//
//     raw_pwm[0]  -> deadtime_channel -> pwm_hi[0],  pwm_lo[0]
//     raw_pwm[1]  -> deadtime_channel -> pwm_hi[1],  pwm_lo[1]
//     ...
//     raw_pwm[21] -> deadtime_channel -> pwm_hi[21], pwm_lo[21]
//
// All channels share:
//
//     clk_200MHz
//     rst_n
//
// Each channel independently guarantees:
//
//     pwm_hi[n] && pwm_lo[n] == 0
//
// Physical deadtime is defined in motor_control_pkg.sv:
//
//     DEADTIME_CLOCKS = 8
//
// At 200 MHz:
//
//     8 * 5 ns = 40 ns
//
// ============================================================================

module deadtime_bank (

    input  logic        clk_200MHz,
    input  logic        rst_n,

    input  logic [21:0] raw_pwm,

    output logic [21:0] pwm_hi,
    output logic [21:0] pwm_lo

);

    import motor_control_pkg::*;


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

            deadtime_channel u_deadtime_channel (

                .clk_200MHz (
                    clk_200MHz
                ),

                .rst_n (
                    rst_n
                ),

                .raw_pwm (
                    raw_pwm[phase_index]
                ),

                .pwm_hi (
                    pwm_hi[phase_index]
                ),

                .pwm_lo (
                    pwm_lo[phase_index]
                )

            );

        end

    endgenerate


endmodule