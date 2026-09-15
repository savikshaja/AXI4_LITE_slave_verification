class axi_seq_item extends uvm_sequence_item; 

  // Inputs and outputs 
  rand bit [`AW-1:0]      AWADDR; 
  rand bit [`DW-1:0]      WDATA; 
  rand bit [(`DW/8-1):0]  WSTRB; 
  rand bit [2:0]          AWPROT, ARPROT; 
  rand bit                BREADY; 
  rand bit [`AW-1:0]      ARADDR; 

  // Handshake signals - address 
  rand bit                AWVALID, ARVALID; 
  rand bit                RREADY;
  
  // Handshake signal - data 
  rand bit                WVALID; 

  // Delays for address, data, read data (no delay for response) 
  rand bit [2:0]          aw_delay; 
  rand bit [2:0]          w_delay; 
  rand bit [2:0]          ar_delay; 
   
  // Output from slave, input to master 
  logic                   AWREADY, WREADY, ARREADY; 
  logic [`DW-1:0]         RDATA; 
  logic [1:0]             BRESP, RRESP; 
  logic                   RVALID, BVALID; 
   
  constraint protection {
    ARPROT == 3'b000; 
    AWPROT == 3'b000;
  } 

  // Byte-aligned address from master 
  constraint address_align {
    AWADDR[1:0] == 2'b00; 
    ARADDR[1:0] == 2'b00;
    AWADDR inside {[32'h00:32'h3F]};
    ARADDR inside {[32'h00:32'h3F]};
  } 

  `uvm_object_utils_begin(axi_seq_item)  
    `uvm_field_int(AWADDR,  UVM_ALL_ON)  
    `uvm_field_int(WDATA,   UVM_ALL_ON)  
    `uvm_field_int(WSTRB,   UVM_ALL_ON)  
    `uvm_field_int(AWVALID, UVM_ALL_ON)  
    `uvm_field_int(WVALID,  UVM_ALL_ON)  
    `uvm_field_int(ARVALID, UVM_ALL_ON)  
    `uvm_field_int(AWPROT,  UVM_ALL_ON)  
    `uvm_field_int(ARPROT,  UVM_ALL_ON)  
    `uvm_field_int(BREADY,  UVM_ALL_ON)  
    `uvm_field_int(ARADDR,  UVM_ALL_ON)  
    `uvm_field_int(RREADY,  UVM_ALL_ON)  
    `uvm_field_int(AWREADY, UVM_ALL_ON)  
    `uvm_field_int(WREADY,  UVM_ALL_ON)  
    `uvm_field_int(ARREADY, UVM_ALL_ON)  
    `uvm_field_int(RDATA,   UVM_ALL_ON)  
    `uvm_field_int(BRESP,   UVM_ALL_ON)  
    `uvm_field_int(RRESP,   UVM_ALL_ON)  
    `uvm_field_int(RVALID,  UVM_ALL_ON)  
    `uvm_field_int(BVALID,  UVM_ALL_ON)  
  `uvm_object_utils_end  

  function new(string name = "axi_seq_item");  
    super.new(name);  
  endfunction 

endclass
