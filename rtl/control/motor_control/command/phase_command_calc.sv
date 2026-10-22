// ============================================================================
// phase_command_calc.sv
// BLDC48Controller FPGA
//
// 22-phase fixed-point command calculation engine.
//
// Legacy-compatible waveform-coordinate mapping:
//   voltage_angle = electrical_angle - 90 degrees
//   LUT_angle     = voltage_angle + 90 degrees - phase_advance
//
// The additional +90 degrees converts the legacy control-angle
// representation to the half-wave LUT coordinate system.
//
// phase_advance = 0 means no additional runtime phase advance.
// The original per-phase offsets and PWM datapath are unchanged.
// ============================================================================

module phase_command_calc (
    input  logic        clk_50MHz,
    input  logic        rst_n,

    // Runtime commands
    input  logic [12:0] encoder_phi,
    input  logic [12:0] amplitude,
    input  logic [15:0] phase_advance,

    // Current active LUT bank
    input  logic        lut_active_bank,

    // Batch control
    input  logic        batch_start,
    output logic        batch_busy,
    output logic        batch_done,

    // LUT read interface
    output logic        lut_rd_bank,
    output logic        lut_rd_en,
    output logic [11:0] lut_rd_addr,
    input  logic [12:0] lut_rd_data,

    // Current calculation information
    output logic [4:0]  phase_index,
    output logic [15:0] phase_angle_u16,
    output logic        waveform_sign,
    output logic [12:0] waveform_magnitude,

    // Batch snapshots
    output logic [12:0] encoder_snapshot,
    output logic [12:0] amplitude_snapshot,
    output logic [15:0] phase_advance_snapshot,

    // Completed Level-2 command frame
    output logic [12:0] compare_shadow [0:21]
);

    import motor_control_pkg::*;

    // ========================================================================
    // FSM
    // ========================================================================

    localparam [3:0] STATE_IDLE        = 4'd0;
    localparam [3:0] STATE_PHASE_ANGLE = 4'd1;
    localparam [3:0] STATE_LUT_READ    = 4'd2;
    localparam [3:0] STATE_LUT_WAIT    = 4'd3;
    localparam [3:0] STATE_LUT_CAPTURE = 4'd4;
    localparam [3:0] STATE_MULTIPLY    = 4'd5;
    localparam [3:0] STATE_PWM_SCALE   = 4'd6;
    localparam [3:0] STATE_ROUND       = 4'd7;
    localparam [3:0] STATE_COMPARE     = 4'd8;
    localparam [3:0] STATE_STORE       = 4'd9;

    logic [3:0] state;

    // ========================================================================
    // Batch-common angle calculation
    // ========================================================================

    logic [12:0] relative_encoder;
    logic [31:0] encoder_angle_reciprocal;
    logic [15:0] mechanical_angle_u16;
    logic [31:0] electrical_product;
    logic [15:0] electrical_angle_u16;
    logic [15:0] voltage_angle_u16;
    logic [15:0] control_angle_u16;

    always_comb begin

        // Physical encoder domain: 0 ... 6399.
        // Explicit modulo wrapping relative to calibrated zero.

        if (encoder_phi >= ENCODER_OFFSET) begin
            relative_encoder =
                encoder_phi - ENCODER_OFFSET;
        end else begin
            relative_encoder =
                encoder_phi + ENCODER_COUNTS - ENCODER_OFFSET;
        end

        // Encoder domain -> U16 mechanical angle.
        //
        // Golden reference:
        //   (relative * 65536 + 3200) / 6400
        //
        // Reciprocal multiplication avoids a general-purpose divider.

        encoder_angle_reciprocal =
            (relative_encoder * 32'd671089) + 32'd31449;

        mechanical_angle_u16 =
            encoder_angle_reciprocal[31:16];

        // Mechanical -> electrical angle.
        // Low 16 bits implement modulo 65536.

        electrical_product =
            mechanical_angle_u16 * POLE_PAIRS;

        electrical_angle_u16 =
            16'd0 - electrical_product[15:0];

        // Preserve the original torque-vector orientation.

        voltage_angle_u16 =
            electrical_angle_u16 - ANGLE_90;

    end

    // ========================================================================
    // Per-phase registers
    // ========================================================================

    logic [15:0] phase_angle_reg;
    logic        waveform_sign_reg;
    logic [12:0] waveform_magnitude_reg;

    assign phase_angle_u16 = phase_angle_reg;
    assign waveform_sign = waveform_sign_reg;
    assign waveform_magnitude = waveform_magnitude_reg;

    // ========================================================================
    // Fixed-point datapath
    //
    // W = waveform magnitude
    // A = runtime amplitude
    //
    // P = W * A
    // S = P * PWM_CENTER
    //
    // delta = (S + 2^23) >> 24
    //
    // compare = PWM_CENTER +/- delta
    // ========================================================================

    logic [25:0] waveform_amplitude_product;
    logic [37:0] pwm_scaled_product;
    logic [38:0] pwm_rounding_accumulator;
    logic [12:0] pwm_delta;
    logic [12:0] compare_value;

    // ========================================================================
    // LUT read interface
    //
    // Half-wave representation:
    //   sign    = phase_angle[15]
    //   address = phase_angle[14:3]
    //
    // The LUT stores unsigned magnitude.
    // ========================================================================

    always_comb begin

        lut_rd_en = 1'b0;
        lut_rd_addr = 12'd0;

        if (state == STATE_LUT_READ) begin
            lut_rd_en = 1'b1;
            lut_rd_addr = phase_angle_reg[14:3];
        end

    end

    // ========================================================================
    // Main sequential FSM
    // ========================================================================

    integer i;

    always_ff @(posedge clk_50MHz) begin

        if (!rst_n) begin

            state <= STATE_IDLE;
            batch_busy <= 1'b0;
            batch_done <= 1'b0;
            phase_index <= 5'd0;

            encoder_snapshot <= 13'd0;
            amplitude_snapshot <= 13'd0;
            phase_advance_snapshot <= 16'd0;
            lut_rd_bank <= 1'b0;

            control_angle_u16 <= 16'd0;
            phase_angle_reg <= 16'd0;
            waveform_sign_reg <= 1'b0;
            waveform_magnitude_reg <= 13'd0;

            waveform_amplitude_product <= 26'd0;
            pwm_scaled_product <= 38'd0;
            pwm_rounding_accumulator <= 39'd0;
            pwm_delta <= 13'd0;
            compare_value <= PWM_CENTER;

            for (i = 0; i < NUM_PHASES; i = i + 1) begin
                compare_shadow[i] <= PWM_CENTER;
            end

        end else begin

            // One-clock completion pulse.
            batch_done <= 1'b0;

            case (state)

                // ============================================================
                // IDLE
                // ============================================================

                STATE_IDLE: begin

                    batch_busy <= 1'b0;

                    if (batch_start) begin

                        // Capture coherent runtime command values.

                        encoder_snapshot <= encoder_phi;
                        amplitude_snapshot <= amplitude;
                        phase_advance_snapshot <= phase_advance;
                        lut_rd_bank <= lut_active_bank;

                        // ----------------------------------------------------
                        // LEGACY WAVEFORM COORDINATE CORRECTION
                        //
                        // Original:
                        //   control = voltage_angle - phase_advance
                        //
                        // Corrected:
                        //   control = voltage_angle + 90 - phase_advance
                        //
                        // With phase_advance=0, this reproduces the angle
                        // relationship previously tested using C000.
                        //
                        // The physical -90-degree voltage-angle definition
                        // above remains unchanged.
                        // ----------------------------------------------------

                        control_angle_u16 <=
                            voltage_angle_u16
                            + ANGLE_90
                            - phase_advance;

                        phase_index <= 5'd0;
                        batch_busy <= 1'b1;
                        state <= STATE_PHASE_ANGLE;

                    end

                end

                // ============================================================
                // PHASE ANGLE
                // ============================================================

                STATE_PHASE_ANGLE: begin

                    phase_angle_reg <=
                        control_angle_u16
                        - get_phase_offset(phase_index);

                    state <= STATE_LUT_READ;

                end

                // ============================================================
                // LUT READ
                // ============================================================

                STATE_LUT_READ: begin

                    waveform_sign_reg <=
                        phase_angle_reg[15];

                    state <= STATE_LUT_WAIT;

                end

                // ============================================================
                // LUT WAIT
                // ============================================================

                STATE_LUT_WAIT: begin

                    state <= STATE_LUT_CAPTURE;

                end

                // ============================================================
                // LUT CAPTURE
                // ============================================================

                STATE_LUT_CAPTURE: begin

                    waveform_magnitude_reg <=
                        lut_rd_data;

                    state <= STATE_MULTIPLY;

                end

                // ============================================================
                // MULTIPLY
                // ============================================================

                STATE_MULTIPLY: begin

                    waveform_amplitude_product <=
                        waveform_magnitude_reg
                        * amplitude_snapshot;

                    state <= STATE_PWM_SCALE;

                end

                // ============================================================
                // PWM SCALE
                // ============================================================

                STATE_PWM_SCALE: begin

                    pwm_scaled_product <=
                        waveform_amplitude_product
                        * PWM_CENTER;

                    state <= STATE_ROUND;

                end

                // ============================================================
                // ROUND
                // ============================================================

                STATE_ROUND: begin

                    pwm_rounding_accumulator <=
                        {1'b0, pwm_scaled_product}
                        + PWM_ROUNDING_BIAS;

                    state <= STATE_COMPARE;

                end

                // ============================================================
                // COMPARE
                // ============================================================

                STATE_COMPARE: begin

                    pwm_delta <=
                        pwm_rounding_accumulator
                        >> PWM_SCALE_DENOMINATOR_BITS;

                    state <= STATE_STORE;

                end

                // ============================================================
                // STORE
                // ============================================================

                STATE_STORE: begin

                    if (waveform_sign_reg) begin

                        compare_value <=
                            PWM_CENTER - pwm_delta;

                        compare_shadow[phase_index] <=
                            PWM_CENTER - pwm_delta;

                    end else begin

                        compare_value <=
                            PWM_CENTER + pwm_delta;

                        compare_shadow[phase_index] <=
                            PWM_CENTER + pwm_delta;

                    end

                    // The final phase completes the coherent shadow frame.

                    if (phase_index == (NUM_PHASES - 1)) begin

                        phase_index <= 5'd0;
                        batch_busy <= 1'b0;
                        batch_done <= 1'b1;
                        state <= STATE_IDLE;

                    end else begin

                        phase_index <=
                            phase_index + 5'd1;

                        state <= STATE_PHASE_ANGLE;

                    end

                end

                // ============================================================
                // Illegal-state recovery
                // ============================================================

                default: begin

                    state <= STATE_IDLE;
                    batch_busy <= 1'b0;
                    batch_done <= 1'b0;
                    phase_index <= 5'd0;

                end

            endcase

        end

    end

endmodule
