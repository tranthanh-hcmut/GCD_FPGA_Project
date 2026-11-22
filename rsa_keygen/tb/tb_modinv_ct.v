`timescale 1ns/1ps
// tb_modinv_ct.v - kiem x * inv mod y == 1, co bao loi khi gcd != 1, latency co dinh
module tb_modinv_ct;
    parameter N = 32;
    reg clk = 0, rst_n = 0, start = 0;
    reg  [N-1:0] x, y;
    wire [N-1:0] inv;
    wire ok, busy, done;
    integer pass = 0, fail = 0, i, t0, lat, lat_ref = -1, lat_bad = 0;
    reg [2*N-1:0] prod;
    reg [N-1:0] rx, ry, gg, t1, t2, tt;

    modinv_ct #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .start(start), .x(x), .y(y),
                            .inv(inv), .ok(ok), .busy(busy), .done(done));
    always #5 clk = ~clk;

    task run(input [N-1:0] xx, input [N-1:0] yy);
        begin
            @(posedge clk); x <= xx; y <= yy; start <= 1;
            @(posedge clk); start <= 0; t0 = $time;
            @(posedge done); lat = ($time - t0) / 10; #1;
            if (lat_ref < 0) lat_ref = lat;
            if (lat != lat_ref) lat_bad = lat_bad + 1;
            // golden: gcd hanh vi + kiem x*inv mod y
            t1 = xx; t2 = yy;
            while (t2 != 0) begin tt = t1 % t2; t1 = t2; t2 = tt; end
            prod = xx * inv;
            if ((t1 == 1) ? (ok && (prod % yy) == 1 && inv < yy) : !ok) pass = pass + 1;
            else begin
                fail = fail + 1;
                $display("[FAIL] x=%0d y=%0d inv=%0d ok=%0d (gcd=%0d)", xx, yy, inv, ok, t1);
            end
        end
    endtask

    initial begin
        #25 rst_n = 1;
        run(17, 3120);                   // KAT: 2753
        $display("KAT: 17^-1 mod 3120 = %0d (mong doi 2753)", inv);
        run(7, 60000); run(3, 9);  run(1, 2); run(65537, 3875240952 % (1 << N));
        for (i = 0; i < 3000; i = i + 1) begin
            ry = ($random & {N{1'b1}}) | (1 << (N-1)); ry[0] = 1'b0;   // y chan nhu phi
            rx = (($random & {N{1'b1}}) % ry) | 1;
            if (rx < ry) run(rx, ry);
        end
        $display("modinv_ct N=%0d: PASS %0d / FAIL %0d | latency = %0d chu ky, lech latency = %0d",
                 N, pass, fail, lat_ref, lat_bad);
        $finish;
    end
endmodule
