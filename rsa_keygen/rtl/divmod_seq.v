`timescale 1ns/1ps
// ============================================================================
// divmod_seq.v - Chia phuc hoi (restoring) tuan tu: 2N-bit / N-bit
//   q = num / den, r = num % den. Dung 2N chu ky, khong phu thuoc du lieu.
//   Thay cho toan tu % to hop (bao cao muc 2.2: % 32 bit keo fmax xuong 10,9 MHz).
//   Dung o buoc quy trinh 7 de kiem e*d mod phi = 1.
// ============================================================================
module divmod_seq #(
    parameter N = 32
)(
    input  wire           clk,
    input  wire           rst_n,
    input  wire           start,
    input  wire [2*N-1:0] num,
    input  wire [N-1:0]   den,
    output reg  [2*N-1:0] q,
    output reg  [N-1:0]   r,
    output wire           busy,
    output reg            done
);
    localparam CW = $clog2(2*N);
    reg           run;
    reg [2*N-1:0] sh;          // so bi chia dang dich ra
    reg [N:0]     rem;         // phan du tam, rong N+1 bit
    reg [N-1:0]   dv;
    reg [CW-1:0]  cnt;
    wire [N:0]    trial = {rem[N-1:0], sh[2*N-1]};
    wire [N+1:0]  diff  = {1'b0, trial} - {2'b00, dv};
    assign busy = run;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            run <= 0; done <= 0; q <= 0; sh <= 0; rem <= 0; dv <= 0; cnt <= 0;
        end else begin
            done <= 1'b0;
            if (!run) begin
                if (start) begin
                    sh <= num; rem <= 0; dv <= den; q <= 0; cnt <= 0; run <= 1'b1;
                end
            end else begin
                sh <= sh << 1;
                if (!diff[N+1]) begin rem <= diff[N:0]; q <= {q[2*N-2:0], 1'b1}; end
                else            begin rem <= trial;     q <= {q[2*N-2:0], 1'b0}; end
                cnt <= cnt + 1'b1;
                if (cnt == 2*N-1) run <= 1'b0;
            end
            if (run && cnt == 2*N-1) done <= 1'b1;
        end
    end
    always @* r = rem[N-1:0];
endmodule
