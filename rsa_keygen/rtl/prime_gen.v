`timescale 1ns/1ps
// ============================================================================
// prime_gen.v - Sinh so nguyen to K = N/2 bit (buoc quy trinh 2 va 3)
//   DRAW : lay tu TRNG, ep 2 bit cao = 11 va bit thap = 1  => n = p*q du N bit
//   SIEVE: gcd(c, 3*5*...*23) = 1 ?  (dung lai loi gcd_ct)
//   MR   : Miller-Rabin co so {2, 3}; voi c < 2^16 la ket luan CHINH XAC.
//          So lan binh phuong LUON la K-1 (khong phu thuoc s cua c-1).
//   Loi gcd_ct va modexp nam o NGOAI (dung chung voi rsa_keygen) - module nay
//   chi phat lenh qua cac cong gcd_* va mx_*.
// ============================================================================
module prime_gen #(
    parameter N         = 32,
    parameter EW        = 2*N,
    parameter MAX_TRIES = 255
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    start,
    input  wire [N/2-1:0]          avoid,       // q phai khac p (0 = khong tranh)
    // TRNG
    input  wire [31:0]             rnd_word,
    input  wire                    rnd_valid,
    output reg                     rnd_take,
    // loi gcd_ct dung chung
    output reg                     gcd_start,
    output reg  [N-1:0]            gcd_a,
    output reg  [N-1:0]            gcd_b,
    input  wire                    gcd_done,
    input  wire [N-1:0]            gcd_g,
    // loi modexp dung chung
    output reg                     mx_start,
    output reg  [N-1:0]            mx_x,
    output reg  [EW-1:0]           mx_e,
    output reg  [$clog2(EW+1)-1:0] mx_ebits,
    output reg  [N-1:0]            mx_m,
    input  wire                    mx_done,
    input  wire [N-1:0]            mx_y,
    // ket qua
    output reg  [N/2-1:0]          prime,
    output reg  [7:0]              tries,       // so ung vien da rut (de thong ke)
    output wire                    busy,
    output reg                     done,
    output reg                     fail
);
    localparam K = N / 2;
    localparam [N-1:0] SMALLPROD = (N >= 32) ? 32'd111546435   // 3*5*7*11*13*17*19*23
                                             : 32'd15015;      // 3*5*7*11*13
    localparam S_IDLE = 4'd0, S_DRAW = 4'd1, S_SIEVE = 4'd2, S_PREP = 4'd3,
               S_POW = 4'd4, S_SQ = 4'd5, S_DEC = 4'd6, S_OUT = 4'd7;

    reg [3:0]           state;
    reg                 issued, base_idx, probable;
    reg [K-1:0]         c, md;                 // ung vien, md = (c-1)/2^s
    reg [$clog2(K+1)-1:0] s, i;
    reg [N-1:0]         xr;
    wire [K-1:0]        cm1 = c - 1'b1;
    assign busy = (state != S_IDLE);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; issued <= 0; base_idx <= 0; probable <= 0;
            c <= 0; md <= 0; s <= 0; i <= 0; xr <= 0; prime <= 0; tries <= 0;
            done <= 0; fail <= 0; rnd_take <= 0;
            gcd_start <= 0; gcd_a <= 0; gcd_b <= 0;
            mx_start <= 0; mx_x <= 0; mx_e <= 0; mx_ebits <= 0; mx_m <= 0;
        end else begin
            done <= 0; rnd_take <= 0; gcd_start <= 0; mx_start <= 0;
            case (state)
            S_IDLE: if (start) begin tries <= 0; fail <= 0; state <= S_DRAW; end

            S_DRAW: if (tries == MAX_TRIES) begin
                        fail <= 1'b1; done <= 1'b1; state <= S_IDLE;
                    end else if (rnd_valid && !rnd_take) begin
                        c <= {2'b11, rnd_word[K-3:1], 1'b1};
                        rnd_take <= 1'b1;
                        tries <= tries + 1'b1;
                        issued <= 1'b0;
                        state <= S_SIEVE;
                    end

            S_SIEVE: begin                                  // tang 1: sang
                if (!issued) begin
                    gcd_a <= {{(N-K){1'b0}}, c}; gcd_b <= SMALLPROD;
                    gcd_start <= 1'b1; issued <= 1'b1;
                end else if (gcd_done) begin
                    issued <= 1'b0;
                    if (gcd_g == 1) begin
                        md <= cm1; s <= 0; i <= 0; base_idx <= 0;
                        state <= S_PREP;
                    end else state <= S_DRAW;
                end
            end

            S_PREP: begin                                   // c-1 = md*2^s, co dinh K chu ky
                if (!md[0]) begin md <= md >> 1; s <= s + 1'b1; end
                i <= i + 1'b1;
                if (i == K-1) state <= S_POW;
            end

            S_POW: begin                                    // x = a^md mod c
                if (!issued) begin
                    mx_x <= base_idx ? 3 : 2; mx_e <= {{(EW-K){1'b0}}, md};
                    mx_ebits <= K; mx_m <= {{(N-K){1'b0}}, c};
                    mx_start <= 1'b1; issued <= 1'b1;
                end else if (mx_done) begin
                    issued <= 1'b0; xr <= mx_y;
                    probable <= (mx_y == 1) || (mx_y == {{(N-K){1'b0}}, cm1});
                    i <= 1;
                    state <= S_SQ;
                end
            end

            S_SQ: begin                                     // luon K-1 lan binh phuong
                if (!issued) begin
                    mx_x <= xr; mx_e <= 2; mx_ebits <= 2;
                    mx_start <= 1'b1; issued <= 1'b1;
                end else if (mx_done) begin
                    issued <= 1'b0; xr <= mx_y;
                    if (i < s && mx_y == {{(N-K){1'b0}}, cm1}) probable <= 1'b1;
                    i <= i + 1'b1;
                    if (i == K-1) state <= S_DEC;
                end
            end

            S_DEC: begin
                if (!probable) state <= S_DRAW;             // hop so
                else if (!base_idx) begin base_idx <= 1'b1; state <= S_POW; end
                else if (c == avoid) state <= S_DRAW;       // trung p
                else state <= S_OUT;
            end

            S_OUT: begin prime <= c; done <= 1'b1; state <= S_IDLE; end
            endcase
        end
    end
endmodule
