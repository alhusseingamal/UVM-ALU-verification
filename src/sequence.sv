class alu_base_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(alu_base_sequence)  
  alu_sequence_item reset_pkt;
  
  // Constructor  
  function new(string name= "alu_base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Constructor!", UVM_HIGH)
  endfunction
  
  // Body Task
  task body();
    repeat (2) begin  // reset is HIGH held for 2 clock edges
      `uvm_info("BASE_SEQ", "body task!", UVM_HIGH)
      reset_pkt = alu_sequence_item::type_id::create("reset_pkt");
      start_item(reset_pkt);
      if(!(reset_pkt.randomize() with {reset == 1;})) begin // randomization subject to (reset == 1) and to the constraints specified in the item
        `uvm_fatal("RAND_FAIL", "Randomization failed")
      end
      finish_item(reset_pkt);
    end
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
  alu_sequence_item item;

  function new(string name = "alu_illegal_op_sequence");
    super.new(name);
  endfunction

  task body();
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

  task send_vec(logic [3:0] op, logic [7:0] va, logic [7:0] vb);
    alu_sequence_item item = alu_sequence_item::type_id::create("item");
    start_item(item);
    item.reset  = 1'b0;
    item.opCode = op;
    item.a      = va;
    item.b      = vb;
    finish_item(item);
  endtask

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
  endtask: body
endclass: alu_corner_sequence
