module frame_sdram_dma_top #(
    parameter integer DIV_FACTOR = 100,
    parameter logic [31:0] BUFFER_BASE = 32'h10000000,
    parameter logic [31:0] MAX_HISTORY_FRAMES = 32'd2485512
) (
    input  logic         clk,
    input  logic         rst_n,

    // ============================================================
    // Frame Input
    // ============================================================
    // 108 bytes = 27 x 32-bit words.
    // Input data must be coherent in the clk domain.
    // ============================================================

    input  logic [863:0] input_array_flat,

    // ============================================================
    // Avalon-MM Write Master
    // ============================================================
    // 32-bit data, byte-addressed, single-word transactions.
    // ============================================================

    output logic [31:0]  master_address,
    output logic         master_write,
    output logic [31:0]  master_writedata,
    output logic [3:0]   master_byteenable,
    output logic [4:0]   master_burstcount,
    input  logic         master_waitrequest,

    // ============================================================
    // Avalon-MM Control Slave
    // ============================================================
    // Address is a 32-bit register index.
    //
    // Register 0: Recording frame limit
    // Register 1: SDRAM base compatibility register
    // Register 2: Recorded history frame count
    // Register 3: Recording start / completion
    // Register 4: Latest-frame sequence ID
    // Register 5: DMA status
    // ============================================================

    input  logic [2:0]   as_address,
    input  logic         as_read,
    input  logic         as_write,
    input  logic         chipselect,
    input  logic [31:0]  as_writedata,
    output logic [31:0]  as_readdata
);

    // ============================================================
    // Internal Connections
    // ============================================================

    logic         sample_pulse;
    logic         record_start;
    logic [31:0]  record_limit;

    logic [31:0]  frame_seq;
    logic         frame_valid;
    logic [31:0]  recorded_frame_count;
    logic         recording_active;
    logic         recording_done;
    logic         busy;

    // ============================================================
    // Periodic Sampling Trigger
    // ============================================================

    frame_sdram_dma_pulse #(
        .DIV_FACTOR(DIV_FACTOR)
    ) u_pulse (
        .clk   (clk),
        .rst_n (rst_n),
        .pulse (sample_pulse)
    );

    // ============================================================
    // SDRAM DMA Core
    // ============================================================

    frame_sdram_dma_core #(
        .BUFFER_BASE(BUFFER_BASE),
        .MAX_HISTORY_FRAMES(MAX_HISTORY_FRAMES)
    ) u_core (
        .clk                  (clk),
        .rst_n                (rst_n),

        .sample_pulse         (sample_pulse),
        .input_array_flat     (input_array_flat),

        .record_start         (record_start),
        .record_limit         (record_limit),

        .master_address       (master_address),
        .master_write         (master_write),
        .master_writedata     (master_writedata),
        .master_byteenable    (master_byteenable),
        .master_burstcount    (master_burstcount),
        .master_waitrequest   (master_waitrequest),

        .frame_seq            (frame_seq),
        .frame_valid          (frame_valid),
        .recorded_frame_count (recorded_frame_count),
        .recording_active     (recording_active),
        .recording_done       (recording_done),
        .busy                 (busy)
    );

    // ============================================================
    // ARM Control and Status Registers
    // ============================================================

    frame_sdram_dma_control #(
        .DEFAULT_BASE(BUFFER_BASE),
        .MAX_HISTORY_FRAMES(MAX_HISTORY_FRAMES)
    ) u_control (
        .clk                  (clk),
        .rst_n                (rst_n),

        .as_address           (as_address),
        .as_read              (as_read),
        .as_write             (as_write),
        .chipselect           (chipselect),
        .as_writedata         (as_writedata),
        .as_readdata          (as_readdata),

        .frame_seq            (frame_seq),
        .frame_valid          (frame_valid),
        .recorded_frame_count (recorded_frame_count),
        .recording_active     (recording_active),
        .recording_done       (recording_done),
        .busy                 (busy),

        .record_limit         (record_limit),
        .record_start         (record_start)
    );

endmodule
