class axi_subscriber extends uvm_subscriber #(axi_seq_item); 

  `uvm_component_utils(axi_subscriber) 
   
  axi_seq_item drv; 
   
  covergroup input_cg; 
    cp_awaddr: coverpoint drv.AWADDR { 
      bins read_write  = {[32'h00:32'h24]}; 
      bins read_only   = {[32'h28:32'h30]}; 
      bins write_only  = {[32'h34:32'h38]}; 
      bins reserved    = {32'h3C}; 
    } 
     
    cp_awvalid: coverpoint drv.AWVALID { 
      // bins low  = {0}; 
      bins high = {1}; 
    } 
     
    cp_wvalid: coverpoint drv.WVALID { 
      // bins low  = {0}; 
      bins high = {1}; 
    } 
     
    cp_wdata: coverpoint drv.WDATA { 
      bins data[16] = {[32'h0000_0000:32'hFFFF_FFFF]}; 
    } 
     
    cp_wstrb: coverpoint drv.WSTRB { 
      bins strb[] = {4'b0000, 4'b0001, 4'b0010, 4'b0100, 4'b1000, 4'b0011, 4'b1100, 4'b1111}; 
    } 
     
    cp_araddr: coverpoint drv.ARADDR { 
      bins read_write  = {[32'h00:32'h24]}; 
      bins read_only   = {[32'h28:32'h30]}; 
      bins write_only  = {[32'h34:32'h38]}; 
      bins reserved    = {32'h3C}; 
    } 
     
    cp_arvalid: coverpoint drv.ARVALID { 
      bins low  = {0}; 
      bins high = {1}; 
    } 
     
    cp_bready: coverpoint drv.BREADY { 
      // bins low  = {0}; 
      bins high = {1}; 
    } 
     
    cp_rready: coverpoint drv.RREADY { 
      // bins low  = {0}; 
      bins high = {1}; 
    } 

    awv_x_wv      : cross cp_awvalid, cp_wvalid; 
    ard_x_arv     : cross cp_araddr, cp_arvalid; 
    bready_x_addr : cross cp_bready, cp_awaddr; 
    rready_x_raddr: cross cp_rready, cp_araddr; 
  endgroup 

  function new(string name = "axi_subscriber", uvm_component parent = null); 
    super.new(name, parent); 
    input_cg = new(); 
  endfunction 

  virtual function void write(axi_seq_item t); 
    drv = t; 
    input_cg.sample(); 
    `uvm_info(get_name(), "INPUT TRANSACTION RECEIVED", UVM_HIGH) 
  endfunction 

  function void report_phase(uvm_phase phase); 
    super.report_phase(phase); 
    `uvm_info(get_name(), $sformatf("INPUT COVERAGE = %0.2f %%", input_cg.get_coverage()), UVM_NONE) 
  endfunction 

endclass
