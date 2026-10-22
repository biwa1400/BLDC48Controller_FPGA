// ============================================================================
// console_top.sv
//
// BLDC48Controller FPGA
//
// Three independent rotary encoder readers:
//
//     1. DTC
//     2. Phase Advance
//     3. VS Rho
//
// VS Rho configuration is defined in:
//
//     rtl/constants_pkg.sv
//
// ============================================================================

module console_top (

    input  logic clk,

    input  logic a_dtc,
    input  logic b_dtc,

    input  logic a_phase_advance,
    input  logic b_phase_advance,

    input  logic a_vs_rho,
    input  logic b_vs_rho,

    output logic [6:0]  DTC_value,
    output logic [12:0] phase_advance_value,
    output logic [11:0] vs_rho_value

);

    import constants_pkg::*;

    // ========================================================================
    // 1. DTC reader
    // ========================================================================

    MBL600_encoder #(
        .WIDTH(7),
        .SHIFT_RIGHT(3),
        .VALUE_MIN(7'd20),
        .VALUE_MAX(7'd127)
    ) DTC_reader_inst (
        .clk(clk),
        .a(a_dtc),
        .b(b_dtc),
        .value_wire(DTC_value)
    );


    // ========================================================================
    // 2. Phase Advance reader
    // ========================================================================

    MBL600_encoder #(
        .WIDTH(13),
        .SHIFT_RIGHT(2),
        .VALUE_MIN(13'd0),
        .VALUE_MAX(13'd1600)
    ) phase_advance_reader_inst (
        .clk(clk),
        .a(a_phase_advance),
        .b(b_phase_advance),
        .value_wire(phase_advance_value)
    );


    // ========================================================================
    // 3. VS Rho reader
    // ========================================================================
    //
    // Configuration:
    //
    //     rtl/constants_pkg.sv
    //
    //     VS_RHO_MIN
    //     VS_RHO_INIT
    //     VS_RHO_MAX
    //
    // Initial value will be configured separately
    // in MBL600_encoder.sv.
    //
    // ========================================================================

    MBL600_encoder #(
        .WIDTH(12),
        .SHIFT_RIGHT(2),
        .VALUE_MIN(VS_RHO_MIN),
        .VALUE_MAX(VS_RHO_MAX)
    ) vs_rho_reader_inst (
        .clk(clk),
        .a(a_vs_rho),
        .b(b_vs_rho),
        .value_wire(vs_rho_value)
    );

endmodule