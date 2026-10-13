`timescale 1ns / 1ps

module gcd_div #(
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
                if (reg_b == {N{1'b0}}) begin
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
                reg_a <= reg_b;
                reg_b <= reg_a % reg_b;
            end

            if (state == S_COMPUTE && reg_b == {N{1'b0}}) begin
                result <= reg_a;
            end
        end
    end

endmodule