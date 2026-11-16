class alu_monitor extends uvm_monitor;
  /* verilator coverage_off */
  `uvm_component_utils(alu_monitor)
  virtual alu_interface vif;
  
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
    alu_sequence_item pending_item = null;

    forever begin
      @(vif.mon_cb);

      // if reset is active, flush the pipeline
      // note: anything other than 1'b1 (1'b0, 1'bx, 1'bz) is regarded as active reset. This handled the unknown reset values at the start of simulation.
      if(vif.mon_cb.reset !== 1'b0) begin  // explictly require reset to be 0 (And not just == 1'b1) to avoid problems when 1'bx is 1'bx
        pending_item = null;
        continue;
      end

      // complete and broadcast the transaction driven on the previous clock edge (if it is valid of course)
      if (pending_item != null) begin
        pending_item.result = vif.mon_cb.result;
        pending_item.cout = vif.mon_cb.cout;
        monitor_port.write(pending_item);
      end

      // capture inputs being latched by the DUT on this clock edge
      pending_item        = alu_sequence_item::type_id::create("pending_item");
      pending_item.reset  = vif.mon_cb.reset;
      pending_item.a      = vif.mon_cb.a;
      pending_item.b      = vif.mon_cb.b;
      pending_item.opCode = vif.mon_cb.opCode;

    end
  endtask: run_phase
  
endclass: alu_monitor