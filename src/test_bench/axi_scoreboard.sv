class axi_scoreboard extends uvm_scoreboard; 

  `uvm_component_utils(axi_scoreboard) 

  // Analysis FIFOs from monitors 
  uvm_tlm_analysis_fifo #(axi_seq_item) ip_mon; 
  uvm_tlm_analysis_fifo #(axi_seq_item) op_mon; 
  uvm_tlm_analysis_fifo #(axi_seq_item) reset_mon; 

  // Slave memory model 
  bit [`DW-1:0] mem[bit [`AW-1:0]]; 

  // Report counts 
  int resp_pass; 
  int resp_fail; 
  int data_pass; 
  int data_fail; 

  function new(string name = "axi_scoreboard", uvm_component parent = null); 
    super.new(name, parent); 
    ip_mon    = new("ip_mon", this); 
    op_mon    = new("op_mon", this); 
    reset_mon = new("reset_mon", this); 
  endfunction 

  task run_phase(uvm_phase phase); 
    compare_loop(); 
  endtask 

  // -------------------------------------------------------------- 
  // Pairs ip_seq/op_seq transactions and compares them. Races the 
  // pairing attempt against reset so a transaction that's already 
  // been dequeued (and so can't be flushed by process_reset()) is 
  // discarded instead of getting mismatched with the next real 
  // response. 
  // -------------------------------------------------------------- 
  task compare_loop(); 
    axi_seq_item ip_seq; 
    axi_seq_item op_seq; 
    axi_seq_item rst_seq; 
    axi_seq_item temp_seq; 

    forever begin 
      fork : WAIT_FOR_TRANSACTION_OR_RESET 
        begin : TRANSACTION 
          ip_mon.get(ip_seq); 
          op_mon.get(op_seq); 

          if (ip_seq.AWVALID && ip_seq.WVALID) 
            write_data(ip_seq, op_seq); 
          else 
            read_data(ip_seq, op_seq); 
        end 

        begin : RESET 
          reset_mon.get(rst_seq); 

          `uvm_info("SCOREBOARD", "RESET RECEIVED - DISCARDING IN-FLIGHT TRANSACTION", UVM_MEDIUM) 

          mem.delete(); 

          while (ip_mon.try_get(temp_seq)); 
          while (op_mon.try_get(temp_seq)); 
        end 
      join_any 

      disable WAIT_FOR_TRANSACTION_OR_RESET; 
    end 
  endtask 

  task write_data(axi_seq_item ip_seq, axi_seq_item op_seq); 
    bit [1:0] exp_resp; 

    if (ip_seq.AWADDR[31:6] != 26'd0) 
      exp_resp = 2'b11; 
    else if (ip_seq.AWADDR[1:0] != 2'b00) 
      exp_resp = 2'b10; 
    else if (ip_seq.AWADDR inside {[32'h0028:32'h0030]}) 
      exp_resp = 2'b10; 
    else if (ip_seq.AWADDR inside {[32'h0000:32'h0024], [32'h0034:32'h0038], 32'h003c}) 
      exp_resp = 2'b00; 
    else 
      exp_resp = 2'b01; 

    if (exp_resp == 2'b00 || exp_resp == 2'b01) begin 
      // Strobe operation 
      if (!mem.exists(ip_seq.AWADDR)) 
        mem[ip_seq.AWADDR] = '0; 

      for (int i = 0; i < 4; i++) begin 
        if (ip_seq.WSTRB[i]) 
          mem[ip_seq.AWADDR][8*i +: 8] = ip_seq.WDATA[8*i +: 8]; 
      end 
    end 

    if (exp_resp == op_seq.BRESP) begin 
      resp_pass++; 
      $display("WRITE RESPONSE PASS: actual BRESP=%b, expected BRESP=%b", op_seq.BRESP, exp_resp); 
    end else begin 
      resp_fail++; 
      $display("WRITE RESPONSE FAIL: actual BRESP=%b, expected BRESP=%b", op_seq.BRESP, exp_resp); 
    end 
  endtask 

  task read_data(axi_seq_item ip_seq, axi_seq_item op_seq); 
    bit [1:0]     exp_resp; 
    bit [`DW-1:0] rdata; 

    if (ip_seq.ARADDR[31:6] != 26'd0) 
      exp_resp = 2'b11; 
    else if (ip_seq.ARADDR[1:0] != 2'b00) 
      exp_resp = 2'b10; 
    else if (ip_seq.ARADDR inside {[32'h0034:32'h0038]}) 
      exp_resp = 2'b10; 
    else if (ip_seq.ARADDR inside {[32'h0000:32'h0030], 32'h003c}) 
      exp_resp = 2'b00; 
    else 
      exp_resp = 2'b01; 

    if (exp_resp == 2'b00 || exp_resp == 2'b01) begin 
      if (mem.exists(ip_seq.ARADDR)) begin 
        rdata = mem[ip_seq.ARADDR]; 
      end else begin 
        rdata = '0; 
      end 
    end 

    if (rdata == op_seq.RDATA) begin 
      data_pass++; 
      $display("READ DATA PASS: actual RDATA=%h, expected RDATA=%h", op_seq.RDATA, rdata); 
    end else begin 
      data_fail++; 
      $display("READ DATA FAIL: actual RDATA=%h, expected RDATA=%h", op_seq.RDATA, rdata); 
    end 

    if (exp_resp == op_seq.RRESP) begin 
      resp_pass++; 
      $display("READ RESPONSE PASS: actual RRESP=%b, expected RRESP=%b", op_seq.RRESP, exp_resp); 
    end else begin 
      resp_fail++; 
      $display("READ RESPONSE FAIL: actual RRESP=%b, expected RRESP=%b", op_seq.RRESP, exp_resp); 
    end 
  endtask 

  function void report_phase(uvm_phase phase); 
    super.report_phase(phase); 
    `uvm_info("SCB_SUMMARY", $sformatf("RESP CHECKS  : PASS=%0d FAIL=%0d", resp_pass, resp_fail), UVM_NONE) 
    `uvm_info("SCB_SUMMARY", $sformatf("DATA CHECKS  : PASS=%0d FAIL=%0d", data_pass, data_fail), UVM_NONE) 
    `uvm_info("SCB_SUMMARY", $sformatf("TOTAL CHECKS : PASS=%0d FAIL=%0d", resp_pass + data_pass, resp_fail + data_fail), UVM_NONE) 
  endfunction 

endclass
