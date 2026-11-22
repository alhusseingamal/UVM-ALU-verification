// Pure base class: holds shared helper tasks, no stimulus in body()
virtual class alu_base_sequence extends uvm_sequence #(alu_sequence_item);
  // `uvm_object_utils(alu_base_sequence)
  /*
  Under the hood, `uvm_object_utils(alu_base_sequence) registers uvm_object_registry#(alu_base_sequence), 
  which implements create_object() by calling obj = new(name);. Because alu_base_sequence is declared virtual, 
  calling new() on it is illegal in SystemVerilog and triggers an abstract-class instantiation error at compile time.
  */
  
  // Constructor
  function new(string name= "alu_base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Constructor!", UVM_HIGH)
  endfunction

  task send_vec(logic [3:0] op, logic [7:0] va, logic [7:0] vb, logic rst = 1'b0);
    alu_sequence_item item = alu_sequence_item::type_id::create("item");
    start_item(item);
    item.reset  = rst;
    item.opCode = op;
    item.a      = va;
    item.b      = vb;
    finish_item(item);
  endtask
  
  // Body Task
  virtual task body();
      `uvm_info("BASE_SEQ", "body task!", UVM_HIGH)
  endtask: body
endclass: alu_base_sequence


class alu_reset_sequence extends alu_base_sequence;
  `uvm_object_utils(alu_reset_sequence)  

  // Constructor  
  function new(string name= "alu_reset_sequence");
    super.new(name);
    `uvm_info("RESET_SEQ", "Constructor!", UVM_HIGH)
  endfunction
  
  // Body Task
  task body();
    alu_sequence_item reset_pkt;
    repeat (2) begin  // reset is held HIGH for 2 clock edges
      `uvm_info("RESET_SEQ", "body task!", UVM_HIGH)
      reset_pkt = alu_sequence_item::type_id::create("reset_pkt");
      start_item(reset_pkt);
      if(!(reset_pkt.randomize() with {reset == 1;})) begin // randomization subject to (reset == 1) and to the constraints specified in the item
        `uvm_fatal("RAND_FAIL", "Randomization failed")
      end
      finish_item(reset_pkt);
    end
  endtask: body
endclass: alu_reset_sequence



class alu_test_sequence extends alu_base_sequence;
  `uvm_object_utils(alu_test_sequence)
  
  // Constructor
  function new(string name= "alu_test_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Constructor!", UVM_HIGH)
  endfunction
  
  // Body Task : overrides the body task of the base sequence
  task body();
    alu_sequence_item item;
    repeat (200) begin
      `uvm_info("TEST_SEQ", "body task!", UVM_HIGH)
      item = alu_sequence_item::type_id::create("item");
      start_item(item);
      if(!(item.randomize() with {reset == 0;})) begin
        `uvm_fatal("RAND_FAIL", "Randomization failed")
      end
      finish_item(item);
    end
  endtask: body
  
endclass: alu_test_sequence




class alu_illegal_op_sequence extends alu_base_sequence;
  `uvm_object_utils(alu_illegal_op_sequence)

  function new(string name = "alu_illegal_op_sequence");
    super.new(name);
  endfunction

  task body();
    alu_sequence_item item;
    repeat (20) begin
      item = alu_sequence_item::type_id::create("item");
      start_item(item);
      // Overrides the 'soft' valid_op_c constraint cleanly!
      if (!(item.randomize() with { reset == 0; opCode inside {[4:15]}; }))
        `uvm_fatal("RAND_FAIL", "Randomization failed")
      finish_item(item);
    end
  endtask: body
endclass: alu_illegal_op_sequence




class alu_corner_sequence extends alu_base_sequence;
  `uvm_object_utils(alu_corner_sequence)

  function new(string name = "alu_corner_sequence");
    super.new(name);
  endfunction

  task body();
    send_vec(4'd2, 8'hFF, 8'hFF); // MUL max: F = 16'hFE01 (sets F[15:9], F[0], tmp[8:1])
    send_vec(4'd0, 8'hFF, 8'h01); // ADD carry: F = 16'h0100, cout = 1 (sets F[8], cout)
    send_vec(4'd0, 8'hFF, 8'h00); // ADD 255: F = 16'h00FF, cout = 0 (sets F[7:0], tmp[0])
    send_vec(4'd0, 8'h00, 8'h00); // ADD zero: F = 16'h0000 (clears A, B, F, tmp)
    send_vec(4'd1, 8'hFF, 8'h00); // SUB 255: F = 16'h00FF
    send_vec(4'd1, 8'hAA, 8'hAA); // SUB zero: F = 16'h0000 (non-ADD with tmp[8]=1)
    send_vec(4'd3, 8'hFF, 8'h01); // DIV 255: F = 16'h00FF
    send_vec(4'd3, 8'h05, 8'h05); // DIV 1: F = 16'h0001 (non-ADD with tmp[8]=0)
    send_vec(4'hF, 8'h80, 8'h80); // Illegal op 4'b1111: F = 16'h00AC (sets ALUSel=4'hF)
    send_vec(4'd0, 8'h00, 8'h00); // ADD zero: clears ALUSel=4'h0 and F=16'h0000
    send_vec(4'd1, 8'h00, 8'hFF); // SUB underflow: F = 16'hFF01 (sets F[15:8])
    send_vec(4'd3, 8'h01, 8'h02); // DIV zero quotient: F = 16'h0000
  endtask: body
endclass: alu_corner_sequence
