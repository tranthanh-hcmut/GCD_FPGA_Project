`timescale 1ns/1ps
// tb_modexp.v - kiem modexp so voi luy thua hanh vi; latency chi phu thuoc ebits
module tb_modexp;
    parameter N = 32;
    localparam EW = 2*N;
    reg clk = 0, rst_n = 0, start = 0;
    reg  [N-1:0]  x, m;
    reg  [EW-1:0] e;
    reg  [$clog2(EW+1)-1:0] ebits;
    wire [N-1:0]  y;
    wire busy, done;
    integer pass = 0, fail = 0, i, t0, lat, lat_ref = -1, lat_bad = 0;
    reg [N-1:0] rm, rx;

    modexp #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .start(start), .x(x), .e(e), .ebits(ebits),
                         .m(m), .y(y), .busy(busy), .done(done));
    always #5 clk = ~clk;

    function [N-1:0] golden;               // square-and-multiply hanh vi, 2N bit
        input [N-1:0] b; input [EW-1:0] ex; input [N-1:0] mod; input integer nb;
        reg [2*N-1:0] acc, bb; integer k;
        begin
            acc = 1 % mod; bb = b % mod;
            for (k = nb - 1; k >= 0; k = k - 1) begin
                acc = (acc * acc) % mod;
                if (ex[k]) acc = (acc * bb) % mod;
            end
            golden = acc;
        end
    endfunction

    task run(input [N-1:0] xx, input [EW-1:0] ee, input integer nb, input [N-1:0] mm, input check_lat);
        begin
            @(posedge clk); x <= xx; e <= ee; ebits <= nb; m <= mm; start <= 1;
            @(posedge clk); start <= 0; t0 = $time;
            @(posedge done); lat = ($time - t0) / 10; #1;
            if (check_lat) begin
                if (lat_ref < 0) lat_ref = lat;
                if (lat != lat_ref) lat_bad = lat_bad + 1;
            end
            if (y === golden(xx, ee, mm, nb)) pass = pass + 1;
            else begin fail = fail + 1; $display("[FAIL] %0d^%0d mod %0d = %0d", xx, ee, mm, y); end
        end
    endtask

    initial begin
        #25 rst_n = 1;
        run(3, 200, 8, 1009, 0);
        $display("KAT: 3^200 mod 1009 = %0d (mong doi 985)", y);
        run(2, 0, 0, 1009, 0); run(0, 5, 3, 1009, 0); run(1008, 2, 2, 1009, 0);
        for (i = 0; i < 300; i = i + 1) begin                 // mu day du EW bit
            rm = $random | 1 | (1 << (N-1)); rx = $random % rm;
            run(rx, {$random, $random}, EW, rm, 1);
        end
        $display("modexp N=%0d: PASS %0d / FAIL %0d | latency (ebits=%0d) = %0d chu ky, lech latency = %0d",
                 N, pass, fail, EW, lat_ref, lat_bad);
        $finish;
    end
endmodule
