`timescale 1ns/1ps
// ============================================================================
// board_top.v - Dua rsa_keygen len kit Arty Z7 (Z7-10 hoac Z7-20)
//   clk 125 MHz (H16) -> MMCM -> 50 MHz
//   btn[3]: reset   btn[0]: sinh khoa   btn[1]: demo ma hoa -> giai ma   btn[2]: in lai khoa
//   sw[0] = 1: che do do TRNG - day bit tho qua UART (8 bit tho / byte) de phan tich
//   led[0] rng_ok  led[1] busy  led[2] key_valid  led[3] err
//   led4 (RGB): do = loi, xanh la = co khoa;  led5 xanh duong nhap nhay = dang chay
//   uart_txd: chan 1 cua Pmod JA (Y18) -> chan RX cua mach USB-UART 3,3 V (GND: chan 5)
//   (USB-UART san co tren kit noi vao PS, PL khong dung truc tiep duoc.)
// ============================================================================
module board_top #(
    parameter CLKS_PER_BIT = 434,          // 50 MHz / 115200
    parameter DEB_STABLE   = 500_000,
    parameter SAMPLE_DIV   = 64
)(
    input  wire       clk,                 // 125 MHz
    input  wire [3:0] btn,
    input  wire [1:0] sw,
    output wire [3:0] led,
    output wire       led4_r, led4_g, led4_b,
    output wire       led5_r, led5_g, led5_b,
    output wire       uart_txd
);
    localparam N = 32;
    // ---------------- clock 50 MHz ----------------
    wire clk50;
`ifdef SYNTHESIS
    wire fb, clk50_u, locked;
    MMCME2_BASE #(.CLKIN1_PERIOD(8.0), .CLKFBOUT_MULT_F(8.0), .CLKOUT0_DIVIDE_F(20.0),
                  .DIVCLK_DIVIDE(1)) u_mmcm (
        .CLKIN1(clk), .CLKFBIN(fb), .CLKFBOUT(fb), .CLKOUT0(clk50_u), .LOCKED(locked),
        .PWRDWN(1'b0), .RST(1'b0),
        .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(),
        .CLKOUT4(), .CLKOUT5(), .CLKOUT6(), .CLKFBOUTB());
    BUFG u_bufg (.I(clk50_u), .O(clk50));
