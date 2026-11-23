`timescale 1ns/1ps
// tb_mul_div.v - kiem mul_seq va divmod_seq so voi toan tu * / % hanh vi
module tb_mul_div;
    parameter N = 32;
    reg clk = 0, rst_n = 0, ms = 0, ds = 0;
    reg  [N-1:0]   a, b, den;
    reg  [2*N-1:0] num;
    wire [2*N-1:0] p, q;
    wire [N-1:0]   r;
    wire mb, md, db, dd;
    integer pass = 0, fail = 0, i, t0, lm = -1, ld = -1;

    mul_seq    #(.N(N)) um (.clk(clk), .rst_n(rst_n), .start(ms), .a(a), .b(b), .p(p), .busy(mb), .done(md));
    divmod_seq #(.N(N)) ud (.clk(clk), .rst_n(rst_n), .start(ds), .num(num), .den(den),
                            .q(q), .r(r), .busy(db), .done(dd));
    always #5 clk = ~clk;

    task tmul(input [N-1:0] x, input [N-1:0] y);
        begin
            @(posedge clk); a <= x; b <= y; ms <= 1; @(posedge clk); ms <= 0; t0 = $time;
            @(posedge md); lm = ($time - t0) / 10; #1;
            if (p === x * y) pass = pass + 1;
            else begin fail = fail + 1; $display("[FAIL] %0d*%0d=%0d", x, y, p); end
        end
    endtask
    task tdiv(input [2*N-1:0] x, input [N-1:0] y);
        begin
            @(posedge clk); num <= x; den <= y; ds <= 1; @(posedge clk); ds <= 0; t0 = $time;
            @(posedge dd); ld = ($time - t0) / 10; #1;
            if (q === x / y && r === x % y) pass = pass + 1;
            else begin fail = fail + 1; $display("[FAIL] %0d/%0d: q=%0d r=%0d", x, y, q, r); end
        end
    endtask

    initial begin
        #25 rst_n = 1;
        tmul(0, 5); tmul({N{1'b1}}, {N{1'b1}}); tmul(60127, 64453);
        tdiv(65537 * 2989997009, 32'd3875240952); tdiv(5, 7); tdiv({2*N{1'b1}}, 1);
        for (i = 0; i < 1000; i = i + 1) begin
            tmul($random, $random);
            tdiv({$random, $random}, $random | 1);
        end
        $display("mul_seq/divmod_seq N=%0d: PASS %0d / FAIL %0d | latency nhan = %0d, chia = %0d chu ky",
                 N, pass, fail, lm, ld);
        $finish;
    end
endmodule
