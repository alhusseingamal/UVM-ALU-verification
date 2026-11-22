class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)

  virtual alu_interface vif;

  alu_env env;

  // Sequences
  alu_reset_sequence reset_seq, mid_reset_seq;
  alu_test_sequence test_seq;
  alu_illegal_op_sequence illegal_seq;
  alu_corner_sequence corner_seq;

  // Constructor
  function new(string name = "alu_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TEST_CLASS", "Constructor!", UVM_HIGH)
  endfunction: new

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST_CLASS", "Build Phase", UVM_HIGH)
    env = alu_env::type_id::create("env", this);
    if(!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
      `uvm_error("TEST_CLASS", "Failed to get VIF from config DB! : not set in testbench top level")
    uvm_config_db#(virtual alu_interface)::set(this, "env", "vif", vif);
  endfunction: build_phase

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST_CLASS", "Connect Phase", UVM_HIGH)
  endfunction: connect_phase
  
  // Run Phase
  task run_phase (uvm_phase phase);
    uvm_objection objection;
    super.run_phase(phase);
    `uvm_info("TEST_CLASS", "Run Phase", UVM_HIGH)

    // once all sequences drop their objections, let the clock run for 20 time units
    // so the final transaction has enough time to exit the pipeline and get checked by scoreboard
    // Note: this line configures what UVM should do when the objection is dropped; 
    //        it does not start the delay at the point where it is called.
    // This is the new standard way to do it in contrast to the less preferred method of #20ns at the end of run_phase
    // or the deprecated phase.phase_done.set_drain_time(this, 20);

    objection = phase.get_objection();
    if (objection != null) begin
      objection.set_drain_time(this, 20ns);
    end

    phase.raise_objection(this);

    // note: the task in format sequence.start(sequencer) is a blocking task that doesn't 
    // return until the sequence's body() finishes driving all its items.

    // reset_seq: assert reset for 2 clock cycles (the 2 defined in sequence.sv for reset sequence)
    reset_seq = alu_reset_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agnt.seqr); // specify the sequencer to send the sequence to

    // corner_seq: a curated set of vectors that aims to trigger each bit toggle (0->1 and 1->0) in A,B, ALUSel, F, ALUResult, tmp and cout
    // without this, many edge cases are never triggered by test_seq
    corner_seq = alu_corner_sequence::type_id::create("corner_seq");
    corner_seq.start(env.agnt.seqr);
    
    // test_seq: drive back-to-back transactions
    test_seq = alu_test_sequence::type_id::create("test_seq");
    test_seq.start(env.agnt.seqr);

    // mid_reset_seq: mid-run reset check to ensure reset toggles
    mid_reset_seq = alu_reset_sequence::type_id::create("mid_reset_seq");
    mid_reset_seq.start(env.agnt.seqr);

    // illegal_seq: drive reserved opcodes
    illegal_seq = alu_illegal_op_sequence::type_id::create("illegal_seq");
    illegal_seq.start(env.agnt.seqr);

    // Allow the last transaction to complete pipeline stages and reach scoreboard
    // #20ns;  // OLD method: left for illustration

    phase.drop_objection(this);
  endtask: run_phase

endclass: alu_test
