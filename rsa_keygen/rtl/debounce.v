`timescale 1ns/1ps
// debounce.v - dong bo + chong doi nut bam; 'rise' = xung 1 chu ky khi vua nhan
module debounce #(
    parameter STABLE = 500_000     // 10 ms o 50 MHz
)(
    input  wire clk,
    input  wire rst_n,
    input  wire btn,
    output reg  level,
    output reg  rise
);
    reg s1, s2;
    reg [$clog2(STABLE+1)-1:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin s1 <= 0; s2 <= 0; cnt <= 0; level <= 0; rise <= 0; end
        else begin
            s1 <= btn; s2 <= s1; rise <= 1'b0;
            if (s2 == level) cnt <= 0;
            else if (cnt == STABLE-1) begin
                cnt <= 0; level <= s2; rise <= s2;
            end else cnt <= cnt + 1'b1;
        end
    end
endmodule
