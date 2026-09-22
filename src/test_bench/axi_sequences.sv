class write_normal_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(write_normal_seq)

  function new(string name = "write_normal_seq");
    super.new(name);
  endfunction

  axi_seq_item seq;

  task body();
    repeat (50) begin
      seq = axi_seq_item::type_id::create("seq");
      start_item(seq);
      assert(seq.randomize() with {
        AWVALID == 1'b1;
        WVALID  == 1'b1;
        aw_delay == 1;
        w_delay  == 0;
        WSTRB    == 4'b1111;
        ARVALID  == 1'b0;
      });
      finish_item(seq);
    end
  endtask
endclass

class write_addr_then_data_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(write_addr_then_data_seq)

  function new(string name = "write_addr_then_data_seq");
    super.new(name);
  endfunction

  task body();
    axi_seq_item addr_item;
    axi_seq_item data_item;

    repeat (10) begin
      addr_item = axi_seq_item::type_id::create("addr_item");
      start_item(addr_item);
      assert(addr_item.randomize() with {
        AWVALID == 1'b1;
        WVALID  == 1'b0;
        ARVALID == 1'b0;
      });
      finish_item(addr_item);

      data_item = axi_seq_item::type_id::create("data_item");
      start_item(data_item);
      assert(data_item.randomize() with {
        AWVALID == 1'b0;
        WVALID  == 1'b1;
        ARVALID == 1'b0;
      });
      finish_item(data_item);
    end
  endtask
endclass

class write_addr_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(write_addr_seq)

  function new(string name = "write_addr_seq");
    super.new(name);
  endfunction

  axi_seq_item seq;

  task body();
    repeat (50) begin
      seq = axi_seq_item::type_id::create("seq");
      start_item(seq);
      assert(seq.randomize() with {
        AWVALID == 1'b1;
        ARVALID == 1'b0;
        WVALID  == 1'b1;
        aw_delay == 0;
        w_delay  != 0;
      });
      finish_item(seq);
    end
  endtask
endclass

class write_data_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(write_data_seq)

  function new(string name = "write_data_seq");
    super.new(name);
  endfunction

  axi_seq_item seq;

  task body();
    repeat (50) begin
      seq = axi_seq_item::type_id::create("seq");
      start_item(seq);
      assert(seq.randomize() with {
        AWVALID == 1'b1;
        WVALID  == 1'b1;
        w_delay  == 0;
        ARVALID == 1'b0;
        aw_delay != 0;
      });
      finish_item(seq);
    end
  endtask
endclass

class read_addr_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(read_addr_seq)

  function new(string name = "read_addr_seq");
    super.new(name);
  endfunction

  axi_seq_item seq;

  task body();
    repeat (50) begin
      seq = axi_seq_item::type_id::create("seq");
      start_item(seq);
      assert(seq.randomize() with {
        ARVALID == 1'b1;
        AWVALID == 1'b0;
        WVALID  == 1'b0;
      });
      finish_item(seq);
    end
  endtask
endclass

class write_read_back_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(write_read_back_seq)

  function new(string name = "write_read_back_seq");
    super.new(name);
  endfunction

  axi_seq_item wr_seq;
  axi_seq_item rd_seq;

  task body();
    repeat (10) begin
      for (int addr = 32'h0000_0000; addr <= 32'h0000_003C; addr += 4) begin
        wr_seq = axi_seq_item::type_id::create("wr_seq");
        start_item(wr_seq);
        assert(wr_seq.randomize() with {
          AWVALID == 1'b1;
          WVALID  == 1'b1;
          AWADDR  == addr;
          aw_delay == 0;
          w_delay  == 2;
          ARVALID == 1'b0;
          WSTRB   == 4'b1111;
        });
        finish_item(wr_seq);
      end

      for (int addr = 32'h0000_0000; addr <= 32'h0000_003C; addr += 4) begin
        rd_seq = axi_seq_item::type_id::create("rd_seq");
        start_item(rd_seq);
        assert(rd_seq.randomize() with {
          AWVALID == 1'b0;
          WVALID  == 1'b0;
          ARVALID == 1'b1;
          ARADDR  == addr;
          ar_delay == 0;
          w_delay  == 0;
        });
        finish_item(rd_seq);
      end
    end
  endtask
endclass

