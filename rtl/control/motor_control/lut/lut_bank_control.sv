
// ============================================================================
// lut_bank_control.sv
//
// BLDC48Controller FPGA
// LUT A/B bank control.
//
// Responsibilities:
//   - Maintain current active LUT bank.
//   - Latch LUT commit requests.
//   - Delay bank switching until a safe calculation boundary.
//   - Block switching during LUT verification.
//   - Toggle active bank atomically.
//   - Generate commit acknowledgement.
//
// Bank convention:
//   0 = Bank A
//   1 = Bank B
//
// ============================================================================

module lut_bank_control (
    input  logic clk_50MHz,
    input  logic rst_n,

    // Commit request from ARM
    input  logic lut_commit_req,

    // Calculation boundary permission
    input  logic safe_switch,

    // High while LUT verification is in progress.
    // A pending COMMIT must not execute while this is asserted.
    input  logic verify_lock,

    // Status
    output logic active_bank,
    output logic commit_pending,
    output logic lut_commit_ack
);

    // ========================================================================
    // Bank / commit state machine
    // ========================================================================

    always_ff @(posedge clk_50MHz) begin

        if (!rst_n) begin

            active_bank    <= 1'b0;
            commit_pending <= 1'b0;
            lut_commit_ack <= 1'b0;

        end
        else begin

            // ACK remains asserted until request is released.
            if (lut_commit_ack) begin

                if (!lut_commit_req) begin
                    lut_commit_ack <= 1'b0;
                end

            end
            else begin

                // Latch a new commit request.
                if (lut_commit_req) begin
                    commit_pending <= 1'b1;
                end

                // Commit only when:
                //   1. No calculation batch is active.
                //   2. No verification transaction holds the bank.
                //   3. A commit request is pending or newly asserted.
                if (
                    safe_switch &&
                    !verify_lock &&
                    (commit_pending || lut_commit_req)
                ) begin

                    active_bank    <= ~active_bank;
                    commit_pending <= 1'b0;
                    lut_commit_ack <= 1'b1;

                end

            end

        end

    end

endmodule
