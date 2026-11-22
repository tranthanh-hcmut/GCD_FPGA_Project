`timescale 1ns/1ps
// ============================================================================
// rsa_keygen.v - Bo sinh khoa RSA theo QUY TRINH 9 buoc (buoc quy trinh 0..8)
//
//   0 KAT (gcd, modinv, modexp)        5 do e: gcd_ct(e, phi), e += 2
//   1 cho TRNG qua startup test         6 d = e^-1 mod phi (modinv_ct)
//   2-3 prime_gen cho p, roi q != p     7 verify: e*d mod phi = 1; M -> C -> M'
//   4 n = p*q, phi = (p-1)(q-1)           (giai ma voi mu lam mu d' = d + r*(e*d-1))
//                                       8 xoa p, q, phi; key_valid = 1
//
//   Bat ky luc nao noise_alarm = 1 -> ERR. Verify sai -> xoa, sinh lai (toi da 2 lan).
//   Sau DONE: op_go/op_mode de demo ma hoa (0: x^e) / giai ma (1: x^d', d' lam mu).
//   DEBUG = 1 chi dung khi mo phong: lo p, q, phi, d ra cong *_dbg.
// ============================================================================
module rsa_keygen #(
    parameter N           = 32,
    parameter DEBUG       = 0,
    parameter SAMPLE_DIV  = 64,
    parameter MAX_E_TRIES = 64,
    parameter [N-1:0] KAT_INV_EXP = 2753,       // 17^-1 mod 3120 (tb doi de gia lap loi)
    parameter TRNG_SEED   = 32'h1234_5678
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,                  // xung: sinh khoa moi
    // demo ma hoa / giai ma sau khi co khoa
    input  wire         op_go,
    input  wire         op_mode,                // 0 = ma hoa (e), 1 = giai ma (d lam mu)
    input  wire [N-1:0] op_in,                  // phai < n
    output reg  [N-1:0] op_out,
    output reg          op_done,
    // khoa cong khai va trang thai
    output reg  [N-1:0] n,
    output reg  [N-1:0] e,
    output reg          key_valid,
    output wire         busy,
    output reg          err,
    output reg  [2:0]   err_code,               // 1 KAT, 2 TRNG, 3 het ung vien, 4 het e, 5 verify
    output wire         rng_ok,
    output wire         raw_bit_dbg,
    output wire         raw_valid_dbg,
    // thong ke cho bao cao
    output reg  [7:0]   stat_cand_p,
    output reg  [7:0]   stat_cand_q,
    output reg  [7:0]   stat_e_tries,
    output reg  [1:0]   stat_vfail,
    output reg  [31:0]  stat_cycles,
    // CHI DE MO PHONG (DEBUG = 1)
    output wire [N-1:0] p_dbg, q_dbg, phi_dbg, d_dbg
);
    localparam K  = N / 2;
    localparam EW = 2 * N;
    localparam [EW-1:0] E_START = (N >= 32) ? 65537 : 3;

    localparam S_IDLE   = 5'd0,  S_KAT1  = 5'd1,  S_KAT2  = 5'd2,  S_KAT3  = 5'd3,
               S_RNG    = 5'd4,  S_GENP  = 5'd5,  S_GENQ  = 5'd6,  S_MULN  = 5'd7,
               S_MULPHI = 5'd8,  S_EINIT = 5'd9,  S_EGCD  = 5'd10, S_INV   = 5'd11,
               S_VMUL   = 5'd12, S_VMOD  = 5'd13, S_VDRAWM= 5'd14, S_VDRAWR= 5'd15,
               S_BLIND  = 5'd16, S_VENC  = 5'd17, S_VDEC  = 5'd18, S_ZERO  = 5'd19,
               S_DONE   = 5'd20, S_ERR   = 5'd21, S_OPDRAW= 5'd22, S_OPBL  = 5'd23,
               S_OPRUN  = 5'd24, S_WIPE  = 5'd25;

    reg [4:0]    state;
    reg          issued;
    reg [K-1:0]  p, q;
    reg [N-1:0]  phi, d, msg, cph;
    reg [EW-1:0] ed, kbl, dbl;                   // e*d, e*d-1, mu lam mu
    reg [7:0]    rbl;
    reg [3:0]    bcnt;
    reg [2:0]    pending_err;

    // ---------------- TRNG ----------------
    reg          rnd_take_c;
    wire         rnd_take_pg;
    wire [31:0]  rnd_word;
    wire         rnd_valid, noise_alarm;
    wire [2:0]   alarm_src;
    trng_top #(.SAMPLE_DIV(SAMPLE_DIV), .SEED(TRNG_SEED)) u_trng (
        .clk(clk), .rst_n(rst_n), .take(rnd_take_c | rnd_take_pg), .word(rnd_word),
        .word_valid(rnd_valid), .rng_ok(rng_ok), .noise_alarm(noise_alarm),
        .alarm_src(alarm_src), .raw_bit_dbg(raw_bit_dbg),
        .raw_valid_dbg(raw_valid_dbg));

    // ---------------- loi so hoc ----------------
    wire pg_owns = (state == S_GENP) || (state == S_GENQ);

    reg          gcd_start_c;  reg [N-1:0] gcd_a_c, gcd_b_c;
    wire         gcd_start_pg; wire [N-1:0] gcd_a_pg, gcd_b_pg;
    wire [N-1:0] gcd_g;        wire gcd_done, gcd_busy;
    gcd_ct #(.N(N)) u_gcd (.clk(clk), .rst_n(rst_n),
        .start(pg_owns ? gcd_start_pg : gcd_start_c),
        .a(pg_owns ? gcd_a_pg : gcd_a_c), .b(pg_owns ? gcd_b_pg : gcd_b_c),
        .g(gcd_g), .busy(gcd_busy), .done(gcd_done));

    reg          mx_start_c;   reg [N-1:0] mx_x_c, mx_m_c;  reg [EW-1:0] mx_e_c;
    reg  [$clog2(EW+1)-1:0] mx_eb_c;
    wire         mx_start_pg;  wire [N-1:0] mx_x_pg, mx_m_pg; wire [EW-1:0] mx_e_pg;
    wire [$clog2(EW+1)-1:0] mx_eb_pg;
    wire [N-1:0] mx_y;         wire mx_done, mx_busy;
    modexp #(.N(N), .EW(EW)) u_mx (.clk(clk), .rst_n(rst_n),
        .start(pg_owns ? mx_start_pg : mx_start_c),
        .x(pg_owns ? mx_x_pg : mx_x_c), .e(pg_owns ? mx_e_pg : mx_e_c),
        .ebits(pg_owns ? mx_eb_pg : mx_eb_c), .m(pg_owns ? mx_m_pg : mx_m_c),
        .y(mx_y), .busy(mx_busy), .done(mx_done));

    reg          inv_start;    reg [N-1:0] inv_x, inv_y;
    wire [N-1:0] inv_r;        wire inv_ok, inv_done, inv_busy;
    modinv_ct #(.N(N)) u_inv (.clk(clk), .rst_n(rst_n), .start(inv_start), .x(inv_x), .y(inv_y),
        .inv(inv_r), .ok(inv_ok), .busy(inv_busy), .done(inv_done));

    reg          mul_start;    reg [N-1:0] mul_a, mul_b;
    wire [EW-1:0] mul_p;       wire mul_done, mul_busy;
    mul_seq #(.N(N)) u_mul (.clk(clk), .rst_n(rst_n), .start(mul_start), .a(mul_a), .b(mul_b),
        .p(mul_p), .busy(mul_busy), .done(mul_done));

    reg          div_start;    reg [EW-1:0] div_num; reg [N-1:0] div_den;
    wire [EW-1:0] div_q;       wire [N-1:0] div_r; wire div_done, div_busy;
    divmod_seq #(.N(N)) u_div (.clk(clk), .rst_n(rst_n), .start(div_start), .num(div_num),
        .den(div_den), .q(div_q), .r(div_r), .busy(div_busy), .done(div_done));

    reg          pg_start;     reg [K-1:0] pg_avoid;
    wire [K-1:0] pg_prime;     wire [7:0] pg_tries; wire pg_done, pg_fail, pg_busy;
    prime_gen #(.N(N), .EW(EW)) u_pg (.clk(clk), .rst_n(rst_n), .start(pg_start), .avoid(pg_avoid),
        .rnd_word(rnd_word), .rnd_valid(rnd_valid), .rnd_take(rnd_take_pg),
        .gcd_start(gcd_start_pg), .gcd_a(gcd_a_pg), .gcd_b(gcd_b_pg), .gcd_done(gcd_done), .gcd_g(gcd_g),
        .mx_start(mx_start_pg), .mx_x(mx_x_pg), .mx_e(mx_e_pg), .mx_ebits(mx_eb_pg), .mx_m(mx_m_pg),
        .mx_done(mx_done), .mx_y(mx_y),
        .prime(pg_prime), .tries(pg_tries), .busy(pg_busy), .done(pg_done), .fail(pg_fail));

    assign busy    = !(state == S_IDLE || state == S_DONE || state == S_ERR);
    assign p_dbg   = DEBUG ? {{(N-K){1'b0}}, p} : {N{1'b0}};
    assign q_dbg   = DEBUG ? {{(N-K){1'b0}}, q} : {N{1'b0}};
    assign phi_dbg = DEBUG ? phi : {N{1'b0}};
    assign d_dbg   = DEBUG ? d   : {N{1'b0}};

    // ---------------- FSM dieu phoi ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; issued <= 0; pending_err <= 0;
            p <= 0; q <= 0; phi <= 0; d <= 0; msg <= 0; cph <= 0;
            ed <= 0; kbl <= 0; dbl <= 0; rbl <= 0; bcnt <= 0;
            n <= 0; e <= 0; key_valid <= 0; err <= 0; err_code <= 0;
            op_out <= 0; op_done <= 0;
            stat_cand_p <= 0; stat_cand_q <= 0; stat_e_tries <= 0; stat_vfail <= 0; stat_cycles <= 0;
            rnd_take_c <= 0; gcd_start_c <= 0; gcd_a_c <= 0; gcd_b_c <= 0;
            mx_start_c <= 0; mx_x_c <= 0; mx_e_c <= 0; mx_eb_c <= 0; mx_m_c <= 0;
            inv_start <= 0; inv_x <= 0; inv_y <= 0; mul_start <= 0; mul_a <= 0; mul_b <= 0;
            div_start <= 0; div_num <= 0; div_den <= 0; pg_start <= 0; pg_avoid <= 0;
        end else begin
            // xung mac dinh
            rnd_take_c <= 0; gcd_start_c <= 0; mx_start_c <= 0; inv_start <= 0;
            mul_start <= 0; div_start <= 0; pg_start <= 0; op_done <= 0;
            if (busy) stat_cycles <= stat_cycles + 1'b1;

            if (noise_alarm && state != S_ERR && state != S_WIPE) begin
                pending_err <= 3'd2; state <= S_WIPE;          // bao dong nhieu: dung ngay
            end else case (state)
            S_IDLE: if (start) begin
                key_valid <= 0; issued <= 0; stat_vfail <= 0; stat_cycles <= 0;
                state <= S_KAT1;
            end
            // ---- buoc 0: known-answer test ----
            S_KAT1: if (!issued) begin
                    gcd_a_c <= 17; gcd_b_c <= 3120; gcd_start_c <= 1; issued <= 1;
                end else if (gcd_done) begin
                    issued <= 0;
                    if (gcd_g == 1) state <= S_KAT2; else begin pending_err <= 1; state <= S_WIPE; end
                end
            S_KAT2: if (!issued) begin
                    inv_x <= 17; inv_y <= 3120; inv_start <= 1; issued <= 1;
                end else if (inv_done) begin
                    issued <= 0;
                    if (inv_ok && inv_r == KAT_INV_EXP) state <= S_KAT3;
                    else begin pending_err <= 1; state <= S_WIPE; end
                end
            S_KAT3: if (!issued) begin
                    mx_x_c <= 3; mx_e_c <= 200; mx_eb_c <= 8; mx_m_c <= 1009; mx_start_c <= 1; issued <= 1;
                end else if (mx_done) begin
                    issued <= 0;
                    if (mx_y == 985) state <= S_RNG; else begin pending_err <= 1; state <= S_WIPE; end
                end
            // ---- buoc 1: cho TRNG qua startup test ----
            S_RNG: if (rng_ok) state <= S_GENP;
            // ---- buoc 2-3: p roi q ----
            S_GENP: if (!issued) begin
                    pg_avoid <= 0; pg_start <= 1; issued <= 1;
                end else if (pg_done) begin
                    issued <= 0; stat_cand_p <= pg_tries;
                    if (pg_fail) begin pending_err <= 3; state <= S_WIPE; end
                    else begin p <= pg_prime; state <= S_GENQ; end
                end
            S_GENQ: if (!issued) begin
                    pg_avoid <= p; pg_start <= 1; issued <= 1;
                end else if (pg_done) begin
                    issued <= 0; stat_cand_q <= pg_tries;
                    if (pg_fail) begin pending_err <= 3; state <= S_WIPE; end
                    else begin q <= pg_prime; state <= S_MULN; end
                end
            // ---- buoc 4: n, phi ----
            S_MULN: if (!issued) begin
                    mul_a <= p; mul_b <= q; mul_start <= 1; issued <= 1;
                end else if (mul_done) begin
                    issued <= 0; n <= mul_p[N-1:0];
                    state <= S_MULPHI;
                end
            S_MULPHI: if (!issued) begin
                    mul_a <= p - 1'b1; mul_b <= q - 1'b1; mul_start <= 1; issued <= 1;
                end else if (mul_done) begin
                    issued <= 0; phi <= mul_p[N-1:0];
                    state <= S_EINIT;
                end
            // ---- buoc 5: do e ----
            S_EINIT: begin
                e <= E_START[N-1:0]; stat_e_tries <= 0; state <= S_EGCD;
            end
            S_EGCD: if (!issued) begin
                    if (stat_e_tries == MAX_E_TRIES || e >= phi) begin pending_err <= 4; state <= S_WIPE; end
                    else begin gcd_a_c <= e; gcd_b_c <= phi; gcd_start_c <= 1; issued <= 1;
                               stat_e_tries <= stat_e_tries + 1'b1; end
                end else if (gcd_done) begin
                    issued <= 0;
                    if (gcd_g == 1) state <= S_INV; else e <= e + 2;
                end
            // ---- buoc 6: d ----
            S_INV: if (!issued) begin
                    inv_x <= e; inv_y <= phi; inv_start <= 1; issued <= 1;
                end else if (inv_done) begin
                    issued <= 0; d <= inv_r;
                    if (inv_ok) state <= S_VMUL; else begin pending_err <= 5; state <= S_WIPE; end
                end
            // ---- buoc 7: kiem tra nhat quan ----
            S_VMUL: if (!issued) begin
                    mul_a <= e; mul_b <= d; mul_start <= 1; issued <= 1;
                end else if (mul_done) begin
                    issued <= 0; ed <= mul_p; state <= S_VMOD;
                end
            S_VMOD: if (!issued) begin
                    div_num <= ed; div_den <= phi; div_start <= 1; issued <= 1;
                end else if (div_done) begin
                    issued <= 0; kbl <= ed - 1'b1;
                    if (div_r == 1) state <= S_VDRAWM;
                    else state <= (stat_vfail == 1) ? S_WIPE : S_GENP;
                    if (div_r != 1) begin
                        stat_vfail <= stat_vfail + 1'b1;
                        if (stat_vfail == 1) pending_err <= 5;
                    end
                end
            S_VDRAWM: if (rnd_valid && !rnd_take_c) begin
                    msg <= {1'b0, rnd_word[N-2:0]};          // M < 2^(N-1) <= n
                    rnd_take_c <= 1; state <= S_VDRAWR;
                end
            S_VDRAWR: if (rnd_valid && !rnd_take_c) begin
                    rbl <= rnd_word[7:0]; rnd_take_c <= 1;
                    dbl <= {{N{1'b0}}, d}; bcnt <= 0; state <= S_BLIND;
                end
            S_BLIND: begin                                     // d' = d + r*(e*d-1), 8 chu ky
                if (rbl[bcnt[2:0]]) dbl <= dbl + (kbl << bcnt[2:0]);
                bcnt <= bcnt + 1'b1;
                if (bcnt == 7) state <= S_VENC;
            end
            S_VENC: if (!issued) begin
                    mx_x_c <= msg; mx_e_c <= {{N{1'b0}}, e}; mx_eb_c <= EW; mx_m_c <= n;
                    mx_start_c <= 1; issued <= 1;
                end else if (mx_done) begin
                    issued <= 0; cph <= mx_y; state <= S_VDEC;
                end
            S_VDEC: if (!issued) begin
                    mx_x_c <= cph; mx_e_c <= dbl; mx_eb_c <= EW; mx_m_c <= n;
                    mx_start_c <= 1; issued <= 1;
                end else if (mx_done) begin
                    issued <= 0;
                    if (mx_y == msg) state <= S_ZERO;
                    else begin
                        stat_vfail <= stat_vfail + 1'b1;
                        if (stat_vfail == 1) begin pending_err <= 5; state <= S_WIPE; end
                        else state <= S_GENP;
                    end
                end
            // ---- buoc 8: xoa bi mat, ban giao ----
            S_ZERO: begin
                p <= 0; q <= 0; phi <= 0; ed <= 0; dbl <= 0; msg <= 0; cph <= 0; rbl <= 0;
                key_valid <= 1; state <= S_DONE;
            end
            S_DONE: begin
                if (start) begin key_valid <= 0; issued <= 0; stat_vfail <= 0; stat_cycles <= 0; state <= S_KAT1; end
                else if (op_go) begin
                    msg <= op_in;
                    if (op_mode) state <= S_OPDRAW;            // giai ma: lam mu truoc
                    else begin dbl <= {{N{1'b0}}, e}; state <= S_OPRUN; end
                end
            end
            S_OPDRAW: if (rnd_valid && !rnd_take_c) begin
                    rbl <= rnd_word[7:0]; rnd_take_c <= 1;
                    dbl <= {{N{1'b0}}, d}; bcnt <= 0; state <= S_OPBL;
                end
            S_OPBL: begin
                if (rbl[bcnt[2:0]]) dbl <= dbl + (kbl << bcnt[2:0]);
                bcnt <= bcnt + 1'b1;
                if (bcnt == 7) state <= S_OPRUN;
            end
            S_OPRUN: if (!issued) begin
                    mx_x_c <= msg; mx_e_c <= dbl; mx_eb_c <= EW; mx_m_c <= n;
                    mx_start_c <= 1; issued <= 1;
                end else if (mx_done) begin
                    issued <= 0; op_out <= mx_y; op_done <= 1; dbl <= 0; msg <= 0;
                    state <= S_DONE;
                end
            // ---- loi: xoa moi bi mat, khoa lai cho reset ----
            S_WIPE: begin
                p <= 0; q <= 0; phi <= 0; d <= 0; ed <= 0; kbl <= 0; dbl <= 0;
                msg <= 0; cph <= 0; rbl <= 0; n <= 0; e <= 0; key_valid <= 0;
                err <= 1; err_code <= pending_err; state <= S_ERR;
            end
            S_ERR: ;                                           // chi thoat bang rst_n
            default: state <= S_ERR;
            endcase
        end
    end
endmodule
