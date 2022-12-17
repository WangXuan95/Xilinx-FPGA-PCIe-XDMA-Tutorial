--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
--Date        : Fri Dec 16 10:45:39 2022
--Host        : DESKTOP-C6I6OAQ running 64-bit major release  (build 9200)
--Command     : generate_target xdma_bram.bd
--Design      : xdma_bram
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity xdma_bram is
  port (
    pcie_mgt_0_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    pcie_mgt_0_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    pcie_mgt_0_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    pcie_mgt_0_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    sys_clk_0 : in STD_LOGIC;
    sys_rst_n_0 : in STD_LOGIC;
    user_lnk_up_0 : out STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of xdma_bram : entity is "xdma_bram,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=xdma_bram,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_bram_cntlr_cnt=1,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of xdma_bram : entity is "xdma_bram.hwdef";
end xdma_bram;

architecture STRUCTURE of xdma_bram is
  component xdma_bram_xdma_0_0 is
  port (
    sys_clk : in STD_LOGIC;
    sys_rst_n : in STD_LOGIC;
    user_lnk_up : out STD_LOGIC;
    pci_exp_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    pci_exp_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    pci_exp_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    pci_exp_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    axi_aclk : out STD_LOGIC;
    axi_aresetn : out STD_LOGIC;
    usr_irq_req : in STD_LOGIC_VECTOR ( 15 downto 0 );
    usr_irq_ack : out STD_LOGIC_VECTOR ( 15 downto 0 );
    msix_enable : out STD_LOGIC;
    m_axi_awready : in STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rlast : in STD_LOGIC;
    m_axi_rvalid : in STD_LOGIC;
    m_axi_awid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awlock : out STD_LOGIC;
    m_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_wlast : out STD_LOGIC;
    m_axi_wvalid : out STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_arid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_araddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arlock : out STD_LOGIC;
    m_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_rready : out STD_LOGIC;
    m_axib_awid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axib_awaddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axib_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axib_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axib_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axib_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axib_awvalid : out STD_LOGIC;
    m_axib_awready : in STD_LOGIC;
    m_axib_awlock : out STD_LOGIC;
    m_axib_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axib_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axib_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axib_wlast : out STD_LOGIC;
    m_axib_wvalid : out STD_LOGIC;
    m_axib_wready : in STD_LOGIC;
    m_axib_bid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axib_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axib_bvalid : in STD_LOGIC;
    m_axib_bready : out STD_LOGIC;
    m_axib_arid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axib_araddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axib_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axib_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axib_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axib_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axib_arvalid : out STD_LOGIC;
    m_axib_arready : in STD_LOGIC;
    m_axib_arlock : out STD_LOGIC;
    m_axib_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axib_rid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axib_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axib_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axib_rlast : in STD_LOGIC;
    m_axib_rvalid : in STD_LOGIC;
    m_axib_rready : out STD_LOGIC
  );
  end component xdma_bram_xdma_0_0;
  component xdma_bram_blk_mem_gen_0_1 is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 63 downto 0 )
  );
  end component xdma_bram_blk_mem_gen_0_1;
  component xdma_bram_axi_bram_ctrl_0_2 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 12 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awlock : in STD_LOGIC;
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 12 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC;
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_rdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    bram_rst_a : out STD_LOGIC;
    bram_clk_a : out STD_LOGIC;
    bram_en_a : out STD_LOGIC;
    bram_we_a : out STD_LOGIC_VECTOR ( 7 downto 0 );
    bram_addr_a : out STD_LOGIC_VECTOR ( 12 downto 0 );
    bram_wrdata_a : out STD_LOGIC_VECTOR ( 63 downto 0 );
    bram_rddata_a : in STD_LOGIC_VECTOR ( 63 downto 0 )
  );
  end component xdma_bram_axi_bram_ctrl_0_2;
  component xdma_bram_xlconstant_0_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component xdma_bram_xlconstant_0_0;
  signal axi_bram_ctrl_0_BRAM_PORTA_ADDR : STD_LOGIC_VECTOR ( 12 downto 0 );
  signal axi_bram_ctrl_0_BRAM_PORTA_CLK : STD_LOGIC;
  signal axi_bram_ctrl_0_BRAM_PORTA_DIN : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axi_bram_ctrl_0_BRAM_PORTA_DOUT : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axi_bram_ctrl_0_BRAM_PORTA_EN : STD_LOGIC;
  signal axi_bram_ctrl_0_BRAM_PORTA_WE : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal sys_clk_0_1 : STD_LOGIC;
  signal sys_rst_n_0_1 : STD_LOGIC;
  signal xdma_0_M_AXI_ARADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal xdma_0_M_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_ARID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal xdma_0_M_AXI_ARLOCK : STD_LOGIC;
  signal xdma_0_M_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_ARREADY : STD_LOGIC;
  signal xdma_0_M_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_ARVALID : STD_LOGIC;
  signal xdma_0_M_AXI_AWADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal xdma_0_M_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_AWID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal xdma_0_M_AXI_AWLOCK : STD_LOGIC;
  signal xdma_0_M_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_AWREADY : STD_LOGIC;
  signal xdma_0_M_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_AWVALID : STD_LOGIC;
  signal xdma_0_M_AXI_BID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_BREADY : STD_LOGIC;
  signal xdma_0_M_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_BVALID : STD_LOGIC;
  signal xdma_0_M_AXI_RDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal xdma_0_M_AXI_RID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_RLAST : STD_LOGIC;
  signal xdma_0_M_AXI_RREADY : STD_LOGIC;
  signal xdma_0_M_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_RVALID : STD_LOGIC;
  signal xdma_0_M_AXI_WDATA : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal xdma_0_M_AXI_WLAST : STD_LOGIC;
  signal xdma_0_M_AXI_WREADY : STD_LOGIC;
  signal xdma_0_M_AXI_WSTRB : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal xdma_0_M_AXI_WVALID : STD_LOGIC;
  signal xdma_0_axi_aclk : STD_LOGIC;
  signal xdma_0_axi_aresetn : STD_LOGIC;
  signal xdma_0_pcie_mgt_rxn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xdma_0_pcie_mgt_rxp : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xdma_0_pcie_mgt_txn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xdma_0_pcie_mgt_txp : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xdma_0_user_lnk_up : STD_LOGIC;
  signal xlconstant_0_dout : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_axi_bram_ctrl_0_bram_rst_a_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_arlock_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_arvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_awlock_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_awvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_bready_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_rready_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_wlast_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_wvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_msix_enable_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_m_axib_araddr_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_xdma_0_m_axib_arburst_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_xdma_0_m_axib_arcache_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_xdma_0_m_axib_arid_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_xdma_0_m_axib_arlen_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_xdma_0_m_axib_arprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_xdma_0_m_axib_arsize_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_xdma_0_m_axib_awaddr_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_xdma_0_m_axib_awburst_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_xdma_0_m_axib_awcache_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_xdma_0_m_axib_awid_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_xdma_0_m_axib_awlen_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_xdma_0_m_axib_awprot_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_xdma_0_m_axib_awsize_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_xdma_0_m_axib_wdata_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_xdma_0_m_axib_wstrb_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_xdma_0_usr_irq_ack_UNCONNECTED : STD_LOGIC_VECTOR ( 15 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of sys_clk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.SYS_CLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of sys_clk_0 : signal is "XIL_INTERFACENAME CLK.SYS_CLK_0, CLK_DOMAIN xdma_bram_sys_clk_0, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of sys_rst_n_0 : signal is "xilinx.com:signal:reset:1.0 RST.SYS_RST_N_0 RST";
  attribute X_INTERFACE_PARAMETER of sys_rst_n_0 : signal is "XIL_INTERFACENAME RST.SYS_RST_N_0, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of pcie_mgt_0_rxn : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_mgt_0 rxn";
  attribute X_INTERFACE_INFO of pcie_mgt_0_rxp : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_mgt_0 rxp";
  attribute X_INTERFACE_INFO of pcie_mgt_0_txn : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_mgt_0 txn";
  attribute X_INTERFACE_INFO of pcie_mgt_0_txp : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_mgt_0 txp";
begin
  pcie_mgt_0_txn(0) <= xdma_0_pcie_mgt_txn(0);
  pcie_mgt_0_txp(0) <= xdma_0_pcie_mgt_txp(0);
  sys_clk_0_1 <= sys_clk_0;
  sys_rst_n_0_1 <= sys_rst_n_0;
  user_lnk_up_0 <= xdma_0_user_lnk_up;
  xdma_0_pcie_mgt_rxn(0) <= pcie_mgt_0_rxn(0);
  xdma_0_pcie_mgt_rxp(0) <= pcie_mgt_0_rxp(0);
axi_bram_ctrl_0: component xdma_bram_axi_bram_ctrl_0_2
     port map (
      bram_addr_a(12 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_ADDR(12 downto 0),
      bram_clk_a => axi_bram_ctrl_0_BRAM_PORTA_CLK,
      bram_en_a => axi_bram_ctrl_0_BRAM_PORTA_EN,
      bram_rddata_a(63 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_DOUT(63 downto 0),
      bram_rst_a => NLW_axi_bram_ctrl_0_bram_rst_a_UNCONNECTED,
      bram_we_a(7 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_WE(7 downto 0),
      bram_wrdata_a(63 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_DIN(63 downto 0),
      s_axi_aclk => xdma_0_axi_aclk,
      s_axi_araddr(12 downto 0) => xdma_0_M_AXI_ARADDR(12 downto 0),
      s_axi_arburst(1 downto 0) => xdma_0_M_AXI_ARBURST(1 downto 0),
      s_axi_arcache(3 downto 0) => xdma_0_M_AXI_ARCACHE(3 downto 0),
      s_axi_aresetn => xdma_0_axi_aresetn,
      s_axi_arid(3 downto 0) => xdma_0_M_AXI_ARID(3 downto 0),
      s_axi_arlen(7 downto 0) => xdma_0_M_AXI_ARLEN(7 downto 0),
      s_axi_arlock => xdma_0_M_AXI_ARLOCK,
      s_axi_arprot(2 downto 0) => xdma_0_M_AXI_ARPROT(2 downto 0),
      s_axi_arready => xdma_0_M_AXI_ARREADY,
      s_axi_arsize(2 downto 0) => xdma_0_M_AXI_ARSIZE(2 downto 0),
      s_axi_arvalid => xdma_0_M_AXI_ARVALID,
      s_axi_awaddr(12 downto 0) => xdma_0_M_AXI_AWADDR(12 downto 0),
      s_axi_awburst(1 downto 0) => xdma_0_M_AXI_AWBURST(1 downto 0),
      s_axi_awcache(3 downto 0) => xdma_0_M_AXI_AWCACHE(3 downto 0),
      s_axi_awid(3 downto 0) => xdma_0_M_AXI_AWID(3 downto 0),
      s_axi_awlen(7 downto 0) => xdma_0_M_AXI_AWLEN(7 downto 0),
      s_axi_awlock => xdma_0_M_AXI_AWLOCK,
      s_axi_awprot(2 downto 0) => xdma_0_M_AXI_AWPROT(2 downto 0),
      s_axi_awready => xdma_0_M_AXI_AWREADY,
      s_axi_awsize(2 downto 0) => xdma_0_M_AXI_AWSIZE(2 downto 0),
      s_axi_awvalid => xdma_0_M_AXI_AWVALID,
      s_axi_bid(3 downto 0) => xdma_0_M_AXI_BID(3 downto 0),
      s_axi_bready => xdma_0_M_AXI_BREADY,
      s_axi_bresp(1 downto 0) => xdma_0_M_AXI_BRESP(1 downto 0),
      s_axi_bvalid => xdma_0_M_AXI_BVALID,
      s_axi_rdata(63 downto 0) => xdma_0_M_AXI_RDATA(63 downto 0),
      s_axi_rid(3 downto 0) => xdma_0_M_AXI_RID(3 downto 0),
      s_axi_rlast => xdma_0_M_AXI_RLAST,
      s_axi_rready => xdma_0_M_AXI_RREADY,
      s_axi_rresp(1 downto 0) => xdma_0_M_AXI_RRESP(1 downto 0),
      s_axi_rvalid => xdma_0_M_AXI_RVALID,
      s_axi_wdata(63 downto 0) => xdma_0_M_AXI_WDATA(63 downto 0),
      s_axi_wlast => xdma_0_M_AXI_WLAST,
      s_axi_wready => xdma_0_M_AXI_WREADY,
      s_axi_wstrb(7 downto 0) => xdma_0_M_AXI_WSTRB(7 downto 0),
      s_axi_wvalid => xdma_0_M_AXI_WVALID
    );
blk_mem_gen_0: component xdma_bram_blk_mem_gen_0_1
     port map (
      addra(15 downto 13) => B"000",
      addra(12 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_ADDR(12 downto 0),
      clka => axi_bram_ctrl_0_BRAM_PORTA_CLK,
      dina(63 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_DIN(63 downto 0),
      douta(63 downto 0) => axi_bram_ctrl_0_BRAM_PORTA_DOUT(63 downto 0),
      ena => axi_bram_ctrl_0_BRAM_PORTA_EN,
      wea(0) => axi_bram_ctrl_0_BRAM_PORTA_WE(0)
    );
xdma_0: component xdma_bram_xdma_0_0
     port map (
      axi_aclk => xdma_0_axi_aclk,
      axi_aresetn => xdma_0_axi_aresetn,
      m_axi_araddr(63 downto 0) => xdma_0_M_AXI_ARADDR(63 downto 0),
      m_axi_arburst(1 downto 0) => xdma_0_M_AXI_ARBURST(1 downto 0),
      m_axi_arcache(3 downto 0) => xdma_0_M_AXI_ARCACHE(3 downto 0),
      m_axi_arid(3 downto 0) => xdma_0_M_AXI_ARID(3 downto 0),
      m_axi_arlen(7 downto 0) => xdma_0_M_AXI_ARLEN(7 downto 0),
      m_axi_arlock => xdma_0_M_AXI_ARLOCK,
      m_axi_arprot(2 downto 0) => xdma_0_M_AXI_ARPROT(2 downto 0),
      m_axi_arready => xdma_0_M_AXI_ARREADY,
      m_axi_arsize(2 downto 0) => xdma_0_M_AXI_ARSIZE(2 downto 0),
      m_axi_arvalid => xdma_0_M_AXI_ARVALID,
      m_axi_awaddr(63 downto 0) => xdma_0_M_AXI_AWADDR(63 downto 0),
      m_axi_awburst(1 downto 0) => xdma_0_M_AXI_AWBURST(1 downto 0),
      m_axi_awcache(3 downto 0) => xdma_0_M_AXI_AWCACHE(3 downto 0),
      m_axi_awid(3 downto 0) => xdma_0_M_AXI_AWID(3 downto 0),
      m_axi_awlen(7 downto 0) => xdma_0_M_AXI_AWLEN(7 downto 0),
      m_axi_awlock => xdma_0_M_AXI_AWLOCK,
      m_axi_awprot(2 downto 0) => xdma_0_M_AXI_AWPROT(2 downto 0),
      m_axi_awready => xdma_0_M_AXI_AWREADY,
      m_axi_awsize(2 downto 0) => xdma_0_M_AXI_AWSIZE(2 downto 0),
      m_axi_awvalid => xdma_0_M_AXI_AWVALID,
      m_axi_bid(3 downto 0) => xdma_0_M_AXI_BID(3 downto 0),
      m_axi_bready => xdma_0_M_AXI_BREADY,
      m_axi_bresp(1 downto 0) => xdma_0_M_AXI_BRESP(1 downto 0),
      m_axi_bvalid => xdma_0_M_AXI_BVALID,
      m_axi_rdata(63 downto 0) => xdma_0_M_AXI_RDATA(63 downto 0),
      m_axi_rid(3 downto 0) => xdma_0_M_AXI_RID(3 downto 0),
      m_axi_rlast => xdma_0_M_AXI_RLAST,
      m_axi_rready => xdma_0_M_AXI_RREADY,
      m_axi_rresp(1 downto 0) => xdma_0_M_AXI_RRESP(1 downto 0),
      m_axi_rvalid => xdma_0_M_AXI_RVALID,
      m_axi_wdata(63 downto 0) => xdma_0_M_AXI_WDATA(63 downto 0),
      m_axi_wlast => xdma_0_M_AXI_WLAST,
      m_axi_wready => xdma_0_M_AXI_WREADY,
      m_axi_wstrb(7 downto 0) => xdma_0_M_AXI_WSTRB(7 downto 0),
      m_axi_wvalid => xdma_0_M_AXI_WVALID,
      m_axib_araddr(63 downto 0) => NLW_xdma_0_m_axib_araddr_UNCONNECTED(63 downto 0),
      m_axib_arburst(1 downto 0) => NLW_xdma_0_m_axib_arburst_UNCONNECTED(1 downto 0),
      m_axib_arcache(3 downto 0) => NLW_xdma_0_m_axib_arcache_UNCONNECTED(3 downto 0),
      m_axib_arid(3 downto 0) => NLW_xdma_0_m_axib_arid_UNCONNECTED(3 downto 0),
      m_axib_arlen(7 downto 0) => NLW_xdma_0_m_axib_arlen_UNCONNECTED(7 downto 0),
      m_axib_arlock => NLW_xdma_0_m_axib_arlock_UNCONNECTED,
      m_axib_arprot(2 downto 0) => NLW_xdma_0_m_axib_arprot_UNCONNECTED(2 downto 0),
      m_axib_arready => '0',
      m_axib_arsize(2 downto 0) => NLW_xdma_0_m_axib_arsize_UNCONNECTED(2 downto 0),
      m_axib_arvalid => NLW_xdma_0_m_axib_arvalid_UNCONNECTED,
      m_axib_awaddr(63 downto 0) => NLW_xdma_0_m_axib_awaddr_UNCONNECTED(63 downto 0),
      m_axib_awburst(1 downto 0) => NLW_xdma_0_m_axib_awburst_UNCONNECTED(1 downto 0),
      m_axib_awcache(3 downto 0) => NLW_xdma_0_m_axib_awcache_UNCONNECTED(3 downto 0),
      m_axib_awid(3 downto 0) => NLW_xdma_0_m_axib_awid_UNCONNECTED(3 downto 0),
      m_axib_awlen(7 downto 0) => NLW_xdma_0_m_axib_awlen_UNCONNECTED(7 downto 0),
      m_axib_awlock => NLW_xdma_0_m_axib_awlock_UNCONNECTED,
      m_axib_awprot(2 downto 0) => NLW_xdma_0_m_axib_awprot_UNCONNECTED(2 downto 0),
      m_axib_awready => '0',
      m_axib_awsize(2 downto 0) => NLW_xdma_0_m_axib_awsize_UNCONNECTED(2 downto 0),
      m_axib_awvalid => NLW_xdma_0_m_axib_awvalid_UNCONNECTED,
      m_axib_bid(3 downto 0) => B"0000",
      m_axib_bready => NLW_xdma_0_m_axib_bready_UNCONNECTED,
      m_axib_bresp(1 downto 0) => B"00",
      m_axib_bvalid => '0',
      m_axib_rdata(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      m_axib_rid(3 downto 0) => B"0000",
      m_axib_rlast => '0',
      m_axib_rready => NLW_xdma_0_m_axib_rready_UNCONNECTED,
      m_axib_rresp(1 downto 0) => B"00",
      m_axib_rvalid => '0',
      m_axib_wdata(63 downto 0) => NLW_xdma_0_m_axib_wdata_UNCONNECTED(63 downto 0),
      m_axib_wlast => NLW_xdma_0_m_axib_wlast_UNCONNECTED,
      m_axib_wready => '0',
      m_axib_wstrb(7 downto 0) => NLW_xdma_0_m_axib_wstrb_UNCONNECTED(7 downto 0),
      m_axib_wvalid => NLW_xdma_0_m_axib_wvalid_UNCONNECTED,
      msix_enable => NLW_xdma_0_msix_enable_UNCONNECTED,
      pci_exp_rxn(0) => xdma_0_pcie_mgt_rxn(0),
      pci_exp_rxp(0) => xdma_0_pcie_mgt_rxp(0),
      pci_exp_txn(0) => xdma_0_pcie_mgt_txn(0),
      pci_exp_txp(0) => xdma_0_pcie_mgt_txp(0),
      sys_clk => sys_clk_0_1,
      sys_rst_n => sys_rst_n_0_1,
      user_lnk_up => xdma_0_user_lnk_up,
      usr_irq_ack(15 downto 0) => NLW_xdma_0_usr_irq_ack_UNCONNECTED(15 downto 0),
      usr_irq_req(15 downto 0) => xlconstant_0_dout(15 downto 0)
    );
xlconstant_0: component xdma_bram_xlconstant_0_0
     port map (
      dout(15 downto 0) => xlconstant_0_dout(15 downto 0)
    );
end STRUCTURE;
