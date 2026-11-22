`timescale 1ns/1ps
// ============================================================================
// mul_seq.v - Bo nhan tuan tu dich-cong (shift-and-add), N x N -> 2N bit
//   Dung N chu ky, khong phu thuoc du lieu. Khong dung DSP => duong gang ngan.
//   Dung o buoc quy trinh 4 (n = p*q, phi = (p-1)(q-1)) va 7 (e*d, r*k).
// ============================================================================
module mul_seq #(
    parameter N = 32
)(
    input  wire           clk,
    input  wire           rst_n,
    input  wire           start,
    input  wire [N-1:0]   a,
    input  wire [N-1:0]   b,
    output reg  [2*N-1:0] p,
    output wire           busy,
    output reg            done
);
    localparam CW = $clog2(N);
    reg           run;
    reg [2*N-1:0] mcand;
    reg [N-1:0]   mplier;
    reg [CW-1:0]  cnt;
    assign busy = run;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            run <= 0; done <= 0; p <= 0; mcand <= 0; mplier <= 0; cnt <= 0;
        end else begin
            done <= 1'b0;
            if (!run) begin
                if (start) begin
                    p <= 0; mcand <= {{N{1'b0}}, a}; mplier <= b; cnt <= 0; run <= 1'b1;
                end
            end else begin
                if (mplier[0]) p <= p + mcand;      // cong co dieu kien = 1 mux
                mcand  <= mcand << 1;
                mplier <= mplier >> 1;
                cnt    <= cnt + 1'b1;
                if (cnt == N-1) begin run <= 1'b0; done <= 1'b1; end
            end
        end
    end
endmodule
