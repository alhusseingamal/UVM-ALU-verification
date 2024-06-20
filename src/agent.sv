class alu_agent extends uvm_agent;
  `uvm_component_utils(alu_agent)

  virtual alu_interface vif;
  
  alu_sequencer seqr;
  alu_driver drv;
  alu_monitor mon;

  // Constructor
  function new(string name = "alu_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("AGENT_CLASS", "Constructor!", UVM_HIGH)
  endfunction: new

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT_CLASS", "Build Phase", UVM_HIGH)
    seqr = alu_sequencer::type_id::create("seqr", this);
    drv = alu_driver::type_id::create("drv", this);
    mon = alu_monitor::type_id::create("mon", this);

    if(!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
      `uvm_error("AGENT_CLASS", "Failed to get VIF from config DB! : not set in ENV_CLASS")
    uvm_config_db#(virtual alu_interface)::set(this, "drv", "vif", vif);
    uvm_config_db#(virtual alu_interface)::set(this, "mon", "vif", vif);
  endfunction: build_phase

  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("AGENT_CLASS", "Connect Phase", UVM_HIGH)
    drv.seq_item_port.connect(seqr.seq_item_export); // seq_item_port is a TLM port defined by default
  endfunction: connect_phase

  // Run Phase
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase
  
endclass: alu_agent