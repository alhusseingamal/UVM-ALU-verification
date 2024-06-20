class alu_driver extends uvm_driver#(alu_sequence_item);
  `uvm_component_utils(alu_driver)  
  virtual alu_interface vif;
  alu_sequence_item item;
  
  // Constructor
  function new(string name = "alu_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Constructor!", UVM_HIGH)
  endfunction: new
  
  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase", UVM_HIGH)
    if(!(uvm_config_db #(virtual alu_interface)::get(this, "", "vif", vif)))
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB! : not set in AGENT_CLASS")
  endfunction: build_phase
  
  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("DRIVER_CLASS", "Connect Phase", UVM_HIGH)  
  endfunction: connect_phase
  
  // Run Phase
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("DRIVER_CLASS", "Run Phase", UVM_HIGH)
    forever begin                                                       // forever keep driving the sequence items
      item = alu_sequence_item::type_id::create("item");                // create a new sequence item
      seq_item_port.get_next_item(item);                                // retrieves the next sequence item from the sequencer, blocks until an item is available
      drive(item);
      seq_item_port.item_done(); // inform the sqncr that the driver has finished processing the current sequence item, allowing the sqncr to send the next sequence item
    end
  endtask: run_phase
  
  // drive the sequence item into the DUT through the virtual interface
  task drive(alu_sequence_item item);
    @(posedge vif.clk);
    vif.reset <= item.reset;
    vif.a <= item.a;
    vif.b <= item.b;
    vif.opCode <= item.opCode;
  endtask: drive

endclass: alu_driver