`timescale 1ns/1ps
// ============================================================================
// trng_top.v - TRNG day du: trng_ro -> trng_health (bit tho) + trng_post
//   SAMPLE_DIV: so chu ky clk giua 2 lan lay mau (cang lon jitter tich luy cang nhieu).
// ============================================================================
module trng_top #(
    parameter SAMPLE_DIV = 64,
    parameter WW         = 32,
    parameter RCT_MAX    = 48,
    parameter WIN        = 256,
    parameter LO         = 96,
    parameter HI         = 160,
    parameter STARTUP    = 4,
    parameter SEED       = 32'h1234_5678
)(
    input  wire          clk,
    input  wire          rst_n,
    input  wire          take,
    output wire [WW-1:0] word,
    output wire          word_valid,
    output wire          rng_ok,
    output wire          noise_alarm,
    output wire [2:0]    alarm_src,
    output wire          raw_bit_dbg,
    output wire          raw_valid_dbg
);
    reg [$clog2(SAMPLE_DIV+1)-1:0] div;
    reg sample_en;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin div <= 0; sample_en <= 0; end
        else begin
            sample_en <= (div == SAMPLE_DIV-1);
            div <= (div == SAMPLE_DIV-1) ? 0 : div + 1'b1;
        end
    end

    wire raw_bit, raw_valid;
    trng_ro #(.SEED(SEED)) u_ro (.clk(clk), .rst_n(rst_n), .sample_en(sample_en),
                                 .raw_bit(raw_bit), .raw_valid(raw_valid));
    trng_health #(.RCT_MAX(RCT_MAX), .WIN(WIN), .LO(LO), .HI(HI), .STARTUP(STARTUP))
        u_health (.clk(clk), .rst_n(rst_n), .raw_valid(raw_valid), .raw_bit(raw_bit),
                  .rng_ok(rng_ok), .noise_alarm(noise_alarm), .alarm_src(alarm_src));
    trng_post #(.WW(WW)) u_post (.clk(clk), .rst_n(rst_n), .raw_valid(raw_valid),
                                 .raw_bit(raw_bit), .take(take), .word(word), .word_valid(word_valid));
    assign raw_bit_dbg   = raw_bit;
    assign raw_valid_dbg = raw_valid;
endmodule
