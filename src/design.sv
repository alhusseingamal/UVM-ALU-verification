`timescale 1ns/1ps
module alu(
  input clk,
  input reset,                // Asynchronous active high reset
  input [7:0] A, B,           // ALU 8-bit Inputs                 
  input [3:0] ALUSel,         // ALU Selection
  output reg [15:0] F,        // ALU result
  output logic cout             // Carry Out Flag
);

  reg [15:0] ALU_Result;
  wire [8:0] tmp;

  assign tmp = {1'b0,A} + {1'b0,B};
  
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      F <= 16'd0;
      cout <= 1'd0;
    end
    else begin
      F <= ALU_Result;
      cout <= (ALUSel == 4'b0000 ? tmp[8] : 1'b0);
    end
  end

  always @(*)
    begin
      case(ALUSel)
        4'b0000: ALU_Result = A + B;      // 9-bit sum stored in [8:0], [15:9] = 0
        4'b0001: ALU_Result = A - B;
        4'b0010: ALU_Result = A * B;      // Full 16-bit product
        4'b0011: ALU_Result = A / B;
        default: ALU_Result = 16'h00AC;   // Give out random BAD value
      endcase
    end

endmodule
