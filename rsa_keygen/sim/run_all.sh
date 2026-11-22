#!/usr/bin/env bash
# run_all.sh - chay toan bo testbench bang Icarus Verilog (iverilog >= 11)
# Dung:  cd sim && ./run_all.sh          (moi buoc)
#        ./run_all.sh gcd                (chi 1 buoc: gcd inv muldiv modexp trng prime keygen board)
set -e
cd "$(dirname "$0")"
R=../rtl; T=../tb
CORE="$R/gcd_ct.v $R/modinv_ct.v $R/mul_seq.v $R/divmod_seq.v $R/montmul.v $R/modexp.v"
TRNG="$R/trng_ro.v $R/trng_health.v $R/trng_post.v $R/trng_top.v"
run() { echo; echo "### $1"; iverilog -g2012 -o "$1.vvp" "${@:2}" && vvp -n "$1.vvp" | grep -v '\$finish'; }
want() { [ -z "$1" ] || [ "$1" = "$2" ]; }

if want "$1" gcd;    then for n in 8 32; do run gcd_N$n -P tb_gcd_ct.N=$n $R/gcd_ct.v $T/tb_gcd_ct.v; done; fi
if want "$1" inv;    then for n in 16 32; do run inv_N$n -P tb_modinv_ct.N=$n $R/modinv_ct.v $T/tb_modinv_ct.v; done; fi
if want "$1" muldiv; then run muldiv_N32 $R/mul_seq.v $R/divmod_seq.v $T/tb_mul_div.v; fi
if want "$1" modexp; then for n in 16 32; do run modexp_N$n -P tb_modexp.N=$n $R/montmul.v $R/modexp.v $T/tb_modexp.v; done; fi
if want "$1" trng;   then run trng $TRNG $T/tb_trng.v; fi
if want "$1" prime;  then run prime_gen $R/gcd_ct.v $R/montmul.v $R/modexp.v $TRNG $R/prime_gen.v $T/tb_prime_gen.v; fi
if want "$1" keygen; then
    run keygen_N16 -P tb_rsa_keygen.N=16 $CORE $TRNG $R/prime_gen.v $R/rsa_keygen.v $T/tb_rsa_keygen.v
    run keygen_N32 -P tb_rsa_keygen.N=32 -P tb_rsa_keygen.NKEY=6 $CORE $TRNG $R/prime_gen.v $R/rsa_keygen.v $T/tb_rsa_keygen.v
fi
if want "$1" board;  then run board $CORE $TRNG $R/prime_gen.v $R/rsa_keygen.v $R/uart_tx.v $R/debounce.v $R/board_top.v $T/tb_board_top.v; fi
