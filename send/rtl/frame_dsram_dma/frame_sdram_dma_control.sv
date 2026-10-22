
module frame_sdram_dma_control #(
    parameter logic [31:0] DEFAULT_BASE = 32'h10000000,
    parameter logic [31:0] MAX_HISTORY_FRAMES = 32'd2485512
) (
    input  logic        clk,
    input  logic        rst_n,

    // Avalon-MM slave interface
    // Address is a 32-bit register index, not a byte address.
    input  logic [2:0]  as_address,
    input  logic        as_read,
    input  logic        as_write,
    input  logic        chipselect,
    input  logic [31:0] as_writedata,
    output logic [31:0] as_readdata,

    // Status signals from DMA core
    input  logic [31:0] frame_seq,
    input  logic        frame_valid,
    input  logic [31:0] recorded_frame_count,
    input  logic        recording_active,
    input  logic        recording_done,
    input  logic        busy,

    // Control signals to DMA core
    output logic [31:0] record_limit,
    output logic        record_start
);

    // ============================================================
    // Avalon-MM Register Map
    // ============================================================
    //
    // Address  Byte Offset  Access  Description
    // ------------------------------------------------------------
    // 0x0      0x00         R/W     RECORD_LIMIT
    // 0x1      0x04         R/W     BUFFER_BASE
    // 0x2      0x08         R       RECORDED_COUNT
    // 0x3      0x0C         R/W     RECORD_CONTROL
    // 0x4      0x10         R       FRAME_SEQUENCE
    // 0x5      0x14         R       DMA_STATUS
    //
    // ============================================================

    // REG 0x0 - RECORD_LIMIT (R/W)
    // Number of history frames to record.
    // Valid range: 1 to MAX_HISTORY_FRAMES.
    // Writing 0 selects 1 frame.
    // Values above MAX_HISTORY_FRAMES are clamped.
    // Default: MAX_HISTORY_FRAMES.
    localparam logic [2:0] REG_LIMIT = 3'd0;

    // REG 0x1 - BUFFER_BASE (R/W)
    // Compatibility register for the existing ARM software.
    // The DMA core uses its fixed BUFFER_BASE parameter.
    // Writing this register does NOT change the DMA destination.
    // Default: 0x10000000.
    localparam logic [2:0] REG_BASE = 3'd1;

    // REG 0x2 - RECORDED_COUNT (Read Only)
    // Number of fully written history frames.
    // The count starts at 0 for each new recording.
    // Valid history data starts at BUFFER_BASE + 108 bytes.
    // Export size in bytes = RECORDED_COUNT * 108.
    localparam logic [2:0] REG_COUNT = 3'd2;

    // REG 0x3 - RECORD_CONTROL (Write / Read)
    //
    // Write:
    //   Bit 0 = 1 : Request a new history recording.
    //   Bit 0 = 0 : No action.
    //   Bits 31:1 : Ignored.
    //
    // Read:
    //   Bit 0 = recording_done.
    //   Bits 31:1 = 0.
    //
    // recording_done:
    //   0 = Recording not completed.
    //   1 = Requested history recording completed.
    //
    // The DMA continues updating the latest-frame buffer
    // after history recording has finished.
    localparam logic [2:0] REG_CTRL = 3'd3;

    // REG 0x4 - FRAME_SEQUENCE (Read Only)
    // Sequence counter for the latest-frame buffer only.
    //
    //   Odd value  = Latest frame is being overwritten.
    //   Even value = Latest frame write has completed.
    //
    // ARM reading procedure:
    //   1. Check frame_valid.
    //   2. Read sequence_before.
    //   3. Reject if sequence_before is odd.
    //   4. Copy 108 bytes from 0x10000000.
    //   5. Read sequence_after.
    //   6. Accept only if both values are equal and even.
    //
    // Memory ordering and DMA write visibility must also
    // be handled correctly by the system integration.
    //
    // History frames do not require sequence checking
    // after recording_done has been safely published.
    localparam logic [2:0] REG_SEQ = 3'd4;

    // REG 0x5 - DMA_STATUS (Read Only)
    //
    // Bit 0: frame_valid
    //   1 = At least one latest frame has been completed.
    //
    // Bit 1: recording_active
    //   1 = History recording is currently active.
    //
    // Bit 2: busy
    //   1 = DMA core is currently transferring a frame.
    //
    // Bit 3: recording_done
    //   1 = History recording has completed.
    //
    // Bits 31:4 = 0.
    localparam logic [2:0] REG_STATUS = 3'd5;

    // ============================================================
    // Internal Registers
    // ============================================================

    logic [31:0] base_register;

    // ============================================================
    // Register Write Logic
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            record_limit  <= MAX_HISTORY_FRAMES;
            base_register <= DEFAULT_BASE;
            record_start  <= 1'b0;
        end else begin
            // Generate a one-clock-cycle recording start pulse.
            record_start <= 1'b0;

            if (chipselect && as_write) begin
                case (as_address)
                    REG_LIMIT: begin
                        if (as_writedata == 32'd0)
                            record_limit <= 32'd1;
                        else if (as_writedata > MAX_HISTORY_FRAMES)
                            record_limit <= MAX_HISTORY_FRAMES;
                        else
                            record_limit <= as_writedata;
                    end

                    REG_BASE: begin
                        base_register <= as_writedata;
                    end

                    REG_CTRL: begin
                        if (as_writedata[0] &&
                            !recording_active &&
                            !record_start)
                            record_start <= 1'b1;
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

    // ============================================================
    // Register Read Logic
    // ============================================================

    always_comb begin
        as_readdata = 32'd0;

        if (chipselect && as_read) begin
            case (as_address)
                REG_LIMIT:
                    as_readdata = record_limit;

                REG_BASE:
                    as_readdata = base_register;

                REG_COUNT:
                    as_readdata = recorded_frame_count;

                REG_CTRL:
                    as_readdata = {31'd0, recording_done};

                REG_SEQ:
                    as_readdata = frame_seq;

                REG_STATUS:
                    as_readdata = {
                        28'd0,
                        recording_done,
                        busy,
                        recording_active,
                        frame_valid
                    };

                default:
                    as_readdata = 32'd0;
            endcase
        end
    end

endmodule
