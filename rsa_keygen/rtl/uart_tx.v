`timescale 1ns/1ps
// uart_tx.v - UART 8N1, chi phat. CLKS_PER_BIT = f_clk / baud (50 MHz / 115200 = 434)
module uart_tx #(
    parameter CLKS_PER_BIT = 434
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       send,        // xung: phat 'data'
    input  wire [7:0] data,
    output reg        tx,
    output wire       ready        // 1 = ranh, nhan byte moi
);
    localparam CW = $clog2(CLKS_PER_BIT);
    reg [9:0]    sh;               // {stop, data[7:0], start}
    reg [3:0]    nbit;
    reg [CW-1:0] cnt;
    reg          active;
    assign ready = !active;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1'b1; sh <= 10'h3FF; nbit <= 0; cnt <= 0; active <= 0;
        end else if (!active) begin
            tx <= 1'b1;
            if (send) begin sh <= {1'b1, data, 1'b0}; nbit <= 0; cnt <= 0; active <= 1'b1; end
        end else begin
            tx <= sh[0];
            if (cnt == CLKS_PER_BIT-1) begin
                cnt <= 0; sh <= {1'b1, sh[9:1]}; nbit <= nbit + 1'b1;
                if (nbit == 9) active <= 1'b0;
            end else cnt <= cnt + 1'b1;
        end
    end
endmodule
