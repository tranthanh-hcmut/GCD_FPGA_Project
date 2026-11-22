`timescale 1ns/1ps
// ============================================================================
// tb_rsa_keygen.v - Kiem toan quy trinh (DEBUG = 1 de doc p, q, phi, d)
//   A. Sinh NKEY khoa: kiem n = p*q, p/q nguyen to, e*d mod phi = 1,
//      bi mat da xoa ve 0, ma hoa -> giai ma tra lai dung M.
//   B. Loi co y 1: dao 1 bit cua d truoc buoc verify -> phai bi bat, sinh lai.
//   C. Loi co y 2: KAT sai (tham so KAT_INV_EXP = 2754) -> ERR, ma 1.
//   D. Loi co y 3: TRNG chet giua chung -> ERR, ma 2, moi bi mat bi xoa.
// ============================================================================
module tb_rsa_keygen;
    parameter N    = 32;
    parameter NKEY = 4;
    localparam K = N / 2;
    localparam S_VMUL = 5'd12;

    reg clk = 0, rst_n = 0, start = 0, op_go = 0, op_mode = 0;
    reg  [N-1:0] op_in;
    wire [N-1:0] op_out, n, e, p_dbg, q_dbg, phi_dbg, d_dbg;
    wire op_done, key_valid, busy, err, rng_ok, raw_dbg;
    wire [2:0] err_code;
    wire [7:0] cp, cq, et; wire [1:0] vf; wire [31:0] cyc;
    integer i, pass = 0, fail = 0;
    reg [2*N-1:0] t64;
    reg [N-1:0] m_save, c_save;

    rsa_keygen #(.N(N), .DEBUG(1), .SAMPLE_DIV(4)) dut (
        .clk(clk), .rst_n(rst_n), .start(start), .op_go(op_go), .op_mode(op_mode), .op_in(op_in),
        .op_out(op_out), .op_done(op_done), .n(n), .e(e), .key_valid(key_valid), .busy(busy),
        .err(err), .err_code(err_code), .rng_ok(rng_ok), .raw_bit_dbg(raw_dbg),
        .stat_cand_p(cp), .stat_cand_q(cq), .stat_e_tries(et), .stat_vfail(vf), .stat_cycles(cyc),
        .p_dbg(p_dbg), .q_dbg(q_dbg), .phi_dbg(phi_dbg), .d_dbg(d_dbg));

    // ban sao co KAT sai
    wire kv2, b2, er2, ok2, rd2, od2; wire [2:0] ec2; wire [N-1:0] o2, n2, e2, x1, x2, x3, x4;
    wire [7:0] y1, y2, y3; wire [1:0] y4; wire [31:0] y5;
    rsa_keygen #(.N(N), .DEBUG(1), .SAMPLE_DIV(4), .KAT_INV_EXP(2754)) dut_kat (
        .clk(clk), .rst_n(rst_n), .start(start), .op_go(1'b0), .op_mode(1'b0), .op_in({N{1'b0}}),
        .op_out(o2), .op_done(od2), .n(n2), .e(e2), .key_valid(kv2), .busy(b2), .err(er2),
        .err_code(ec2), .rng_ok(ok2), .raw_bit_dbg(rd2), .stat_cand_p(y1), .stat_cand_q(y2),
        .stat_e_tries(y3), .stat_vfail(y4), .stat_cycles(y5),
        .p_dbg(x1), .q_dbg(x2), .phi_dbg(x3), .d_dbg(x4));

    always #5 clk = ~clk;

    function is_prime(input [N-1:0] v);
        integer f;
        begin
            is_prime = (v >= 2);
            for (f = 2; f * f <= v; f = f + 1) if (v % f == 0) is_prime = 0;
        end
    endfunction

    task check(input cond, input [8*48-1:0] what);
        begin
            if (cond) pass = pass + 1;
            else begin fail = fail + 1; $display("  [FAIL] %0s", what); end
        end
    endtask

    task keygen_once(output [N-1:0] rp, output [N-1:0] rq, output [N-1:0] rphi, output [N-1:0] rd);
        begin
            @(posedge clk); start <= 1; @(posedge clk); start <= 0;
            // bat p, q, phi, d ngay truoc buoc 8 (sau do chung bi xoa)
            wait (dut.state == 5'd19);  // S_ZERO
            rp = p_dbg; rq = q_dbg; rphi = phi_dbg; rd = d_dbg;
            wait (key_valid || err);
            @(posedge clk); #1;
        end
    endtask

    reg [N-1:0] P, Q, PHI, D;
    initial begin
        #25 rst_n = 1;
        // ---------------- C: KAT sai (chay song song tren dut_kat) ----------------
        // ---------------- A: sinh khoa binh thuong ----------------
        $display("=== A. Sinh %0d khoa, N = %0d ===", NKEY, N);
        $display("  #  p      q      n           e       d           ung vien p/q  lan do e  chu ky");
        for (i = 0; i < NKEY; i = i + 1) begin
            keygen_once(P, Q, PHI, D);
            t64 = P * Q;             check(t64[N-1:0] == n && !err, "n = p*q");
            check(is_prime(P) && is_prime(Q) && P != Q, "p, q nguyen to, khac nhau");
            check(n[N-1] == 1'b1, "n du N bit");
            t64 = e * D;             check(t64 % PHI == 1, "e*d mod phi = 1");
            check(dut.p == 0 && dut.q == 0 && dut.phi == 0, "p, q, phi da xoa ve 0");
            $display("  %0d  %0d  %0d  %0d  %0d  %0d  %0d/%0d  %0d  %0d",
                     i + 1, P, Q, n, e, D, cp, cq, et, cyc);
            // demo: ma hoa roi giai ma (giai ma dung mu lam mu)
            op_in = 32'h0BADF00D % n; m_save = op_in;
            @(posedge clk); op_mode <= 0; op_go <= 1; @(posedge clk); op_go <= 0;
            @(posedge op_done); #1 c_save = op_out;
            @(posedge clk); op_in <= c_save; op_mode <= 1; op_go <= 1; @(posedge clk); op_go <= 0;
            @(posedge op_done); #1;
            check(op_out == m_save, "giai ma(ma hoa(M)) = M");
        end
        check(er2 && ec2 == 3'd1 && !kv2, "C: KAT sai -> ERR ma 1");
        $display("=== C. KAT sai: err = %0d, err_code = %0d (mong doi 1, 1) ===", er2, ec2);

        // ---------------- B: dao 1 bit cua d truoc verify ----------------
        $display("=== B. Tiem loi: dao bit 0 cua d o lan sinh dau ===");
        @(posedge clk); start <= 1; @(posedge clk); start <= 0;
        wait (dut.state == S_VMUL); #1 dut.d = dut.d ^ 1;
        wait (key_valid || err); @(posedge clk); #1;
        check(key_valid && !err && vf == 1, "B: verify bat loi, sinh lai thanh cong");
        $display("  verify that bai %0d lan, key_valid = %0d, err = %0d", vf, key_valid, err);

        // ---------------- D: TRNG chet giua chung ----------------
        $display("=== D. TRNG chet khi dang sinh khoa ===");
        @(posedge clk); start <= 1; @(posedge clk); start <= 0;
        wait (dut.state == 5'd5);             // dang sinh p
        dut.u_trng.u_ro.stuck = 1'b1;
        wait (err); @(posedge clk); #1;
        check(err_code == 3'd2 && !key_valid, "D: ERR ma 2");
        check(dut.p == 0 && dut.q == 0 && dut.d == 0 && dut.phi == 0 && n == 0, "D: bi mat da xoa");
        $display("  err = %0d, err_code = %0d, d = %0d, n = %0d", err, err_code, dut.d, n);

        $display("=== TONG KET: PASS %0d / FAIL %0d ===", pass, fail);
        $finish;
    end
    initial begin #2_000_000_000; $display("TIMEOUT"); $finish; end
endmodule
