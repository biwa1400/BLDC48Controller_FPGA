// ====================================================================
// Module: MBL600_encoder
// Type  : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: Generic incremental rotary encoder reader.
//           Used for DTC, Phase Advance, and VS Rho measurement.
// ====================================================================

module MBL600_encoder #(
    parameter int WIDTH        = 12,       // Output width
    parameter int SHIFT_RIGHT  = 2,        // Bit shift for scaling output
    parameter int FILTER_TAPS  = 25,       // Debounce filter taps
    parameter logic [WIDTH-1:0] VALUE_MIN = '0,   // Minimum count limit
    parameter logic [WIDTH-1:0] VALUE_MAX = 4095  // Maximum count limit
)(
    input  logic                     clk,        // System clock
    input  logic                     a,          // Encoder channel A
    input  logic                     b,          // Encoder channel B
    output logic [WIDTH-1:0]         value_wire  // Filtered and scaled output
);

    // ======================================================
    // Debounce filter for encoder signals
    // ======================================================
    logic [FILTER_TAPS-1:0] shift_reg_a = '0;
    logic [FILTER_TAPS-1:0] shift_reg_b = '0;
    logic a_filtered = 1'b0;
    logic b_filtered = 1'b0;

    always_ff @(posedge clk) begin
        shift_reg_a <= {shift_reg_a[FILTER_TAPS-2:0], a};
        shift_reg_b <= {shift_reg_b[FILTER_TAPS-2:0], b};

        // All bits are 1 → output high
        if (&shift_reg_a)
            a_filtered <= 1'b1;
        // All bits are 0 → output low
        else if (~|shift_reg_a)
            a_filtered <= 1'b0;

        if (&shift_reg_b)
            b_filtered <= 1'b1;
        else if (~|shift_reg_b)
            b_filtered <= 1'b0;
    end

    // ======================================================
    // Edge detection and direction decoding
    // ======================================================
    logic a_delayed = 1'b0;
    logic b_delayed = 1'b0;

    always_ff @(posedge clk) begin
        a_delayed <= a_filtered;
        b_delayed <= b_filtered;
    end

    logic count_enable;
    logic count_direction;

    always_comb begin
        count_enable    = a_filtered ^ a_delayed ^ b_filtered ^ b_delayed;
        count_direction = a_filtered ^ b_delayed;
    end

    // ======================================================
    // Main counting logic
    // ======================================================
    localparam int EXT_WIDTH = WIDTH + SHIFT_RIGHT;
    logic [EXT_WIDTH-1:0] value_reg = {VALUE_MIN, {SHIFT_RIGHT{1'b0}}};

    always_ff @(posedge clk) begin
        if (count_enable) begin
            if (count_direction) begin
                // Increment when direction is forward
                if (value_reg < {VALUE_MAX, {SHIFT_RIGHT{1'b0}}})
                    value_reg <= value_reg + 1'b1;
            end else begin
                // Decrement when direction is reverse
                if (value_reg > {VALUE_MIN, {SHIFT_RIGHT{1'b0}}})
                    value_reg <= value_reg - 1'b1;
            end
        end
    end

    // Output scaled value
    assign value_wire = value_reg[EXT_WIDTH-1:SHIFT_RIGHT];

endmodule
