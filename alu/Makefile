IVERILOG := iverilog
VVP      := vvp

# Flags
IVERILOG_FLAGS := -Wall -g2012 -Isrc
VVP_FLAGS      := -v -l sim/log

# Directories
BUILD_DIR := build
VCD_DIR   := sim
SRC_DIR   := src
TB_DIR    := tb

# All design source files. The package must be listed first so its
# definitions are visible when compiling modules that import it.
VERILOG_SOURCES := \
	$(SRC_DIR)/alu_pkg.sv \
	$(SRC_DIR)/alu_addsub.sv \
	$(SRC_DIR)/alu_multiplier.sv \
	$(SRC_DIR)/alu_divider.sv \
	$(SRC_DIR)/alu_shifter.sv \
	$(SRC_DIR)/alu_logic.sv \
	$(SRC_DIR)/alu.sv

# Testbenches to build and run (name matches the top module in the .sv file).
TESTBENCHES := alu_tb

.PHONY: all prepare clean build-cli
all: prepare $(TESTBENCHES)

build-cli: prepare $(BUILD_DIR)/alu_cli_tb.out

prepare:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(VCD_DIR)

# Compile each testbench together with all design sources.
$(BUILD_DIR)/%.out: $(TB_DIR)/%.sv $(VERILOG_SOURCES)
	@echo "Compiling $< (and dependencies) -> $@"
	$(IVERILOG) $(IVERILOG_FLAGS) -s $(*F) $(VERILOG_SOURCES) $< -o $@

# Run the compiled testbench, capture the log, and move any generated VCD.
run_%: $(BUILD_DIR)/%.out
	@echo "Running $(*F)"
	$(VVP) $< $(VVP_FLAGS) > $(VCD_DIR)/$*.log
	@if [ -f $*.vcd ]; then mv $*.vcd $(VCD_DIR)/; fi
	@cat $(VCD_DIR)/$*.log

$(TESTBENCHES): %: run_%

clean:
	rm -rf $(BUILD_DIR) $(VCD_DIR)
