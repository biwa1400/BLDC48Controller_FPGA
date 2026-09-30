module top #(
    parameter INPUT_ARRAY_SIZE = 56  
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

    // Flattened input array
    input  logic [8*INPUT_ARRAY_SIZE-1:0] input_array_flat
);

    // Unpacked array
    logic [7:0] input_array [0:INPUT_ARRAY_SIZE-1];

    // =========================
    // Unpack flattened array
    // =========================
    genvar i;
    generate
        for (i = 0; i < INPUT_ARRAY_SIZE; i = i + 1) begin: unpack_loop
            assign input_array[i] = input_array_flat[i*8 +: 8];
        end
    endgenerate

    // =========================
    // Instantiate original top
    // =========================
    sdram_dma_top #(
        .INPUT_ARRAY_SIZE(INPUT_ARRAY_SIZE) 
    ) u_sdram_dma_top (
        .clk                 (clk),
        .rst_n               (rst_n),
        .master_address      (master_address),
        .master_write        (master_write),
        .master_byteenable   (master_byteenable),
        .master_writedata    (master_writedata),
        .master_burstcount   (master_burstcount),
        .master_waitrequest  (master_waitrequest),
        .chipselect          (chipselect),
        .as_address          (as_address),
        .as_write            (as_write),
        .as_writedata        (as_writedata),
        .as_read             (as_read),
        .as_readdata         (as_readdata),
        .input_array         (input_array)
    );

endmodule
