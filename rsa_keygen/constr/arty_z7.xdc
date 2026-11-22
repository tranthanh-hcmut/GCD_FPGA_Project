## arty_z7.xdc - rang buoc cho board_top tren Arty Z7-10 / Z7-20
## Chan lay tu Arty-Z7-20-Master.xdc cua Digilent (github.com/Digilent/digilent-xdc);
## Z7-10 dung chung cac chan nay.

## Clock 125 MHz
set_property -dict { PACKAGE_PIN H16  IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];

## Nut bam: btn0 sinh khoa, btn1 demo, btn2 in lai khoa, btn3 reset
set_property -dict { PACKAGE_PIN D19  IOSTANDARD LVCMOS33 } [get_ports { btn[0] }];
set_property -dict { PACKAGE_PIN D20  IOSTANDARD LVCMOS33 } [get_ports { btn[1] }];
set_property -dict { PACKAGE_PIN L20  IOSTANDARD LVCMOS33 } [get_ports { btn[2] }];
set_property -dict { PACKAGE_PIN L19  IOSTANDARD LVCMOS33 } [get_ports { btn[3] }];

## Cong tac: sw0 = che do do TRNG (day bit tho qua UART)
set_property -dict { PACKAGE_PIN M20  IOSTANDARD LVCMOS33 } [get_ports { sw[0] }];
set_property -dict { PACKAGE_PIN M19  IOSTANDARD LVCMOS33 } [get_ports { sw[1] }];

## LED: led0 rng_ok, led1 busy, led2 key_valid, led3 err
set_property -dict { PACKAGE_PIN R14  IOSTANDARD LVCMOS33 } [get_ports { led[0] }];
set_property -dict { PACKAGE_PIN P14  IOSTANDARD LVCMOS33 } [get_ports { led[1] }];
set_property -dict { PACKAGE_PIN N16  IOSTANDARD LVCMOS33 } [get_ports { led[2] }];
set_property -dict { PACKAGE_PIN M14  IOSTANDARD LVCMOS33 } [get_ports { led[3] }];
set_property -dict { PACKAGE_PIN N15  IOSTANDARD LVCMOS33 } [get_ports { led4_r }];
set_property -dict { PACKAGE_PIN G17  IOSTANDARD LVCMOS33 } [get_ports { led4_g }];
set_property -dict { PACKAGE_PIN L15  IOSTANDARD LVCMOS33 } [get_ports { led4_b }];
set_property -dict { PACKAGE_PIN M15  IOSTANDARD LVCMOS33 } [get_ports { led5_r }];
set_property -dict { PACKAGE_PIN L14  IOSTANDARD LVCMOS33 } [get_ports { led5_g }];
set_property -dict { PACKAGE_PIN G14  IOSTANDARD LVCMOS33 } [get_ports { led5_b }];

## UART TX tren Pmod JA chan 1 (Y18). Noi vao chan RX cua mach USB-UART 3,3 V,
## GND cua mach noi vao chan 5 cua JA. (USB-UART co san tren kit noi vao PS, PL khong dung duoc.)
set_property -dict { PACKAGE_PIN Y18  IOSTANDARD LVCMOS33 } [get_ports { uart_txd }];

## Ring oscillator cua TRNG: cho phep vong to hop (DRC LUTLP-1) va bo qua timing
set_property ALLOW_COMBINATORIAL_LOOPS TRUE [get_nets -hierarchical -filter {NAME =~ *u_ro*chain*}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *u_ro/s1_reg}]
## Neu Vivado van bao loi LUTLP-1, bo comment dong duoi:
# set_property SEVERITY {Warning} [get_drc_checks LUTLP-1]
