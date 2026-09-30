module dummy_axi_if(
    input  logic        clk,
    input  logic        reset_n,
	 
    input  logic        as_chipselect,
    input  logic [1:0]  as_address,
    input  logic        as_write,
    output logic [31:0] as_readdata,
    input  logic [31:0] as_writedata
);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            as_readdata <= 32'd0;
        else if (as_chipselect) begin
            unique case (as_address)
                2'd0: as_readdata <= 32'd0;
                2'd1: as_readdata <= 32'd1;
                2'd2: as_readdata <= 32'd2;
                default: as_readdata <= 32'd3;
            endcase
        end
    end

endmodule
