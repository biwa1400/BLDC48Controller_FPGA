// ============================================================================
// constants_pkg.sv
//
// BLDC48Controller FPGA
//
// Central configuration for motor control constants.
//
// ============================================================================

package constants_pkg;

    // ========================================================================
    // VS Rho configuration
    // ========================================================================

    // Minimum value AND initial power-up value
    parameter int VS_RHO_MIN = 12'd10;

    // Maximum allowed value
    parameter int VS_RHO_MAX = 12'd4095;


    // ========================================================================
    // Initial phase configuration
    // ========================================================================

    parameter int INIT_PHI = 13'd1022;


    // ========================================================================
    // PWM deadtime configuration
    // ========================================================================

    // FPGA clock frequency: 200 MHz
    // Clock period: 5 ns
    //
    // Deadtime (ns) = DEADTIME_CLOCKS * 5
    //
    // Examples:
    //      8 cycles =  40 ns
    //     20 cycles = 100 ns
    //     36 cycles = 180 ns (CURRENT)
    //     40 cycles = 200 ns
    //     60 cycles = 300 ns

    parameter int DEADTIME_CLOCKS = 36;

endpackage