`else
    wire locked = 1'b1;
    assign clk50 = clk;
`endif
    // ---------------- reset: power-on + btn[3] ----------------
    reg [3:0] por = 4'h0;
    reg [1:0] rsync = 2'b00;
    always @(posedge clk50) begin
        if (!locked) por <= 0; else if (por != 4'hF) por <= por + 1'b1;
        rsync <= {rsync[0], (por == 4'hF) && !btn[3]};
    end
    wire rst_n = rsync[1];

    wire b_gen, b_demo, b_show, lv0, lv1, lv2;
    debounce #(.STABLE(DEB_STABLE)) d0 (.clk(clk50), .rst_n(rst_n), .btn(btn[0]), .level(lv0), .rise(b_gen));
    debounce #(.STABLE(DEB_STABLE)) d1 (.clk(clk50), .rst_n(rst_n), .btn(btn[1]), .level(lv1), .rise(b_demo));
    debounce #(.STABLE(DEB_STABLE)) d2 (.clk(clk50), .rst_n(rst_n), .btn(btn[2]), .level(lv2), .rise(b_show));
    reg [1:0] sws; always @(posedge clk50) sws <= sw;

    // ---------------- bo sinh khoa ----------------
    reg          kg_start, op_go, op_mode;
    reg  [N-1:0] op_in;
    wire [N-1:0] op_out, n, e, pd, qd, phd, dd;
    wire         op_done, key_valid, busy, err, rng_ok, raw_bit, raw_valid;
    wire [2:0]   err_code;
    wire [7:0]   cand_p, cand_q, e_tries; wire [1:0] vfail; wire [31:0] cycles;
    rsa_keygen #(.N(N), .DEBUG(0), .SAMPLE_DIV(SAMPLE_DIV)) u_kg (
        .clk(clk50), .rst_n(rst_n), .start(kg_start), .op_go(op_go), .op_mode(op_mode),
        .op_in(op_in), .op_out(op_out), .op_done(op_done), .n(n), .e(e), .key_valid(key_valid),
        .busy(busy), .err(err), .err_code(err_code), .rng_ok(rng_ok), .raw_bit_dbg(raw_bit), .raw_valid_dbg(raw_valid),
        .stat_cand_p(cand_p), .stat_cand_q(cand_q), .stat_e_tries(e_tries), .stat_vfail(vfail),
        .stat_cycles(cycles), .p_dbg(pd), .q_dbg(qd), .phi_dbg(phd), .d_dbg(dd));

    // ---------------- UART + bo in thong diep ----------------
    reg       tx_send; reg [7:0] tx_data; wire tx_ready;
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_tx (.clk(clk50), .rst_n(rst_n), .send(tx_send),
        .data(tx_data), .tx(uart_txd), .ready(tx_ready));

    localparam MSG_KEY = 2'd0, MSG_DEMO = 2'd1, MSG_ERR = 2'd2;
    localparam LEN_KEY = 40, LEN_DEMO = 38, LEN_ERR = 12;
    reg [1:0]   msg;
    reg [5:0]   idx;
    reg [N-1:0] m_demo, c_demo, m2_demo;

    function [7:0] hx(input [3:0] v);
        hx = (v < 10) ? 8'h30 + v : 8'h37 + v;       // '0'..'9','A'..'F'
    endfunction
    function [7:0] h8(input [31:0] w, input [5:0] pos);   // chu so hex thu pos (0 = cao nhat)
        h8 = hx(w >> (4 * (7 - pos)));
    endfunction
    // "KEY n=XXXXXXXX e=XXXXXXXX cyc=XXXXXXXX\r\n"   (40 ky tu)
    // "M=XXXXXXXX C=XXXXXXXX M'=XXXXXXXX OK\r\n"     (38 ky tu)
    // "ERR code=X\r\n"                                (12 ky tu)
    reg [7:0] ch;
    always @* begin
        ch = " ";
        case (msg)
        MSG_KEY: case (idx)
            0: ch = "K"; 1: ch = "E"; 2: ch = "Y"; 3: ch = " "; 4: ch = "n"; 5: ch = "=";
            6,7,8,9,10,11,12,13: ch = h8(n, idx - 6);
            14: ch = " "; 15: ch = "e"; 16: ch = "=";
            17,18,19,20,21,22,23,24: ch = h8(e, idx - 17);
            25: ch = " "; 26: ch = "c"; 27: ch = "y"; 28: ch = "c"; 29: ch = "=";
            30,31,32,33,34,35,36,37: ch = h8(cycles, idx - 30);
            38: ch = 8'h0D; 39: ch = 8'h0A;
            default: ch = " ";
            endcase
        MSG_DEMO: case (idx)
            0: ch = "M"; 1: ch = "=";
            2,3,4,5,6,7,8,9: ch = h8(m_demo, idx - 2);
            10: ch = " "; 11: ch = "C"; 12: ch = "=";
            13,14,15,16,17,18,19,20: ch = h8(c_demo, idx - 13);
            21: ch = " "; 22: ch = "M"; 23: ch = "'"; 24: ch = "=";
            25,26,27,28,29,30,31,32: ch = h8(m2_demo, idx - 25);
            33: ch = " ";
            34: ch = (m2_demo == m_demo) ? "O" : "N";
            35: ch = (m2_demo == m_demo) ? "K" : "G";
            36: ch = 8'h0D; 37: ch = 8'h0A;
            default: ch = " ";
            endcase
        default: case (idx)
            0: ch = "E"; 1: ch = "R"; 2: ch = "R"; 3: ch = " "; 4: ch = "c"; 5: ch = "o";
            6: ch = "d"; 7: ch = "e"; 8: ch = "="; 9: ch = hx({1'b0, err_code});
            10: ch = 8'h0D; 11: ch = 8'h0A;
            default: ch = " ";
            endcase
        endcase
    end
    wire [5:0] msg_len = (msg == MSG_KEY) ? LEN_KEY : (msg == MSG_DEMO) ? LEN_DEMO : LEN_ERR;

    // ---------------- FSM dieu khien kit ----------------
    localparam B_IDLE = 3'd0, B_WAITKEY = 3'd1, B_PRINT = 3'd2, B_ENC = 3'd3,
               B_DEC = 3'd4, B_RAW = 3'd5;
    reg [2:0] bst;
    reg       sent_err;
    reg [7:0] rawbyte; reg [2:0] rawcnt;

    always @(posedge clk50 or negedge rst_n) begin
        if (!rst_n) begin
            bst <= B_IDLE; kg_start <= 0; op_go <= 0; op_mode <= 0; op_in <= 0;
            tx_send <= 0; tx_data <= 0; msg <= 0; idx <= 0; sent_err <= 0;
            m_demo <= 0; c_demo <= 0; m2_demo <= 0; rawbyte <= 0; rawcnt <= 0;
        end else begin
            kg_start <= 0; op_go <= 0; tx_send <= 0;
            case (bst)
            B_IDLE: begin
                if (sws[0]) begin rawcnt <= 0; bst <= B_RAW; end
                else if (err && !sent_err) begin
                    sent_err <= 1; msg <= MSG_ERR; idx <= 0; bst <= B_PRINT;
                end else if (b_gen && !busy && !err) begin
                    kg_start <= 1; bst <= B_WAITKEY;
                end else if (b_show && key_valid) begin
                    msg <= MSG_KEY; idx <= 0; bst <= B_PRINT;
                end else if (b_demo && key_valid) begin
                    m_demo <= 32'h0BADF00D;                  // < 2^31 <= n
                    op_in <= 32'h0BADF00D; op_mode <= 0; op_go <= 1; bst <= B_ENC;
                end
            end
            B_WAITKEY: if (key_valid) begin msg <= MSG_KEY; idx <= 0; bst <= B_PRINT; end
                       else if (err) bst <= B_IDLE;
            B_ENC: if (op_done) begin
                    c_demo <= op_out; op_in <= op_out; op_mode <= 1; op_go <= 1; bst <= B_DEC;
                end
            B_DEC: if (op_done) begin
                    m2_demo <= op_out; msg <= MSG_DEMO; idx <= 0; bst <= B_PRINT;
                end
            B_PRINT: if (tx_ready && !tx_send) begin
                    if (idx == msg_len) bst <= B_IDLE;
                    else begin tx_data <= ch; tx_send <= 1; idx <= idx + 1'b1; end
                end
            B_RAW: begin                                   // do TRNG: gom 8 bit tho -> 1 byte
                if (!sws[0]) bst <= B_IDLE;
                else if (raw_valid) begin
                    rawbyte <= {rawbyte[6:0], raw_bit};
                    rawcnt  <= rawcnt + 1'b1;
                    if (rawcnt == 7 && tx_ready && !tx_send) begin
                        tx_data <= {rawbyte[6:0], raw_bit}; tx_send <= 1;
                    end
                end
            end
            endcase
        end
    end

    // ---------------- LED ----------------
    reg [25:0] hb = 26'd0; always @(posedge clk50) hb <= hb + 1'b1;
    assign led    = {err, key_valid, busy, rng_ok};
    assign led4_r = err;
    assign led4_g = key_valid && !err;
    assign led4_b = 1'b0;
    assign led5_r = 1'b0;
    assign led5_g = 1'b0;
    assign led5_b = busy & hb[22];
endmodule
