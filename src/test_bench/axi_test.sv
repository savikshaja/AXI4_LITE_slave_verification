class axi_test extends uvm_test; 

  `uvm_component_utils(axi_test) 
   
  axi_env e_h; 
   
  function new(string name = "axi_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 
   
  function void build_phase(uvm_phase phase); 
    super.build_phase(phase); 
    e_h = axi_env::type_id::create("e_h", this); 
  endfunction 

  function void end_of_elaboration_phase(uvm_phase phase); 
    super.end_of_elaboration_phase(phase); 
    uvm_top.print_topology(); 
  endfunction 

endclass 


class write_normal_test extends axi_test; 

  `uvm_component_utils(write_normal_test) 

  function new(string name = "write_normal_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    write_normal_seq seq; 
    phase.raise_objection(this); 
    seq = write_normal_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100);    
    phase.drop_objection(this); 
  endtask 

endclass 


class write_addr_test extends axi_test; 

  `uvm_component_utils(write_addr_test) 

  function new(string name = "write_addr_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    write_addr_seq seq; 
    phase.raise_objection(this); 
    seq = write_addr_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100);    
    phase.drop_objection(this); 
  endtask 

endclass 


class write_data_test extends axi_test; 

  `uvm_component_utils(write_data_test) 

  function new(string name = "write_data_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    write_data_seq seq; 
    phase.raise_objection(this); 
    seq = write_data_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100);    
    phase.drop_objection(this); 
  endtask 

endclass 


class read_addr_test extends axi_test; 

  `uvm_component_utils(read_addr_test) 

  function new(string name = "read_addr_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    read_addr_seq seq; 
    phase.raise_objection(this); 
    seq = read_addr_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100);    
    phase.drop_objection(this); 
  endtask 

endclass 


class write_read_back_test extends axi_test; 

  `uvm_component_utils(write_read_back_test) 

  function new(string name = "write_read_back_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    write_read_back_seq seq; 
    phase.raise_objection(this); 
    seq = write_read_back_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100);    
    phase.drop_objection(this); 
  endtask 

endclass 


class slverr_write_test extends axi_test; 

  `uvm_component_utils(slverr_write_test) 

  function new(string name = "slverr_write_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 
   
  task run_phase(uvm_phase phase); 
    slverr_write_seq seq; 
    phase.raise_objection(this); 
    seq = slverr_write_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100); 
    phase.drop_objection(this); 
  endtask 

endclass 


class slverr_read_test extends axi_test; 

  `uvm_component_utils(slverr_read_test) 

  function new(string name = "slverr_read_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    slverr_read_seq seq; 
    phase.raise_objection(this); 
    seq = slverr_read_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100); 
    phase.drop_objection(this); 
  endtask 

endclass 


class decerr_test extends axi_test; 

  `uvm_component_utils(decerr_test) 

  function new(string name = "decerr_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    decerr_seq seq; 
    phase.raise_objection(this); 
    seq = decerr_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100); 
    phase.drop_objection(this); 
  endtask 

endclass 


class read_write_simultaneous_test extends axi_test; 

  `uvm_component_utils(read_write_simultaneous_test) 

  function new(string name = "read_write_simultaneous_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    read_write_simultaneous_seq seq; 
    phase.raise_objection(this); 
    seq = read_write_simultaneous_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100); 
    phase.drop_objection(this); 
  endtask 

endclass 


class slverr_unaligned_write_read_test extends axi_test; 

  `uvm_component_utils(slverr_unaligned_write_read_test) 

  function new(string name = "slverr_unaligned_write_read_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 

  task run_phase(uvm_phase phase); 
    slverr_unaligned_write_read_seq seq; 
    phase.raise_objection(this); 
    seq = slverr_unaligned_write_read_seq::type_id::create("seq"); 
    seq.start(e_h.i_agent.seqr_h); 
    phase.phase_done.set_drain_time(this, 100); 
    phase.drop_objection(this); 
  endtask 

endclass 


class regression_test extends axi_test; 

  `uvm_component_utils(regression_test) 
   
  function new(string name = "regression_test", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 
   
  task run_phase(uvm_phase phase); 
    write_normal_seq                wnseq; 
    write_addr_seq                  wdrseq; 
    write_data_seq                  wdseq; 
    read_addr_seq                   rdrseq; 
    write_read_back_seq             wrseq; 
    read_write_simultaneous_seq     rws_seq; 
    slverr_write_seq                slvw_seq; 
    slverr_read_seq                 slvr_seq; 
    decerr_seq                      dec_seq; 
    slverr_unaligned_write_read_seq unalign_seq; 
     
    phase.raise_objection(this); 
     
    wnseq       = write_normal_seq::type_id::create("wnseq"); 
    wdrseq      = write_addr_seq::type_id::create("wdrseq"); 
    wdseq       = write_data_seq::type_id::create("wdseq"); 
    rdrseq      = read_addr_seq::type_id::create("rdreq"); 
    wrseq       = write_read_back_seq::type_id::create("wrseq"); 
    rws_seq     = read_write_simultaneous_seq::type_id::create("rws_seq"); 
    slvw_seq    = slverr_write_seq::type_id::create("slvw_seq"); 
    slvr_seq    = slverr_read_seq::type_id::create("slvr_seq"); 
    dec_seq     = decerr_seq::type_id::create("dec_seq"); 
    unalign_seq = slverr_unaligned_write_read_seq::type_id::create("unalign_seq"); 
     
    $display("-----------------normal write-----------------------");     
    wnseq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------normal write with addr delay-----------------------");  
    wdrseq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------normal write with data delay-------------------------");  
    wdseq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------normal read with addr delay---------------------------");  
    rdrseq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------write and read back to back---------------------------");  
    wrseq.start(e_h.i_agent.seqr_h); 
     
    $display("--------------------read_write_simultaneous_test------------------------"); 
    rws_seq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------slverr write on read address------------------"); 
    slvw_seq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------slverr read on write address-------------------"); 
    slvr_seq.start(e_h.i_agent.seqr_h); 
     
    $display("------------------decerr---------------------------------------"); 
    dec_seq.start(e_h.i_agent.seqr_h); 
     
    $display("-------------------unaligned address-----------------------------");     
    unalign_seq.start(e_h.i_agent.seqr_h); 
     
    $display("------------------------write read then decerr then read---------------------");     
    $display("-----------------write and read back to back---------------------------");  
    wrseq.start(e_h.i_agent.seqr_h); 
     
    $display("------------------decerr---------------------------------------"); 
    dec_seq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------normal read with addr delay---------------------------");  
    rdrseq.start(e_h.i_agent.seqr_h); 
     
    $display("------------------------write read then unaligned address then read------------------"); 
    $display("-----------------write and read back to back---------------------------");  
    wrseq.start(e_h.i_agent.seqr_h); 
     
    $display("-------------------unaligned address-----------------------------");     
    unalign_seq.start(e_h.i_agent.seqr_h); 
     
    $display("-----------------normal read with addr delay---------------------------");  
    rdrseq.start(e_h.i_agent.seqr_h); 
     
    phase.phase_done.set_drain_time(this, 100);     
    phase.drop_objection(this); 
     
  endtask 

endclass
