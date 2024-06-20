vlog package.sv testbench.sv interface.sv design.sv +cover
vsim top -coverage +UVM_TESTNAME=alu_test
add wave -position insertpoint sim:/top/vif/*
run -all; coverage report -codeall -cvg -verbose -output coverage_report.txt