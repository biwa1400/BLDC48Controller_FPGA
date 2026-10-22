//==================================================================================================
// Module Name : drive_top
// Description : Top-level module for PWM generation with deadtime control.
//               It instantiates the deadtime_control module and provides 22 channels of PWM outputs.
// Parameters  : DEADTIME_LH - Deadtime for low-to-high transition (default 8)
//               DEADTIME_HL - Deadtime for high-to-low transition (default 8)
// Ports       :
//   Inputs  :
//     rstn      - Active-low reset
//     clk       - System clock
//     dtc       - Deadtime control value
//     pwm_duty  - Array of PWM duty cycles [0~21]
//   Outputs :
//     o_pwm_lo      - Array of low-side PWM outputs [0~21]
//     o_pwm_hi      - Array of high-side PWM outputs [0~21]
//     mos_power_en  - Always high signal to enable MOSFETs
//==================================================================================================

module drive_top #(
    parameter DEADTIME_LH = 8, // Deadtime low-to-high default
    parameter DEADTIME_HL = 8  // Deadtime high-to-low default
)(
    input  logic        deadtime_control_rstn,            // active low reset
    input  logic        clk_200MHz,             // system clock
    input  logic [6:0]  dtc,             // deadtime control value
    input  logic [12:0] pwm_duty [0:21], // PWM duty cycles array [0~21]
    output logic [21:0] o_pwm_lo, // PWM low side output array [0~21]
    output logic [21:0] o_pwm_hi, // PWM high side output array [0~21]
    output logic        mos_power_en     // MOSFET power enable, always high
);



    // Always enable MOSFET power
    assign mos_power_en = 1'b1;

    // Instantiate deadtime_control module with parameters
    deadtime_control #(
        .DEADTIME_LH(DEADTIME_LH), // Pass low-to-high deadtime
        .DEADTIME_HL(DEADTIME_HL)  // Pass high-to-low deadtime
    ) u_deadtime_control (
        .rstn      (deadtime_control_rstn),          // reset signal
        .clk       (clk_200MHz),           // clock signal
        .dtc       (dtc),           // deadtime control value

        // Expand PWM duty inputs
        .pwm1_duty (pwm_duty[0]),//.pwm1_duty (pwm_duty[0]),
        .pwm2_duty (pwm_duty[1]),
        .pwm3_duty (pwm_duty[2]),
        .pwm4_duty (pwm_duty[3]),
        .pwm5_duty (pwm_duty[4]),
        .pwm6_duty (pwm_duty[5]),
        .pwm7_duty (pwm_duty[6]),
        .pwm8_duty (pwm_duty[7]),
        .pwm9_duty (pwm_duty[8]),
        .pwm10_duty(pwm_duty[9]),
        .pwm11_duty(pwm_duty[10]),
        .pwm12_duty(pwm_duty[11]),
        .pwm13_duty(pwm_duty[12]),
        .pwm14_duty(pwm_duty[13]),
        .pwm15_duty(pwm_duty[14]),
        .pwm16_duty(pwm_duty[15]),
        .pwm17_duty(pwm_duty[16]),
        .pwm18_duty(pwm_duty[17]),
        .pwm19_duty(pwm_duty[18]),
        .pwm20_duty(pwm_duty[19]),
        .pwm21_duty(pwm_duty[20]),
        .pwm22_duty(pwm_duty[21]),

        // Expand PWM outputs
        .o_pwm_1_lo(o_pwm_lo[0]),
        .o_pwm_1_hi(o_pwm_hi[0]),
        .o_pwm_2_lo(o_pwm_lo[1]),
        .o_pwm_2_hi(o_pwm_hi[1]),
        .o_pwm_3_lo(o_pwm_lo[2]),
        .o_pwm_3_hi(o_pwm_hi[2]),
        .o_pwm_4_lo(o_pwm_lo[3]),
        .o_pwm_4_hi(o_pwm_hi[3]),
        .o_pwm_5_lo(o_pwm_lo[4]),
        .o_pwm_5_hi(o_pwm_hi[4]),
        .o_pwm_6_lo(o_pwm_lo[5]),
        .o_pwm_6_hi(o_pwm_hi[5]),
        .o_pwm_7_lo(o_pwm_lo[6]),
        .o_pwm_7_hi(o_pwm_hi[6]),
        .o_pwm_8_lo(o_pwm_lo[7]),
        .o_pwm_8_hi(o_pwm_hi[7]),
        .o_pwm_9_lo(o_pwm_lo[8]),
        .o_pwm_9_hi(o_pwm_hi[8]),
        .o_pwm_10_lo(o_pwm_lo[9]),
        .o_pwm_10_hi(o_pwm_hi[9]),
        .o_pwm_11_lo(o_pwm_lo[10]),
        .o_pwm_11_hi(o_pwm_hi[10]),
        .o_pwm_12_lo(o_pwm_lo[11]),
        .o_pwm_12_hi(o_pwm_hi[11]),
        .o_pwm_13_lo(o_pwm_lo[12]),
        .o_pwm_13_hi(o_pwm_hi[12]),
        .o_pwm_14_lo(o_pwm_lo[13]),
        .o_pwm_14_hi(o_pwm_hi[13]),
        .o_pwm_15_lo(o_pwm_lo[14]),
        .o_pwm_15_hi(o_pwm_hi[14]),
        .o_pwm_16_lo(o_pwm_lo[15]),
        .o_pwm_16_hi(o_pwm_hi[15]),
        .o_pwm_17_lo(o_pwm_lo[16]),
        .o_pwm_17_hi(o_pwm_hi[16]),
        .o_pwm_18_lo(o_pwm_lo[17]),
        .o_pwm_18_hi(o_pwm_hi[17]),
        .o_pwm_19_lo(o_pwm_lo[18]),
        .o_pwm_19_hi(o_pwm_hi[18]),
        .o_pwm_20_lo(o_pwm_lo[19]),
        .o_pwm_20_hi(o_pwm_hi[19]),
        .o_pwm_21_lo(o_pwm_lo[20]),
        .o_pwm_21_hi(o_pwm_hi[20]),
        .o_pwm_22_lo(o_pwm_lo[21]),
        .o_pwm_22_hi(o_pwm_hi[21])
    );

endmodule
