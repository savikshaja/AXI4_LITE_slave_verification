class axi_driver extends uvm_driver #(axi_seq_item);

  `uvm_component_utils(axi_driver)

  function new(string name = "axi_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  axi_seq_item req;

  virtual axi_inf.drv_mod vif;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual axi_inf.drv_mod)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    @(posedge vif.aresetn);
    forever begin
      seq_item_port.get_next_item(req);

      fork
        begin
          fork
            drive_write(req);
            drive_read(req);
          join
        end
        begin
          @(negedge vif.aresetn);
          $display("[%0t] DRIVER : RESET DETECTED", $time);
        end
      join_any

      disable fork;

      seq_item_port.item_done();

      if (!vif.aresetn)
        @(posedge vif.aresetn);
    end
  endtask

  task drive_write(axi_seq_item req);

    if (req.AWVALID && !req.WVALID) begin
      vif.drv_cb.WVALID  <= 1'b0;
      vif.drv_cb.WDATA   <= req.WDATA;
      vif.drv_cb.WSTRB   <= req.WSTRB;

      vif.drv_cb.AWVALID <= 1'b0;
      repeat (req.aw_delay)
        @(vif.drv_cb);
      @(vif.drv_cb);

      vif.drv_cb.AWADDR  <= req.AWADDR;
      vif.drv_cb.AWPROT  <= req.AWPROT;
      vif.drv_cb.AWVALID <= 1'b1;

      $display("[%0t] DRIVER : ADDRESS ONLY", $time);
      $display("[%0t] DRIVER : AWVALID=%b AWADDR=%h", $time, req.AWVALID, req.AWADDR);
      $display("[%0t] DRIVER : WVALID=%b BUT WDATA=%h WSTRB=%h", $time, req.WVALID, req.WDATA, req.WSTRB);

      do
        @(vif.drv_cb);
      while (!vif.drv_cb.AWREADY);

      vif.drv_cb.AWVALID <= 1'b0;
      $display("[%0t] DRIVER : AW HANDSHAKE DONE", $time);
      return;
    end

    if (!req.AWVALID && req.WVALID) begin
      vif.drv_cb.AWVALID <= 1'b0;
      vif.drv_cb.AWADDR  <= req.AWADDR;
      vif.drv_cb.AWPROT  <= req.AWPROT;

      $display("[%0t] DRIVER : AWVALID=0 BUT DRIVING AWADDR=%h", $time, req.AWADDR);

      repeat (req.w_delay)
        @(vif.drv_cb);
      @(vif.drv_cb);

      vif.drv_cb.WDATA   <= req.WDATA;
      vif.drv_cb.WSTRB   <= req.WSTRB;
      vif.drv_cb.WVALID  <= 1'b1;

      $display("[%0t] DRIVER : DATA ONLY", $time);
      $display("[%0t] DRIVER : WVALID=%b WDATA=%h WSTRB=%h", $time, req.WVALID, req.WDATA, req.WSTRB);

      do
        @(vif.drv_cb);
      while (!vif.drv_cb.WREADY);

      vif.drv_cb.WVALID <= 1'b0;
      $display("[%0t] DRIVER : W HANDSHAKE DONE", $time);

      repeat (req.ready_delay)
        @(vif.drv_cb);

      vif.drv_cb.BREADY <= 1'b1;
      $display("[%0t] DRIVER : WAITING FOR BVALID", $time);

      do
        @(vif.drv_cb);
      while (!vif.drv_cb.BVALID);

      vif.drv_cb.BREADY <= 1'b0;
      $display("[%0t] DRIVER : B HANDSHAKE DONE", $time);
      return;
    end

    if (req.AWVALID && req.WVALID) begin
      fork
        begin : write_address
          vif.drv_cb.AWVALID <= 1'b0;
          repeat (req.aw_delay)
            @(vif.drv_cb);
          @(vif.drv_cb);

          vif.drv_cb.AWADDR  <= req.AWADDR;
          vif.drv_cb.AWPROT  <= req.AWPROT;
          vif.drv_cb.AWVALID <= 1'b1;

          $display("[%0t] DRIVER : NORMAL WRITE AWADDR=%h", $time, req.AWADDR);

          do
            @(vif.drv_cb);
          while (!vif.drv_cb.AWREADY);

          vif.drv_cb.AWVALID <= 1'b0;
          $display("[%0t] DRIVER : AW HANDSHAKE DONE", $time);
        end

        begin : write_data
          vif.drv_cb.WVALID  <= 1'b0;
          repeat (req.w_delay)
            @(vif.drv_cb);
          @(vif.drv_cb);

          vif.drv_cb.WDATA   <= req.WDATA;
          vif.drv_cb.WSTRB   <= req.WSTRB;
          vif.drv_cb.WVALID  <= 1'b1;

          $display("[%0t] DRIVER : NORMAL WRITE WDATA=%h WSTRB=%h", $time, req.WDATA, req.WSTRB);

          do
            @(vif.drv_cb);
          while (!vif.drv_cb.WREADY);

          vif.drv_cb.WVALID <= 1'b0;
          $display("[%0t] DRIVER : W HANDSHAKE DONE", $time);
        end
      join

      $display("[%0t] DRIVER : AW + W COMPLETE, WAITING FOR BVALID", $time);

      repeat (req.ready_delay)
        @(vif.drv_cb);

      vif.drv_cb.BREADY <= 1'b1;

      do
        @(vif.drv_cb);
      while (!vif.drv_cb.BVALID);

      vif.drv_cb.BREADY <= 1'b0;
      $display("[%0t] DRIVER : B HANDSHAKE DONE", $time);
    end

  endtask

  task drive_read(axi_seq_item req);
    if (!req.ARVALID)
      return;

    vif.drv_cb.ARVALID <= 1'b0;
    repeat (req.ar_delay)
      @(vif.drv_cb);
    @(vif.drv_cb);

    vif.drv_cb.ARADDR  <= req.ARADDR;
    vif.drv_cb.ARPROT  <= req.ARPROT;
    vif.drv_cb.ARVALID <= req.ARVALID;

    $display("[%0t] DRIVER READ : ARADDR=%h", $time, req.ARADDR);

    do
      @(vif.drv_cb);
    while (!vif.drv_cb.ARREADY);

    vif.drv_cb.ARVALID <= 1'b0;

    repeat (req.ready_delay)
      @(vif.drv_cb);

    vif.drv_cb.RREADY <= 1'b1;
    $display("[%0t] DRIVER READ : WAITING FOR RVALID", $time);

    do
      @(vif.drv_cb);
    while (!vif.drv_cb.RVALID);

    vif.drv_cb.RREADY <= 1'b0;
    $display("[%0t] DRIVER READ : R HANDSHAKE DONE", $time);
  endtask

endclass
