// ============================================================================
// deadtime_channel.sv
//
// BLDC48Controller FPGA
//
// Single-phase complementary MOSFET gate generator with deadtime.
//
// Input:
//     raw_pwm = 1 : Request HIGH-side ON
//     raw_pwm = 0 : Request LOW-side  ON
//
// Safety:
//     pwm_hi && pwm_lo must NEVER be true.
//
// Deadtime:
//     DEADTIME_CLOCKS = 36
//
// At 200 MHz:
//     Clock period = 5 ns
//     Deadtime     = 36 * 5 ns = 180 ns
//
// Switching:
//     LOW -> HIGH:
//         LOW turns OFF.
//         Wait 36 clock periods.
//         HIGH turns ON if request remains HIGH.
//
//     HIGH -> LOW:
//         HIGH turns OFF.
//         Wait 36 clock periods.
//         LOW turns ON if request remains LOW.
//
// If raw_pwm changes during deadtime:
//     - Cancel previous pending turn-on.
//     - Keep both outputs OFF.
//     - Restart deadtime for the new target.
//
// Reset:
//     Both outputs OFF.
//
// ============================================================================

module deadtime_channel #(

    parameter int DEADTIME_CLOCKS = 36

)(

    input  logic clk_200MHz,
    input  logic rst_n,

    input  logic raw_pwm,

    output logic pwm_hi,
    output logic pwm_lo

);

    // ========================================================================
    // Counter width
    // ========================================================================

    localparam int COUNTER_WIDTH =
        (DEADTIME_CLOCKS <= 1)
        ? 1
        : $clog2(DEADTIME_CLOCKS);


    // ========================================================================
    // Internal state
    // ========================================================================

    logic pending_target;

    logic deadtime_active;

    logic [COUNTER_WIDTH-1:0] deadtime_counter;


    // ========================================================================
    // Complementary gate state machine
    // ========================================================================

    always_ff @(posedge clk_200MHz) begin

        if (!rst_n) begin

            pwm_hi <= 1'b0;
            pwm_lo <= 1'b0;

            pending_target <= 1'b0;

            deadtime_active <= 1'b0;

            deadtime_counter <= '0;

        end
        else begin

            // ================================================================
            // Deadtime active
            // ================================================================

            if (deadtime_active) begin

                pwm_hi <= 1'b0;
                pwm_lo <= 1'b0;


                // Input changed during deadtime.
                // Restart full deadtime interval.

                if (raw_pwm != pending_target) begin

                    pending_target <= raw_pwm;

                    deadtime_counter <= '0;

                end

                else begin

                    // Final deadtime clock reached.

                    if (deadtime_counter ==
                        (DEADTIME_CLOCKS - 1)) begin

                        deadtime_active <= 1'b0;

                        deadtime_counter <= '0;


                        if (pending_target) begin

                            pwm_hi <= 1'b1;
                            pwm_lo <= 1'b0;

                        end
                        else begin

                            pwm_hi <= 1'b0;
                            pwm_lo <= 1'b1;

                        end

                    end
                    else begin

                        deadtime_counter <=
                            deadtime_counter + 1'b1;

                    end

                end

            end


            // ================================================================
            // No active deadtime
            // ================================================================

            else begin

                // ------------------------------------------------------------
                // HIGH-side currently ON
                // ------------------------------------------------------------

                if (pwm_hi) begin

                    if (!raw_pwm) begin

                        pwm_hi <= 1'b0;
                        pwm_lo <= 1'b0;

                        pending_target <= 1'b0;

                        deadtime_active <= 1'b1;

                        deadtime_counter <= '0;

                    end

                end


                // ------------------------------------------------------------
                // LOW-side currently ON
                // ------------------------------------------------------------

                else if (pwm_lo) begin

                    if (raw_pwm) begin

                        pwm_hi <= 1'b0;
                        pwm_lo <= 1'b0;

                        pending_target <= 1'b1;

                        deadtime_active <= 1'b1;

                        deadtime_counter <= '0;

                    end

                end


                // ------------------------------------------------------------
                // Both outputs OFF
                // ------------------------------------------------------------

                else begin

                    pwm_hi <= 1'b0;
                    pwm_lo <= 1'b0;

                    pending_target <= raw_pwm;

                    deadtime_active <= 1'b1;

                    deadtime_counter <= '0;

                end

            end

        end

    end

endmodule