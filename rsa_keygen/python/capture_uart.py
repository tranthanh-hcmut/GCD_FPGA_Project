#!/usr/bin/env python3
"""
capture_uart.py - Doc UART tu kit (can: pip install pyserial).
  python3 capture_uart.py COM5                -> in dong chu (khoa, demo, loi)
  python3 capture_uart.py COM5 raw.bin 200000 -> ghi 200000 byte bit tho (bat sw0 truoc)
Tren Linux cong co dang /dev/ttyUSB0.
"""
import sys
import serial

port = sys.argv[1]
with serial.Serial(port, 115200, timeout=5) as s:
    if len(sys.argv) >= 4:
        out, want = sys.argv[2], int(sys.argv[3])
        buf = bytearray()
        while len(buf) < want:
            chunk = s.read(min(4096, want - len(buf)))
            if not chunk:
                break
            buf += chunk
            print(f"\r{len(buf)}/{want} byte", end="")
        open(out, "wb").write(buf)
        print(f"\nDa ghi {len(buf)} byte vao {out}")
    else:
        while True:
            line = s.readline().decode(errors="replace").rstrip()
            if line:
                print(line)
