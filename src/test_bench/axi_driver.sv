class axi_driver extends uvm_driver #(axi_seq_item); 
  `uvm_component_utils(axi_driver) 
  
  function new(string name = "axi_driver", uvm_component parent = null); 
    super.new(name, parent); 
  endfunction 
  
  axi_seq_item req; 
  
  virtual axi_inf.drv_mod vif; 
  
  function void build_phase(uvm_phase phase); 
    super.build_phase(phase); 
    if (!uvm_config_db#(virtual axi_inf.drv_mod)::get(this, "", "vif", vif)) 
      `uvm_fatal("DRV", "virtual not found"); 
  endfunction 
      
  task run_phase(uvm_phase phase); 
    @(posedge vif.aresetn); 
    forever begin 
      // $display("[%0t] START THE DRIVER SEQ", $time); 
      seq_item_port.get_next_item(req); 
      fork 
        drive_write(req); 
        drive_read(req); 
      join 
      seq_item_port.item_done(); 
    end 
  endtask 
   
  task drive_write(axi_seq_item req); 
    if (!(req.AWVALID || req.WVALID)) 
      return; 
    //$display("[%0t] DRIVER TASK - WRITE", $time); 
    fork 
      begin : write_address 
        repeat(req.aw_delay) @(vif.drv_cb); 
         
        @(vif.drv_cb); 
        vif.drv_cb.AWADDR <= req.AWADDR; 
        vif.drv_cb.AWPROT <= req.AWPROT; 
        vif.drv_cb.AWVALID <= 1'b1; 
      //  $display("[%0t] AWVALID=1 AWADDR=%H", $time, req.AWADDR); 
         
        do @(vif.drv_cb); 
        while (!vif.drv_cb.AWREADY); 
        vif.drv_cb.AWVALID <= 1'b0; 
        //$display("[%0t] AWVALID SET = 0", $time); 
      end : write_address 
       
      begin : write_data 
        repeat(req.w_delay) @(vif.drv_cb); 
        @(vif.drv_cb); 
        vif.drv_cb.WDATA <= req.WDATA; 
        vif.drv_cb.WSTRB <= req.WSTRB; 
        vif.drv_cb.WVALID <= 1'b1; 
        //$display("[%0t] WVALID=1 WDATA=%H WSTRB=%H", $time, req.WDATA, req.WSTRB); 
         
        do begin 
          @(vif.drv_cb); 
          //$display("[%t] waiting for WREADY", $time); 
        end while (!vif.drv_cb.WREADY); 
         
        vif.drv_cb.WVALID <= 1'b0; 
        //$display("[%0t] WVALID SET = 0", $time); 
      end : write_data 

      $display("[DRIVER WRITE %t] AWADDR=%h WDATA=%h", $time, req.AWADDR, req.WDATA); 
    join 
     
    //$display("[%0t] BREADY=1", $time); 
    vif.drv_cb.BREADY <= 1'b1; 
    do @(vif.drv_cb); 
    while (!vif.drv_cb.BVALID); 
    vif.drv_cb.BREADY <= 1'b0; 
    //$display("[%0t] BREADY=0", $time); 
  endtask 
   
  task drive_read(axi_seq_item req); 
    if (!req.ARVALID) return; 
    //$display("[%0t] DRIVER TASK - READ", $time); 
    repeat(req.ar_delay) @(vif.drv_cb); 
    @(vif.drv_cb); 
    vif.drv_cb.ARADDR <= req.ARADDR; 
    vif.drv_cb.ARPROT <= req.ARPROT; 
    vif.drv_cb.ARVALID <= 1'b1; 
    //$display("[%0t] ARVALID=1 ARADDR=%H", $time, req.ARADDR);
    $display("[DRIVER READ %t] ARADDR=%h", $time, req.ARADDR); 
     
    do @(vif.drv_cb); 
    while (!vif.drv_cb.ARREADY); 
    vif.drv_cb.ARVALID <= 1'b0; 
    //$display("[%0t] RREADY=1", $time); 
     
    vif.drv_cb.RREADY <= 1'b1; 
    do @(vif.drv_cb); 
    while (!vif.drv_cb.RVALID); 
    vif.drv_cb.RREADY <= 1'b0; 
    //$display("[%0t] RREADY=0", $time); 
  endtask 
   
endclass
