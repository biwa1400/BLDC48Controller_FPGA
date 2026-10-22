
module frame_sdram_dma_core #(
    parameter logic [31:0] BUFFER_BASE = 32'h10000000,
    parameter logic [31:0] MAX_HISTORY_FRAMES = 32'd2485512
) (
    input  logic         clk,
    input  logic         rst_n,

    // Frame input and periodic sampling trigger
    input  logic         sample_pulse,
    input  logic [863:0] input_array_flat,

    // Recording control
    input  logic         record_start,
    input  logic [31:0]  record_limit,

    // Avalon-MM write master
    output logic [31:0]  master_address,
    output logic         master_write,
    output logic [31:0]  master_writedata,
    output logic [3:0]   master_byteenable,
    output logic [4:0]   master_burstcount,
    input  logic         master_waitrequest,

    // Status for ARM control registers
    output logic [31:0]  frame_seq,
    output logic         frame_valid,
    output logic [31:0]  recorded_frame_count,
    output logic         recording_active,
    output logic         recording_done,
    output logic         busy
);

    // ============================================================
    // SDRAM Layout
    // ============================================================
    //
    // Latest frame:
    //   0x10000000 - 0x1000006B
    //   108 bytes, continuously overwritten.
    //
    // History frames:
    //   0x1000006C onward
    //   108 bytes per frame, sequential writes only.
    //
    // One frame = 27 x 32-bit Avalon-MM writes.
    // No FIFO and no additional frame queue.
    // ============================================================

    localparam logic [31:0] FRAME_BYTES  = 32'd108;
    localparam logic [31:0] HISTORY_BASE = BUFFER_BASE + FRAME_BYTES;
    localparam logic [4:0]  LAST_WORD    = 5'd26;

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_LIVE_WRITE,
        ST_HISTORY_WRITE
    } state_t;

    state_t state;

    // One immutable frame snapshot for both destinations.
    logic [863:0] snapshot;

    // Current word and history write address.
    logic [4:0]  word_index;
    logic [31:0] history_address;
    logic [31:0] active_record_limit;

    // At most one pending sampling request.
    // This stores a trigger, not frame data.
    logic sample_pending;

    // Pending recording command and its captured frame limit.
    logic        record_start_pending;
    logic [31:0] pending_record_limit;

    logic start_frame;
    logic accept_record_command;
    logic write_accepted;
    logic last_word_accepted;

    // ============================================================
    // Control Conditions
    // ============================================================

    assign busy = (state != ST_IDLE);

    // A recording command takes priority over a new frame.
    // This ensures the next sampled frame is recorded.
    assign accept_record_command =
        (state == ST_IDLE) &&
        record_start_pending &&
        !recording_active;

    assign start_frame =
        (state == ST_IDLE) &&
        !accept_record_command &&
        (sample_pending || sample_pulse);

    // An Avalon write is accepted only when waitrequest is low.
    assign write_accepted =
        master_write && !master_waitrequest;

    assign last_word_accepted =
        write_accepted && (word_index == LAST_WORD);

    // ============================================================
    // Avalon-MM Write Master
    // ============================================================
    //
    // Address is byte-addressed.
    // burstcount = 1: single 32-bit write per transaction.
    // byteenable = 1111: all four bytes enabled.
    //
    // While waitrequest is high, state and word_index hold,
    // so address, data and write remain stable.
    // ============================================================

    always_comb begin
        master_address    = 32'd0;
        master_write      = 1'b0;
        master_writedata  = 32'd0;
        master_byteenable = 4'b1111;
        master_burstcount = 5'd1;

        case (state)
            ST_LIVE_WRITE: begin
                master_address =
                    BUFFER_BASE + {25'd0, word_index, 2'b00};
                master_writedata =
                    snapshot[32 * word_index +: 32];
                master_write = 1'b1;
            end

            ST_HISTORY_WRITE: begin
                master_address =
                    history_address + {25'd0, word_index, 2'b00};
                master_writedata =
                    snapshot[32 * word_index +: 32];
                master_write = 1'b1;
            end

            default: begin
            end
        endcase
    end

    // ============================================================
    // Pending Sample Trigger
    // ============================================================
    //
    // A pulse received while DMA is busy is remembered.
    // Multiple pulses are merged into one pending request.
    //
    // If a new pulse arrives on the same cycle that a
    // pending request is consumed, preserve the new pulse.
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_pending <= 1'b0;
        end else if (start_frame) begin
            sample_pending <= sample_pulse && sample_pending;
        end else if (sample_pulse) begin
            sample_pending <= 1'b1;
        end
    end

    // ============================================================
    // Pending Recording Command
    // ============================================================
    //
    // Capture the command and frame limit together.
    // The command can wait until the DMA becomes idle.
    //
    // A command already pending or an active recording
    // prevents another command from being queued.
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            record_start_pending <= 1'b0;
            pending_record_limit <= MAX_HISTORY_FRAMES;
        end else begin
            if (accept_record_command) begin
                record_start_pending <= 1'b0;
            end else if (record_start &&
                         !record_start_pending &&
                         !recording_active) begin
                record_start_pending <= 1'b1;

                if (record_limit == 32'd0)
                    pending_record_limit <= 32'd1;
                else if (record_limit > MAX_HISTORY_FRAMES)
                    pending_record_limit <= MAX_HISTORY_FRAMES;
                else
                    pending_record_limit <= record_limit;
            end
        end
    end

    // ============================================================
    // DMA State Machine
    // ============================================================
    //
    // ST_IDLE:
    //   Accept recording command or capture a new snapshot.
    //
    // ST_LIVE_WRITE:
    //   Write 27 words to the fixed latest-frame address.
    //
    // ST_HISTORY_WRITE:
    //   Write the same 27 words to the next history address.
    //
    // After recording finishes, latest-frame updates continue.
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state                <= ST_IDLE;
            snapshot             <= '0;
            word_index           <= 5'd0;
            history_address      <= HISTORY_BASE;
            active_record_limit  <= MAX_HISTORY_FRAMES;
            recorded_frame_count <= 32'd0;
            recording_active     <= 1'b0;
            recording_done       <= 1'b0;
            frame_seq            <= 32'd0;
            frame_valid          <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    word_index <= 5'd0;

                    if (accept_record_command) begin
                        // Start a new recording before taking
                        // the next frame snapshot.
                        history_address      <= HISTORY_BASE;
                        active_record_limit  <= pending_record_limit;
                        recorded_frame_count <= 32'd0;
                        recording_active     <= 1'b1;
                        recording_done       <= 1'b0;

                    end else if (start_frame) begin
                        // Capture all 108 bytes simultaneously.
                        snapshot  <= input_array_flat;

                        // Odd sequence means the latest-frame
                        // SDRAM region is being overwritten.
                        frame_seq <= frame_seq + 32'd1;

                        state <= ST_LIVE_WRITE;
                    end
                end

                ST_LIVE_WRITE: begin
                    if (write_accepted) begin
                        if (last_word_accepted) begin
                            word_index <= 5'd0;

                            // Even sequence means all 27
                            // Avalon writes were accepted.
                            frame_seq   <= frame_seq + 32'd1;
                            frame_valid <= 1'b1;

                            if (recording_active)
                                state <= ST_HISTORY_WRITE;
                            else
                                state <= ST_IDLE;
                        end else begin
                            word_index <= word_index + 5'd1;
                        end
                    end
                end

                ST_HISTORY_WRITE: begin
                    if (write_accepted) begin
                        if (last_word_accepted) begin
                            word_index <= 5'd0;

                            // Count only fully accepted frames.
                            recorded_frame_count <=
                                recorded_frame_count + 32'd1;

                            history_address <=
                                history_address + FRAME_BYTES;

                            if (recorded_frame_count + 32'd1 >=
                                active_record_limit) begin
                                recording_active <= 1'b0;
                                recording_done   <= 1'b1;
                            end

                            state <= ST_IDLE;
                        end else begin
                            word_index <= word_index + 5'd1;
                        end
                    end
                end

                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

endmodule
