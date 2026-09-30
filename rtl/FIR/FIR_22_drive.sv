module FIR_22_drive
#(
    parameter int unsigned TDM_FACTOR = 100,
    parameter int unsigned CHANNELS   = 22
)
(
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic [15:0] val_in  [0:CHANNELS-1],
    output logic [15:0] val_out [0:CHANNELS-1]
);

    // ============================================================
    // 22-channel two-stage FIR using shared MAC + M10K history RAM
    //
    // Per-channel signal path:
    //
    //   500 kSPS
    //      |
    //      v
    //   Stage 1: 23-tap anti-alias FIR
    //      |
    //      v
    //   Decimate by 10
    //      |
    //      v
    //    50 kSPS
    //      |
    //      v
    //   Stage 2: 37-tap 1 kHz low-pass FIR
    //      |
    //      v
    //    50 kSPS
    //
    // The two FIR stages share one signed multiplier datapath.
    //
    // Each history RAM is duplicated because one symmetric FIR MAC
    // needs two samples per clock.  Each copy has one synchronous
    // read port and one write port, which maps naturally to M10K.
    //
    // No history array is reset with a large for-loop.  STATE_INIT
    // clears the RAMs sequentially so Quartus can infer block RAM.
    // ============================================================

    localparam int STAGE1_TAPS   = 23;
    localparam int STAGE1_PAIRS  = 11;
    localparam int STAGE2_TAPS   = 37;
    localparam int STAGE2_PAIRS  = 18;
    localparam int DECIMATION    = 10;

    localparam int S1_WORDS      = CHANNELS * STAGE1_TAPS;
    localparam int S2_WORDS      = CHANNELS * STAGE2_TAPS;
    localparam int S1_ADDR_W     = (S1_WORDS <= 2) ? 1 : $clog2(S1_WORDS);
    localparam int S2_ADDR_W     = (S2_WORDS <= 2) ? 1 : $clog2(S2_WORDS);
    localparam int INIT_WORDS    = (S1_WORDS > S2_WORDS) ? S1_WORDS : S2_WORDS;
    localparam int INIT_ADDR_W   = (INIT_WORDS <= 2) ? 1 : $clog2(INIT_WORDS);
    localparam int SAMPLE_CNT_W  = (TDM_FACTOR <= 2) ? 1 : $clog2(TDM_FACTOR);


    // ============================================================
    // Q20 -> signed 16-bit conversion
    //
    // Uses symmetric rounding for positive and negative values.
    // ============================================================

    function automatic signed [15:0] q20_to_s16;
        input signed [40:0] value;
        reg   signed [40:0] scaled_value;
        begin
            if (value >= 0)
                scaled_value = (value + 41'sd524288) >>> 20;
            else
                scaled_value = -(((-value) + 41'sd524288) >>> 20);

            if (scaled_value > 41'sd32767)
                q20_to_s16 = 16'sh7FFF;
            else if (scaled_value < -41'sd32768)
                q20_to_s16 = 16'sh8000;
            else
                q20_to_s16 = scaled_value[15:0];
        end
    endfunction


    // ============================================================
    // Circular-pointer helpers
    // ============================================================

    function automatic [4:0] s1_inc_ptr;
        input [4:0] ptr;
        begin
            if (ptr == STAGE1_TAPS - 1)
                s1_inc_ptr = 5'd0;
            else
                s1_inc_ptr = ptr + 1'b1;
        end
    endfunction


    function automatic [5:0] s2_inc_ptr;
        input [5:0] ptr;
        begin
            if (ptr == STAGE2_TAPS - 1)
                s2_inc_ptr = 6'd0;
            else
                s2_inc_ptr = ptr + 1'b1;
        end
    endfunction


    function automatic [4:0] s1_sub_ptr;
        input [4:0] base;
        input [4:0] offset;
        integer temp;
        begin
            if (base >= offset)
                temp = base - offset;
            else
                temp = base + STAGE1_TAPS - offset;

            s1_sub_ptr = temp;
        end
    endfunction


    function automatic [5:0] s2_sub_ptr;
        input [5:0] base;
        input [5:0] offset;
        integer temp;
        begin
            if (base >= offset)
                temp = base - offset;
            else
                temp = base + STAGE2_TAPS - offset;

            s2_sub_ptr = temp;
        end
    endfunction


    function automatic [S1_ADDR_W-1:0] make_s1_addr;
        input [4:0] channel;
        input [4:0] ring_index;
        integer temp;
        begin
            temp = channel * STAGE1_TAPS + ring_index;
            make_s1_addr = temp;
        end
    endfunction


    function automatic [S2_ADDR_W-1:0] make_s2_addr;
        input [4:0] channel;
        input [5:0] ring_index;
        integer temp;
        begin
            temp = channel * STAGE2_TAPS + ring_index;
            make_s2_addr = temp;
        end
    endfunction


    // ============================================================
    // Stage-1 coefficient ROM
    // 23 taps, symmetric, Q20
    // ============================================================

    function automatic signed [18:0] stage1_coeff;
        input [4:0] index;
        begin
            case (index)
                5'd0:  stage1_coeff = 19'sd4680;
                5'd1:  stage1_coeff = 19'sd8016;
                5'd2:  stage1_coeff = 19'sd13939;
                5'd3:  stage1_coeff = 19'sd21714;
                5'd4:  stage1_coeff = 19'sd31157;
                5'd5:  stage1_coeff = 19'sd41838;
                5'd6:  stage1_coeff = 19'sd53095;
                5'd7:  stage1_coeff = 19'sd64092;
                5'd8:  stage1_coeff = 19'sd73915;
                5'd9:  stage1_coeff = 19'sd81688;
                5'd10: stage1_coeff = 19'sd86676;
                5'd11: stage1_coeff = 19'sd86956;
                default: stage1_coeff = 19'sd0;
            endcase
        end
    endfunction


    // ============================================================
    // Stage-2 coefficient ROM
    // 37 taps, symmetric, Q20
    // ============================================================

    function automatic signed [18:0] stage2_coeff;
        input [5:0] index;
        begin
            case (index)
                6'd0:  stage2_coeff =  19'sd3949;
                6'd1:  stage2_coeff =  19'sd2610;
                6'd2:  stage2_coeff =  19'sd2144;
                6'd3:  stage2_coeff =  19'sd371;
                6'd4:  stage2_coeff = -19'sd2809;
                6'd5:  stage2_coeff = -19'sd7087;
                6'd6:  stage2_coeff = -19'sd11660;
                6'd7:  stage2_coeff = -19'sd15278;
                6'd8:  stage2_coeff = -19'sd16405;
                6'd9:  stage2_coeff = -19'sd13504;
                6'd10: stage2_coeff = -19'sd5361;
                6'd11: stage2_coeff =  19'sd8560;
                6'd12: stage2_coeff =  19'sd27886;
                6'd13: stage2_coeff =  19'sd51245;
                6'd14: stage2_coeff =  19'sd76350;
                6'd15: stage2_coeff =  19'sd100359;
                6'd16: stage2_coeff =  19'sd120253;
                6'd17: stage2_coeff =  19'sd133400;
                6'd18: stage2_coeff =  19'sd138530;
                default: stage2_coeff = 19'sd0;
            endcase
        end
    endfunction


    // ============================================================
    // State machine
    // ============================================================

    typedef enum logic [3:0] {
        STATE_INIT,
        STATE_IDLE,
        STATE_S1_RUN,
        STATE_S1_DRAIN,
        STATE_S2_WRITE,
        STATE_S2_RUN,
        STATE_S2_DRAIN,
        STATE_COMMIT
    } fir_state_t;

    fir_state_t state;


    // ============================================================
    // 500 kSPS sample generator
    // ============================================================

    logic [SAMPLE_CNT_W-1:0] sample_counter;
    logic                    sample_valid;

    assign sample_valid =
        (state != STATE_INIT) &&
        (sample_counter == '0);


    // ============================================================
    // Input capture and Stage-1 serialized write engine
    //
    // val_in[0..21] is captured simultaneously every 100 clocks.
    // The 22 captured values are then written to M10K over 22 clocks.
    // ============================================================

    logic signed [15:0] input_latch [0:CHANNELS-1];

    logic                s1_write_active;
    logic [4:0]          s1_write_channel;
    logic [4:0]          s1_write_target_ptr;
    logic                s1_write_is_decim;

    logic [4:0]          s1_next_write_ptr;
    logic [4:0]          s1_base_ptr;

    logic [3:0]          decim_phase;


    // ============================================================
    // Stage-2 write pointer
    // ============================================================

    logic [5:0] s2_next_write_ptr;
    logic [5:0] s2_write_target_ptr;
    logic [5:0] s2_base_ptr;
    logic [4:0] s2_write_channel;


    // ============================================================
    // FIR results and shared accumulators
    //
    // Tap-major processing is intentional for Stage 1.  It ensures
    // the oldest pair for all 22 channels is consumed before the next
    // 500 kSPS sample can overwrite that circular-buffer location.
    // ============================================================

    logic signed [15:0] s1_result [0:CHANNELS-1];
    logic signed [15:0] s2_result [0:CHANNELS-1];
    logic signed [40:0] channel_acc [0:CHANNELS-1];


    // ============================================================
    // MAC issue counters
    // ============================================================

    logic [4:0] issue_channel;
    logic [5:0] issue_tap;


    // ============================================================
    // M10K RAM declarations
    //
    // Two identical copies per stage provide two simultaneous reads
    // for a symmetric FIR pair while still allowing one write.
    // ============================================================

    (* ramstyle = "M10K" *)
    logic signed [15:0] s1_ram_a [0:S1_WORDS-1];

    (* ramstyle = "M10K" *)
    logic signed [15:0] s1_ram_b [0:S1_WORDS-1];

    (* ramstyle = "M10K" *)
    logic signed [15:0] s2_ram_a [0:S2_WORDS-1];

    (* ramstyle = "M10K" *)
    logic signed [15:0] s2_ram_b [0:S2_WORDS-1];


    // ============================================================
    // RAM write interfaces
    // ============================================================

    logic                         s1_mem_we;
    logic [S1_ADDR_W-1:0]         s1_mem_waddr;
    logic signed [15:0]           s1_mem_wdata;

    logic                         s2_mem_we;
    logic [S2_ADDR_W-1:0]         s2_mem_waddr;
    logic signed [15:0]           s2_mem_wdata;


    // ============================================================
    // RAM synchronous read interfaces
    // ============================================================

    logic [S1_ADDR_W-1:0] s1_rd_addr_a;
    logic [S1_ADDR_W-1:0] s1_rd_addr_b;
    logic signed [15:0]   s1_rd_data_a;
    logic signed [15:0]   s1_rd_data_b;

    logic [S2_ADDR_W-1:0] s2_rd_addr_a;
    logic [S2_ADDR_W-1:0] s2_rd_addr_b;
    logic signed [15:0]   s2_rd_data_a;
    logic signed [15:0]   s2_rd_data_b;


    // ============================================================
    // Sequential RAM process
    //
    // No reset is applied to the RAM arrays or read-data registers.
    // STATE_INIT clears memory through the normal write ports.
    // ============================================================

    always_ff @(posedge clk_i) begin

        if (s1_mem_we) begin
            s1_ram_a[s1_mem_waddr] <= s1_mem_wdata;
            s1_ram_b[s1_mem_waddr] <= s1_mem_wdata;
        end

        s1_rd_data_a <= s1_ram_a[s1_rd_addr_a];
        s1_rd_data_b <= s1_ram_b[s1_rd_addr_b];

        if (s2_mem_we) begin
            s2_ram_a[s2_mem_waddr] <= s2_mem_wdata;
            s2_ram_b[s2_mem_waddr] <= s2_mem_wdata;
        end

        s2_rd_data_a <= s2_ram_a[s2_rd_addr_a];
        s2_rd_data_b <= s2_ram_b[s2_rd_addr_b];

    end


    // ============================================================
    // RAM initialization counter
    // ============================================================

    logic [INIT_ADDR_W-1:0] init_addr;


    // ============================================================
    // RAM write arbitration
    // ============================================================

    always_comb begin

        s1_mem_we    = 1'b0;
        s1_mem_waddr = '0;
        s1_mem_wdata = 16'sd0;

        s2_mem_we    = 1'b0;
        s2_mem_waddr = '0;
        s2_mem_wdata = 16'sd0;


        // --------------------------------------------------------
        // Sequential RAM clear after reset.
        // --------------------------------------------------------

        if (rst_ni && state == STATE_INIT) begin

            if (init_addr < S1_WORDS) begin
                s1_mem_we    = 1'b1;
                s1_mem_waddr = init_addr[S1_ADDR_W-1:0];
                s1_mem_wdata = 16'sd0;
            end

            if (init_addr < S2_WORDS) begin
                s2_mem_we    = 1'b1;
                s2_mem_waddr = init_addr[S2_ADDR_W-1:0];
                s2_mem_wdata = 16'sd0;
            end

        end

        else begin

            // ----------------------------------------------------
            // Stage-1 ADC history write.
            // ----------------------------------------------------

            if (s1_write_active) begin
                s1_mem_we = 1'b1;
                s1_mem_waddr = make_s1_addr(
                    s1_write_channel,
                    s1_write_target_ptr
                );
                s1_mem_wdata = input_latch[s1_write_channel];
            end


            // ----------------------------------------------------
            // Stage-2 history write.
            // ----------------------------------------------------

            if (state == STATE_S2_WRITE) begin
                s2_mem_we = 1'b1;
                s2_mem_waddr = make_s2_addr(
                    s2_write_channel,
                    s2_write_target_ptr
                );
                s2_mem_wdata = s1_result[s2_write_channel];
            end

        end

    end


    // ============================================================
    // RAM read-address generation
    // ============================================================

    logic [4:0] s1_left_ring;
    logic [4:0] s1_right_ring;

    logic [5:0] s2_left_ring;
    logic [5:0] s2_right_ring;


    always_comb begin

        s1_left_ring  = 5'd0;
        s1_right_ring = 5'd0;

        s2_left_ring  = 6'd0;
        s2_right_ring = 6'd0;

        s1_rd_addr_a = '0;
        s1_rd_addr_b = '0;

        s2_rd_addr_a = '0;
        s2_rd_addr_b = '0;


        if (state == STATE_S1_RUN) begin

            s1_left_ring = s1_sub_ptr(
                s1_base_ptr,
                issue_tap[4:0]
            );

            s1_right_ring = s1_sub_ptr(
                s1_base_ptr,
                (STAGE1_TAPS - 1) - issue_tap[4:0]
            );

            s1_rd_addr_a = make_s1_addr(
                issue_channel,
                s1_left_ring
            );

            s1_rd_addr_b = make_s1_addr(
                issue_channel,
                s1_right_ring
            );

        end


        if (state == STATE_S2_RUN) begin

            s2_left_ring = s2_sub_ptr(
                s2_base_ptr,
                issue_tap
            );

            s2_right_ring = s2_sub_ptr(
                s2_base_ptr,
                (STAGE2_TAPS - 1) - issue_tap
            );

            s2_rd_addr_a = make_s2_addr(
                issue_channel,
                s2_left_ring
            );

            s2_rd_addr_b = make_s2_addr(
                issue_channel,
                s2_right_ring
            );

        end

    end


    // ============================================================
    // One-cycle RAM-read metadata pipeline
    // ============================================================

    logic               mac_pipe_valid;
    logic               mac_pipe_stage2;
    logic               mac_pipe_center;
    logic [4:0]         mac_pipe_channel;
    logic [5:0]         mac_pipe_tap;
    logic signed [18:0] mac_pipe_coeff;


    // ============================================================
    // Single shared multiplier datapath
    // ============================================================

    logic signed [16:0] mac_sample;
    logic signed [18:0] mac_coeff;
    logic signed [35:0] mac_product;
    logic signed [40:0] mac_product_ext;


    always_comb begin

        mac_sample = 17'sd0;
        mac_coeff  = mac_pipe_coeff;

        if (mac_pipe_valid) begin

            if (mac_pipe_stage2) begin

                if (mac_pipe_center)
                    mac_sample = $signed(s2_rd_data_a);
                else
                    mac_sample =
                        $signed(s2_rd_data_a) +
                        $signed(s2_rd_data_b);

            end
            else begin

                if (mac_pipe_center)
                    mac_sample = $signed(s1_rd_data_a);
                else
                    mac_sample =
                        $signed(s1_rd_data_a) +
                        $signed(s1_rd_data_b);

            end

        end

        // The only FIR multiplication expression.
        mac_product = $signed(mac_sample) * $signed(mac_coeff);

        mac_product_ext = {
            {5{mac_product[35]}},
            mac_product
        };

    end


    // ============================================================
    // Main control process
    // ============================================================

    integer ch;

    always_ff @(posedge clk_i or negedge rst_ni) begin

        if (!rst_ni) begin

            state <= STATE_INIT;
            init_addr <= '0;

            sample_counter <= '0;
            decim_phase <= 4'd0;

            s1_write_active <= 1'b0;
            s1_write_channel <= 5'd0;
            s1_write_target_ptr <= 5'd0;
            s1_write_is_decim <= 1'b0;

            s1_next_write_ptr <= 5'd0;
            s1_base_ptr <= 5'd0;

            s2_next_write_ptr <= 6'd0;
            s2_write_target_ptr <= 6'd0;
            s2_base_ptr <= 6'd0;
            s2_write_channel <= 5'd0;

            issue_channel <= 5'd0;
            issue_tap <= 6'd0;

            mac_pipe_valid <= 1'b0;
            mac_pipe_stage2 <= 1'b0;
            mac_pipe_center <= 1'b0;
            mac_pipe_channel <= 5'd0;
            mac_pipe_tap <= 6'd0;
            mac_pipe_coeff <= 19'sd0;

            for (ch = 0; ch < CHANNELS; ch = ch + 1) begin
                input_latch[ch] <= 16'sd0;
                s1_result[ch] <= 16'sd0;
                s2_result[ch] <= 16'sd0;
                channel_acc[ch] <= 41'sd0;
                val_out[ch] <= 16'd0;
            end

        end

        else begin

            // ====================================================
            // RAM initialization
            // ====================================================

            if (state == STATE_INIT) begin

                sample_counter <= '0;
                mac_pipe_valid <= 1'b0;
                s1_write_active <= 1'b0;

                if (init_addr == INIT_WORDS - 1) begin
                    init_addr <= '0;
                    state <= STATE_IDLE;
                end
                else begin
                    init_addr <= init_addr + 1'b1;
                end

            end

            else begin

                // =================================================
                // 500 kSPS timing
                // =================================================

                if (sample_counter == TDM_FACTOR - 1)
                    sample_counter <= '0;
                else
                    sample_counter <= sample_counter + 1'b1;


                // =================================================
                // Capture all 22 inputs simultaneously.
                // =================================================

                if (sample_valid) begin

                    for (ch = 0; ch < CHANNELS; ch = ch + 1)
                        input_latch[ch] <= $signed(val_in[ch]);

                    // 22 serialized writes finish well before the
                    // next 500 kSPS sample arrives 100 clocks later.
                    s1_write_active <= 1'b1;
                    s1_write_channel <= 5'd0;
                    s1_write_target_ptr <= s1_next_write_ptr;
                    s1_next_write_ptr <= s1_inc_ptr(s1_next_write_ptr);

                    if (decim_phase == DECIMATION - 1) begin
                        decim_phase <= 4'd0;
                        s1_write_is_decim <= 1'b1;
                    end
                    else begin
                        decim_phase <= decim_phase + 1'b1;
                        s1_write_is_decim <= 1'b0;
                    end

                end


                // =================================================
                // Stage-1 serialized RAM write engine
                // =================================================

                if (s1_write_active) begin

                    if (s1_write_channel == CHANNELS - 1) begin

                        s1_write_active <= 1'b0;
                        s1_write_channel <= 5'd0;

                        // Start Stage 1 only after all 22 channels of
                        // the decimation sample are safely in RAM.
                        if (s1_write_is_decim) begin

                            s1_base_ptr <= s1_write_target_ptr;
                            s1_write_is_decim <= 1'b0;

                            issue_channel <= 5'd0;
                            issue_tap <= 6'd0;
                            mac_pipe_valid <= 1'b0;

                            for (ch = 0; ch < CHANNELS; ch = ch + 1)
                                channel_acc[ch] <= 41'sd0;

                            state <= STATE_S1_RUN;

                        end

                    end
                    else begin
                        s1_write_channel <= s1_write_channel + 1'b1;
                    end

                end


                // =================================================
                // FIR state machine
                // =================================================

                case (state)

                    // ------------------------------------------------
                    // IDLE
                    // ------------------------------------------------

                    STATE_IDLE: begin
                        mac_pipe_valid <= 1'b0;
                    end


                    // ------------------------------------------------
                    // Stage 1
                    //
                    // Tap-major order:
                    //   tap 0, channels 0..21
                    //   tap 1, channels 0..21
                    //   ...
                    //   tap 11, channels 0..21
                    //
                    // This protects the oldest circular-buffer words
                    // from being overwritten by later 500 kSPS writes.
                    // ------------------------------------------------

                    STATE_S1_RUN: begin

                        // Consume the RAM result issued one clock ago.
                        if (mac_pipe_valid && !mac_pipe_stage2) begin

                            if (mac_pipe_tap == STAGE1_PAIRS) begin
                                s1_result[mac_pipe_channel] <=
                                    q20_to_s16(
                                        channel_acc[mac_pipe_channel] +
                                        mac_product_ext
                                    );

                                channel_acc[mac_pipe_channel] <= 41'sd0;
                            end
                            else begin
                                channel_acc[mac_pipe_channel] <=
                                    channel_acc[mac_pipe_channel] +
                                    mac_product_ext;
                            end

                        end

                        // Issue the current synchronous RAM read.
                        mac_pipe_valid <= 1'b1;
                        mac_pipe_stage2 <= 1'b0;
                        mac_pipe_channel <= issue_channel;
                        mac_pipe_tap <= issue_tap;
                        mac_pipe_coeff <= stage1_coeff(issue_tap[4:0]);
                        mac_pipe_center <= (issue_tap == STAGE1_PAIRS);

                        // Advance tap-major issue counters.
                        if (issue_channel == CHANNELS - 1) begin

                            issue_channel <= 5'd0;

                            if (issue_tap == STAGE1_PAIRS) begin
                                state <= STATE_S1_DRAIN;
                            end
                            else begin
                                issue_tap <= issue_tap + 1'b1;
                            end

                        end
                        else begin
                            issue_channel <= issue_channel + 1'b1;
                        end

                    end


                    // ------------------------------------------------
                    // Consume the final Stage-1 RAM result.
                    // ------------------------------------------------

                    STATE_S1_DRAIN: begin

                        if (mac_pipe_valid && !mac_pipe_stage2) begin

                            if (mac_pipe_tap == STAGE1_PAIRS) begin
                                s1_result[mac_pipe_channel] <=
                                    q20_to_s16(
                                        channel_acc[mac_pipe_channel] +
                                        mac_product_ext
                                    );
                                channel_acc[mac_pipe_channel] <= 41'sd0;
                            end
                            else begin
                                channel_acc[mac_pipe_channel] <=
                                    channel_acc[mac_pipe_channel] +
                                    mac_product_ext;
                            end

                        end

                        mac_pipe_valid <= 1'b0;

                        s2_write_target_ptr <= s2_next_write_ptr;
                        s2_next_write_ptr <= s2_inc_ptr(s2_next_write_ptr);
                        s2_write_channel <= 5'd0;

                        state <= STATE_S2_WRITE;

                    end


                    // ------------------------------------------------
                    // Serialize all 22 Stage-1 outputs into Stage-2 RAM.
                    // ------------------------------------------------

                    STATE_S2_WRITE: begin

                        mac_pipe_valid <= 1'b0;

                        if (s2_write_channel == CHANNELS - 1) begin

                            s2_base_ptr <= s2_write_target_ptr;
                            s2_write_channel <= 5'd0;

                            issue_channel <= 5'd0;
                            issue_tap <= 6'd0;

                            for (ch = 0; ch < CHANNELS; ch = ch + 1)
                                channel_acc[ch] <= 41'sd0;

                            state <= STATE_S2_RUN;

                        end
                        else begin
                            s2_write_channel <= s2_write_channel + 1'b1;
                        end

                    end


                    // ------------------------------------------------
                    // Stage 2
                    //
                    // 19 symmetric MAC operations per channel.
                    // ------------------------------------------------

                    STATE_S2_RUN: begin

                        // Consume the RAM result issued one clock ago.
                        if (mac_pipe_valid && mac_pipe_stage2) begin

                            if (mac_pipe_tap == STAGE2_PAIRS) begin
                                s2_result[mac_pipe_channel] <=
                                    q20_to_s16(
                                        channel_acc[mac_pipe_channel] +
                                        mac_product_ext
                                    );

                                channel_acc[mac_pipe_channel] <= 41'sd0;
                            end
                            else begin
                                channel_acc[mac_pipe_channel] <=
                                    channel_acc[mac_pipe_channel] +
                                    mac_product_ext;
                            end

                        end

                        // Issue the current synchronous RAM read.
                        mac_pipe_valid <= 1'b1;
                        mac_pipe_stage2 <= 1'b1;
                        mac_pipe_channel <= issue_channel;
                        mac_pipe_tap <= issue_tap;
                        mac_pipe_coeff <= stage2_coeff(issue_tap);
                        mac_pipe_center <= (issue_tap == STAGE2_PAIRS);

                        // Tap-major issue counters.
                        if (issue_channel == CHANNELS - 1) begin

                            issue_channel <= 5'd0;

                            if (issue_tap == STAGE2_PAIRS) begin
                                state <= STATE_S2_DRAIN;
                            end
                            else begin
                                issue_tap <= issue_tap + 1'b1;
                            end

                        end
                        else begin
                            issue_channel <= issue_channel + 1'b1;
                        end

                    end


                    // ------------------------------------------------
                    // Consume the final Stage-2 RAM result.
                    // ------------------------------------------------

                    STATE_S2_DRAIN: begin

                        if (mac_pipe_valid && mac_pipe_stage2) begin

                            if (mac_pipe_tap == STAGE2_PAIRS) begin
                                s2_result[mac_pipe_channel] <=
                                    q20_to_s16(
                                        channel_acc[mac_pipe_channel] +
                                        mac_product_ext
                                    );
                                channel_acc[mac_pipe_channel] <= 41'sd0;
                            end
                            else begin
                                channel_acc[mac_pipe_channel] <=
                                    channel_acc[mac_pipe_channel] +
                                    mac_product_ext;
                            end

                        end

                        mac_pipe_valid <= 1'b0;
                        state <= STATE_COMMIT;

                    end


                    // ------------------------------------------------
                    // Atomic 22-channel output update.
                    // ------------------------------------------------

                    STATE_COMMIT: begin

                        for (ch = 0; ch < CHANNELS; ch = ch + 1)
                            val_out[ch] <= s2_result[ch];

                        mac_pipe_valid <= 1'b0;
                        state <= STATE_IDLE;

                    end


                    default: begin
                        state <= STATE_INIT;
                        init_addr <= '0;
                        mac_pipe_valid <= 1'b0;
                    end

                endcase

            end

        end

    end

endmodule
