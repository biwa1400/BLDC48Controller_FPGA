// Module: peak_current_detector
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: Detect peak current in each cycle for multiple ADC channels

module peak_current_detector #(
    parameter ADC_BITS = 12,
    parameter NUM_CHANNELS = 22
) (
    input  wire                          clk,
    input  wire signed [ADC_BITS:0]      i_adc_value [NUM_CHANNELS-1:0],
    output reg  signed [ADC_BITS:0]      o_adc_value [NUM_CHANNELS-1:0]
);

    // Threshold and zero constants, automatically adapt to ADC_BITS
    localparam signed [ADC_BITS:0] THRESHOLD = 50;
    localparam signed [ADC_BITS:0] ZERO      = '0;

    // Internal registers to store maximum value of each channel
    reg signed [ADC_BITS:0] max_adc_value [NUM_CHANNELS-1:0];

    integer i;

    // Initialize max values to ZERO
    initial begin
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin
            max_adc_value[i] = ZERO;
            o_adc_value[i]   = ZERO;
        end
    end

    // Main sequential logic
    always @(posedge clk) begin
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin
            // Update output: if signal falls below threshold and a valid max exists
            if (i_adc_value[i] < THRESHOLD && max_adc_value[i] != ZERO) begin
                o_adc_value[i] <= max_adc_value[i];
            end

            // Update maximum value
            if (i_adc_value[i] > THRESHOLD && i_adc_value[i] > max_adc_value[i]) begin
                max_adc_value[i] <= i_adc_value[i];
            end
            // Reset max when signal is strongly negative
            else if (i_adc_value[i] < -THRESHOLD) begin
                max_adc_value[i] <= ZERO;
            end
        end
    end

endmodule
