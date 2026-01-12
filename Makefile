# Makefile for RISC-V Pipeline Processor

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = surfer

# Files
# Pipeline Implementation
SRC = src/rv_pl.v \
      src/controller.v \
      src/alu.v \
      src/reg_file.v \
      src/adder.v \
      src/sign_extend.v \
      src/mux.v \
      src/inst_mem.v \
      src/data_mem.v \
      src/hazard_unit.v \
      src/alu_decoder.v

TB = testbench/rv_pl_tb.v
OUT = rv_pl_test
VCD = rv_pl_test.vcd

# Targets
.PHONY: all compile run wave clean

all: compile run

compile:
	$(IVERILOG) -I src -o $(OUT) $(TB) $(SRC)

run: compile
	$(VVP) $(OUT)

wave: run
	$(GTKWAVE) $(VCD)

clean:
	rm -f $(OUT) $(VCD)
