`timescale 1ns / 1ps

module tb_gcd_sub;

    parameter N = 32;

    reg          clk;
    reg          rst_n;
    reg          start;
    reg  [N-1:0] a;
    reg  [N-1:0] b;
    wire [N-1:0] result;
    wire         done;

    // Khởi tạo UUT (Unit Under Test)
    gcd_sub #(.N(N)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(done)
    );

    // Tạo xung clock 100 MHz (chu kỳ 10ns: 5ns mức thấp, 5ns mức cao)
    always #5 clk = ~clk;

    // Task tự động cấp test case và đếm chu kỳ thực thi (Latency)
    task run_test(
        input [N-1:0] test_a,
        input [N-1:0] test_b,
        input [N-1:0] expected_gcd,
        input [255:0] test_name
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

            // Chờ module tính xong (cờ done = 1) và đếm số chu kỳ clock
            while (!done) begin
                @(posedge clk);
                latency_count = latency_count + 1;
            end

            // Kiểm tra kết quả tính toán
            if (result === expected_gcd) begin
                $display("[PASS] %-25s | A = %-10d | B = %-10d | GCD = %-10d | Latency = %0d cycles",
                         test_name, test_a, test_b, result, latency_count);
            end else begin
                $display("[FAIL] %-25s | A = %-10d | B = %-10d | Expected = %-10d | Got = %-10d",
                         test_name, test_a, test_b, expected_gcd, result);
            end
            @(posedge clk);
        end
    endtask

    initial begin
        // Khởi tạo các tín hiệu
        clk   = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        a     = 0;
        b     = 0;

        // Reset hệ thống
        #20;
        rst_n = 1'b1;
        #15;

        $display("==========================================================================");
        $display("                      GCD_SUB (EUCLID TRU LIEN TIEP)                      ");
        $display("==========================================================================");

        // ---> VỊ TRÍ GẮN TESTCASE MỚI VÀO ĐÂY <---
        if (N == 8) begin
            // ===========================================================================
            // N = 8 (13 directed test cases khop tap C++)
            // ===========================================================================
            run_test(8'd48,  8'd48,  8'd48,  "Case A == B");
            run_test(8'd25,  8'd0,   8'd25,  "Case B == 0");
            run_test(8'd0,   8'd37,  8'd37,  "Case A == 0");
            run_test(8'd0,   8'd0,   8'd0,   "Case A == B == 0");
            run_test(8'd17,  8'd19,  8'd1,   "Case Coprime primes");
            run_test(8'd35,  8'd64,  8'd1,   "Case Coprime composites");
            run_test(8'd252, 8'd105, 8'd21,  "Case Standard 252,105");
            run_test(8'd15,  8'd25,  8'd5,   "Case Standard 15,25");
            run_test(8'd100, 8'd25,  8'd25,  "Case Multiple");
            run_test(8'd255, 8'd1,   8'd1,   "Case Max & 1 (worst sub)");
            run_test(8'd255, 8'd255, 8'd255, "Case Max == Max");
            run_test(8'd255, 8'd85,  8'd85,  "Case Max width, multiple");
            run_test(8'd233, 8'd144, 8'd1,   "Case Fibonacci (worst div)");
        end else begin
            // ===========================================================================
            // N = 32 (14 directed test cases khop tap C++)
            // ===========================================================================
            run_test(32'd48,         32'd48,         32'd48,         "Case A == B");
            run_test(32'd25,         32'd0,          32'd25,         "Case B == 0");
            run_test(32'd0,          32'd37,         32'd37,         "Case A == 0");
            run_test(32'd0,          32'd0,          32'd0,          "Case A == B == 0");
            run_test(32'd17,         32'd19,         32'd1,          "Case Coprime primes");
            run_test(32'd35,         32'd64,         32'd1,          "Case Coprime composites");
            run_test(32'd252,        32'd105,        32'd21,         "Case Standard 252,105");
            run_test(32'd15,         32'd25,         32'd5,          "Case Standard 15,25");
            run_test(32'd100,        32'd25,         32'd25,         "Case Multiple");
            run_test(32'd1000,       32'd1,          32'd1,          "Case Skewed 1000,1");
            run_test(32'hFFFFFFFF,   32'hFFFFFFFF,   32'hFFFFFFFF,   "Case Max == Max");
            run_test(32'hFFFFFFFF,   32'h55555555,   32'h55555555,   "Case Max width, multiple");
            run_test(32'd1836311903, 32'd1134903170, 32'd1,          "Case Fibonacci (worst div)");
            run_test(32'hFFFFFFFF,   32'd357913941,  32'd3,          "Case Max width, gcd=3");
        end
        // -----------------------------------------

        #50;
        $display("==========================================================================");
        $display("                                      END                                 ");
        $display("==========================================================================");
        $finish;
    end

endmodule