// ============================================================================
// motor_control_pkg.sv
//
// BLDC48Controller - Motor Control Common Definitions
//
// This package contains fixed architectural constants shared by the
// motor-control RTL.
//
// These values are derived from the validated Python fixed-point
// Golden Model.
//
// Runtime commands such as amplitude and phase_advance are intentionally
// NOT defined here.
//
// ============================================================================

package motor_control_pkg;

    // ========================================================================
    // Motor / Encoder Configuration
    // ========================================================================

    // LM10 encoder:
    //
    // 6400 counts = one mechanical revolution.
    //
    // Legal physical encoder range:
    //
    //     0 ... 6399
    //
    // 13 bits are required to represent this range.
    localparam integer ENCODER_BITS   = 13;
    localparam integer ENCODER_COUNTS = 6400;

    // Mechanical zero offset in raw LM10 counts.
    //
    // This is the physical calibrated mounting offset and is intentionally
    // retained from the existing motor configuration.
    localparam integer ENCODER_OFFSET = 1022;

    // Number of motor pole pairs.
    localparam integer POLE_PAIRS = 3;


    // ========================================================================
    // Internal Angle Representation
    // ========================================================================

    // U16 angle representation:
    //
    //      0 =   0 degrees
    //  16384 =  90 degrees
    //  32768 = 180 degrees
    //  49152 = 270 degrees
    //
    // 65536 counts = one complete revolution.
    localparam integer ANGLE_BITS = 16;

    localparam integer ANGLE_MODULUS = 65536;

    localparam logic [15:0] ANGLE_90  = 16'd16384;
    localparam logic [15:0] ANGLE_180 = 16'd32768;
    localparam logic [15:0] ANGLE_270 = 16'd49152;


    // ========================================================================
    // Encoder Domain -> U16 Mechanical Angle Conversion
    // ========================================================================
    //
    // Physical encoder domain:
    //
    //     0 ... 6399
    //
    // Internal mechanical-angle domain:
    //
    //     0 ... 65535
    //
    // The conversion is defined by the validated Python Fixed-Point
    // Golden Model as:
    //
    //     mechanical_u16
    //         =
    //     ROUND_HALF_UP(
    //         relative_encoder * 65536 / 6400
    //     )
    //
    // For positive integer arithmetic this is implemented exactly as:
    //
    //     mechanical_u16
    //         =
    //     (
    //         relative_encoder * 65536
    //         + 3200
    //     )
    //     / 6400
    //
    // These constants intentionally mirror:
    //
    //     ENCODER_ANGLE_NUMERATOR
    //     ENCODER_ANGLE_DENOMINATOR
    //     ENCODER_ANGLE_ROUNDING_BIAS
    //
    // in fixed_derived_config.py.
    //
    // NOTE:
    //
    // 6400 is not a power of two.
    //
    // Therefore the previous 4096-count implementation based on:
    //
    //     relative_encoder << 4
    //
    // is no longer valid.
    //
    // Likewise, modulo-6400 encoder wrapping must not be implemented using
    // a bit mask or by relying on fixed-width overflow.
    //
    // ========================================================================

    localparam integer ENCODER_ANGLE_NUMERATOR =
        ANGLE_MODULUS;

    localparam integer ENCODER_ANGLE_DENOMINATOR =
        ENCODER_COUNTS;

    localparam integer ENCODER_ANGLE_ROUNDING_BIAS =
        ENCODER_COUNTS / 2;


    // ========================================================================
    // Waveform LUT Configuration
    // ========================================================================

    // Half-wave LUT:
    //
    // 4096 entries represent 0 ... 180 degrees.
    //
    // Full-wave sign is reconstructed from angle bit 15.
    localparam integer LUT_ADDRESS_BITS = 12;
    localparam integer LUT_DATA_BITS    = 13;
    localparam integer LUT_DEPTH        = 4096;

    // LUT magnitude scale:
    //
    // 4096 = 1.0
    //
    localparam integer LUT_SCALE = 4096;

    // Maximum legal LUT magnitude.
    localparam integer LUT_MAX_COMMAND = 4096;

    // For the half-wave LUT:
    //
    // angle[14:0] represents 0 ... 180 degrees.
    //
    // 32768 angle counts / 4096 LUT addresses = 8.
    //
    // Therefore:
    //
    //     lut_addr = angle[14:3]
    //
    localparam integer LUT_ADDRESS_SHIFT = 3;

    // Two waveform LUT banks are used.
    localparam integer LUT_BANKS = 2;


    // ========================================================================
    // Amplitude Configuration
    // ========================================================================

    // Runtime amplitude format:
    //
    // unsigned Q1.12
    //
    //      0 = 0.0
    //   2048 = 0.5
    //   4096 = 1.0
    //
    localparam integer AMPLITUDE_BITS      = 13;
    localparam integer AMPLITUDE_FRAC_BITS = 12;

    localparam integer AMPLITUDE_SCALE        = 4096;
    localparam integer AMPLITUDE_MAX_COMMAND  = 4096;


    // ========================================================================
    // PWM Configuration
    // ========================================================================

    // PWM clock:
    //
    // 200 MHz -> 5 ns per clock.
    localparam integer PWM_CLOCK_HZ = 200000000;

    // Center-aligned triangular carrier.
    //
    // Carrier range:
    //     0 ... 6666
    //
    // One complete PWM period:
    //
    //     2 * 6666 = 13332 clocks
    //
    // Actual PWM frequency:
    //
    //     200 MHz / 13332
    //       ~= 15001.5 Hz
    //
    localparam integer PWM_TOP    = 6666;
    localparam integer PWM_CENTER = 3333;

    localparam integer PWM_PERIOD_CLOCKS = 13332;

    // PWM compare values are stored in 13 bits.
    localparam integer PWM_COMPARE_BITS = 13;


    // ========================================================================
    // Fixed-Point PWM Scaling
    // ========================================================================

    // Waveform magnitude:
    //
    //     W / 4096
    //
    // Amplitude:
    //
    //     A / 4096
    //
    // PWM deviation:
    //
    //     delta = W * A * PWM_CENTER / 2^24
    //
    // Therefore the denominator is:
    //
    //     4096 * 4096 = 2^24
    //
    localparam integer PWM_SCALE_DENOMINATOR_BITS = 24;

    // ROUND_HALF_UP bias before >> 24.
    localparam integer PWM_ROUNDING_BIAS = 8388608;


    // ========================================================================
    // Deadtime Configuration
    // ========================================================================

    // 200 MHz:
    //
    //     1 clock = 5 ns
    //
    // 8 clocks:
    //
    //     8 * 5 ns = 40 ns
    //
    localparam integer DEADTIME_CLOCKS = 8;


    // ========================================================================
    // Phase Configuration
    // ========================================================================

    localparam integer NUM_PHASES = 22;

    // 22 equally spaced electrical phases.
    //
    // Ideal spacing:
    //
    //     65536 / 22
    //
    // Each phase offset is independently quantized using ROUND_HALF_UP.
    //
    // Important invariant:
    //
    //     PHASE_OFFSET[k + 11]
    //         =
    //     PHASE_OFFSET[k] + 32768  (mod 65536)
    //
    // Thus opposite phases remain exactly 180 degrees apart.

    localparam logic [15:0] PHASE_OFFSET_00 = 16'd0;
    localparam logic [15:0] PHASE_OFFSET_01 = 16'd2979;
    localparam logic [15:0] PHASE_OFFSET_02 = 16'd5958;
    localparam logic [15:0] PHASE_OFFSET_03 = 16'd8937;
    localparam logic [15:0] PHASE_OFFSET_04 = 16'd11916;
    localparam logic [15:0] PHASE_OFFSET_05 = 16'd14895;
    localparam logic [15:0] PHASE_OFFSET_06 = 16'd17873;
    localparam logic [15:0] PHASE_OFFSET_07 = 16'd20852;
    localparam logic [15:0] PHASE_OFFSET_08 = 16'd23831;
    localparam logic [15:0] PHASE_OFFSET_09 = 16'd26810;
    localparam logic [15:0] PHASE_OFFSET_10 = 16'd29789;

    localparam logic [15:0] PHASE_OFFSET_11 = 16'd32768;
    localparam logic [15:0] PHASE_OFFSET_12 = 16'd35747;
    localparam logic [15:0] PHASE_OFFSET_13 = 16'd38726;
    localparam logic [15:0] PHASE_OFFSET_14 = 16'd41705;
    localparam logic [15:0] PHASE_OFFSET_15 = 16'd44684;
    localparam logic [15:0] PHASE_OFFSET_16 = 16'd47663;
    localparam logic [15:0] PHASE_OFFSET_17 = 16'd50641;
    localparam logic [15:0] PHASE_OFFSET_18 = 16'd53620;
    localparam logic [15:0] PHASE_OFFSET_19 = 16'd56599;
    localparam logic [15:0] PHASE_OFFSET_20 = 16'd59578;
    localparam logic [15:0] PHASE_OFFSET_21 = 16'd62557;


    // ========================================================================
    // Phase Offset Lookup Function
    // ========================================================================

    // A function is used instead of a package array to maintain compatibility
    // with the older VCS toolchain.

    function automatic [15:0] get_phase_offset;

        input integer phase_index;

        begin
            case (phase_index)

                 0: get_phase_offset = PHASE_OFFSET_00;
                 1: get_phase_offset = PHASE_OFFSET_01;
                 2: get_phase_offset = PHASE_OFFSET_02;
                 3: get_phase_offset = PHASE_OFFSET_03;
                 4: get_phase_offset = PHASE_OFFSET_04;
                 5: get_phase_offset = PHASE_OFFSET_05;
                 6: get_phase_offset = PHASE_OFFSET_06;
                 7: get_phase_offset = PHASE_OFFSET_07;
                 8: get_phase_offset = PHASE_OFFSET_08;
                 9: get_phase_offset = PHASE_OFFSET_09;
                10: get_phase_offset = PHASE_OFFSET_10;

                11: get_phase_offset = PHASE_OFFSET_11;
                12: get_phase_offset = PHASE_OFFSET_12;
                13: get_phase_offset = PHASE_OFFSET_13;
                14: get_phase_offset = PHASE_OFFSET_14;
                15: get_phase_offset = PHASE_OFFSET_15;
                16: get_phase_offset = PHASE_OFFSET_16;
                17: get_phase_offset = PHASE_OFFSET_17;
                18: get_phase_offset = PHASE_OFFSET_18;
                19: get_phase_offset = PHASE_OFFSET_19;
                20: get_phase_offset = PHASE_OFFSET_20;
                21: get_phase_offset = PHASE_OFFSET_21;

                default:
                    get_phase_offset = 16'd0;

            endcase
        end

    endfunction


endpackage