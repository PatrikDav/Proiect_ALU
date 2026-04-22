#!/usr/bin/env bash
set -e

IVERILOG=${IVERILOG:-iverilog}
VVP=${VVP:-vvp}

SCRIPT_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ALU_DIR="$SCRIPT_DIR/alu"
BUILD_DIR="$ALU_DIR/build"
OUT="$BUILD_DIR/alu_cli_tb.out"

usage() {
    cat <<EOF
Usage: $(basename "$0") <op> <a> <b>

  <op> : add | sub | mul | div | and | or | xor | sll | sra
  <a>  : 8-bit signed operand  (decimal -128..127, or 0xNN)
  <b>  : 8-bit signed operand  (decimal -128..127, or 0xNN)
         For shifts, only low 3 bits of <b> are used (shift amount 0..7).

Examples:
  $(basename "$0") add 5 3
  $(basename "$0") sub 2 5
  $(basename "$0") mul 16 16
  $(basename "$0") div 7 0
  $(basename "$0") and 0xF0 0x0F
  $(basename "$0") sra -32 2
EOF
    exit 1
}

if [ $# -ne 3 ]; then
    usage
fi

op_name=$(echo "$1" | tr 'A-Z' 'a-z')
case "$op_name" in
    add) op_code=0 ;;
    sub) op_code=1 ;;
    mul) op_code=2 ;;
    div) op_code=3 ;;
    and) op_code=4 ;;
    or)  op_code=5 ;;
    xor) op_code=6 ;;
    sll) op_code=7 ;;
    sra) op_code=8 ;;
    *)   echo "Unknown op: $1"; usage ;;
esac

if ! a_val=$(( $2 )) 2>/dev/null; then
    echo "Invalid operand a: $2"; usage
fi
if ! b_val=$(( $3 )) 2>/dev/null; then
    echo "Invalid operand b: $3"; usage
fi

SOURCES=(
    "$ALU_DIR/src/alu_pkg.sv"
    "$ALU_DIR/src/alu_addsub.sv"
    "$ALU_DIR/src/alu_multiplier.sv"
    "$ALU_DIR/src/alu_divider.sv"
    "$ALU_DIR/src/alu_shifter.sv"
    "$ALU_DIR/src/alu_logic.sv"
    "$ALU_DIR/src/alu.sv"
    "$ALU_DIR/tb/alu_cli_tb.sv"
)

needs_build=0
if [ ! -f "$OUT" ]; then
    needs_build=1
else
    for src in "${SOURCES[@]}"; do
        if [ "$src" -nt "$OUT" ]; then
            needs_build=1
            break
        fi
    done
fi

if [ "$needs_build" = "1" ]; then
    mkdir -p "$BUILD_DIR"
    COMPILE_LOG="$BUILD_DIR/alu_cli_tb.compile.log"
    if ! "$IVERILOG" -g2012 -s alu_cli_tb -o "$OUT" "${SOURCES[@]}" > "$COMPILE_LOG" 2>&1; then
        echo "Compilation failed:"
        cat "$COMPILE_LOG"
        exit 1
    fi
fi

"$VVP" -N "$OUT" "+a=$a_val" "+b=$b_val" "+op=$op_code" 2>&1 \
    | grep -v -E '(\$finish called|sorry:)'
