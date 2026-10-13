`timescale 1ns / 1ps

module tb_gcd_binary;

    parameter N = 32;

    reg          clk;
    reg          rst_n;
    reg          start;
    reg  [N-1:0] a;
    reg  [N-1:0] b;
    wire [N-1:0] result;
    wire         done;

    // Khoi tao UUT
    gcd_binary #(.N(N)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(done)
    );

    // Tao xung clock 100 MHz (chu ky 10ns)
    always #5 clk = ~clk;

    // Task tu dong chay va dem Latency
    task run_test(
        input [N-1:0] test_a,
        input [N-1:0] test_b,
        input [N-1:0] expected_gcd,
        input [159:0] test_name
    );
        integer latency_count;
        begin
            @(posedge clk);
            a     = test_a;
            b     = test_b;
            start = 1'b1;
            latency_count = 0;

            @(posedge clk);
            start = 1'b0;

            // Cho co done len 1 va dem so chu ky
            while (!done) begin
                @(posedge clk);
                latency_count = latency_count + 1;
            end

            // Kiem tra ket qua
            if (result === expected_gcd) begin
                $display("[PASS] %-25s | A = %-5d | B = %-5d | GCD = %-5d | Latency = %0d cycles",
                         test_name, test_a, test_b, result, latency_count);
            end else begin
                $display("[FAIL] %-25s | A = %-5d | B = %-5d | Expected = %-5d | Got = %-5d",
                         test_name, test_a, test_b, expected_gcd, result);
            end
            @(posedge clk);
        end
    endtask

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        a     = 0;
        b     = 0;

        // Reset mach
        #20;
        rst_n = 1'b1;
        #15;

        $display("==========================================================================");
        $display("                         GCD_BINARY (THUAT TOAN STEIN)                    ");
        $display("==========================================================================");

        // 1. Truong hop ca hai so deu chan (kiem tra logic nhan 2 qua shift)
        run_test(32'd48,  32'd48,  32'd48, "Case A == B (48, 48)");

        // 2. Truong hop bien co so 0
        run_test(32'd25,  32'd0,   32'd25, "Case B == 0 (25, 0)");
        run_test(32'd0,   32'd37,  32'd37, "Case A == 0 (0, 37)");

        // 3. So nguyen to cung nhau, hai so chan le khong cung uoc chung
        run_test(32'd17,  32'd19,  32'd1,  "Case Coprime Odd-Odd");
        run_test(32'd35,  32'd64,  32'd1,  "Case Coprime Odd-Even");

        // 4. So hoc thong thuong
        run_test(32'd15,  32'd25,  32'd5,  "Case Standard (15, 25)");
        run_test(32'd100, 32'd25,  32'd25, "Case Multiple (100, 25)");

        // 5. Test case chenh lech lon (minh hoa uu the vuot troi so voi phep tru)
        run_test(32'd1000, 32'd1,  32'd1,  "Case Skewed (1000, 1)");

        #50;
        $display("==========================================================================");
        $display("                                    END                                   ");
        $display("==========================================================================");
        $finish;
    end

endmodule