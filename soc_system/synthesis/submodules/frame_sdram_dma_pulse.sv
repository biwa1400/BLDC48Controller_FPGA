
module frame_sdram_dma_pulse #(
    parameter integer DIV_FACTOR = 100
) (
    input  logic clk,
    input  logic rst_n,
    output logic pulse
);

    localparam integer COUNTER_WIDTH =
        (DIV_FACTOR > 1) ? $clog2(DIV_FACTOR) : 1;

    logic [COUNTER_WIDTH-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;
            pulse   <= 1'b0;
        end else if (counter == DIV_FACTOR - 1) begin
            counter <= '0;
            pulse   <= 1'b1;
        end else begin
            counter <= counter + 1'b1;
            pulse   <= 1'b0;
        end
    end

endmodule
