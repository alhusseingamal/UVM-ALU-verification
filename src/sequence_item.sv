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
  // - note: this is a soft constraint; it can be overriden in case of conflict with 
  // a higher priority inline constraint like the one in alu_illegal_op_sequence
  // - note: if two hard constraints (constraints are hard by default; 'soft' is not specified), 
  // randomization fails, and UVM returns a fatal error
  
  // Constructor
  function new(string name = "alu_sequence_item");
    super.new(name);
  endfunction: new

endclass: alu_sequence_item
