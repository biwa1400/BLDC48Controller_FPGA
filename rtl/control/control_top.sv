module control_top #(
    // -------- Configurable parameters --------
    parameter LM10_WIDTH    = 12,         // Encoder resolution bits
    parameter LM10_COUNTS   = 4096,       // Encoder total counts
    parameter ADC_BITS      = 12,         // ADC resolution bits
    parameter VS_RHO_MIN    = constants_pkg::VS_RHO_MIN,
    parameter INIT_PHI      = constants_pkg::INIT_PHI
)(
    // -------- Input signals --------
    input  logic clk_50m,                          // System clock
    input  logic [LM10_WIDTH-1:0] phi,            // Rotor mechanical angle (0~4095)
    input  logic [15:0] rpm,                      // Rotor speed in RPM

    // -------- Voltage & phase outputs --------
    input logic [11:0] vs_rho,                    // Voltage magnitude
    input logic [LM10_WIDTH-1:0] phase_advance,   // Phase advance

    // -------- PWM output array --------
    output logic [12:0] pwm_duty [0:21],         // Array of 22 PWM duties, each 13-bit wide
    output logic init_start,                      // Initialization start flag

    input logic encoder_ok,                       // Encoder Z-index found flag
    input logic run
);

foc_top #(
    .LM10_WIDTH     ( LM10_WIDTH   ),
    .LM10_COUNTS    ( LM10_COUNTS ),
    .ADC_BITS       ( ADC_BITS       ),
    .INIT_CYCLES    ( 50000000       ), // 本例中，时钟(clk)频率为 50MHz，初始化时间=1秒
//  .ANGLE_INV      ( 1'b1           ), // 角度传感器是否装反
    .POLE_PAIR      ( 2'd3           ), // 电机极对数为 3
    .INIT_PHI       ( INIT_PHI       ),
    .SAMPLE_DELAY   ( 9'd120         ), // 采样延时
    .Kp             ( 24'd32768      ), // 电流环 PID P 参数
    .Ki             ( 24'd2          )  // 电流环 PID I 参数
) foc_top_i (
//  .rstn           ( rstn           ),
    .clk            ( clk_50m        ),
//  .svpwm_clk      ( clk_400m       ),
    .encoder_ok     ( encoder_ok     ), // 编码器 Z 索引找到标志
    .phi            ( phi            ), // 机械角度
    .rpm            ( rpm            ), // 转速
//  .sn_adc         (                 ), // ADC 采样时刻控制信号
//  .en_adc         ( en_adc          ), // ADC 采样有效信号
//  .adc_1          ( adc_1           ), // ADC 相位1
//  .adc_2          ( adc_3           ),
//  .adc_3          ( adc_5           ),
//  .adc_4          ( adc_7           ),
//  .adc_5          ( adc_9           ),
//  .adc_6          ( adc_11          ),
//  .adc_7          ( adc_13          ),
//  .adc_8          ( adc_15          ),
//  .adc_9          ( adc_17          ),
//  .adc_10         ( adc_19          ),
//  .adc_11         ( adc_21          ),
    .pwm1_duty      ( pwm_duty[0]    ),
    .pwm2_duty      ( pwm_duty[1]    ),
    .pwm3_duty      ( pwm_duty[2]    ),
    .pwm4_duty      ( pwm_duty[3]    ),
    .pwm5_duty      ( pwm_duty[4]    ),
    .pwm6_duty      ( pwm_duty[5]    ),
    .pwm7_duty      ( pwm_duty[6]    ),
    .pwm8_duty      ( pwm_duty[7]    ),
    .pwm9_duty      ( pwm_duty[8]    ),
    .pwm10_duty     ( pwm_duty[9]    ),
    .pwm11_duty     ( pwm_duty[10]   ),
    .pwm12_duty     ( pwm_duty[11]   ),
    .pwm13_duty     ( pwm_duty[12]   ),
    .pwm14_duty     ( pwm_duty[13]   ),
    .pwm15_duty     ( pwm_duty[14]   ),
    .pwm16_duty     ( pwm_duty[15]   ),
    .pwm17_duty     ( pwm_duty[16]   ),
    .pwm18_duty     ( pwm_duty[17]   ),
    .pwm19_duty     ( pwm_duty[18]   ),
    .pwm20_duty     ( pwm_duty[19]   ),
    .pwm21_duty     ( pwm_duty[20]   ),
    .pwm22_duty     ( pwm_duty[21]   ),
//  .en_idq         ( en_idq         ), // 输出信号
//  .id             ( id             ),
//  .iq             ( iq             ),
//  .id_aim         ( id_aim         ),
//  .iq_aim         ( iq_aim         ),
    .init_done      (                 ), // 初始化结束信号
    .init_start     ( init_start     ),
    .vs_rho         ( vs_rho         ),
    .phase_advance  ( phase_advance  )
);

always @ (posedge clk_50m) begin
    if (encoder_ok && run && vs_rho > VS_RHO_MIN + 12'd15)
        init_start <= 1'b1;
    else 
        init_start <= 1'b0;
end

endmodule
