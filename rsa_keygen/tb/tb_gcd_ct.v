// tb_gcd_ct.v - kiem gcd_ct: dung ket qua VA latency bang nhau moi vector
`timescale 1ns/1ps
module tb_gcd_ct;
    parameter N = 32;
    reg clk = 0, rst_n = 0, start = 0;
    reg  [N-1:0] a, b;
    wire [N-1:0] g;
    wire busy, done;
    integer pass = 0, fail = 0, i, t0, lat, lat_ref = -1, lat_bad = 0;

    gcd_ct #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .start(start), .a(a), .b(b),
                         .g(g), .busy(busy), .done(done));
    always #5 clk = ~clk;

    function [N-1:0] golden;               // Euclid hanh vi
        input [N-1:0] x, y;
        reg [N-1:0] t;
        begin
            while (y != 0) begin t = x % y; x = y; y = t; end
            golden = x;
        end
    endfunction

    task run(input [N-1:0] x, input [N-1:0] y);
        begin
            @(posedge clk); a <= x; b <= y; start <= 1;
            @(posedge clk); start <= 0; t0 = $time;
            @(posedge done); lat = ($time - t0) / 10;
            if (lat_ref < 0) lat_ref = lat;
            if (lat != lat_ref) lat_bad = lat_bad + 1;
            #1;
            if (g === golden(x, y)) pass = pass + 1;
            else begin
                fail = fail + 1;
                $display("[FAIL] gcd(%0d,%0d) = %0d, mong doi %0d", x, y, g, golden(x, y));
            end
        end
    endtask

    initial begin
        #25 rst_n = 1;
        run(48, 48); run(0, 25); run(36, 0); run(0, 0); run(17, 13); run(1, 200);
        run({N{1'b1}}, {N{1'b1}}); run({N{1'b1}}, 1);
        run(1836311903 % (1 << (N-1)), 1134903170 % (1 << (N-1)));
        run(128, 64); run(17, 3120); run(111546435 % (1 << (N-1)), 49157);
        for (i = 0; i < 2000; i = i + 1) run($random, $random);
        $display("gcd_ct N=%0d: PASS %0d / FAIL %0d | latency = %0d chu ky, so vector lech latency = %0d",
                 N, pass, fail, lat_ref, lat_bad);
        $finish;
    end
endmodule
