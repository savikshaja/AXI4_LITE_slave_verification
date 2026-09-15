interface axi_inf #(parameter AW = 32, parameter DW = 32) (input bit aclk, aresetn);

  logic [AW-1:0]      AWADDR;
  logic [DW-1:0]      WDATA;
  logic [(DW/8-1):0]  WSTRB;
  logic               AWVALID, WVALID, ARVALID;
  logic [2:0]         AWPROT, ARPROT;
  logic               BREADY;
  logic [AW-1:0]      ARADDR;
  logic               RREADY;

  logic               AWREADY, WREADY, ARREADY;
  logic [DW-1:0]      RDATA;
  logic [1:0]         BRESP, RRESP;
  logic               RVALID, BVALID;

  clocking drv_cb @(posedge aclk);
    default input #1;
    default output #1;
    input  AWREADY, WREADY, ARREADY, BVALID, RVALID;
    output AWADDR, AWPROT, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, ARPROT, RREADY;
  endclocking

  clocking ipm_cb @(posedge aclk);
    default input #1;
    input AWADDR, AWPROT, AWVALID, WDATA, WSTRB, WVALID, BREADY, ARADDR, ARVALID, ARPROT, RREADY;
    input AWREADY, WREADY, ARREADY;
  endclocking

  clocking opm_cb @(posedge aclk);
    default input #1;
    input BRESP, BVALID, RRESP, RVALID, RDATA, BREADY, RREADY, AWADDR, WDATA;
  endclocking

  modport drv_mod(clocking drv_cb, input aresetn);
  modport ipm_mod(clocking ipm_cb, input aresetn);
  modport opm_mod(clocking opm_cb, input aresetn);

  property p_reset;
    @(posedge aclk)
    !aresetn |-> (!AWREADY && !WREADY && !BVALID && !ARREADY && !RVALID);
  endproperty

  a_reset: assert property(p_reset)
    $display("[ASSERT PASS] RESET: All outputs are inactive during reset");
  else
    $display("[ASSERT FAIL] RESET: Output active during reset");

  property p_awvalid_stable;
    @(posedge aclk) disable iff (!aresetn)
    (AWVALID && !AWREADY) |=> AWVALID;
  endproperty

  a_awvalid_stable: assert property(p_awvalid_stable)
    $display("[ASSERT PASS] AWVALID held until AWREADY");
  else
    $display("[ASSERT FAIL] AWVALID dropped before AWREADY");

  property p_awaddr_stable;
    @(posedge aclk) disable iff (!aresetn)
    (AWVALID && !AWREADY) |=> ($stable(AWADDR) && $stable(AWPROT));
  endproperty

  a_awaddr_stable: assert property(p_awaddr_stable)
    $display("[ASSERT PASS] AWADDR/AWPROT stable while waiting");
  else
    $display("[ASSERT FAIL] AWADDR/AWPROT changed while waiting");

  property p_wvalid_stable;
    @(posedge aclk) disable iff (!aresetn)
    (WVALID && !WREADY) |=> WVALID;
  endproperty

  a_wvalid_stable: assert property(p_wvalid_stable)
    $display("[ASSERT PASS] WVALID held until WREADY");
  else
    $display("[ASSERT FAIL] WVALID dropped before WREADY");

  property p_wdata_stable;
    @(posedge aclk) disable iff (!aresetn)
    (WVALID && !WREADY) |=> ($stable(WDATA) && $stable(WSTRB));
  endproperty

  a_wdata_stable: assert property(p_wdata_stable)
    $display("[ASSERT PASS] WDATA/WSTRB stable while waiting");
  else
    $display("[ASSERT FAIL] WDATA/WSTRB changed while waiting");

  property p_bvalid_stable;
    @(posedge aclk) disable iff (!aresetn)
    (BVALID && !BREADY) |=> BVALID;
  endproperty

  a_bvalid_stable: assert property(p_bvalid_stable)
    $display("[ASSERT PASS] BVALID held until BREADY");
  else
    $display("[ASSERT FAIL] BVALID dropped before BREADY");

  property p_bresp_stable;
    @(posedge aclk) disable iff (!aresetn)
    (BVALID && !BREADY) |=> $stable(BRESP);
  endproperty

  a_bresp_stable: assert property(p_bresp_stable)
    $display("[ASSERT PASS] BRESP stable while waiting");
  else
    $display("[ASSERT FAIL] BRESP changed while waiting");

  property p_arvalid_stable;
    @(posedge aclk) disable iff (!aresetn)
    (ARVALID && !ARREADY) |=> ARVALID;
  endproperty

  a_arvalid_stable: assert property(p_arvalid_stable)
    $display("[ASSERT PASS] ARVALID held until ARREADY");
  else
    $display("[ASSERT FAIL] ARVALID dropped before ARREADY");

  property p_araddr_stable;
    @(posedge aclk) disable iff (!aresetn)
    (ARVALID && !ARREADY) |=> ($stable(ARADDR) && $stable(ARPROT));
  endproperty

  a_araddr_stable: assert property(p_araddr_stable)
    $display("[ASSERT PASS] ARADDR/ARPROT stable while waiting");
  else
    $display("[ASSERT FAIL] ARADDR/ARPROT changed while waiting");

  property p_rvalid_stable;
    @(posedge aclk) disable iff (!aresetn)
    (RVALID && !RREADY) |=> RVALID;
  endproperty

  a_rvalid_stable: assert property(p_rvalid_stable)
    $display("[ASSERT PASS] RVALID held until RREADY");
  else
    $display("[ASSERT FAIL] RVALID dropped before RREADY");

  property p_rdata_stable;
    @(posedge aclk) disable iff (!aresetn)
    (RVALID && !RREADY) |=> ($stable(RDATA) && $stable(RRESP));
  endproperty

  a_rdata_stable: assert property(p_rdata_stable)
    $display("[ASSERT PASS] RDATA/RRESP stable while waiting");
  else
    $display("[ASSERT FAIL] RDATA/RRESP changed while waiting");

  property p_awvalid_after_handshake;
    @(posedge aclk) disable iff (!aresetn)
    (AWVALID && AWREADY) |=> (!AWVALID throughout (BVALID && BREADY)[->1]);
  endproperty

  a_awvalid_after_handshake: assert property(p_awvalid_after_handshake)
    $display("[ASSERT PASS] AWVALID remains LOW after AW handshake");
  else
    $display("[ASSERT FAIL] AWVALID asserted again before B handshake");

  property p_arvalid_after_handshake;
    @(posedge aclk) disable iff (!aresetn)
    (ARVALID && ARREADY) |=> (!ARVALID throughout (RVALID && RREADY)[->1]);
  endproperty

  a_arvalid_after_handshake: assert property(p_arvalid_after_handshake)
    $display("[ASSERT PASS] ARVALID remains LOW after AR handshake");
  else
    $display("[ASSERT FAIL] ARVALID asserted again before R handshake");

  property p_no_unknown;
    @(posedge aclk) disable iff (!aresetn)
    !$isunknown({AWREADY, WREADY, BVALID, BRESP, ARREADY, RVALID, RDATA, RRESP});
  endproperty

  a_no_unknown: assert property(p_no_unknown)
    $display("[ASSERT PASS] No UNKNOWN values on AXI outputs");
  else
    $display("[ASSERT FAIL] UNKNOWN value detected on AXI outputs");

endinterface
