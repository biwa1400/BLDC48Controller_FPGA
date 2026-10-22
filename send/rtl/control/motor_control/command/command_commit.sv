// ============================================================================
// command_commit.sv
//
// BLDC48Controller FPGA
//
// Atomic 22-phase PWM command commit.
//
// Purpose:
//
//     compare_shadow[0:21]
//             |
//             | shadow_ready
//             v
//        pending storage
//             |
//             | wait for PWM frame boundary
//             v
//     compare_active[0:21]
//
// The PWM subsystem must never observe a partially updated 22-phase command
// frame.
//
// A complete shadow frame is captured when shadow_ready is asserted.
// The captured frame is then committed atomically to compare_active only at
// pwm_frame_boundary.
//
// Clock-domain note:
//
//     compare_shadow / shadow_ready : produced by 50 MHz calculation logic
//     compare_active                : consumed by 200 MHz PWM logic
//
// The project currently uses related PLL clocks (50 MHz and 200 MHz) and
// intentionally does not introduce an asynchronous FIFO here.
//
// Proper generated-clock timing constraints must therefore be applied during
// synthesis / timing analysis.
//
// Architectural constants come exclusively from motor_control_pkg.sv.
//
// ============================================================================

module command_commit (

    input  logic        clk_200MHz,
    input  logic        rst_n,

    // ------------------------------------------------------------------------
    // Completed calculation frame
    // ------------------------------------------------------------------------

    input  logic [12:0] compare_shadow [0:21],

    // One complete 22-phase calculation frame is ready.
    input  logic        shadow_ready,

    // ------------------------------------------------------------------------
    // PWM timing
    // ------------------------------------------------------------------------

    input  logic        pwm_frame_boundary,

    // ------------------------------------------------------------------------
    // Active command frame used by PWM
    // ------------------------------------------------------------------------

    output logic [12:0] compare_active [0:21],

    // Indicates that a complete command frame is waiting for the next
    // PWM frame boundary.
    output logic        commit_pending,

    // One clk_200MHz pulse when compare_active is atomically updated.
    output logic        commit_pulse

);

    import motor_control_pkg::*;


    // ========================================================================
    // Pending command frame
    // ========================================================================
    //
    // We do not commit directly from compare_shadow.
    //
    // Instead, when shadow_ready is observed, all 22 values are copied into
    // this pending frame.
    //
    // This gives the PWM side a stable complete frame while it waits for the
    // next PWM frame boundary.
    //
    // ========================================================================

    logic [12:0] compare_pending [0:21];

    integer i;


    // ========================================================================
    // Capture and atomic commit
    // ========================================================================

    always_ff @(posedge clk_200MHz) begin

        if (!rst_n) begin

            commit_pending <=
                1'b0;

            commit_pulse <=
                1'b0;


            for (i = 0; i < NUM_PHASES; i = i + 1) begin

                compare_pending[i] <=
                    PWM_CENTER;

                compare_active[i] <=
                    PWM_CENTER;

            end

        end
        else begin

            // commit_pulse is normally low.
            // It is asserted for exactly one clk_200MHz cycle whenever a
            // complete pending frame becomes the new active frame.

            commit_pulse <=
                1'b0;


            // ----------------------------------------------------------------
            // Capture a newly completed calculation frame.
            // ----------------------------------------------------------------
            //
            // All 22 compare values are captured together.
            //
            // If another completed calculation frame arrives before the
            // previous pending frame has been committed, the newest complete
            // frame replaces the previous pending frame.
            //
            // This is intentional:
            //
            //     - partial frames are never used
            //     - stale intermediate command frames do not need to queue
            //     - PWM always receives the newest complete available command
            //
            // ----------------------------------------------------------------

            if (shadow_ready) begin

                for (i = 0; i < NUM_PHASES; i = i + 1) begin

                    compare_pending[i] <=
                        compare_shadow[i];

                end

                commit_pending <=
                    1'b1;

            end


            // ----------------------------------------------------------------
            // Atomic active-frame update.
            // ----------------------------------------------------------------
            //
            // compare_active may change only at a PWM frame boundary.
            //
            // All 22 values are updated on the same clk_200MHz edge.
            //
            // ----------------------------------------------------------------

            if (pwm_frame_boundary && commit_pending) begin

                for (i = 0; i < NUM_PHASES; i = i + 1) begin

                    compare_active[i] <=
                        compare_pending[i];

                end

                commit_pending <=
                    1'b0;

                commit_pulse <=
                    1'b1;

            end

        end

    end


endmodule