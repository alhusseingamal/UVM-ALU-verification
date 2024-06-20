class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)
  
  uvm_analysis_imp #(alu_sequence_item, alu_scoreboard) scoreboard_port; // port to receive data from monitor
  alu_sequence_item transactions[$]; // variable-size queue to store transactions
  
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
  task compare(alu_sequence_item curr_trans);
    logic [8:0] temp;
    logic [15:0] expectedResult;
    logic [7:0] actualResult;
    bit expectedCout, actualCout;
    actualResult = curr_trans.result;                       // sample the actual result
    actualCout = curr_trans.cout;
    
    case(curr_trans.opCode)                           // generate the expected result
      0: begin
        temp = curr_trans.a + curr_trans.b;
        expectedResult = temp[7:0];
        expectedCout = temp[8];
      end
      1: begin
        expectedResult = curr_trans.a - curr_trans.b;
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
    endcase
    
    if({8'b0, actualResult} != expectedResult) begin
      `uvm_error("COMPARE", $sformatf("Transaction failed!\noperandA = %d, operandB = %d, opCode = %d\nactual result = %d, expected result = %d",
      curr_trans.a, curr_trans.b, curr_trans.opCode, actualResult, expectedResult))
    end
    else if (actualCout != expectedCout) begin
      `uvm_error("COMPARE", $sformatf("Transaction failed!\noperandA = %d, operandB = %d, opCode = %d\nactual cout = %d, expected cout = %d",
      curr_trans.a, curr_trans.b, curr_trans.opCode, actualCout, expectedCout))
    end
    else begin
      `uvm_info("COMPARE", $sformatf("Transaction Passed!\nnoperandA = %d, operandB = %d, opCode = %d\nactual result = %d, expected result = %d\nactual cout = %d, expected cout = %d",
      curr_trans.a, curr_trans.b, curr_trans.opCode, actualResult, expectedResult, actualCout, expectedCout), UVM_LOW)
    end
  endtask: compare
  
endclass: alu_scoreboard