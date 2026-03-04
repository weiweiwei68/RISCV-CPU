# --- Parameters ---
SIM      = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

# --- Folders ---
SRC_DIR   = rtl
TB_DIR    = tb
BUILD_DIR = build

# --- Target Files ---
TOP_MODULE = cpu_top
TB_MODULE  = MultiCycle_tb

# --- Source Files ---
# Use 'wildcard' to automatically find all .v files in the rtl folder
SRC_FILES = $(wildcard $(SRC_DIR)/*.v)
TB_FILE   = $(TB_DIR)/$(TB_MODULE).v

# --- Output Files ---
# The final executable simulation file
SIM_FILE  = $(BUILD_DIR)/$(TB_MODULE)
# The waveform file
# VCD_FILE  = $(BUILD_DIR)/$(TOP_MODULE).vcd

# --- Rules ---
.PHONY: all compile run clean help

all: compile run

compile: 
	@echo "Compiling Verilog..."
	@mkdir -p $(BUILD_DIR)
	$(SIM) -o $(SIM_FILE) $(TB_FILE) $(SRC_FILES)

run: 
	@echo "Running Simulation..."
	$(VVP) $(SIM_FILE)

clean:
	rm -rf $(BUILD_DIR)
	@echo "Cleaned build files..."

help:
	@echo "Available commands:"
	@echo "  make compile  - Compile Verilog files"
	@echo "  make run      - Run simulation"
	@echo "  make clean    - Remove build files"
	@echo "  make help     - Show this message"