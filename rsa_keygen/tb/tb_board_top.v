`timescale 1ns/1ps
// tb_board_top.v - mo phong board_top (khong co MMCM), giai ma UART va in ra man hinh
//   Nhan btn0 (sinh khoa) roi btn1 (demo), kiem dong chu in ra qua UART.
module tb_board_top;
    localparam CPB = 8;                       // rut ngan UART trong mo phong
    reg clk = 0;
    reg [3:0] btn = 0; reg [1:0] sw = 0;
    wire [3:0] led; wire r4, g4, b4, r5, g5, b5, txd;
    board_top #(.CLKS_PER_BIT(CPB), .DEB_STABLE(4), .SAMPLE_DIV(4)) dut (
        .clk(clk), .btn(btn), .sw(sw), .led(led), .led4_r(r4), .led4_g(g4), .led4_b(b4),
        .led5_r(r5), .led5_g(g5), .led5_b(b5), .uart_txd(txd));
    always #10 clk = ~clk;                    // 50 MHz (bo qua MMCM khi mo phong)

    // bo thu UART don gian: in tung ky tu
    integer k, nraw = 0, ones = 0; reg [7:0] b;
    always begin
        @(negedge txd);
        #(CPB * 20 * 1.5);
        for (k = 0; k < 8; k = k + 1) begin b[k] = txd; #(CPB * 20); end
        if (!dut.sws[0]) $write("%c", b);
        else begin nraw = nraw + 1; for (k = 0; k < 8; k = k + 1) ones = ones + b[k]; end
    end

    task press(input integer i);
        begin btn[i] = 1; repeat (20) @(posedge clk); btn[i] = 0; repeat (20) @(posedge clk); end
    endtask

    initial begin
        repeat (50) @(posedge clk);
        $display("--- nhan btn0: sinh khoa ---");
        press(0);
        wait (led[2] || led[3]);
        repeat (1000 * CPB) @(posedge clk);
        $display("--- nhan btn1: ma hoa roi giai ma 0BADF00D ---");
        press(1);
        wait (dut.bst == 3'd2); wait (dut.bst == 3'd0);
        repeat (50 * CPB) @(posedge clk);
        $display("LED = %b (err, key_valid, busy, rng_ok)", led);
        $display("--- bat sw0: che do do TRNG ---");
        sw[0] = 1; repeat (200000) @(posedge clk); sw[0] = 0;
        $display("Nhan %0d byte bit tho, ti le bit 1 = %0d/%0d", nraw, ones, nraw * 8);
        $finish;
    end
endmodule
