// 22-phase PWM output remapper.
// LEGACY_PHASE_MAPPING=1: reproduce legacy physical output ordering.
// LEGACY_PHASE_MAPPING=0: identity mapping (new project original).
module pwm_phase_remapper #(
    parameter bit LEGACY_PHASE_MAPPING = 1'b1
) (
    input  logic [21:0] pwm_hi_in,
    input  logic [21:0] pwm_lo_in,
    output logic [21:0] pwm_hi_out,
    output logic [21:0] pwm_lo_out
);

    generate
        if (LEGACY_PHASE_MAPPING) begin : g_legacy
            assign pwm_hi_out[ 0] = pwm_hi_in[ 0];
            assign pwm_lo_out[ 0] = pwm_lo_in[ 0];
            assign pwm_hi_out[ 1] = pwm_hi_in[ 3];
            assign pwm_lo_out[ 1] = pwm_lo_in[ 3];
            assign pwm_hi_out[ 2] = pwm_hi_in[ 6];
            assign pwm_lo_out[ 2] = pwm_lo_in[ 6];
            assign pwm_hi_out[ 3] = pwm_hi_in[ 9];
            assign pwm_lo_out[ 3] = pwm_lo_in[ 9];
            assign pwm_hi_out[ 4] = pwm_hi_in[12];
            assign pwm_lo_out[ 4] = pwm_lo_in[12];
            assign pwm_hi_out[ 5] = pwm_hi_in[15];
            assign pwm_lo_out[ 5] = pwm_lo_in[15];
            assign pwm_hi_out[ 6] = pwm_hi_in[18];
            assign pwm_lo_out[ 6] = pwm_lo_in[18];
            assign pwm_hi_out[ 7] = pwm_hi_in[21];
            assign pwm_lo_out[ 7] = pwm_lo_in[21];
            assign pwm_hi_out[ 8] = pwm_hi_in[ 2];
            assign pwm_lo_out[ 8] = pwm_lo_in[ 2];
            assign pwm_hi_out[ 9] = pwm_hi_in[ 5];
            assign pwm_lo_out[ 9] = pwm_lo_in[ 5];
            assign pwm_hi_out[10] = pwm_hi_in[ 8];
            assign pwm_lo_out[10] = pwm_lo_in[ 8];
            assign pwm_hi_out[11] = pwm_hi_in[11];
            assign pwm_lo_out[11] = pwm_lo_in[11];
            assign pwm_hi_out[12] = pwm_hi_in[14];
            assign pwm_lo_out[12] = pwm_lo_in[14];
            assign pwm_hi_out[13] = pwm_hi_in[17];
            assign pwm_lo_out[13] = pwm_lo_in[17];
            assign pwm_hi_out[14] = pwm_hi_in[20];
            assign pwm_lo_out[14] = pwm_lo_in[20];
            assign pwm_hi_out[15] = pwm_hi_in[ 1];
            assign pwm_lo_out[15] = pwm_lo_in[ 1];
            assign pwm_hi_out[16] = pwm_hi_in[ 4];
            assign pwm_lo_out[16] = pwm_lo_in[ 4];
            assign pwm_hi_out[17] = pwm_hi_in[ 7];
            assign pwm_lo_out[17] = pwm_lo_in[ 7];
            assign pwm_hi_out[18] = pwm_hi_in[10];
            assign pwm_lo_out[18] = pwm_lo_in[10];
            assign pwm_hi_out[19] = pwm_hi_in[13];
            assign pwm_lo_out[19] = pwm_lo_in[13];
            assign pwm_hi_out[20] = pwm_hi_in[16];
            assign pwm_lo_out[20] = pwm_lo_in[16];
            assign pwm_hi_out[21] = pwm_hi_in[19];
            assign pwm_lo_out[21] = pwm_lo_in[19];
        end else begin : g_identity
            assign pwm_hi_out = pwm_hi_in;
            assign pwm_lo_out = pwm_lo_in;
        end
    endgenerate

endmodule
