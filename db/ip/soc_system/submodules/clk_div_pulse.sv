module clk_div_pulse #(
    parameter int DIV_FACTOR = 'd8   // Division factor: output pulse frequency = clk / DIV_FACTOR
)(
    input  logic clk,        // Input main clock
    input  logic rst_n,      // Asynchronous active-low reset
    output logic pulse       // Output single-cycle pulse at divided clock rising edge
);

    // Counter for clock division
    logic [$clog2(DIV_FACTOR)-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 'd0;
            pulse   <= 1'b0;
        end else begin
            if (counter == DIV_FACTOR - 'd1) begin
                counter <= 'd0;
                pulse   <= 1'b1;   // Generate a single-cycle pulse at rising edge of divided clock
            end else begin
                counter <= counter + 'd1;
                pulse   <= 1'b0;
            end
        end
    end

endmodule
