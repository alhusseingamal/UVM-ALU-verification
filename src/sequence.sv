class alu_base_sequence extends uvm_sequence;
  `uvm_object_utils(alu_base_sequence)  
  alu_sequence_item reset_pkt;
  
  // Constructor  
  function new(string name= "alu_base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Constructor!", UVM_HIGH)
  endfunction
  
  // Body Task
  task body();
    `uvm_info("BASE_SEQ", "body task!", UVM_HIGH)
    reset_pkt = alu_sequence_item::type_id::create("reset_pkt");
    start_item(reset_pkt);
    if(!(reset_pkt.randomize() with {reset == 1;})) begin // randomization subject to (reset == 1) and to the constraints specified in the item
      `uvm_fatal("RAND_FAIL", "Randomization failed")
    end
    finish_item(reset_pkt);
  endtask: body
endclass: alu_base_sequence

class alu_test_sequence extends alu_base_sequence;
  `uvm_object_utils(alu_test_sequence)
  alu_sequence_item item;
  
  // Constructor
  function new(string name= "alu_test_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Constructor!", UVM_HIGH)
  endfunction
  
  // Body Task : overrides the body task of the base sequence
  task body();
    `uvm_info("TEST_SEQ", "body task!", UVM_HIGH)
    item = alu_sequence_item::type_id::create("item");
    start_item(item);
    if(!(item.randomize() with {reset == 0;})) begin
      `uvm_fatal("RAND_FAIL", "Randomization failed")
    end
    finish_item(item);
  endtask: body
  
endclass: alu_test_sequence