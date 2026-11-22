`timescale 1ns/1ps
// ============================================================================
// trng_ro.v - Nguon entropy: ring oscillator (RO) + lay mau  (Ch.4 §4.4.7, §4.4.9)
//   Khi TONG HOP (Vivado dinh nghia macro SYNTHESIS): NRO vong, moi vong LEN
//   cong NOT (LUT1, LEN le), XOR cac vong, dong bo qua 2 FF roi lay mau.
//   Khi MO PHONG: RO khong dao dong duoc trong mo phong hanh vi, nen thay bang
//   LFSR 32 bit co cung cong. Testbench dat 'stuck = 1' de gia lap nguon chet.
// ============================================================================
module trng_ro #(
    parameter NRO  = 4,
    parameter LEN  = 5,
    parameter SEED = 32'h1234_5678
)(
    input  wire clk,
    input  wire rst_n,
    input  wire sample_en,        // xung lay mau
    output reg  raw_bit,          // "das bit" (bit tho, chua hau xu ly)
    output reg  raw_valid
);
`ifdef SYNTHESIS
    wire [NRO-1:0] ro;
    genvar i, j;
    generate
        for (i = 0; i < NRO; i = i + 1) begin : g_ring
            (* DONT_TOUCH = "TRUE", ALLOW_COMBINATORIAL_LOOPS = "TRUE" *)
            wire [LEN-1:0] chain;
            for (j = 0; j < LEN; j = j + 1) begin : g_inv
                (* DONT_TOUCH = "TRUE" *)
                LUT1 #(.INIT(2'b01)) u_inv (       // O = ~I0
                    .O (chain[j]),
                    .I0(chain[(j == 0) ? LEN-1 : j-1])
                );
            end
            assign ro[i] = chain[LEN-1];
        end
    endgenerate
    (* ASYNC_REG = "TRUE" *) reg s1, s2;           // chong metastability
    always @(posedge clk) begin s1 <= ^ro; s2 <= s1; end
    wire src = s2;
`else
    reg [31:0] lfsr;
    reg        stuck = 1'b0;                        // tb: dut...u_ro.stuck = 1
    always @(posedge clk or negedge rst_n)
        if (!rst_n) lfsr <= SEED;
        else        lfsr <= (lfsr >> 1) ^ (lfsr[0] ? 32'h8020_0003 : 32'h0);
    wire src = stuck ? 1'b0 : lfsr[0];
`endif
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin raw_bit <= 1'b0; raw_valid <= 1'b0; end
        else begin
            raw_valid <= sample_en;
            if (sample_en) raw_bit <= src;
        end
    end
endmodule
