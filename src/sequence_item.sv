class alu_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(alu_sequence_item)

  // Instantiation
  rand logic reset;
  rand logic [7:0] a, b;
  rand logic [3:0] opCode;
  
  // Outputs are not randomized of course
  logic [15:0] result;
  logic cout;

  // Required Constraints
  // Soft constraints allow directed sequences to override without constraint_mode(0)
  constraint div_by_zero_c { (opCode == 4'd3) -> (b != 8'd0); }
  constraint valid_op_c {soft opCode inside {[0:3]};}
  constraint a_ge_b_c {a >= b;}
  
  // Constructor
  function new(string name = "alu_sequence_item");
    super.new(name);
  endfunction: new

endclass: alu_sequence_item
