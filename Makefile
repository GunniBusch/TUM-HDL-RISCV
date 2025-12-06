# Makefile for RISC-V Processor

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = surfer

# Files
SRC = src/*.v
TB = testbench/riscv_top_tb.v
OUT = riscv_test
VCD = riscv_test.vcd

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
