// ============================================================================
// motor_control_adapter.sv
//
// Compatibility adapter between the legacy AC501_SoC_GHRD control interface
// and the frozen motor-control RTL.
//
// Responsibilities:
//   1. Pass the 13-bit LM10 encoder value through unchanged.
//   2. Convert legacy VS_RHO 12-bit magnitude to Q12 amplitude.
//   3. Convert legacy 0..6399 electrical-angle phase advance to U16 angle.
//   4. Reproduce the legacy external drive-enable condition.
//
// The frozen motor_drive_core is NOT modified by this adapter.
//
// Legacy phase-angle domain:
//   0    =   0 deg
//   1600 =  90 deg
//   3200 = 180 deg
//   4800 = 270 deg
//   6400 = 360 deg
//
// U16 angle domain:
//   0     =   0 deg
//   16384 =  90 deg
//   32768 = 180 deg
//   49152 = 270 deg
//
// Conversion:
//   phase_advance_u16 =
//       ROUND_HALF_UP(phase_advance_legacy * 65536 / 6400)
//
// The original /6400 implementation is replaced by a bit-exact reciprocal
// multiply. The replacement has been exhaustively verified for the complete
// 13-bit input domain 0..8191.
// ============================================================================

module motor_control_adapter #(
    parameter logic [11:0] VS_RHO_MIN = 12'd0
) (
    input  logic [12:0] encoder_legacy,
    input  logic [11:0] vs_rho_legacy,
    input  logic [12:0] phase_advance_legacy,
    input  logic        encoder_ref_ready,
    input  logic        run,

    output logic [12:0] encoder_core,
    output logic [12:0] amplitude_core,
    output logic [15:0] phase_advance_core,
    output logic        drive_enable_core
);

    logic [33:0] phase_advance_reciprocal;

    // ------------------------------------------------------------------------
    // Encoder
    // ------------------------------------------------------------------------
    // Both interfaces use the physical LM10 13-bit value, range 0..6399.
    // No conversion is required.
    assign encoder_core = encoder_legacy;

    // ------------------------------------------------------------------------
    // Amplitude
    // ------------------------------------------------------------------------
    // Legacy VS_RHO uses the same Q12 numerical magnitude.
    // Preserve every legacy value exactly by zero-extension.
    //
    // Legacy reachable range: 25..4095
    // Frozen core legal range: 0..4096
    //
    // Exact core full-scale value 4096 is intentionally not synthesized from
    // legacy value 4095 because that would alter the legacy numerical meaning.
    assign amplitude_core = {1'b0, vs_rho_legacy};

    // ------------------------------------------------------------------------
    // Phase advance
    // ------------------------------------------------------------------------
    // Convert the legacy 6400-count electrical-angle domain to U16 using the
    // same ROUND_HALF_UP convention used by the frozen encoder mathematics.
    //
    // Original implementation:
    //
    //     (phase_advance_legacy * 65536 + 3200) / 6400
    //
    // The following reciprocal-multiply implementation is bit-exact over the
    // complete 13-bit input domain 0..8191:
    //
    //     (phase_advance_legacy * 1342177 + 65536) >> 17
    //
    // Maximum intermediate value:
    //
    //     8191 * 1342177 + 65536 = 10993837343
    //
    // which fits in 34 unsigned bits.
    assign phase_advance_reciprocal =
        (phase_advance_legacy * 34'd1342177) + 34'd65536;

    assign phase_advance_core =
        phase_advance_reciprocal[32:17];

    // ------------------------------------------------------------------------
    // External drive permission
    // ------------------------------------------------------------------------
    // Preserve the legacy control_top start condition:
    //
    // encoder_ok && run && vs_rho > VS_RHO_MIN + 15
    //
    // Encoder zero-found/start policy intentionally remains outside the frozen
    // motor_drive_core.
    assign drive_enable_core =
        encoder_ref_ready &&
        run &&
        (vs_rho_legacy > (VS_RHO_MIN + 12'd15));

endmodule