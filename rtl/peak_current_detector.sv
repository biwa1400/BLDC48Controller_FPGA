// ============================================================================
// peak_current_detector.sv
//
// 22 independent peak current detectors.
//
// Features:
// 1. Fast upward peak update.
// 2. Downward update only after a confirmed cycle.
// 3. Positive threshold: +25.
// 4. Negative threshold: -25.
// 5. Negative qualification: 20 us continuously below -25.
// 6. If no complete cycle is detected within 1 second,
//    automatically reset the output peak to zero.
// 7. Timeout works in both WAIT_POS and TRACK states.
// 8. Each channel has an independent timeout counter.
//
// Clock: 50 MHz
// No reset port (original interface preserved).
// ============================================================================

module peak_current_detector #(
    parameter ADC_BITS = 12,
    parameter NUM_CHANNELS = 22
) (
    input wire clk,
    input wire signed [ADC_BITS:0] i_adc_value [NUM_CHANNELS-1:0],
    output reg signed [ADC_BITS:0] o_adc_value [NUM_CHANNELS-1:0]
);

    // ========================================================================
    // Constants
    // ========================================================================

    localparam integer CLK_HZ = 50000000;

    // Negative half-cycle confirmation
    localparam integer NEG_CONFIRM_US = 20;

    localparam integer NEG_CONFIRM_CYCLES_RAW =
        (CLK_HZ / 1000000) * NEG_CONFIRM_US;

    localparam integer NEG_CONFIRM_CYCLES =
        (NEG_CONFIRM_CYCLES_RAW < 1) ? 1 : NEG_CONFIRM_CYCLES_RAW;

    localparam integer COUNT_BITS =
        (NEG_CONFIRM_CYCLES <= 1) ? 1 :
        $clog2(NEG_CONFIRM_CYCLES + 1);

    // Timeout: 1 second
    localparam integer TIMEOUT_SECONDS = 1;

    localparam integer TIMEOUT_CYCLES =
        CLK_HZ * TIMEOUT_SECONDS;

    localparam integer TIMEOUT_BITS =
        (TIMEOUT_CYCLES <= 1) ? 1 :
        $clog2(TIMEOUT_CYCLES);

    // Detection thresholds
    localparam signed [ADC_BITS:0] POS_THRESHOLD = 25;
    localparam signed [ADC_BITS:0] NEG_THRESHOLD = -25;

    // State machine
    localparam [0:0] WAIT_POS = 1'b0;
    localparam [0:0] TRACK    = 1'b1;

    // ========================================================================
    // Registers
    // ========================================================================

    reg state [NUM_CHANNELS-1:0];

    reg signed [ADC_BITS:0] cycle_max [NUM_CHANNELS-1:0];

    reg [COUNT_BITS-1:0] neg_count [NUM_CHANNELS-1:0];

    // Time since the last completed cycle
    reg [TIMEOUT_BITS-1:0] timeout_count [NUM_CHANNELS-1:0];

    // Prevent a constant positive input from repeatedly starting cycles
    // after timeout. A non-positive sample is required to rearm.
    reg rearm_required [NUM_CHANNELS-1:0];

    integer i;

    // ========================================================================
    // Initialization
    // ========================================================================

    initial begin
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin
            state[i] = WAIT_POS;
            cycle_max[i] = '0;
            neg_count[i] = '0;
            timeout_count[i] = '0;
            rearm_required[i] = 1'b0;
            o_adc_value[i] = '0;
        end
    end

    // ========================================================================
    // Peak detection
    // ========================================================================

    always @(posedge clk) begin

        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin

            // ================================================================
            // Global timeout
            //
            // Applies to BOTH states.
            // Reset only when a complete cycle is confirmed.
            // ================================================================

            if (timeout_count[i] >= TIMEOUT_CYCLES - 1) begin

                // No complete cycle for 1 second
                o_adc_value[i] <= '0;

                cycle_max[i] <= '0;
                neg_count[i] <= '0;

                state[i] <= WAIT_POS;

                timeout_count[i] <= '0;

                // Require a fresh positive transition before restarting
                rearm_required[i] <= 1'b1;

            end else begin

                // Count time regardless of detector state
                timeout_count[i] <= timeout_count[i] + 1'b1;

                // ============================================================
                // State machine
                // ============================================================

                case (state[i])

                    // --------------------------------------------------------
                    // WAIT_POS
                    // --------------------------------------------------------

                    WAIT_POS: begin

                        // Rearm only after input returns to
                        // zero or negative.
                        if (i_adc_value[i] <= 0)
                            rearm_required[i] <= 1'b0;

                        if ((i_adc_value[i] > POS_THRESHOLD) &&
                            !rearm_required[i]) begin

                            // Start new positive half-cycle
                            cycle_max[i] <= i_adc_value[i];

                            neg_count[i] <= '0;

                            state[i] <= TRACK;

                            // Fast upward update
                            if (i_adc_value[i] > o_adc_value[i])
                                o_adc_value[i] <= i_adc_value[i];

                        end

                    end

                    // --------------------------------------------------------
                    // TRACK
                    // --------------------------------------------------------

                    TRACK: begin

                        // Track maximum of current positive cycle
                        if (i_adc_value[i] > cycle_max[i])
                            cycle_max[i] <= i_adc_value[i];

                        // Immediate upward update
                        if (i_adc_value[i] > o_adc_value[i])
                            o_adc_value[i] <= i_adc_value[i];

                        // ----------------------------------------------------
                        // Negative half-cycle qualification
                        // ----------------------------------------------------

                        if (i_adc_value[i] < NEG_THRESHOLD) begin

                            if (neg_count[i] < NEG_CONFIRM_CYCLES - 1) begin

                                neg_count[i] <= neg_count[i] + 1'b1;

                            end else begin

                                // ============================================
                                // Complete cycle confirmed
                                // ============================================

                                // Downward update only at cycle boundary
                                if (cycle_max[i] < o_adc_value[i])
                                    o_adc_value[i] <= cycle_max[i];

                                // Prepare for next cycle
                                state[i] <= WAIT_POS;

                                cycle_max[i] <= '0;
                                neg_count[i] <= '0;

                                // Restart 1-second timeout
                                timeout_count[i] <= '0;

                                rearm_required[i] <= 1'b0;

                            end

                        end else begin

                            // Negative qualification interrupted
                            neg_count[i] <= '0;

                        end

                    end

                    // --------------------------------------------------------
                    // Default
                    // --------------------------------------------------------

                    default: begin

                        state[i] <= WAIT_POS;

                        cycle_max[i] <= '0;
                        neg_count[i] <= '0;

                        rearm_required[i] <= 1'b0;

                    end

                endcase

            end

        end

    end

endmodule