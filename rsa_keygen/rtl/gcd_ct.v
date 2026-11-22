`timescale 1ns/1ps
// ============================================================================
// gcd_ct.v - Binary GCD (Stein) THOI GIAN CO DINH
//   Moi chu ky lam dung 1 buoc Stein (dich, hoac tru roi dich).
//   Moi buoc giam bitlen(a)+bitlen(b) it nhat 1  =>  toi da 2N buoc.
//   Module LUON chay du 2N chu ky; xong som thi giu nguyen thanh ghi.
//   => latency khong phu thuoc du lieu (Ch.13 §13.2, §13.5).
// Giao tiep: start = xung 1 chu ky; done = xung 1 chu ky; g giu tu luc done.
// ============================================================================
module gcd_ct #(
    parameter N = 32
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output reg  [N-1:0] g,
    output wire         busy,
    output reg          done
);
    localparam S_IDLE = 1'b0, S_RUN = 1'b1;
    localparam CW = $clog2(2*N);          // dem 0 .. 2N-1
    localparam KW = $clog2(N+1);

    reg          state;
    reg [N-1:0]  ra, rb;
    reg [KW-1:0] k;                        // so lan ca hai cung chan
    reg [CW-1:0] cnt;

    wire fin = (ra == {N{1'b0}}) || (rb == {N{1'b0}}) || (ra == rb);
    assign busy = (state == S_RUN);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            ra <= 0; rb <= 0; k <= 0; cnt <= 0;
            g <= 0; done <= 1'b0;
        end else begin
            done <= 1'b0;
            case (state)
            S_IDLE: if (start) begin
                ra <= a; rb <= b; k <= 0; cnt <= 0;
                state <= S_RUN;
            end
            S_RUN: begin
                if (!fin) begin
                    case ({ra[0], rb[0]})
                    2'b00: begin ra <= ra >> 1; rb <= rb >> 1; k <= k + 1'b1; end
                    2'b01: ra <= ra >> 1;                       // ra chan
                    2'b10: rb <= rb >> 1;                       // rb chan
                    2'b11: if (ra > rb) ra <= (ra - rb) >> 1;   // ca hai le
                           else         rb <= (rb - ra) >> 1;
                    endcase
                end
                // chu ky thu 2N: ket qua chac chan da xong (fin = 1)
                if (cnt == 2*N-1) begin
                    g     <= ((ra == {N{1'b0}}) ? rb : ra) << k;
                    done  <= 1'b1;
                    state <= S_IDLE;
                end
                cnt <= cnt + 1'b1;
            end
            endcase
        end
    end
endmodule
