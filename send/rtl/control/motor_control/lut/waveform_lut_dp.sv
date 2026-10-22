// ============================================================================
// waveform_lut_dp.sv
// BLDC48Controller FPGA - dual-bank 4096 x 13-bit waveform LUT
// One synchronous write port and one shared synchronous read port per bank.
// Verification responses are registered separately from calculation RAM data.
// ============================================================================
module waveform_lut_dp (
    input  logic        clk_50MHz,
    input  logic        rst_n,
    input  logic        active_bank,
    input  logic        wr_en,
    input  logic        wr_bank,
    input  logic [11:0] wr_addr,
    input  logic [12:0] wr_data,
    input  logic        rd_bank,
    input  logic        rd_en,
    input  logic [11:0] rd_addr,
    output logic [12:0] rd_data,
    input  logic        verify_en,
    input  logic        verify_bank,
    input  logic [11:0] verify_addr,
    output logic [12:0] verify_data,
    output logic        verify_valid,
    input  logic        calc_batch_busy
);
    logic [12:0] bank_a [0:4095];
    logic [12:0] bank_b [0:4095];
    logic [12:0] bank_a_q;
    logic [12:0] bank_b_q;
    logic        rd_bank_q;
    logic        verify_pending_q;
    logic        verify_bank_q;

    wire wr_en_a = wr_en && !wr_bank && active_bank;
    wire wr_en_b = wr_en && wr_bank && !active_bank;

    // A verification request is accepted only for the inactive bank and
    // only when that bank's read port is not owned by calculation.
    wire verify_allowed =
        rst_n && verify_en && (verify_bank != active_bank) &&
        !(calc_batch_busy && (verify_bank == rd_bank_q)) &&
        !(rd_en && (rd_bank == verify_bank));
    wire verify_accept_a = verify_allowed && !verify_bank;
    wire verify_accept_b = verify_allowed && verify_bank;

    wire read_a_en = (rd_en && !rd_bank) || verify_accept_a;
    wire read_b_en = (rd_en && rd_bank) || verify_accept_b;
    wire [11:0] read_a_addr = (rd_en && !rd_bank) ? rd_addr : verify_addr;
    wire [11:0] read_b_addr = (rd_en && rd_bank) ? rd_addr : verify_addr;

    // Keep the memory read itself registered so Quartus can infer block RAM.
    // No reset or initialization is applied to either RAM array.
    always @(posedge clk_50MHz) begin
        if (wr_en_a)
            bank_a[wr_addr] <= wr_data;
        if (read_a_en)
            bank_a_q <= bank_a[read_a_addr];
    end

    always @(posedge clk_50MHz) begin
        if (wr_en_b)
            bank_b[wr_addr] <= wr_data;
        if (read_b_en)
            bank_b_q <= bank_b[read_b_addr];
    end

    // The calculation output remains a one-clock synchronous RAM read.
    always_ff @(posedge clk_50MHz) begin
        if (!rst_n)
            rd_bank_q <= 1'b0;
        else if (rd_en)
            rd_bank_q <= rd_bank;
    end

    always_comb begin
        if (!rst_n)
            rd_data = 13'd0;
        else
            rd_data = rd_bank_q ? bank_b_q : bank_a_q;
    end

    // Cycle N: accept request and read bank_* into bank_*_q.
    // Cycle N+1: capture the requested bank's RAM output into verify_data,
    //            assert verify_valid. The response remains stable afterward.
    // This avoids sharing a changing calculation RAM output with Avalon.
    always_ff @(posedge clk_50MHz) begin
        if (!rst_n) begin
            verify_pending_q <= 1'b0;
            verify_bank_q    <= 1'b0;
            verify_data      <= 13'd0;
            verify_valid     <= 1'b0;
        end
        else begin
            verify_pending_q <= verify_allowed;
            if (verify_allowed)
                verify_bank_q <= verify_bank;

            verify_valid <= verify_pending_q;
            if (verify_pending_q)
                verify_data <= verify_bank_q ? bank_b_q : bank_a_q;
        end
    end
endmodule
