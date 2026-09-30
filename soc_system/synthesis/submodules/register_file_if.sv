



module register_file_if (
    // Clock & Reset
    input  logic        clk,
    input  logic        rst_n,

    // AXI Slave Interface
    input  logic        chipselect,
    input  logic [1:0]  as_address,
    input  logic        as_write,
    input  logic [31:0] as_writedata,
    input  logic        as_read,
    output reg [31:0]   as_readdata,

    // Control & Input
	 output logic        run

);

    // ===================================
    // run register
    // ===================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            run <= 1'b0;
        else if (chipselect && as_write && as_address == 2'd0)
            run <= as_writedata[0];
    end



    // ===================================
    // Readback logic
    // ===================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            as_readdata <= 32'd0;
        else if (chipselect && as_read) begin
            case (as_address)
                2'd0: as_readdata <= {31'b0, run};
                default: as_readdata <= 32'd0;
            endcase
        end
    end

endmodule
