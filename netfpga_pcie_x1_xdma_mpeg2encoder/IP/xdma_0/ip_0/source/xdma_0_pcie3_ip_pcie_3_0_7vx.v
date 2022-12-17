//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
//
// Project    : Virtex-7 FPGA Gen3 Integrated Block for PCI Express
// File       : xdma_0_pcie3_ip_pcie_3_0_7vx.v
// Version    : 4.2
//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : <CoreName>_pcie_3_0_7vx.v                                   //
// Description  : Instantiates PCIe Top Level and GT top level and connects   //
//                 them via PIPE interface.                                   //
//                                                                            //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
//  pcie_3_0_7vx.v                                                            //
//      gt_top.v                                                              //
//          pcie_tx_elec_idle_filter_7vx.v                                    //
//          pipe_clock.v                                                      //
//          pipe_reset.v                                                      //
//          qpll_reset.v                                                      //
//              * Generate GTHE2_CHANNEL for every lane.                      //
//                  pipe_user.v                                               //
//                  pipe_rate.v                                               //
//                  pipe_sync.v                                               //
//                  pipe_drp.v                                                //
//                  pipe_eq.v                                                 //
//                      rxeq_scan.v                                           //
//                  gt_wrapper.v                                              //
//                      GTHE2_CHANNEL                                         //
//                      GTHE2_COMMON                                          //
//              * Generate GTHE2_COMMON for every quad.                       //
//                  qpll_drp.v                                                //
//                  qpll_wrapper.v                                            //
//      pcie_top.v                                                            //
//          pcie_init_ctrl.v                                                  //
//          pcie_tlp_tph_tbl_7vx.v                                            //
//          pcie_7vx.v                                                        //
//              PCIE_3_0                                                      //
//              pcie_bram_7vx.v                                               //
//                  pcie_bram_7vx_rep.v                                       //
//                      pcie_bram_7vx_rep_8k.v                                //
//                  pcie_bram_7vx_req.v                                       //
//                      pcie_bram_7vx_8k.v                                    //
//                  pcie_bram_7vx_cpl.v                                       //
//                      pcie_bram_7vx_8k.v                                    //
//                      pcie_bram_7vx_16k.v                                   //
//          pcie_pipe_pipeline.v                                              //
//              pcie_pipe_lane.v                                              //
//              pcie_pipe_misc.v                                              //
//      tandem_cpler.v                                                        //
//          tandem_cpler_ctl_arb.v                                            //
//          PIO_RX_ENGINE.v                                                   //
//          PIO_TX_ENGINE.v                                                   //
//          PIO_INTR_CTRL.v                                                   //
//      Fast_PCIe_config_top.v                                                //
//          pr_loader.v                                                       //
//              PIO_FPC.v                                                     //
//                  PIO_TO_CTRL_FPC.v                                         //
//                  PIO_EP_FPC.v                                              //
//                      PIO_EP_MA_FPC.v                                       //
//                      PIO_TX_ENG_FPC.v                                      //
//                      PIO_RX_ENG_FPC.v                                      //
//                      icap_access.v                                         //
//                      data_transfer.v                                       //
//                          fastConfigFIFO.v                                  //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module xdma_0_pcie3_ip_pcie_3_0_7vx # (
  parameter integer TCQ = 100,
  parameter         component_name = "pcie3_7x_v4_3_4",
  // The following parameters can be changed to configure the link to a different width/speed.
  // See Product Guide for details: Table "Data Width and Clock Frequency Settings for the Client Interfaces"
  parameter  [2:0]  PL_LINK_CAP_MAX_LINK_SPEED = 3'h4, // Maximum Link Speed
  parameter  [3:0]  PL_LINK_CAP_MAX_LINK_WIDTH = 4'h8, // Maximum Link Width
  parameter integer USER_CLK2_FREQ = 4,                // AXI Client Interface Frequency
  parameter         C_DATA_WIDTH = 256,                // AXI Client Interface Width
  parameter integer PIPE_PIPELINE_STAGES = 0,          // PIPE Interface pipeline: 0-None, 1- single pipeline, 2-double pipeline
  parameter         PIPE_SIM = "FALSE",                // No effect in RTL using this parameter.  
  parameter         PIPE_SIM_MODE = "FALSE",           // Use this paramter to control PIPE mode simulation logic; in-side this module    
  parameter         EXT_PIPE_SIM = "FALSE",
  //GT Parameters
  parameter         REF_CLK_FREQ = 0,                  // Reference Clock Frequency
  parameter         PCIE_EXT_CLK = "TRUE",
  parameter         PCIE_EXT_GT_COMMON = "FALSE",
  parameter         EXT_CH_GT_DRP      = "FALSE",      // PCIe external CH DRP
  parameter         PCIE_DRP           = "FALSE",      // PCIe DRP

  parameter         TRANSCEIVER_CTRL_STATUS_PORTS = "FALSE",  
  parameter         PCIE_TXBUF_EN = "FALSE",
  parameter         PCIE_GT_DEVICE = "GTH",
  parameter integer PCIE_CHAN_BOND = 0,
  parameter         PCIE_CHAN_BOND_EN = "FALSE",
  parameter         PCIE_USE_MODE = "2.0",
  parameter         PCIE_LPM_DFE = "LPM",
  parameter integer PCIE_LINK_SPEED  = 3,
  parameter integer KEEP_WIDTH  = (C_DATA_WIDTH/32),
  parameter         TX_MARGIN_FULL_0          = 7'b1001111,    
  parameter         TX_MARGIN_FULL_1          = 7'b1001110,   
  parameter         TX_MARGIN_FULL_2          = 7'b1001101,  
  parameter         TX_MARGIN_FULL_3          = 7'b1001100, 
  parameter         TX_MARGIN_FULL_4          = 7'b1000011,
  parameter         TX_MARGIN_LOW_0           = 7'b1000101,
  parameter         TX_MARGIN_LOW_1           = 7'b1000110,
  parameter         TX_MARGIN_LOW_2           = 7'b1000011, 
  parameter         TX_MARGIN_LOW_3           =7'b1000010, 
  parameter         TX_MARGIN_LOW_4           =7'b1000000,
  // PCIe 3_0 Core parameters
  parameter         ARI_CAP_ENABLE = "FALSE",
  parameter         AXISTEN_IF_CC_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_CC_PARITY_CHK = "FALSE",
  parameter         AXISTEN_IF_CQ_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_ENABLE_CLIENT_TAG = "FALSE",
  parameter [17:0]  AXISTEN_IF_ENABLE_MSG_ROUTE = 18'h2FFFF,
  parameter         AXISTEN_IF_ENABLE_RX_MSG_INTFC = "FALSE",
  parameter         AXISTEN_IF_RC_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_RC_STRADDLE = "FALSE",
  parameter         AXISTEN_IF_RQ_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_RQ_PARITY_CHK = "FALSE",
  parameter  [7:0]  DNSTREAM_LINK_NUM = 8'h00,
  parameter  [1:0]  GEN3_PCS_AUTO_REALIGN = 2'h1,
  parameter         GEN3_PCS_RX_ELECIDLE_INTERNAL = "TRUE",
  parameter  [8:0]  LL_ACK_TIMEOUT = 9'h000,
  parameter         LL_ACK_TIMEOUT_EN = "FALSE",
  parameter integer LL_ACK_TIMEOUT_FUNC = 0,
  parameter [15:0]  LL_CPL_FC_UPDATE_TIMER = 16'h0000,
  parameter         LL_CPL_FC_UPDATE_TIMER_OVERRIDE = "FALSE",
  parameter [15:0]  LL_FC_UPDATE_TIMER = 16'h0000,
  parameter         LL_FC_UPDATE_TIMER_OVERRIDE = "FALSE",
  parameter [15:0]  LL_NP_FC_UPDATE_TIMER = 16'h0000,
  parameter         LL_NP_FC_UPDATE_TIMER_OVERRIDE = "FALSE",
  parameter [15:0]  LL_P_FC_UPDATE_TIMER = 16'h0000,
  parameter         LL_P_FC_UPDATE_TIMER_OVERRIDE = "FALSE",
  parameter  [8:0]  LL_REPLAY_TIMEOUT = 9'h000,
  parameter         LL_REPLAY_TIMEOUT_EN = "FALSE",
  parameter integer LL_REPLAY_TIMEOUT_FUNC = 0,
  parameter  [9:0]  LTR_TX_MESSAGE_MINIMUM_INTERVAL = 10'h0FA,
  parameter         LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE = "FALSE",
  parameter         LTR_TX_MESSAGE_ON_LTR_ENABLE = "FALSE",
  parameter         PF0_AER_CAP_ECRC_CHECK_CAPABLE = "FALSE",
  parameter         PF0_AER_CAP_ECRC_GEN_CAPABLE = "FALSE",
  parameter [11:0]  PF0_AER_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  PF0_ARI_CAP_NEXTPTR = 12'h000,
  parameter  [7:0]  PF0_ARI_CAP_NEXT_FUNC = 8'h00,
  parameter  [3:0]  PF0_ARI_CAP_VER = 4'h1,
  parameter  [4:0]  PF0_BAR0_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_BAR0_CONTROL = 3'h4,
  parameter  [4:0]  PF0_BAR1_APERTURE_SIZE = 5'h00,
  parameter  [2:0]  PF0_BAR1_CONTROL = 3'h0,
  parameter  [4:0]  PF0_BAR2_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_BAR2_CONTROL = 3'h4,
  parameter  [4:0]  PF0_BAR3_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_BAR3_CONTROL = 3'h0,
  parameter  [4:0]  PF0_BAR4_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_BAR4_CONTROL = 3'h4,
  parameter  [4:0]  PF0_BAR5_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_BAR5_CONTROL = 3'h0,
  parameter  [7:0]  PF0_BIST_REGISTER = 8'h00,
  parameter  [7:0]  PF0_CAPABILITY_POINTER = 8'h50,
  parameter [23:0]  PF0_CLASS_CODE = 24'h000000,
  parameter [15:0]  PF0_VENDOR_ID = 16'h10EE,
  parameter [15:0]  PF0_DEVICE_ID = 16'h0007,
  parameter         PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT = "TRUE",
  parameter         PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT = "TRUE",
  parameter         PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT = "TRUE",
  parameter         PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE = "TRUE",
  parameter         PF0_DEV_CAP2_LTR_SUPPORT = "TRUE",
  parameter  [1:0]  PF0_DEV_CAP2_OBFF_SUPPORT = 2'h0,
  parameter         PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT = "FALSE",
  parameter integer PF0_DEV_CAP_ENDPOINT_L0S_LATENCY = 0,
  parameter integer PF0_DEV_CAP_ENDPOINT_L1_LATENCY = 0,
  parameter         PF0_DEV_CAP_EXT_TAG_SUPPORTED = "TRUE",
  parameter         PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE = "TRUE",
  parameter  [2:0]  PF0_DEV_CAP_MAX_PAYLOAD_SIZE = 3'h3,
  parameter [11:0]  PF0_DPA_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  VF0_ARI_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  VF1_ARI_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  VF2_ARI_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  VF3_ARI_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  VF4_ARI_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  VF5_ARI_CAP_NEXTPTR = 12'h000,
  parameter         VF0_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         VF0_TPHR_CAP_ENABLE = "FALSE",
  parameter         VF0_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  VF0_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0]   VF0_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter [1:0]   VF0_TPHR_CAP_ST_TABLE_LOC = 3'b10,
  parameter [10:0]  VF0_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0]   VF0_TPHR_CAP_VER = 4'h1,
  parameter         VF1_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         VF1_TPHR_CAP_ENABLE = "FALSE",
  parameter         VF1_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  VF1_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0]   VF1_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter [1:0]   VF1_TPHR_CAP_ST_TABLE_LOC = 3'b10,
  parameter [10:0]  VF1_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0]   VF1_TPHR_CAP_VER = 4'h1,
  parameter         VF2_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         VF2_TPHR_CAP_ENABLE = "FALSE",
  parameter         VF2_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  VF2_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0]   VF2_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter [1:0]   VF2_TPHR_CAP_ST_TABLE_LOC = 3'b10,
  parameter [10:0]  VF2_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0]   VF2_TPHR_CAP_VER = 4'h1,
  parameter         VF3_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         VF3_TPHR_CAP_ENABLE = "FALSE",
  parameter         VF3_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  VF3_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0]   VF3_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter [1:0]   VF3_TPHR_CAP_ST_TABLE_LOC = 3'b10,
  parameter [10:0]  VF3_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0]   VF3_TPHR_CAP_VER = 4'h1,
  parameter         VF4_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         VF4_TPHR_CAP_ENABLE = "FALSE",
  parameter         VF4_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  VF4_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0]   VF4_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter [1:0]   VF4_TPHR_CAP_ST_TABLE_LOC = 3'b10,
  parameter [10:0]  VF4_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0]   VF4_TPHR_CAP_VER = 4'h1,
  parameter         VF5_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         VF5_TPHR_CAP_ENABLE = "FALSE",
  parameter         VF5_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  VF5_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0]   VF5_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter [1:0]   VF5_TPHR_CAP_ST_TABLE_LOC = 3'b10,
  parameter [10:0]  VF5_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0]   VF5_TPHR_CAP_VER = 4'h1,
  parameter  [4:0]  PF0_DPA_CAP_SUB_STATE_CONTROL = 5'h00,
  parameter         PF0_DPA_CAP_SUB_STATE_CONTROL_EN = "TRUE",
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 = 8'h00,
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 = 8'h00,
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 = 8'h00,
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 = 8'h00,
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 = 8'h00,
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 = 8'h00,
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 = 8'h00,
  parameter  [7:0]  PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 = 8'h00,
  parameter  [3:0]  PF0_DPA_CAP_VER = 4'h1,
  parameter [11:0]  PF0_DSN_CAP_NEXTPTR = 12'h10C,
  parameter  [4:0]  PF0_EXPANSION_ROM_APERTURE_SIZE = 5'h03,
  parameter         PF0_EXPANSION_ROM_ENABLE = "FALSE",
  parameter  [7:0]  PF0_INTERRUPT_LINE = 8'h00,
  parameter  [2:0]  PF0_INTERRUPT_PIN = 3'h1,
  parameter integer PF0_LINK_CAP_ASPM_SUPPORT = 0,
  parameter integer PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 = 7,
  parameter integer PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 = 7,
  parameter integer PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 = 7,
  parameter integer PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 = 7,
  parameter integer PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 = 7,
  parameter integer PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 = 7,
  parameter integer PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 = 7,
  parameter integer PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 = 7,
  parameter integer PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 = 7,
  parameter integer PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 = 7,
  parameter integer PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 = 7,
  parameter integer PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 = 7,
  parameter         PF0_LINK_STATUS_SLOT_CLOCK_CONFIG = "TRUE",
  parameter  [9:0]  PF0_LTR_CAP_MAX_NOSNOOP_LAT = 10'h000,
  parameter  [9:0]  PF0_LTR_CAP_MAX_SNOOP_LAT = 10'h000,
  parameter [11:0]  PF0_LTR_CAP_NEXTPTR = 12'h000,
  parameter  [3:0]  PF0_LTR_CAP_VER = 4'h1,
  parameter  [7:0]  PF0_MSIX_CAP_NEXTPTR = 8'h00,
  parameter integer PF0_MSIX_CAP_PBA_BIR = 0,
  parameter         PF0_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer PF0_MSIX_CAP_TABLE_BIR = 0,
  parameter         PF0_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  PF0_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer PF0_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  PF0_MSI_CAP_NEXTPTR = 8'h00,
  parameter [11:0]  PF0_PB_CAP_NEXTPTR = 12'h000,
  parameter         PF0_PB_CAP_SYSTEM_ALLOCATED = "FALSE",
  parameter  [3:0]  PF0_PB_CAP_VER = 4'h1,
  parameter  [7:0]  PF0_PM_CAP_ID = 8'h01,
  parameter  [7:0]  PF0_PM_CAP_NEXTPTR = 8'h00,
  parameter         PF0_PM_CAP_PMESUPPORT_D0 = "TRUE",
  parameter         PF0_PM_CAP_PMESUPPORT_D1 = "TRUE",
  parameter         PF0_PM_CAP_PMESUPPORT_D3HOT = "TRUE",
  parameter         PF0_PM_CAP_SUPP_D1_STATE = "TRUE",
  parameter  [2:0]  PF0_PM_CAP_VER_ID = 3'h3,
  parameter         PF0_PM_CSR_NOSOFTRESET = "TRUE",
  parameter         PF0_RBAR_CAP_ENABLE = "FALSE",
  parameter  [2:0]  PF0_RBAR_CAP_INDEX0 = 3'h0,
  parameter  [2:0]  PF0_RBAR_CAP_INDEX1 = 3'h0,
  parameter  [2:0]  PF0_RBAR_CAP_INDEX2 = 3'h0,
  parameter [11:0]  PF0_RBAR_CAP_NEXTPTR = 12'h000,
  parameter [19:0]  PF0_RBAR_CAP_SIZE0 = 20'h00000,
  parameter [19:0]  PF0_RBAR_CAP_SIZE1 = 20'h00000,
  parameter [19:0]  PF0_RBAR_CAP_SIZE2 = 20'h00000,
  parameter  [3:0]  PF0_RBAR_CAP_VER = 4'h1,
  parameter  [2:0]  PF0_RBAR_NUM = 3'h1,
  parameter  [7:0]  PF0_REVISION_ID = 8'h00,
  parameter  [4:0]  PF0_SRIOV_BAR0_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_SRIOV_BAR0_CONTROL = 3'h4,
  parameter  [4:0]  PF0_SRIOV_BAR1_APERTURE_SIZE = 5'h00,
  parameter  [2:0]  PF0_SRIOV_BAR1_CONTROL = 3'h0,
  parameter  [4:0]  PF0_SRIOV_BAR2_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_SRIOV_BAR2_CONTROL = 3'h4,
  parameter  [4:0]  PF0_SRIOV_BAR3_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_SRIOV_BAR3_CONTROL = 3'h0,
  parameter  [4:0]  PF0_SRIOV_BAR4_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_SRIOV_BAR4_CONTROL = 3'h4,
  parameter  [4:0]  PF0_SRIOV_BAR5_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF0_SRIOV_BAR5_CONTROL = 3'h0,
  parameter [15:0]  PF0_SRIOV_CAP_INITIAL_VF = 16'h0000,
  parameter [11:0]  PF0_SRIOV_CAP_NEXTPTR = 12'h000,
  parameter [15:0]  PF0_SRIOV_CAP_TOTAL_VF = 16'h0000,
  parameter  [3:0]  PF0_SRIOV_CAP_VER = 4'h1,
  parameter [15:0]  PF0_SRIOV_FIRST_VF_OFFSET = 16'h0000,
  parameter [15:0]  PF0_SRIOV_FUNC_DEP_LINK = 16'h0000,
  parameter [31:0]  PF0_SRIOV_SUPPORTED_PAGE_SIZE = 32'h00000000,
  parameter [15:0]  PF0_SRIOV_VF_DEVICE_ID = 16'h0000,
  parameter [15:0]  PF0_SUBSYSTEM_VENDOR_ID = 16'h0000,
  parameter [15:0]  PF0_SUBSYSTEM_ID = 16'h0000,
  parameter         PF0_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         PF0_TPHR_CAP_ENABLE = "TRUE",
  parameter         PF0_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  PF0_TPHR_CAP_NEXTPTR = 12'h300,
  parameter  [2:0]  PF0_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter  [1:0]  PF0_TPHR_CAP_ST_TABLE_LOC = 2'b10,
  parameter [10:0]  PF0_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter  [3:0]  PF0_TPHR_CAP_VER = 4'h1,
  parameter [11:0]  PF0_VC_CAP_NEXTPTR = 12'h000,
  parameter  [3:0]  PF0_VC_CAP_VER = 4'h1,
  parameter         PF1_AER_CAP_ECRC_CHECK_CAPABLE = "FALSE",
  parameter         PF1_AER_CAP_ECRC_GEN_CAPABLE = "FALSE",
  parameter [11:0]  PF1_AER_CAP_NEXTPTR = 12'h000,
  parameter [11:0]  PF1_ARI_CAP_NEXTPTR = 12'h000,
  parameter  [7:0]  PF1_ARI_CAP_NEXT_FUNC = 8'h00,
  parameter  [4:0]  PF1_BAR0_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_BAR0_CONTROL = 3'h4,
  parameter  [4:0]  PF1_BAR1_APERTURE_SIZE = 5'h00,
  parameter  [2:0]  PF1_BAR1_CONTROL = 3'h0,
  parameter  [4:0]  PF1_BAR2_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_BAR2_CONTROL = 3'h4,
  parameter  [4:0]  PF1_BAR3_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_BAR3_CONTROL = 3'h0,
  parameter  [4:0]  PF1_BAR4_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_BAR4_CONTROL = 3'h4,
  parameter  [4:0]  PF1_BAR5_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_BAR5_CONTROL = 3'h0,
  parameter  [7:0]  PF1_BIST_REGISTER = 8'h00,
  parameter  [7:0]  PF1_CAPABILITY_POINTER = 8'h50,
  parameter [23:0]  PF1_CLASS_CODE = 24'h000000,
  parameter [15:0]  PF1_DEVICE_ID = 16'h0000,
  parameter  [2:0]  PF1_DEV_CAP_MAX_PAYLOAD_SIZE = 3'h3,
  parameter [11:0]  PF1_DPA_CAP_NEXTPTR = 12'h000,
  parameter  [4:0]  PF1_DPA_CAP_SUB_STATE_CONTROL = 5'h00,
  parameter         PF1_DPA_CAP_SUB_STATE_CONTROL_EN = "TRUE",
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 = 8'h00,
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 = 8'h00,
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 = 8'h00,
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 = 8'h00,
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 = 8'h00,
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 = 8'h00,
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 = 8'h00,
  parameter  [7:0]  PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 = 8'h00,
  parameter  [3:0]  PF1_DPA_CAP_VER = 4'h1,
  parameter [11:0]  PF1_DSN_CAP_NEXTPTR = 12'h10C,
  parameter  [4:0]  PF1_EXPANSION_ROM_APERTURE_SIZE = 5'h03,
  parameter         PF1_EXPANSION_ROM_ENABLE = "FALSE",
  parameter  [7:0]  PF1_INTERRUPT_LINE = 8'h00,
  parameter  [2:0]  PF1_INTERRUPT_PIN = 3'h1,
  parameter  [7:0]  PF1_MSIX_CAP_NEXTPTR = 8'h00,
  parameter integer PF1_MSIX_CAP_PBA_BIR = 0,
  parameter         PF1_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer PF1_MSIX_CAP_TABLE_BIR = 0,
  parameter         PF1_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  PF1_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer PF1_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  PF1_MSI_CAP_NEXTPTR = 8'h00,
  parameter [11:0]  PF1_PB_CAP_NEXTPTR = 12'h000,
  parameter         PF1_PB_CAP_SYSTEM_ALLOCATED = "FALSE",
  parameter  [3:0]  PF1_PB_CAP_VER = 4'h1,
  parameter  [7:0]  PF1_PM_CAP_ID = 8'h01,
  parameter  [7:0]  PF1_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  PF1_PM_CAP_VER_ID = 3'h3,
  parameter         PF1_RBAR_CAP_ENABLE = "FALSE",
  parameter  [2:0]  PF1_RBAR_CAP_INDEX0 = 3'h0,
  parameter  [2:0]  PF1_RBAR_CAP_INDEX1 = 3'h0,
  parameter  [2:0]  PF1_RBAR_CAP_INDEX2 = 3'h0,
  parameter [11:0]  PF1_RBAR_CAP_NEXTPTR = 12'h000,
  parameter [19:0]  PF1_RBAR_CAP_SIZE0 = 20'h00000,
  parameter [19:0]  PF1_RBAR_CAP_SIZE1 = 20'h00000,
  parameter [19:0]  PF1_RBAR_CAP_SIZE2 = 20'h00000,
  parameter  [3:0]  PF1_RBAR_CAP_VER = 4'h1,
  parameter  [2:0]  PF1_RBAR_NUM = 3'h1,
  parameter  [7:0]  PF1_REVISION_ID = 8'h00,
  parameter  [4:0]  PF1_SRIOV_BAR0_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_SRIOV_BAR0_CONTROL = 3'h4,
  parameter  [4:0]  PF1_SRIOV_BAR1_APERTURE_SIZE = 5'h00,
  parameter  [2:0]  PF1_SRIOV_BAR1_CONTROL = 3'h0,
  parameter  [4:0]  PF1_SRIOV_BAR2_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_SRIOV_BAR2_CONTROL = 3'h4,
  parameter  [4:0]  PF1_SRIOV_BAR3_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_SRIOV_BAR3_CONTROL = 3'h0,
  parameter  [4:0]  PF1_SRIOV_BAR4_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_SRIOV_BAR4_CONTROL = 3'h4,
  parameter  [4:0]  PF1_SRIOV_BAR5_APERTURE_SIZE = 5'h03,
  parameter  [2:0]  PF1_SRIOV_BAR5_CONTROL = 3'h0,
  parameter [15:0]  PF1_SRIOV_CAP_INITIAL_VF = 16'h0000,
  parameter [11:0]  PF1_SRIOV_CAP_NEXTPTR = 12'h000,
  parameter [15:0]  PF1_SRIOV_CAP_TOTAL_VF = 16'h0000,
  parameter  [3:0]  PF1_SRIOV_CAP_VER = 4'h1,
  parameter [15:0]  PF1_SRIOV_FIRST_VF_OFFSET = 16'h0000,
  parameter [15:0]  PF1_SRIOV_FUNC_DEP_LINK = 16'h0000,
  parameter [31:0]  PF1_SRIOV_SUPPORTED_PAGE_SIZE = 32'h00000000,
  parameter [15:0]  PF1_SRIOV_VF_DEVICE_ID = 16'h0000,
  parameter [15:0]  PF1_SUBSYSTEM_ID = 16'h0000,
  parameter         PF1_TPHR_CAP_DEV_SPECIFIC_MODE = "FALSE",
  parameter         PF1_TPHR_CAP_ENABLE = "TRUE",
  parameter         PF1_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  PF1_TPHR_CAP_NEXTPTR = 12'h300,
  parameter  [2:0]  PF1_TPHR_CAP_ST_MODE_SEL = 3'b010,
  parameter  [1:0]  PF1_TPHR_CAP_ST_TABLE_LOC = 2'b10,
  parameter [10:0]  PF1_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter  [3:0]  PF1_TPHR_CAP_VER = 4'h1,
  parameter         PL_DISABLE_EI_INFER_IN_L0 = "FALSE",
  parameter         PL_DISABLE_GEN3_DC_BALANCE = "FALSE",
  parameter         PL_DISABLE_SCRAMBLING = "FALSE",
  parameter         PL_DISABLE_UPCONFIG_CAPABLE = "FALSE",
  parameter         PL_EQ_ADAPT_DISABLE_COEFF_CHECK = "FALSE",
  parameter         PL_EQ_ADAPT_DISABLE_PRESET_CHECK = "FALSE",
  parameter  [4:0]  PL_EQ_ADAPT_ITER_COUNT = 5'h02,
  parameter  [1:0]  PL_EQ_ADAPT_REJECT_RETRY_COUNT = 2'h1,
  parameter         PL_EQ_BYPASS_PHASE23 = "FALSE",
  parameter         PL_EQ_SHORT_ADAPT_PHASE = "FALSE",
  parameter [15:0]  PL_LANE0_EQ_CONTROL = 16'h3400,
  parameter [15:0]  PL_LANE1_EQ_CONTROL = 16'h3400,
  parameter [15:0]  PL_LANE2_EQ_CONTROL = 16'h3400,
  parameter [15:0]  PL_LANE3_EQ_CONTROL = 16'h3400,
  parameter [15:0]  PL_LANE4_EQ_CONTROL = 16'h3400,
  parameter [15:0]  PL_LANE5_EQ_CONTROL = 16'h3400,
  parameter [15:0]  PL_LANE6_EQ_CONTROL = 16'h3400,
  parameter [15:0]  PL_LANE7_EQ_CONTROL = 16'h3400,
  parameter integer PL_N_FTS_COMCLK_GEN1 = 255,
  parameter integer PL_N_FTS_COMCLK_GEN2 = 255,
  parameter integer PL_N_FTS_COMCLK_GEN3 = 255,
  parameter integer PL_N_FTS_GEN1 = 255,
  parameter integer PL_N_FTS_GEN2 = 255,
  parameter integer PL_N_FTS_GEN3 = 255,
  parameter         PL_UPSTREAM_FACING = "TRUE",
  parameter [15:0]  PM_ASPML0S_TIMEOUT = 16'h05DC,
  parameter [19:0]  PM_ASPML1_ENTRY_DELAY = 20'h01D4C,
  parameter         PM_ENABLE_SLOT_POWER_CAPTURE = "TRUE",
  parameter [31:0]  PM_L1_REENTRY_DELAY = 32'h000061A8,
  parameter [19:0]  PM_PME_SERVICE_TIMEOUT_DELAY = 20'h186A0,
  parameter [15:0]  PM_PME_TURNOFF_ACK_DELAY = 16'h0064,
  parameter         SIM_VERSION = "1.0",
  parameter integer SPARE_BIT0 = 0,
  parameter integer SPARE_BIT1 = 0,
  parameter integer SPARE_BIT2 = 0,
  parameter integer SPARE_BIT3 = 0,
  parameter integer SPARE_BIT4 = 0,
  parameter integer SPARE_BIT5 = 0,
  parameter integer SPARE_BIT6 = 0,
  parameter integer SPARE_BIT7 = 0,
  parameter integer SPARE_BIT8 = 0,
  parameter  [7:0]  SPARE_BYTE0 = 8'h00,
  parameter  [7:0]  SPARE_BYTE1 = 8'h00,
  parameter  [7:0]  SPARE_BYTE2 = 8'h00,
  parameter  [7:0]  SPARE_BYTE3 = 8'h00,
  parameter [31:0]  SPARE_WORD0 = 32'h00000000,
  parameter [31:0]  SPARE_WORD1 = 32'h00000000,
  parameter [31:0]  SPARE_WORD2 = 32'h00000000,
  parameter [31:0]  SPARE_WORD3 = 32'h00000000,
  parameter         SRIOV_CAP_ENABLE = "FALSE",
  parameter [23:0]  TL_COMPL_TIMEOUT_REG0 = 24'hBEBC20,
  parameter [27:0]  TL_COMPL_TIMEOUT_REG1 = 28'h3211620,
  parameter [11:0]  TL_CREDITS_CD = 12'h3E0,
  parameter  [7:0]  TL_CREDITS_CH = 8'h20,
  parameter [11:0]  TL_CREDITS_NPD = 12'h028,
  parameter  [7:0]  TL_CREDITS_NPH = 8'h20,
  parameter [11:0]  TL_CREDITS_PD = 12'h198,
  parameter  [7:0]  TL_CREDITS_PH = 8'h20,
  parameter         TL_ENABLE_MESSAGE_RID_CHECK_ENABLE = "TRUE",
  parameter         TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE = "FALSE",
  parameter         TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE = "FALSE",
  parameter         TL_LEGACY_MODE_ENABLE = "FALSE",
  parameter         TL_PF_ENABLE_REG = "FALSE",
  parameter         TL_TAG_MGMT_ENABLE = "TRUE",
  parameter  [7:0]  VF0_CAPABILITY_POINTER = 8'h50,
  parameter integer VF0_MSIX_CAP_PBA_BIR = 0,
  parameter         VF0_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF0_MSIX_CAP_TABLE_BIR = 0,
  parameter         VF0_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF0_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF0_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF0_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF0_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF0_PM_CAP_VER_ID = 3'h3,
  parameter integer VF1_MSIX_CAP_PBA_BIR = 0,
  parameter         VF1_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF1_MSIX_CAP_TABLE_BIR = 0,
  parameter         VF1_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF1_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF1_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF1_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF1_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF1_PM_CAP_VER_ID = 3'h3,
  parameter integer VF2_MSIX_CAP_PBA_BIR = 0,
  parameter         VF2_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF2_MSIX_CAP_TABLE_BIR = 0,
  parameter         VF2_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF2_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF2_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF2_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF2_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF2_PM_CAP_VER_ID = 3'h3,
  parameter integer VF3_MSIX_CAP_PBA_BIR = 0,
  parameter         VF3_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF3_MSIX_CAP_TABLE_BIR = 0,
  parameter         VF3_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF3_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF3_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF3_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF3_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF3_PM_CAP_VER_ID = 3'h3,
  parameter integer VF4_MSIX_CAP_PBA_BIR = 0,
  parameter         VF4_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF4_MSIX_CAP_TABLE_BIR = 0,
  parameter         VF4_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF4_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF4_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF4_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF4_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF4_PM_CAP_VER_ID = 3'h3,
  parameter integer VF5_MSIX_CAP_PBA_BIR = 0,
  parameter         VF5_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF5_MSIX_CAP_TABLE_BIR = 0,
  parameter         VF5_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF5_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF5_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF5_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF5_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF5_PM_CAP_VER_ID = 3'h3,
  parameter         IMPL_TARGET = "HARD",
  parameter         NO_DECODE_LOGIC = "FALSE",
  parameter         COMPLETION_SPACE = "16KB",
  // Tandem PROM/PCIe Parameters
  parameter         PCIE_FAST_CONFIG = "NONE",  // NONE, TANDEM_PROM, TANDEM_PCIE
  //Parameters below are used during GU Customization.  Do not change.
  parameter         gen_x0y0_ucf = "FALSE",
  parameter         gen_x0y1_ucf = "FALSE",
  parameter         gen_x0y2_ucf = "FALSE",
  parameter         gen_x0y3_ucf = "FALSE",
  parameter         pcie_blk_locn = 0,
  parameter         silicon_revision = "GES",
  parameter         xlnx_ref_board = 0,
  parameter         MSI_EN = "TRUE",
  parameter         MSIX_EN = "FALSE",
  parameter         SHARED_LOGIC_IN_CORE = "FALSE",
  parameter         TX_FC_IF = "FALSE",
  parameter         CFG_FC_IF = "FALSE",
  parameter         CFG_EXT_IF = "FALSE",
  parameter         CFG_STATUS_IF = "FALSE",
  parameter         PER_FUNC_STATUS_IF = "FALSE",
  parameter         CFG_MGMT_IF = "FALSE",
  parameter         RCV_MSG_IF = "FALSE",
  parameter         CFG_TX_MSG_IF = "FALSE",
  parameter         CFG_CTL_IF = "FALSE",
  parameter         EXT_STARTUP_PRIMITIVE = "FALSE",
  parameter         EXT_PIPE_INTERFACE = "FALSE",
  parameter         POWER_DOWN = "FALSE",
  parameter         PCIE_ASYNC_EN = "FALSE",
  parameter         DEV_PORT_TYPE = 0,
  parameter         ENABLE_JTAG_DBG = "FALSE",
  parameter         MULT_PF_DES     = "FALSE",
  parameter         DBG_DESCRAMBLE_EN = "TRUE",
  parameter         WIN10_INTEROP = "FALSE" 

)  (

  //----------------------------------------------------------------------------------------------------------------//
  // 1. PCI Express (pci_exp) Interface                                                                             //
  //----------------------------------------------------------------------------------------------------------------//

  // Tx
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_txn,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_txp,

  // Rx
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_rxn,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_rxp,

  //----------------------------------------------------------------------------------------------------------------//
  // 2. Clock & GT COMMON Sharing Interface                                                                         //
  //----------------------------------------------------------------------------------------------------------------//
  // Shared Logic Internal
  output                                     int_pclk_out_slave,
  output                                     int_pipe_rxusrclk_out,
  output [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]  int_rxoutclk_out,
  output                                     int_dclk_out,
  output                                     int_userclk1_out,
  output                                     int_userclk2_out,
  output                                     int_oobclk_out,
  output  [1:0]                              int_qplllock_out,
  output  [1:0]                              int_qplloutclk_out,
  output  [1:0]                              int_qplloutrefclk_out,
  input  [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]  int_pclk_sel_slave,
 
  // Shared Logic External Clock
  input                                       pipe_pclk_in,
  input                                       pipe_rxusrclk_in,
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_rxoutclk_in,
  input                                       pipe_dclk_in,
  input                                       pipe_userclk1_in,
  input                                       pipe_userclk2_in,
  input                                       pipe_oobclk_in,
  input                                       pipe_mmcm_lock_in,
  output                                      pipe_txoutclk_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_rxoutclk_out,
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_pclk_sel_out,
  output                                      pipe_gen3_out,

  // Shared Logic External GT COMMON  
  input  [11:0]                               qpll_drp_crscode,
  input  [17:0]                               qpll_drp_fsm,
  input  [1:0]                                qpll_drp_done,
  input  [1:0]                                qpll_drp_reset,
  input  [1:0]                                qpll_qplllock,
  input  [1:0]                                qpll_qplloutclk,
  input  [1:0]                                qpll_qplloutrefclk,
  output                                      qpll_qplld,
  output [1:0]                                qpll_qpllreset,
  output                                      qpll_drp_clk,
  output                                      qpll_drp_rst_n,
  output                                      qpll_drp_ovrd,
  output                                      qpll_drp_gen3,
  output                                      qpll_drp_start,

  // Status
  output                                      mmcm_lock,

//----------------------------------------------------------------------------------------------------------------//
  // 3. AXI Interface                                                                                               //
  //----------------------------------------------------------------------------------------------------------------//

  // Common
  output                                     user_clk,
  output reg                                 user_reset,
  output                                     user_lnk_up,
  output                                     user_app_rdy,

  input                                      s_axis_rq_tlast,
  input  [C_DATA_WIDTH-1:0]                  s_axis_rq_tdata,
  input  [59:0]                              s_axis_rq_tuser,
  input  [KEEP_WIDTH-1:0]                    s_axis_rq_tkeep,
  output [3:0]                               s_axis_rq_tready,
  input                                      s_axis_rq_tvalid,

  output  [C_DATA_WIDTH-1:0]                 m_axis_rc_tdata,
  output  [74:0]                             m_axis_rc_tuser,
  output                                     m_axis_rc_tlast,
  output  [KEEP_WIDTH-1:0]                   m_axis_rc_tkeep,
  output                                     m_axis_rc_tvalid,
  input                                      m_axis_rc_tready,

  output  [C_DATA_WIDTH-1:0]                 m_axis_cq_tdata,
  output  [84:0]                             m_axis_cq_tuser,
  output                                     m_axis_cq_tlast,
  output  [KEEP_WIDTH-1:0]                   m_axis_cq_tkeep,
  output                                     m_axis_cq_tvalid,
  input                                      m_axis_cq_tready,

  input  [C_DATA_WIDTH-1:0]                  s_axis_cc_tdata,
  input  [32:0]                              s_axis_cc_tuser,
  input                                      s_axis_cc_tlast,
  input  [KEEP_WIDTH-1:0]                    s_axis_cc_tkeep,
  input                                      s_axis_cc_tvalid,
  output  [3:0]                              s_axis_cc_tready,

  output  [3:0]                              pcie_rq_seq_num,
  output                                     pcie_rq_seq_num_vld,
  output  [5:0]                              pcie_rq_tag,
  output                                     pcie_rq_tag_vld,

  output  [1:0]                              pcie_tfc_nph_av,
  output  [1:0]                              pcie_tfc_npd_av,
  input                                      pcie_cq_np_req,
  output  [5:0]                              pcie_cq_np_req_count,

  //----------------------------------------------------------------------------------------------------------------//
  // 4. Configuration (CFG) Interface                                                                               //
  //----------------------------------------------------------------------------------------------------------------//

  //----------------------------------------------------------------------------------------------------------------//
  // EP and RP                                                                                                      //
  //----------------------------------------------------------------------------------------------------------------//

  output                                     cfg_phy_link_down,
  output  [1:0]                              cfg_phy_link_status,
  output  [3:0]                              cfg_negotiated_width,
  output  [2:0]                              cfg_current_speed,
  output  [2:0]                              cfg_max_payload,
  output  [2:0]                              cfg_max_read_req,
  output  [7:0]                              cfg_function_status,
  output  [5:0]                              cfg_function_power_state,
  output  [11:0]                             cfg_vf_status,
  output  [17:0]                             cfg_vf_power_state,
  output  [1:0]                              cfg_link_power_state,

  // Management Interface
  input  [18:0]                              cfg_mgmt_addr,
  input                                      cfg_mgmt_write,
  input  [31:0]                              cfg_mgmt_write_data,
  input  [3:0]                               cfg_mgmt_byte_enable,
  input                                      cfg_mgmt_read,
  output  [31:0]                             cfg_mgmt_read_data,
  output                                     cfg_mgmt_read_write_done,
  input                                      cfg_mgmt_type1_cfg_reg_access,

  // Error Reporting Interface
  output                                     cfg_err_cor_out,
  output                                     cfg_err_nonfatal_out,
  output                                     cfg_err_fatal_out,
 // output                                   cfg_local_error,

  output                                     cfg_ltr_enable,
  output  [5:0]                              cfg_ltssm_state,
  output  [1:0]                              cfg_rcb_status,
  output  [1:0]                              cfg_dpa_substate_change,
  output  [1:0]                              cfg_obff_enable,
  output                                     cfg_pl_status_change,

  output  [1:0]                              cfg_tph_requester_enable,
  output  [5:0]                              cfg_tph_st_mode,
  output  [5:0]                              cfg_vf_tph_requester_enable,
  output  [17:0]                             cfg_vf_tph_st_mode,

  output                                     cfg_msg_received,
  output  [7:0]                              cfg_msg_received_data,
  output  [4:0]                              cfg_msg_received_type,

  input                                      cfg_msg_transmit,
  input   [2:0]                              cfg_msg_transmit_type,
  input   [31:0]                             cfg_msg_transmit_data,
  output                                     cfg_msg_transmit_done,

  output  [7:0]                              cfg_fc_ph,
  output  [11:0]                             cfg_fc_pd,
  output  [7:0]                              cfg_fc_nph,
  output  [11:0]                             cfg_fc_npd,
  output  [7:0]                              cfg_fc_cplh,
  output  [11:0]                             cfg_fc_cpld,
  input   [2:0]                              cfg_fc_sel,

  input   [2:0]                              cfg_per_func_status_control,
  output  [15:0]                             cfg_per_func_status_data,
  input   [2:0]                              cfg_per_function_number,
  input                                      cfg_per_function_output_request,
  output                                     cfg_per_function_update_done,

  input   [15:0]                             cfg_subsys_vend_id,
  input   [63:0]                             cfg_dsn,
  input                                      cfg_power_state_change_ack,
  output                                     cfg_power_state_change_interrupt,
  input                                      cfg_err_cor_in,
  input                                      cfg_err_uncor_in,

  output  [1:0]                              cfg_flr_in_process,
  input   [1:0]                              cfg_flr_done,
  output  [5:0]                              cfg_vf_flr_in_process,
  input   [5:0]                              cfg_vf_flr_done,

  input                                      cfg_link_training_enable,

  output                                     cfg_ext_read_received,
  output                                     cfg_ext_write_received,
  output  [9:0]                              cfg_ext_register_number,
  output  [7:0]                              cfg_ext_function_number,
  output  [31:0]                             cfg_ext_write_data,
  output  [3:0]                              cfg_ext_write_byte_enable,
  input   [31:0]                             cfg_ext_read_data,
  input                                      cfg_ext_read_data_valid,

  // Interrupt Interface Signals
  input   [3:0]                              cfg_interrupt_int,
  input   [1:0]                              cfg_interrupt_pending,
  output                                     cfg_interrupt_sent,

  output  [1:0]                              cfg_interrupt_msi_enable,
  output  [5:0]                              cfg_interrupt_msi_vf_enable,
  output  [5:0]                              cfg_interrupt_msi_mmenable,
  output                                     cfg_interrupt_msi_mask_update,
  output  [31:0]                             cfg_interrupt_msi_data,
  input   [3:0]                              cfg_interrupt_msi_select,
  input   [31:0]                             cfg_interrupt_msi_int,
  input   [63:0]                             cfg_interrupt_msi_pending_status,
  output                                     cfg_interrupt_msi_sent,
  output                                     cfg_interrupt_msi_fail,

  output  [1:0]                              cfg_interrupt_msix_enable,
  output  [1:0]                              cfg_interrupt_msix_mask,
  output  [5:0]                              cfg_interrupt_msix_vf_enable,
  output  [5:0]                              cfg_interrupt_msix_vf_mask,
  input   [31:0]                             cfg_interrupt_msix_data,
  input   [63:0]                             cfg_interrupt_msix_address,
  input                                      cfg_interrupt_msix_int,
  output                                     cfg_interrupt_msix_sent,
  output                                     cfg_interrupt_msix_fail,

  input   [2:0]                              cfg_interrupt_msi_attr,
  input                                      cfg_interrupt_msi_tph_present,
  input   [1:0]                              cfg_interrupt_msi_tph_type,
  input   [8:0]                              cfg_interrupt_msi_tph_st_tag,
  input   [2:0]                              cfg_interrupt_msi_function_number,

  output                                     cfg_hot_reset_out,
  input                                      cfg_config_space_enable,
  input                                      cfg_req_pm_transition_l23_ready,

  //----------------------------------------------------------------------------------------------------------------//
  // RP Only                                                                                                        //
  //----------------------------------------------------------------------------------------------------------------//

  input                                      cfg_hot_reset_in,
  input   [7:0]                              cfg_ds_port_number,
  input   [7:0]                              cfg_ds_bus_number,
  input   [4:0]                              cfg_ds_device_number,
  input   [2:0]                              cfg_ds_function_number,

  //----------------------------------------------------------------------------------------------------------------//
  // 6. TPH Interface                                                                                               //
  //----------------------------------------------------------------------------------------------------------------//
  input   [4:0]                              user_tph_stt_address,
  input   [2:0]                              user_tph_function_num,
  output  [31:0]                             user_tph_stt_read_data,
  output                                     user_tph_stt_read_data_valid,
  input                                      user_tph_stt_read_enable,

  //----------------------------------------------------------------------------------------------------------------//
  // 7. System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//

  input wire                                 sys_clk,
  input wire                                 sys_reset,
  input					     pipe_mmcm_rst_n,

//--------------TRANSCEIVER_DEBUG---------------------------------


  input   [ 2:0]                               pipe_txprbssel,        
  input   [ 2:0]                               pipe_rxprbssel,     
  input                                        pipe_txprbsforceerr,
  input                                        pipe_rxprbscntreset,
  input   [ 2:0]                               pipe_loopback,     

  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_rxprbserr,   
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]      pipe_txinhibit,   


  output  [4:0]                                pipe_rst_fsm,         
  output  [11:0]                               pipe_qrst_fsm,       
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*5)-1:0] pipe_rate_fsm,      
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*6)-1:0] pipe_sync_fsm_tx,  
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*7)-1:0] pipe_sync_fsm_rx, 
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*7)-1:0] pipe_drp_fsm,    

  output                                       pipe_rst_idle,         
  output                                       pipe_qrst_idle,       
  output                                       pipe_rate_idle,      
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_eyescandataerror,          
  output  [PL_LINK_CAP_MAX_LINK_WIDTH*3-1:0]   pipe_rxstatus,
  output  [PL_LINK_CAP_MAX_LINK_WIDTH*15-1:0]  pipe_dmonitorout,

  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_cpll_lock,
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] pipe_qpll_lock,
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_rxpmaresetdone,       
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  pipe_rxbufstatus,         
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_txphaligndone,       
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_txphinitdone,        
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_txdlysresetdone,    
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_rxphaligndone,      
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_rxdlysresetdone,     
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_rxsyncdone,       
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  pipe_rxdisperr,       
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  pipe_rxnotintable,      
  output  [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    pipe_rxcommadet,        

  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     gt_ch_drp_rdy,
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_0,          
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_1,         
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_2,        
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_3,       
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_4,      
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_5,     
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_6,    
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_7,   
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_8,  
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     pipe_debug_9, 
  output  [31:0]                               pipe_debug,

  input                                        free_run_clock,
//---- PIPE Ports to Core Top Level for PIPE Mode Simulation with 3rd Party IP/BFM/Xilinx BFM ------------------------
  input   [25:0]                               common_commands_in,
  input   [83:0]                               pipe_rx_0_sigs,
  input   [83:0]                               pipe_rx_1_sigs,
  input   [83:0]                               pipe_rx_2_sigs,
  input   [83:0]                               pipe_rx_3_sigs,
  input   [83:0]                               pipe_rx_4_sigs,
  input   [83:0]                               pipe_rx_5_sigs,
  input   [83:0]                               pipe_rx_6_sigs,
  input   [83:0]                               pipe_rx_7_sigs,
                         
  output  [25:0]                               common_commands_out,
  output  [83:0]                               pipe_tx_0_sigs,
  output  [83:0]                               pipe_tx_1_sigs,
  output  [83:0]                               pipe_tx_2_sigs,
  output  [83:0]                               pipe_tx_3_sigs,
  output  [83:0]                               pipe_tx_4_sigs,
  output  [83:0]                               pipe_tx_5_sigs,
  output  [83:0]                               pipe_tx_6_sigs,
  output  [83:0]                               pipe_tx_7_sigs,

  //--------------Channel DRP---------------------------------
  output                                       ext_ch_gt_drpclk,
  input   [(PL_LINK_CAP_MAX_LINK_WIDTH*9)-1:0] ext_ch_gt_drpaddr,
  input   [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpen,
  input   [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdi,
  input   [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpwe,

  output  [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdo,
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drprdy,
  //----------------------------------------------------------------------------------------------------------------//
  // 9. Tandem PROM/PCIE ICAP Primitive Ports                                                                       //
  //----------------------------------------------------------------------------------------------------------------//
  input                                        icap_clk,
  input                                        icap_csib,
  input                                        icap_rdwrb,
  input   [31:0]                               icap_i,
  output  [31:0]                               icap_o,

  output                                       pcie_drp_rdy,
  output             [15:0]                    pcie_drp_do,
  input                                        pcie_drp_clk,
  input                                        pcie_drp_en,
  input                                        pcie_drp_we,
  input              [10:0]                    pcie_drp_addr,
  input              [15:0]                    pcie_drp_di,


  //----------------------------------------------------------------------------------------------------------------//
  // 10. Tandem PROM/PCIE STARTUP primitive Ports                                                                    //
  //----------------------------------------------------------------------------------------------------------------//

  // This input should be used when the startup block is generated exteranl to the PCI Express Core
  input                                       startup_eos_in,     // 1-bit input: This signal should be driven by the EOS output of the STARTUP primitive.
  // These inputs and outputs may be use when the startup block is generated internal to the PCI Express Core.
  output                                      startup_cfgclk,     // 1-bit output: Configuration main clock output
  output                                      startup_cfgmclk,    // 1-bit output: Configuration internal oscillator clock output
  output                                      startup_eos,        // 1-bit output: Active high output signal indicating the End Of Startup
  output                                      startup_preq,       // 1-bit output: PROGRAM request to fabric output
  input                                       startup_clk,        // 1-bit input: User start-up clock input
  input                                       startup_gsr,        // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
  input                                       startup_gts,        // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
  input                                       startup_keyclearb,  // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
  input                                       startup_pack,       // 1-bit input: PROGRAM acknowledge input
  input                                       startup_usrcclko,   // 1-bit input: User CCLK input
  input                                       startup_usrcclkts,  // 1-bit input: User CCLK 3-state enable input
  input                                       startup_usrdoneo,   // 1-bit input: User DONE pin output control
  input                                       startup_usrdonets,  // 1-bit input: User DONE 3-state enable output

  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    cpllpd, 
  input [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]  txpd,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]  rxpd,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    txpdelecidlemode,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    txdetectrx,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    txelecidle,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] qpllpd, 
  input                                       powerdown

);


  localparam integer USER_CLK_FREQ              = ((PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? 5 : 4);
  localparam  [1:0]  CRM_USER_CLK_FREQ          = ((USER_CLK2_FREQ == 4) ? 2'b10: ((USER_CLK2_FREQ == 3) ? 2'b01 : 2'b00));
  localparam  [1:0]  AXISTEN_IF_WIDTH           = (C_DATA_WIDTH == 256) ? 2'b10 : ((C_DATA_WIDTH == 128) ? 2'b01 : 2'b00);
  localparam         CRM_CORE_CLK_FREQ_500      = ((PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? "TRUE" : "FALSE");
  localparam         INTERFACE_SPEED            = ((PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? "500 MHZ" : "250 MHZ");
  localparam         ENABLE_FAST_SIM_TRAINING   = "TRUE";

  wire         drp_clk_wire;
  wire         drp_en_wire;
  wire         drp_we_wire;
  wire [10:0]  drp_addr_wire;
  wire [15:0]  drp_di_wire;

  wire         drp_rdy_wire;
  wire  [15:0] drp_do_wire;

  wire         dt_654524_drp_clk;
  wire         dt_654524_drp_en;
  wire         dt_654524_drp_we;
  wire [10:0]  dt_654524_drp_addr;
  wire [15:0]  dt_654524_drp_di;

  wire         cfg_local_error;
  wire         rec_clk;
  wire         pipe_clk;
  wire         core_clk;
  wire         phy_rdy;

  wire [15:0]  cfg_vend_id        = PF0_VENDOR_ID;
  wire [15:0]  cfg_dev_id         = PF0_DEVICE_ID;
  wire [7:0]   cfg_rev_id         = PF0_REVISION_ID;
//  wire [15:0]  cfg_subsys_vend_id = PF0_SUBSYSTEM_VENDOR_ID;
  wire [15:0]  cfg_subsys_id      = PF0_SUBSYSTEM_ID;

  // PIPE Interface Wires
  wire         pipe_tx_reset;
  wire         pipe_rx0_polarity;
  wire         pipe_rx1_polarity;
  wire         pipe_rx2_polarity;
  wire         pipe_rx3_polarity;
  wire         pipe_rx4_polarity;
  wire         pipe_rx5_polarity;
  wire         pipe_rx6_polarity;
  wire         pipe_rx7_polarity;

  wire         pipe_tx0_compliance;
  wire         pipe_tx1_compliance;
  wire         pipe_tx2_compliance;
  wire         pipe_tx3_compliance;
  wire         pipe_tx4_compliance;
  wire         pipe_tx5_compliance;
  wire         pipe_tx6_compliance;
  wire         pipe_tx7_compliance;

  wire         pipe_rx0_data_valid;
  wire         pipe_rx1_data_valid;
  wire         pipe_rx2_data_valid;
  wire         pipe_rx3_data_valid;
  wire         pipe_rx4_data_valid;
  wire         pipe_rx5_data_valid;
  wire         pipe_rx6_data_valid;
  wire         pipe_rx7_data_valid;

  wire         pipe_tx0_elec_idle;
  wire         pipe_tx1_elec_idle;
  wire         pipe_tx2_elec_idle;
  wire         pipe_tx3_elec_idle;
  wire         pipe_tx4_elec_idle;
  wire         pipe_tx5_elec_idle;
  wire         pipe_tx6_elec_idle;
  wire         pipe_tx7_elec_idle;

  wire         pipe_rx0_start_block;
  wire         pipe_rx1_start_block;
  wire         pipe_rx2_start_block;
  wire         pipe_rx3_start_block;
  wire         pipe_rx4_start_block;
  wire         pipe_rx5_start_block;
  wire         pipe_rx6_start_block;
  wire         pipe_rx7_start_block;

  wire         pipe_tx_deemph;
  wire         pipe_tx_rcvr_det;
  wire   [1:0] pipe_tx_rate;
  wire   [2:0] pipe_tx_margin;
  wire         pipe_tx_swing;
  wire   [5:0] pipe_tx_eqfs;
  wire   [5:0] pipe_tx_eqlf;

  wire   [1:0] pipe_rx0_eqcontrol;
  wire   [1:0] pipe_rx1_eqcontrol;
  wire   [1:0] pipe_rx2_eqcontrol;
  wire   [1:0] pipe_rx3_eqcontrol;
  wire   [1:0] pipe_rx4_eqcontrol;
  wire   [1:0] pipe_rx5_eqcontrol;
  wire   [1:0] pipe_rx6_eqcontrol;
  wire   [1:0] pipe_rx7_eqcontrol;

  wire   [1:0] pipe_tx0_char_is_k;
  wire   [1:0] pipe_tx1_char_is_k;
  wire   [1:0] pipe_tx2_char_is_k;
  wire   [1:0] pipe_tx3_char_is_k;
  wire   [1:0] pipe_tx4_char_is_k;
  wire   [1:0] pipe_tx5_char_is_k;
  wire   [1:0] pipe_tx6_char_is_k;
  wire   [1:0] pipe_tx7_char_is_k;

  wire   [1:0] pipe_tx0_eqcontrol;
  wire   [1:0] pipe_tx1_eqcontrol;
  wire   [1:0] pipe_tx2_eqcontrol;
  wire   [1:0] pipe_tx3_eqcontrol;
  wire   [1:0] pipe_tx4_eqcontrol;
  wire   [1:0] pipe_tx5_eqcontrol;
  wire   [1:0] pipe_tx6_eqcontrol;
  wire   [1:0] pipe_tx7_eqcontrol;

  wire   [1:0] pipe_tx0_powerdown;
  wire   [1:0] pipe_tx1_powerdown;
  wire   [1:0] pipe_tx2_powerdown;
  wire   [1:0] pipe_tx3_powerdown;
  wire   [1:0] pipe_tx4_powerdown;
  wire   [1:0] pipe_tx5_powerdown;
  wire   [1:0] pipe_tx6_powerdown;
  wire   [1:0] pipe_tx7_powerdown;

  wire   [1:0] pipe_rx0_syncheader;
  wire   [1:0] pipe_rx1_syncheader;
  wire   [1:0] pipe_rx2_syncheader;
  wire   [1:0] pipe_rx3_syncheader;
  wire   [1:0] pipe_rx4_syncheader;
  wire   [1:0] pipe_rx5_syncheader;
  wire   [1:0] pipe_rx6_syncheader;
  wire   [1:0] pipe_rx7_syncheader;

  wire   [2:0] pipe_rx0_eqpreset;
  wire   [2:0] pipe_rx1_eqpreset;
  wire   [2:0] pipe_rx2_eqpreset;
  wire   [2:0] pipe_rx3_eqpreset;
  wire   [2:0] pipe_rx4_eqpreset;
  wire   [2:0] pipe_rx5_eqpreset;
  wire   [2:0] pipe_rx6_eqpreset;
  wire   [2:0] pipe_rx7_eqpreset;

  wire  [31:0] pipe_tx0_data;
  wire  [31:0] pipe_tx1_data;
  wire  [31:0] pipe_tx2_data;
  wire  [31:0] pipe_tx3_data;
  wire  [31:0] pipe_tx4_data;
  wire  [31:0] pipe_tx5_data;
  wire  [31:0] pipe_tx6_data;
  wire  [31:0] pipe_tx7_data;

  wire   [3:0] pipe_rx0_eq_txpreset;
  wire   [3:0] pipe_rx1_eq_txpreset;
  wire   [3:0] pipe_rx2_eq_txpreset;
  wire   [3:0] pipe_rx3_eq_txpreset;
  wire   [3:0] pipe_rx4_eq_txpreset;
  wire   [3:0] pipe_rx5_eq_txpreset;
  wire   [3:0] pipe_rx6_eq_txpreset;
  wire   [3:0] pipe_rx7_eq_txpreset;

  wire   [3:0] pipe_tx0_eqpreset;
  wire   [3:0] pipe_tx1_eqpreset;
  wire   [3:0] pipe_tx2_eqpreset;
  wire   [3:0] pipe_tx3_eqpreset;
  wire   [3:0] pipe_tx4_eqpreset;
  wire   [3:0] pipe_tx5_eqpreset;
  wire   [3:0] pipe_tx6_eqpreset;
  wire   [3:0] pipe_tx7_eqpreset;

  wire   [5:0] pipe_rx0_eq_lffs;
  wire   [5:0] pipe_rx1_eq_lffs;
  wire   [5:0] pipe_rx2_eq_lffs;
  wire   [5:0] pipe_rx3_eq_lffs;
  wire   [5:0] pipe_rx4_eq_lffs;
  wire   [5:0] pipe_rx5_eq_lffs;
  wire   [5:0] pipe_rx6_eq_lffs;
  wire   [5:0] pipe_rx7_eq_lffs;

  wire   [5:0] pipe_tx0_eqdeemph;
  wire   [5:0] pipe_tx1_eqdeemph;
  wire   [5:0] pipe_tx2_eqdeemph;
  wire   [5:0] pipe_tx3_eqdeemph;
  wire   [5:0] pipe_tx4_eqdeemph;
  wire   [5:0] pipe_tx5_eqdeemph;
  wire   [5:0] pipe_tx6_eqdeemph;
  wire   [5:0] pipe_tx7_eqdeemph;

  wire   [7:0] pipe_rx_slide;

  wire         pipe_rx0_elec_idle;
  wire         pipe_rx1_elec_idle;
  wire         pipe_rx2_elec_idle;
  wire         pipe_rx3_elec_idle;
  wire         pipe_rx4_elec_idle;
  wire         pipe_rx5_elec_idle;
  wire         pipe_rx6_elec_idle;
  wire         pipe_rx7_elec_idle;

  wire         pipe_rx0_eqdone;
  wire         pipe_rx1_eqdone;
  wire         pipe_rx2_eqdone;
  wire         pipe_rx3_eqdone;
  wire         pipe_rx4_eqdone;
  wire         pipe_rx5_eqdone;
  wire         pipe_rx6_eqdone;
  wire         pipe_rx7_eqdone;

  wire         pipe_rx0_eq_adapt_done;
  wire         pipe_rx1_eq_adapt_done;
  wire         pipe_rx2_eq_adapt_done;
  wire         pipe_rx3_eq_adapt_done;
  wire         pipe_rx4_eq_adapt_done;
  wire         pipe_rx5_eq_adapt_done;
  wire         pipe_rx6_eq_adapt_done;
  wire         pipe_rx7_eq_adapt_done;

  wire         pipe_rx0_eq_lffs_sel;
  wire         pipe_rx1_eq_lffs_sel;
  wire         pipe_rx2_eq_lffs_sel;
  wire         pipe_rx3_eq_lffs_sel;
  wire         pipe_rx4_eq_lffs_sel;
  wire         pipe_rx5_eq_lffs_sel;
  wire         pipe_rx6_eq_lffs_sel;
  wire         pipe_rx7_eq_lffs_sel;

  wire         pipe_rx0_phy_status;
  wire         pipe_rx1_phy_status;
  wire         pipe_rx2_phy_status;
  wire         pipe_rx3_phy_status;
  wire         pipe_rx4_phy_status;
  wire         pipe_rx5_phy_status;
  wire         pipe_rx6_phy_status;
  wire         pipe_rx7_phy_status;

  wire         pipe_rx0_valid;
  wire         pipe_rx1_valid;
  wire         pipe_rx2_valid;
  wire         pipe_rx3_valid;
  wire         pipe_rx4_valid;
  wire         pipe_rx5_valid;
  wire         pipe_rx6_valid;
  wire         pipe_rx7_valid;

  wire         pipe_tx0_eqdone;
  wire         pipe_tx1_eqdone;
  wire         pipe_tx2_eqdone;
  wire         pipe_tx3_eqdone;
  wire         pipe_tx4_eqdone;
  wire         pipe_tx5_eqdone;
  wire         pipe_tx6_eqdone;
  wire         pipe_tx7_eqdone;

  wire  [17:0] pipe_rx0_eq_new_txcoeff;
  wire  [17:0] pipe_rx1_eq_new_txcoeff;
  wire  [17:0] pipe_rx2_eq_new_txcoeff;
  wire  [17:0] pipe_rx3_eq_new_txcoeff;
  wire  [17:0] pipe_rx4_eq_new_txcoeff;
  wire  [17:0] pipe_rx5_eq_new_txcoeff;
  wire  [17:0] pipe_rx6_eq_new_txcoeff;
  wire  [17:0] pipe_rx7_eq_new_txcoeff;

  wire  [17:0] pipe_tx0_eqcoeff;
  wire  [17:0] pipe_tx1_eqcoeff;
  wire  [17:0] pipe_tx2_eqcoeff;
  wire  [17:0] pipe_tx3_eqcoeff;
  wire  [17:0] pipe_tx4_eqcoeff;
  wire  [17:0] pipe_tx5_eqcoeff;
  wire  [17:0] pipe_tx6_eqcoeff;
  wire  [17:0] pipe_tx7_eqcoeff;

  wire   [1:0] pipe_rx0_char_is_k;
  wire   [1:0] pipe_rx1_char_is_k;
  wire   [1:0] pipe_rx2_char_is_k;
  wire   [1:0] pipe_rx3_char_is_k;
  wire   [1:0] pipe_rx4_char_is_k;
  wire   [1:0] pipe_rx5_char_is_k;
  wire   [1:0] pipe_rx6_char_is_k;
  wire   [1:0] pipe_rx7_char_is_k;

  wire   [2:0] pipe_rx0_status;
  wire   [2:0] pipe_rx1_status;
  wire   [2:0] pipe_rx2_status;
  wire   [2:0] pipe_rx3_status;
  wire   [2:0] pipe_rx4_status;
  wire   [2:0] pipe_rx5_status;
  wire   [2:0] pipe_rx6_status;
  wire   [2:0] pipe_rx7_status;

  wire  [31:0] pipe_rx0_data;
  wire  [31:0] pipe_rx1_data;
  wire  [31:0] pipe_rx2_data;
  wire  [31:0] pipe_rx3_data;
  wire  [31:0] pipe_rx4_data;
  wire  [31:0] pipe_rx5_data;
  wire  [31:0] pipe_rx6_data;
  wire  [31:0] pipe_rx7_data;

  wire   [7:0] pipe_rx_syncdone;
  wire         PIPE_GEN3_OUT_wire;

  wire         sys_or_hot_rst;
  wire         user_lnk_up_int;
  reg          user_reset_int;

  // Wire Declaration for Inputs that are issolated in Tandem configuration
  wire         cfg_mgmt_write_wire;
  wire         cfg_mgmt_read_wire;
  wire   [2:0] cfg_per_func_status_control_wire;
  wire         cfg_per_function_output_request_wire;
  wire  [63:0] cfg_dsn_wire;
  wire         cfg_power_state_change_ack_wire;
  wire         cfg_err_cor_in_wire;
  wire         cfg_err_uncor_in_wire;
  wire   [1:0] cfg_flr_done_wire;
  wire   [5:0] cfg_vf_flr_done_wire;
  wire         cfg_link_training_enable_wire;
  wire         cfg_ext_read_data_valid_wire;
  wire   [1:0] cfg_interrupt_pending_wire;
  wire   [3:0] cfg_interrupt_msi_select_wire;
  wire  [63:0] cfg_interrupt_msi_pending_status_wire;
  wire         cfg_config_space_enable_wire;
  wire         cfg_req_pm_transition_l23_ready_wire;
  wire         cfg_hot_reset_in_wire;
  wire   [7:0] cfg_ds_port_number_wire;
  wire   [7:0] cfg_ds_bus_number_wire;
  wire   [4:0] cfg_ds_device_number_wire;
  wire   [2:0] cfg_ds_function_number_wire;
  wire   [4:0] user_tph_stt_address_wire;
  wire   [2:0] user_tph_function_num_wire;
  wire         user_tph_stt_read_enable_wire;
  // Wire Declaration for Outputs that are issolated in Tandem configuration
  wire         cfg_phy_link_down_wire;
  wire   [1:0] cfg_phy_link_status_wire;
  wire   [5:0] cfg_ltssm_state_wire;
  wire         cfg_hot_reset_out_wire;
  // Wire Declarations for tandem_cplr to pcie_top connections
  wire [C_DATA_WIDTH-1:0] s_axis_cc_tdata_wire;
  wire   [KEEP_WIDTH-1:0] s_axis_cc_tkeep_wire;
  wire                    s_axis_cc_tlast_wire;
  wire                    s_axis_cc_tvalid_wire;
  wire  [32:0]            s_axis_cc_tuser_wire;
  wire   [3:0]            s_axis_cc_tready_wire;
  wire                    s_axis_rq_tlast_wire;
  wire [C_DATA_WIDTH-1:0] s_axis_rq_tdata_wire;
  wire  [59:0]            s_axis_rq_tuser_wire;
  wire   [KEEP_WIDTH-1:0] s_axis_rq_tkeep_wire;
  wire   [3:0]            s_axis_rq_tready_wire;
  wire                    s_axis_rq_tvalid_wire;
  wire                    cfg_msg_transmit_done_wire;
  wire                    cfg_msg_transmit_wire;
  wire   [2:0]            cfg_msg_transmit_type_wire;
  wire  [31:0]            cfg_msg_transmit_data_wire;
  wire   [5:0]            pcie_rq_tag_wire;
  wire                    pcie_rq_tag_vld_wire;
  wire   [1:0]            pcie_tfc_nph_av_wire;
  wire   [1:0]            pcie_tfc_npd_av_wire;
  wire   [3:0]            pcie_rq_seq_num_wire;
  wire                    pcie_tfc_np_pl_empty_wire;
  wire                    pcie_rq_seq_num_vld_wire;
  wire   [7:0]            cfg_fc_ph_wire;
  wire   [7:0]            cfg_fc_nph_wire;
  wire   [7:0]            cfg_fc_cplh_wire;
  wire  [11:0]            cfg_fc_pd_wire;
  wire  [11:0]            cfg_fc_npd_wire;
  wire  [11:0]            cfg_fc_cpld_wire;
  wire   [2:0]            cfg_fc_sel_wire;
  wire [C_DATA_WIDTH-1:0] m_axis_cq_tdata_wire;
  wire                    m_axis_cq_tlast_wire;
  wire                    m_axis_cq_tvalid_wire;
  wire  [84:0]            m_axis_cq_tuser_wire;
  wire  [KEEP_WIDTH-1:0]  m_axis_cq_tkeep_wire;
  wire  [21:0]            m_axis_cq_tready_wire;
  wire                    pcie_cq_np_req_wire;
  wire   [5:0]            pcie_cq_np_req_count_wire;
  wire [C_DATA_WIDTH-1:0] m_axis_rc_tdata_wire;
  wire                    m_axis_rc_tlast_wire;
  wire                    m_axis_rc_tvalid_wire;
  wire  [74:0]            m_axis_rc_tuser_wire;
  wire  [KEEP_WIDTH-1:0]  m_axis_rc_tkeep_wire;
  wire  [21:0]            m_axis_rc_tready_wire;
  wire                    cfg_msg_received_wire;
  wire   [4:0]            cfg_msg_received_type_wire;
  wire   [7:0]            cfg_msg_received_data_wire;
  wire   [3:0]            cfg_interrupt_int_wire;
  wire  [31:0]            cfg_interrupt_msi_int_wire;
  wire                    cfg_interrupt_msix_int_wire;
  wire [C_DATA_WIDTH-1:0] s_axis_cc_tdata_cplr;
  wire   [KEEP_WIDTH-1:0] s_axis_cc_tkeep_cplr;
  wire                    s_axis_cc_tlast_cplr;
  wire                    s_axis_cc_tvalid_cplr;
  wire  [32:0]            s_axis_cc_tuser_cplr;
  wire                    m_axis_cq_tready_cplr;
  wire                    s_axis_rq_tlast_cplr;
  wire [C_DATA_WIDTH-1:0] s_axis_rq_tdata_cplr;
  wire  [59:0]            s_axis_rq_tuser_cplr;
  wire   [KEEP_WIDTH-1:0] s_axis_rq_tkeep_cplr;
  wire                    s_axis_rq_tvalid_cplr;
  wire                    cfg_msg_transmit_cplr;
  wire   [2:0]            cfg_msg_transmit_type_cplr;
  wire  [31:0]            cfg_msg_transmit_data_cplr;
  wire   [2:0]            cfg_fc_sel_cplr;
  wire                    pcie_cq_np_req_cplr;
  wire                    m_axis_rc_tready_cplr;

  // user_app_rdy signals which control the issolation muxes
  wire                         user_app_rdy_req;

// Variables and Parameters for Pipe mode Simulation

  wire  [7:0] pipe_rxeq_user_en          ;
  wire  [143:0] pipe_rxeq_user_txcoeff   ;

  generate
  if(PIPE_SIM_MODE=="FALSE") begin
     assign   pipe_rxeq_user_en      = 8'h00  ;
     assign   pipe_rxeq_user_txcoeff = 144'h0 ;
     assign         pipe_rx0_data_valid =  1'b0;
     assign         pipe_rx1_data_valid =  1'b0;
     assign         pipe_rx2_data_valid =  1'b0;
     assign         pipe_rx3_data_valid =  1'b0;
     assign         pipe_rx4_data_valid =  1'b0;
     assign         pipe_rx5_data_valid =  1'b0;
     assign         pipe_rx6_data_valid =  1'b0;
     assign         pipe_rx7_data_valid =  1'b0;
     assign         pipe_rx0_start_block = 1'b0;
     assign         pipe_rx1_start_block = 1'b0;
     assign         pipe_rx2_start_block = 1'b0;
     assign         pipe_rx3_start_block = 1'b0;
     assign         pipe_rx4_start_block = 1'b0;
     assign         pipe_rx5_start_block = 1'b0;
     assign         pipe_rx6_start_block = 1'b0;
     assign         pipe_rx7_start_block = 1'b0;
     assign         pipe_rx0_syncheader =  2'b0;
     assign         pipe_rx1_syncheader =  2'b0;
     assign         pipe_rx2_syncheader =  2'b0;
     assign         pipe_rx3_syncheader =  2'b0;
     assign         pipe_rx4_syncheader =  2'b0;
     assign         pipe_rx5_syncheader =  2'b0;
     assign         pipe_rx6_syncheader =  2'b0;
     assign         pipe_rx7_syncheader =  2'b0;
  end
  else begin
     assign   pipe_rxeq_user_en      =  8'hff;
     assign   pipe_rxeq_user_txcoeff =  {8{6'd00,6'd30,6'd10}} ;
  end
  endgenerate
  //------------------------------------------------------------------------------------------------------------------//
  // Convert incoming reset from AXI required active High                                                             //
  // to active low as that is what is required by GT and PCIe Block                                                   //
  //------------------------------------------------------------------------------------------------------------------//
  wire sys_rst_n;
  wire PIPE_MMCM_LOCK_IN_wire;
      
  assign sys_rst_n = !sys_reset;
  assign PIPE_MMCM_LOCK_IN_wire = pipe_mmcm_lock_in;

  assign user_lnk_up_int = (cfg_phy_link_status_wire == 2'b11) ? 1'b1 : 1'b0;

  assign sys_or_hot_rst = !sys_rst_n || cfg_hot_reset_out_wire;

  //------------------------------------------------------------------------------------------------------------------//
  // Generate user_reset                                                                                              //
  // Once user reset output of PCIE and Phy Layer is active, de-assert reset                                          //
  // Only assert reset if system reset or hot reset is seen.  Keep AXI backend/user application alive otherwise       //
  //------------------------------------------------------------------------------------------------------------------//
  always @(posedge user_clk or posedge sys_or_hot_rst)
  begin
    if (sys_or_hot_rst) begin
      user_reset_int <= #TCQ 1'b1;
    end else if (cfg_phy_link_status_wire[1] && !cfg_phy_link_down_wire) begin
      user_reset_int <= #TCQ 1'b0;
    end
  end

  // Invert active low reset to active high AXI reset
  always @(posedge user_clk or posedge sys_or_hot_rst)
  begin
    if (sys_or_hot_rst) begin
      user_reset <= #TCQ 1'b1;
    end else begin
      user_reset <= #TCQ user_reset_int;
    end
  end


 xdma_0_pcie3_ip_pcie_top #(
  .TCQ                                                  ( TCQ ),
  .PIPE_SIM_MODE                                        (PIPE_SIM_MODE ),
  .PIPE_PIPELINE_STAGES                                 ( PIPE_PIPELINE_STAGES ),
  .ARI_CAP_ENABLE                                       ( ARI_CAP_ENABLE ),
  .AXISTEN_IF_CC_ALIGNMENT_MODE                         ( AXISTEN_IF_CC_ALIGNMENT_MODE ),
  .AXISTEN_IF_CC_PARITY_CHK                             ( AXISTEN_IF_CC_PARITY_CHK ),
  .AXISTEN_IF_CQ_ALIGNMENT_MODE                         ( AXISTEN_IF_CQ_ALIGNMENT_MODE ),
  .AXISTEN_IF_ENABLE_CLIENT_TAG                         ( AXISTEN_IF_ENABLE_CLIENT_TAG ),
  .AXISTEN_IF_ENABLE_MSG_ROUTE                          ( AXISTEN_IF_ENABLE_MSG_ROUTE ),
  .AXISTEN_IF_ENABLE_RX_MSG_INTFC                       ( AXISTEN_IF_ENABLE_RX_MSG_INTFC ),
  .AXISTEN_IF_RC_ALIGNMENT_MODE                         ( AXISTEN_IF_RC_ALIGNMENT_MODE ),
  .AXISTEN_IF_RC_STRADDLE                               ( AXISTEN_IF_RC_STRADDLE ),
  .AXISTEN_IF_RQ_ALIGNMENT_MODE                         ( AXISTEN_IF_RQ_ALIGNMENT_MODE ),
  .AXISTEN_IF_RQ_PARITY_CHK                             ( AXISTEN_IF_RQ_PARITY_CHK ),
  .AXISTEN_IF_WIDTH                                     ( AXISTEN_IF_WIDTH ),
  .C_DATA_WIDTH                                         ( C_DATA_WIDTH ),
  .CRM_CORE_CLK_FREQ_500                                ( CRM_CORE_CLK_FREQ_500 ),
  .CRM_USER_CLK_FREQ                                    ( CRM_USER_CLK_FREQ ),
  .DNSTREAM_LINK_NUM                                    ( DNSTREAM_LINK_NUM ),
  .GEN3_PCS_AUTO_REALIGN                                ( GEN3_PCS_AUTO_REALIGN ),
  .GEN3_PCS_RX_ELECIDLE_INTERNAL                        ( GEN3_PCS_RX_ELECIDLE_INTERNAL ),
  .LL_ACK_TIMEOUT                                       ( LL_ACK_TIMEOUT ),
  .LL_ACK_TIMEOUT_EN                                    ( LL_ACK_TIMEOUT_EN ),
  .LL_ACK_TIMEOUT_FUNC                                  ( LL_ACK_TIMEOUT_FUNC ),
  .LL_CPL_FC_UPDATE_TIMER                               ( LL_CPL_FC_UPDATE_TIMER ),
  .LL_CPL_FC_UPDATE_TIMER_OVERRIDE                      ( LL_CPL_FC_UPDATE_TIMER_OVERRIDE ),
  .LL_FC_UPDATE_TIMER                                   ( LL_FC_UPDATE_TIMER ),
  .LL_FC_UPDATE_TIMER_OVERRIDE                          ( LL_FC_UPDATE_TIMER_OVERRIDE ),
  .LL_NP_FC_UPDATE_TIMER                                ( LL_NP_FC_UPDATE_TIMER ),
  .LL_NP_FC_UPDATE_TIMER_OVERRIDE                       ( LL_NP_FC_UPDATE_TIMER_OVERRIDE ),
  .LL_P_FC_UPDATE_TIMER                                 ( LL_P_FC_UPDATE_TIMER ),
  .LL_P_FC_UPDATE_TIMER_OVERRIDE                        ( LL_P_FC_UPDATE_TIMER_OVERRIDE ),
  .LL_REPLAY_TIMEOUT                                    ( LL_REPLAY_TIMEOUT ),
  .LL_REPLAY_TIMEOUT_EN                                 ( LL_REPLAY_TIMEOUT_EN ),
  .LL_REPLAY_TIMEOUT_FUNC                               ( LL_REPLAY_TIMEOUT_FUNC ),
  .LTR_TX_MESSAGE_MINIMUM_INTERVAL                      ( LTR_TX_MESSAGE_MINIMUM_INTERVAL ),
  .LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE            ( LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE ),
  .LTR_TX_MESSAGE_ON_LTR_ENABLE                         ( LTR_TX_MESSAGE_ON_LTR_ENABLE ),
  .PF0_AER_CAP_ECRC_CHECK_CAPABLE                       ( PF0_AER_CAP_ECRC_CHECK_CAPABLE ),
  .PF0_AER_CAP_ECRC_GEN_CAPABLE                         ( PF0_AER_CAP_ECRC_GEN_CAPABLE ),
  .PF0_AER_CAP_NEXTPTR                                  ( PF0_AER_CAP_NEXTPTR ),
  .PF0_ARI_CAP_NEXTPTR                                  ( PF0_ARI_CAP_NEXTPTR ),
  .PF0_ARI_CAP_NEXT_FUNC                                ( PF0_ARI_CAP_NEXT_FUNC ),
  .PF0_ARI_CAP_VER                                      ( PF0_ARI_CAP_VER ),
  .PF0_BAR0_APERTURE_SIZE                               ( PF0_BAR0_APERTURE_SIZE ),
  .PF0_BAR0_CONTROL                                     ( PF0_BAR0_CONTROL ),
  .PF0_BAR1_APERTURE_SIZE                               ( PF0_BAR1_APERTURE_SIZE ),
  .PF0_BAR1_CONTROL                                     ( PF0_BAR1_CONTROL ),
  .PF0_BAR2_APERTURE_SIZE                               ( PF0_BAR2_APERTURE_SIZE ),
  .PF0_BAR2_CONTROL                                     ( PF0_BAR2_CONTROL ),
  .PF0_BAR3_APERTURE_SIZE                               ( PF0_BAR3_APERTURE_SIZE ),
  .PF0_BAR3_CONTROL                                     ( PF0_BAR3_CONTROL ),
  .PF0_BAR4_APERTURE_SIZE                               ( PF0_BAR4_APERTURE_SIZE ),
  .PF0_BAR4_CONTROL                                     ( PF0_BAR4_CONTROL ),
  .PF0_BAR5_APERTURE_SIZE                               ( PF0_BAR5_APERTURE_SIZE ),
  .PF0_BAR5_CONTROL                                     ( PF0_BAR5_CONTROL ),
  .PF0_BIST_REGISTER                                    ( PF0_BIST_REGISTER ),
  .PF0_CAPABILITY_POINTER                               ( PF0_CAPABILITY_POINTER ),
  .PF0_CLASS_CODE                                       ( PF0_CLASS_CODE ),
  .PF0_DEVICE_ID                                        ( PF0_DEVICE_ID ),
  .PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT       ( PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT ),
  .PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT            ( PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT ),
  .PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT            ( PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT ),
  .PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE                     ( PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE ),
  .PF0_DEV_CAP2_LTR_SUPPORT                             ( PF0_DEV_CAP2_LTR_SUPPORT ),
  .PF0_DEV_CAP2_OBFF_SUPPORT                            ( PF0_DEV_CAP2_OBFF_SUPPORT ),
  .PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT                   ( PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT ),
  .PF0_DEV_CAP_ENDPOINT_L0S_LATENCY                     ( PF0_DEV_CAP_ENDPOINT_L0S_LATENCY ),
  .PF0_DEV_CAP_ENDPOINT_L1_LATENCY                      ( PF0_DEV_CAP_ENDPOINT_L1_LATENCY ),
  .PF0_DEV_CAP_EXT_TAG_SUPPORTED                        ( PF0_DEV_CAP_EXT_TAG_SUPPORTED ),
  .PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE             ( PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE ),
  .PF0_DEV_CAP_MAX_PAYLOAD_SIZE                         ( PF0_DEV_CAP_MAX_PAYLOAD_SIZE ),
  .PF0_DPA_CAP_NEXTPTR                                  ( PF0_DPA_CAP_NEXTPTR ),
  .VF0_ARI_CAP_NEXTPTR                                  ( VF0_ARI_CAP_NEXTPTR ),
  .VF1_ARI_CAP_NEXTPTR                                  ( VF1_ARI_CAP_NEXTPTR ),
  .VF2_ARI_CAP_NEXTPTR                                  ( VF2_ARI_CAP_NEXTPTR ),
  .VF3_ARI_CAP_NEXTPTR                                  ( VF3_ARI_CAP_NEXTPTR ),
  .VF4_ARI_CAP_NEXTPTR                                  ( VF4_ARI_CAP_NEXTPTR ),
  .VF5_ARI_CAP_NEXTPTR                                  ( VF5_ARI_CAP_NEXTPTR ),
  .VF0_TPHR_CAP_DEV_SPECIFIC_MODE                       ( VF0_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .VF0_TPHR_CAP_ENABLE                                  ( VF0_TPHR_CAP_ENABLE ),
  .VF0_TPHR_CAP_INT_VEC_MODE                            ( VF0_TPHR_CAP_INT_VEC_MODE ),
  .VF0_TPHR_CAP_NEXTPTR                                 ( VF0_TPHR_CAP_NEXTPTR ),
  .VF0_TPHR_CAP_ST_MODE_SEL                             ( VF0_TPHR_CAP_ST_MODE_SEL ),
  .VF0_TPHR_CAP_ST_TABLE_LOC                            ( VF0_TPHR_CAP_ST_TABLE_LOC ),
  .VF0_TPHR_CAP_ST_TABLE_SIZE                           ( VF0_TPHR_CAP_ST_TABLE_SIZE ),
  .VF0_TPHR_CAP_VER                                     ( VF0_TPHR_CAP_VER ),
  .VF1_TPHR_CAP_DEV_SPECIFIC_MODE                       ( VF1_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .VF1_TPHR_CAP_ENABLE                                  ( VF1_TPHR_CAP_ENABLE ),
  .VF1_TPHR_CAP_INT_VEC_MODE                            ( VF1_TPHR_CAP_INT_VEC_MODE ),
  .VF1_TPHR_CAP_NEXTPTR                                 ( VF1_TPHR_CAP_NEXTPTR ),
  .VF1_TPHR_CAP_ST_MODE_SEL                             ( VF1_TPHR_CAP_ST_MODE_SEL ),
  .VF1_TPHR_CAP_ST_TABLE_LOC                            ( VF1_TPHR_CAP_ST_TABLE_LOC ),
  .VF1_TPHR_CAP_ST_TABLE_SIZE                           ( VF1_TPHR_CAP_ST_TABLE_SIZE ),
  .VF1_TPHR_CAP_VER                                     ( VF1_TPHR_CAP_VER ),
  .VF2_TPHR_CAP_DEV_SPECIFIC_MODE                       ( VF2_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .VF2_TPHR_CAP_ENABLE                                  ( VF2_TPHR_CAP_ENABLE ),
  .VF2_TPHR_CAP_INT_VEC_MODE                            ( VF2_TPHR_CAP_INT_VEC_MODE ),
  .VF2_TPHR_CAP_NEXTPTR                                 ( VF2_TPHR_CAP_NEXTPTR ),
  .VF2_TPHR_CAP_ST_MODE_SEL                             ( VF2_TPHR_CAP_ST_MODE_SEL ),
  .VF2_TPHR_CAP_ST_TABLE_LOC                            ( VF2_TPHR_CAP_ST_TABLE_LOC ),
  .VF2_TPHR_CAP_ST_TABLE_SIZE                           ( VF2_TPHR_CAP_ST_TABLE_SIZE ),
  .VF2_TPHR_CAP_VER                                     ( VF2_TPHR_CAP_VER ),
  .VF3_TPHR_CAP_DEV_SPECIFIC_MODE                       ( VF3_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .VF3_TPHR_CAP_ENABLE                                  ( VF3_TPHR_CAP_ENABLE ),
  .VF3_TPHR_CAP_INT_VEC_MODE                            ( VF3_TPHR_CAP_INT_VEC_MODE ),
  .VF3_TPHR_CAP_NEXTPTR                                 ( VF3_TPHR_CAP_NEXTPTR ),
  .VF3_TPHR_CAP_ST_MODE_SEL                             ( VF3_TPHR_CAP_ST_MODE_SEL ),
  .VF3_TPHR_CAP_ST_TABLE_LOC                            ( VF3_TPHR_CAP_ST_TABLE_LOC ),
  .VF3_TPHR_CAP_ST_TABLE_SIZE                           ( VF3_TPHR_CAP_ST_TABLE_SIZE ),
  .VF3_TPHR_CAP_VER                                     ( VF3_TPHR_CAP_VER ),
  .VF4_TPHR_CAP_DEV_SPECIFIC_MODE                       ( VF4_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .VF4_TPHR_CAP_ENABLE                                  ( VF4_TPHR_CAP_ENABLE ),
  .VF4_TPHR_CAP_INT_VEC_MODE                            ( VF4_TPHR_CAP_INT_VEC_MODE ),
  .VF4_TPHR_CAP_NEXTPTR                                 ( VF4_TPHR_CAP_NEXTPTR ),
  .VF4_TPHR_CAP_ST_MODE_SEL                             ( VF4_TPHR_CAP_ST_MODE_SEL ),
  .VF4_TPHR_CAP_ST_TABLE_LOC                            ( VF4_TPHR_CAP_ST_TABLE_LOC ),
  .VF4_TPHR_CAP_ST_TABLE_SIZE                           ( VF4_TPHR_CAP_ST_TABLE_SIZE ),
  .VF4_TPHR_CAP_VER                                     ( VF4_TPHR_CAP_VER ),
  .VF5_TPHR_CAP_DEV_SPECIFIC_MODE                       ( VF5_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .VF5_TPHR_CAP_ENABLE                                  ( VF5_TPHR_CAP_ENABLE ),
  .VF5_TPHR_CAP_INT_VEC_MODE                            ( VF5_TPHR_CAP_INT_VEC_MODE ),
  .VF5_TPHR_CAP_NEXTPTR                                 ( VF5_TPHR_CAP_NEXTPTR ),
  .VF5_TPHR_CAP_ST_MODE_SEL                             ( VF5_TPHR_CAP_ST_MODE_SEL ),
  .VF5_TPHR_CAP_ST_TABLE_LOC                            ( VF5_TPHR_CAP_ST_TABLE_LOC ),
  .VF5_TPHR_CAP_ST_TABLE_SIZE                           ( VF5_TPHR_CAP_ST_TABLE_SIZE ),
  .VF5_TPHR_CAP_VER                                     ( VF5_TPHR_CAP_VER ),
  .PF0_DPA_CAP_SUB_STATE_CONTROL                        ( PF0_DPA_CAP_SUB_STATE_CONTROL ),
  .PF0_DPA_CAP_SUB_STATE_CONTROL_EN                     ( PF0_DPA_CAP_SUB_STATE_CONTROL_EN ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 ),
  .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7              ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 ),
  .PF0_DPA_CAP_VER                                      ( PF0_DPA_CAP_VER ),
  .PF0_DSN_CAP_NEXTPTR                                  ( PF0_DSN_CAP_NEXTPTR ),
  .PF0_EXPANSION_ROM_APERTURE_SIZE                      ( PF0_EXPANSION_ROM_APERTURE_SIZE ),
  .PF0_EXPANSION_ROM_ENABLE                             ( PF0_EXPANSION_ROM_ENABLE ),
  .PF0_INTERRUPT_LINE                                   ( PF0_INTERRUPT_LINE ),
  .PF0_INTERRUPT_PIN                                    ( PF0_INTERRUPT_PIN ),
  .PF0_LINK_CAP_ASPM_SUPPORT                            ( PF0_LINK_CAP_ASPM_SUPPORT ),
  .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1            ( PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 ),
  .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2            ( PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 ),
  .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3            ( PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 ),
  .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1                   ( PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 ),
  .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2                   ( PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 ),
  .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3                   ( PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 ),
  .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1             ( PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 ),
  .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2             ( PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 ),
  .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3             ( PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 ),
  .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1                    ( PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 ),
  .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2                    ( PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 ),
  .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3                    ( PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 ),
  .PF0_LINK_STATUS_SLOT_CLOCK_CONFIG                    ( PF0_LINK_STATUS_SLOT_CLOCK_CONFIG ),
  .PF0_LTR_CAP_MAX_NOSNOOP_LAT                          ( PF0_LTR_CAP_MAX_NOSNOOP_LAT ),
  .PF0_LTR_CAP_MAX_SNOOP_LAT                            ( PF0_LTR_CAP_MAX_SNOOP_LAT ),
  .PF0_LTR_CAP_NEXTPTR                                  ( PF0_LTR_CAP_NEXTPTR ),
  .PF0_LTR_CAP_VER                                      ( PF0_LTR_CAP_VER ),
  .PF0_MSIX_CAP_NEXTPTR                                 ( PF0_MSIX_CAP_NEXTPTR ),
  .PF0_MSIX_CAP_PBA_BIR                                 ( PF0_MSIX_CAP_PBA_BIR ),
  .PF0_MSIX_CAP_PBA_OFFSET                              ( {3'b000,PF0_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .PF0_MSIX_CAP_TABLE_BIR                               ( PF0_MSIX_CAP_TABLE_BIR ),
  .PF0_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,PF0_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .PF0_MSIX_CAP_TABLE_SIZE                              ( PF0_MSIX_CAP_TABLE_SIZE ),
  .PF0_MSI_CAP_MULTIMSGCAP                              ( PF0_MSI_CAP_MULTIMSGCAP ),
  .PF0_MSI_CAP_NEXTPTR                                  ( PF0_MSI_CAP_NEXTPTR ),
  .PF0_PB_CAP_NEXTPTR                                   ( PF0_PB_CAP_NEXTPTR ),
  .PF0_PB_CAP_SYSTEM_ALLOCATED                          ( PF0_PB_CAP_SYSTEM_ALLOCATED ),
  .PF0_PB_CAP_VER                                       ( PF0_PB_CAP_VER ),
  .PF0_PM_CAP_ID                                        ( PF0_PM_CAP_ID ),
  .PF0_PM_CAP_NEXTPTR                                   ( PF0_PM_CAP_NEXTPTR ),
  .PF0_PM_CAP_PMESUPPORT_D0                             ( PF0_PM_CAP_PMESUPPORT_D0 ),
  .PF0_PM_CAP_PMESUPPORT_D1                             ( PF0_PM_CAP_PMESUPPORT_D1 ),
  .PF0_PM_CAP_PMESUPPORT_D3HOT                          ( PF0_PM_CAP_PMESUPPORT_D3HOT ),
  .PF0_PM_CAP_SUPP_D1_STATE                             ( PF0_PM_CAP_SUPP_D1_STATE ),
  .PF0_PM_CAP_VER_ID                                    ( PF0_PM_CAP_VER_ID ),
  .PF0_PM_CSR_NOSOFTRESET                               ( PF0_PM_CSR_NOSOFTRESET ),
  .PF0_RBAR_CAP_ENABLE                                  ( PF0_RBAR_CAP_ENABLE ),
  .PF0_RBAR_CAP_INDEX0                                  ( PF0_RBAR_CAP_INDEX0 ),
  .PF0_RBAR_CAP_INDEX1                                  ( PF0_RBAR_CAP_INDEX1 ),
  .PF0_RBAR_CAP_INDEX2                                  ( PF0_RBAR_CAP_INDEX2 ),
  .PF0_RBAR_CAP_NEXTPTR                                 ( PF0_RBAR_CAP_NEXTPTR ),
  .PF0_RBAR_CAP_SIZE0                                   ( PF0_RBAR_CAP_SIZE0 ),
  .PF0_RBAR_CAP_SIZE1                                   ( PF0_RBAR_CAP_SIZE1 ),
  .PF0_RBAR_CAP_SIZE2                                   ( PF0_RBAR_CAP_SIZE2 ),
  .PF0_RBAR_CAP_VER                                     ( PF0_RBAR_CAP_VER ),
  .PF0_RBAR_NUM                                         ( PF0_RBAR_NUM ),
  .PF0_REVISION_ID                                      ( PF0_REVISION_ID ),
  .PF0_SRIOV_BAR0_APERTURE_SIZE                         ( PF0_SRIOV_BAR0_APERTURE_SIZE ),
  .PF0_SRIOV_BAR0_CONTROL                               ( PF0_SRIOV_BAR0_CONTROL ),
  .PF0_SRIOV_BAR1_APERTURE_SIZE                         ( PF0_SRIOV_BAR1_APERTURE_SIZE ),
  .PF0_SRIOV_BAR1_CONTROL                               ( PF0_SRIOV_BAR1_CONTROL ),
  .PF0_SRIOV_BAR2_APERTURE_SIZE                         ( PF0_SRIOV_BAR2_APERTURE_SIZE ),
  .PF0_SRIOV_BAR2_CONTROL                               ( PF0_SRIOV_BAR2_CONTROL ),
  .PF0_SRIOV_BAR3_APERTURE_SIZE                         ( PF0_SRIOV_BAR3_APERTURE_SIZE ),
  .PF0_SRIOV_BAR3_CONTROL                               ( PF0_SRIOV_BAR3_CONTROL ),
  .PF0_SRIOV_BAR4_APERTURE_SIZE                         ( PF0_SRIOV_BAR4_APERTURE_SIZE ),
  .PF0_SRIOV_BAR4_CONTROL                               ( PF0_SRIOV_BAR4_CONTROL ),
  .PF0_SRIOV_BAR5_APERTURE_SIZE                         ( PF0_SRIOV_BAR5_APERTURE_SIZE ),
  .PF0_SRIOV_BAR5_CONTROL                               ( PF0_SRIOV_BAR5_CONTROL ),
  .PF0_SRIOV_CAP_INITIAL_VF                             ( PF0_SRIOV_CAP_INITIAL_VF ),
  .PF0_SRIOV_CAP_NEXTPTR                                ( PF0_SRIOV_CAP_NEXTPTR ),
  .PF0_SRIOV_CAP_TOTAL_VF                               ( PF0_SRIOV_CAP_TOTAL_VF ),
  .PF0_SRIOV_CAP_VER                                    ( PF0_SRIOV_CAP_VER ),
  .PF0_SRIOV_FIRST_VF_OFFSET                            ( PF0_SRIOV_FIRST_VF_OFFSET ),
  .PF0_SRIOV_FUNC_DEP_LINK                              ( PF0_SRIOV_FUNC_DEP_LINK ),
  .PF0_SRIOV_SUPPORTED_PAGE_SIZE                        ( PF0_SRIOV_SUPPORTED_PAGE_SIZE ),
  .PF0_SRIOV_VF_DEVICE_ID                               ( PF0_SRIOV_VF_DEVICE_ID ),
  .PF0_SUBSYSTEM_ID                                     ( PF0_SUBSYSTEM_ID ),
  .PF0_TPHR_CAP_DEV_SPECIFIC_MODE                       ( PF0_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .PF0_TPHR_CAP_ENABLE                                  ( PF0_TPHR_CAP_ENABLE ),
  .PF0_TPHR_CAP_INT_VEC_MODE                            ( PF0_TPHR_CAP_INT_VEC_MODE ),
  .PF0_TPHR_CAP_NEXTPTR                                 ( PF0_TPHR_CAP_NEXTPTR ),
  .PF0_TPHR_CAP_ST_MODE_SEL                             ( PF0_TPHR_CAP_ST_MODE_SEL ),
  .PF0_TPHR_CAP_ST_TABLE_LOC                            ( PF0_TPHR_CAP_ST_TABLE_LOC ),
  .PF0_TPHR_CAP_ST_TABLE_SIZE                           ( PF0_TPHR_CAP_ST_TABLE_SIZE ),
  .PF0_TPHR_CAP_VER                                     ( PF0_TPHR_CAP_VER ),
  .PF0_VC_CAP_NEXTPTR                                   ( PF0_VC_CAP_NEXTPTR ),
  .PF0_VC_CAP_VER                                       ( PF0_VC_CAP_VER ),
  .PF1_AER_CAP_ECRC_CHECK_CAPABLE                       ( PF1_AER_CAP_ECRC_CHECK_CAPABLE ),
  .PF1_AER_CAP_ECRC_GEN_CAPABLE                         ( PF1_AER_CAP_ECRC_GEN_CAPABLE ),
  .PF1_AER_CAP_NEXTPTR                                  ( PF1_AER_CAP_NEXTPTR ),
  .PF1_ARI_CAP_NEXTPTR                                  ( PF1_ARI_CAP_NEXTPTR ),
  .PF1_ARI_CAP_NEXT_FUNC                                ( PF1_ARI_CAP_NEXT_FUNC ),
  .PF1_BAR0_APERTURE_SIZE                               ( PF1_BAR0_APERTURE_SIZE ),
  .PF1_BAR0_CONTROL                                     ( PF1_BAR0_CONTROL ),
  .PF1_BAR1_APERTURE_SIZE                               ( PF1_BAR1_APERTURE_SIZE ),
  .PF1_BAR1_CONTROL                                     ( PF1_BAR1_CONTROL ),
  .PF1_BAR2_APERTURE_SIZE                               ( PF1_BAR2_APERTURE_SIZE ),
  .PF1_BAR2_CONTROL                                     ( PF1_BAR2_CONTROL ),
  .PF1_BAR3_APERTURE_SIZE                               ( PF1_BAR3_APERTURE_SIZE ),
  .PF1_BAR3_CONTROL                                     ( PF1_BAR3_CONTROL ),
  .PF1_BAR4_APERTURE_SIZE                               ( PF1_BAR4_APERTURE_SIZE ),
  .PF1_BAR4_CONTROL                                     ( PF1_BAR4_CONTROL ),
  .PF1_BAR5_APERTURE_SIZE                               ( PF1_BAR5_APERTURE_SIZE ),
  .PF1_BAR5_CONTROL                                     ( PF1_BAR5_CONTROL ),
  .PF1_BIST_REGISTER                                    ( PF1_BIST_REGISTER ),
  .PF1_CAPABILITY_POINTER                               ( PF1_CAPABILITY_POINTER ),
  .PF1_CLASS_CODE                                       ( PF1_CLASS_CODE ),
  .PF1_DEVICE_ID                                        ( PF1_DEVICE_ID ),
  .PF1_DEV_CAP_MAX_PAYLOAD_SIZE                         ( PF1_DEV_CAP_MAX_PAYLOAD_SIZE ),
  .PF1_DPA_CAP_NEXTPTR                                  ( PF1_DPA_CAP_NEXTPTR ),
  .PF1_DPA_CAP_SUB_STATE_CONTROL                        ( PF1_DPA_CAP_SUB_STATE_CONTROL ),
  .PF1_DPA_CAP_SUB_STATE_CONTROL_EN                     ( PF1_DPA_CAP_SUB_STATE_CONTROL_EN ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 ),
  .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7              ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 ),
  .PF1_DPA_CAP_VER                                      ( PF1_DPA_CAP_VER ),
  .PF1_DSN_CAP_NEXTPTR                                  ( PF1_DSN_CAP_NEXTPTR ),
  .PF1_EXPANSION_ROM_APERTURE_SIZE                      ( PF1_EXPANSION_ROM_APERTURE_SIZE ),
  .PF1_EXPANSION_ROM_ENABLE                             ( PF1_EXPANSION_ROM_ENABLE ),
  .PF1_INTERRUPT_LINE                                   ( PF1_INTERRUPT_LINE ),
  .PF1_INTERRUPT_PIN                                    ( PF1_INTERRUPT_PIN ),
  .PF1_MSIX_CAP_NEXTPTR                                 ( PF1_MSIX_CAP_NEXTPTR ),
  .PF1_MSIX_CAP_PBA_BIR                                 ( PF1_MSIX_CAP_PBA_BIR ),
  .PF1_MSIX_CAP_PBA_OFFSET                              ( {3'b000,PF1_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .PF1_MSIX_CAP_TABLE_BIR                               ( PF1_MSIX_CAP_TABLE_BIR ),
  .PF1_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,PF1_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .PF1_MSIX_CAP_TABLE_SIZE                              ( PF1_MSIX_CAP_TABLE_SIZE ),
  .PF1_MSI_CAP_MULTIMSGCAP                              ( PF1_MSI_CAP_MULTIMSGCAP ),
  .PF1_MSI_CAP_NEXTPTR                                  ( PF1_MSI_CAP_NEXTPTR ),
  .PF1_PB_CAP_NEXTPTR                                   ( PF1_PB_CAP_NEXTPTR ),
  .PF1_PB_CAP_SYSTEM_ALLOCATED                          ( PF1_PB_CAP_SYSTEM_ALLOCATED ),
  .PF1_PB_CAP_VER                                       ( PF1_PB_CAP_VER ),
  .PF1_PM_CAP_ID                                        ( PF1_PM_CAP_ID ),
  .PF1_PM_CAP_NEXTPTR                                   ( PF1_PM_CAP_NEXTPTR ),
  .PF1_PM_CAP_VER_ID                                    ( PF1_PM_CAP_VER_ID ),
  .PF1_RBAR_CAP_ENABLE                                  ( PF1_RBAR_CAP_ENABLE ),
  .PF1_RBAR_CAP_INDEX0                                  ( PF1_RBAR_CAP_INDEX0 ),
  .PF1_RBAR_CAP_INDEX1                                  ( PF1_RBAR_CAP_INDEX1 ),
  .PF1_RBAR_CAP_INDEX2                                  ( PF1_RBAR_CAP_INDEX2 ),
  .PF1_RBAR_CAP_NEXTPTR                                 ( PF1_RBAR_CAP_NEXTPTR ),
  .PF1_RBAR_CAP_SIZE0                                   ( PF1_RBAR_CAP_SIZE0 ),
  .PF1_RBAR_CAP_SIZE1                                   ( PF1_RBAR_CAP_SIZE1 ),
  .PF1_RBAR_CAP_SIZE2                                   ( PF1_RBAR_CAP_SIZE2 ),
  .PF1_RBAR_CAP_VER                                     ( PF1_RBAR_CAP_VER ),
  .PF1_RBAR_NUM                                         ( PF1_RBAR_NUM ),
  .PF1_REVISION_ID                                      ( PF1_REVISION_ID ),
  .PF1_SRIOV_BAR0_APERTURE_SIZE                         ( PF1_SRIOV_BAR0_APERTURE_SIZE ),
  .PF1_SRIOV_BAR0_CONTROL                               ( PF1_SRIOV_BAR0_CONTROL ),
  .PF1_SRIOV_BAR1_APERTURE_SIZE                         ( PF1_SRIOV_BAR1_APERTURE_SIZE ),
  .PF1_SRIOV_BAR1_CONTROL                               ( PF1_SRIOV_BAR1_CONTROL ),
  .PF1_SRIOV_BAR2_APERTURE_SIZE                         ( PF1_SRIOV_BAR2_APERTURE_SIZE ),
  .PF1_SRIOV_BAR2_CONTROL                               ( PF1_SRIOV_BAR2_CONTROL ),
  .PF1_SRIOV_BAR3_APERTURE_SIZE                         ( PF1_SRIOV_BAR3_APERTURE_SIZE ),
  .PF1_SRIOV_BAR3_CONTROL                               ( PF1_SRIOV_BAR3_CONTROL ),
  .PF1_SRIOV_BAR4_APERTURE_SIZE                         ( PF1_SRIOV_BAR4_APERTURE_SIZE ),
  .PF1_SRIOV_BAR4_CONTROL                               ( PF1_SRIOV_BAR4_CONTROL ),
  .PF1_SRIOV_BAR5_APERTURE_SIZE                         ( PF1_SRIOV_BAR5_APERTURE_SIZE ),
  .PF1_SRIOV_BAR5_CONTROL                               ( PF1_SRIOV_BAR5_CONTROL ),
  .PF1_SRIOV_CAP_INITIAL_VF                             ( PF1_SRIOV_CAP_INITIAL_VF ),
  .PF1_SRIOV_CAP_NEXTPTR                                ( PF1_SRIOV_CAP_NEXTPTR ),
  .PF1_SRIOV_CAP_TOTAL_VF                               ( PF1_SRIOV_CAP_TOTAL_VF ),
  .PF1_SRIOV_CAP_VER                                    ( PF1_SRIOV_CAP_VER ),
  .PF1_SRIOV_FIRST_VF_OFFSET                            ( PF1_SRIOV_FIRST_VF_OFFSET ),
  .PF1_SRIOV_FUNC_DEP_LINK                              ( PF1_SRIOV_FUNC_DEP_LINK ),
  .PF1_SRIOV_SUPPORTED_PAGE_SIZE                        ( PF1_SRIOV_SUPPORTED_PAGE_SIZE ),
  .PF1_SRIOV_VF_DEVICE_ID                               ( PF1_SRIOV_VF_DEVICE_ID ),
  .PF1_SUBSYSTEM_ID                                     ( PF1_SUBSYSTEM_ID ),
  .PF1_TPHR_CAP_DEV_SPECIFIC_MODE                       ( PF1_TPHR_CAP_DEV_SPECIFIC_MODE ),
  .PF1_TPHR_CAP_ENABLE                                  ( PF1_TPHR_CAP_ENABLE ),
  .PF1_TPHR_CAP_INT_VEC_MODE                            ( PF1_TPHR_CAP_INT_VEC_MODE ),
  .PF1_TPHR_CAP_NEXTPTR                                 ( PF1_TPHR_CAP_NEXTPTR ),
  .PF1_TPHR_CAP_ST_MODE_SEL                             ( PF1_TPHR_CAP_ST_MODE_SEL ),
  .PF1_TPHR_CAP_ST_TABLE_LOC                            ( PF1_TPHR_CAP_ST_TABLE_LOC ),
  .PF1_TPHR_CAP_ST_TABLE_SIZE                           ( PF1_TPHR_CAP_ST_TABLE_SIZE ),
  .PF1_TPHR_CAP_VER                                     ( PF1_TPHR_CAP_VER ),
  .PL_DISABLE_EI_INFER_IN_L0                            ( PL_DISABLE_EI_INFER_IN_L0 ),
  .PL_DISABLE_GEN3_DC_BALANCE                           ( PL_DISABLE_GEN3_DC_BALANCE ),
  .PL_DISABLE_SCRAMBLING                                ( PL_DISABLE_SCRAMBLING ),
  .PL_DISABLE_UPCONFIG_CAPABLE                          ( PL_DISABLE_UPCONFIG_CAPABLE ),
  .PL_EQ_ADAPT_DISABLE_COEFF_CHECK                      ( PL_EQ_ADAPT_DISABLE_COEFF_CHECK ),
  .PL_EQ_ADAPT_DISABLE_PRESET_CHECK                     ( PL_EQ_ADAPT_DISABLE_PRESET_CHECK ),
  .PL_EQ_ADAPT_ITER_COUNT                               ( PL_EQ_ADAPT_ITER_COUNT ),
  .PL_EQ_ADAPT_REJECT_RETRY_COUNT                       ( PL_EQ_ADAPT_REJECT_RETRY_COUNT ),
  .PL_EQ_BYPASS_PHASE23                                 ( PL_EQ_BYPASS_PHASE23 ),
  .PL_EQ_SHORT_ADAPT_PHASE                              ( PL_EQ_SHORT_ADAPT_PHASE ),
  .PL_LANE0_EQ_CONTROL                                  ( PL_LANE0_EQ_CONTROL ),
  .PL_LANE1_EQ_CONTROL                                  ( PL_LANE1_EQ_CONTROL ),
  .PL_LANE2_EQ_CONTROL                                  ( PL_LANE2_EQ_CONTROL ),
  .PL_LANE3_EQ_CONTROL                                  ( PL_LANE3_EQ_CONTROL ),
  .PL_LANE4_EQ_CONTROL                                  ( PL_LANE4_EQ_CONTROL ),
  .PL_LANE5_EQ_CONTROL                                  ( PL_LANE5_EQ_CONTROL ),
  .PL_LANE6_EQ_CONTROL                                  ( PL_LANE6_EQ_CONTROL ),
  .PL_LANE7_EQ_CONTROL                                  ( PL_LANE7_EQ_CONTROL ),
  .PL_LINK_CAP_MAX_LINK_SPEED                           ( PL_LINK_CAP_MAX_LINK_SPEED ),
  .PL_LINK_CAP_MAX_LINK_WIDTH                           ( PL_LINK_CAP_MAX_LINK_WIDTH ),
  .PL_N_FTS_COMCLK_GEN1                                 ( PL_N_FTS_COMCLK_GEN1 ),
  .PL_N_FTS_COMCLK_GEN2                                 ( PL_N_FTS_COMCLK_GEN2 ),
  .PL_N_FTS_COMCLK_GEN3                                 ( PL_N_FTS_COMCLK_GEN3 ),
  .PL_N_FTS_GEN1                                        ( PL_N_FTS_GEN1 ),
  .PL_N_FTS_GEN2                                        ( PL_N_FTS_GEN2 ),
  .PL_N_FTS_GEN3                                        ( PL_N_FTS_GEN3 ),
  // synthesis translate_off
  .PL_SIM_FAST_LINK_TRAINING                            ( ENABLE_FAST_SIM_TRAINING ),
  // synthesis translate_on
  .PL_UPSTREAM_FACING                                   ( PL_UPSTREAM_FACING ),
  .PM_ASPML0S_TIMEOUT                                   ( PM_ASPML0S_TIMEOUT ),
  .PM_ASPML1_ENTRY_DELAY                                ( PM_ASPML1_ENTRY_DELAY ),
  .PM_ENABLE_SLOT_POWER_CAPTURE                         ( PM_ENABLE_SLOT_POWER_CAPTURE ),
  .PM_L1_REENTRY_DELAY                                  ( PM_L1_REENTRY_DELAY ),
  .PM_PME_SERVICE_TIMEOUT_DELAY                         ( PM_PME_SERVICE_TIMEOUT_DELAY ),
  .PM_PME_TURNOFF_ACK_DELAY                             ( PM_PME_TURNOFF_ACK_DELAY ),
  .SIM_VERSION                                          ( SIM_VERSION ),
  .SPARE_BIT0                                           ( SPARE_BIT0 ),
  .SPARE_BIT1                                           ( SPARE_BIT1 ),
  .SPARE_BIT2                                           ( SPARE_BIT2 ),
  .SPARE_BIT3                                           ( SPARE_BIT3 ),
  .SPARE_BIT4                                           ( SPARE_BIT4 ),
  .SPARE_BIT5                                           ( SPARE_BIT5 ),
  .SPARE_BIT6                                           ( SPARE_BIT6 ),
  .SPARE_BIT7                                           ( SPARE_BIT7 ),
  .SPARE_BIT8                                           ( SPARE_BIT8 ),
  .SPARE_BYTE0                                          ( SPARE_BYTE0 ),
  .SPARE_BYTE1                                          ( SPARE_BYTE1 ),
  .SPARE_BYTE2                                          ( SPARE_BYTE2 ),
  .SPARE_BYTE3                                          ( SPARE_BYTE3 ),
  .SPARE_WORD0                                          ( SPARE_WORD0 ),
  .SPARE_WORD1                                          ( SPARE_WORD1 ),
  .SPARE_WORD2                                          ( SPARE_WORD2 ),
  .SPARE_WORD3                                          ( SPARE_WORD3 ),
  .SRIOV_CAP_ENABLE                                     ( SRIOV_CAP_ENABLE ),
  .TL_COMPL_TIMEOUT_REG0                                ( TL_COMPL_TIMEOUT_REG0 ),
  .TL_COMPL_TIMEOUT_REG1                                ( TL_COMPL_TIMEOUT_REG1 ),
  .TL_CREDITS_CD                                        ( TL_CREDITS_CD ),
  .TL_CREDITS_CH                                        ( TL_CREDITS_CH ),
  .TL_CREDITS_NPD                                       ( TL_CREDITS_NPD ),
  .TL_CREDITS_NPH                                       ( TL_CREDITS_NPH ),
  .TL_CREDITS_PD                                        ( TL_CREDITS_PD ),
  .TL_CREDITS_PH                                        ( TL_CREDITS_PH ),
  .TL_ENABLE_MESSAGE_RID_CHECK_ENABLE                   ( TL_ENABLE_MESSAGE_RID_CHECK_ENABLE ),
  .TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE              ( TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE ),
  .TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE                ( TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE ),
  .TL_LEGACY_MODE_ENABLE                                ( TL_LEGACY_MODE_ENABLE ),
  .TL_PF_ENABLE_REG                                     ( TL_PF_ENABLE_REG ),
  .TL_TAG_MGMT_ENABLE                                   ( TL_TAG_MGMT_ENABLE ),
  .VF0_CAPABILITY_POINTER                               ( VF0_CAPABILITY_POINTER ),
  .VF0_MSIX_CAP_PBA_BIR                                 ( VF0_MSIX_CAP_PBA_BIR ),
  .VF0_MSIX_CAP_PBA_OFFSET                              ( {3'b000,VF0_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .VF0_MSIX_CAP_TABLE_BIR                               ( VF0_MSIX_CAP_TABLE_BIR ),
  .VF0_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,VF0_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .VF0_MSIX_CAP_TABLE_SIZE                              ( VF0_MSIX_CAP_TABLE_SIZE ),
  .VF0_MSI_CAP_MULTIMSGCAP                              ( VF0_MSI_CAP_MULTIMSGCAP ),
  .VF0_PM_CAP_ID                                        ( VF0_PM_CAP_ID ),
  .VF0_PM_CAP_NEXTPTR                                   ( VF0_PM_CAP_NEXTPTR ),
  .VF0_PM_CAP_VER_ID                                    ( VF0_PM_CAP_VER_ID ),
  .VF1_MSIX_CAP_PBA_BIR                                 ( VF1_MSIX_CAP_PBA_BIR ),
  .VF1_MSIX_CAP_PBA_OFFSET                              ( {3'b000,VF1_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .VF1_MSIX_CAP_TABLE_BIR                               ( VF1_MSIX_CAP_TABLE_BIR ),
  .VF1_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,VF1_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .VF1_MSIX_CAP_TABLE_SIZE                              ( VF1_MSIX_CAP_TABLE_SIZE ),
  .VF1_MSI_CAP_MULTIMSGCAP                              ( VF1_MSI_CAP_MULTIMSGCAP ),
  .VF1_PM_CAP_ID                                        ( VF1_PM_CAP_ID ),
  .VF1_PM_CAP_NEXTPTR                                   ( VF1_PM_CAP_NEXTPTR ),
  .VF1_PM_CAP_VER_ID                                    ( VF1_PM_CAP_VER_ID ),
  .VF2_MSIX_CAP_PBA_BIR                                 ( VF2_MSIX_CAP_PBA_BIR ),
  .VF2_MSIX_CAP_PBA_OFFSET                              ( {3'b000,VF2_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .VF2_MSIX_CAP_TABLE_BIR                               ( VF2_MSIX_CAP_TABLE_BIR ),
  .VF2_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,VF2_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .VF2_MSIX_CAP_TABLE_SIZE                              ( VF2_MSIX_CAP_TABLE_SIZE ),
  .VF2_MSI_CAP_MULTIMSGCAP                              ( VF2_MSI_CAP_MULTIMSGCAP ),
  .VF2_PM_CAP_ID                                        ( VF2_PM_CAP_ID ),
  .VF2_PM_CAP_NEXTPTR                                   ( VF2_PM_CAP_NEXTPTR ),
  .VF2_PM_CAP_VER_ID                                    ( VF2_PM_CAP_VER_ID ),
  .VF3_MSIX_CAP_PBA_BIR                                 ( VF3_MSIX_CAP_PBA_BIR ),
  .VF3_MSIX_CAP_PBA_OFFSET                              ( {3'b000,VF3_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .VF3_MSIX_CAP_TABLE_BIR                               ( VF3_MSIX_CAP_TABLE_BIR ),
  .VF3_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,VF3_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .VF3_MSIX_CAP_TABLE_SIZE                              ( VF3_MSIX_CAP_TABLE_SIZE ),
  .VF3_MSI_CAP_MULTIMSGCAP                              ( VF3_MSI_CAP_MULTIMSGCAP ),
  .VF3_PM_CAP_ID                                        ( VF3_PM_CAP_ID ),
  .VF3_PM_CAP_NEXTPTR                                   ( VF3_PM_CAP_NEXTPTR ),
  .VF3_PM_CAP_VER_ID                                    ( VF3_PM_CAP_VER_ID ),
  .VF4_MSIX_CAP_PBA_BIR                                 ( VF4_MSIX_CAP_PBA_BIR ),
  .VF4_MSIX_CAP_PBA_OFFSET                              ( {3'b000,VF4_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .VF4_MSIX_CAP_TABLE_BIR                               ( VF4_MSIX_CAP_TABLE_BIR ),
  .VF4_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,VF4_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .VF4_MSIX_CAP_TABLE_SIZE                              ( VF4_MSIX_CAP_TABLE_SIZE ),
  .VF4_MSI_CAP_MULTIMSGCAP                              ( VF4_MSI_CAP_MULTIMSGCAP ),
  .VF4_PM_CAP_ID                                        ( VF4_PM_CAP_ID ),
  .VF4_PM_CAP_NEXTPTR                                   ( VF4_PM_CAP_NEXTPTR ),
  .VF4_PM_CAP_VER_ID                                    ( VF4_PM_CAP_VER_ID ),
  .VF5_MSIX_CAP_PBA_BIR                                 ( VF5_MSIX_CAP_PBA_BIR ),
  .VF5_MSIX_CAP_PBA_OFFSET                              ( {3'b000,VF5_MSIX_CAP_PBA_OFFSET[28:3]} ),
  .VF5_MSIX_CAP_TABLE_BIR                               ( VF5_MSIX_CAP_TABLE_BIR ),
  .VF5_MSIX_CAP_TABLE_OFFSET                            ( {3'b000,VF5_MSIX_CAP_TABLE_OFFSET[28:3]} ),
  .VF5_MSIX_CAP_TABLE_SIZE                              ( VF5_MSIX_CAP_TABLE_SIZE ),
  .VF5_MSI_CAP_MULTIMSGCAP                              ( VF5_MSI_CAP_MULTIMSGCAP ),
  .VF5_PM_CAP_ID                                        ( VF5_PM_CAP_ID ),
  .VF5_PM_CAP_NEXTPTR                                   ( VF5_PM_CAP_NEXTPTR ),
  .VF5_PM_CAP_VER_ID                                    ( VF5_PM_CAP_VER_ID ),
  .IMPL_TARGET                                          ( IMPL_TARGET ),
  .NO_DECODE_LOGIC                                      ( NO_DECODE_LOGIC ),
  .INTERFACE_SPEED                                      ( INTERFACE_SPEED ),
  .COMPLETION_SPACE                                     ( COMPLETION_SPACE )
) pcie_top_i (

  .core_clk                                             ( core_clk ),                     // I

  .rec_clk                                              ( rec_clk ),                      // I
  .user_clk                                             ( user_clk ),                     // I

  .pipe_clk                                             ( pipe_clk ),                     // I

  .phy_rdy                                              ( phy_rdy ),                      // I
  .mmcm_lock                                            ( mmcm_lock ),                    // I

  .s_axis_rq_tlast                                      ( s_axis_rq_tlast_wire ),         // I
  .s_axis_rq_tdata                                      ( s_axis_rq_tdata_wire ),         // I
  .s_axis_rq_tuser                                      ( s_axis_rq_tuser_wire ),         // I
  .s_axis_rq_tkeep                                      ( s_axis_rq_tkeep_wire ),         // I
  .s_axis_rq_tready                                     ( s_axis_rq_tready_wire ),        // O
  .s_axis_rq_tvalid                                     ( s_axis_rq_tvalid_wire ),        // I

  .m_axis_rc_tdata                                      ( m_axis_rc_tdata_wire ),         // O
  .m_axis_rc_tuser                                      ( m_axis_rc_tuser_wire ),         // O
  .m_axis_rc_tlast                                      ( m_axis_rc_tlast_wire ),         // O
  .m_axis_rc_tkeep                                      ( m_axis_rc_tkeep_wire ),         // O
  .m_axis_rc_tvalid                                     ( m_axis_rc_tvalid_wire ),        // O
  .m_axis_rc_tready                                     ( m_axis_rc_tready_wire ),        // I

  .m_axis_cq_tdata                                      ( m_axis_cq_tdata_wire ),         // O
  .m_axis_cq_tuser                                      ( m_axis_cq_tuser_wire ),         // O
  .m_axis_cq_tlast                                      ( m_axis_cq_tlast_wire ),         // O
  .m_axis_cq_tkeep                                      ( m_axis_cq_tkeep_wire ),         // O
  .m_axis_cq_tvalid                                     ( m_axis_cq_tvalid_wire ),        // O
  .m_axis_cq_tready                                     ( m_axis_cq_tready_wire ),        // I

  .s_axis_cc_tdata                                      ( s_axis_cc_tdata_wire ),         // I
  .s_axis_cc_tuser                                      ( s_axis_cc_tuser_wire ),         // I
  .s_axis_cc_tlast                                      ( s_axis_cc_tlast_wire ),         // I
  .s_axis_cc_tkeep                                      ( s_axis_cc_tkeep_wire ),         // I
  .s_axis_cc_tvalid                                     ( s_axis_cc_tvalid_wire ),        // I
  .s_axis_cc_tready                                     ( s_axis_cc_tready_wire ),        // O

  .pcie_rq_seq_num                                      ( pcie_rq_seq_num_wire ),         // O
  .pcie_rq_seq_num_vld                                  ( pcie_rq_seq_num_vld_wire ),     // O
  .pcie_rq_tag                                          ( pcie_rq_tag_wire ),             // O
  .pcie_rq_tag_vld                                      ( pcie_rq_tag_vld_wire ),         // O

  .pcie_tfc_nph_av                                      ( pcie_tfc_nph_av_wire ),         // O
  .pcie_tfc_npd_av                                      ( pcie_tfc_npd_av_wire ),         // O
  .pcie_cq_np_req                                       ( pcie_cq_np_req_wire ),          // I
  .pcie_cq_np_req_count                                 ( pcie_cq_np_req_count_wire ),    // O

  .cfg_mgmt_addr                                        ( cfg_mgmt_addr ),                // I
  .cfg_mgmt_write                                       ( cfg_mgmt_write_wire ),          // I
  .cfg_mgmt_write_data                                  ( cfg_mgmt_write_data ),          // I
  .cfg_mgmt_byte_enable                                 ( cfg_mgmt_byte_enable ),         // I
  .cfg_mgmt_read                                        ( cfg_mgmt_read_wire ),           // I
  .cfg_mgmt_read_data                                   ( cfg_mgmt_read_data ),           // O
  .cfg_mgmt_read_write_done                             ( cfg_mgmt_read_write_done ),     // O
  .cfg_mgmt_type1_cfg_reg_access                        ( cfg_mgmt_type1_cfg_reg_access ),// I

  .cfg_phy_link_down                                    ( cfg_phy_link_down_wire ),       // O
  .cfg_phy_link_status                                  ( cfg_phy_link_status_wire ),     // O
  .cfg_negotiated_width                                 ( cfg_negotiated_width ),         // O
  .cfg_current_speed                                    ( cfg_current_speed ),            // O
  .cfg_max_payload                                      ( cfg_max_payload ),              // O
  .cfg_max_read_req                                     ( cfg_max_read_req ),             // O
  .cfg_function_status                                  ( cfg_function_status ),          // O
  .cfg_function_power_state                             ( cfg_function_power_state ),     // O
  .cfg_vf_status                                        ( cfg_vf_status ),                // O
  .cfg_vf_power_state                                   ( cfg_vf_power_state ),           // O
  .cfg_link_power_state                                 ( cfg_link_power_state ),         // O

  .cfg_err_cor_out                                      ( cfg_err_cor_out ),              // O
  .cfg_err_nonfatal_out                                 ( cfg_err_nonfatal_out ),         // O
  .cfg_err_fatal_out                                    ( cfg_err_fatal_out ),            // O
  .cfg_local_error                                      ( cfg_local_error ),              // O
  .cfg_ltr_enable                                       ( cfg_ltr_enable ),               // O
  .cfg_ltssm_state                                      ( cfg_ltssm_state_wire ),         // O
  .cfg_rcb_status                                       ( cfg_rcb_status ),               // O
  .cfg_dpa_substate_change                              ( cfg_dpa_substate_change ),      // O
  .cfg_obff_enable                                      ( cfg_obff_enable ),              // O
  .cfg_pl_status_change                                 ( cfg_pl_status_change ),         // O

  .cfg_tph_requester_enable                             ( cfg_tph_requester_enable ),     // O
  .cfg_tph_st_mode                                      ( cfg_tph_st_mode ),              // O
  .cfg_vf_tph_requester_enable                          ( cfg_vf_tph_requester_enable ),  // O
  .cfg_vf_tph_st_mode                                   ( cfg_vf_tph_st_mode ),           // O

  .cfg_msg_received                                     ( cfg_msg_received_wire ),        // O
  .cfg_msg_received_data                                ( cfg_msg_received_data_wire ),   // O
  .cfg_msg_received_type                                ( cfg_msg_received_type_wire ),   // O

  .cfg_msg_transmit                                     ( cfg_msg_transmit_wire ),        // I
  .cfg_msg_transmit_type                                ( cfg_msg_transmit_type_wire ),   // I
  .cfg_msg_transmit_data                                ( cfg_msg_transmit_data_wire ),   // I
  .cfg_msg_transmit_done                                ( cfg_msg_transmit_done_wire ),   // O

  .cfg_fc_ph                                            ( cfg_fc_ph_wire ),               // O
  .cfg_fc_pd                                            ( cfg_fc_pd_wire ),               // O
  .cfg_fc_nph                                           ( cfg_fc_nph_wire ),              // O
  .cfg_fc_npd                                           ( cfg_fc_npd_wire ),              // O
  .cfg_fc_cplh                                          ( cfg_fc_cplh_wire ),             // O
  .cfg_fc_cpld                                          ( cfg_fc_cpld_wire ),             // O
  .cfg_fc_sel                                           ( cfg_fc_sel_wire ),              // I

  .cfg_per_func_status_control                          ( cfg_per_func_status_control_wire ),     // I
  .cfg_per_func_status_data                             ( cfg_per_func_status_data ),             // O
  .cfg_per_function_number                              ( cfg_per_function_number ),              // I
  .cfg_per_function_output_request                      ( cfg_per_function_output_request_wire ), // I
  .cfg_per_function_update_done                         ( cfg_per_function_update_done ),         // O

  .cfg_dsn                                              ( cfg_dsn_wire ),                         // I
  .cfg_power_state_change_ack                           ( cfg_power_state_change_ack_wire ),      // I
  .cfg_power_state_change_interrupt                     ( cfg_power_state_change_interrupt ),     // O
  .cfg_err_cor_in                                       ( cfg_err_cor_in_wire ),                  // I
  .cfg_err_uncor_in                                     ( cfg_err_uncor_in_wire ),                // I

  .cfg_flr_in_process                                   ( cfg_flr_in_process ),                   // O
  .cfg_flr_done                                         ( cfg_flr_done_wire ),                    // I
  .cfg_vf_flr_in_process                                ( cfg_vf_flr_in_process ),                // O
  .cfg_vf_flr_done                                      ( cfg_vf_flr_done_wire ),                 // I

  .cfg_link_training_enable                             ( cfg_link_training_enable_wire ),        // I

  .cfg_interrupt_int                                    ( cfg_interrupt_int_wire ),               // I
  .cfg_interrupt_pending                                ( cfg_interrupt_pending_wire ),           // I
  .cfg_interrupt_sent                                   ( cfg_interrupt_sent ),                   // O

  .cfg_interrupt_msi_enable                             ( cfg_interrupt_msi_enable ),             // O
  .cfg_interrupt_msi_vf_enable                          ( cfg_interrupt_msi_vf_enable ),          // O
  .cfg_interrupt_msi_mmenable                           ( cfg_interrupt_msi_mmenable ),           // O
  .cfg_interrupt_msi_mask_update                        ( cfg_interrupt_msi_mask_update ),        // O
  .cfg_interrupt_msi_data                               ( cfg_interrupt_msi_data ),               // O
  .cfg_interrupt_msi_select                             ( cfg_interrupt_msi_select_wire ),        // I
  .cfg_interrupt_msi_int                                ( cfg_interrupt_msi_int_wire ),           // I
  .cfg_interrupt_msi_pending_status                     ( cfg_interrupt_msi_pending_status_wire ),// I
  .cfg_interrupt_msi_sent                               ( cfg_interrupt_msi_sent ),               // O
  .cfg_interrupt_msi_fail                               ( cfg_interrupt_msi_fail ),               // O

  .cfg_interrupt_msix_enable                            ( cfg_interrupt_msix_enable ),            // O
  .cfg_interrupt_msix_mask                              ( cfg_interrupt_msix_mask ),              // O
  .cfg_interrupt_msix_vf_enable                         ( cfg_interrupt_msix_vf_enable ),         // O
  .cfg_interrupt_msix_vf_mask                           ( cfg_interrupt_msix_vf_mask ),           // O
  .cfg_interrupt_msix_data                              ( cfg_interrupt_msix_data ),              // I
  .cfg_interrupt_msix_address                           ( cfg_interrupt_msix_address ),           // I
  .cfg_interrupt_msix_int                               ( cfg_interrupt_msix_int_wire ),          // I
  .cfg_interrupt_msix_sent                              ( cfg_interrupt_msix_sent ),              // O
  .cfg_interrupt_msix_fail                              ( cfg_interrupt_msix_fail ),              // O

  .cfg_interrupt_msi_attr                               ( cfg_interrupt_msi_attr ),               // I
  .cfg_interrupt_msi_tph_present                        ( cfg_interrupt_msi_tph_present ),        // I
  .cfg_interrupt_msi_tph_type                           ( cfg_interrupt_msi_tph_type ),           // I
  .cfg_interrupt_msi_tph_st_tag                         ( cfg_interrupt_msi_tph_st_tag ),         // I
  .cfg_interrupt_msi_function_number                    ( cfg_interrupt_msi_function_number ),    // I

  .cfg_ext_read_received                                ( cfg_ext_read_received ),                // O
  .cfg_ext_write_received                               ( cfg_ext_write_received ),               // O
  .cfg_ext_register_number                              ( cfg_ext_register_number ),              // O
  .cfg_ext_function_number                              ( cfg_ext_function_number ),              // O
  .cfg_ext_write_data                                   ( cfg_ext_write_data ),                   // O
  .cfg_ext_write_byte_enable                            ( cfg_ext_write_byte_enable ),            // O
  .cfg_ext_read_data                                    ( cfg_ext_read_data ),                    // I
  .cfg_ext_read_data_valid                              ( cfg_ext_read_data_valid_wire ),         // I

  .cfg_dev_id                                           ( cfg_dev_id ),                           // I
  .cfg_vend_id                                          ( cfg_vend_id ),                          // I
  .cfg_rev_id                                           ( cfg_rev_id ),                           // I
  .cfg_subsys_id                                        ( cfg_subsys_id ),                        // I
  .cfg_subsys_vend_id                                   ( cfg_subsys_vend_id ),                   // I

  .cfg_hot_reset_out                                    ( cfg_hot_reset_out_wire ),               // O
  .cfg_config_space_enable                              ( cfg_config_space_enable_wire ),         // I
  .cfg_req_pm_transition_l23_ready                      ( cfg_req_pm_transition_l23_ready_wire ), // I

  .cfg_hot_reset_in                                     ( cfg_hot_reset_in_wire ),                // I

  .cfg_ds_port_number                                   ( cfg_ds_port_number_wire ),              // I
  .cfg_ds_bus_number                                    ( cfg_ds_bus_number_wire ),               // I
  .cfg_ds_device_number                                 ( cfg_ds_device_number_wire ),            // I
  .cfg_ds_function_number                               ( cfg_ds_function_number_wire ),          // I

  .user_tph_stt_address                                 ( user_tph_stt_address_wire ),            // I
  .user_tph_function_num                                ( user_tph_function_num_wire ),           // I
  .user_tph_stt_read_data                               ( user_tph_stt_read_data ),               // O
  .user_tph_stt_read_data_valid                         ( user_tph_stt_read_data_valid ),         // O
  .user_tph_stt_read_enable                             ( user_tph_stt_read_enable_wire ),        // I

  .drp_rdy                                              ( drp_rdy_wire ),                         // O
  .drp_do                                               ( drp_do_wire ),                          // O
  .drp_clk                                              ( drp_clk_wire ),                         // I
  .drp_en                                               ( drp_en_wire ),                          // I
  .drp_we                                               ( drp_we_wire ),                          // I
  .drp_addr                                             ( drp_addr_wire ),                        // I
  .drp_di                                               ( drp_di_wire ),                          // I

  .pipe_tx_reset_gt                                     ( pipe_tx_reset ),
  .pipe_rx0_polarity_gt                                 ( pipe_rx0_polarity ),
  .pipe_rx1_polarity_gt                                 ( pipe_rx1_polarity ),
  .pipe_rx2_polarity_gt                                 ( pipe_rx2_polarity ),
  .pipe_rx3_polarity_gt                                 ( pipe_rx3_polarity ),
  .pipe_rx4_polarity_gt                                 ( pipe_rx4_polarity ),
  .pipe_rx5_polarity_gt                                 ( pipe_rx5_polarity ),
  .pipe_rx6_polarity_gt                                 ( pipe_rx6_polarity ),
  .pipe_rx7_polarity_gt                                 ( pipe_rx7_polarity ),

  .pipe_tx0_compliance_gt                               ( pipe_tx0_compliance ),
  .pipe_tx1_compliance_gt                               ( pipe_tx1_compliance ),
  .pipe_tx2_compliance_gt                               ( pipe_tx2_compliance ),
  .pipe_tx3_compliance_gt                               ( pipe_tx3_compliance ),
  .pipe_tx4_compliance_gt                               ( pipe_tx4_compliance ),
  .pipe_tx5_compliance_gt                               ( pipe_tx5_compliance ),
  .pipe_tx6_compliance_gt                               ( pipe_tx6_compliance ),
  .pipe_tx7_compliance_gt                               ( pipe_tx7_compliance ),

  .pipe_tx0_data_valid_gt                               ( ),
  .pipe_tx1_data_valid_gt                               ( ),
  .pipe_tx2_data_valid_gt                               ( ),
  .pipe_tx3_data_valid_gt                               ( ),
  .pipe_tx4_data_valid_gt                               ( ),
  .pipe_tx5_data_valid_gt                               ( ),
  .pipe_tx6_data_valid_gt                               ( ),
  .pipe_tx7_data_valid_gt                               ( ),

  .pipe_tx0_elec_idle_gt                                ( pipe_tx0_elec_idle ),
  .pipe_tx1_elec_idle_gt                                ( pipe_tx1_elec_idle ),
  .pipe_tx2_elec_idle_gt                                ( pipe_tx2_elec_idle ),
  .pipe_tx3_elec_idle_gt                                ( pipe_tx3_elec_idle ),
  .pipe_tx4_elec_idle_gt                                ( pipe_tx4_elec_idle ),
  .pipe_tx5_elec_idle_gt                                ( pipe_tx5_elec_idle ),
  .pipe_tx6_elec_idle_gt                                ( pipe_tx6_elec_idle ),
  .pipe_tx7_elec_idle_gt                                ( pipe_tx7_elec_idle ),

  .pipe_tx0_start_block_gt                              ( ),
  .pipe_tx1_start_block_gt                              ( ),
  .pipe_tx2_start_block_gt                              ( ),
  .pipe_tx3_start_block_gt                              ( ),
  .pipe_tx4_start_block_gt                              ( ),
  .pipe_tx5_start_block_gt                              ( ),
  .pipe_tx6_start_block_gt                              ( ),
  .pipe_tx7_start_block_gt                              ( ),

  .pipe_tx_deemph_gt                                    ( pipe_tx_deemph ),
  .pipe_tx_rcvr_det_gt                                  ( pipe_tx_rcvr_det ),
  .pipe_tx_rate_gt                                      ( pipe_tx_rate ),
  .pipe_tx_margin_gt                                    ( pipe_tx_margin ),
  .pipe_tx_swing_gt                                     ( pipe_tx_swing ),
  .pipe_tx_eqfs_gt                                      ( pipe_tx_eqfs ),
  .pipe_tx_eqlf_gt                                      ( pipe_tx_eqlf ),

  .pipe_rx0_eqcontrol_gt                                ( pipe_rx0_eqcontrol ),
  .pipe_rx1_eqcontrol_gt                                ( pipe_rx1_eqcontrol ),
  .pipe_rx2_eqcontrol_gt                                ( pipe_rx2_eqcontrol ),
  .pipe_rx3_eqcontrol_gt                                ( pipe_rx3_eqcontrol ),
  .pipe_rx4_eqcontrol_gt                                ( pipe_rx4_eqcontrol ),
  .pipe_rx5_eqcontrol_gt                                ( pipe_rx5_eqcontrol ),
  .pipe_rx6_eqcontrol_gt                                ( pipe_rx6_eqcontrol ),
  .pipe_rx7_eqcontrol_gt                                ( pipe_rx7_eqcontrol ),

  .pipe_tx0_char_is_k_gt                                ( pipe_tx0_char_is_k ),
  .pipe_tx1_char_is_k_gt                                ( pipe_tx1_char_is_k ),
  .pipe_tx2_char_is_k_gt                                ( pipe_tx2_char_is_k ),
  .pipe_tx3_char_is_k_gt                                ( pipe_tx3_char_is_k ),
  .pipe_tx4_char_is_k_gt                                ( pipe_tx4_char_is_k ),
  .pipe_tx5_char_is_k_gt                                ( pipe_tx5_char_is_k ),
  .pipe_tx6_char_is_k_gt                                ( pipe_tx6_char_is_k ),
  .pipe_tx7_char_is_k_gt                                ( pipe_tx7_char_is_k ),

  .pipe_tx0_eqcontrol_gt                                ( pipe_tx0_eqcontrol ),
  .pipe_tx1_eqcontrol_gt                                ( pipe_tx1_eqcontrol ),
  .pipe_tx2_eqcontrol_gt                                ( pipe_tx2_eqcontrol ),
  .pipe_tx3_eqcontrol_gt                                ( pipe_tx3_eqcontrol ),
  .pipe_tx4_eqcontrol_gt                                ( pipe_tx4_eqcontrol ),
  .pipe_tx5_eqcontrol_gt                                ( pipe_tx5_eqcontrol ),
  .pipe_tx6_eqcontrol_gt                                ( pipe_tx6_eqcontrol ),
  .pipe_tx7_eqcontrol_gt                                ( pipe_tx7_eqcontrol ),

  .pipe_tx0_powerdown_gt                                ( pipe_tx0_powerdown ),
  .pipe_tx1_powerdown_gt                                ( pipe_tx1_powerdown ),
  .pipe_tx2_powerdown_gt                                ( pipe_tx2_powerdown ),
  .pipe_tx3_powerdown_gt                                ( pipe_tx3_powerdown ),
  .pipe_tx4_powerdown_gt                                ( pipe_tx4_powerdown ),
  .pipe_tx5_powerdown_gt                                ( pipe_tx5_powerdown ),
  .pipe_tx6_powerdown_gt                                ( pipe_tx6_powerdown ),
  .pipe_tx7_powerdown_gt                                ( pipe_tx7_powerdown ),

  .pipe_tx0_syncheader_gt                               ( ),
  .pipe_tx1_syncheader_gt                               ( ),
  .pipe_tx2_syncheader_gt                               ( ),
  .pipe_tx3_syncheader_gt                               ( ),
  .pipe_tx4_syncheader_gt                               ( ),
  .pipe_tx5_syncheader_gt                               ( ),
  .pipe_tx6_syncheader_gt                               ( ),
  .pipe_tx7_syncheader_gt                               ( ),

  .pipe_rx0_eqpreset_gt                                 ( pipe_rx0_eqpreset ),
  .pipe_rx1_eqpreset_gt                                 ( pipe_rx1_eqpreset ),
  .pipe_rx2_eqpreset_gt                                 ( pipe_rx2_eqpreset ),
  .pipe_rx3_eqpreset_gt                                 ( pipe_rx3_eqpreset ),
  .pipe_rx4_eqpreset_gt                                 ( pipe_rx4_eqpreset ),
  .pipe_rx5_eqpreset_gt                                 ( pipe_rx5_eqpreset ),
  .pipe_rx6_eqpreset_gt                                 ( pipe_rx6_eqpreset ),
  .pipe_rx7_eqpreset_gt                                 ( pipe_rx7_eqpreset ),

  .pipe_tx0_data_gt                                     ( pipe_tx0_data ),
  .pipe_tx1_data_gt                                     ( pipe_tx1_data ),
  .pipe_tx2_data_gt                                     ( pipe_tx2_data ),
  .pipe_tx3_data_gt                                     ( pipe_tx3_data ),
  .pipe_tx4_data_gt                                     ( pipe_tx4_data ),
  .pipe_tx5_data_gt                                     ( pipe_tx5_data ),
  .pipe_tx6_data_gt                                     ( pipe_tx6_data ),
  .pipe_tx7_data_gt                                     ( pipe_tx7_data ),

  .pipe_rx0_eqlp_txpreset_gt                            ( pipe_rx0_eq_txpreset ),
  .pipe_rx1_eqlp_txpreset_gt                            ( pipe_rx1_eq_txpreset ),
  .pipe_rx2_eqlp_txpreset_gt                            ( pipe_rx2_eq_txpreset ),
  .pipe_rx3_eqlp_txpreset_gt                            ( pipe_rx3_eq_txpreset ),
  .pipe_rx4_eqlp_txpreset_gt                            ( pipe_rx4_eq_txpreset ),
  .pipe_rx5_eqlp_txpreset_gt                            ( pipe_rx5_eq_txpreset ),
  .pipe_rx6_eqlp_txpreset_gt                            ( pipe_rx6_eq_txpreset ),
  .pipe_rx7_eqlp_txpreset_gt                            ( pipe_rx7_eq_txpreset ),

  .pipe_tx0_eqpreset_gt                                 ( pipe_tx0_eqpreset ),
  .pipe_tx1_eqpreset_gt                                 ( pipe_tx1_eqpreset ),
  .pipe_tx2_eqpreset_gt                                 ( pipe_tx2_eqpreset ),
  .pipe_tx3_eqpreset_gt                                 ( pipe_tx3_eqpreset ),
  .pipe_tx4_eqpreset_gt                                 ( pipe_tx4_eqpreset ),
  .pipe_tx5_eqpreset_gt                                 ( pipe_tx5_eqpreset ),
  .pipe_tx6_eqpreset_gt                                 ( pipe_tx6_eqpreset ),
  .pipe_tx7_eqpreset_gt                                 ( pipe_tx7_eqpreset ),

  .pipe_rx0_eqlp_lffs_gt                                ( pipe_rx0_eq_lffs ),
  .pipe_rx1_eqlp_lffs_gt                                ( pipe_rx1_eq_lffs ),
  .pipe_rx2_eqlp_lffs_gt                                ( pipe_rx2_eq_lffs ),
  .pipe_rx3_eqlp_lffs_gt                                ( pipe_rx3_eq_lffs ),
  .pipe_rx4_eqlp_lffs_gt                                ( pipe_rx4_eq_lffs ),
  .pipe_rx5_eqlp_lffs_gt                                ( pipe_rx5_eq_lffs ),
  .pipe_rx6_eqlp_lffs_gt                                ( pipe_rx6_eq_lffs ),
  .pipe_rx7_eqlp_lffs_gt                                ( pipe_rx7_eq_lffs ),

  .pipe_tx0_eqdeemph_gt                                 ( pipe_tx0_eqdeemph ),
  .pipe_tx1_eqdeemph_gt                                 ( pipe_tx1_eqdeemph ),
  .pipe_tx2_eqdeemph_gt                                 ( pipe_tx2_eqdeemph ),
  .pipe_tx3_eqdeemph_gt                                 ( pipe_tx3_eqdeemph ),
  .pipe_tx4_eqdeemph_gt                                 ( pipe_tx4_eqdeemph ),
  .pipe_tx5_eqdeemph_gt                                 ( pipe_tx5_eqdeemph ),
  .pipe_tx6_eqdeemph_gt                                 ( pipe_tx6_eqdeemph ),
  .pipe_tx7_eqdeemph_gt                                 ( pipe_tx7_eqdeemph ),

  .pipe_rx_slide_gt                                     ( pipe_rx_slide ),

  .pipe_rx0_data_valid_gt                               ( pipe_rx0_data_valid ),
  .pipe_rx1_data_valid_gt                               ( pipe_rx1_data_valid ),
  .pipe_rx2_data_valid_gt                               ( pipe_rx2_data_valid ),
  .pipe_rx3_data_valid_gt                               ( pipe_rx3_data_valid ),
  .pipe_rx4_data_valid_gt                               ( pipe_rx4_data_valid ),
  .pipe_rx5_data_valid_gt                               ( pipe_rx5_data_valid ),
  .pipe_rx6_data_valid_gt                               ( pipe_rx6_data_valid ),
  .pipe_rx7_data_valid_gt                               ( pipe_rx7_data_valid ),

  .pipe_rx0_elec_idle_gt                                ( pipe_rx0_elec_idle ),
  .pipe_rx1_elec_idle_gt                                ( pipe_rx1_elec_idle ),
  .pipe_rx2_elec_idle_gt                                ( pipe_rx2_elec_idle ),
  .pipe_rx3_elec_idle_gt                                ( pipe_rx3_elec_idle ),
  .pipe_rx4_elec_idle_gt                                ( pipe_rx4_elec_idle ),
  .pipe_rx5_elec_idle_gt                                ( pipe_rx5_elec_idle ),
  .pipe_rx6_elec_idle_gt                                ( pipe_rx6_elec_idle ),
  .pipe_rx7_elec_idle_gt                                ( pipe_rx7_elec_idle ),

  .pipe_rx0_eqdone_gt                                   ( pipe_rx0_eqdone ),
  .pipe_rx1_eqdone_gt                                   ( pipe_rx1_eqdone ),
  .pipe_rx2_eqdone_gt                                   ( pipe_rx2_eqdone ),
  .pipe_rx3_eqdone_gt                                   ( pipe_rx3_eqdone ),
  .pipe_rx4_eqdone_gt                                   ( pipe_rx4_eqdone ),
  .pipe_rx5_eqdone_gt                                   ( pipe_rx5_eqdone ),
  .pipe_rx6_eqdone_gt                                   ( pipe_rx6_eqdone ),
  .pipe_rx7_eqdone_gt                                   ( pipe_rx7_eqdone ),

  .pipe_rx0_eqlp_adaptdone_gt                           ( pipe_rx0_eq_adapt_done ),
  .pipe_rx1_eqlp_adaptdone_gt                           ( pipe_rx1_eq_adapt_done ),
  .pipe_rx2_eqlp_adaptdone_gt                           ( pipe_rx2_eq_adapt_done ),
  .pipe_rx3_eqlp_adaptdone_gt                           ( pipe_rx3_eq_adapt_done ),
  .pipe_rx4_eqlp_adaptdone_gt                           ( pipe_rx4_eq_adapt_done ),
  .pipe_rx5_eqlp_adaptdone_gt                           ( pipe_rx5_eq_adapt_done ),
  .pipe_rx6_eqlp_adaptdone_gt                           ( pipe_rx6_eq_adapt_done ),
  .pipe_rx7_eqlp_adaptdone_gt                           ( pipe_rx7_eq_adapt_done ),

  .pipe_rx0_eqlp_lffs_sel_gt                            ( pipe_rx0_eq_lffs_sel ),
  .pipe_rx1_eqlp_lffs_sel_gt                            ( pipe_rx1_eq_lffs_sel ),
  .pipe_rx2_eqlp_lffs_sel_gt                            ( pipe_rx2_eq_lffs_sel ),
  .pipe_rx3_eqlp_lffs_sel_gt                            ( pipe_rx3_eq_lffs_sel ),
  .pipe_rx4_eqlp_lffs_sel_gt                            ( pipe_rx4_eq_lffs_sel ),
  .pipe_rx5_eqlp_lffs_sel_gt                            ( pipe_rx5_eq_lffs_sel ),
  .pipe_rx6_eqlp_lffs_sel_gt                            ( pipe_rx6_eq_lffs_sel ),
  .pipe_rx7_eqlp_lffs_sel_gt                            ( pipe_rx7_eq_lffs_sel ),

  .pipe_rx0_phy_status_gt                               ( pipe_rx0_phy_status ),
  .pipe_rx1_phy_status_gt                               ( pipe_rx1_phy_status ),
  .pipe_rx2_phy_status_gt                               ( pipe_rx2_phy_status ),
  .pipe_rx3_phy_status_gt                               ( pipe_rx3_phy_status ),
  .pipe_rx4_phy_status_gt                               ( pipe_rx4_phy_status ),
  .pipe_rx5_phy_status_gt                               ( pipe_rx5_phy_status ),
  .pipe_rx6_phy_status_gt                               ( pipe_rx6_phy_status ),
  .pipe_rx7_phy_status_gt                               ( pipe_rx7_phy_status ),

  .pipe_rx0_start_block_gt                              ( pipe_rx0_start_block ),
  .pipe_rx1_start_block_gt                              ( pipe_rx1_start_block ),
  .pipe_rx2_start_block_gt                              ( pipe_rx2_start_block ),
  .pipe_rx3_start_block_gt                              ( pipe_rx3_start_block ),
  .pipe_rx4_start_block_gt                              ( pipe_rx4_start_block ),
  .pipe_rx5_start_block_gt                              ( pipe_rx5_start_block ),
  .pipe_rx6_start_block_gt                              ( pipe_rx6_start_block ),
  .pipe_rx7_start_block_gt                              ( pipe_rx7_start_block ),

  .pipe_rx0_valid_gt                                    ( pipe_rx0_valid ),
  .pipe_rx1_valid_gt                                    ( pipe_rx1_valid ),
  .pipe_rx2_valid_gt                                    ( pipe_rx2_valid ),
  .pipe_rx3_valid_gt                                    ( pipe_rx3_valid ),
  .pipe_rx4_valid_gt                                    ( pipe_rx4_valid ),
  .pipe_rx5_valid_gt                                    ( pipe_rx5_valid ),
  .pipe_rx6_valid_gt                                    ( pipe_rx6_valid ),
  .pipe_rx7_valid_gt                                    ( pipe_rx7_valid ),

  .pipe_tx0_eqdone_gt                                   ( pipe_tx0_eqdone ),
  .pipe_tx1_eqdone_gt                                   ( pipe_tx1_eqdone ),
  .pipe_tx2_eqdone_gt                                   ( pipe_tx2_eqdone ),
  .pipe_tx3_eqdone_gt                                   ( pipe_tx3_eqdone ),
  .pipe_tx4_eqdone_gt                                   ( pipe_tx4_eqdone ),
  .pipe_tx5_eqdone_gt                                   ( pipe_tx5_eqdone ),
  .pipe_tx6_eqdone_gt                                   ( pipe_tx6_eqdone ),
  .pipe_tx7_eqdone_gt                                   ( pipe_tx7_eqdone ),

  .pipe_rx0_eqlp_new_txcoef_forpreset_gt                ( pipe_rx0_eq_new_txcoeff ),
  .pipe_rx1_eqlp_new_txcoef_forpreset_gt                ( pipe_rx1_eq_new_txcoeff ),
  .pipe_rx2_eqlp_new_txcoef_forpreset_gt                ( pipe_rx2_eq_new_txcoeff ),
  .pipe_rx3_eqlp_new_txcoef_forpreset_gt                ( pipe_rx3_eq_new_txcoeff ),
  .pipe_rx4_eqlp_new_txcoef_forpreset_gt                ( pipe_rx4_eq_new_txcoeff ),
  .pipe_rx5_eqlp_new_txcoef_forpreset_gt                ( pipe_rx5_eq_new_txcoeff ),
  .pipe_rx6_eqlp_new_txcoef_forpreset_gt                ( pipe_rx6_eq_new_txcoeff ),
  .pipe_rx7_eqlp_new_txcoef_forpreset_gt                ( pipe_rx7_eq_new_txcoeff ),

  .pipe_tx0_eqcoeff_gt                                  ( pipe_tx0_eqcoeff ),
  .pipe_tx1_eqcoeff_gt                                  ( pipe_tx1_eqcoeff ),
  .pipe_tx2_eqcoeff_gt                                  ( pipe_tx2_eqcoeff ),
  .pipe_tx3_eqcoeff_gt                                  ( pipe_tx3_eqcoeff ),
  .pipe_tx4_eqcoeff_gt                                  ( pipe_tx4_eqcoeff ),
  .pipe_tx5_eqcoeff_gt                                  ( pipe_tx5_eqcoeff ),
  .pipe_tx6_eqcoeff_gt                                  ( pipe_tx6_eqcoeff ),
  .pipe_tx7_eqcoeff_gt                                  ( pipe_tx7_eqcoeff ),

  .pipe_rx0_char_is_k_gt                                ( pipe_rx0_char_is_k ),
  .pipe_rx1_char_is_k_gt                                ( pipe_rx1_char_is_k ),
  .pipe_rx2_char_is_k_gt                                ( pipe_rx2_char_is_k ),
  .pipe_rx3_char_is_k_gt                                ( pipe_rx3_char_is_k ),
  .pipe_rx4_char_is_k_gt                                ( pipe_rx4_char_is_k ),
  .pipe_rx5_char_is_k_gt                                ( pipe_rx5_char_is_k ),
  .pipe_rx6_char_is_k_gt                                ( pipe_rx6_char_is_k ),
  .pipe_rx7_char_is_k_gt                                ( pipe_rx7_char_is_k ),

  .pipe_rx0_syncheader_gt                               ( pipe_rx0_syncheader ),
  .pipe_rx1_syncheader_gt                               ( pipe_rx1_syncheader ),
  .pipe_rx2_syncheader_gt                               ( pipe_rx2_syncheader ),
  .pipe_rx3_syncheader_gt                               ( pipe_rx3_syncheader ),
  .pipe_rx4_syncheader_gt                               ( pipe_rx4_syncheader ),
  .pipe_rx5_syncheader_gt                               ( pipe_rx5_syncheader ),
  .pipe_rx6_syncheader_gt                               ( pipe_rx6_syncheader ),
  .pipe_rx7_syncheader_gt                               ( pipe_rx7_syncheader ),

  .pipe_rx0_status_gt                                   ( pipe_rx0_status ),
  .pipe_rx1_status_gt                                   ( pipe_rx1_status ),
  .pipe_rx2_status_gt                                   ( pipe_rx2_status ),
  .pipe_rx3_status_gt                                   ( pipe_rx3_status ),
  .pipe_rx4_status_gt                                   ( pipe_rx4_status ),
  .pipe_rx5_status_gt                                   ( pipe_rx5_status ),
  .pipe_rx6_status_gt                                   ( pipe_rx6_status ),
  .pipe_rx7_status_gt                                   ( pipe_rx7_status ),

  .pipe_rx0_data_gt                                     ( pipe_rx0_data ),
  .pipe_rx1_data_gt                                     ( pipe_rx1_data ),
  .pipe_rx2_data_gt                                     ( pipe_rx2_data ),
  .pipe_rx3_data_gt                                     ( pipe_rx3_data ),
  .pipe_rx4_data_gt                                     ( pipe_rx4_data ),
  .pipe_rx5_data_gt                                     ( pipe_rx5_data ),
  .pipe_rx6_data_gt                                     ( pipe_rx6_data ),
  .pipe_rx7_data_gt                                     ( pipe_rx7_data ),

  .pipe_rx_syncdone_gt                                  ( pipe_rx_syncdone )
);

  xdma_0_pcie3_ip_gt_top #(
    .TCQ                                                  ( TCQ ),
    .PL_LINK_CAP_MAX_LINK_WIDTH                           ( PL_LINK_CAP_MAX_LINK_WIDTH ),
    .PL_LINK_CAP_MAX_LINK_SPEED                           ( PL_LINK_CAP_MAX_LINK_SPEED ),
    .REF_CLK_FREQ                                         ( REF_CLK_FREQ ),
    .USER_CLK2_FREQ                                       ( USER_CLK2_FREQ ),
    .USER_CLK_FREQ                                        ( USER_CLK_FREQ ),
    .PCIE_ASYNC_EN                                        ( PCIE_ASYNC_EN ),
    // synthesis translate_off
    .PL_SIM_FAST_LINK_TRAINING                            ( ENABLE_FAST_SIM_TRAINING ),
    // synthesis translate_on
    .PCIE_EXT_CLK                                         ( PCIE_EXT_CLK ),
    .PCIE_EXT_GT_COMMON                                   ( PCIE_EXT_GT_COMMON ),
    .EXT_CH_GT_DRP                                        ( EXT_CH_GT_DRP ),
    .TX_MARGIN_FULL_0                                     ( TX_MARGIN_FULL_0 ),
    .TX_MARGIN_FULL_1                                     ( TX_MARGIN_FULL_1 ),
    .TX_MARGIN_FULL_2                                     ( TX_MARGIN_FULL_2 ),
    .TX_MARGIN_FULL_3                                     ( TX_MARGIN_FULL_3 ),
    .TX_MARGIN_FULL_4                                     ( TX_MARGIN_FULL_4 ),
    .TX_MARGIN_LOW_0                                      ( TX_MARGIN_LOW_0 ), 
    .TX_MARGIN_LOW_1                                      ( TX_MARGIN_LOW_1 ), 
    .TX_MARGIN_LOW_2                                      ( TX_MARGIN_LOW_2 ),
    .TX_MARGIN_LOW_3                                      ( TX_MARGIN_LOW_3 ),
    .TX_MARGIN_LOW_4                                      ( TX_MARGIN_LOW_4 ),
    .PCIE_TXBUF_EN                                        ( PCIE_TXBUF_EN ),
    .PCIE_GT_DEVICE                                       ( PCIE_GT_DEVICE ),
    .PCIE_CHAN_BOND                                       ( PCIE_CHAN_BOND ),
    .PCIE_CHAN_BOND_EN                                    ( PCIE_CHAN_BOND_EN ),
    .PCIE_USE_MODE                                        ( PCIE_USE_MODE ),
    .PCIE_LPM_DFE                                         ( PCIE_LPM_DFE ),
    .PCIE_LINK_SPEED                                      ( PCIE_LINK_SPEED )
  ) gt_top_i(

    //------------------------------------------------------------------------------------//
    // Pipe Per-Link Signals                                                              //
    //------------------------------------------------------------------------------------//
    .pipe_tx_rcvr_det                                    ( pipe_tx_rcvr_det        ),
    .pipe_tx_reset                                       ( pipe_tx_reset           ),
    .pipe_tx_rate                                        ( pipe_tx_rate            ),
    .pipe_tx_deemph                                      ( pipe_tx_deemph          ),
    .pipe_tx_margin                                      ( pipe_tx_margin          ),
    .pipe_tx_swing                                       ( pipe_tx_swing           ),
    .pipe_txeq_fs                                        ( pipe_tx_eqfs            ),
    .pipe_txeq_lf                                        ( pipe_tx_eqlf            ),
    .pipe_rxslide                                        ( pipe_rx_slide           ),
    .pipe_rxsync_done                                    ( pipe_rx_syncdone        ),
    .cfg_ltssm_state                                     ( cfg_ltssm_state_wire    ),

    // Pipe Per-Lane Signals - Lane 0
    .pipe_rx0_char_is_k                                  ( pipe_rx0_char_is_k      ),
    .pipe_rx0_data                                       ( pipe_rx0_data           ),
    .pipe_rx0_valid                                      ( pipe_rx0_valid          ),
    .pipe_rx0_chanisaligned                              ( ),
    .pipe_rx0_status                                     ( pipe_rx0_status         ),
    .pipe_rx0_phy_status                                 ( pipe_rx0_phy_status     ),
    .pipe_rx0_elec_idle                                  ( pipe_rx0_elec_idle      ),
    .pipe_rx0_polarity                                   ( pipe_rx0_polarity       ),
    .pipe_tx0_compliance                                 ( pipe_tx0_compliance     ),
    .pipe_tx0_char_is_k                                  ( pipe_tx0_char_is_k      ),
    .pipe_tx0_data                                       ( pipe_tx0_data           ),
    .pipe_tx0_elec_idle                                  ( pipe_tx0_elec_idle      ),
    .pipe_tx0_powerdown                                  ( pipe_tx0_powerdown      ),
    .pipe_tx0_eqcontrol                                  ( pipe_tx0_eqcontrol      ),
    .pipe_tx0_eqpreset                                   ( pipe_tx0_eqpreset       ),
    .pipe_tx0_eqdeemph                                   ( pipe_tx0_eqdeemph       ),
    .pipe_tx0_eqdone                                     ( pipe_tx0_eqdone         ),
    .pipe_tx0_eqcoeff                                    ( pipe_tx0_eqcoeff        ),
    .pipe_rx0_eqcontrol                                  ( pipe_rx0_eqcontrol      ),
    .pipe_rx0_eqpreset                                   ( pipe_rx0_eqpreset       ),
    .pipe_rx0_eq_lffs                                    ( pipe_rx0_eq_lffs        ),
    .pipe_rx0_eq_txpreset                                ( pipe_rx0_eq_txpreset    ),
    .pipe_rx0_eq_new_txcoeff                             ( pipe_rx0_eq_new_txcoeff ),
    .pipe_rx0_eq_lffs_sel                                ( pipe_rx0_eq_lffs_sel    ),
    .pipe_rx0_eq_adapt_done                              ( pipe_rx0_eq_adapt_done  ),
    .pipe_rx0_eqdone                                     ( pipe_rx0_eqdone         ),

    // Pipe Per-Lane Signals - Lane 1
    .pipe_rx1_char_is_k                                  ( pipe_rx1_char_is_k      ),
    .pipe_rx1_data                                       ( pipe_rx1_data           ),
    .pipe_rx1_valid                                      ( pipe_rx1_valid          ),
    .pipe_rx1_chanisaligned                              ( ),
    .pipe_rx1_status                                     ( pipe_rx1_status         ),
    .pipe_rx1_phy_status                                 ( pipe_rx1_phy_status     ),
    .pipe_rx1_elec_idle                                  ( pipe_rx1_elec_idle      ),
    .pipe_rx1_polarity                                   ( pipe_rx1_polarity       ),
    .pipe_tx1_compliance                                 ( pipe_tx1_compliance     ),
    .pipe_tx1_char_is_k                                  ( pipe_tx1_char_is_k      ),
    .pipe_tx1_data                                       ( pipe_tx1_data           ),
    .pipe_tx1_elec_idle                                  ( pipe_tx1_elec_idle      ),
    .pipe_tx1_powerdown                                  ( pipe_tx1_powerdown      ),
    .pipe_tx1_eqcontrol                                  ( pipe_tx1_eqcontrol      ),
    .pipe_tx1_eqpreset                                   ( pipe_tx1_eqpreset       ),
    .pipe_tx1_eqdeemph                                   ( pipe_tx1_eqdeemph       ),
    .pipe_tx1_eqdone                                     ( pipe_tx1_eqdone         ),
    .pipe_tx1_eqcoeff                                    ( pipe_tx1_eqcoeff        ),
    .pipe_rx1_eqcontrol                                  ( pipe_rx1_eqcontrol      ),
    .pipe_rx1_eqpreset                                   ( pipe_rx1_eqpreset       ),
    .pipe_rx1_eq_lffs                                    ( pipe_rx1_eq_lffs        ),
    .pipe_rx1_eq_txpreset                                ( pipe_rx1_eq_txpreset    ),
    .pipe_rx1_eq_new_txcoeff                             ( pipe_rx1_eq_new_txcoeff ),
    .pipe_rx1_eq_lffs_sel                                ( pipe_rx1_eq_lffs_sel    ),
    .pipe_rx1_eq_adapt_done                              ( pipe_rx1_eq_adapt_done  ),
    .pipe_rx1_eqdone                                     ( pipe_rx1_eqdone         ),

    // Pipe Per-Lane Signals - Lane 2
    .pipe_rx2_char_is_k                                  ( pipe_rx2_char_is_k      ),
    .pipe_rx2_data                                       ( pipe_rx2_data           ),
    .pipe_rx2_valid                                      ( pipe_rx2_valid          ),
    .pipe_rx2_chanisaligned                              ( ),
    .pipe_rx2_status                                     ( pipe_rx2_status         ),
    .pipe_rx2_phy_status                                 ( pipe_rx2_phy_status     ),
    .pipe_rx2_elec_idle                                  ( pipe_rx2_elec_idle      ),
    .pipe_rx2_polarity                                   ( pipe_rx2_polarity       ),
    .pipe_tx2_compliance                                 ( pipe_tx2_compliance     ),
    .pipe_tx2_char_is_k                                  ( pipe_tx2_char_is_k      ),
    .pipe_tx2_data                                       ( pipe_tx2_data           ),
    .pipe_tx2_elec_idle                                  ( pipe_tx2_elec_idle      ),
    .pipe_tx2_powerdown                                  ( pipe_tx2_powerdown      ),
    .pipe_tx2_eqcontrol                                  ( pipe_tx2_eqcontrol      ),
    .pipe_tx2_eqpreset                                   ( pipe_tx2_eqpreset       ),
    .pipe_tx2_eqdeemph                                   ( pipe_tx2_eqdeemph       ),
    .pipe_tx2_eqdone                                     ( pipe_tx2_eqdone         ),
    .pipe_tx2_eqcoeff                                    ( pipe_tx2_eqcoeff        ),
    .pipe_rx2_eqcontrol                                  ( pipe_rx2_eqcontrol      ),
    .pipe_rx2_eqpreset                                   ( pipe_rx2_eqpreset       ),
    .pipe_rx2_eq_lffs                                    ( pipe_rx2_eq_lffs        ),
    .pipe_rx2_eq_txpreset                                ( pipe_rx2_eq_txpreset    ),
    .pipe_rx2_eq_new_txcoeff                             ( pipe_rx2_eq_new_txcoeff ),
    .pipe_rx2_eq_lffs_sel                                ( pipe_rx2_eq_lffs_sel    ),
    .pipe_rx2_eq_adapt_done                              ( pipe_rx2_eq_adapt_done  ),
    .pipe_rx2_eqdone                                     ( pipe_rx2_eqdone         ),

    // Pipe Per-Lane Signals - Lane 3
    .pipe_rx3_char_is_k                                  ( pipe_rx3_char_is_k      ),
    .pipe_rx3_data                                       ( pipe_rx3_data           ),
    .pipe_rx3_valid                                      ( pipe_rx3_valid          ),
    .pipe_rx3_chanisaligned                              ( ),
    .pipe_rx3_status                                     ( pipe_rx3_status         ),
    .pipe_rx3_phy_status                                 ( pipe_rx3_phy_status     ),
    .pipe_rx3_elec_idle                                  ( pipe_rx3_elec_idle      ),
    .pipe_rx3_polarity                                   ( pipe_rx3_polarity       ),
    .pipe_tx3_compliance                                 ( pipe_tx3_compliance     ),
    .pipe_tx3_char_is_k                                  ( pipe_tx3_char_is_k      ),
    .pipe_tx3_data                                       ( pipe_tx3_data           ),
    .pipe_tx3_elec_idle                                  ( pipe_tx3_elec_idle      ),
    .pipe_tx3_powerdown                                  ( pipe_tx3_powerdown      ),
    .pipe_tx3_eqcontrol                                  ( pipe_tx3_eqcontrol      ),
    .pipe_tx3_eqpreset                                   ( pipe_tx3_eqpreset       ),
    .pipe_tx3_eqdeemph                                   ( pipe_tx3_eqdeemph       ),
    .pipe_tx3_eqdone                                     ( pipe_tx3_eqdone         ),
    .pipe_tx3_eqcoeff                                    ( pipe_tx3_eqcoeff        ),
    .pipe_rx3_eqcontrol                                  ( pipe_rx3_eqcontrol      ),
    .pipe_rx3_eqpreset                                   ( pipe_rx3_eqpreset       ),
    .pipe_rx3_eq_lffs                                    ( pipe_rx3_eq_lffs        ),
    .pipe_rx3_eq_txpreset                                ( pipe_rx3_eq_txpreset    ),
    .pipe_rx3_eq_new_txcoeff                             ( pipe_rx3_eq_new_txcoeff ),
    .pipe_rx3_eq_lffs_sel                                ( pipe_rx3_eq_lffs_sel    ),
    .pipe_rx3_eq_adapt_done                              ( pipe_rx3_eq_adapt_done  ),
    .pipe_rx3_eqdone                                     ( pipe_rx3_eqdone         ),

    // Pipe Per-Lane Signals - Lane 4
    .pipe_rx4_char_is_k                                  ( pipe_rx4_char_is_k      ),
    .pipe_rx4_data                                       ( pipe_rx4_data           ),
    .pipe_rx4_valid                                      ( pipe_rx4_valid          ),
    .pipe_rx4_chanisaligned                              ( ),
    .pipe_rx4_status                                     ( pipe_rx4_status         ),
    .pipe_rx4_phy_status                                 ( pipe_rx4_phy_status     ),
    .pipe_rx4_elec_idle                                  ( pipe_rx4_elec_idle      ),
    .pipe_rx4_polarity                                   ( pipe_rx4_polarity       ),
    .pipe_tx4_compliance                                 ( pipe_tx4_compliance     ),
    .pipe_tx4_char_is_k                                  ( pipe_tx4_char_is_k      ),
    .pipe_tx4_data                                       ( pipe_tx4_data           ),
    .pipe_tx4_elec_idle                                  ( pipe_tx4_elec_idle      ),
    .pipe_tx4_powerdown                                  ( pipe_tx4_powerdown      ),
    .pipe_tx4_eqcontrol                                  ( pipe_tx4_eqcontrol      ),
    .pipe_tx4_eqpreset                                   ( pipe_tx4_eqpreset       ),
    .pipe_tx4_eqdeemph                                   ( pipe_tx4_eqdeemph       ),
    .pipe_tx4_eqdone                                     ( pipe_tx4_eqdone         ),
    .pipe_tx4_eqcoeff                                    ( pipe_tx4_eqcoeff        ),
    .pipe_rx4_eqcontrol                                  ( pipe_rx4_eqcontrol      ),
    .pipe_rx4_eqpreset                                   ( pipe_rx4_eqpreset       ),
    .pipe_rx4_eq_lffs                                    ( pipe_rx4_eq_lffs        ),
    .pipe_rx4_eq_txpreset                                ( pipe_rx4_eq_txpreset    ),
    .pipe_rx4_eq_new_txcoeff                             ( pipe_rx4_eq_new_txcoeff ),
    .pipe_rx4_eq_lffs_sel                                ( pipe_rx4_eq_lffs_sel    ),
    .pipe_rx4_eq_adapt_done                              ( pipe_rx4_eq_adapt_done  ),
    .pipe_rx4_eqdone                                     ( pipe_rx4_eqdone         ),

    // Pipe Per-Lane Signals - Lane 5
    .pipe_rx5_char_is_k                                  ( pipe_rx5_char_is_k      ),
    .pipe_rx5_data                                       ( pipe_rx5_data           ),
    .pipe_rx5_valid                                      ( pipe_rx5_valid          ),
    .pipe_rx5_chanisaligned                              ( ),
    .pipe_rx5_status                                     ( pipe_rx5_status         ),
    .pipe_rx5_phy_status                                 ( pipe_rx5_phy_status     ),
    .pipe_rx5_elec_idle                                  ( pipe_rx5_elec_idle      ),
    .pipe_rx5_polarity                                   ( pipe_rx5_polarity       ),
    .pipe_tx5_compliance                                 ( pipe_tx5_compliance     ),
    .pipe_tx5_char_is_k                                  ( pipe_tx5_char_is_k      ),
    .pipe_tx5_data                                       ( pipe_tx5_data           ),
    .pipe_tx5_elec_idle                                  ( pipe_tx5_elec_idle      ),
    .pipe_tx5_powerdown                                  ( pipe_tx5_powerdown      ),
    .pipe_tx5_eqcontrol                                  ( pipe_tx5_eqcontrol      ),
    .pipe_tx5_eqpreset                                   ( pipe_tx5_eqpreset       ),
    .pipe_tx5_eqdeemph                                   ( pipe_tx5_eqdeemph       ),
    .pipe_tx5_eqdone                                     ( pipe_tx5_eqdone         ),
    .pipe_tx5_eqcoeff                                    ( pipe_tx5_eqcoeff        ),
    .pipe_rx5_eqcontrol                                  ( pipe_rx5_eqcontrol      ),
    .pipe_rx5_eqpreset                                   ( pipe_rx5_eqpreset       ),
    .pipe_rx5_eq_lffs                                    ( pipe_rx5_eq_lffs        ),
    .pipe_rx5_eq_txpreset                                ( pipe_rx5_eq_txpreset    ),
    .pipe_rx5_eq_new_txcoeff                             ( pipe_rx5_eq_new_txcoeff ),
    .pipe_rx5_eq_lffs_sel                                ( pipe_rx5_eq_lffs_sel    ),
    .pipe_rx5_eq_adapt_done                              ( pipe_rx5_eq_adapt_done  ),
    .pipe_rx5_eqdone                                     ( pipe_rx5_eqdone         ),

    // Pipe Per-Lane Signals - Lane 6
    .pipe_rx6_char_is_k                                  ( pipe_rx6_char_is_k      ),
    .pipe_rx6_data                                       ( pipe_rx6_data           ),
    .pipe_rx6_valid                                      ( pipe_rx6_valid          ),
    .pipe_rx6_chanisaligned                              ( ),
    .pipe_rx6_status                                     ( pipe_rx6_status         ),
    .pipe_rx6_phy_status                                 ( pipe_rx6_phy_status     ),
    .pipe_rx6_elec_idle                                  ( pipe_rx6_elec_idle      ),
    .pipe_rx6_polarity                                   ( pipe_rx6_polarity       ),
    .pipe_tx6_compliance                                 ( pipe_tx6_compliance     ),
    .pipe_tx6_char_is_k                                  ( pipe_tx6_char_is_k      ),
    .pipe_tx6_data                                       ( pipe_tx6_data           ),
    .pipe_tx6_elec_idle                                  ( pipe_tx6_elec_idle      ),
    .pipe_tx6_powerdown                                  ( pipe_tx6_powerdown      ),
    .pipe_tx6_eqcontrol                                  ( pipe_tx6_eqcontrol      ),
    .pipe_tx6_eqpreset                                   ( pipe_tx6_eqpreset       ),
    .pipe_tx6_eqdeemph                                   ( pipe_tx6_eqdeemph       ),
    .pipe_tx6_eqdone                                     ( pipe_tx6_eqdone         ),
    .pipe_tx6_eqcoeff                                    ( pipe_tx6_eqcoeff        ),
    .pipe_rx6_eqcontrol                                  ( pipe_rx6_eqcontrol      ),
    .pipe_rx6_eqpreset                                   ( pipe_rx6_eqpreset       ),
    .pipe_rx6_eq_lffs                                    ( pipe_rx6_eq_lffs        ),
    .pipe_rx6_eq_txpreset                                ( pipe_rx6_eq_txpreset    ),
    .pipe_rx6_eq_new_txcoeff                             ( pipe_rx6_eq_new_txcoeff ),
    .pipe_rx6_eq_lffs_sel                                ( pipe_rx6_eq_lffs_sel    ),
    .pipe_rx6_eq_adapt_done                              ( pipe_rx6_eq_adapt_done  ),
    .pipe_rx6_eqdone                                     ( pipe_rx6_eqdone         ),

    // Pipe Per-Lane Signals - Lane 7
    .pipe_rx7_char_is_k                                  ( pipe_rx7_char_is_k      ),
    .pipe_rx7_data                                       ( pipe_rx7_data           ),
    .pipe_rx7_valid                                      ( pipe_rx7_valid          ),
    .pipe_rx7_chanisaligned                              ( ),
    .pipe_rx7_status                                     ( pipe_rx7_status         ),
    .pipe_rx7_phy_status                                 ( pipe_rx7_phy_status     ),
    .pipe_rx7_elec_idle                                  ( pipe_rx7_elec_idle      ),
    .pipe_rx7_polarity                                   ( pipe_rx7_polarity       ),
    .pipe_tx7_compliance                                 ( pipe_tx7_compliance     ),
    .pipe_tx7_char_is_k                                  ( pipe_tx7_char_is_k      ),
    .pipe_tx7_data                                       ( pipe_tx7_data           ),
    .pipe_tx7_elec_idle                                  ( pipe_tx7_elec_idle      ),
    .pipe_tx7_powerdown                                  ( pipe_tx7_powerdown      ),
    .pipe_tx7_eqcontrol                                  ( pipe_tx7_eqcontrol      ),
    .pipe_tx7_eqpreset                                   ( pipe_tx7_eqpreset       ),
    .pipe_tx7_eqdeemph                                   ( pipe_tx7_eqdeemph       ),
    .pipe_tx7_eqdone                                     ( pipe_tx7_eqdone         ),
    .pipe_tx7_eqcoeff                                    ( pipe_tx7_eqcoeff        ),
    .pipe_rx7_eqcontrol                                  ( pipe_rx7_eqcontrol      ),
    .pipe_rx7_eqpreset                                   ( pipe_rx7_eqpreset       ),
    .pipe_rx7_eq_lffs                                    ( pipe_rx7_eq_lffs        ),
    .pipe_rx7_eq_txpreset                                ( pipe_rx7_eq_txpreset    ),
    .pipe_rx7_eq_new_txcoeff                             ( pipe_rx7_eq_new_txcoeff ),
    .pipe_rx7_eq_lffs_sel                                ( pipe_rx7_eq_lffs_sel    ),
    .pipe_rx7_eq_adapt_done                              ( pipe_rx7_eq_adapt_done  ),
    .pipe_rx7_eqdone                                     ( pipe_rx7_eqdone         ),

     // Manual PCIe Equalization Control
    .pipe_rxeq_user_en                                    ( pipe_rxeq_user_en[PL_LINK_CAP_MAX_LINK_WIDTH-1:0]          ),
    .pipe_rxeq_user_txcoeff                               ( pipe_rxeq_user_txcoeff[18*PL_LINK_CAP_MAX_LINK_WIDTH-1:0]  ),
    .pipe_rxeq_user_mode                                  ( {PL_LINK_CAP_MAX_LINK_WIDTH{1'b0}}                         ),

    .drp_rdy                                              ( drp_rdy_wire ),
    .drp_do                                               ( drp_do_wire ),
    .drp_clk                                              ( dt_654524_drp_clk ),
    .drp_en                                               ( dt_654524_drp_en ),
    .drp_we                                               ( dt_654524_drp_we ),
    .drp_addr                                             ( dt_654524_drp_addr ),
    .drp_di                                               ( dt_654524_drp_di ),

    // PCI Express signals
    .pci_exp_txn                                         ( pci_exp_txn ),
    .pci_exp_txp                                         ( pci_exp_txp ),
    .pci_exp_rxn                                         ( pci_exp_rxn ),
    .pci_exp_rxp                                         ( pci_exp_rxp ),

    //---------- PIPE Clock & Reset Ports ------------------
    .pipe_clk                                           ( sys_clk ),
    .sys_rst_n                                          ( sys_rst_n ),
    .rec_clk                                            ( rec_clk ),
    .pipe_pclk                                          ( pipe_clk ),
    .core_clk                                           ( core_clk ),
    .user_clk                                           ( user_clk ),
    .phy_rdy                                            ( phy_rdy ),
    .mmcm_lock                                          ( mmcm_lock ),
    .pipe_mmcm_rst_n                                    ( pipe_mmcm_rst_n),

    // ---------- Shared Logic Internal------------------
    .INT_PCLK_OUT_SLAVE                                ( int_pclk_out_slave ),
    .INT_RXUSRCLK_OUT                                  ( int_pipe_rxusrclk_out ),
    .INT_RXOUTCLK_OUT                                  ( int_rxoutclk_out ),
    .INT_DCLK_OUT                                      ( int_dclk_out ),
    .INT_USERCLK1_OUT                                  ( int_userclk1_out ),
    .INT_USERCLK2_OUT                                  ( int_userclk2_out),
    .INT_OOBCLK_OUT                                    ( int_oobclk_out),
    .INT_QPLLLOCK_OUT                                  ( int_qplllock_out ),
    .INT_QPLLOUTCLK_OUT                                ( int_qplloutclk_out ),
    .INT_QPLLOUTREFCLK_OUT                             ( int_qplloutrefclk_out ),
    .INT_PCLK_SEL_SLAVE                                ( int_pclk_sel_slave ),

    // ---------- Shared Logic External------------------

    //External GT COMMON Ports

    .qpll_drp_crscode                                     ( qpll_drp_crscode ),
    .qpll_drp_fsm                                         ( qpll_drp_fsm ),
    .qpll_drp_done                                        ( qpll_drp_done ),
    .qpll_drp_reset                                       ( qpll_drp_reset ),
    .qpll_qplllock                                        ( qpll_qplllock ),
    .qpll_qplloutclk                                      ( qpll_qplloutclk ),
    .qpll_qplloutrefclk                                   ( qpll_qplloutrefclk ),
    .qpll_qplld                                           ( qpll_qplld ),
    .qpll_qpllreset                                       ( qpll_qpllreset ),
    .qpll_drp_clk                                         ( qpll_drp_clk ),
    .qpll_drp_rst_n                                       ( qpll_drp_rst_n ),
    .qpll_drp_ovrd                                        ( qpll_drp_ovrd ),
    .qpll_drp_gen3                                        ( qpll_drp_gen3),
    .qpll_drp_start                                       ( qpll_drp_start ),

    //External Clock Ports 
    .PIPE_PCLK_IN                                       ( pipe_pclk_in ),
    .PIPE_RXUSRCLK_IN                                   ( pipe_rxusrclk_in ),
    .PIPE_RXOUTCLK_IN                                   ( pipe_rxoutclk_in ),
    .PIPE_DCLK_IN                                       ( pipe_dclk_in ),
    .PIPE_USERCLK1_IN                                   ( pipe_userclk1_in ),
    .PIPE_USERCLK2_IN                                   ( pipe_userclk2_in ),
    .PIPE_OOBCLK_IN                                     ( pipe_oobclk_in ),
    .PIPE_MMCM_LOCK_IN                                  ( PIPE_MMCM_LOCK_IN_wire ),
    .PIPE_TXOUTCLK_OUT                                  ( pipe_txoutclk_out ),
    .PIPE_RXOUTCLK_OUT                                  ( pipe_rxoutclk_out ),
    .PIPE_PCLK_SEL_OUT                                  ( pipe_pclk_sel_out ),
    .PIPE_GEN3_OUT                                      ( PIPE_GEN3_OUT_wire ),

    //--------------------------------------------------------------------------
    //  GT Debug Ports
    //--------------------------------------------------------------------------
    .ext_ch_gt_drpclk                                     (ext_ch_gt_drpclk),
    .ext_ch_gt_drpaddr                                    (ext_ch_gt_drpaddr),
    .ext_ch_gt_drpen                                      (ext_ch_gt_drpen),
    .ext_ch_gt_drpdi                                      (ext_ch_gt_drpdi),
    .ext_ch_gt_drpwe                                      (ext_ch_gt_drpwe),
    .ext_ch_gt_drpdo                                      (ext_ch_gt_drpdo),
    .ext_ch_gt_drprdy                                     (ext_ch_gt_drprdy),

    //---------- PRBS/Loopback Ports -----------------------
    .PIPE_TXPRBSSEL                                      ( pipe_txprbssel ),
    .PIPE_RXPRBSSEL                                      ( pipe_rxprbssel ),
    .PIPE_TXPRBSFORCEERR                                 ( pipe_txprbsforceerr ),
    .PIPE_RXPRBSCNTRESET                                 ( pipe_rxprbscntreset ),
    .PIPE_LOOPBACK                                       ( pipe_loopback),

    .PIPE_RXPRBSERR                                      ( pipe_rxprbserr),
    .PIPE_TXINHIBIT                                      ( pipe_txinhibit),
    .PIPE_PCSRSVDIN                                      ( {PL_LINK_CAP_MAX_LINK_WIDTH{16'b0}} ),

 //---------- Transceiver Debug FSM Ports ---------------------------------
    .PIPE_RST_FSM             (pipe_rst_fsm),
    .PIPE_QRST_FSM            (pipe_qrst_fsm),
    .PIPE_RATE_FSM            (pipe_rate_fsm ),
    .PIPE_SYNC_FSM_TX         (pipe_sync_fsm_tx ),
    .PIPE_SYNC_FSM_RX         (pipe_sync_fsm_rx ),
    .PIPE_DRP_FSM             (pipe_drp_fsm ),

    .PIPE_RST_IDLE            (pipe_rst_idle ),
    .PIPE_QRST_IDLE           (pipe_qrst_idle ),
    .PIPE_RATE_IDLE           (pipe_rate_idle ),
    .PIPE_EYESCANDATAERROR    ( pipe_eyescandataerror ),
    .PIPE_RXSTATUS            ( pipe_rxstatus ),
    .PIPE_DMONITOROUT         ( pipe_dmonitorout ),

    .PIPE_CPLL_LOCK           ( pipe_cpll_lock ),
    .PIPE_QPLL_LOCK           ( pipe_qpll_lock ),
    .PIPE_RXPMARESETDONE      ( pipe_rxpmaresetdone ),       
    .PIPE_RXBUFSTATUS         ( pipe_rxbufstatus ),         
    .PIPE_TXPHALIGNDONE       ( pipe_txphaligndone ),       
    .PIPE_TXPHINITDONE        ( pipe_txphinitdone ),        
    .PIPE_TXDLYSRESETDONE     ( pipe_txdlysresetdone ),    
    .PIPE_RXPHALIGNDONE       ( pipe_rxphaligndone ),      
    .PIPE_RXDLYSRESETDONE     ( pipe_rxdlysresetdone ),     
    .PIPE_RXSYNCDONE          ( pipe_rxsyncdone ),       
    .PIPE_RXDISPERR           ( pipe_rxdisperr ),       
    .PIPE_RXNOTINTABLE        ( pipe_rxnotintable ),      
    .PIPE_RXCOMMADET          ( pipe_rxcommadet ),        
    //---------- JTAG Ports --------------------------------
    .PIPE_JTAG_RDY             (gt_ch_drp_rdy),

    //---------- Debug Ports -------------------------------
    .PIPE_DEBUG_0             (pipe_debug_0 ),
    .PIPE_DEBUG_1             (pipe_debug_1 ),
    .PIPE_DEBUG_2             (pipe_debug_2  ),
    .PIPE_DEBUG_3             (pipe_debug_3 ),
    .PIPE_DEBUG_4             (pipe_debug_4  ),
    .PIPE_DEBUG_5             (pipe_debug_5  ),
    .PIPE_DEBUG_6             (pipe_debug_6  ),
    .PIPE_DEBUG_7             (pipe_debug_7  ),
    .PIPE_DEBUG_8             (pipe_debug_8 ),
    .PIPE_DEBUG_9             (pipe_debug_9  ),
    .PIPE_DEBUG               (pipe_debug),

    .CPLLPD                   (cpllpd),
    .TXPD                     (txpd),
    .RXPD                     (rxpd),
    .TXPDELECIDLEMODE         (txpdelecidlemode),
    .TXDETECTRX               (txdetectrx),
    .TXELECIDLE               (txelecidle),
    .QPLLPD                   (qpllpd),
    .POWERDOWN                (powerdown)
);
     assign pipe_gen3_out = 1'b0;
    assign common_commands_out = 26'b0;
    assign pipe_tx_0_sigs      = 84'b0;
    assign pipe_tx_1_sigs      = 84'b0;
    assign pipe_tx_2_sigs      = 84'b0;
    assign pipe_tx_3_sigs      = 84'b0;
    assign pipe_tx_4_sigs      = 84'b0;
    assign pipe_tx_5_sigs      = 84'b0;
    assign pipe_tx_6_sigs      = 84'b0;
    assign pipe_tx_7_sigs      = 84'b0;


    // Assign as passthrough if not tandem configuration
    // Input assigned passthroughs
    assign icap_o = 32'h0000_0000;
    assign cfg_mgmt_write_wire = cfg_mgmt_write;
    assign cfg_mgmt_read_wire = cfg_mgmt_read;

    assign cfg_per_func_status_control_wire = cfg_per_func_status_control;
    assign cfg_per_function_output_request_wire = cfg_per_function_output_request;
    assign cfg_dsn_wire = cfg_dsn;
    assign cfg_power_state_change_ack_wire = cfg_power_state_change_ack;
    assign cfg_err_cor_in_wire = cfg_err_cor_in;
    assign cfg_err_uncor_in_wire = cfg_err_uncor_in;
    assign cfg_flr_done_wire = cfg_flr_done;
    assign cfg_vf_flr_done_wire = cfg_vf_flr_done;
    assign cfg_link_training_enable_wire = cfg_link_training_enable;
    assign cfg_ext_read_data_valid_wire = cfg_ext_read_data_valid;
    assign cfg_interrupt_pending_wire = cfg_interrupt_pending;
    assign cfg_interrupt_msi_select_wire = cfg_interrupt_msi_select;
    assign cfg_interrupt_msi_pending_status_wire = cfg_interrupt_msi_pending_status;
    assign cfg_config_space_enable_wire = cfg_config_space_enable;
    assign cfg_req_pm_transition_l23_ready_wire = cfg_req_pm_transition_l23_ready;
    assign cfg_hot_reset_in_wire = cfg_hot_reset_in;
    assign cfg_ds_port_number_wire = cfg_ds_port_number;
    assign cfg_ds_bus_number_wire = cfg_ds_bus_number;
    assign cfg_ds_device_number_wire = cfg_ds_device_number;
    assign cfg_ds_function_number_wire = cfg_ds_function_number;
    assign user_tph_stt_address_wire = user_tph_stt_address;
    assign user_tph_function_num_wire = user_tph_function_num;
    assign user_tph_stt_read_enable_wire = user_tph_stt_read_enable;
    // Output assigned passthroughs
    assign cfg_phy_link_down = cfg_phy_link_down_wire;
    assign cfg_phy_link_status = cfg_phy_link_status_wire;
    assign cfg_ltssm_state = cfg_ltssm_state_wire;
    assign cfg_hot_reset_out = cfg_hot_reset_out_wire;

    assign pcie_drp_rdy = drp_rdy_wire;
    assign pcie_drp_do = drp_do_wire;
    
    // Input assigned passthroughs
    assign drp_clk_wire   = pcie_drp_clk;
    assign drp_en_wire    = pcie_drp_en;
    assign drp_we_wire    = pcie_drp_we;
    assign drp_addr_wire  = pcie_drp_addr;
    assign drp_di_wire    = pcie_drp_di;

    // Passthrough for tandem_cplr outputs
    assign s_axis_cc_tdata_wire = s_axis_cc_tdata;
    assign s_axis_cc_tkeep_wire = s_axis_cc_tkeep;
    assign s_axis_cc_tlast_wire = s_axis_cc_tlast;
    assign s_axis_cc_tvalid_wire = s_axis_cc_tvalid;
    assign s_axis_cc_tuser_wire = s_axis_cc_tuser;
    assign s_axis_cc_tready = s_axis_cc_tready_wire;

    assign m_axis_cq_tdata = m_axis_cq_tdata_wire;
    assign m_axis_cq_tlast = m_axis_cq_tlast_wire;
    assign m_axis_cq_tvalid = m_axis_cq_tvalid_wire;
    assign m_axis_cq_tuser = m_axis_cq_tuser_wire;
    assign m_axis_cq_tkeep = m_axis_cq_tkeep_wire;
    assign m_axis_cq_tready_wire = {22{m_axis_cq_tready}};

    assign s_axis_rq_tdata_wire = s_axis_rq_tdata;
    assign s_axis_rq_tkeep_wire = s_axis_rq_tkeep;
    assign s_axis_rq_tlast_wire = s_axis_rq_tlast;
    assign s_axis_rq_tvalid_wire = s_axis_rq_tvalid;
    assign s_axis_rq_tuser_wire = s_axis_rq_tuser;
    assign s_axis_rq_tready = s_axis_rq_tready_wire;

    assign m_axis_rc_tdata = m_axis_rc_tdata_wire;
    assign m_axis_rc_tlast = m_axis_rc_tlast_wire;
    assign m_axis_rc_tvalid = m_axis_rc_tvalid_wire;
    assign m_axis_rc_tuser = m_axis_rc_tuser_wire;
    assign m_axis_rc_tkeep = m_axis_rc_tkeep_wire;
    assign m_axis_rc_tready_wire = {22{m_axis_rc_tready}};

    assign cfg_msg_transmit_done = cfg_msg_transmit_done_wire;
    assign cfg_msg_transmit_wire = cfg_msg_transmit;
    assign cfg_msg_transmit_type_wire = cfg_msg_transmit_type;
    assign cfg_msg_transmit_data_wire = cfg_msg_transmit_data;
    assign pcie_rq_tag = pcie_rq_tag_wire;
    assign pcie_rq_tag_vld = pcie_rq_tag_vld_wire;
    assign pcie_tfc_nph_av = pcie_tfc_nph_av_wire;
    assign pcie_tfc_npd_av = pcie_tfc_npd_av_wire;
    assign pcie_rq_seq_num = pcie_rq_seq_num_wire;
    assign pcie_rq_seq_num_vld = pcie_rq_seq_num_vld_wire;
    assign cfg_fc_ph = cfg_fc_ph_wire;
    assign cfg_fc_nph = cfg_fc_nph_wire;
    assign cfg_fc_cplh = cfg_fc_cplh_wire;
    assign cfg_fc_pd = cfg_fc_pd_wire;
    assign cfg_fc_npd = cfg_fc_npd_wire;
    assign cfg_fc_cpld = cfg_fc_cpld_wire;
    assign cfg_fc_sel_wire = cfg_fc_sel;
    assign pcie_cq_np_req_count = pcie_cq_np_req_count_wire;
    assign pcie_cq_np_req_wire = pcie_cq_np_req;
    assign cfg_msg_received = cfg_msg_received_wire;
    assign cfg_msg_received_type = cfg_msg_received_type_wire;
    assign cfg_msg_received_data = cfg_msg_received_data_wire;
    assign cfg_interrupt_int_wire = cfg_interrupt_int;
    assign cfg_interrupt_msi_int_wire = cfg_interrupt_msi_int;
    assign cfg_interrupt_msix_int_wire = cfg_interrupt_msix_int;
    assign user_app_rdy = 1'b1;
    assign startup_cfgclk = 1'b0;
    assign startup_cfgmclk = 1'b0;
    assign startup_eos = 1'b0;
    assign startup_preq = 1'b0;
    // Generate user_lnk_up
    assign user_lnk_up = user_lnk_up_int;
  //----------------------------------------------------------------------------------------------------------------//

//////////////////////////////////////////////////STORE_LTSSM/////////////////////////////////////////////////////////
  (* mark_debug *) wire store_ltssm;
  reg   [5:0] ltssm_reg0 = 6'b0;
  reg   [5:0] ltssm_reg1 = 6'b0;
  reg   [5:0] ltssm_reg2 = 6'b0; 

  always@ (posedge user_clk)
  begin
    ltssm_reg0          <= cfg_ltssm_state;
    ltssm_reg1          <= ltssm_reg0;
    ltssm_reg2          <= ltssm_reg1;
  end

  assign store_ltssm     = (ltssm_reg2 != cfg_ltssm_state) ? 1'b1 : 1'b0; 




///////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule

