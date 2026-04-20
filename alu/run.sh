#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Convenience script to compile and run the ALU testbench without `make`.
# Equivalent to `make all`. Use this when only iverilog is available
# (e.g. on a bare MSYS2/Windows install).
# -----------------------------------------------------------------------------
set -e

IVERILOG=${IVERILOG:-iverilog}
VVP=${VVP:-vvp}

SCRIPT_DIR=$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

SRC_DIR=src
TB_DIR=tb
BUILD_DIR=build
SIM_DIR=sim

mkdir -p "$BUILD_DIR" "$SIM_DIR"

# Order matters for packages: alu_pkg.sv must come before files that import it.
SOURCES=(
  "$SRC_DIR/alu_pkg.sv"
  "$SRC_DIR/alu_addsub.sv"
  "$SRC_DIR/alu_multiplier.sv"
  "$SRC_DIR/alu_divider.sv"
  "$SRC_DIR/alu_shifter.sv"
  "$SRC_DIR/alu_logic.sv"
  "$SRC_DIR/alu.sv"
  "$TB_DIR/alu_tb.sv"
)

echo "Compiling..."
"$IVERILOG" -g2012 -s alu_tb -o "$BUILD_DIR/alu_tb.out" "${SOURCES[@]}"

echo "Running alu_tb..."
"$VVP" "$BUILD_DIR/alu_tb.out" | tee "$SIM_DIR/alu_tb.log"

# Move generated VCD into sim/ so source tree stays clean.
if [ -f alu_tb.vcd ]; then
    mv alu_tb.vcd "$SIM_DIR/"
fi

echo ""
echo "Done. Log:     $SIM_DIR/alu_tb.log"
echo "      Waveform: $SIM_DIR/alu_tb.vcd  (open with gtkwave)"
