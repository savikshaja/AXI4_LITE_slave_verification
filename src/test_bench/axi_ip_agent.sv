class axi_ip_agent extends uvm_agent;

  `uvm_component_utils(axi_ip_agent)

  // Sub-components in the input agent
  axi_sequencer   seqr_h;
  axi_driver      drv_h;
  axi_ip_monitor  ip_h;

  function new(string name = "axi_ip_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      seqr_h = axi_sequencer::type_id::create("seqr_h", this);
      drv_h  = axi_driver::type_id::create("drv_h", this);
    end
    ip_h = axi_ip_monitor::type_id::create("ip_h", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      drv_h.seq_item_port.connect(seqr_h.seq_item_export);
    end
  endfunction

endclass
