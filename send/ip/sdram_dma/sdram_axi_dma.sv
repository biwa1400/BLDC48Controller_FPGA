
module sdram_axi_dma #(
    parameter INPUT_ARRAY_SIZE = 108   // Parameterized input array size
)(
    // Clock & Reset
    input  logic        clk,
    input  logic        rst_n,

    // AXI Master Interface
    output logic [31:0] master_address,
    output logic        master_write,
    output logic [3:0]  master_byteenable,
    output logic [31:0] master_writedata,
    output logic [4:0]  master_burstcount,
    input  logic        master_waitrequest,

    // Input array
    input  logic [7:0]  input_array [0:INPUT_ARRAY_SIZE-1], // Parameterized array
     
    // Control ports
    input  logic        sample_enable,      // Trigger signal
    input  logic [31:0] segment_base_address,
    input  logic [31:0] segment_max_offset,
    output logic [31:0] segment_offset,
    input  logic        init,
    input  logic        reset_offset,
     
    // Busy signal
    output logic        busy                // High when FSM is busy
);

    // Internal control signals
    logic [31:0] control_write_base;
    logic        control_go;
    logic        control_done;

    // Internal user signals
    logic        user_write_buffer;
    logic [31:0] user_buffer_input_data;
    logic        user_buffer_full;

    // Index width automatically calculated based on array size
    logic [$clog2(INPUT_ARRAY_SIZE)-1:0] data_idx;
     
    logic [31:0] segment_offset_internal;

    // Instantiate AXI DMA
    axi_dma axi_dma_1 (
        .clk                    (clk),
        .reset                  (~rst_n),
        .master_address         (master_address),
        .master_write           (master_write),
        .master_byteenable      (master_byteenable),
        .master_writedata       (master_writedata),
        .master_burstcount      (master_burstcount),
        .master_waitrequest     (master_waitrequest),
        .control_fixed_location (0),
        .control_write_base     (control_write_base),
        .control_write_length   (INPUT_ARRAY_SIZE),
        .control_go             (control_go),
        .control_done           (control_done),
        .user_write_buffer      (user_write_buffer),
        .user_buffer_input_data (user_buffer_input_data),
        .user_buffer_full       (user_buffer_full)
    );

    // FSM state definition
    typedef enum logic [2:0] {
        INIT,
        WAIT_TRIGGER,
        REG_TO_BUFFER,
        WAIT_TRANSMIT,
        START_TRANSMIT
    } state_t;

    state_t current_state, next_state;

    // State register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= INIT;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = current_state;
        case(current_state)
            INIT:           if (init) next_state = WAIT_TRIGGER;
            WAIT_TRIGGER:   if (sample_enable) next_state = REG_TO_BUFFER;
            REG_TO_BUFFER:  if (data_idx >= INPUT_ARRAY_SIZE) next_state = WAIT_TRANSMIT;
            WAIT_TRANSMIT:  if (control_done) next_state = START_TRANSMIT;
            START_TRANSMIT: next_state = WAIT_TRIGGER;
        endcase
    end

    // User FIFO write logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            user_write_buffer      <= 1'b0;
            user_buffer_input_data <= 'd0;
            data_idx               <= 'd0;
        end else begin
            user_write_buffer <= 1'b0;

            case(current_state)
                WAIT_TRIGGER: data_idx <= 'd0;

                REG_TO_BUFFER: begin
                    if (data_idx + 'd4 <= INPUT_ARRAY_SIZE) begin
                        user_write_buffer      <= 1'b1;
                        user_buffer_input_data <= {input_array[data_idx+3],
                                                   input_array[data_idx+2],
                                                   input_array[data_idx+1],
                                                   input_array[data_idx]};
                        data_idx <= data_idx + 'd4;
                    end
                end
                default: ;
            endcase
        end
    end

    // Control signals for AXI DMA
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            control_write_base <= 'd0;
            control_go         <= 1'b0;
        end else begin
            control_go <= 1'b0;
            if (current_state == START_TRANSMIT) begin
                control_write_base <= INPUT_ARRAY_SIZE * segment_offset_internal + segment_base_address;
                control_go         <= 1'b1;
            end
        end
    end
     
    // Segment offset counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            segment_offset_internal <= 'd0;
        else if (current_state == START_TRANSMIT) begin
            if (reset_offset)
                segment_offset_internal <= 'd0;
            else if (segment_offset_internal < segment_max_offset)
                segment_offset_internal <= segment_offset_internal + 'd1;
            else
                segment_offset_internal <= 'd0;
        end
    end
     
    // Segment offset external
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            segment_offset <= 'd0;
        else if(current_state == START_TRANSMIT)
            segment_offset <= segment_offset_internal;
    end 

    // Busy signal
    always_comb begin
        busy = (current_state != WAIT_TRIGGER && current_state != INIT);
    end

endmodule
