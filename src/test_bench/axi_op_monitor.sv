class axi_op_monitor extends uvm_monitor;

  `uvm_component_utils(axi_op_monitor)

  uvm_analysis_port#(axi_seq_item) op_port;

  virtual axi_inf.opm_mod          vif;
  axi_seq_item                     seq;

  function new(string name = "axi_op_monitor", uvm_component parent = null);
    super.new(name, parent);
    op_port = new("op_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_inf.opm_mod)::get(this, "", "vif", vif))
      `uvm_fatal("OP_MON", "virtual not found");
  endfunction

  task run_phase(uvm_phase phase);
    // @(vif.opm_cb);
    //@(posedge vif.aresetn);
    fork
      task_write();
      task_read();
    join
  endtask

  task task_write();
    forever begin
      // seq = axi_seq_item::type_id::create("seq");
      @(vif.opm_cb);
      if (vif.opm_cb.BVALID && vif.opm_cb.BREADY) begin
        seq = axi_seq_item::type_id::create("seq");
        seq.BRESP  = vif.opm_cb.BRESP;
        seq.AWADDR = vif.opm_cb.AWADDR;
        seq.WDATA  = vif.opm_cb.WDATA;
        $display("[%0t] OP_MONITOR : BRESP=%0d AWADDR=%H WDATA=%H", $time, seq.BRESP, seq.AWADDR, seq.WDATA);
        op_port.write(seq);
        //$display("[%0t] OP_MONITOR : SENT WRITE TO SCOREBOARD", $time);
      end
    end
  endtask

  task task_read();
    forever begin
      @(vif.opm_cb);
      if (vif.opm_cb.RVALID && vif.opm_cb.RREADY) begin
        seq = axi_seq_item::type_id::create("seq");
        // @(vif.opm_cb);
        seq.RDATA = vif.opm_cb.RDATA;
        seq.RRESP = vif.opm_cb.RRESP;
        $display("[%0t] OP_MONITOR : RDATA=%H RRESP=%0d", $time, seq.RDATA, seq.RRESP);
        op_port.write(seq);
        //$display("[%0t] OP_MONITOR : SENT READ TO SCOREBOARD", $time);
      end
    end
  endtask

endclass
