`timescale 1ns / 1ps

module gcd_binary #(
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

    // Dinh nghia cac trang thai FSM
    localparam [1:0] S_IDLE    = 2'b00,
                     S_COMPUTE = 2'b01,
                     S_DONE    = 2'b10;

    reg [1:0]         state, next_state;
    reg [N-1:0]       reg_a;
    reg [N-1:0]       reg_b;
    reg [$clog2(N):0] shift; // Bien dem thua so 2 chung (tu co gian theo N)

    reg load_inputs;
    reg update_regs;
    
    // Cac co kiem tra trang thai
    wire a_equals_b = (reg_a == reg_b);
    wire a_is_zero  = (reg_a == {N{1'b0}});
    wire b_is_zero  = (reg_b == {N{1'b0}});
    
    // Kiem tra chan / le dua tren LSB
    wire a_is_even  = (reg_a[0] == 1'b0);
    wire b_is_even  = (reg_b[0] == 1'b0);
    wire a_gt_b     = (reg_a > reg_b);

    // 1. Chuyen trang thai FSM tuan tu
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // 2. Logic chuyen trang thai to hop
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
                // Dung khi mot trong hai so bang 0 hoac hai so bang nhau
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

    // 3. Datapath: Xu ly du lieu theo tung chu ky xung nhip
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_a  <= {N{1'b0}};
            reg_b  <= {N{1'b0}};
            shift  <= 0;
            result <= {N{1'b0}};
        end else begin
            if (load_inputs) begin
                reg_a <= a;
                reg_b <= b;
                shift <= 0;
            end else if (update_regs) begin
                // Logic cot loi cua thuat toan Stein
                if (a_is_even && b_is_even) begin
                    // Ca hai deu chan: chia 2 va tang bien dem shift
                    reg_a <= reg_a >> 1;
                    reg_b <= reg_b >> 1;
                    shift <= shift + 1;
                end else if (a_is_even) begin
                    // A chan, B le: chia 2 cho A
                    reg_a <= reg_a >> 1;
                end else if (b_is_even) begin
                    // A le, B chan: chia 2 cho B
                    reg_b <= reg_b >> 1;
                end else begin
                    // Ca hai deu le: lay so lon tru so nho
                    if (a_gt_b)
                        reg_a <= reg_a - reg_b;
                    else
                        reg_b <= reg_b - reg_a;
                end
            end

            // Cap nhat ket qua khi tinh xong (dich trai tra lai thua so 2)
            if (state == S_COMPUTE && (a_equals_b || a_is_zero || b_is_zero)) begin
                if (a_is_zero)
                    result <= reg_b << shift;
                else
                    result <= reg_a << shift;
            end
        end
    end

endmodule