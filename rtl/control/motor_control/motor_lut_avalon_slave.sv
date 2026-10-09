
// ============================================================================
// motor_lut_avalon_slave.sv
// BLDC48Controller FPGA - Avalon-MM dual-bank LUT adapter
//
// Word address map:
//   0x0000 CONTROL: bit 0 COMMIT (write 1), bit 1 UPDATE_LOCK,
//                   bit 2 clear sticky error (write 1)
//   0x0001 STATUS:  bit 0 active bank, bit 1 commit ACK,
//                   bit 2 sticky access error, bit 3 UPDATE_LOCK
//   0x1000-0x1FFF: 4096 LUT words (13 significant bits)
//
// A locked update targets the bank inactive when the lock was acquired.
// A COMMIT request is accepted only after a separate unlock write.
// SRAM verification reads are synchronous and use Avalon waitrequest.
// The clock must be shared with the motor LUT interface (50 MHz).
//
// Fix:
//   Capture verify_valid in both RD_ISSUE and RD_WAIT.
//   This prevents missing a response that arrives during RD_ISSUE.
// ============================================================================
module motor_lut_avalon_slave (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [12:0] avs_address,
    input  logic        avs_write,
    input  logic        avs_read,
    input  logic [31:0] avs_writedata,
    output logic [31:0] avs_readdata,
    output logic        avs_waitrequest,
    output logic        lut_wr_en,
    output logic        lut_wr_bank,
    output logic [11:0] lut_wr_addr,
    output logic [12:0] lut_wr_data,
    output logic        lut_commit_req,
    input  logic        lut_active_bank,
    input  logic        lut_commit_ack,
    output logic        lut_verify_lock,
    output logic        lut_verify_en,
    output logic        lut_verify_bank,
    output logic [11:0] lut_verify_addr,
    input  logic [12:0] lut_verify_data,
    input  logic        lut_verify_valid
);
    localparam logic [12:0] ADDR_CONTROL = 13'h0000;
    localparam logic [12:0] ADDR_STATUS  = 13'h0001;
    localparam logic [12:0] ADDR_LUT    = 13'h1000;

    typedef enum logic [1:0] {
        RD_IDLE,
        RD_ISSUE,
        RD_WAIT,
        RD_RESP
    } rd_state_t;

    rd_state_t rd_state;

    logic [11:0] read_addr_q;
    logic        target_bank_q;
    logic [12:0] read_data_q;
    logic        access_error;
    logic        control_write;
    logic        lut_write;
    logic        lut_read;

    assign control_write = avs_write && !avs_waitrequest &&
                           (avs_address == ADDR_CONTROL);

    assign lut_write = avs_write && !avs_waitrequest &&
                       avs_address[12];

    assign lut_read = avs_read && avs_address[12];

    assign lut_wr_en = lut_write &&
                       lut_verify_lock &&
                       !lut_commit_req &&
                       !lut_commit_ack &&
                       (target_bank_q != lut_active_bank);

    assign lut_wr_bank = target_bank_q;
    assign lut_wr_addr = avs_address[11:0];
    assign lut_wr_data = avs_writedata[12:0];

    assign lut_verify_en   = (rd_state == RD_ISSUE);
    assign lut_verify_bank = target_bank_q;
    assign lut_verify_addr = read_addr_q;

    // Avalon waitrequest
    always_comb begin
        avs_waitrequest = 1'b0;

        if (rd_state != RD_IDLE) begin
            avs_waitrequest = (rd_state != RD_RESP);
        end
        else if (lut_read) begin
            avs_waitrequest = 1'b1;
        end
    end

    // Avalon read data
    always_comb begin
        avs_readdata = 32'd0;

        if (avs_read) begin
            if (rd_state == RD_RESP) begin
                avs_readdata = {19'd0, read_data_q};
            end
            else if (rd_state == RD_IDLE) begin
                case (avs_address)
                    ADDR_CONTROL: begin
                        avs_readdata[0] = lut_commit_req;
                        avs_readdata[1] = lut_verify_lock;
                    end

                    ADDR_STATUS: begin
                        avs_readdata[0] = lut_active_bank;
                        avs_readdata[1] = lut_commit_ack;
                        avs_readdata[2] = access_error;
                        avs_readdata[3] = lut_verify_lock;
                    end

                    default: begin
                        avs_readdata = 32'd0;
                    end
                endcase
            end
        end
    end

    // Control registers and read state machine
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            lut_commit_req  <= 1'b0;
            lut_verify_lock <= 1'b0;
            target_bank_q   <= 1'b1;
            access_error    <= 1'b0;
            read_addr_q     <= 12'd0;
            read_data_q     <= 13'd0;
            rd_state        <= RD_IDLE;
        end
        else begin
            // Keep COMMIT asserted until acknowledged.
            if (lut_commit_ack)
                lut_commit_req <= 1'b0;

            if (control_write) begin
                if (avs_writedata[2])
                    access_error <= 1'b0;

                // Lock acquisition snapshots the inactive bank.
                if (avs_writedata[1] && !lut_verify_lock) begin
                    if (!lut_commit_req && !lut_commit_ack) begin
                        lut_verify_lock <= 1'b1;
                        target_bank_q <= ~lut_active_bank;
                    end
                    else begin
                        access_error <= 1'b1;
                    end
                end
                else if (!avs_writedata[1] && lut_verify_lock) begin
                    if (rd_state == RD_IDLE)
                        lut_verify_lock <= 1'b0;
                    else
                        access_error <= 1'b1;
                end

                // COMMIT is a distinct transaction after unlock.
                if (avs_writedata[0]) begin
                    if (!lut_verify_lock &&
                        !avs_writedata[1] &&
                        !lut_commit_req &&
                        !lut_commit_ack) begin
                        lut_commit_req <= 1'b1;
                    end
                    else begin
                        access_error <= 1'b1;
                    end
                end
            end

            if (lut_write && !lut_wr_en)
                access_error <= 1'b1;

            case (rd_state)
                RD_IDLE: begin
                    if (lut_read) begin
                        read_addr_q <= avs_address[11:0];

                        if (lut_verify_lock &&
                            !lut_commit_req &&
                            !lut_commit_ack &&
                            (target_bank_q != lut_active_bank)) begin
                            rd_state <= RD_ISSUE;
                        end
                        else begin
                            read_data_q <= 13'd0;
                            access_error <= 1'b1;
                            rd_state <= RD_RESP;
                        end
                    end
                end

                RD_ISSUE: begin
                    // A previous request may return its response
                    // while the state machine is issuing a retry.
                    if (lut_verify_valid) begin
                        read_data_q <= lut_verify_data;
                        rd_state <= RD_RESP;
                    end
                    else begin
                        rd_state <= RD_WAIT;
                    end
                end

                RD_WAIT: begin
                    if (lut_verify_valid) begin
                        read_data_q <= lut_verify_data;
                        rd_state <= RD_RESP;
                    end
                    else begin
                        rd_state <= RD_ISSUE;
                    end
                end

                RD_RESP: begin
                    rd_state <= RD_IDLE;
                end

                default: begin
                    rd_state <= RD_IDLE;
                end
            endcase
        end
    end
endmodule
