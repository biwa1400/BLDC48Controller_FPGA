module sdram_dma_top #(
    parameter INPUT_ARRAY_SIZE = 52
)(
    input  logic        clk,
    input  logic        rst_n,

    // AXI Master Interface
    output logic [31:0] master_address,
    output logic        master_write,
    output logic [3:0]  master_byteenable,
    output logic [31:0] master_writedata,
    output logic [4:0]  master_burstcount,
    input  logic        master_waitrequest,

    // AXI Register Interface
    input  logic        chipselect,
    input  logic [1:0]  as_address,
    input  logic        as_write,
    input  logic [31:0] as_writedata,
    input  logic        as_read,
    output logic [31:0] as_readdata,

    // Data input
    input  logic [7:0]  input_array [0:INPUT_ARRAY_SIZE-1]
);

    // Internal signals
    logic [31:0] segment_base_address;
    logic [31:0] segment_max_offset;
    logic [31:0] segment_offset;
    logic        init;
    logic        pulse;
    logic        sample_enable;
    logic        sample_req;
    logic        busy;
    logic        reset_offset;
    logic        continuous_buffer_mode;
    logic        continuous_buffer_mode_en;
    logic        continuous_buffer_done;

    // Control interface
    sdram_dma_control_if u_control_if (
        .clk                 (clk),
        .rst_n               (rst_n),
        .chipselect          (chipselect),
        .as_address          (as_address),
        .as_write            (as_write),
        .as_writedata        (as_writedata),
        .as_read             (as_read),
        .as_readdata         (as_readdata),
        .segment_base_address(segment_base_address),
        .segment_max_offset  (segment_max_offset),
        .segment_offset      (segment_offset),
        .init                (init),
        .continuous_buffer_mode_en (continuous_buffer_mode_en),
        .continuous_buffer_done    (continuous_buffer_done)
    );

    // Clock divider
    clk_div_pulse #(.DIV_FACTOR(100)) u_clk_div_pulse (
        .clk   (clk),
        .rst_n (rst_n),
        .pulse (pulse)
    );

    // Pulse latch
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sample_req <= 1'b0;
        else begin
            if (pulse)
                sample_req <= 1'b1;
            else if (~busy)
                sample_req <= 1'b0;
        end
    end

    // Continuous buffer mode
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            continuous_buffer_mode <= 1'b0;
        else begin
            if (continuous_buffer_mode_en)
                continuous_buffer_mode <= 1'b1;
            else if (segment_offset == segment_max_offset)
                continuous_buffer_mode <= 1'b0;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            continuous_buffer_done <= 1'b0;
        else begin
            if (segment_offset == segment_max_offset)
                continuous_buffer_done <= 1'b1;
            else if (continuous_buffer_mode_en)
                continuous_buffer_done <= 1'b0;
        end
    end

    assign sample_enable = sample_req & ~busy;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            reset_offset <= 1'b1;
        else begin
            if (continuous_buffer_mode)
                reset_offset <= 1'b0;
            else
                reset_offset <= 1'b1;
        end
    end

    // Instantiate sdram_axi_dma
    sdram_axi_dma #(
        .INPUT_ARRAY_SIZE(INPUT_ARRAY_SIZE)
    ) u_sdram_axi_dma (
        .clk                 (clk),
        .rst_n               (rst_n),
        .master_address      (master_address),
        .master_write        (master_write),
        .master_byteenable   (master_byteenable),
        .master_writedata    (master_writedata),
        .master_burstcount   (master_burstcount),
        .master_waitrequest  (master_waitrequest),
        .input_array         (input_array),
        .sample_enable       (sample_enable),
        .segment_base_address(segment_base_address),
        .segment_max_offset  (segment_max_offset),
        .segment_offset      (segment_offset),
        .busy                (busy),
        .init                (init),
        .reset_offset        (reset_offset)
    );

endmodule
