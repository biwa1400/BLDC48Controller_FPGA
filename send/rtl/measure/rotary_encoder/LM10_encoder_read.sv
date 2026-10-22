// LM10 A/B/Z incremental encoder. 50 MHz clock assumed for RPM scaling.
// Position: modulo LM10_COUNTS, homed on first qualified Z reference.
// Subsequent Z events correct position only near the expected index.
module LM10_encoder_read #(
    parameter integer LM10_WIDTH = 13,
    parameter integer LM10_COUNTS = 6400,
    parameter integer Z_WINDOW_COUNTS = 16,
    parameter integer AB_FILTER_CYCLES = 10,
    parameter integer Z_FILTER_CYCLES = 25,
    parameter integer RPM_SAMPLE_CYCLES = 468750
) (
    input wire clk,
    input wire a,
    input wire b,
    input wire z,
    output wire ref_ready,
    output wire [LM10_WIDTH-1:0] regout,
    output reg signed [15:0] rpm
);
    reg [1:0] a_sync = 2'b00;
    reg [1:0] b_sync = 2'b00;
    reg [1:0] z_sync = 2'b00;
    always @(posedge clk) begin
        a_sync <= {a_sync[0], a};
        b_sync <= {b_sync[0], b};
        z_sync <= {z_sync[0], z};
    end

    reg [AB_FILTER_CYCLES-1:0] a_hist = {AB_FILTER_CYCLES{1'b0}};
    reg [AB_FILTER_CYCLES-1:0] b_hist = {AB_FILTER_CYCLES{1'b0}};
    reg [Z_FILTER_CYCLES-1:0] z_hist = {Z_FILTER_CYCLES{1'b0}};
    reg a_f = 1'b0;
    reg b_f = 1'b0;
    reg z_f = 1'b0;
    always @(posedge clk) begin
        a_hist <= {a_hist[AB_FILTER_CYCLES-2:0], a_sync[1]};
        b_hist <= {b_hist[AB_FILTER_CYCLES-2:0], b_sync[1]};
        z_hist <= {z_hist[Z_FILTER_CYCLES-2:0], z_sync[1]};
        if (&a_hist) a_f <= 1'b1;
        else if (~|a_hist) a_f <= 1'b0;
        if (&b_hist) b_f <= 1'b1;
        else if (~|b_hist) b_f <= 1'b0;
        if (&z_hist) z_f <= 1'b1;
        else if (~|z_hist) z_f <= 1'b0;
    end

    reg [1:0] ab_prev = 2'b00;
    reg ab_initialized = 1'b0;
    wire [1:0] ab_now = {a_f, b_f};
    wire ab_step = (ab_now != ab_prev) && ((ab_now ^ ab_prev) == 2'b01 || (ab_now ^ ab_prev) == 2'b10);
    // Matches original direction convention for a single legal A/B edge.
    wire step_up = a_f ^ ab_prev[0];
    wire signed [1:0] step_delta = step_up ? 2'sd1 : -2'sd1;
    reg [LM10_WIDTH-1:0] position = {LM10_WIDTH{1'b0}};
    reg homed = 1'b0;
    assign ref_ready = homed;
    assign regout = position;

    reg z_qualified_prev = 1'b0;
    reg z_armed = 1'b1;
    wire z_qualified = a_f && b_f && z_f;
    wire z_event = z_armed && z_qualified && !z_qualified_prev;
    wire near_index = (position <= Z_WINDOW_COUNTS) ||
                      (position >= LM10_COUNTS - Z_WINDOW_COUNTS);
    wire index_accept = z_event && (!homed || near_index);

    reg [31:0] sample_counter = 32'd0;
    reg signed [15:0] rpm_accum = 16'sd0;
    wire sample_end = (sample_counter == RPM_SAMPLE_CYCLES - 1);
    initial rpm = 16'sd0;

    always @(posedge clk) begin
        if (!ab_initialized) begin
            ab_prev <= ab_now;
            ab_initialized <= 1'b1;
        end else if (ab_now != ab_prev) begin
            ab_prev <= ab_now;
        end

        z_qualified_prev <= z_qualified;
        if (!z_f) z_armed <= 1'b1;
        else if (z_event) z_armed <= 1'b0;

        if (index_accept) begin
            position <= {LM10_WIDTH{1'b0}};
            homed <= 1'b1;
        end else if (homed && ab_initialized && ab_step) begin
            if (step_up)
                position <= (position == LM10_COUNTS - 1) ? {LM10_WIDTH{1'b0}} : position + 1'b1;
            else
                position <= (position == 0) ? LM10_COUNTS - 1 : position - 1'b1;
        end

        if (sample_end) begin
            sample_counter <= 32'd0;
            rpm <= rpm_accum;
            rpm_accum <= (ab_initialized && ab_step) ? {{14{step_delta[1]}}, step_delta} : 16'sd0;
        end else begin
            sample_counter <= sample_counter + 1'b1;
            if (ab_initialized && ab_step) rpm_accum <= rpm_accum + {{14{step_delta[1]}}, step_delta};
        end
    end
endmodule
