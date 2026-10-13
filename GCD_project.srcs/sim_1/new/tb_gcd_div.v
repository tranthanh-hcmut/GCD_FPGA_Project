`timescale 1ns / 1ps

module tb_gcd_div;

    parameter N = 32;

    reg         clk;
    reg         rst_n;
    reg         start;
    reg [N-1:0] a;
    reg [N-1:0] b;
    wire [N-1:0] result;
    wire        done;

    integer latency_count;

    gcd_div #(.N(N)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .a(a),
        .b(b),
        .result(result),
        .done(done)
    );

    always #5 clk = ~clk;

    task run_test(
        input [N-1:0] in_a,
        input [N-1:0] in_b,
        input [N-1:0] expected_gcd,
        input [255:0] test_name
    );
    begin
        @(posedge clk);
        a     = in_a;
        b     = in_b;
        start = 1'b1;
        latency_count = 0;

        @(posedge clk);
        start = 1'b0;

        while (!done) begin
            @(posedge clk);
            latency_count = latency_count + 1;
        end

        if (result === expected_gcd) begin
            $display("[PASS] %0s | GCD(%0d, %0d) = %0d | Latency: %0d clk", 
                     test_name, in_a, in_b, result, latency_count);
        end else begin
            $display("[FAIL] %0s | GCD(%0d, %0d) = %0d (Expected: %0d) | Latency: %0d clk", 
                     test_name, in_a, in_b, result, expected_gcd, latency_count);
        end

        @(posedge clk);
    end
    endtask

    initial begin
        clk   = 0;
        rst_n = 0;
        start = 0;
        a     = 0;
        b     = 0;

        #20;
        rst_n = 1;
        #15;

        $display("===== GCD EUCLID CHIA (N = %0d) =====", N);

        run_test(32'd48, 32'd48, 32'd48, "Case A == B");
        run_test(32'd25, 32'd0, 32'd25, "Case B == 0");
        run_test(32'd0, 32'd37, 32'd37, "Case A == 0");
        run_test(32'd17, 32'd19, 32'd1, "Case Coprime Primes");
        run_test(32'd35, 32'd64, 32'd1, "Case Coprime Composites");
        run_test(32'd15, 32'd25, 32'd5, "Case Standard");
        run_test(32'hFFFFFFFF, 32'd357913941, 32'd1, "Case Max Bit Width");

        $display("===== END =====");
        #50;
        $finish;
    end

endmodule