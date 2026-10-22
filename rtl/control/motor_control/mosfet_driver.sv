// ============================================================================
// mosfet_driver.sv
// Final MOSFET output selection.
// Priority: manual override > bootstrap precharge > normal PWM.
//
// Override bit mapping:
//   override_outputs[21:0]  -> pwm_lo[21:0]
//   override_outputs[43:22] -> pwm_hi[21:0]
//
// No interlock or dead-time is added to manual override.
// Precharge is only permitted when precharge_active is asserted; the caller
// must drive it from the 50 MHz bootstrap_precharge controller.
// During precharge, all high-side outputs are forced low.
// Until normal_enable, normal PWM is inhibited (both banks zero).
// The caller must safely synchronize clock-domain control signals as needed.
// ============================================================================
module mosfet_driver (
    input  logic [21:0] normal_pwm_hi,
    input  logic [21:0] normal_pwm_lo,
    input  logic        override_enable,
    input  logic [43:0] override_outputs,
    input  logic        precharge_active,
    input  logic [21:0] precharge_lo,
    input  logic        normal_enable,
    output logic [21:0] pwm_hi,
    output logic [21:0] pwm_lo
);
    always_comb begin
        pwm_hi = '0;
        pwm_lo = '0;
        if (override_enable) begin
            pwm_hi = override_outputs[43:22];
            pwm_lo = override_outputs[21:0];
        end else if (precharge_active) begin
            pwm_hi = '0;
            pwm_lo = precharge_lo;
        end else if (normal_enable) begin
            pwm_hi = normal_pwm_hi;
            pwm_lo = normal_pwm_lo;
        end
    end
endmodule
