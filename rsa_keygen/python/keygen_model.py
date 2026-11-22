#!/usr/bin/env python3
"""
keygen_model.py - Golden model cho phan nang cao CO3091 (sinh khoa RSA tren FPGA).

Moi ham o day mo phong DUNG tung chu ky cua module RTL cung ten, de:
  1. so sanh gia tri trung gian voi waveform trong Vivado/iverilog;
  2. chung minh cac can so chu ky (2N cho gcd_ct va modinv_ct);
  3. chay ca quy trinh 9 buoc voi TRNG gia co seed va in log tung buoc.

Chay:  python3 keygen_model.py                    (N=32, 1 khoa, in log tung buoc)
       python3 keygen_model.py --N 16 --seed 3    (cau hinh 16 bit)
       python3 keygen_model.py --stats 2000       (thong ke tren 2000 khoa)
       python3 keygen_model.py --check            (kiem bat bien, can chu ky, MR chinh xac)
       python3 keygen_model.py --from-pq 49393 52571   (doi chieu voi khoa RTL in ra)
"""
import argparse
import math
import random

# ---------------------------------------------------------------------------
# Buoc 2 - gcd_ct: Stein, moi chu ky lam dung 1 buoc, chay co dinh 2N chu ky
# ---------------------------------------------------------------------------
def gcd_ct(a, b, N, trace=False):
    ra, rb, k = a, b, 0
    steps = 0
    for cyc in range(2 * N):
        fin = ra == 0 or rb == 0 or ra == rb
        if trace:
            print(f"  cyc {cyc:3d}: ra={ra:#x} rb={rb:#x} k={k} fin={int(fin)}")
        if fin:
            continue                      # chu ky "gia": giu nguyen thanh ghi
        steps += 1
        if ra % 2 == 0 and rb % 2 == 0:
            ra, rb, k = ra >> 1, rb >> 1, k + 1
        elif ra % 2 == 0:
            ra >>= 1
        elif rb % 2 == 0:
            rb >>= 1
        elif ra > rb:
            ra = (ra - rb) >> 1
        else:
            rb = (rb - ra) >> 1
    assert ra == 0 or rb == 0 or ra == rb, "2N chu ky chua du - sai can!"
    g = (rb if ra == 0 else ra) << k
    return g, steps


# ---------------------------------------------------------------------------
# Buoc 3 - modinv_ct: Euclid mo rong nhi phan (HAC 14.61, dang "tru roi dich")
#   bat bien: A*x + B*y = u ,  C*x + D*y = v
# ---------------------------------------------------------------------------
def _halve(P, Q, x, y):
    if P % 2 == 0 and Q % 2 == 0:
        return P >> 1, Q >> 1             # >> tren so am trong Python = dich so hoc
    assert (P + y) % 2 == 0 and (Q - x) % 2 == 0
    return (P + y) >> 1, (Q - x) >> 1


