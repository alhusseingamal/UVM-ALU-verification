class alu_subscriber extends uvm_subscriber #(alu_sequence_item);
    `uvm_component_utils(alu_subscriber)
    alu_sequence_item item;

    covergroup cg;
        option.per_instance = 1;                                       // coverage is per instance
        result : coverpoint item.result{
            bins bin_1[] = {0, 255};                                   // coverage of values 0 and 255
        }
        cout : coverpoint item.cout{
            bins bin_1[] = {0, 1};                                     // coverage of values 0 and 1
        }
    endgroup

    function void write(alu_sequence_item t);
        item = t;
        cg.sample();
    endfunction: write 

    // Constructor
    function new(string name = "alu_subscriber", uvm_component parent);
        super.new(name, parent);
        `uvm_info("SUB_CLASS", "Constructor!", UVM_HIGH)
        cg = new();
    endfunction: new

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("SUB_CLASS", "Build Phase", UVM_HIGH)
        item = alu_sequence_item::type_id::create("item");
    endfunction: build_phase

    // Connect Phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("SUB_CLASS", "Connect Phase", UVM_HIGH)
    endfunction: connect_phase

    // Run Phase
    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("SUB_CLASS", "Run Phase", UVM_HIGH)
    endtask: run_phase

endclass: alu_subscriber