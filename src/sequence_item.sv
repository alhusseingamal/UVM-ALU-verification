class alu_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(alu_sequence_item)

  // Instantiation
  rand logic reset;
  rand logic [7:0] a, b;
  rand logic [3:0] opCode;
  
  // Outputs are not randomized of course
  logic [7:0] result;
  bit cout;

  // Required Constraints
  constraint a_ge_b_c {a >= b;}
  constraint opCode_c {opCode inside {[0:3]};} // opcodes from 4 to 15 are reserved
  
  // Constructor
  function new(string name = "alu_sequence_item");
    super.new(name);
  endfunction: new

endclass: alu_sequence_item