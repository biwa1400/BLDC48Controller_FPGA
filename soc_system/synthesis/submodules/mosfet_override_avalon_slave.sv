// ============================================================================
// mosfet_override_avalon_slave.sv
// 44 independent output levels, controlled over Avalon-MM.
// Word addresses (32-bit words, NOT byte offsets):
// 0 CTRL: bit0 override enable (R/W)
// 1 OUTPUT_LO: bits 31:0 (R/W)
// 2 OUTPUT_HI: bits 11:0 = outputs 43:32 (R/W)
// 3 SET_LO: write-one-to-set outputs 31:0
// 4 CLEAR_LO: write-one-to-clear outputs 31:0
// 5 SET_HI: write-one-to-set outputs 43:32
// 6 CLEAR_HI: write-one-to-clear outputs 43:32
// 7 VERSION: constant 0x4D4F0001 ('MO', revision 1)
// Bit mapping: outputs 0..21 = LO 0..21, 22..43 = HI 0..21.
// No deadtime, interlock, or complementary output enforcement.
// Reset clears all outputs and disables override mode.
// ============================================================================
module mosfet_override_avalon_slave (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [2:0]  avs_address,
    input  logic        avs_write,
    input  logic        avs_read,
    input  logic [31:0] avs_writedata,
    output logic [31:0] avs_readdata,
    output logic        avs_waitrequest,
    output logic        override_enable,
    output logic [43:0] override_outputs
);
    assign avs_waitrequest = 1'b0;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            override_enable  <= 1'b0;
            override_outputs <= 44'b0;
        end else if (avs_write) begin
            case (avs_address)
                3'd0: override_enable <= avs_writedata[0];
                3'd1: override_outputs[31:0] <= avs_writedata;
                3'd2: override_outputs[43:32] <= avs_writedata[11:0];
                3'd3: override_outputs[31:0] <= override_outputs[31:0] | avs_writedata;
                3'd4: override_outputs[31:0] <= override_outputs[31:0] & ~avs_writedata;
                3'd5: override_outputs[43:32] <= override_outputs[43:32] | avs_writedata[11:0];
                3'd6: override_outputs[43:32] <= override_outputs[43:32] & ~avs_writedata[11:0];
                default: ;
            endcase
        end
    end

    always_comb begin
        avs_readdata = 32'b0;
        if (avs_read) begin
            case (avs_address)
                3'd0: avs_readdata = {31'b0, override_enable};
                3'd1: avs_readdata = override_outputs[31:0];
                3'd2: avs_readdata = {20'b0, override_outputs[43:32]};
                3'd7: avs_readdata = 32'h4D4F_0001;
                default: avs_readdata = 32'b0;
            endcase
        end
    end
endmodule
