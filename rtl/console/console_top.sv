// ====================================================================
// Module: console_top
// Type  : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: Top-level module instantiating three encoder readers:
//           1) DTC
//           2) Phase Advance
//           3) VS Rho
// ====================================================================

module console_top (
    input  logic clk,    // System clock

    // Three independent encoder signal pairs
    input  logic a_dtc,  // Encoder A for DTC
    input  logic b_dtc,  // Encoder B for DTC

    input  logic a_phase_advance,  // Encoder A for Phase Advance
    input  logic b_phase_advance,  // Encoder B for Phase Advance

    input  logic a_vs_rho,  // Encoder A for VS Rho
    input  logic b_vs_rho,  // Encoder B for VS Rho

    output logic [6:0]  DTC_value,
    output logic [12:0] phase_advance_value,
    output logic [11:0] vs_rho_value
);

    // -----------------------------------------------------
    // 1️⃣ DTC reader
    // -----------------------------------------------------
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

    // -----------------------------------------------------
    // 2️⃣ Phase Advance reader
    // -----------------------------------------------------
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

    // -----------------------------------------------------
    // 3️⃣ VS Rho reader
    // -----------------------------------------------------
    MBL600_encoder #(
        .WIDTH(12),
        .SHIFT_RIGHT(2),
        .VALUE_MIN(12'd25),
        .VALUE_MAX(12'd4095)
    ) vs_rho_reader_inst (
        .clk(clk),
        .a(a_vs_rho),
        .b(b_vs_rho),
        .value_wire(vs_rho_value)
    );

endmodule
