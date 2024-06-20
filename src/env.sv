class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)

  virtual alu_interface vif;

  alu_agent agnt;
  alu_scoreboard scb;
  alu_subscriber sub;

  //Constructor
  function new(string name = "alu_env", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ENV_CLASS", "Constructor!", UVM_HIGH)
  endfunction: new

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV_CLASS", "Build Phase", UVM_HIGH)
    agnt = alu_agent::type_id::create("agnt", this);
    scb = alu_scoreboard::type_id::create("scb", this);
    sub = alu_subscriber::type_id::create("sub", this);

    if(!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
      `uvm_error("ENV_CLASS", "Failed to get VIF from config DB! : not set in TEST_CLASS")
    uvm_config_db#(virtual alu_interface)::set(this, "agnt", "vif", vif);
  endfunction: build_phase
  
  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS", "Connect Phase", UVM_HIGH)
    agnt.mon.monitor_port.connect(scb.scoreboard_port); // connect monitor to scoreboard through the created port scoreboard_port
    agnt.mon.monitor_port.connect(sub.analysis_export); // connect monitor to subscriber through the default port analysis_export
  endfunction: connect_phase
  
  // Run Phase
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase
    
endclass: alu_env