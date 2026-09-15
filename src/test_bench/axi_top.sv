`include "uvm_macros.svh"
`include "defines.svh"
`include "axi_pkg.sv"
`include "axi_inf.sv"

import uvm_pkg::*;
import axi_pkg::*;

module axi_top;

  bit aclk;
  bit aresetn;

  initial begin
    aclk = 0;
    forever #5 aclk = ~aclk;
  end

  initial begin
    aresetn = 0;
    repeat(4) @(posedge aclk);   // Hold reset for a few clock cycles
    aresetn = 1;
  end

  axi_inf #(
    .AW(`AW),
    .DW(`DW)
  ) vif (
    .aclk    (aclk),
    .aresetn (aresetn)
  );

  axi4_lite_slave #(
    .DATA_WIDTH   (`DW),
    .ADDR_WIDTH   (`AW),
    .MEM_DEPTH    (16),
    .DEFAULT_PROT (3'b000)
  ) DUT (
    .ACLK     (aclk),
    .ARESETn  (aresetn),
    .AWADDR   (vif.AWADDR),
    .AWPROT   (vif.AWPROT),
    .AWVALID  (vif.AWVALID),
    .AWREADY  (vif.AWREADY),
    .WDATA    (vif.WDATA),
    .WSTRB    (vif.WSTRB),
    .WVALID   (vif.WVALID),
    .WREADY   (vif.WREADY),
    .BRESP    (vif.BRESP),
    .BVALID   (vif.BVALID),
    .BREADY   (vif.BREADY),
    .ARADDR   (vif.ARADDR),
    .ARPROT   (vif.ARPROT),
    .ARVALID  (vif.ARVALID),
    .ARREADY  (vif.ARREADY),
    .RDATA    (vif.RDATA),
    .RRESP    (vif.RRESP),
    .RVALID   (vif.RVALID),
    .RREADY   (vif.RREADY)
  );

  initial begin
    uvm_config_db #(virtual axi_inf.drv_mod)::set(null, "*", "vif", vif);
    uvm_config_db #(virtual axi_inf.ipm_mod)::set(null, "*", "vif", vif);
    uvm_config_db #(virtual axi_inf.opm_mod)::set(null, "*", "vif", vif);

    run_test();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, axi_top);
  end

  initial begin
    $display("TIMEOUT TEST: simulation started");
    uvm_top.set_timeout(50000ns, 1);
    $display("UVM TIMEOUT SET TO 50000ns");
  end

endmodule
