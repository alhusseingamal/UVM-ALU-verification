interface alu_interface(input logic clk);

  logic reset;

  logic [7:0] a, b;
  logic [3:0] opCode;
  logic [7:0] result;
  bit cout;

endinterface: alu_interface