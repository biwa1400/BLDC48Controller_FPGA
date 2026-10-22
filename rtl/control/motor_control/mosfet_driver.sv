// ============================================================================
// mosfet_driver.sv
// Final MOSFET output selection: normal motor PWM or manual override.
//
// Override bit mapping:
//   override_outputs[21:0]  -> pwm_lo[21:0]
//   override_outputs[43:22] -> pwm_hi[21:0]
//
// No interlock or dead-time is added in the manual override path.
// ============================================================================
module mosfet_driver (
    input  logic [21:0] normal_pwm_hi,
    input  logic [21:0] normal_pwm_lo,
    input  logic        override_enable,
    input  logic [43:0] override_outputs,
    output logic [21:0] pwm_hi,
    output logic [21:0] pwm_lo
);

    always_comb begin
        if (override_enable) begin
            pwm_hi = override_outputs[43:22];
            pwm_lo = override_outputs[21:0];
        end else begin
            pwm_hi = normal_pwm_hi;
            pwm_lo = normal_pwm_lo;
        end
    end

endmodule