class slverr_write_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(slverr_write_seq)

  function new(string name = "slverr_write_seq");
    super.new(name);
  endfunction

  task body();
    repeat (50) begin
      axi_seq_item wr_item, rd_item;
      wr_item = axi_seq_item::type_id::create("wr_item");
      start_item(wr_item);
      if (!wr_item.randomize() with {
        AWADDR inside {32'h28, 32'h2C, 32'h30};
        AWVALID == 1;
        WVALID  == 1;
        ARVALID == 0;
        aw_delay != w_delay;
      })
        `uvm_error("SLVERR_WR_SEQ", "Randomization failed")
      finish_item(wr_item);

      rd_item = axi_seq_item::type_id::create("rd_item");
      start_item(rd_item);
      if (!rd_item.randomize() with {
        ARADDR == wr_item.AWADDR;
        AWVALID == 0;
        WVALID  == 0;
        ARVALID == 1;
      })
        `uvm_error("SLVERR_WR_SEQ", "Randomization failed")
      finish_item(rd_item);
    end
  endtask
endclass

class slverr_read_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(slverr_read_seq)

  function new(string name = "slverr_read_seq");
    super.new(name);
  endfunction

  task body();
    repeat (50) begin
      axi_seq_item item;
      item = axi_seq_item::type_id::create("item");
      start_item(item);
      if (!item.randomize() with {
        ARADDR inside {32'h34, 32'h38};
        ARVALID == 1;
        AWVALID == 0;
        WVALID  == 0;
      })
        `uvm_error("SLVERR_RD_SEQ", "Randomization failed")
      finish_item(item);
    end
  endtask
endclass

class decerr_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(decerr_seq)

  function new(string name = "decerr_seq");
    super.new(name);
  endfunction

  axi_seq_item wr_seq;
  axi_seq_item rd_seq;

  task body();
    repeat (5) begin
      for (int addr = 32'h0000_0040; addr <= 32'h0000_007C; addr += 4) begin
        wr_seq = axi_seq_item::type_id::create("wr_seq");
        start_item(wr_seq);
        wr_seq.address_alian.constraint_mode(0);
        assert(wr_seq.randomize() with {
          AWVALID == 1'b1;
          WVALID  == 1'b1;
          ARVALID == 1'b0;
          AWADDR  == addr;
          WSTRB   == 4'b1111;
          aw_delay != w_delay;
        });
        wr_seq.address_alian.constraint_mode(1);
        finish_item(wr_seq);
      end

      for (int addr = 32'h0000_0040; addr <= 32'h0000_007C; addr += 4) begin
        rd_seq = axi_seq_item::type_id::create("rd_seq");
        start_item(rd_seq);
        rd_seq.address_alian.constraint_mode(0);
        assert(rd_seq.randomize() with {
          AWVALID == 1'b0;
          WVALID  == 1'b0;
          ARVALID == 1'b1;
          ARADDR  == addr;
          RREADY  == 1'b1;
        });
        rd_seq.address_alian.constraint_mode(1);
        finish_item(rd_seq);
      end

      for (int i = 7; i <= 31; i++) begin
        bit [31:0] addr = (32'h1 << i);
        wr_seq = axi_seq_item::type_id::create("wr_seq");
        start_item(wr_seq);
        wr_seq.address_alian.constraint_mode(0);
        assert(wr_seq.randomize() with {
          AWVALID == 1'b1;
          WVALID  == 1'b1;
          ARVALID == 1'b0;
          AWADDR  == addr;
          WSTRB   == 4'b1111;
          aw_delay == 5;
          w_delay  == 2;
        });
        wr_seq.address_alian.constraint_mode(1);
        finish_item(wr_seq);
      end

      for (int i = 7; i <= 31; i++) begin
        bit [31:0] addr = (32'h1 << i);
        rd_seq = axi_seq_item::type_id::create("rd_seq");
        start_item(rd_seq);
        rd_seq.address_alian.constraint_mode(0);
        assert(rd_seq.randomize() with {
          AWVALID == 1'b0;
          WVALID  == 1'b0;
          ARVALID == 1'b1;
          ARADDR  == addr;
          RREADY  == 1'b1;
        });
        rd_seq.address_alian.constraint_mode(1);
        finish_item(rd_seq);
      end
    end
  endtask
endclass

class read_write_simultaneous_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(read_write_simultaneous_seq)

  function new(string name = "read_write_simultaneous_seq");
    super.new(name);
  endfunction

  task body();
    axi_seq_item item;

    for (int addr = 32'h0000_0000; addr <= 32'h0000_003C; addr += 4) begin
      item = axi_seq_item::type_id::create("item");
      start_item(item);
      assert(item.randomize() with {
        AWVALID == 1'b1;
        WVALID  == 1'b1;
        AWADDR  == addr;
        ARVALID == 1'b1;
        ARADDR  == addr;
        aw_delay != w_delay;
      });
      finish_item(item);
    end
  endtask
endclass

class slverr_unaligned_write_read_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(slverr_unaligned_write_read_seq)

  function new(string name = "slverr_unaligned_write_read_seq");
    super.new(name);
  endfunction

  axi_seq_item wr_item;
  axi_seq_item rd_item;

  task body();
    for (int addr = 32'h0000_0001; addr <= 32'h0000_003F; addr++) begin
      wr_item = axi_seq_item::type_id::create("wr_item");
      start_item(wr_item);
      wr_item.address_alian.constraint_mode(0);
      assert(wr_item.randomize() with {
        AWADDR  == addr;
        AWVALID == 1'b1;
        WVALID  == 1'b1;
        ARVALID == 1'b0;
        aw_delay == 0;
        w_delay  == 2;
      });
      wr_item.address_alian.constraint_mode(1);
      finish_item(wr_item);

      rd_item = axi_seq_item::type_id::create("rd_item");
      start_item(rd_item);
      rd_item.address_alian.constraint_mode(0);
      assert(rd_item.randomize() with {
        ARADDR  == addr;
        ARVALID == 1'b1;
        AWVALID == 1'b0;
        WVALID  == 1'b0;
      });
      rd_item.address_alian.constraint_mode(1);
      finish_item(rd_item);
    end
  endtask
endclass
