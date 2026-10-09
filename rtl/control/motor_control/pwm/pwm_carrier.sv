// ============================================================================
// pwm_carrier.sv
//
// BLDC48Controller FPGA
//
// Shared center-aligned PWM triangular carrier.
//
// Clock:
//     clk_200MHz
//
// Fixed architecture:
//     PWM_TOP           = 6666
//     PWM_PERIOD_CLOCKS = 13332
//
// Exact sampled carrier sequence:
//
//     Rising half:
//         0, 1, 2, ... 6665
//
//     Falling half:
//         6666, 6665, ... 2, 1
//
//     Then the next frame begins at:
//         0
//
// Therefore:
//
//     6666 rising samples
//   + 6666 falling samples
//   = 13332 clocks / PWM frame
//
// At 200 MHz:
//
//     PWM period    = 13332 * 5 ns = 66.66 us
//     PWM frequency = 200 MHz / 13332
//                   = approximately 15001.5 Hz
//
// direction_down:
//     0 = rising half
//     1 = falling half
//
// frame_boundary:
//
//     This is an EVENT indication for the clock edge that starts the next
//     PWM frame.
//
//     It is asserted while the CURRENT carrier state is:
//
//         carrier        = 1
//         direction_down = 1
//
//     Therefore, on the next clk_200MHz rising edge:
//
//         carrier        becomes 0
//         direction_down becomes 0
//
//     Any synchronous consumer using frame_boundary on that same edge can
//     atomically update its state exactly when the new PWM frame begins.
//
// Architectural constants come exclusively from motor_control_pkg.sv.
//
// ============================================================================

module pwm_carrier (

    input  logic        clk_200MHz,
    input  logic        rst_n,

    output logic [12:0] carrier,
    output logic        direction_down,
    output logic        frame_boundary

);

    import motor_control_pkg::*;


    // ========================================================================
    // PWM frame-boundary event
    // ========================================================================
    //
    // IMPORTANT:
    //
    // frame_boundary is intentionally combinational from the CURRENT carrier
    // state.
    //
    // When the falling carrier reaches 1, frame_boundary becomes high.
    //
    // At the following clk_200MHz rising edge:
    //
    //     carrier transitions 1 -> 0
    //
    // and synchronous consumers such as command_commit see
    // frame_boundary == 1 on that SAME edge.
    //
    // This avoids committing compare_active one clock late.
    //
    // ========================================================================

    always_comb begin

        if (rst_n &&
            direction_down &&
            (carrier == 13'd1)) begin

            frame_boundary = 1'b1;

        end
        else begin

            frame_boundary = 1'b0;

        end

    end


    // ========================================================================
    // Center-aligned triangular carrier
    // ========================================================================

    always_ff @(posedge clk_200MHz) begin

        if (!rst_n) begin

            carrier <=
                13'd0;

            direction_down <=
                1'b0;

        end
        else begin


            // ----------------------------------------------------------------
            // Rising half
            // ----------------------------------------------------------------

            if (!direction_down) begin

                if (carrier == (PWM_TOP - 1)) begin

                    // Current sample:
                    //
                    //     carrier        = PWM_TOP - 1
                    //     direction_down = 0
                    //
                    // Next sample:
                    //
                    //     carrier        = PWM_TOP
                    //     direction_down = 1

                    carrier <=
                        PWM_TOP;

                    direction_down <=
                        1'b1;

                end
                else begin

                    carrier <=
                        carrier + 13'd1;

                end

            end


            // ----------------------------------------------------------------
            // Falling half
            // ----------------------------------------------------------------

            else begin

                if (carrier == 13'd1) begin

                    // Current sample:
                    //
                    //     carrier        = 1
                    //     direction_down = 1
                    //
                    // frame_boundary is HIGH during this state.
                    //
                    // On this clock edge the next PWM frame begins:
                    //
                    //     carrier        = 0
                    //     direction_down = 0

                    carrier <=
                        13'd0;

                    direction_down <=
                        1'b0;

                end
                else begin

                    carrier <=
                        carrier - 13'd1;

                end

            end

        end

    end


endmodule