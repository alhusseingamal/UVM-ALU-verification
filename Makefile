VERILATOR_ROOT ?= $(HOME)/data1/DV/tools/verilator
UVM_ROOT       ?= $(HOME)/data1/DV/tools/uvm/UVM-1800.2-2020.3.1/1800.2-2020.3.1/src
VERILATOR      ?= $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COV  ?= $(VERILATOR_ROOT)/bin/verilator_coverage
BUILD_JOBS     ?= $(shell nproc)
OUTPUT_GROUPS  ?= 24

BUILD_DIR ?= build
OBJ_DIR   := $(BUILD_DIR)/obj_dir
SIM       := $(OBJ_DIR)/Vtop

SV_SOURCES := \
	$(UVM_ROOT)/uvm_pkg.sv \
	src/definitions.sv \
	src/interface.sv \
	src/package.sv \
	src/design.sv \
	src/testbench.sv

SV_DEPS := $(wildcard src/*.sv) coverage.vlt

VERILATOR_FLAGS := \
	--binary \
	--build-jobs $(BUILD_JOBS) \
	--output-groups $(OUTPUT_GROUPS) \
	--timing \
	--timescale 1ns/1ps \
	--trace \
	--coverage \
	coverage.vlt \
	-Wno-fatal \
	--top-module top \
	--Mdir $(OBJ_DIR) \
	+define+UVM_NO_DPI \
	+incdir+$(UVM_ROOT) \
	+incdir+src \
	-MAKEFLAGS "OPT_FAST=-O0"

VERBOSITY ?= UVM_LOW
SIM_ARGS  ?= +UVM_VERBOSITY=$(VERBOSITY) +UVM_NO_RELNOTES

.PHONY: all compile run coverage clean

all: compile

compile: $(SIM)

$(SIM): Makefile $(SV_SOURCES) $(SV_DEPS) | $(BUILD_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) $(SV_SOURCES)

$(BUILD_DIR):
	mkdir -p $@

run: $(SIM)
	rm -f coverage.dat
	./$(SIM) $(SIM_ARGS)

coverage: run
	@echo "=== Verilator Coverage Breakdown (Line / Branch / Expr / Toggle / Covergroup) ==="
	$(VERILATOR_COV) --report summary,hier coverage.dat
	$(VERILATOR_COV) --annotate coverage_report --annotate-all --annotate-points --annotate-min 1 --write-info coverage.info coverage.dat
	@echo "=== LCOV Summary ==="
	lcov --rc branch_coverage=1 --summary coverage.info
	genhtml --branch-coverage coverage.info --output-directory coverage_html

clean:
	rm -rf $(BUILD_DIR) d.vcd coverage.dat coverage.info coverage_report coverage_html