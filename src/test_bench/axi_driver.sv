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
      `uvm_fatal("DRV", "virtual interface not found"); 
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
          $display("[%t] reset detected", $time); 
        end 
      join_any 
      disable fork; 
          
      seq_item_port.item_done(); 
       
      if (!vif.aresetn) 
        @(posedge vif.aresetn); 
    end 
  endtask 
   
  task drive_write(axi_seq_item req); 
    if (!(req.AWVALID || req.WVALID)) 
      return; 
       
    fork 
      begin : write_address 
        vif.drv_cb.AWVALID <= 1'b0; 
        repeat(req.aw_delay) @(vif.drv_cb); 
         
        @(vif.drv_cb); 
        vif.drv_cb.AWADDR  <= req.AWADDR; 
        vif.drv_cb.AWPROT  <= req.AWPROT; 
        vif.drv_cb.AWVALID <= 1'b1; 
         
        do @(vif.drv_cb); 
        while (!vif.drv_cb.AWREADY); 
        vif.drv_cb.AWVALID <= 1'b0; 
      end : write_address 
       
      begin : write_data 
        vif.drv_cb.WVALID <= 1'b0; 
        repeat(req.w_delay) @(vif.drv_cb); 
        @(vif.drv_cb); 
        vif.drv_cb.WDATA  <= req.WDATA; 
        vif.drv_cb.WSTRB  <= req.WSTRB; 
        vif.drv_cb.WVALID <= 1'b1; 
         
        do begin 
          @(vif.drv_cb); 
        end while (!vif.drv_cb.WREADY); 
         
        vif.drv_cb.WVALID <= 1'b0; 
      end : write_data 
    join 
     
    $display("[DRIVER WRITE %t] AWADDR=%h WDATA=%h", $time, req.AWADDR, req.WDATA); 
     
    $display("[\%0t] BREADY=1", $time); 
    repeat(req.ready_delay) @(vif.drv_cb); 
    vif.drv_cb.BREADY <= 1'b1; 
    do @(vif.drv_cb); 
    while (!vif.drv_cb.BVALID); 
    vif.drv_cb.BREADY <= 1'b0; 
  endtask 
   
  task drive_read(axi_seq_item req); 
    if (!req.ARVALID) 
      return; 
       
    vif.drv_cb.ARVALID <= 1'b0; 
    repeat(req.ar_delay) @(vif.drv_cb); 
    @(vif.drv_cb); 
    vif.drv_cb.ARADDR  <= req.ARADDR; 
    vif.drv_cb.ARPROT  <= req.ARPROT; 
    vif.drv_cb.ARVALID <= 1'b1; 
     
    $display("[DRIVER READ \%t] ARADDR=\%h", $time, req.ARADDR); 
     
    do @(vif.drv_cb); 
    while (!vif.drv_cb.ARREADY); 
    vif.drv_cb.ARVALID <= 1'b0; 

    repeat(req.ready_delay) @(vif.drv_cb); 
    vif.drv_cb.RREADY <= 1'b1; 
    do @(vif.drv_cb); 
    while (!vif.drv_cb.RVALID); 
    vif.drv_cb.RREADY <= 1'b0; 
  endtask 

endclass
