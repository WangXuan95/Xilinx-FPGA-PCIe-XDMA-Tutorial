//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Fri Dec 16 12:38:58 2022
//Host        : DESKTOP-C6I6OAQ running 64-bit major release  (build 9200)
//Command     : generate_target xdma_bram_wrapper.bd
//Design      : xdma_bram_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module xdma_bram_wrapper
   (pcie_mgt_0_rxn,
    pcie_mgt_0_rxp,
    pcie_mgt_0_txn,
    pcie_mgt_0_txp,
    sys_clk_0,
    sys_rst_n_0,
    user_lnk_up_0);
  input [0:0]pcie_mgt_0_rxn;
  input [0:0]pcie_mgt_0_rxp;
  output [0:0]pcie_mgt_0_txn;
  output [0:0]pcie_mgt_0_txp;
  input sys_clk_0;
  input sys_rst_n_0;
  output user_lnk_up_0;

  wire [0:0]pcie_mgt_0_rxn;
  wire [0:0]pcie_mgt_0_rxp;
  wire [0:0]pcie_mgt_0_txn;
  wire [0:0]pcie_mgt_0_txp;
  wire sys_clk_0;
  wire sys_rst_n_0;
  wire user_lnk_up_0;

  xdma_bram xdma_bram_i
       (.pcie_mgt_0_rxn(pcie_mgt_0_rxn),
        .pcie_mgt_0_rxp(pcie_mgt_0_rxp),
        .pcie_mgt_0_txn(pcie_mgt_0_txn),
        .pcie_mgt_0_txp(pcie_mgt_0_txp),
        .sys_clk_0(sys_clk_0),
        .sys_rst_n_0(sys_rst_n_0),
        .user_lnk_up_0(user_lnk_up_0));
endmodule
