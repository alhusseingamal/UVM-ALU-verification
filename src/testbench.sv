module top;
  import uvm_pkg::*;
  import alu_package::*;
  logic clk;
  alu_interface vif(.clk(clk));
  alu dut(.clk(vif.clk), .reset(vif.reset), .A(vif.a), .B(vif.b), .ALUSel(vif.opCode), .F(vif.result), .cout(vif.cout));
  // Notice the hierarchical path of the signals from the top module, into the interface, and then into the DUT.

  initial begin
    uvm_config_db #(virtual alu_interface)::set(null, "uvm_test_top", "vif", vif);                // Interface Setting
    run_test("alu_test");                                                                         // Start the test
  end

  // Clock Generation
  localparam CLK_PERIOD = 4;
  initial begin
    clk = 0;
    #(CLK_PERIOD/2);
    forever begin
      clk = ~clk;
      #(CLK_PERIOD/2);
    end
  end

  // Maximum Simulation Time
  initial begin
    #5000;
    $display("Sorry! Ran out of clock cycles!");
    $finish();
  end
  
  // Generate Waveforms
  initial begin
    $dumpfile("d.vcd");
    $dumpvars();
  end

endmodule: top