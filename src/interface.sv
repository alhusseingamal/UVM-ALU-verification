`timescale 1ns/1ps
`include "definitions.sv"
interface alu_interface(input logic clk);

  logic reset;

  logic [7:0] a, b;
  logic [3:0] opCode;
  logic [15:0] result;
  logic cout; // bit type masks X/Z states to 0, so logic is necessary


  // Driver drives its outputs DRIVER_SKEW after posedge clk
  clocking drv_cb @(posedge clk);
    default input #1step output #`DRIVER_SKEW;
    output reset, a, b, opCode;
  endclocking

  // Monitor samples 1step before posedge clk (stable preponed values)
  // Note: the 1step is exactly the time precision specified (e.g. 1ps if timescale is defined as `timescale 1ns/1ps)
  clocking mon_cb @(posedge clk);
    default input #1step output #`MONITOR_SKEW;
    input reset, a, b, opCode, result, cout; // monitored/sampled 1 simulation step before posedge clk
  endclocking

endinterface: alu_interface
