`timescale 1ns/1ps
// ============================================================================
// modinv_ct.v - Nghich dao modulo bang Euclid mo rong NHI PHAN, thoi gian co dinh
//   Tinh inv = x^-1 mod y. Yeu cau: x LE, 0 < x < y  (x = e, y = phi(n) chan).
//   Bat bien:  A*x + B*y = u ,  C*x + D*y = v   (HAC thuat toan 14.61)
//   Moi chu ky 1 buoc kieu Stein  =>  <= 2N buoc; luon chay 2N chu ky
//   + 2 chu ky chuan hoa he so ve [0, y).
//   Chi dung cong/tru/dich: khong bo chia, khong bo nhan (Ch.6 §6.5).
//   He so co dau, |A|,|C| < 2y  =>  thanh ghi W = N+4 bit (du cho A-C+y).
// ============================================================================
module modinv_ct #(
    parameter N = 32
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [N-1:0] x,
    input  wire [N-1:0] y,
    output reg  [N-1:0] inv,
    output reg          ok,          // 1 neu gcd(x,y) = 1 (nghich dao ton tai)
    output wire         busy,
    output reg          done
);
    localparam W  = N + 4;
    localparam CW = $clog2(2*N);
    localparam S_IDLE = 2'd0, S_RUN = 2'd1, S_NORM1 = 2'd2, S_NORM2 = 2'd3;

    reg [1:0]           state;
    reg [N-1:0]         u, v, rx, ry;
    reg signed [W-1:0]  A, B, C, D, coef;
    reg [CW-1:0]        cnt;
    reg [N-1:0]         gres;

    wire signed [W-1:0] X = {{(W-N){1'b0}}, rx};
    wire signed [W-1:0] Y = {{(W-N){1'b0}}, ry};
    wire fin = (u == 0) || (v == 0) || (u == v);
    assign busy = (state != S_IDLE);

    // ---- to hop: mot buoc ------------------------------------------------
    reg [N-1:0]        nu, nv;
    reg signed [W-1:0] nA, nB, nC, nD, P, Q;
    always @* begin
        nu = u; nv = v; nA = A; nB = B; nC = C; nD = D;
        P = 0; Q = 0;
        if (!fin) begin
            if (!u[0]) begin                         // u chan
                nu = u >> 1;  P = A;     Q = B;
            end else if (!v[0]) begin                // v chan
                nv = v >> 1;  P = C;     Q = D;
            end else if (u > v) begin                // ca hai le, u > v
                nu = (u - v) >> 1;  P = A - C;  Q = B - D;
            end else begin                           // ca hai le, v >= u
                nv = (v - u) >> 1;  P = C - A;  Q = D - B;
            end
            // "halve": chia doi cap he so, giu dung bat bien
            if (!P[0] && !Q[0]) begin P = P >>> 1;       Q = Q >>> 1;       end
            else                begin P = (P + Y) >>> 1; Q = (Q - X) >>> 1; end
            if (!u[0] || (u[0] && v[0] && u > v)) begin nA = P; nB = Q; end
            else                                       begin nC = P; nD = Q; end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; done <= 1'b0; ok <= 1'b0; inv <= 0;
            u <= 0; v <= 0; rx <= 0; ry <= 0; cnt <= 0;
            A <= 0; B <= 0; C <= 0; D <= 0; coef <= 0; gres <= 0;
        end else begin
            done <= 1'b0;
            case (state)
            S_IDLE: if (start) begin
                rx <= x; ry <= y; u <= x; v <= y;
                A <= 1; B <= 0; C <= 0; D <= 1;
                cnt <= 0; state <= S_RUN;
            end
            S_RUN: begin
                u <= nu; v <= nv; A <= nA; B <= nB; C <= nC; D <= nD;
                cnt <= cnt + 1'b1;
                if (cnt == 2*N-1) begin                  // da xong chac chan
                    gres  <= (u == 0) ? v : u;
                    coef  <= (u == 0) ? C : A;
                    state <= S_NORM1;
                end
            end
            S_NORM1: begin                               // (-2y,2y) -> (-y,2y)
                if (coef < 0) coef <= coef + Y;
                state <= S_NORM2;
            end
            S_NORM2: begin                               // -> [0, y)
                if (coef < 0)       inv <= coef + Y;
                else if (coef >= Y) inv <= coef - Y;
                else                inv <= coef;
                ok    <= (gres == 1);
                done  <= 1'b1;
                state <= S_IDLE;
            end
            endcase
        end
    end
endmodule
