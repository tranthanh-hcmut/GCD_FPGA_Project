#!/usr/bin/env python3
"""
analyze_trng.py - Phan tich bit tho TRNG thu tu kit (che do sw0 = 1).
  python3 analyze_trng.py raw.bin
In ra: ti le bit 1, chuoi dai nhat, ty le cua so 256 bit lot vao [96,160],
va uoc luong min-entropy theo tan suat byte pho bien nhat (kieu "most common value").
Luu y (Ch.3 §3.3): qua cac kiem tra thong ke KHONG chung minh duoc entropy.
"""
import math
import sys
from collections import Counter

data = open(sys.argv[1], "rb").read()
bits = [(b >> (7 - i)) & 1 for b in data for i in range(8)]
n = len(bits)
ones = sum(bits)
run = best = 1
for a, b in zip(bits, bits[1:]):
    run = run + 1 if a == b else 1
    best = max(best, run)
wins = [sum(bits[i:i + 256]) for i in range(0, n - 255, 256)]
ok = sum(96 <= w <= 160 for w in wins)
cnt = Counter(data)
p_max = cnt.most_common(1)[0][1] / len(data)
# can tren 99% cua p_max (giong NIST SP 800-90B, muc 6.3.1)
p_up = min(1.0, p_max + 2.576 * math.sqrt(p_max * (1 - p_max) / max(len(data) - 1, 1)))
print(f"So bit            : {n}")
print(f"Ti le bit 1       : {ones / n:.4f}")
print(f"Chuoi dai nhat    : {best} bit (tot test bao dong tai 48)")
print(f"Cua so 256 bit dat: {ok}/{len(wins)} (online test can [96,160])")
print(f"Min-entropy uoc luong: {-math.log2(p_up) / 8:.3f} bit / bit tho")
