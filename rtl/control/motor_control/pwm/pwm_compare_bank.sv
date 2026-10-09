// ============================================================================
// pwm_compare_bank.sv
//
// BLDC48Controller FPGA
//
// 22-phase center-aligned PWM comparator bank.
//
// Inputs:
//
//     carrier
//         Shared center-aligned PWM carrier.
//
//     direction_down
//         0 = rising half
//         1 = falling half
//
//     compare_active[0:21]
//         Active 22-phase PWM compare commands.
//
// Output:
//
//     raw_pwm[21:0]
//         Registered raw PWM state before complementary gate generation
//         and deadtime.
//
// Comparator definition:
//
//     compare == 0
//         raw_pwm = 0
//
//     compare == PWM_TOP
//         raw_pwm = 1
//
//     otherwise
//
//         raw_pwm =
//             (carrier < compare)
//             OR
//             ((carrier == compare) AND direction_down)
//
// This comparator definition is intentionally asymmetric at equality.
//
// Rising half:
//
//     carrier == compare  -> OFF
//
// Falling half:
//
//     carrier == compare  -> ON
//
// With the frozen carrier sequence:
//
//     rising:
//         0 ... PWM_TOP-1
//
//     falling:
//         PWM_TOP ... 1
//
// the exact number of HIGH samples per complete PWM frame is:
//
//     HIGH clocks = 2 * compare
//
// Therefore:
//
//     duty = compare / PWM_TOP
//
// including the exact endpoint behavior:
//
//     compare = 0
//         0% duty
//
//     compare = PWM_TOP
//         100% duty
//
// Timing:
//
//     The combinational comparator result is registered at clk_200MHz before
//     being passed to the complementary deadtime logic.
//
//     This adds one clk_200MHz period of fixed latency to raw_pwm while
//     preserving the comparator definition, duty ratio, and relative phase
//     relationship between all 22 channels.
//
// Architectural constants come exclusively from motor_control_pkg.sv.
//
// ============================================================================

module pwm_compare_bank (

    input  logic        clk_200MHz,
    input  logic        rst_n,

    input  logic [12:0] carrier,
    input  logic        direction_down,

    input  logic [12:0] compare_active [0:21],

    output logic [21:0] raw_pwm

);

    import motor_control_pkg::*;


    integer i;


    // ========================================================================
    // Combinational PWM comparator results
    // ========================================================================

    logic [21:0] raw_pwm_next;


    // ========================================================================
    // 22-phase PWM comparator bank
    // ========================================================================

    always_comb begin

        // Safe/default combinational value.

        raw_pwm_next = 22'd0;


        for (i = 0; i < NUM_PHASES; i = i + 1) begin


            // ----------------------------------------------------------------
            // Exact 0% duty endpoint
            // ----------------------------------------------------------------

            if (compare_active[i] == 13'd0) begin

                raw_pwm_next[i] =
                    1'b0;

            end


            // ----------------------------------------------------------------
            // Exact 100% duty endpoint
            // ----------------------------------------------------------------

            else if (compare_active[i] >= PWM_TOP) begin

                raw_pwm_next[i] =
                    1'b1;

            end


            // ----------------------------------------------------------------
            // Normal center-aligned PWM comparison
            // ----------------------------------------------------------------

            else begin

                if (carrier < compare_active[i]) begin

                    raw_pwm_next[i] =
                        1'b1;

                end

                else if ((carrier == compare_active[i]) &&
                         direction_down) begin

                    raw_pwm_next[i] =
                        1'b1;

                end

                else begin

                    raw_pwm_next[i] =
                        1'b0;

                end

            end

        end

    end


    // ========================================================================
    // 200 MHz PWM comparator output pipeline
    // ========================================================================
    //
    // Register the complete 22-phase comparator result before it enters the
    // deadtime bank.
    //
    // This breaks the timing path:
    //
    //     carrier / compare_active
    //         ->
    //     PWM comparator
    //         ->
    //     deadtime state logic
    //         ->
    //     gate output registers
    //
    // into two independent 200 MHz timing paths.
    //
    // All 22 channels are registered on the same clock edge, preserving their
    // relative phase relationship.
    //
    // ========================================================================

    always_ff @(posedge clk_200MHz) begin

        if (!rst_n) begin

            raw_pwm <=
                22'd0;

        end
        else begin

            raw_pwm <=
                raw_pwm_next;

        end

    end


endmodule