class axi_env extends uvm_env;

  `uvm_component_utils(axi_env)

  // Components: agents, scoreboard, and subscriber
  axi_ip_agent   i_agent;
  axi_op_agent   o_agent; 
  axi_scoreboard score_h; 
  axi_subscriber sub_h;
   
  function new(string name = "axi_env", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  function void build_phase(uvm_phase phase); 
    super.build_phase(phase); 
    i_agent = axi_ip_agent::type_id::create("i_agent", this);
    o_agent = axi_op_agent::type_id::create("o_agent", this);
    score_h = axi_scoreboard::type_id::create("score_h", this);
    sub_h   = axi_subscriber::type_id::create("sub_h", this);
  endfunction 

  function void connect_phase(uvm_phase phase); 
    super.connect_phase(phase); 
    i_agent.ip_h.ip_port.connect(score_h.ip_mon.analysis_export);
    i_agent.ip_h.ip_port.connect(sub_h.analysis_export);
    o_agent.op_h.op_port.connect(score_h.op_mon.analysis_export);
  endfunction

endclass
