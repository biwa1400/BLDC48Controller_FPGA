// ============================================================================
// bootstrap_precharge.sv
// 22-channel low-side bootstrap capacitor precharge sequencer.
// CLK_HZ must match the clock connected to clk.
// Output bits [0]..[21] correspond to Low 1..Low 22.
// The caller must route outputs to the MOSFET pins and inhibit normal PWM
// until normal_enable is asserted. Manual override remains external.
// ============================================================================
module bootstrap_precharge #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer CHANNELS = 22
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start_request,
    output logic [CHANNELS-1:0] precharge_lo,
    output logic [CHANNELS-1:0] precharge_hi,
    output logic                normal_enable
);
    localparam integer STEP_CYCLES = CLK_HZ / 100;  // 10 ms
    localparam integer HOLD_CYCLES = CLK_HZ / 10;   // 100 ms
    localparam integer OFF_CYCLES  = CLK_HZ / 1000; // 1 ms
    localparam integer MAX_CYCLES = (HOLD_CYCLES > STEP_CYCLES) ? HOLD_CYCLES : STEP_CYCLES;
    localparam integer TIMER_WIDTH = $clog2(MAX_CYCLES + 1);
    localparam integer INDEX_WIDTH = $clog2(CHANNELS + 1);

    typedef enum logic [2:0] {IDLE, STEP, HOLD, OFF_WAIT, RUN} state_t;
    state_t state;
    logic [TIMER_WIDTH-1:0] timer;
    logic [INDEX_WIDTH-1:0] count_on;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            timer <= '0;
            count_on <= '0;
        end else if (!start_request) begin
            // Abort immediately on loss of start permission.
            state <= IDLE;
            timer <= '0;
            count_on <= '0;
        end else begin
            case (state)
                IDLE: begin
                    state <= STEP;
                    timer <= '0;
                    count_on <= 1; // Low 1 turns on immediately.
                end
                STEP: begin
                    if (timer == STEP_CYCLES - 1) begin
                        timer <= '0;
                        if (count_on == CHANNELS) begin
                            state <= HOLD;
                        end else begin
                            count_on <= count_on + 1'b1;
                            if (count_on == CHANNELS - 1)
                                state <= HOLD; // 100 ms begins when Low 22 turns on.
                        end
                    end else timer <= timer + 1'b1;
                end
                HOLD: begin
                    if (timer == HOLD_CYCLES - 1) begin
                        timer <= '0;
                        state <= OFF_WAIT;
                    end else timer <= timer + 1'b1;
                end
                OFF_WAIT: begin
                    if (timer == OFF_CYCLES - 1) begin
                        timer <= '0;
                        state <= RUN;
                    end else timer <= timer + 1'b1;
                end
                RUN: begin
                    timer <= '0;
                end
                default: begin
                    state <= IDLE;
                    timer <= '0;
                    count_on <= '0;
                end
            endcase
        end
    end

    always_comb begin
        precharge_hi = '0;
        precharge_lo = '0;
        normal_enable = 1'b0;
        if (rst_n && start_request) begin
            case (state)
                STEP, HOLD: begin
                    for (integer i = 0; i < CHANNELS; i = i + 1)
                        precharge_lo[i] = (i < count_on);
                end
                RUN: normal_enable = 1'b1;
                default: ;
            endcase
        end
    end
endmodule
