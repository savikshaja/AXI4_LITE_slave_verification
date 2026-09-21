class axi_ip_monitor extends uvm_monitor; 

  `uvm_component_utils(axi_ip_monitor) 

  uvm_analysis_port #(axi_seq_item) ip_port; 
  uvm_analysis_port #(axi_seq_item) reset_port; 
   
  virtual axi_inf.ipm_mod vif; 

  function new(string name = "axi_ip_monitor", uvm_component parent = null); 
    super.new(name, parent); 
    ip_port    = new("ip_port", this); 
    reset_port = new("reset_port", this); 
  endfunction 

  function void build_phase(uvm_phase phase); 
    super.build_phase(phase); 
    if (!uvm_config_db #(virtual axi_inf.ipm_mod)::get(this, "", "vif", vif)) 
      `uvm_fatal("IP_MON", "Virtual interface handle 'vif' not found") 
  endfunction 
      
  task run_phase(uvm_phase phase); 
    fork 
      task_reset(); 
      task_write(); 
      task_read(); 
    join 
  endtask 
      
  task task_reset(); 
    axi_seq_item seq; 

    forever begin 
      @(negedge vif.aresetn); 

      seq = axi_seq_item::type_id::create("reset_seq"); 
      seq.reset = 1'b1; 

      `uvm_info("IP_MONITOR", "RESET DETECTED - Sending reset transaction", UVM_MEDIUM) 

      reset_port.write(seq); 
    end 
  endtask 

  task task_write(); 
    axi_seq_item seq; 
    forever begin 
      seq = axi_seq_item::type_id::create("seq"); 
       
      fork 
        begin 
          forever begin 
            @(vif.ipm_cb); 
            if (vif.ipm_cb.AWVALID && vif.ipm_cb.AWREADY) 
              break; 
          end 
          seq.AWADDR = vif.ipm_cb.AWADDR; 
          seq.AWPROT = vif.ipm_cb.AWPROT; 
        end 
         
        begin 
          forever begin 
            @(vif.ipm_cb); 
            if (vif.ipm_cb.WVALID && vif.ipm_cb.WREADY) 
              break; 
          end 
          seq.WDATA = vif.ipm_cb.WDATA; 
          seq.WSTRB = vif.ipm_cb.WSTRB; 
        end 
      join 

      // Explicitly tag this object so the scoreboard can classify it correctly 
      seq.AWVALID = 1'b1; 
      seq.WVALID  = 1'b1; 
      seq.ARVALID = 1'b0; 
      seq.BREADY  = 1'b1; 
      seq.RREADY  = 1'b0; 

      $display("[%0t] IP_MONITOR : AWADDR=%H AWPROT=%H WDATA=%H WSTRB=%H", 
               $time, seq.AWADDR, seq.AWPROT, seq.WDATA, seq.WSTRB); 
      ip_port.write(seq); 
    end 
  endtask 
      
  task task_read(); 
    axi_seq_item seq; 
    forever begin 
      @(vif.ipm_cb); 
      if (vif.ipm_cb.ARVALID && vif.ipm_cb.ARREADY) begin 
        seq = axi_seq_item::type_id::create("seq"); 
        seq.ARADDR = vif.ipm_cb.ARADDR; 
        seq.ARPROT = vif.ipm_cb.ARPROT; 

        // Explicitly tag this object so the scoreboard can classify it correctly 
        seq.ARVALID = 1'b1; 
        seq.AWVALID = 1'b0; 
        seq.WVALID  = 1'b0; 
        seq.BREADY  = 1'b0; 
        seq.RREADY  = 1'b1; 

        $display("[%0t] IP_MONITOR : ARADDR=%H ARPROT=%H", $time, seq.ARADDR, seq.ARPROT); 
        ip_port.write(seq); 
      end 
    end 
  endtask 

endclass
