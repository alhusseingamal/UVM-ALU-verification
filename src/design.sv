module alu(
  input clk,
  input reset,                // Asynchronous active high reset
  input [7:0] A, B,           // ALU 8-bit Inputs                 
  input [3:0] ALUSel,         // ALU Selection
  output reg [7:0] F,         // ALU 8-bit Output
  output bit cout             // Carry Out Flag
);

  reg [7:0] ALU_Result;
  wire [8:0] tmp;

  assign tmp = {1'b0,A} + {1'b0,B};
  
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      F <= 8'd0;
      cout <= 1'd0;
    end
    else begin
      F <= ALU_Result;
      cout <= tmp[8];
    end
  end

  always @(*)
    begin
      case(ALUSel)
        4'b0000: // Addition
          ALU_Result = A + B ; 
        4'b0001: // Subtraction
          ALU_Result = A - B ;
        4'b0010: // Multiplication
          ALU_Result = A * B;
        4'b0011: // Division
          ALU_Result = A/B;
        default: ALU_Result = 8'hAC ; // Give out random BAD value
      endcase
    end

endmodule