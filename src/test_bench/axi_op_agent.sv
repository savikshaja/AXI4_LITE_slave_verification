class axi_op_agent extends uvm_agent;

  `uvm_component_utils(axi_op_agent)

  // Component in output agent
  axi_op_monitor op_h;

  function new(string name = "axi_op_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    is_active = UVM_PASSIVE;
    op_h = axi_op_monitor::type_id::create("op_h", this);
  endfunction

endclass
