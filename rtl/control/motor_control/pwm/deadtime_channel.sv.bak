// ============================================================================
// deadtime_channel.sv
//
// BLDC48Controller FPGA
//
// Single-phase complementary MOSFET gate generator with deadtime.
//
// Input:
//
//     raw_pwm = 1
//         Request HIGH-side ON
//         Request LOW-side  OFF
//
//     raw_pwm = 0
//         Request HIGH-side OFF
//         Request LOW-side  ON
//
// Outputs:
//
//     pwm_hi
//     pwm_lo
//
// Safety rule:
//
//     pwm_hi && pwm_lo must NEVER be true.
//
// Deadtime:
//
//     DEADTIME_CLOCKS = 8
//
// At 200 MHz:
//
//     clock period = 5 ns
//
// therefore:
//
//     deadtime = 8 * 5 ns = 40 ns
//
// Switching rule:
//
//     LOW -> HIGH request:
//
//         LOW turns OFF immediately.
//         HIGH remains OFF.
//         Wait 8 complete clk_200MHz periods.
//         HIGH turns ON only if raw_pwm is still HIGH.
//
//     HIGH -> LOW request:
//
//         HIGH turns OFF immediately.
//         LOW remains OFF.
//         Wait 8 complete clk_200MHz periods.
//         LOW turns ON only if raw_pwm is still LOW.
//
// If raw_pwm changes again while deadtime is active:
//
//     - the previous pending turn-on is cancelled
//     - both outputs remain OFF
//     - the deadtime counter restarts for the newly requested side
//
// Reset:
//
//     Both outputs OFF.
//
// Architectural constants come exclusively from motor_control_pkg.sv.
//
// ============================================================================

module deadtime_channel (

    input  logic clk_200MHz,
    input  logic rst_n,

    input  logic raw_pwm,

    output logic pwm_hi,
    output logic pwm_lo

);

    import motor_control_pkg::*;


    // ========================================================================
    // Internal state
    // ========================================================================

    // Requested side currently being delayed.
    //
    // 1 = HIGH-side is pending
    // 0 = LOW-side is pending

    logic pending_target;


    // Indicates that a deadtime interval is currently active.

    logic deadtime_active;


    // DEADTIME_CLOCKS = 8.
    //
    // Four bits are sufficient and keep the implementation simple.

    logic [3:0] deadtime_counter;


    // ========================================================================
    // Complementary gate state machine
    // ========================================================================

    always_ff @(posedge clk_200MHz) begin

        if (!rst_n) begin

            pwm_hi <=
                1'b0;

            pwm_lo <=
                1'b0;

            pending_target <=
                1'b0;

            deadtime_active <=
                1'b0;

            deadtime_counter <=
                4'd0;

        end
        else begin


            // =================================================================
            // Deadtime currently active
            // =================================================================

            if (deadtime_active) begin

                // During the entire deadtime interval both MOSFETs remain OFF.

                pwm_hi <=
                    1'b0;

                pwm_lo <=
                    1'b0;


                // -------------------------------------------------------------
                // Input changed again during deadtime
                // -------------------------------------------------------------
                //
                // Cancel the previous pending turn-on and restart the full
                // deadtime interval for the newly requested side.
                //
                // -------------------------------------------------------------

                if (raw_pwm != pending_target) begin

                    pending_target <=
                        raw_pwm;

                    deadtime_counter <=
                        4'd0;

                end


                // -------------------------------------------------------------
                // Requested state remained stable
                // -------------------------------------------------------------

                else begin

                    // Counter interpretation:
                    //
                    // counter = 0
                    //     first complete deadtime clock
                    //
                    // ...
                    //
                    // counter = DEADTIME_CLOCKS - 1
                    //     final deadtime clock
                    //
                    // The requested transistor is enabled on the following
                    // clock edge.
                    //
                    // This gives exactly DEADTIME_CLOCKS complete 200 MHz
                    // periods with both outputs OFF.

                    if (deadtime_counter ==
                        (DEADTIME_CLOCKS - 1)) begin

                        deadtime_active <=
                            1'b0;

                        deadtime_counter <=
                            4'd0;


                        if (pending_target) begin

                            pwm_hi <=
                                1'b1;

                            pwm_lo <=
                                1'b0;

                        end
                        else begin

                            pwm_hi <=
                                1'b0;

                            pwm_lo <=
                                1'b1;

                        end

                    end
                    else begin

                        deadtime_counter <=
                            deadtime_counter + 4'd1;

                    end

                end

            end


            // =================================================================
            // No deadtime currently active
            // =================================================================

            else begin


                // -------------------------------------------------------------
                // HIGH-side currently ON
                // -------------------------------------------------------------

                if (pwm_hi) begin

                    if (!raw_pwm) begin

                        // HIGH -> LOW transition requested.
                        //
                        // HIGH must turn OFF immediately.
                        // LOW must remain OFF.
                        // Begin deadtime before LOW may turn ON.

                        pwm_hi <=
                            1'b0;

                        pwm_lo <=
                            1'b0;

                        pending_target <=
                            1'b0;

                        deadtime_active <=
                            1'b1;

                        deadtime_counter <=
                            4'd0;

                    end

                end


                // -------------------------------------------------------------
                // LOW-side currently ON
                // -------------------------------------------------------------

                else if (pwm_lo) begin

                    if (raw_pwm) begin

                        // LOW -> HIGH transition requested.
                        //
                        // LOW must turn OFF immediately.
                        // HIGH must remain OFF.
                        // Begin deadtime before HIGH may turn ON.

                        pwm_hi <=
                            1'b0;

                        pwm_lo <=
                            1'b0;

                        pending_target <=
                            1'b1;

                        deadtime_active <=
                            1'b1;

                        deadtime_counter <=
                            4'd0;

                    end

                end


                // -------------------------------------------------------------
                // Both outputs currently OFF
                // -------------------------------------------------------------
                //
                // This occurs after reset and may also occur after external
                // control has held the channel inactive.
                //
                // We do NOT immediately enable either transistor.
                //
                // Instead, the requested side must first pass through the full
                // deadtime interval.
                //
                // This gives deterministic and safe startup behavior.
                //
                // -------------------------------------------------------------

                else begin

                    pwm_hi <=
                        1'b0;

                    pwm_lo <=
                        1'b0;

                    pending_target <=
                        raw_pwm;

                    deadtime_active <=
                        1'b1;

                    deadtime_counter <=
                        4'd0;

                end

            end

        end

    end


endmodule