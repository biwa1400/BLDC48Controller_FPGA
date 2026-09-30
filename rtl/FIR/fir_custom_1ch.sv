module fir_custom_1ch (
    input  logic                   clk,
    input  logic                   reset_n,

    input  logic signed [15:0]     data_in,
    input  logic                   data_valid,

    output logic signed [15:0]     data_out,
    output logic                   data_out_valid,

    // Output of the anti-alias FIR after /10 decimation.
    // Sample rate = 50 kSPS.
    output logic signed [15:0]     decimated_out,
    output logic                   decimated_out_valid
);

    // ============================================================
    // Two-stage decimating FIR
    //
    // Input:
    //   500 kSPS
    //
    // Stage 1:
    //   23-tap anti-alias FIR
    //   Only one output is calculated for every 10 input samples.
    //
    // Decimation:
    //   500 kSPS / 10 = 50 kSPS
    //
    // Stage 2:
    //   37-tap final low-pass FIR
    //
    // Final design target:
    //
    //   Passband : 0 ... 1 kHz
    //   Ripple   : <= +/-1 %
    //   Stopband : >= 5 kHz
    //   Rejection: > 40 dB
    //
    // Coefficient format:
    //   signed Q20
    //
    // Both FIR stages use serial MAC processing.
    // They do NOT instantiate one multiplier per tap.
    // ============================================================


    // ============================================================
    // Constants
    // ============================================================

    localparam int STAGE1_TAPS   = 23;
    localparam int STAGE1_PAIRS  = 11;

    localparam int STAGE2_TAPS   = 37;
    localparam int STAGE2_PAIRS  = 18;


    // ============================================================
    // Q20 rounding and 16-bit saturation
    // ============================================================

    function automatic signed [15:0] q20_to_s16;
        input signed [40:0] value;

        reg signed [40:0] rounded_value;
        reg signed [40:0] scaled_value;

        begin

            // Round to nearest integer before removing Q20 scaling.
            if (value >= 0)
                rounded_value = value + 41'sd524288;
            else
                rounded_value = value - 41'sd524288;

            scaled_value = rounded_value >>> 20;

            // Saturate to signed 16-bit range.
            if (scaled_value > 41'sd32767)
                q20_to_s16 = 16'sh7FFF;
            else if (scaled_value < -41'sd32768)
                q20_to_s16 = 16'sh8000;
            else
                q20_to_s16 = scaled_value[15:0];

        end
    endfunction


    // ============================================================
    // Stage 1
    //
    // 23-tap anti-alias FIR at 500 kSPS input rate.
    //
    // Because this FIR is immediately followed by /10 decimation,
    // we only calculate one FIR output for every 10 input samples.
    //
    // The input history is still updated at the full 500 kSPS.
    // ============================================================

    logic signed [15:0] s1_samples [0:STAGE1_TAPS-1];

    // Symmetric FIR:
    //
    // h[0]  = h[22]
    // h[1]  = h[21]
    // ...
    // h[10] = h[12]
    // h[11] = center tap
    //
    // Full coefficient sum = 2^20 exactly.
    //
    // Therefore DC gain = 1.000000.
    //
    logic signed [18:0] s1_coeff [0:STAGE1_PAIRS];


    initial begin

        s1_coeff[0]  = 19'sd4680;
        s1_coeff[1]  = 19'sd8016;
        s1_coeff[2]  = 19'sd13939;
        s1_coeff[3]  = 19'sd21714;
        s1_coeff[4]  = 19'sd31157;
        s1_coeff[5]  = 19'sd41838;
        s1_coeff[6]  = 19'sd53095;
        s1_coeff[7]  = 19'sd64092;
        s1_coeff[8]  = 19'sd73915;
        s1_coeff[9]  = 19'sd81688;
        s1_coeff[10] = 19'sd86676;

        // Center tap.
        s1_coeff[11] = 19'sd86956;

    end


    // ============================================================
    // Stage 1 decimation phase
    //
    // Counts valid 500 kSPS input samples:
    //
    //   0 1 2 ... 9
    //
    // On phase 9, start one Stage-1 FIR calculation.
    // ============================================================

    logic [3:0] s1_decim_phase;

    logic       s1_busy;
    logic [4:0] s1_mac_index;

    logic signed [40:0] s1_accumulator;

    logic signed [16:0] s1_pair_comb;
    logic signed [35:0] s1_product_comb;


    // ============================================================
    // Stage 1 combinational MAC input
    // ============================================================

    always_comb begin

        s1_pair_comb    = 17'sd0;
        s1_product_comb = 36'sd0;

        if (s1_busy) begin

            if (s1_mac_index < STAGE1_PAIRS) begin

                // Symmetric pair:
                //
                // samples[i] + samples[22-i]
                //
                s1_pair_comb =
                    $signed(s1_samples[s1_mac_index]) +
                    $signed(s1_samples[
                        (STAGE1_TAPS - 1) - s1_mac_index
                    ]);

                s1_product_comb =
                    $signed(s1_pair_comb) *
                    $signed(s1_coeff[s1_mac_index]);

            end
            else begin

                // Center tap: samples[11]
                s1_pair_comb =
                    $signed(s1_samples[STAGE1_PAIRS]);

                s1_product_comb =
                    $signed(s1_pair_comb) *
                    $signed(s1_coeff[STAGE1_PAIRS]);

            end

        end

    end


    // ============================================================
    // Stage 1 sequential processing
    // ============================================================

    integer s1_i;


    always_ff @(posedge clk or negedge reset_n) begin

        if (!reset_n) begin

            for (s1_i = 0;
                 s1_i < STAGE1_TAPS;
                 s1_i = s1_i + 1) begin

                s1_samples[s1_i] <= 16'sd0;

            end

            s1_decim_phase <= 4'd0;

            s1_busy        <= 1'b0;
            s1_mac_index   <= 5'd0;
            s1_accumulator <= 41'sd0;

            decimated_out       <= 16'sd0;
            decimated_out_valid <= 1'b0;

        end
        else begin

            // Default: no new decimated output.
            decimated_out_valid <= 1'b0;


            // ----------------------------------------------------
            // Capture every 500 kSPS input sample.
            // ----------------------------------------------------

            if (data_valid) begin

                // Shift the Stage-1 history.
                for (s1_i = STAGE1_TAPS-1;
                     s1_i > 0;
                     s1_i = s1_i - 1) begin

                    s1_samples[s1_i] <=
                        s1_samples[s1_i-1];

                end

                s1_samples[0] <= data_in;


                // ------------------------------------------------
                // Decimation by 10.
                //
                // Only calculate the FIR output on every
                // tenth input sample.
                // ------------------------------------------------

                if (s1_decim_phase == 4'd9) begin

                    s1_decim_phase <= 4'd0;

                    // Stage 1 has much more than enough time:
                    //
                    // 50 MHz / 50 kSPS = 1000 clocks/output.
                    //
                    // This FIR needs only 12 MAC cycles.
                    //
                    s1_busy        <= 1'b1;
                    s1_mac_index   <= 5'd0;
                    s1_accumulator <= 41'sd0;

                end
                else begin

                    s1_decim_phase <=
                        s1_decim_phase + 1'b1;

                end

            end


            // ----------------------------------------------------
            // Serial Stage-1 MAC.
            //
            // This starts one clock after the sample-history shift,
            // therefore s1_samples[] already contains the newest
            // input sample.
            // ----------------------------------------------------

            if (s1_busy) begin

                if (s1_mac_index == STAGE1_PAIRS) begin

                    // Last multiplication = center tap.
                    //
                    // Include the final product before converting
                    // from Q20 back to signed 16-bit.
                    //
                    decimated_out <=
                        q20_to_s16(
                            s1_accumulator +
                            $signed(s1_product_comb)
                        );

                    decimated_out_valid <= 1'b1;

                    s1_accumulator <= 41'sd0;
                    s1_mac_index   <= 5'd0;
                    s1_busy        <= 1'b0;

                end
                else begin

                    s1_accumulator <=
                        s1_accumulator +
                        $signed(s1_product_comb);

                    s1_mac_index <=
                        s1_mac_index + 1'b1;

                end

            end

        end

    end


    // ============================================================
    // Stage 2
    //
    // 37-tap final low-pass FIR.
    //
    // Input sample rate = 50 kSPS.
    //
    // Passband:
    //   0 ... 1 kHz
    //
    // Stopband:
    //   >= 5 kHz
    //
    // Full coefficient sum = 2^20 exactly.
    //
    // Therefore DC gain = 1.000000.
    // ============================================================

    logic signed [15:0] s2_samples [0:STAGE2_TAPS-1];

    logic signed [18:0] s2_coeff [0:STAGE2_PAIRS];


    initial begin

        s2_coeff[0]  =  19'sd3949;
        s2_coeff[1]  =  19'sd2610;
        s2_coeff[2]  =  19'sd2144;
        s2_coeff[3]  =  19'sd371;

        s2_coeff[4]  = -19'sd2809;
        s2_coeff[5]  = -19'sd7087;
        s2_coeff[6]  = -19'sd11660;
        s2_coeff[7]  = -19'sd15278;
        s2_coeff[8]  = -19'sd16405;
        s2_coeff[9]  = -19'sd13504;
        s2_coeff[10] = -19'sd5361;

        s2_coeff[11] =  19'sd8560;
        s2_coeff[12] =  19'sd27886;
        s2_coeff[13] =  19'sd51245;
        s2_coeff[14] =  19'sd76350;
        s2_coeff[15] =  19'sd100359;
        s2_coeff[16] =  19'sd120253;
        s2_coeff[17] =  19'sd133400;

        // Center tap.
        s2_coeff[18] =  19'sd138530;

    end


    logic       s2_busy;
    logic [5:0] s2_mac_index;

    logic signed [40:0] s2_accumulator;

    logic signed [16:0] s2_pair_comb;
    logic signed [35:0] s2_product_comb;


    // ============================================================
    // Stage 2 combinational MAC input
    // ============================================================

    always_comb begin

        s2_pair_comb    = 17'sd0;
        s2_product_comb = 36'sd0;

        if (s2_busy) begin

            if (s2_mac_index < STAGE2_PAIRS) begin

                // Symmetric pair:
                //
                // samples[i] + samples[36-i]
                //
                s2_pair_comb =
                    $signed(s2_samples[s2_mac_index]) +
                    $signed(s2_samples[
                        (STAGE2_TAPS - 1) - s2_mac_index
                    ]);

                s2_product_comb =
                    $signed(s2_pair_comb) *
                    $signed(s2_coeff[s2_mac_index]);

            end
            else begin

                // Center tap: samples[18]
                s2_pair_comb =
                    $signed(s2_samples[STAGE2_PAIRS]);

                s2_product_comb =
                    $signed(s2_pair_comb) *
                    $signed(s2_coeff[STAGE2_PAIRS]);

            end

        end

    end


    // ============================================================
    // Stage 2 sequential processing
    // ============================================================

    integer s2_i;


    always_ff @(posedge clk or negedge reset_n) begin

        if (!reset_n) begin

            for (s2_i = 0;
                 s2_i < STAGE2_TAPS;
                 s2_i = s2_i + 1) begin

                s2_samples[s2_i] <= 16'sd0;

            end

            s2_busy        <= 1'b0;
            s2_mac_index   <= 6'd0;
            s2_accumulator <= 41'sd0;

            data_out       <= 16'sd0;
            data_out_valid <= 1'b0;

        end
        else begin

            // Default: no new final output.
            data_out_valid <= 1'b0;


            // ----------------------------------------------------
            // New 50 kSPS sample from Stage 1.
            // ----------------------------------------------------

            if (decimated_out_valid) begin

                // Shift Stage-2 history.
                for (s2_i = STAGE2_TAPS-1;
                     s2_i > 0;
                     s2_i = s2_i - 1) begin

                    s2_samples[s2_i] <=
                        s2_samples[s2_i-1];

                end

                s2_samples[0] <= decimated_out;


                // Start serial MAC.
                //
                // 50 MHz / 50 kSPS = 1000 clocks available.
                //
                // Only 19 MAC cycles are required.
                //
                s2_busy        <= 1'b1;
                s2_mac_index   <= 6'd0;
                s2_accumulator <= 41'sd0;

            end


            // ----------------------------------------------------
            // Serial Stage-2 MAC.
            //
            // Starts after the sample-history shift, so the
            // newest decimated sample is already samples[0].
            // ----------------------------------------------------

            if (s2_busy) begin

                if (s2_mac_index == STAGE2_PAIRS) begin

                    data_out <=
                        q20_to_s16(
                            s2_accumulator +
                            $signed(s2_product_comb)
                        );

                    data_out_valid <= 1'b1;

                    s2_accumulator <= 41'sd0;
                    s2_mac_index   <= 6'd0;
                    s2_busy        <= 1'b0;

                end
                else begin

                    s2_accumulator <=
                        s2_accumulator +
                        $signed(s2_product_comb);

                    s2_mac_index <=
                        s2_mac_index + 1'b1;

                end

            end

        end

    end


endmodule