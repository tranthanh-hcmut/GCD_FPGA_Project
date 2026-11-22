`timescale 1ns/1ps
// ============================================================================
// montmul.v - Nhan Montgomery co so 2 (bit-serial), KHONG co phep tru cuoi
//   t = a*b*2^-L mod m (chua rut gon hoan toan), L = N+2.
//   Dieu kien: m le, a < 2m, b < 2m.  Vi 4m < 2^L nen dau ra t < 2m
//   => dua thang dau ra lam dau vao lan sau, KHONG can phep tru co dieu kien
//   (Ch.16 §16.9: them vong lap de bo han phep tru gay ro ri).
//   Moi vong: T = (T + a_i*b + q*m) / 2, q = bit thap cua (T + a_i*b).
//   Latency co dinh L chu ky.
// ============================================================================
module montmul #(
    parameter N = 32
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [N:0]   a,          // < 2m
    input  wire [N:0]   b,          // < 2m
    input  wire [N-1:0] m,          // le
    output reg  [N:0]   t,          // < 2m
    output wire         busy,
    output reg          done
);
    localparam L  = N + 2;
    localparam CW = $clog2(L);
    reg          run;
    reg [L-1:0]  ra;                // bit cua a, dich ra tung bit
    reg [N:0]    rb;
    reg [N-1:0]  rm;
    reg [N+2:0]  T;                 // T < 3m  -> N+2 bit, tong < 6m -> N+3 bit
    reg [CW-1:0] cnt;
    wire [N+2:0] t1 = T  + (ra[0] ? {2'b00, rb} : {(N+3){1'b0}});
    wire [N+2:0] t2 = t1 + (t1[0] ? {3'b000, rm} : {(N+3){1'b0}});
    assign busy = run;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            run <= 0; done <= 0; t <= 0; ra <= 0; rb <= 0; rm <= 0; T <= 0; cnt <= 0;
        end else begin
            done <= 1'b0;
            if (!run) begin
                if (start) begin
                    ra <= {{(L-N-1){1'b0}}, a}; rb <= b; rm <= m; T <= 0; cnt <= 0; run <= 1'b1;
                end
            end else begin
                T   <= t2 >> 1;
                ra  <= ra >> 1;
                cnt <= cnt + 1'b1;
                if (cnt == L-1) begin
                    t    <= t2[N+1:1];      // = (t2 >> 1), < 2m nen vua N+1 bit
                    run  <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule
