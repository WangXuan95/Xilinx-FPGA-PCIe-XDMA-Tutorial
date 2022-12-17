
module fpga_top (
    output wire       o_led0,
    input  wire       i_pcie_rstn,
    input  wire       i_pcie_refclkp, i_pcie_refclkn,
    input  wire [0:0] i_pcie_rxp, i_pcie_rxn,
    output wire [0:0] o_pcie_txp, o_pcie_txn
);


localparam AXI_IDWIDTH = 4;
localparam AXI_AWIDTH  = 64;
localparam AXI_DWIDTH  = 64;


wire  pcie_rstn;
wire  pcie_refclk;

wire  rstn;
wire  clk;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PCIe XDMA's AXI interface
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire                      axi_awready;
wire                      axi_awvalid;
wire [    AXI_AWIDTH-1:0] axi_awaddr;
wire [               7:0] axi_awlen;
wire [   AXI_IDWIDTH-1:0] axi_awid;
// AXI Master Write Data Channel
wire                      axi_wready;
wire                      axi_wvalid;
wire                      axi_wlast;
wire [    AXI_DWIDTH-1:0] axi_wdata;
// AXI Master Write Response Channel
wire                      axi_bready;
wire                      axi_bvalid;
wire [   AXI_IDWIDTH-1:0] axi_bid;
wire [               1:0] axi_bresp;
// AXI Master Read Address Channel
wire                      axi_arready;
wire                      axi_arvalid;
wire [    AXI_AWIDTH-1:0] axi_araddr;
wire [               7:0] axi_arlen;
wire [   AXI_IDWIDTH-1:0] axi_arid;
// AXI Master Read Data Channel
wire                      axi_rready;
wire                      axi_rvalid;
wire                      axi_rlast;
wire [    AXI_DWIDTH-1:0] axi_rdata;
wire [   AXI_IDWIDTH-1:0] axi_rid;
wire [               1:0] axi_rresp;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ref clock input buffer
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
IBUFDS_GTE2 refclk_ibuf (
    .CEB             ( 1'b0              ),
    .I               ( i_pcie_refclkp    ),
    .IB              ( i_pcie_refclkn    ),
    .O               ( pcie_refclk       ),
    .ODIV2           (                   )
);



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Reset input buffer
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
IBUF   sys_reset_n_ibuf (
    .I               ( i_pcie_rstn       ),
    .O               ( pcie_rstn         )
);



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PCIe XDMA core
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
xdma_0 xdma_0_i (
    // PCI Express (PCIe) Interface : connect to the pins of FPGA chip
    .sys_rst_n       ( pcie_rstn         ),
    .sys_clk         ( pcie_refclk       ),
    .pci_exp_txn     ( o_pcie_txn        ),
    .pci_exp_txp     ( o_pcie_txp        ),
    .pci_exp_rxn     ( i_pcie_rxn        ), 
    .pci_exp_rxp     ( i_pcie_rxp        ),
    // PCIe link up
    .user_lnk_up     ( o_led0            ),
    // interrupts
    .usr_irq_req     ( 16'h0             ),
    .usr_irq_ack     (                   ),
    //
    .msix_enable     (                   ),
    // clock/reset for user (for AXI)
    .axi_aclk        ( clk               ),
    .axi_aresetn     ( rstn              ),
    // AXI Interface
    .m_axi_awready   ( axi_awready       ),
    .m_axi_awvalid   ( axi_awvalid       ),
    .m_axi_awaddr    ( axi_awaddr        ),
    .m_axi_awlen     ( axi_awlen         ),
    .m_axi_awid      ( axi_awid          ),
    .m_axi_awsize    (                   ),
    .m_axi_awburst   (                   ),
    .m_axi_awprot    (                   ),
    .m_axi_awlock    (                   ),
    .m_axi_awcache   (                   ),
    .m_axi_wready    ( axi_wready        ),
    .m_axi_wvalid    ( axi_wvalid        ),
    .m_axi_wlast     ( axi_wlast         ),
    .m_axi_wdata     ( axi_wdata         ),
    .m_axi_wstrb     (                   ),
    .m_axi_bready    ( axi_bready        ),
    .m_axi_bvalid    ( axi_bvalid        ),
    .m_axi_bid       ( axi_bid           ),
    .m_axi_bresp     ( axi_bresp         ),
    .m_axi_arready   ( axi_arready       ),
    .m_axi_arvalid   ( axi_arvalid       ),
    .m_axi_araddr    ( axi_araddr        ),
    .m_axi_arlen     ( axi_arlen         ),
    .m_axi_arid      ( axi_arid          ),
    .m_axi_arsize    (                   ),
    .m_axi_arburst   (                   ),
    .m_axi_arprot    (                   ),
    .m_axi_arlock    (                   ),
    .m_axi_arcache   (                   ),
    .m_axi_rready    ( axi_rready        ),
    .m_axi_rvalid    ( axi_rvalid        ),
    .m_axi_rlast     ( axi_rlast         ),
    .m_axi_rdata     ( axi_rdata         ),
    .m_axi_rid       ( axi_rid           ),
    .m_axi_rresp     ( axi_rresp         ),
     // AXI bypass interface
    .m_axib_awready  ( '0                ),
    .m_axib_awvalid  (                   ),
    .m_axib_awaddr   (                   ),
    .m_axib_awlen    (                   ),
    .m_axib_awid     (                   ),
    .m_axib_awsize   (                   ),
    .m_axib_awburst  (                   ),
    .m_axib_awprot   (                   ),
    .m_axib_awlock   (                   ),
    .m_axib_awcache  (                   ),
    .m_axib_wready   ( '0                ),
    .m_axib_wvalid   (                   ),
    .m_axib_wlast    (                   ),
    .m_axib_wdata    (                   ),
    .m_axib_wstrb    (                   ),
    .m_axib_bready   (                   ),
    .m_axib_bvalid   ( '0                ),
    .m_axib_bid      ( '0                ),
    .m_axib_bresp    ( '0                ),
    .m_axib_arready  ( '0                ),
    .m_axib_arvalid  (                   ),
    .m_axib_araddr   (                   ),
    .m_axib_arlen    (                   ),
    .m_axib_arid     (                   ),
    .m_axib_arsize   (                   ),
    .m_axib_arburst  (                   ),
    .m_axib_arprot   (                   ),
    .m_axib_arlock   (                   ),
    .m_axib_arcache  (                   ),
    .m_axib_rready   (                   ),
    .m_axib_rvalid   ( '0                ),
    .m_axib_rlast    ( '0                ),
    .m_axib_rdata    ( '0                ),
    .m_axib_rid      ( '0                ),
    .m_axib_rresp    ( '0                )
);



///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// AXI BRAM connected to PCIe XDMA's AXI interface
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
axi_mpeg2encoder_wrapper #(
    .AXI_IDWIDTH     ( AXI_IDWIDTH       )
) axi_axi_mpeg2encoder_wrapper_i (
    .rstn            ( rstn              ),
    .clk             ( clk               ),
    // AXI Memory Mapped interface
    .s_axi_awready   ( axi_awready       ),
    .s_axi_awvalid   ( axi_awvalid       ),
    .s_axi_awaddr    ( axi_awaddr        ),
    .s_axi_awlen     ( axi_awlen         ),
    .s_axi_awid      ( axi_awid          ),
    .s_axi_wready    ( axi_wready        ),
    .s_axi_wvalid    ( axi_wvalid        ),
    .s_axi_wlast     ( axi_wlast         ),
    .s_axi_wdata     ( axi_wdata         ),
    .s_axi_bready    ( axi_bready        ),
    .s_axi_bvalid    ( axi_bvalid        ),
    .s_axi_bid       ( axi_bid           ),
    .s_axi_bresp     ( axi_bresp         ),
    .s_axi_arready   ( axi_arready       ),
    .s_axi_arvalid   ( axi_arvalid       ),
    .s_axi_araddr    ( axi_araddr        ),
    .s_axi_arlen     ( axi_arlen         ),
    .s_axi_arid      ( axi_arid          ),
    .s_axi_rready    ( axi_rready        ),
    .s_axi_rvalid    ( axi_rvalid        ),
    .s_axi_rlast     ( axi_rlast         ),
    .s_axi_rdata     ( axi_rdata         ),
    .s_axi_rid       ( axi_rid           ),
    .s_axi_rresp     ( axi_rresp         )
);


endmodule
