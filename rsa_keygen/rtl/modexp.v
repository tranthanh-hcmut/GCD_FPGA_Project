`timescale 1ns/1ps
// ============================================================================
// modexp.v - Luy thua modulo y = x^e mod m dung montmul
//   Square-and-multiply-ALWAYS: moi bit deu binh phuong ROI nhan, chi chon
//   ket qua theo bit mu => chuoi phep toan khong phu thuoc mu
//   (Ch.13 §13.3.2, bai tap 2c; Ch.17 §17.1).
//   ebits = so bit mu duoc xu ly (gia tri CONG KHAI, vd luon 2N cho d).
//   Latency = 2L + (3 + 2*ebits)*L + so chu ky bat tay, chi phu thuoc ebits.
//   Dieu kien: m le, x < m.
// ============================================================================
module modexp #(
    parameter N  = 32,
    parameter EW = 2*N                    // do rong thanh ghi mu
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     start,
    input  wire [N-1:0]             x,
    input  wire [EW-1:0]            e,
    input  wire [$clog2(EW+1)-1:0]  ebits,
    input  wire [N-1:0]             m,
    output reg  [N-1:0]             y,
    output wire                     busy,
    output reg                      done
);
    localparam L  = N + 2;
    localparam IW = $clog2(EW+1);
    localparam S_IDLE = 3'd0, S_R2 = 3'd1, S_XM = 3'd2, S_ONE = 3'd3,
               S_SQ = 3'd4, S_MUL = 3'd5, S_FIN = 3'd6, S_SUB = 3'd7;

    reg [2:0]     state;
    reg           issued;
    reg [N-1:0]   rx, rm;
    reg [EW-1:0]  re;
    reg [IW-1:0]  bidx;                   // so bit con lai
    reg [N:0]     r2, xm, acc;
    reg [$clog2(2*L)-1:0] cnt;

    reg           mm_start;
    reg  [N:0]    mm_a, mm_b;
    wire [N:0]    mm_t;
    wire          mm_busy, mm_done;
    montmul #(.N(N)) u_mm (.clk(clk), .rst_n(rst_n), .start(mm_start), .a(mm_a), .b(mm_b),
                           .m(rm), .t(mm_t), .busy(mm_busy), .done(mm_done));

    wire [N+1:0] dbl  = {r2, 1'b0};
    wire [N+1:0] dsub = dbl - {2'b00, rm};
    assign busy = (state != S_IDLE);

    // phat 1 lenh montmul: a*b; tra ve 1 khi ket qua da san sang o mm_t
    task call_mm(input [N:0] aa, input [N:0] bb);
        begin
            if (!issued) begin mm_a <= aa; mm_b <= bb; mm_start <= 1'b1; issued <= 1'b1; end
        end
    endtask

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; issued <= 0; done <= 0; y <= 0;
            rx <= 0; rm <= 0; re <= 0; bidx <= 0; r2 <= 0; xm <= 0; acc <= 0; cnt <= 0;
            mm_start <= 0; mm_a <= 0; mm_b <= 0;
        end else begin
            done <= 1'b0;
            mm_start <= 1'b0;
            case (state)
            S_IDLE: if (start) begin
                rx <= x; re <= e; rm <= m; bidx <= ebits;
                r2 <= 1; cnt <= 0; issued <= 1'b0;
                state <= S_R2;
            end
            S_R2: begin                               // r2 = 2^(2L) mod m
                r2  <= dsub[N+1] ? dbl[N:0] : dsub[N:0];
                cnt <= cnt + 1'b1;
                if (cnt == 2*L-1) state <= S_XM;
            end
            S_XM: begin                               // xm = x*R mod m
                call_mm({1'b0, rx}, r2);
                if (mm_done) begin xm <= mm_t; issued <= 1'b0; state <= S_ONE; end
            end
            S_ONE: begin                              // acc = 1*R mod m
                call_mm({{N{1'b0}}, 1'b1}, r2);
                if (mm_done) begin
                    acc <= mm_t; issued <= 1'b0;
                    state <= (bidx == 0) ? S_FIN : S_SQ;
                end
            end
            S_SQ: begin
                call_mm(acc, acc);
                if (mm_done) begin acc <= mm_t; issued <= 1'b0; state <= S_MUL; end
            end
            S_MUL: begin                              // luon nhan, chi chon theo bit
                call_mm(acc, xm);
                if (mm_done) begin
                    if (re[bidx-1]) acc <= mm_t;
                    issued <= 1'b0;
                    bidx   <= bidx - 1'b1;
                    state  <= (bidx == 1) ? S_FIN : S_SQ;
                end
            end
            S_FIN: begin                              // ra khoi mien Montgomery
                call_mm(acc, {{N{1'b0}}, 1'b1});
                if (mm_done) begin acc <= mm_t; issued <= 1'b0; state <= S_SUB; end
            end
            S_SUB: begin                              // dau ra <= m: tru 1 lan (luon tinh)
                y     <= (acc >= {1'b0, rm}) ? (acc - {1'b0, rm}) : acc[N-1:0];
                done  <= 1'b1;
                state <= S_IDLE;
            end
            endcase
        end
    end
endmodule
