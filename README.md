
---

# Parameters

| Parameter | Default | Description |
|----------|---------|-------------|
| DATA_WIDTH | 32 | Width of data bus |
| MEM_DEPTH | 16 | Number of 32-bit registers |
| Address Range | 0x00 – 0x3F | Valid byte address space |

---

# Interface

| Signal | Direction | Description |
|---------|-----------|-------------|
| ACLK | Input | Global AXI clock |
| ARESETn | Input | Active-low reset |
| AWADDR / AWVALID / AWREADY | Master ↔ Slave | Write address channel |
| WDATA / WSTRB / WVALID / WREADY | Master ↔ Slave | Write data channel |
| BRESP / BVALID / BREADY | Slave ↔ Master | Write response channel |
| ARADDR / ARVALID / ARREADY | Master ↔ Slave | Read address channel |
| RDATA / RRESP / RVALID / RREADY | Slave ↔ Master | Read data channel |

---

# Slave Memory Organisation

| Byte Address Range | Word Index | Access Type | Description |
|---|---|---|---|
| 0x00 – 0x24 | 0 – 9 | Read/Write | Normal registers |
| 0x28 – 0x30 | 10 – 12 | Read-Only | Status registers |
| 0x34 – 0x38 | 13 – 14 | Write-Only | Command registers |
| 0x3C | 15 | Read/Write | Reserved / normal |
| Others | – | Invalid | DECERR |

All accesses must be 32-bit aligned; an unaligned access generates SLVERR. Out-of-range addresses generate DECERR.

---

# Error Response Encoding

| Response | Encoding | Description |
|---|---|---|
| OKAY | 00 | Successful transaction |
| EXOKAY | 01 | Exclusive access success |
| SLVERR | 10 | Slave-generated error |
| DECERR | 11 | Decode error (invalid address) |

---

# Verification

The environment is a UVM-style, layered testbench (`axi_top`) that drives and checks the DUV through a single bundled virtual interface, `axi_inf`.

Verification components include:

- Sequence Item (`axi_seq_item`)
- Driver (`axi_driver`)
- Input Monitor / Output Monitor
- Scoreboard (`axi_scoreboard`)
- Subscriber
- Environment
- Random and Directed Sequences
- Reset-aware transaction handling (in-flight transactions discarded on reset)

---

# Functional Coverage

Coverage includes:

### Variables

- Write address (`cp_awaddr`)
- Write data (`cp_wdata`)
- Write strobe (`cp_wstrb`)
- Read address (`cp_araddr`)
- Handshake signals (`cp_awvalid`, `cp_arvalid`, `cp_bready`, `cp_rready`)

### Crosses

- `awv_x_wv` — AWVALID × WVALID
- `ard_x_arv` — ARADDR × ARVALID
- `bready_x_addr` — BREADY × write address
- `rready_x_raddr` — RREADY × read address

---

# Assertions (SVA)

Assertions bound to the interface include:

- AWADDR must remain stable while AWVALID is high and AWREADY is not yet asserted
- WDATA / WSTRB must remain stable while WVALID is high and WREADY is not yet asserted
- ARADDR must remain stable while ARVALID is high and ARREADY is not yet asserted
- RDATA must remain stable while ARVALID is high and ARREADY is not yet asserted
- BRESP must remain stable while BVALID is high and BREADY is not yet asserted
- RVALID must be observed following ARVALID and ARREADY assertion

---

# Test Cases

Implemented test cases include:

- Reset Test
- Write with address/data arriving together
- Write with address/data arriving with delay (either order)
- Read
- Write to Read-Only region (SLVERR)
- Read from Write-Only region (SLVERR)
- Unaligned Write / Read (SLVERR)
- Out-of-Range Write / Read (DECERR)
- Simultaneous Read and Write
- SLVERR follow-up read
- DECERR follow-up read

---

# Tools Used

- Verilog
- SystemVerilog
- UVM
- QuestaSim
- URG (Unified Report Generator)
- Git

---
