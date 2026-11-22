`timescale 1ns/1ps
// tb_prime_gen.v - prime_gen noi voi gcd_ct, modexp va trng_top that
//   Sinh NP so nguyen to, kiem bang chia thu, thong ke so ung vien va so chu ky.
module tb_prime_gen;
    parameter N  = 32;
    parameter NP = 30;
    localparam K = N / 2, EW = 2 * N;
    reg clk = 0, rst_n = 0, start = 0;
    always #5 clk = ~clk;

    wire [31:0] rw; wire rv, rok, ralarm, rtake, rdbg, rvdbg; wire [2:0] rsrc;
    trng_top #(.SAMPLE_DIV(4)) u_trng (.clk(clk), .rst_n(rst_n), .take(rtake), .word(rw),
        .word_valid(rv), .rng_ok(rok), .noise_alarm(ralarm), .alarm_src(rsrc),
        .raw_bit_dbg(rdbg), .raw_valid_dbg(rvdbg));

    wire gs, gd, gb; wire [N-1:0] ga, gbb, gg;
    gcd_ct #(.N(N)) u_gcd (.clk(clk), .rst_n(rst_n), .start(gs), .a(ga), .b(gbb), .g(gg), .busy(gb), .done(gd));

    wire ms, md, mb; wire [N-1:0] mxv, mm, my; wire [EW-1:0] me; wire [$clog2(EW+1)-1:0] meb;
    modexp #(.N(N), .EW(EW)) u_mx (.clk(clk), .rst_n(rst_n), .start(ms), .x(mxv), .e(me), .ebits(meb),
        .m(mm), .y(my), .busy(mb), .done(md));

    wire [K-1:0] prime; wire [7:0] tries; wire pbusy, pdone, pfail;
    prime_gen #(.N(N), .EW(EW)) dut (.clk(clk), .rst_n(rst_n), .start(start), .avoid({K{1'b0}}),
        .rnd_word(rw), .rnd_valid(rv), .rnd_take(rtake),
        .gcd_start(gs), .gcd_a(ga), .gcd_b(gbb), .gcd_done(gd), .gcd_g(gg),
        .mx_start(ms), .mx_x(mxv), .mx_e(me), .mx_ebits(meb), .mx_m(mm), .mx_done(md), .mx_y(my),
        .prime(prime), .tries(tries), .busy(pbusy), .done(pdone), .fail(pfail));

    // dem so lan bi loai o tung tang
    integer sieved = 0, mr_rej = 0;
    always @(posedge clk) begin
        if (dut.state == 4'd2 && gd && gg != 1) sieved = sieved + 1;
        if (dut.state == 4'd6 && !dut.probable)  mr_rej = mr_rej + 1;
    end

    function is_prime(input [K-1:0] v);
        integer f;
        begin
            is_prime = (v >= 2);
            for (f = 2; f * f <= v; f = f + 1) if (v % f == 0) is_prime = 0;
        end
    endfunction

    integer i, pass = 0, fail = 0, tot_tries = 0, t0, cyc, tot_cyc = 0;
    initial begin
        #25 rst_n = 1;
        wait (rok);
        for (i = 0; i < NP; i = i + 1) begin
            @(posedge clk); start <= 1; @(posedge clk); start <= 0; t0 = $time;
            @(posedge pdone); #1; cyc = ($time - t0) / 10;
            tot_tries = tot_tries + tries; tot_cyc = tot_cyc + cyc;
            if (!pfail && is_prime(prime) && prime[K-1:K-2] == 2'b11) pass = pass + 1;
            else begin fail = fail + 1; $display("[FAIL] %0d", prime); end
            if (i < 5) $display("  p = %0d  (ung vien %0d, %0d chu ky)", prime, tries, cyc);
        end
        $display("prime_gen N=%0d: PASS %0d / FAIL %0d | TB %0d.%02d ung vien/so, %0d chu ky/so",
                 N, pass, fail, tot_tries / NP, (tot_tries * 100 / NP) % 100, tot_cyc / NP);
        $display("  bi sang loai: %0d, bi Miller-Rabin loai: %0d (tren %0d ung vien)", sieved, mr_rej, tot_tries);
        $finish;
    end
endmodule
