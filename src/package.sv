`timescale 1ns/1ps
package alu_package;
    // note: time unit and time precision could also be defined here (that is the more modern approach)
    // timeunit 1ns;
    // timeprecision 1ps;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Include Files
    `include "sequence_item.sv"
    `include "sequence.sv"
    `include "sequencer.sv"
    `include "driver.sv"
    `include "monitor.sv"
    `include "agent.sv"
    `include "scoreboard.sv"
    `include "subscriber.sv"
    `include "env.sv"
    `include "test.sv"
endpackage: alu_package
