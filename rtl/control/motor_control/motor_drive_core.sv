// ============================================================================
// motor_drive_core.sv
//
// BLDC48Controller FPGA
//
// Motor-control core:
//
//   encoder
//      |
//      v
//   phase command calculation
//      |
//      v
//   compare_shadow[22]
//      |
//      v
//   command commit
//      |
//      v
//   compare_active[22]
//      |
//      v
//   center-aligned PWM comparator
//      |
//      v
//   raw_pwm[22]
//      |
//      v
//   complementary deadtime bank
//      |
//      v
//   pwm_hi_internal[22]
//   pwm_lo_internal[22]
//      |
//      v
//   final drive_enable / reset safety gate
//      |
//      v
//   pwm_hi[22]
//   pwm_lo[22]
//
// ============================================================================

module motor_drive_core (

    input  logic        clk_50MHz,
    input  logic        clk_200MHz,
    input  logic        rst_n,
    input  logic        drive_enable,
    input  logic [12:0] encoder_phi,
    input  logic [12:0] amplitude,
    input  logic [15:0] phase_advance,

    // ------------------------------------------------------------------------
    // LUT write interface
    // ------------------------------------------------------------------------

    input  logic        lut_wr_en,
    input  logic        lut_wr_bank,
    input  logic [11:0] lut_wr_addr,
    input  logic [12:0] lut_wr_data,

    // ------------------------------------------------------------------------
    // LUT commit interface
    // ------------------------------------------------------------------------

    input  logic        lut_commit_req,
    output logic        lut_active_bank,
    output logic        lut_commit_ack,

    // ------------------------------------------------------------------------
    // LUT verification interface (50 MHz domain)
    // ------------------------------------------------------------------------

    input  logic        lut_verify_lock,
    input  logic        lut_verify_en,
    input  logic        lut_verify_bank,
    input  logic [11:0] lut_verify_addr,
    output logic [12:0] lut_verify_data,
    output logic        lut_verify_valid,

    // ------------------------------------------------------------------------
    // Final gate outputs
    // ------------------------------------------------------------------------

    output logic [21:0] pwm_hi,
    output logic [21:0] pwm_lo

);

    import motor_control_pkg::*;

    // ========================================================================
    // LUT signals
    // ========================================================================

    logic        lut_commit_pending;
    logic        lut_safe_switch;
    logic        lut_rd_bank;
    logic        lut_rd_en;
    logic [11:0] lut_rd_addr;
    logic [12:0] lut_rd_data;

    // ========================================================================
    // Phase command calculation signals
    // ========================================================================

    logic        calc_batch_start;
    logic        calc_batch_busy;
    logic        calc_batch_done;
    logic [4:0]  calc_phase_index;
    logic [15:0] calc_phase_angle_u16;
    logic        calc_waveform_sign;
    logic [12:0] calc_waveform_magnitude;
    logic [12:0] calc_encoder_snapshot;
    logic [12:0] calc_amplitude_snapshot;
    logic [15:0] calc_phase_advance_snapshot;
    logic [12:0] compare_shadow [0:21];

    // ========================================================================
    // PWM command commit signals
    // ========================================================================

    logic [12:0] compare_active [0:21];
    logic        command_commit_pending;
    logic        command_commit_pulse;

    // ========================================================================
    // PWM carrier signals
    // ========================================================================

    logic [12:0] pwm_carrier_value;
    logic        pwm_direction_down;
    logic        pwm_frame_boundary;

    // ========================================================================
    // Raw PWM comparator outputs
    // ========================================================================

    logic [21:0] raw_pwm;

    // ========================================================================
    // Deadtime outputs
    // ========================================================================

    logic [21:0] pwm_hi_internal;
    logic [21:0] pwm_lo_internal;

    // ========================================================================
    // LUT safe-switch rule
    // ========================================================================
    //
    // LUT bank switching is allowed only when no calculation batch is active.
    //
    // This guarantees that one complete 22-phase calculation batch always
    // uses one coherent LUT bank.
    //
    // ========================================================================

    // Verification lock is checked both here and in lut_bank_control.
    assign lut_safe_switch =
        !calc_batch_busy && !lut_verify_lock;

    // ========================================================================
    // Calculation batch start rule
    // ========================================================================
    //
    // Do not begin a new calculation batch while a LUT commit transaction is
    // active.
    //
    // This creates a clean sequence:
    //
    //     previous batch completes
    //             ->
    //     LUT bank safely switches
    //             ->
    //     commit ACK
    //             ->
    //     request released
    //             ->
    //     ACK clears
    //             ->
    //     next calculation batch snapshots the new active bank
    //
    // ========================================================================

    assign calc_batch_start =
        rst_n
        &&
        !calc_batch_busy
        &&
        !lut_commit_req
        &&
        !lut_commit_pending
        &&
        !lut_commit_ack;

    // ========================================================================
    // LUT bank control
    // ========================================================================

    lut_bank_control u_lut_bank_control (

        .clk_50MHz (
            clk_50MHz
        ),
        .rst_n (
            rst_n
        ),
        .lut_commit_req (
            lut_commit_req
        ),
        .safe_switch (
            lut_safe_switch
        ),
        .verify_lock (
            lut_verify_lock
        ),
        .active_bank (
            lut_active_bank
        ),
        .commit_pending (
            lut_commit_pending
        ),
        .lut_commit_ack (
            lut_commit_ack
        )

    );

    // ========================================================================
    // Dual-bank waveform LUT
    // ========================================================================

    waveform_lut_dp u_waveform_lut (

        .clk_50MHz (
            clk_50MHz
        ),
        .rst_n (
            rst_n
        ),
        .active_bank (
            lut_active_bank
        ),
        .wr_en (
            lut_wr_en
        ),
        .wr_bank (
            lut_wr_bank
        ),
        .wr_addr (
            lut_wr_addr
        ),
        .wr_data (
            lut_wr_data
        ),
        .rd_en (
            lut_rd_en
        ),
        .rd_bank (
            lut_rd_bank
        ),
        .rd_addr (
            lut_rd_addr
        ),
        .rd_data (
            lut_rd_data
        ),
        .verify_en (
            lut_verify_en && lut_verify_lock
        ),
        .verify_bank (
            lut_verify_bank
        ),
        .verify_addr (
            lut_verify_addr
        ),
        .verify_data (
            lut_verify_data
        ),
        .verify_valid (
            lut_verify_valid
        ),
        .calc_batch_busy (
            calc_batch_busy
        )

    );

    // ========================================================================
    // 22-phase command calculation
    // ========================================================================

    phase_command_calc u_phase_command_calc (

        .clk_50MHz (
            clk_50MHz
        ),
        .rst_n (
            rst_n
        ),
        .encoder_phi (
            encoder_phi
        ),
        .amplitude (
            amplitude
        ),
        .phase_advance (
            phase_advance
        ),
        .lut_active_bank (
            lut_active_bank
        ),
        .batch_start (
            calc_batch_start
        ),
        .lut_rd_data (
            lut_rd_data
        ),
        .batch_busy (
            calc_batch_busy
        ),
        .batch_done (
            calc_batch_done
        ),
        .lut_rd_bank (
            lut_rd_bank
        ),
        .lut_rd_en (
            lut_rd_en
        ),
        .lut_rd_addr (
            lut_rd_addr
        ),
        .phase_index (
            calc_phase_index
        ),
        .phase_angle_u16 (
            calc_phase_angle_u16
        ),
        .waveform_sign (
            calc_waveform_sign
        ),
        .waveform_magnitude (
            calc_waveform_magnitude
        ),
        .encoder_snapshot (
            calc_encoder_snapshot
        ),
        .amplitude_snapshot (
            calc_amplitude_snapshot
        ),
        .phase_advance_snapshot (
            calc_phase_advance_snapshot
        ),
        .compare_shadow (
            compare_shadow
        )

    );

    // ========================================================================
    // PWM carrier
    // ========================================================================

    pwm_carrier u_pwm_carrier (

        .clk_200MHz (
            clk_200MHz
        ),
        .rst_n (
            rst_n
        ),
        .carrier (
            pwm_carrier_value
        ),
        .direction_down (
            pwm_direction_down
        ),
        .frame_boundary (
            pwm_frame_boundary
        )

    );

    // ========================================================================
    // Atomic command commit
    // ========================================================================
    //
    // A complete 22-phase compare frame is first captured from compare_shadow.
    //
    // The captured frame becomes compare_active only at a PWM frame boundary.
    //
    // Therefore all 22 phases change atomically.
    //
    // ========================================================================

    command_commit u_command_commit (

        .clk_200MHz (
            clk_200MHz
        ),
        .rst_n (
            rst_n
        ),
        .compare_shadow (
            compare_shadow
        ),
        .shadow_ready (
            calc_batch_done
        ),
        .pwm_frame_boundary (
            pwm_frame_boundary
        ),
        .compare_active (
            compare_active
        ),
        .commit_pending (
            command_commit_pending
        ),
        .commit_pulse (
            command_commit_pulse
        )

    );

    // ========================================================================
    // 22-channel center-aligned PWM comparator
    // ========================================================================
    //
    // Converts:
    //
    //     compare_active[0:21]
    //
    // into:
    //
    //     raw_pwm[21:0]
    //
    // Frozen comparator rule:
    //
    //     compare == 0
    //         -> always OFF
    //
    //     compare >= PWM_TOP
    //         -> always ON
    //
    //     otherwise:
    //
    //         carrier < compare
    //             -> ON
    //
    //         carrier == compare && direction_down
    //             -> ON
    //
    //         otherwise
    //             -> OFF
    //
    // ========================================================================

    pwm_compare_bank u_pwm_compare_bank (

        .clk_200MHz (
            clk_200MHz
        ),
        .rst_n (
            rst_n
        ),
        .carrier (
            pwm_carrier_value
        ),
        .direction_down (
            pwm_direction_down
        ),
        .compare_active (
            compare_active
        ),
        .raw_pwm (
            raw_pwm
        )

    );

    // ========================================================================
    // Gate-drive enable synchronization
    // ========================================================================
    //
    // drive_enable is generated outside the 200 MHz gate-drive domain.
    //
    // Disable is safety-critical and therefore asserts asynchronously:
    //
    //     drive_enable == 0
    //         -> synchronizer clears immediately
    //         -> deadtime state resets immediately
    //
    // Re-enable is intentionally synchronous:
    //
    //     drive_enable == 1
    //         -> two 200 MHz clock stages
    //         -> gate_drive_rst_n releases
    //
    // The final physical-output safety gate below still uses the original
    // drive_enable directly, so disabling the power stage is not delayed by
    // the synchronizer.
    //
    // ========================================================================

    logic drive_enable_sync_ff1;
    logic drive_enable_sync_ff2;
    logic gate_drive_rst_n;

    always_ff @(posedge clk_200MHz or negedge rst_n or negedge drive_enable) begin

        if ((!rst_n) || (!drive_enable)) begin

            drive_enable_sync_ff1 <=
                1'b0;

            drive_enable_sync_ff2 <=
                1'b0;

        end
        else begin

            drive_enable_sync_ff1 <=
                1'b1;

            drive_enable_sync_ff2 <=
                drive_enable_sync_ff1;

        end

    end

    assign gate_drive_rst_n =
        drive_enable_sync_ff2;

    // ========================================================================
    // 22-channel complementary deadtime bank
    // ========================================================================
    //
    // raw_pwm is NOT connected directly to physical gate outputs.
    //
    // Each channel passes through deadtime_channel:
    //
    //     raw_pwm[n]
    //          ->
    //     deadtime_channel
    //          ->
    //     pwm_hi_internal[n]
    //     pwm_lo_internal[n]
    //
    // The deadtime bank guarantees break-before-make behavior.
    //
    // DEADTIME_CLOCKS = 8
    //
    // At 200 MHz:
    //
    //     8 clocks * 5 ns = 40 ns
    //
    // ========================================================================

    deadtime_bank u_deadtime_bank (

        .clk_200MHz (
            clk_200MHz
        ),
        .rst_n (
            gate_drive_rst_n
        ),
        .raw_pwm (
            raw_pwm
        ),
        .pwm_hi (
            pwm_hi_internal
        ),
        .pwm_lo (
            pwm_lo_internal
        )

    );

    // ========================================================================
    // Final safety gate
    // ========================================================================
    //
    // drive_enable is the final external permission to energize the power
    // stage.
    //
    // START / zero-found / HPS state are intentionally outside this core.
    //
    // Regardless of internal PWM state:
    //
    //     rst_n == 0
    //
    // or
    //
    //     drive_enable == 0
    //
    // forces every physical gate output LOW.
    //
    // ========================================================================

    always_comb begin

        if ((!rst_n) || (!drive_enable)) begin

            pwm_hi =
                22'd0;

            pwm_lo =
                22'd0;

        end
        else begin

            pwm_hi =
                pwm_hi_internal;

            pwm_lo =
                pwm_lo_internal;

        end

    end

endmodule
