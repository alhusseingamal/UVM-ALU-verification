class alu_monitor extends uvm_monitor;
  `uvm_component_utils(alu_monitor)
  virtual alu_interface vif;
  alu_sequence_item item;
  
  uvm_analysis_port #(alu_sequence_item) monitor_port; // transmit data to the scoreboard
  
  // Constructor
  function new(string name = "alu_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info("MONITOR_CLASS", "Constructor!", UVM_HIGH)
  endfunction: new
  
  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MONITOR_CLASS", "Build Phase!", UVM_HIGH)
    monitor_port = new("monitor_port", this);  
    if(!(uvm_config_db #(virtual alu_interface)::get(this, "", "vif", vif)))
      `uvm_error("MONITOR_CLASS", "Failed to get VIF from config DB! : not set in AGENT_CLASS")
  endfunction: build_phase
  
  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("MONITOR_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
  
  // Run Phase
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("MONITOR_CLASS", "Run Phase!", UVM_HIGH)
    forever begin
      item = alu_sequence_item::type_id::create("item");
      wait(!vif.reset); // We don't want to monitor during reset, and we may not know the behavior of the DUT during reset
      // sample inputs : notice the use of blocking assignments
      @(posedge vif.clk);
      item.a = vif.a;
      item.b = vif.b;
      item.opCode = vif.opCode;

      // sample output
      @(posedge vif.clk);
      item.result = vif.result;
      
      // send item to scoreboard
      monitor_port.write(item);
    end
  endtask: run_phase
  
endclass: alu_monitor