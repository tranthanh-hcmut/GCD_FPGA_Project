`timescale 1ns / 1ps

module gcd_sub #(
    parameter N = 8
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output reg  [N-1:0] result,
    output reg          done
);

    localparam [1:0] S_IDLE    = 2'b00,
                     S_COMPUTE = 2'b01,
                     S_DONE    = 2'b10;

    reg [1:0] state, next_state;

    reg [N-1:0] reg_a;
    reg [N-1:0] reg_b;

    reg load_inputs;
    reg update_regs;
    
    // Tín hiệu cờ điều khiển quá trình trừ
    wire a_equals_b = (reg_a == reg_b);
    wire a_is_zero  = (reg_a == {N{1'b0}});
    wire b_is_zero  = (reg_b == {N{1'b0}});
    wire a_gt_b     = (reg_a > reg_b);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state  = state;
        load_inputs = 1'b0;
        update_regs = 1'b0;
        done        = 1'b0;

        case (state)
            S_IDLE: begin
                if (start) begin
                    load_inputs = 1'b1;
                    next_state  = S_COMPUTE;
                end
            end

            S_COMPUTE: begin
                // Dừng tính toán khi a = b hoặc một trong hai bằng 0
                if (a_equals_b || a_is_zero || b_is_zero) begin
                    next_state = S_DONE;
                end else begin
                    update_regs = 1'b1;
                    next_state  = S_COMPUTE;
                end
            end

            S_DONE: begin
                done = 1'b1;
                if (!start)
                    next_state = S_IDLE;
                else
                    next_state = S_DONE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_a  <= {N{1'b0}};
            reg_b  <= {N{1'b0}};
            result <= {N{1'b0}};
        end else begin
            if (load_inputs) begin
                reg_a <= a;
                reg_b <= b;
            end else if (update_regs) begin
                if (a_gt_b) begin
                    reg_a <= reg_a - reg_b;
                end else begin
                    reg_b <= reg_b - reg_a;
                end
            end

            // Cập nhật kết quả khi tính toán xong
            if (state == S_COMPUTE && (a_equals_b || a_is_zero || b_is_zero)) begin
                if (b_is_zero)
                    result <= reg_a;
                else
                    result <= reg_b;
            end
        end
    end

endmodule