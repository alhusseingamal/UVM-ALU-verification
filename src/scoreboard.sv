class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)
  
  uvm_analysis_imp #(alu_sequence_item, alu_scoreboard) scoreboard_port; // port to receive data from monitor
  alu_sequence_item transactions[$]; // variable-size queue to store transactions

  int match_count = 0;
  int mismatch_count = 0;
  
  // Constructor
  function new(string name = "alu_scoreboard", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SCB_CLASS", "Constructor!", UVM_HIGH)
  endfunction: new
  
  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCB_CLASS", "Build Phase", UVM_HIGH)
    scoreboard_port = new("scoreboard_port", this);
  endfunction: build_phase
  
  // Connect Phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SCB_CLASS", "Connect Phase", UVM_HIGH)
  endfunction: connect_phase
  
  // Write Method : this defines what to do with the data received from monitor, in this case, store it in a queue
  function void write(alu_sequence_item item);
    transactions.push_back(item);
  endfunction: write 
  
  // Run Phase
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCB_CLASS", "Run Phase", UVM_HIGH)
    forever begin // get the packet, generate expected value, compare it with actual value, score the transactions accordingly
      alu_sequence_item curr_trans;
      wait((transactions.size() != 0));
      curr_trans = transactions.pop_front();
      compare(curr_trans);
    end  
  endtask: run_phase
  
  // Compare : Generate expected results and compare with actual results
  function void compare(alu_sequence_item curr_trans);
    logic [8:0] temp;
    logic [15:0] expectedResult;
    logic expectedCout;
    
    case(curr_trans.opCode)                           // generate the expected result
      0: begin
        temp = curr_trans.a + curr_trans.b;
        expectedResult = {7'b0, temp};
        expectedCout = temp[8];
      end
      1: begin
        expectedResult = 16'(curr_trans.a) - 16'(curr_trans.b);
        expectedCout = 1'b0;
      end
      2: begin
        expectedResult = curr_trans.a * curr_trans.b;
        expectedCout = 1'b0;
      end
      3: begin
        expectedResult = curr_trans.a / curr_trans.b;
        expectedCout = 1'b0;
      end
      default: begin
        expectedResult = 16'h00AC;
        expectedCout= 1'b0;
      end
    endcase
    
    if (curr_trans.result !== expectedResult || curr_trans.cout !== expectedCout) begin
    `uvm_error("COMPARE", $sformatf(
      "FAIL: op=%0d a=%0d b=%0d | Act: res=%0h cout=%b | Exp: res=%0h cout=%b",
      curr_trans.opCode, curr_trans.a, curr_trans.b,
      curr_trans.result, curr_trans.cout, expectedResult, expectedCout))
      mismatch_count++;
    end else begin
      match_count++;
    end

  endfunction: compare


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB", $sformatf("--- SCOREBOARD SUMMARY: %0d transactions verified successfully, %0d transactions failed ---", match_count, mismatch_count), UVM_NONE)
  endfunction: report_phase

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (transactions.size() != 0) begin
      `uvm_error("SCB", $sformatf(
        "Queue not drained: %0d transactions remain unprocessed",
        transactions.size()))
    end

    if (match_count == 0) begin
      `uvm_error("SCB", "No transactions were verified successfully")
    end
  endfunction: check_phase
  
endclass: alu_scoreboard