def modinv_ct(x, y, N, trace=False, stats=None):
    """Tra ve (inv, ok, steps). x phai le, 0 < x < y."""
    assert x % 2 == 1 and 0 < x < y < (1 << N)
    u, v = x, y
    A, B, C, D = 1, 0, 0, 1
    steps = 0
    for cyc in range(2 * N):
        fin = u == 0 or v == 0 or u == v
        if trace:
            print(f"  cyc {cyc:3d}: u={u:#x} v={v:#x} A={A} C={C} fin={int(fin)}")
        if fin:
            continue
        steps += 1
        if u % 2 == 0:
            u >>= 1
            A, B = _halve(A, B, x, y)
        elif v % 2 == 0:
            v >>= 1
            C, D = _halve(C, D, x, y)
        elif u > v:
            u = (u - v) >> 1
            A, B = _halve(A - C, B - D, x, y)
        else:
            v = (v - u) >> 1
            C, D = _halve(C - A, D - B, x, y)
        assert A * x + B * y == u and C * x + D * y == v, "bat bien bi pha"
        if stats is not None:
            stats["max_coef"] = max(stats.get("max_coef", 0), abs(A), abs(C),
                                    abs(B) * y // max(x, 1), abs(D) * y // max(x, 1))
    assert u == 0 or v == 0 or u == v, "2N chu ky chua du - sai can!"
    g, coef = (v, C) if u == 0 else (u, A)
    # 2 chu ky chuan hoa ve [0, y)
    if coef < 0:
        coef += y
    if coef < 0:
        coef += y
    elif coef >= y:
        coef -= y
    assert 0 <= coef < y, "khoang he so vuot (-2y, 2y)"
    if stats is not None:
        stats["max_final"] = max(stats.get("max_final", 0), abs(coef))
    return coef, g == 1, steps


# ---------------------------------------------------------------------------
# Buoc 5 - montmul (co so 2, L = N+2 vong, KHONG co phep tru cuoi) va modexp
# ---------------------------------------------------------------------------
def montmul(a, b, m, N):
    L = N + 2
    assert m % 2 == 1 and a < 2 * m and b < 2 * m and 4 * m < (1 << L)
    t = 0
    for i in range(L):
        if (a >> i) & 1:
            t += b
        if t & 1:
            t += m
        t >>= 1
    assert t < 2 * m, "Walter: dau ra phai < 2M"
    return t


def modexp(x, e, ebits, m, N):
    """x^e mod m, square-and-multiply-always tren ebits bit (cong khai)."""
    L = N + 2
    r2 = 1
    for _ in range(2 * L):                 # R^2 mod m bang 2L lan nhan doi
        r2 <<= 1
        if r2 >= m:
            r2 -= m
    xm = montmul(x, r2, m, N)              # x*R mod m
    acc = montmul(1, r2, m, N)             # 1*R mod m
    for i in reversed(range(ebits)):
        acc = montmul(acc, acc, m, N)
        t = montmul(acc, xm, m, N)         # luon tinh, chi chon ket qua
        if (e >> i) & 1:
            acc = t
    y = montmul(acc, 1, m, N)
    if y >= m:
        y -= m
    return y


def modexp_cycles(ebits, N):
    """So chu ky RTL (khop voi modexp.v)."""
    L = N + 2
    mm = L + 1                             # montmul: L vong + 1 chu ky nap
    return 2 * L + 2 * mm + ebits * 2 * mm + mm + 2


# ---------------------------------------------------------------------------
# Buoc 7 - Miller-Rabin co dinh so lan binh phuong
# ---------------------------------------------------------------------------
def miller_rabin_ct(c, K, N, bases=(2, 3)):
    m, s = c - 1, 0
    for _ in range(K):                     # K chu ky co dinh
        if m % 2 == 0:
            m >>= 1
            s += 1
    for a in bases:
        x = modexp(a, m, K, c, N)
        probable = x == 1 or x == c - 1
        for i in range(1, K):              # luon K-1 lan binh phuong
            x = modexp(x, 2, 2, c, N)
            if i < s and x == c - 1:
                probable = True
        if not probable:
            return False
    return True


def small_prime_product(N):
    prod = 1
    for p in (3, 5, 7, 11, 13, 17, 19, 23):
        if prod * p >= (1 << N):
            break
        prod *= p
    return prod


# ---------------------------------------------------------------------------
# Ca quy trinh 9 buoc (buoc quy trinh 0..8)
# ---------------------------------------------------------------------------
class FakeTRNG:
    """Thay cho TRNG that: chi de mo phong (seed co dinh => lap lai duoc)."""
    def __init__(self, seed):
        self.rng = random.Random(seed)

    def word(self, bits=32):
        return self.rng.getrandbits(bits)


def keygen(N=32, seed=1, log=True, max_tries=255, max_e=64):
    K = N // 2
    trng = FakeTRNG(seed)
    out = {"cand_p": 0, "cand_q": 0, "e_tries": 0}
    say = print if log else (lambda *a, **k: None)

    # buoc 0 - KAT
    assert gcd_ct(17, 3120, N)[0] == 1
    assert modinv_ct(17, 3120, N)[0] == 2753
    assert modexp(3, 200, 8, 1009, N) == 985
    say("[0] KAT dat: gcd(17,3120)=1, 17^-1 mod 3120=2753, 3^200 mod 1009=985")

    def gen_prime(tag, avoid=None):
        for tries in range(1, max_tries + 1):
            r = trng.word()
            c = (0b11 << (K - 2)) | (r & ((1 << (K - 2)) - 1)) | 1     # buoc 2
            if gcd_ct(c, small_prime_product(N), N)[0] != 1:            # buoc 3a
                say(f"    {tag}: ung vien {c} bi sang loai")
                continue
            if not miller_rabin_ct(c, K, N):                            # buoc 3b
                say(f"    {tag}: ung vien {c} truot Miller-Rabin")
                continue
            if c == avoid:
                say(f"    {tag}: trung p, thu lai")
                continue
            out["cand_" + tag] = tries
            return c
        raise RuntimeError("qua so lan thu")

    p = gen_prime("p")
    q = gen_prime("q", avoid=p)
    say(f"[2-3] p={p} q={q} (so ung vien {out['cand_p']}, {out['cand_q']})")

    n, phi = p * q, (p - 1) * (q - 1)                                   # buoc 4
    assert n >> (N - 1) == 1, "n phai du N bit"
    say(f"[4] n={n} ({n:#x}) phi={phi}")

    e = 65537 if 65537 < phi else 3                                     # buoc 5
    for t in range(1, max_e + 1):
        if gcd_ct(e, phi, N)[0] == 1:
            out["e_tries"] = t
            break
        e += 2
    else:
        raise RuntimeError("qua so lan do e")
    say(f"[5] e={e} sau {out['e_tries']} lan thu")

    d, ok, _ = modinv_ct(e, phi, N)                                     # buoc 6
    assert ok
    say(f"[6] d={d}")

    assert (e * d) % phi == 1                                           # buoc 7a
    msg = trng.word(N - 1)                                              # M < 2^(N-1) <= n
    c = modexp(msg, e, N, n, N)
    rblind = trng.word(8)
    d_blind = d + rblind * (e * d - 1)                                  # lam mu mu
    m2 = modexp(c, d_blind, 2 * N, n, N)
    assert m2 == msg, "verify sai"
    say(f"[7] verify: M={msg:#x} C={c:#x} M'={m2:#x} (r={rblind})")
    say("[8] xuat (n, e); xoa p, q, phi")
    out.update(p=p, q=q, n=n, phi=phi, e=e, d=d)
    return out


def from_pq(p, q, N=32):
    """Tinh lai buoc 4-6 tu p, q in ra boi testbench RTL de doi chieu."""
    n, phi = p * q, (p - 1) * (q - 1)
    e = 65537 if 65537 < phi else 3
    tries = 1
    while math.gcd(e, phi) != 1:
        e += 2
        tries += 1
    d = modinv_ct(e, phi, N)[0]
    print(f"p={p} q={q} -> n={n} ({n:#x}) phi={phi} e={e} (lan do {tries}) d={d}")


def check_mr_exact(K=16):
    def mr(c):
        m, s = c - 1, 0
        while m % 2 == 0:
            m //= 2
            s += 1
        for a in (2, 3):
            x = pow(a, m, c)
            if x in (1, c - 1):
                continue
            for _ in range(s - 1):
                x = x * x % c
                if x == c - 1:
                    break
            else:
                return False
        return True
    sieve = bytearray([1]) * (1 << K)
    sieve[0] = sieve[1] = 0
    for i in range(2, int((1 << K) ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    bad = [c for c in range(5, 1 << K, 2) if mr(c) != bool(sieve[c])]
    print(f"Miller-Rabin co so {{2,3}}: sai {len(bad)} so le duoi 2^{K}")


def check_bounds(trials=20000):
    print("Kiem gcd_ct: vet can N=8 (moi cap a,b < 256) ...")
    worst = 0
    for a in range(256):
        for b in range(256):
            g, st = gcd_ct(a, b, 8)
            assert g == math.gcd(a, b)
            worst = max(worst, st)
    print(f"  dung het; so buoc that toi da = {worst} (can 2N = 16)")
    for N in (16, 32):
        rng = random.Random(N)
        st = {}
        worst = 0
        for _ in range(trials):
            y = rng.getrandbits(N) | (1 << (N - 1))
            y &= ~1                        # phi luon chan
            x = rng.randrange(1, y) | 1
            if x >= y:
                continue
            inv, ok, steps = modinv_ct(x, y, N, stats=st)
            assert ok == (math.gcd(x, y) == 1)
            if ok:
                assert inv == pow(x, -1, y)
            worst = max(worst, steps)
        print(f"Kiem modinv_ct N={N}: {trials} cap ngau nhien dung; "
              f"so buoc toi da {worst} (can 2N = {2*N}); "
              f"|he so| lon nhat / 2^N = {st['max_coef'] / (1 << N):.2f}")
    for N in (16, 32):
        rng = random.Random(7 + N)
        for _ in range(3000):
            m = rng.getrandbits(N) | 1 | (1 << (N - 1))
            x = rng.randrange(m)
            e = rng.getrandbits(N)
            assert modexp(x, e, N, m, N) == pow(x, e, m)
        print(f"Kiem modexp N={N}: 3000 phep dung")
    check_mr_exact()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--N", type=int, default=32)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--stats", type=int, default=0)
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--from-pq", nargs=2, type=int, metavar=("P", "Q"))
    args = ap.parse_args()
    if args.from_pq:
        from_pq(*args.from_pq, N=args.N)
    elif args.check:
        check_bounds()
    elif args.stats:
        cp, ce = [], []
        for s in range(args.stats):
            o = keygen(args.N, seed=s, log=False)
            cp += [o["cand_p"], o["cand_q"]]
            ce.append(o["e_tries"])
        print(f"N={args.N}, {args.stats} khoa: ung vien/so nguyen to TB = "
              f"{sum(cp)/len(cp):.2f}, toi da {max(cp)}; "
              f"so lan do e TB = {sum(ce)/len(ce):.2f}, toi da {max(ce)}")
    else:
        keygen(args.N, seed=args.seed)
