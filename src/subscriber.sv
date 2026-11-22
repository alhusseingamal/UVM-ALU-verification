class alu_subscriber extends uvm_subscriber #(alu_sequence_item);
  /* verilator coverage_off */
  `uvm_component_utils(alu_subscriber)

  alu_sequence_item item;

  covergroup cg;
    option.per_instance = 1;

    op_cp: coverpoint item.opCode {
      bins add     = {4'd0};
      bins sub     = {4'd1};
      bins mul     = {4'd2};
      bins div     = {4'd3};
      bins illegal = {[4'd4:4'd15]};
    }

    rel_cp: coverpoint (item.a < item.b ? 2'd0 : (item.a == item.b ? 2'd1 : 2'd2)) {
      bins a_lt_b = {2'd0};
      bins a_eq_b = {2'd1};
      bins a_gt_b = {2'd2};
    }

    op_x_rel: cross op_cp, rel_cp {
      ignore_bins ignore_illegal = binsof(op_cp.illegal);
    }

    a_cp: coverpoint item.a {
      bins zero = {8'd0};
      bins mid  = {[8'd1:8'd254]};
      bins max  = {8'd255};
    }

    b_cp: coverpoint item.b {
      bins zero = {8'd0};
      bins mid  = {[8'd1:8'd254]};
      bins max  = {8'd255};
    }

    result_cp: coverpoint item.result {
      bins zero      = {16'd0};
      bins low_range = {[16'd1:16'd254]};
      bins max_8bit  = {16'd255};
      bins bad_op    = {16'h00AC};
      bins high_res  = {[16'd256:16'hFE00]};
      bins max_mul   = {16'hFE01};
      bins sub_underflow = {[16'hFF01:16'hFFFF]};
    }

    cout_cp: coverpoint item.cout {
      bins no_carry = {1'b0};
      bins carry    = {1'b1};
    }
  endgroup

  function new(string name = "alu_subscriber", uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction: new

  function void write(alu_sequence_item t);
    item = t;
    cg.sample();
  endfunction: write

endclass: alu_subscriber