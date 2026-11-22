# rsa_keygen — Phần nâng cao CO3091: bộ sinh khóa RSA an toàn trên FPGA

Hiện thực quy trình 9 bước (tài liệu "Quy trình sinh khóa RSA an toàn trên FPGA"):
TRNG → sinh p, q (sàng bằng lõi GCD + Miller–Rabin) → n, φ → dò e bằng lõi GCD →
d = e⁻¹ mod φ (Euclid mở rộng nhị phân) → kiểm tra nhất quán → xóa bí mật.

## Cấu trúc
```
python/   keygen_model.py   golden model mô phỏng từng chu kỳ + thống kê
          analyze_trng.py   phân tích bit thô TRNG thu từ kit
          capture_uart.py   đọc UART từ kit (pip install pyserial)
rtl/      gcd_ct.v          GCD Stein, cố định 2N chu kỳ           (bước 2)
          modinv_ct.v       nghịch đảo modulo nhị phân, 2N+2 chu kỳ (bước 3)
          mul_seq.v         nhân dịch-cộng, N chu kỳ                (bước 4)
          divmod_seq.v      chia phục hồi, 2N chu kỳ                (bước 4)
          montmul.v         nhân Montgomery cơ số 2, N+2 chu kỳ     (bước 5)
          modexp.v          lũy thừa square-and-multiply-always     (bước 5)
          trng_ro.v / trng_health.v / trng_post.v / trng_top.v     (bước 6)
          prime_gen.v       sinh số nguyên tố                        (bước 7)
          rsa_keygen.v      FSM toàn quy trình                       (bước 8)
          uart_tx.v / debounce.v / board_top.v  lên kit Arty Z7     (bước 9)
tb/       testbench tự kiểm tra cho từng module
constr/   arty_z7.xdc
sim/      run_all.sh        chạy mọi testbench bằng Icarus Verilog
vivado/   build.tcl         tổng hợp → bitstream không cần tạo project
```

## Chạy nhanh
```
cd sim && ./run_all.sh            # mọi bước;  ./run_all.sh inv  -> chỉ modinv_ct
cd python && python3 keygen_model.py --check
vivado -mode batch -source vivado/build.tcl     # chạy từ thư mục rsa_keygen
```
Trong Vivado GUI: Add Sources → toàn bộ `rtl/*.v`, `tb/*.v` (Simulation Sources),
`constr/arty_z7.xdc`; top tổng hợp là `board_top`, top mô phỏng là testbench cần chạy.
