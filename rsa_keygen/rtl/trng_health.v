`timescale 1ns/1ps
// ============================================================================
// trng_health.v - Kiem tra suc khoe TREN BIT THO (Ch.3 §3.6, §3.6.1)
//   * Startup test : rng_ok = 1 chi sau STARTUP cua so lien tiep deu dat.
//   * Tot test     : RCT_MAX bit tho giong nhau lien tiep -> bao dong ngay.
//   * Online test  : moi cua so WIN bit, so bit 1 phai trong [LO, HI] (monobit).
//                    1 cua so truot = "pre-alarm"; PRE_N cua so truot lien tiep
//                    = bao dong (giong quy tac pre-alarm/alarm o §3.6.1).
//   noise_alarm giu nguyen den khi reset.
// ============================================================================
module trng_health #(
    parameter RCT_MAX = 48,
    parameter WIN     = 256,
    parameter LO      = 96,
    parameter HI      = 160,
    parameter PRE_N   = 2,
    parameter STARTUP = 4
)(
    input  wire clk,
    input  wire rst_n,
    input  wire raw_valid,
    input  wire raw_bit,
    output reg  rng_ok,
    output reg  noise_alarm,
    output reg  [2:0] alarm_src     // bit0 tot (RCT), bit1 online (monobit)
);
    localparam RW = $clog2(RCT_MAX+1);
    localparam WW = $clog2(WIN+1);
    reg          last;
    reg [RW-1:0] run;
    reg [WW-1:0] wcnt, ones;
    reg [3:0]    pre, good;

    wire [WW-1:0] ones_n = ones + raw_bit;
    wire          win_end = (wcnt == WIN-1);
    wire          win_pass = (ones_n >= LO) && (ones_n <= HI);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last <= 0; run <= 0; wcnt <= 0; ones <= 0; pre <= 0; good <= 0;
            rng_ok <= 0; noise_alarm <= 0; alarm_src <= 0;
        end else if (raw_valid && !noise_alarm) begin
            // ---- tot test: dem do dai chuoi bit giong nhau ----
            if (raw_bit == last && run != 0) begin
                run <= run + 1'b1;
                if (run + 1'b1 >= RCT_MAX) begin
                    noise_alarm <= 1'b1; rng_ok <= 1'b0; alarm_src[0] <= 1'b1;
                end
            end else run <= 1;
            last <= raw_bit;
            // ---- online test: monobit theo cua so ----
            if (win_end) begin
                wcnt <= 0; ones <= 0;
                if (win_pass) begin
                    pre <= 0;
                    if (good < STARTUP) good <= good + 1'b1;
                    if (good + 1'b1 >= STARTUP) rng_ok <= 1'b1;
                end else begin
                    pre <= pre + 1'b1;
                    if (pre + 1'b1 >= PRE_N || !rng_ok) begin   // khi khoi dong: truot 1 lan = bao dong
                        noise_alarm <= 1'b1; rng_ok <= 1'b0; alarm_src[1] <= 1'b1;
                    end
                end
            end else begin
                wcnt <= wcnt + 1'b1;
                ones <= ones_n;
            end
        end
    end
endmodule
