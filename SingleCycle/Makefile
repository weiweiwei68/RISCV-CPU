# Makefile for Single-Cycle CPU
# Compiler and Simulator
VC = iverilog
SIM = vvp

# Directories
RTL_DIR = rtl
TB_DIR = tb

# Targets
all: test_alu test_decoder test_regfile test_pc test_imm_gen test_fetch test_cpu

test_alu:
	$(VC) -I $(RTL_DIR) -o alu_tb.out $(RTL_DIR)/alu.v $(TB_DIR)/alu_tb.v
	$(SIM) alu_tb.out

test_decoder:
	$(VC) -I $(RTL_DIR) -o decoder_tb.out $(RTL_DIR)/decoder.v $(TB_DIR)/decoder_tb.v
	$(SIM) decoder_tb.out

test_regfile:
	$(VC) -I $(RTL_DIR) -o regfile_tb.out $(RTL_DIR)/regfile.v $(TB_DIR)/regfile_tb.v
	$(SIM) regfile_tb.out

test_pc:
	$(VC) -I $(RTL_DIR) -o pc_tb.out $(RTL_DIR)/pc.v $(TB_DIR)/pc_tb.v
	$(SIM) pc_tb.out

test_imm_gen:
	$(VC) -I $(RTL_DIR) -o imm_gen_tb.out $(RTL_DIR)/imm_gen.v $(TB_DIR)/imm_gen_tb.v
	$(SIM) imm_gen_tb.out

test_fetch:
	$(VC) -I $(RTL_DIR) -o fetch_tb.out $(RTL_DIR)/pc.v $(RTL_DIR)/imem.v $(RTL_DIR)/fetch_top.v $(TB_DIR)/fetch_tb.v
	$(SIM) fetch_tb.out

test_cpu:
	$(VC) -I $(RTL_DIR) -o cpu_tb.out $(RTL_DIR)/*.v $(TB_DIR)/cpu_tb.v
	$(SIM) cpu_tb.out

clean:
	rm -f *.out *.vcd

.PHONY: all test_alu test_decoder test_regfile test_pc test_imm_gen test_fetch test_cpu clean
