`timescale 1ns/1ps
// tb_trng.v - startup test, ti le bit 1 sau von Neumann, va bao dong khi nguon chet
module tb_trng;
    reg clk = 0, rst_n = 0, take = 0;
    wire [31:0] word;
    wire word_valid, rng_ok, noise_alarm, raw_dbg;
    wire [2:0] alarm_src;
    integer i, k, ones = 0, words = 0, t_ok, t_dead, t_alarm;

    trng_top #(.SAMPLE_DIV(4)) dut (.clk(clk), .rst_n(rst_n), .take(take), .word(word),
        .word_valid(word_valid), .rng_ok(rng_ok), .noise_alarm(noise_alarm),
        .alarm_src(alarm_src), .raw_bit_dbg(raw_dbg));
    always #5 clk = ~clk;

    initial begin
        #25 rst_n = 1;
        @(posedge rng_ok); t_ok = $time;
        $display("rng_ok len sau %0d chu ky (startup = 4 cua so x 256 bit tho x 4 chu ky/bit)", (t_ok - 25) / 10);
        for (i = 0; i < 500; i = i + 1) begin
            wait (word_valid); @(posedge clk); #1;
            for (k = 0; k < 32; k = k + 1) ones = ones + word[k];
            words = words + 1;
            take = 1; @(posedge clk); #1 take = 0;
        end
        $display("%0d tu 32 bit: ti le bit 1 = %0d / %0d", words, ones, words * 32);
        // --- gia lap nguon entropy chet han ---
        dut.u_ro.stuck = 1'b1; t_dead = $time;
        @(posedge noise_alarm); t_alarm = $time;
        $display("Nguon chet -> noise_alarm sau %0d chu ky (alarm_src = %b, 01 = tot test), rng_ok = %0d",
                 (t_alarm - t_dead) / 10, alarm_src, rng_ok);
        $finish;
    end
endmodule
