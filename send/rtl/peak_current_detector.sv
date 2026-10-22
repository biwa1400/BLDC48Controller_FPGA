// ============================================================================
// peak_current_detector.sv
// Fast upward update; downward update only at a confirmed positive-half-cycle
// end. 22 independent channels. No reset port (original interface preserved).
//
// Clock is assumed to be 50 MHz. ADC samples may be held between updates.
// Negative qualification requires a continuous 20 us below NEG_THRESHOLD.
// This delays falling updates but rejects brief negative spikes.
// ============================================================================
module peak_current_detector #(
    parameter ADC_BITS = 12,
    parameter NUM_CHANNELS = 22
) (
    input wire clk,
    input wire signed [ADC_BITS:0] i_adc_value [NUM_CHANNELS-1:0],
    output reg signed [ADC_BITS:0] o_adc_value [NUM_CHANNELS-1:0]
);
    localparam integer CLK_HZ = 50000000;
    localparam integer NEG_CONFIRM_US = 20;
    localparam integer NEG_CONFIRM_CYCLES_RAW = (CLK_HZ / 1000000) * NEG_CONFIRM_US;
    localparam integer NEG_CONFIRM_CYCLES =
        (NEG_CONFIRM_CYCLES_RAW < 1) ? 1 : NEG_CONFIRM_CYCLES_RAW;
    localparam integer COUNT_BITS = (NEG_CONFIRM_CYCLES <= 1) ? 1 : $clog2(NEG_CONFIRM_CYCLES + 1);
    localparam signed [ADC_BITS:0] POS_THRESHOLD = 50;
    localparam signed [ADC_BITS:0] NEG_THRESHOLD = -50;

    localparam [0:0] WAIT_POS = 1'b0;
    localparam [0:0] TRACK = 1'b1;

    reg state [NUM_CHANNELS-1:0];
    reg signed [ADC_BITS:0] cycle_max [NUM_CHANNELS-1:0];
    reg [COUNT_BITS-1:0] neg_count [NUM_CHANNELS-1:0];

    integer i;
    initial begin
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin
            state[i] = WAIT_POS;
            cycle_max[i] = '0;
            neg_count[i] = '0;
            o_adc_value[i] = '0;
        end
    end

    always @(posedge clk) begin
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin
            case (state[i])
                WAIT_POS: begin
                    if (i_adc_value[i] > POS_THRESHOLD) begin
                        cycle_max[i] <= i_adc_value[i];
                        neg_count[i] <= '0;
                        state[i] <= TRACK;
                        if (i_adc_value[i] > o_adc_value[i])
                            o_adc_value[i] <= i_adc_value[i];
                    end
                end
                TRACK: begin
                    if (i_adc_value[i] > cycle_max[i])
                        cycle_max[i] <= i_adc_value[i];
                    if (i_adc_value[i] > o_adc_value[i])
                        o_adc_value[i] <= i_adc_value[i];

                    if (i_adc_value[i] < NEG_THRESHOLD) begin
                        if (neg_count[i] < NEG_CONFIRM_CYCLES)
                            neg_count[i] <= neg_count[i] + 1'b1;
                        if (neg_count[i] >= NEG_CONFIRM_CYCLES - 1) begin
                            // The previous positive half-cycle is now complete.
                            // Never lower the output based on an unconfirmed
                            // local maximum within that half-cycle.
                            if (cycle_max[i] < o_adc_value[i])
                                o_adc_value[i] <= cycle_max[i];
                            state[i] <= WAIT_POS;
                            cycle_max[i] <= '0;
                            neg_count[i] <= '0;
                        end
                    end else begin
                        neg_count[i] <= '0;
                    end
                end
                default: begin
                    state[i] <= WAIT_POS;
                    cycle_max[i] <= '0;
                    neg_count[i] <= '0;
                end
            endcase
        end
    end
endmodule
