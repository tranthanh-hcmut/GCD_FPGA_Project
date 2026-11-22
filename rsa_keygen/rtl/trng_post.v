`timescale 1ns/1ps
// ============================================================================
// trng_post.v - Hau xu ly von Neumann + ghep thanh tu WW bit
//   (Ch.3 Vi du 3.8b, Ch.4 §4.5): lay cap bit tho (b1,b2): 00/11 bo, 01->0, 10->1.
//   Bit ra khong lech neu bit tho doc lap; toc do <= 1/4 toc do bit tho.
//   word_valid = 1 khi du WW bit moi; nguoi dung xung 'take' de lay va xoa.
// ============================================================================
module trng_post #(
    parameter WW = 32
)(
    input  wire          clk,
    input  wire          rst_n,
    input  wire          raw_valid,
    input  wire          raw_bit,
    input  wire          take,
    output reg  [WW-1:0] word,
    output wire          word_valid
);
    localparam CW = $clog2(WW+1);
    reg          have, first;
    reg [CW-1:0] cnt;
    assign word_valid = (cnt == WW);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            have <= 0; first <= 0; cnt <= 0; word <= 0;
        end else begin
            if (raw_valid) begin
                if (!have) begin
                    first <= raw_bit; have <= 1'b1;
                end else begin
                    have <= 1'b0;
                    if (first != raw_bit && cnt != WW && !take) begin
                        word <= {word[WW-2:0], first};
                        cnt  <= cnt + 1'b1;
                    end
                end
            end
            if (take) cnt <= 0;              // tu cu bi tieu thu, gom lai tu dau
        end
    end
endmodule
