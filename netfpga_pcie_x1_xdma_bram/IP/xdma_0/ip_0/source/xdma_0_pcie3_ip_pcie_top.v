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
// File       : xdma_0_pcie3_ip_pcie_top.v
// Version    : 4.2
//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : xdma_0_pcie3_ip_pcie_top.v                                                  //
// Description  : Instantiates GEN3 PCIe Integrated Block Wrapper and         //
//                connects the IP to the PIPE Interface Pipeline module, the  //
//                PCIe Initialization Controller, and the TPH Table           //
//                implemented in a RAMB36                                     //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
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
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module xdma_0_pcie3_ip_pcie_top #(
  parameter         TCQ = 100,
  parameter         PIPE_SIM_MODE = "FALSE",
  parameter         PIPE_PIPELINE_STAGES = 0,
  parameter         ARI_CAP_ENABLE = "FALSE",
  parameter         AXISTEN_IF_CC_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_CC_PARITY_CHK = "TRUE",
  parameter         AXISTEN_IF_CQ_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_ENABLE_CLIENT_TAG = "FALSE",
  parameter [17:0]  AXISTEN_IF_ENABLE_MSG_ROUTE = 18'h00000,
  parameter         AXISTEN_IF_ENABLE_RX_MSG_INTFC = "FALSE",
  parameter         AXISTEN_IF_RC_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_RC_STRADDLE = "FALSE",
  parameter         AXISTEN_IF_RQ_ALIGNMENT_MODE = "FALSE",
  parameter         AXISTEN_IF_RQ_PARITY_CHK = "TRUE",
  parameter  [1:0]  AXISTEN_IF_WIDTH = 2'h2,
  parameter         C_DATA_WIDTH       = 256,
  parameter         CRM_CORE_CLK_FREQ_500 = "TRUE",
  parameter  [1:0]  CRM_USER_CLK_FREQ = 2'h2,
  parameter  [7:0]  DNSTREAM_LINK_NUM = 8'h00,
  parameter  [1:0]  GEN3_PCS_AUTO_REALIGN = 2'h1,
  parameter         GEN3_PCS_RX_ELECIDLE_INTERNAL = "TRUE",
  parameter         KEEP_WIDTH = C_DATA_WIDTH / 32,
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
  parameter [15:0]  PF0_DEVICE_ID = 16'h0000,
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
  parameter VF0_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter VF0_TPHR_CAP_ENABLE = "FALSE",
  parameter VF0_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0] VF0_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0] VF0_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter [1:0] VF0_TPHR_CAP_ST_TABLE_LOC = 2'h0,
  parameter [10:0] VF0_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0] VF0_TPHR_CAP_VER = 4'h1,
  parameter VF1_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter VF1_TPHR_CAP_ENABLE = "FALSE",
  parameter VF1_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0] VF1_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0] VF1_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter [1:0] VF1_TPHR_CAP_ST_TABLE_LOC = 2'h0,
  parameter [10:0] VF1_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0] VF1_TPHR_CAP_VER = 4'h1,
  parameter VF2_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter VF2_TPHR_CAP_ENABLE = "FALSE",
  parameter VF2_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0] VF2_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0] VF2_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter [1:0] VF2_TPHR_CAP_ST_TABLE_LOC = 2'h0,
  parameter [10:0] VF2_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0] VF2_TPHR_CAP_VER = 4'h1,
  parameter VF3_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter VF3_TPHR_CAP_ENABLE = "FALSE",
  parameter VF3_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0] VF3_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0] VF3_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter [1:0] VF3_TPHR_CAP_ST_TABLE_LOC = 2'h0,
  parameter [10:0] VF3_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0] VF3_TPHR_CAP_VER = 4'h1,
  parameter VF4_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter VF4_TPHR_CAP_ENABLE = "FALSE",
  parameter VF4_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0] VF4_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0] VF4_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter [1:0] VF4_TPHR_CAP_ST_TABLE_LOC = 2'h0,
  parameter [10:0] VF4_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0] VF4_TPHR_CAP_VER = 4'h1,
  parameter VF5_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter VF5_TPHR_CAP_ENABLE = "FALSE",
  parameter VF5_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0] VF5_TPHR_CAP_NEXTPTR = 12'h000,
  parameter [2:0] VF5_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter [1:0] VF5_TPHR_CAP_ST_TABLE_LOC = 2'h0,
  parameter [10:0] VF5_TPHR_CAP_ST_TABLE_SIZE = 11'h000,
  parameter [3:0] VF5_TPHR_CAP_VER = 4'h1,
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
  parameter [28:0]  PF0_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer PF0_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  PF0_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
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
  parameter [15:0]  PF0_SUBSYSTEM_ID = 16'h0000,
  parameter         PF0_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter         PF0_TPHR_CAP_ENABLE = "FALSE",
  parameter         PF0_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  PF0_TPHR_CAP_NEXTPTR = 12'h000,
  parameter  [2:0]  PF0_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter  [1:0]  PF0_TPHR_CAP_ST_TABLE_LOC = 2'h0,
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
  parameter [28:0]  PF1_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer PF1_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  PF1_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
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
  parameter         PF1_TPHR_CAP_DEV_SPECIFIC_MODE = "TRUE",
  parameter         PF1_TPHR_CAP_ENABLE = "FALSE",
  parameter         PF1_TPHR_CAP_INT_VEC_MODE = "TRUE",
  parameter [11:0]  PF1_TPHR_CAP_NEXTPTR = 12'h000,
  parameter  [2:0]  PF1_TPHR_CAP_ST_MODE_SEL = 3'h0,
  parameter  [1:0]  PF1_TPHR_CAP_ST_TABLE_LOC = 2'h0,
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
  parameter [15:0]  PL_LANE0_EQ_CONTROL = 16'h3F00,
  parameter [15:0]  PL_LANE1_EQ_CONTROL = 16'h3F00,
  parameter [15:0]  PL_LANE2_EQ_CONTROL = 16'h3F00,
  parameter [15:0]  PL_LANE3_EQ_CONTROL = 16'h3F00,
  parameter [15:0]  PL_LANE4_EQ_CONTROL = 16'h3F00,
  parameter [15:0]  PL_LANE5_EQ_CONTROL = 16'h3F00,
  parameter [15:0]  PL_LANE6_EQ_CONTROL = 16'h3F00,
  parameter [15:0]  PL_LANE7_EQ_CONTROL = 16'h3F00,
  parameter  [2:0]  PL_LINK_CAP_MAX_LINK_SPEED = 3'h4,
  parameter  [3:0]  PL_LINK_CAP_MAX_LINK_WIDTH = 4'h8,
  parameter integer PL_N_FTS_COMCLK_GEN1 = 255,
  parameter integer PL_N_FTS_COMCLK_GEN2 = 255,
  parameter integer PL_N_FTS_COMCLK_GEN3 = 255,
  parameter integer PL_N_FTS_GEN1 = 255,
  parameter integer PL_N_FTS_GEN2 = 255,
  parameter integer PL_N_FTS_GEN3 = 255,
  parameter         PL_SIM_FAST_LINK_TRAINING = "FALSE",
  parameter         PL_UPSTREAM_FACING = "TRUE",
  parameter [15:0]  PM_ASPML0S_TIMEOUT = 16'h05DC,
  parameter [19:0]  PM_ASPML1_ENTRY_DELAY = 20'h00000,
  parameter         PM_ENABLE_SLOT_POWER_CAPTURE = "TRUE",
  parameter [31:0]  PM_L1_REENTRY_DELAY = 32'h00000000,
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
  parameter [27:0]  TL_COMPL_TIMEOUT_REG1 = 28'h0000000,
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
  parameter [28:0]  VF0_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF0_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  VF0_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF0_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF0_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF0_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF0_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF0_PM_CAP_VER_ID = 3'h3,
  parameter integer VF1_MSIX_CAP_PBA_BIR = 0,
  parameter [28:0]  VF1_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF1_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  VF1_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF1_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF1_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF1_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF1_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF1_PM_CAP_VER_ID = 3'h3,
  parameter integer VF2_MSIX_CAP_PBA_BIR = 0,
  parameter [28:0]  VF2_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF2_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  VF2_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF2_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF2_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF2_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF2_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF2_PM_CAP_VER_ID = 3'h3,
  parameter integer VF3_MSIX_CAP_PBA_BIR = 0,
  parameter [28:0]  VF3_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF3_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  VF3_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF3_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF3_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF3_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF3_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF3_PM_CAP_VER_ID = 3'h3,
  parameter integer VF4_MSIX_CAP_PBA_BIR = 0,
  parameter [28:0]  VF4_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF4_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  VF4_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF4_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF4_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF4_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF4_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF4_PM_CAP_VER_ID = 3'h3,
  parameter integer VF5_MSIX_CAP_PBA_BIR = 0,
  parameter [28:0]  VF5_MSIX_CAP_PBA_OFFSET = 29'h00000050,
  parameter integer VF5_MSIX_CAP_TABLE_BIR = 0,
  parameter [28:0]  VF5_MSIX_CAP_TABLE_OFFSET = 29'h00000040,
  parameter [10:0]  VF5_MSIX_CAP_TABLE_SIZE = 11'h000,
  parameter integer VF5_MSI_CAP_MULTIMSGCAP = 0,
  parameter  [7:0]  VF5_PM_CAP_ID = 8'h01,
  parameter  [7:0]  VF5_PM_CAP_NEXTPTR = 8'h00,
  parameter  [2:0]  VF5_PM_CAP_VER_ID = 3'h3,
  parameter         IMPL_TARGET = "HARD",
  parameter         NO_DECODE_LOGIC = "TRUE",
  parameter         INTERFACE_SPEED = "500 MHZ",
  parameter         COMPLETION_SPACE = "16KB"
) (

  input                            core_clk,
  input                            rec_clk,
  input                            user_clk,
  input                            pipe_clk,

  input                            phy_rdy,               // GT is ready : 1b = GT Ready
  input                            mmcm_lock,             // MMCM Locked : 1b = MMCM Locked

  input                            s_axis_rq_tlast,
  input  [C_DATA_WIDTH-1:0]        s_axis_rq_tdata,
  input              [59:0]        s_axis_rq_tuser,
  input    [KEEP_WIDTH-1:0]        s_axis_rq_tkeep,
  output              [3:0]        s_axis_rq_tready,
  input                            s_axis_rq_tvalid,

  output [C_DATA_WIDTH-1:0]        m_axis_rc_tdata,
  output             [74:0]        m_axis_rc_tuser,
  output                           m_axis_rc_tlast,
  output   [KEEP_WIDTH-1:0]        m_axis_rc_tkeep,
  output                           m_axis_rc_tvalid,
  input              [21:0]        m_axis_rc_tready,

  output [C_DATA_WIDTH-1:0]        m_axis_cq_tdata,
  output             [84:0]        m_axis_cq_tuser,
  output                           m_axis_cq_tlast,
  output   [KEEP_WIDTH-1:0]        m_axis_cq_tkeep,
  output                           m_axis_cq_tvalid,
  input              [21:0]        m_axis_cq_tready,

  input  [C_DATA_WIDTH-1:0]        s_axis_cc_tdata,
  input              [32:0]        s_axis_cc_tuser,
  input                            s_axis_cc_tlast,
  input    [KEEP_WIDTH-1:0]        s_axis_cc_tkeep,
  input                            s_axis_cc_tvalid,
  output              [3:0]        s_axis_cc_tready,

  output              [3:0]        pcie_rq_seq_num,
  output                           pcie_rq_seq_num_vld,
  output              [5:0]        pcie_rq_tag,
  output                           pcie_rq_tag_vld,

  output              [1:0]        pcie_tfc_nph_av,
  output              [1:0]        pcie_tfc_npd_av,
  input                            pcie_cq_np_req,
  output              [5:0]        pcie_cq_np_req_count,

  input              [18:0]        cfg_mgmt_addr,
  input                            cfg_mgmt_write,
  input              [31:0]        cfg_mgmt_write_data,
  input               [3:0]        cfg_mgmt_byte_enable,
  input                            cfg_mgmt_read,
  output             [31:0]        cfg_mgmt_read_data,
  output                           cfg_mgmt_read_write_done,
  input                            cfg_mgmt_type1_cfg_reg_access,

  output                           cfg_phy_link_down,
  output              [1:0]        cfg_phy_link_status,
  output              [3:0]        cfg_negotiated_width,
  output              [2:0]        cfg_current_speed,
  output              [2:0]        cfg_max_payload,
  output              [2:0]        cfg_max_read_req,
  output              [7:0]        cfg_function_status,
  output              [5:0]        cfg_function_power_state,
  output             [11:0]        cfg_vf_status,
  output             [17:0]        cfg_vf_power_state,
  output              [1:0]        cfg_link_power_state,

  output                           cfg_err_cor_out,
  output                           cfg_err_nonfatal_out,
  output                           cfg_err_fatal_out,
  output                           cfg_local_error,
  output                           cfg_ltr_enable,
  output              [5:0]        cfg_ltssm_state,
  output              [1:0]        cfg_rcb_status,
  output              [1:0]        cfg_dpa_substate_change,
  output              [1:0]        cfg_obff_enable,
  output                           cfg_pl_status_change,

  output              [1:0]        cfg_tph_requester_enable,
  output              [5:0]        cfg_tph_st_mode,
  output              [5:0]        cfg_vf_tph_requester_enable,
  output             [17:0]        cfg_vf_tph_st_mode,

  output                           cfg_msg_received,
  output              [7:0]        cfg_msg_received_data,
  output              [4:0]        cfg_msg_received_type,

  input                            cfg_msg_transmit,
  input               [2:0]        cfg_msg_transmit_type,
  input              [31:0]        cfg_msg_transmit_data,
  output                           cfg_msg_transmit_done,

  output              [7:0]        cfg_fc_ph,
  output             [11:0]        cfg_fc_pd,
  output              [7:0]        cfg_fc_nph,
  output             [11:0]        cfg_fc_npd,
  output              [7:0]        cfg_fc_cplh,
  output             [11:0]        cfg_fc_cpld,
  input               [2:0]        cfg_fc_sel,

  input               [2:0]        cfg_per_func_status_control,
  output             [15:0]        cfg_per_func_status_data,
  input               [2:0]        cfg_per_function_number,
  input                            cfg_per_function_output_request,
  output                           cfg_per_function_update_done,

  input              [63:0]        cfg_dsn,
  input                            cfg_power_state_change_ack,
  output                           cfg_power_state_change_interrupt,
  input                            cfg_err_cor_in,
  input                            cfg_err_uncor_in,

  output              [1:0]        cfg_flr_in_process,
  input               [1:0]        cfg_flr_done,
  output              [5:0]        cfg_vf_flr_in_process,
  input               [5:0]        cfg_vf_flr_done,

  input                            cfg_link_training_enable,

  input               [3:0]        cfg_interrupt_int,
  input               [1:0]        cfg_interrupt_pending,
  output                           cfg_interrupt_sent,

  output              [1:0]        cfg_interrupt_msi_enable,
  output              [5:0]        cfg_interrupt_msi_vf_enable,
  output              [5:0]        cfg_interrupt_msi_mmenable,
  output                           cfg_interrupt_msi_mask_update,
  output             [31:0]        cfg_interrupt_msi_data,
  input               [3:0]        cfg_interrupt_msi_select,
  input              [31:0]        cfg_interrupt_msi_int,
  input              [63:0]        cfg_interrupt_msi_pending_status,
  output                           cfg_interrupt_msi_sent,
  output                           cfg_interrupt_msi_fail,

  output              [1:0]        cfg_interrupt_msix_enable,
  output              [1:0]        cfg_interrupt_msix_mask,
  output              [5:0]        cfg_interrupt_msix_vf_enable,
  output              [5:0]        cfg_interrupt_msix_vf_mask,
  input              [31:0]        cfg_interrupt_msix_data,
  input              [63:0]        cfg_interrupt_msix_address,
  input                            cfg_interrupt_msix_int,
  output                           cfg_interrupt_msix_sent,
  output                           cfg_interrupt_msix_fail,

  input               [2:0]        cfg_interrupt_msi_attr,
  input                            cfg_interrupt_msi_tph_present,
  input               [1:0]        cfg_interrupt_msi_tph_type,
  input               [8:0]        cfg_interrupt_msi_tph_st_tag,
  input               [2:0]        cfg_interrupt_msi_function_number,

  output                           cfg_ext_read_received,
  output                           cfg_ext_write_received,
  output              [9:0]        cfg_ext_register_number,
  output              [7:0]        cfg_ext_function_number,
  output             [31:0]        cfg_ext_write_data,
  output              [3:0]        cfg_ext_write_byte_enable,
  input              [31:0]        cfg_ext_read_data,
  input                            cfg_ext_read_data_valid,

  input              [15:0]        cfg_dev_id,
  input              [15:0]        cfg_vend_id,
  input               [7:0]        cfg_rev_id,
  input              [15:0]        cfg_subsys_id,
  input              [15:0]        cfg_subsys_vend_id,

  input               [7:0]        cfg_ds_port_number,

// EP only
  output                           cfg_hot_reset_out,
  input                            cfg_config_space_enable,
  input                            cfg_req_pm_transition_l23_ready,

// RP only
  input                            cfg_hot_reset_in,

  input               [7:0]        cfg_ds_bus_number,
  input               [4:0]        cfg_ds_device_number,
  input               [2:0]        cfg_ds_function_number,

  output                           drp_rdy,
  output             [15:0]        drp_do,
  input                            drp_clk,
  input                            drp_en,
  input                            drp_we,
  input              [10:0]        drp_addr,
  input              [15:0]        drp_di,

  // TPH Interface
  input               [4:0]        user_tph_stt_address,
  input               [2:0]        user_tph_function_num,
  output             [31:0]        user_tph_stt_read_data,
  output                           user_tph_stt_read_data_valid,
  input                            user_tph_stt_read_enable,

  output wire                      pipe_rx0_polarity_gt,
  output wire                      pipe_rx1_polarity_gt,
  output wire                      pipe_rx2_polarity_gt,
  output wire                      pipe_rx3_polarity_gt,
  output wire                      pipe_rx4_polarity_gt,
  output wire                      pipe_rx5_polarity_gt,
  output wire                      pipe_rx6_polarity_gt,
  output wire                      pipe_rx7_polarity_gt,

  output wire                      pipe_tx0_compliance_gt,
  output wire                      pipe_tx1_compliance_gt,
  output wire                      pipe_tx2_compliance_gt,
  output wire                      pipe_tx3_compliance_gt,
  output wire                      pipe_tx4_compliance_gt,
  output wire                      pipe_tx5_compliance_gt,
  output wire                      pipe_tx6_compliance_gt,
  output wire                      pipe_tx7_compliance_gt,

  output wire                      pipe_tx0_data_valid_gt,
  output wire                      pipe_tx1_data_valid_gt,
  output wire                      pipe_tx2_data_valid_gt,
  output wire                      pipe_tx3_data_valid_gt,
  output wire                      pipe_tx4_data_valid_gt,
  output wire                      pipe_tx5_data_valid_gt,
  output wire                      pipe_tx6_data_valid_gt,
  output wire                      pipe_tx7_data_valid_gt,

  output wire                      pipe_tx0_elec_idle_gt,
  output wire                      pipe_tx1_elec_idle_gt,
  output wire                      pipe_tx2_elec_idle_gt,
  output wire                      pipe_tx3_elec_idle_gt,
  output wire                      pipe_tx4_elec_idle_gt,
  output wire                      pipe_tx5_elec_idle_gt,
  output wire                      pipe_tx6_elec_idle_gt,
  output wire                      pipe_tx7_elec_idle_gt,

  output wire                      pipe_tx0_start_block_gt,
  output wire                      pipe_tx1_start_block_gt,
  output wire                      pipe_tx2_start_block_gt,
  output wire                      pipe_tx3_start_block_gt,
  output wire                      pipe_tx4_start_block_gt,
  output wire                      pipe_tx5_start_block_gt,
  output wire                      pipe_tx6_start_block_gt,
  output wire                      pipe_tx7_start_block_gt,

  output                           pipe_tx_deemph_gt,
  output                           pipe_tx_rcvr_det_gt,
  output              [1:0]        pipe_tx_rate_gt,
  output              [2:0]        pipe_tx_margin_gt,
  output                           pipe_tx_swing_gt,
  input               [5:0]        pipe_tx_eqfs_gt,
  input               [5:0]        pipe_tx_eqlf_gt,

  output wire                      pipe_tx_reset_gt,

  output wire         [1:0]        pipe_rx0_eqcontrol_gt,
  output wire         [1:0]        pipe_rx1_eqcontrol_gt,
  output wire         [1:0]        pipe_rx2_eqcontrol_gt,
  output wire         [1:0]        pipe_rx3_eqcontrol_gt,
  output wire         [1:0]        pipe_rx4_eqcontrol_gt,
  output wire         [1:0]        pipe_rx5_eqcontrol_gt,
  output wire         [1:0]        pipe_rx6_eqcontrol_gt,
  output wire         [1:0]        pipe_rx7_eqcontrol_gt,

  output wire         [1:0]        pipe_tx0_char_is_k_gt,
  output wire         [1:0]        pipe_tx1_char_is_k_gt,
  output wire         [1:0]        pipe_tx2_char_is_k_gt,
  output wire         [1:0]        pipe_tx3_char_is_k_gt,
  output wire         [1:0]        pipe_tx4_char_is_k_gt,
  output wire         [1:0]        pipe_tx5_char_is_k_gt,
  output wire         [1:0]        pipe_tx6_char_is_k_gt,
  output wire         [1:0]        pipe_tx7_char_is_k_gt,

  output wire         [1:0]        pipe_tx0_eqcontrol_gt,
  output wire         [1:0]        pipe_tx1_eqcontrol_gt,
  output wire         [1:0]        pipe_tx2_eqcontrol_gt,
  output wire         [1:0]        pipe_tx3_eqcontrol_gt,
  output wire         [1:0]        pipe_tx4_eqcontrol_gt,
  output wire         [1:0]        pipe_tx5_eqcontrol_gt,
  output wire         [1:0]        pipe_tx6_eqcontrol_gt,
  output wire         [1:0]        pipe_tx7_eqcontrol_gt,

  output wire         [1:0]        pipe_tx0_powerdown_gt,
  output wire         [1:0]        pipe_tx1_powerdown_gt,
  output wire         [1:0]        pipe_tx2_powerdown_gt,
  output wire         [1:0]        pipe_tx3_powerdown_gt,
  output wire         [1:0]        pipe_tx4_powerdown_gt,
  output wire         [1:0]        pipe_tx5_powerdown_gt,
  output wire         [1:0]        pipe_tx6_powerdown_gt,
  output wire         [1:0]        pipe_tx7_powerdown_gt,

  output wire         [1:0]        pipe_tx0_syncheader_gt,
  output wire         [1:0]        pipe_tx1_syncheader_gt,
  output wire         [1:0]        pipe_tx2_syncheader_gt,
  output wire         [1:0]        pipe_tx3_syncheader_gt,
  output wire         [1:0]        pipe_tx4_syncheader_gt,
  output wire         [1:0]        pipe_tx5_syncheader_gt,
  output wire         [1:0]        pipe_tx6_syncheader_gt,
  output wire         [1:0]        pipe_tx7_syncheader_gt,

  output wire         [2:0]        pipe_rx0_eqpreset_gt,
  output wire         [2:0]        pipe_rx1_eqpreset_gt,
  output wire         [2:0]        pipe_rx2_eqpreset_gt,
  output wire         [2:0]        pipe_rx3_eqpreset_gt,
  output wire         [2:0]        pipe_rx4_eqpreset_gt,
  output wire         [2:0]        pipe_rx5_eqpreset_gt,
  output wire         [2:0]        pipe_rx6_eqpreset_gt,
  output wire         [2:0]        pipe_rx7_eqpreset_gt,

  output wire        [31:0]        pipe_tx0_data_gt,
  output wire        [31:0]        pipe_tx1_data_gt,
  output wire        [31:0]        pipe_tx2_data_gt,
  output wire        [31:0]        pipe_tx3_data_gt,
  output wire        [31:0]        pipe_tx4_data_gt,
  output wire        [31:0]        pipe_tx5_data_gt,
  output wire        [31:0]        pipe_tx6_data_gt,
  output wire        [31:0]        pipe_tx7_data_gt,

  output wire         [3:0]        pipe_rx0_eqlp_txpreset_gt,
  output wire         [3:0]        pipe_rx1_eqlp_txpreset_gt,
  output wire         [3:0]        pipe_rx2_eqlp_txpreset_gt,
  output wire         [3:0]        pipe_rx3_eqlp_txpreset_gt,
  output wire         [3:0]        pipe_rx4_eqlp_txpreset_gt,
  output wire         [3:0]        pipe_rx5_eqlp_txpreset_gt,
  output wire         [3:0]        pipe_rx6_eqlp_txpreset_gt,
  output wire         [3:0]        pipe_rx7_eqlp_txpreset_gt,

  output wire         [3:0]        pipe_tx0_eqpreset_gt,
  output wire         [3:0]        pipe_tx1_eqpreset_gt,
  output wire         [3:0]        pipe_tx2_eqpreset_gt,
  output wire         [3:0]        pipe_tx3_eqpreset_gt,
  output wire         [3:0]        pipe_tx4_eqpreset_gt,
  output wire         [3:0]        pipe_tx5_eqpreset_gt,
  output wire         [3:0]        pipe_tx6_eqpreset_gt,
  output wire         [3:0]        pipe_tx7_eqpreset_gt,

  output wire         [5:0]        pipe_rx0_eqlp_lffs_gt,
  output wire         [5:0]        pipe_rx1_eqlp_lffs_gt,
  output wire         [5:0]        pipe_rx2_eqlp_lffs_gt,
  output wire         [5:0]        pipe_rx3_eqlp_lffs_gt,
  output wire         [5:0]        pipe_rx4_eqlp_lffs_gt,
  output wire         [5:0]        pipe_rx5_eqlp_lffs_gt,
  output wire         [5:0]        pipe_rx6_eqlp_lffs_gt,
  output wire         [5:0]        pipe_rx7_eqlp_lffs_gt,

  output wire         [5:0]        pipe_tx0_eqdeemph_gt,
  output wire         [5:0]        pipe_tx1_eqdeemph_gt,
  output wire         [5:0]        pipe_tx2_eqdeemph_gt,
  output wire         [5:0]        pipe_tx3_eqdeemph_gt,
  output wire         [5:0]        pipe_tx4_eqdeemph_gt,
  output wire         [5:0]        pipe_tx5_eqdeemph_gt,
  output wire         [5:0]        pipe_tx6_eqdeemph_gt,
  output wire         [5:0]        pipe_tx7_eqdeemph_gt,

  output wire         [7:0]        pipe_rx_slide_gt,
  input  wire         [7:0]        pipe_rx_syncdone_gt,

  input                            pipe_rx0_data_valid_gt,
  input                            pipe_rx1_data_valid_gt,
  input                            pipe_rx2_data_valid_gt,
  input                            pipe_rx3_data_valid_gt,
  input                            pipe_rx4_data_valid_gt,
  input                            pipe_rx5_data_valid_gt,
  input                            pipe_rx6_data_valid_gt,
  input                            pipe_rx7_data_valid_gt,

  input                            pipe_rx0_elec_idle_gt,
  input                            pipe_rx1_elec_idle_gt,
  input                            pipe_rx2_elec_idle_gt,
  input                            pipe_rx3_elec_idle_gt,
  input                            pipe_rx4_elec_idle_gt,
  input                            pipe_rx5_elec_idle_gt,
  input                            pipe_rx6_elec_idle_gt,
  input                            pipe_rx7_elec_idle_gt,

  input                            pipe_rx0_eqdone_gt,
  input                            pipe_rx1_eqdone_gt,
  input                            pipe_rx2_eqdone_gt,
  input                            pipe_rx3_eqdone_gt,
  input                            pipe_rx4_eqdone_gt,
  input                            pipe_rx5_eqdone_gt,
  input                            pipe_rx6_eqdone_gt,
  input                            pipe_rx7_eqdone_gt,

  input                            pipe_rx0_eqlp_adaptdone_gt,
  input                            pipe_rx1_eqlp_adaptdone_gt,
  input                            pipe_rx2_eqlp_adaptdone_gt,
  input                            pipe_rx3_eqlp_adaptdone_gt,
  input                            pipe_rx4_eqlp_adaptdone_gt,
  input                            pipe_rx5_eqlp_adaptdone_gt,
  input                            pipe_rx6_eqlp_adaptdone_gt,
  input                            pipe_rx7_eqlp_adaptdone_gt,

  input                            pipe_rx0_eqlp_lffs_sel_gt,
  input                            pipe_rx1_eqlp_lffs_sel_gt,
  input                            pipe_rx2_eqlp_lffs_sel_gt,
  input                            pipe_rx3_eqlp_lffs_sel_gt,
  input                            pipe_rx4_eqlp_lffs_sel_gt,
  input                            pipe_rx5_eqlp_lffs_sel_gt,
  input                            pipe_rx6_eqlp_lffs_sel_gt,
  input                            pipe_rx7_eqlp_lffs_sel_gt,

  input                            pipe_rx0_phy_status_gt,
  input                            pipe_rx1_phy_status_gt,
  input                            pipe_rx2_phy_status_gt,
  input                            pipe_rx3_phy_status_gt,
  input                            pipe_rx4_phy_status_gt,
  input                            pipe_rx5_phy_status_gt,
  input                            pipe_rx6_phy_status_gt,
  input                            pipe_rx7_phy_status_gt,

  input                            pipe_rx0_start_block_gt,
  input                            pipe_rx1_start_block_gt,
  input                            pipe_rx2_start_block_gt,
  input                            pipe_rx3_start_block_gt,
  input                            pipe_rx4_start_block_gt,
  input                            pipe_rx5_start_block_gt,
  input                            pipe_rx6_start_block_gt,
  input                            pipe_rx7_start_block_gt,

  input                            pipe_rx0_valid_gt,
  input                            pipe_rx1_valid_gt,
  input                            pipe_rx2_valid_gt,
  input                            pipe_rx3_valid_gt,
  input                            pipe_rx4_valid_gt,
  input                            pipe_rx5_valid_gt,
  input                            pipe_rx6_valid_gt,
  input                            pipe_rx7_valid_gt,

  input                            pipe_tx0_eqdone_gt,
  input                            pipe_tx1_eqdone_gt,
  input                            pipe_tx2_eqdone_gt,
  input                            pipe_tx3_eqdone_gt,
  input                            pipe_tx4_eqdone_gt,
  input                            pipe_tx5_eqdone_gt,
  input                            pipe_tx6_eqdone_gt,
  input                            pipe_tx7_eqdone_gt,

  input              [17:0]        pipe_rx0_eqlp_new_txcoef_forpreset_gt,
  input              [17:0]        pipe_rx1_eqlp_new_txcoef_forpreset_gt,
  input              [17:0]        pipe_rx2_eqlp_new_txcoef_forpreset_gt,
  input              [17:0]        pipe_rx3_eqlp_new_txcoef_forpreset_gt,
  input              [17:0]        pipe_rx4_eqlp_new_txcoef_forpreset_gt,
  input              [17:0]        pipe_rx5_eqlp_new_txcoef_forpreset_gt,
  input              [17:0]        pipe_rx6_eqlp_new_txcoef_forpreset_gt,
  input              [17:0]        pipe_rx7_eqlp_new_txcoef_forpreset_gt,

  input              [17:0]        pipe_tx0_eqcoeff_gt,
  input              [17:0]        pipe_tx1_eqcoeff_gt,
  input              [17:0]        pipe_tx2_eqcoeff_gt,
  input              [17:0]        pipe_tx3_eqcoeff_gt,
  input              [17:0]        pipe_tx4_eqcoeff_gt,
  input              [17:0]        pipe_tx5_eqcoeff_gt,
  input              [17:0]        pipe_tx6_eqcoeff_gt,
  input              [17:0]        pipe_tx7_eqcoeff_gt,

  input               [1:0]        pipe_rx0_char_is_k_gt,
  input               [1:0]        pipe_rx1_char_is_k_gt,
  input               [1:0]        pipe_rx2_char_is_k_gt,
  input               [1:0]        pipe_rx3_char_is_k_gt,
  input               [1:0]        pipe_rx4_char_is_k_gt,
  input               [1:0]        pipe_rx5_char_is_k_gt,
  input               [1:0]        pipe_rx6_char_is_k_gt,
  input               [1:0]        pipe_rx7_char_is_k_gt,

  input               [1:0]        pipe_rx0_syncheader_gt,
  input               [1:0]        pipe_rx1_syncheader_gt,
  input               [1:0]        pipe_rx2_syncheader_gt,
  input               [1:0]        pipe_rx3_syncheader_gt,
  input               [1:0]        pipe_rx4_syncheader_gt,
  input               [1:0]        pipe_rx5_syncheader_gt,
  input               [1:0]        pipe_rx6_syncheader_gt,
  input               [1:0]        pipe_rx7_syncheader_gt,

  input               [2:0]        pipe_rx0_status_gt,
  input               [2:0]        pipe_rx1_status_gt,
  input               [2:0]        pipe_rx2_status_gt,
  input               [2:0]        pipe_rx3_status_gt,
  input               [2:0]        pipe_rx4_status_gt,
  input               [2:0]        pipe_rx5_status_gt,
  input               [2:0]        pipe_rx6_status_gt,
  input               [2:0]        pipe_rx7_status_gt,

  input               [31:0]       pipe_rx0_data_gt,
  input               [31:0]       pipe_rx1_data_gt,
  input               [31:0]       pipe_rx2_data_gt,
  input               [31:0]       pipe_rx3_data_gt,
  input               [31:0]       pipe_rx4_data_gt,
  input               [31:0]       pipe_rx5_data_gt,
  input               [31:0]       pipe_rx6_data_gt,
  input               [31:0]       pipe_rx7_data_gt

);
//extra wires to math the axi ports size//
  
  //MAXICQTDATA
  
  wire [255:0] m_axis_cq_tdata_256; 
  assign m_axis_cq_tdata=m_axis_cq_tdata_256[C_DATA_WIDTH-1 : 0]; 
  
  //MAXISRCTDATA
  
  wire [255:0] m_axis_rc_tdata_256; 
  assign  m_axis_rc_tdata=m_axis_rc_tdata_256[C_DATA_WIDTH-1 : 0];
  
  //MAXISCQTKEEP
    wire [7:0] m_axis_cq_tkeep_w; 
  assign m_axis_cq_tkeep=m_axis_cq_tkeep_w [(C_DATA_WIDTH/32)-1 : 0];
  
  //MAXISRCTKEEP
  
  wire [7:0] m_axis_rc_tkeep_w; 
  assign m_axis_rc_tkeep=m_axis_rc_tkeep_w [(C_DATA_WIDTH/32)-1 : 0];
  
  
  //SAXISRQTDATA
    //assign saxiscctdata_extra_wire=256'd0;
  wire [255:0] s_axis_rq_tdata_256; 
  assign s_axis_rq_tdata_256 =s_axis_rq_tdata;

  
  //SAXISCSTDATA
   
   //assign saxiscctdata_extra_wire=256'd0;
  wire [255:0] s_axis_cc_tdata_256; 
  assign s_axis_cc_tdata_256 =s_axis_cc_tdata; 
  
  //SAXISCCTKEEP
   wire [7:0] s_axis_cc_tkeep_w; 
  assign s_axis_cc_tkeep_w =s_axis_cc_tkeep;

  //SAXISRQTKEEP
   
  wire [7:0] s_axis_rq_tkeep_w; 
  assign s_axis_rq_tkeep_w = s_axis_rq_tkeep;


  //----------------------------------//
  // PIPE signals                     //
  //----------------------------------//

  wire        pipe_tx_rcvr_det;
  wire        pipe_tx_reset;
  wire [1:0]  pipe_tx_rate;
  wire        pipe_tx_deemph;
  wire [2:0]  pipe_tx_margin;
  wire        pipe_tx_swing;
  wire [5:0]  pipe_tx_eqfs;
  wire [5:0]  pipe_tx_eqlf;
  wire [7:0]  pipe_rx_slide;
  wire [7:0]  pipe_rx_syncdone;

  // Pipe Per-Lane Signals - Lane 0
  wire [ 1:0] pipe_rx0_char_is_k;
  wire [31:0] pipe_rx0_data;
  wire        pipe_rx0_valid;
  wire        pipe_rx0_data_valid;
  wire [ 2:0] pipe_rx0_status;
  wire        pipe_rx0_phy_status;
  wire        pipe_rx0_elec_idle;
  wire        pipe_rx0_eqdone;
  wire        pipe_rx0_eqlp_adaptdone;
  wire        pipe_rx0_eqlp_lffs_sel;
  wire [3:0]  pipe_rx0_eqlp_txpreset;
  wire [17:0] pipe_rx0_eqlp_new_txcoef_forpreset;
  wire        pipe_rx0_start_block;
  wire [ 1:0] pipe_rx0_syncheader;
  wire        pipe_rx0_polarity;
  wire [ 1:0] pipe_rx0_eqcontrol;
  wire [ 5:0] pipe_rx0_eqlp_lffs;
  wire [ 2:0] pipe_rx0_eqpreset;
  wire [17:0] pipe_tx0_eqcoeff;
  wire        pipe_tx0_eqdone;
  wire        pipe_tx0_compliance;
  wire [ 1:0] pipe_tx0_char_is_k;
  wire [31:0] pipe_tx0_data;
  wire        pipe_tx0_elec_idle;
  wire [ 1:0] pipe_tx0_powerdown;
  wire        pipe_tx0_data_valid;
  wire        pipe_tx0_start_block;
  wire [ 1:0] pipe_tx0_syncheader;
  wire [ 1:0] pipe_tx0_eqcontrol;
  wire [ 5:0] pipe_tx0_eqdeemph;
  wire [ 3:0] pipe_tx0_eqpreset;

  // Pipe Per-Lane Signals - Lane 1
  wire [ 1:0] pipe_rx1_char_is_k;
  wire [31:0] pipe_rx1_data;
  wire        pipe_rx1_valid;
  wire        pipe_rx1_data_valid;
  wire [ 2:0] pipe_rx1_status;
  wire        pipe_rx1_phy_status;
  wire        pipe_rx1_elec_idle;
  wire        pipe_rx1_eqdone;
  wire        pipe_rx1_eqlp_adaptdone;
  wire        pipe_rx1_eqlp_lffs_sel;
  wire [3:0]  pipe_rx1_eqlp_txpreset;
  wire [17:0] pipe_rx1_eqlp_new_txcoef_forpreset;
  wire        pipe_rx1_start_block;
  wire [ 1:0] pipe_rx1_syncheader;
  wire        pipe_rx1_polarity;
  wire [ 1:0] pipe_rx1_eqcontrol;
  wire [ 5:0] pipe_rx1_eqlp_lffs;
  wire [ 2:0] pipe_rx1_eqpreset;
  wire [17:0] pipe_tx1_eqcoeff;
  wire        pipe_tx1_eqdone;
  wire        pipe_tx1_compliance;
  wire [ 1:0] pipe_tx1_char_is_k;
  wire [31:0] pipe_tx1_data;
  wire        pipe_tx1_elec_idle;
  wire [ 1:0] pipe_tx1_powerdown;
  wire        pipe_tx1_data_valid;
  wire        pipe_tx1_start_block;
  wire [ 1:0] pipe_tx1_syncheader;
  wire [ 1:0] pipe_tx1_eqcontrol;
  wire [ 5:0] pipe_tx1_eqdeemph;
  wire [ 3:0] pipe_tx1_eqpreset;

  // Pipe Per-Lane Signals - Lane 2
  wire [ 1:0] pipe_rx2_char_is_k;
  wire [31:0] pipe_rx2_data;
  wire        pipe_rx2_valid;
  wire        pipe_rx2_data_valid;
  wire [ 2:0] pipe_rx2_status;
  wire        pipe_rx2_phy_status;
  wire        pipe_rx2_elec_idle;
  wire        pipe_rx2_eqdone;
  wire        pipe_rx2_eqlp_adaptdone;
  wire        pipe_rx2_eqlp_lffs_sel;
  wire [3:0]  pipe_rx2_eqlp_txpreset;
  wire [17:0] pipe_rx2_eqlp_new_txcoef_forpreset;
  wire        pipe_rx2_start_block;
  wire [ 1:0] pipe_rx2_syncheader;
  wire        pipe_rx2_polarity;
  wire [ 1:0] pipe_rx2_eqcontrol;
  wire [ 5:0] pipe_rx2_eqlp_lffs;
  wire [ 2:0] pipe_rx2_eqpreset;
  wire [17:0] pipe_tx2_eqcoeff;
  wire        pipe_tx2_eqdone;
  wire        pipe_tx2_compliance;
  wire [ 1:0] pipe_tx2_char_is_k;
  wire [31:0] pipe_tx2_data;
  wire        pipe_tx2_elec_idle;
  wire [ 1:0] pipe_tx2_powerdown;
  wire        pipe_tx2_data_valid;
  wire        pipe_tx2_start_block;
  wire [ 1:0] pipe_tx2_syncheader;
  wire [ 1:0] pipe_tx2_eqcontrol;
  wire [ 5:0] pipe_tx2_eqdeemph;
  wire [ 3:0] pipe_tx2_eqpreset;

  // Pipe Per-Lane Signals - Lane 3
  wire [ 1:0] pipe_rx3_char_is_k;
  wire [31:0] pipe_rx3_data;
  wire        pipe_rx3_valid;
  wire        pipe_rx3_data_valid;
  wire [ 2:0] pipe_rx3_status;
  wire        pipe_rx3_phy_status;
  wire        pipe_rx3_elec_idle;
  wire        pipe_rx3_eqdone;
  wire        pipe_rx3_eqlp_adaptdone;
  wire        pipe_rx3_eqlp_lffs_sel;
  wire [3:0]  pipe_rx3_eqlp_txpreset;
  wire [17:0] pipe_rx3_eqlp_new_txcoef_forpreset;
  wire        pipe_rx3_start_block;
  wire [ 1:0] pipe_rx3_syncheader;
  wire        pipe_rx3_polarity;
  wire [ 1:0] pipe_rx3_eqcontrol;
  wire [ 5:0] pipe_rx3_eqlp_lffs;
  wire [ 2:0] pipe_rx3_eqpreset;
  wire [17:0] pipe_tx3_eqcoeff;
  wire        pipe_tx3_eqdone;
  wire        pipe_tx3_compliance;
  wire [ 1:0] pipe_tx3_char_is_k;
  wire [31:0] pipe_tx3_data;
  wire        pipe_tx3_elec_idle;
  wire [ 1:0] pipe_tx3_powerdown;
  wire        pipe_tx3_data_valid;
  wire        pipe_tx3_start_block;
  wire [ 1:0] pipe_tx3_syncheader;
  wire [ 1:0] pipe_tx3_eqcontrol;
  wire [ 5:0] pipe_tx3_eqdeemph;
  wire [ 3:0] pipe_tx3_eqpreset;

  // Pipe Per-Lane Signals - Lane 4
  wire [ 1:0] pipe_rx4_char_is_k;
  wire [31:0] pipe_rx4_data;
  wire        pipe_rx4_valid;
  wire        pipe_rx4_data_valid;
  wire [ 2:0] pipe_rx4_status;
  wire        pipe_rx4_phy_status;
  wire        pipe_rx4_elec_idle;
  wire        pipe_rx4_eqdone;
  wire        pipe_rx4_eqlp_adaptdone;
  wire        pipe_rx4_eqlp_lffs_sel;
  wire [3:0]  pipe_rx4_eqlp_txpreset;
  wire [17:0] pipe_rx4_eqlp_new_txcoef_forpreset;
  wire        pipe_rx4_start_block;
  wire [ 1:0] pipe_rx4_syncheader;
  wire        pipe_rx4_polarity;
  wire [ 1:0] pipe_rx4_eqcontrol;
  wire [ 5:0] pipe_rx4_eqlp_lffs;
  wire [ 2:0] pipe_rx4_eqpreset;
  wire [17:0] pipe_tx4_eqcoeff;
  wire        pipe_tx4_eqdone;
  wire        pipe_tx4_compliance;
  wire [ 1:0] pipe_tx4_char_is_k;
  wire [31:0] pipe_tx4_data;
  wire        pipe_tx4_elec_idle;
  wire [ 1:0] pipe_tx4_powerdown;
  wire        pipe_tx4_data_valid;
  wire        pipe_tx4_start_block;
  wire [ 1:0] pipe_tx4_syncheader;
  wire [ 1:0] pipe_tx4_eqcontrol;
  wire [ 5:0] pipe_tx4_eqdeemph;
  wire [ 3:0] pipe_tx4_eqpreset;

  // Pipe Per-Lane Signals - Lane 5
  wire [ 1:0] pipe_rx5_char_is_k;
  wire [31:0] pipe_rx5_data;
  wire        pipe_rx5_valid;
  wire        pipe_rx5_data_valid;
  wire [ 2:0] pipe_rx5_status;
  wire        pipe_rx5_phy_status;
  wire        pipe_rx5_elec_idle;
  wire        pipe_rx5_eqdone;
  wire        pipe_rx5_eqlp_adaptdone;
  wire        pipe_rx5_eqlp_lffs_sel;
  wire [3:0]  pipe_rx5_eqlp_txpreset;
  wire [17:0] pipe_rx5_eqlp_new_txcoef_forpreset;
  wire        pipe_rx5_start_block;
  wire [ 1:0] pipe_rx5_syncheader;
  wire        pipe_rx5_polarity;
  wire [ 1:0] pipe_rx5_eqcontrol;
  wire [ 5:0] pipe_rx5_eqlp_lffs;
  wire [ 2:0] pipe_rx5_eqpreset;
  wire [17:0] pipe_tx5_eqcoeff;
  wire        pipe_tx5_eqdone;
  wire        pipe_tx5_compliance;
  wire [ 1:0] pipe_tx5_char_is_k;
  wire [31:0] pipe_tx5_data;
  wire        pipe_tx5_elec_idle;
  wire [ 1:0] pipe_tx5_powerdown;
  wire        pipe_tx5_data_valid;
  wire        pipe_tx5_start_block;
  wire [ 1:0] pipe_tx5_syncheader;
  wire [ 1:0] pipe_tx5_eqcontrol;
  wire [ 5:0] pipe_tx5_eqdeemph;
  wire [ 3:0] pipe_tx5_eqpreset;

  // Pipe Per-Lane Signals - Lane 6
  wire [ 1:0] pipe_rx6_char_is_k;
  wire [31:0] pipe_rx6_data;
  wire        pipe_rx6_valid;
  wire        pipe_rx6_data_valid;
  wire [ 2:0] pipe_rx6_status;
  wire        pipe_rx6_phy_status;
  wire        pipe_rx6_elec_idle;
  wire        pipe_rx6_eqdone;
  wire        pipe_rx6_eqlp_adaptdone;
  wire        pipe_rx6_eqlp_lffs_sel;
  wire [3:0]  pipe_rx6_eqlp_txpreset;
  wire [17:0] pipe_rx6_eqlp_new_txcoef_forpreset;
  wire        pipe_rx6_start_block;
  wire [ 1:0] pipe_rx6_syncheader;
  wire        pipe_rx6_polarity;
  wire [ 1:0] pipe_rx6_eqcontrol;
  wire [ 5:0] pipe_rx6_eqlp_lffs;
  wire [ 2:0] pipe_rx6_eqpreset;
  wire [17:0] pipe_tx6_eqcoeff;
  wire        pipe_tx6_eqdone;
  wire        pipe_tx6_compliance;
  wire [ 1:0] pipe_tx6_char_is_k;
  wire [31:0] pipe_tx6_data;
  wire        pipe_tx6_elec_idle;
  wire [ 1:0] pipe_tx6_powerdown;
  wire        pipe_tx6_data_valid;
  wire        pipe_tx6_start_block;
  wire [ 1:0] pipe_tx6_syncheader;
  wire [ 1:0] pipe_tx6_eqcontrol;
  wire [ 5:0] pipe_tx6_eqdeemph;
  wire [ 3:0] pipe_tx6_eqpreset;

  // Pipe Per-Lane Signals - Lane 7
  wire [ 1:0] pipe_rx7_char_is_k;
  wire [31:0] pipe_rx7_data;
  wire        pipe_rx7_valid;
  wire        pipe_rx7_data_valid;
  wire [ 2:0] pipe_rx7_status;
  wire        pipe_rx7_phy_status;
  wire        pipe_rx7_elec_idle;
  wire        pipe_rx7_eqdone;
  wire        pipe_rx7_eqlp_adaptdone;
  wire        pipe_rx7_eqlp_lffs_sel;
  wire [3:0]  pipe_rx7_eqlp_txpreset;
  wire [17:0] pipe_rx7_eqlp_new_txcoef_forpreset;
  wire        pipe_rx7_start_block;
  wire [ 1:0] pipe_rx7_syncheader;
  wire        pipe_rx7_polarity;
  wire [ 1:0] pipe_rx7_eqcontrol;
  wire [ 5:0] pipe_rx7_eqlp_lffs;
  wire [ 2:0] pipe_rx7_eqpreset;
  wire [17:0] pipe_tx7_eqcoeff;
  wire        pipe_tx7_eqdone;
  wire        pipe_tx7_compliance;
  wire [ 1:0] pipe_tx7_char_is_k;
  wire [31:0] pipe_tx7_data;
  wire        pipe_tx7_elec_idle;
  wire [ 1:0] pipe_tx7_powerdown;
  wire        pipe_tx7_data_valid;
  wire        pipe_tx7_start_block;
  wire [ 1:0] pipe_tx7_syncheader;
  wire [ 1:0] pipe_tx7_eqcontrol;
  wire [ 5:0] pipe_tx7_eqdeemph;
  wire [ 3:0] pipe_tx7_eqpreset;

  // Pipe Per-Lane Signals - Force Adapt

  wire [31:0] pipe_rx0_data_pcie;
  wire [31:0] pipe_rx1_data_pcie;
  wire [31:0] pipe_rx2_data_pcie;
  wire [31:0] pipe_rx3_data_pcie;
  wire [31:0] pipe_rx4_data_pcie;
  wire [31:0] pipe_rx5_data_pcie;
  wire [31:0] pipe_rx6_data_pcie;
  wire [31:0] pipe_rx7_data_pcie;

  
  wire [1:0]  pipe_rx0_eqcontrol_pcie;  
  wire [1:0]  pipe_rx1_eqcontrol_pcie;
  wire [1:0]  pipe_rx2_eqcontrol_pcie;
  wire [1:0]  pipe_rx3_eqcontrol_pcie;
  wire [1:0]  pipe_rx4_eqcontrol_pcie;
  wire [1:0]  pipe_rx5_eqcontrol_pcie;
  wire [1:0]  pipe_rx6_eqcontrol_pcie;
  wire [1:0]  pipe_rx7_eqcontrol_pcie;

  //----------------------------------//
  // Non PIPE signals                 //
  //----------------------------------//

  // Initialization Controller Signals
  wire        reset_n;
  wire        pipe_reset_n;
  wire        mgmt_reset_n;
  wire        mgmt_sticky_reset_n;
  wire        cfg_input_update_done;
  wire        cfg_input_update_request;
  wire        cfg_mc_update_done;
  wire        cfg_mc_update_request;

  // TLP Hints Table Signals
  wire [4:0]  cfg_tph_stt_address;
  wire [2:0]  cfg_tph_function_num;
  wire [31:0] cfg_tph_stt_write_data;
  wire        cfg_tph_stt_write_enable;
  wire [3:0]  cfg_tph_stt_write_byte_valid;
  wire [31:0] cfg_tph_stt_read_data;
  wire        cfg_tph_stt_read_enable;
  wire        cfg_tph_stt_read_data_valid;

  // Disable Gen3PCS in PIPE Simulation Mode
  wire gen3pcsdisable ;
  assign gen3pcsdisable = (PIPE_SIM_MODE == "FALSE") ? 1'b0 : 1'b1 ;
  // PCIe Initialization Controller
  xdma_0_pcie3_ip_pcie_init_ctrl_7vx # (
    .PL_UPSTREAM_FACING                                ( PL_UPSTREAM_FACING ),
    .TCQ                     ( TCQ )
  ) pcie_init_ctrl_7vx_i (
    .clk_i                          (user_clk),
    .reset_n_o                      (reset_n),
    .pipe_reset_n_o                 (pipe_reset_n),
    .mgmt_reset_n_o                 (mgmt_reset_n),
    .mgmt_sticky_reset_n_o          (mgmt_sticky_reset_n),
    .mmcm_lock_i                    (mmcm_lock),
    .phy_rdy_i                      (phy_rdy),
    .cfg_input_update_done_i        (cfg_input_update_done),
    .cfg_input_update_request_o     (cfg_input_update_request),
    .cfg_mc_update_done_i           (cfg_mc_update_done),
    .cfg_mc_update_request_o        (cfg_mc_update_request),
    .user_cfg_input_update_i        ( 1'b0 ),
    .state_o                        (  )
  );

  // PCIe TLP Processing Hints Table
  xdma_0_pcie3_ip_pcie_tlp_tph_tbl_7vx # (
    .TCQ                            (TCQ )
  ) pcie_tlp_tph_tbl_7vx_i (
    .user_clk                       ( user_clk ),                     // User Clock
    .reset_n                        ( reset_n ),                      // Warm, Hot Reset, active low

    // Integrated Block Interface
    .cfg_tph_stt_address_i          ( cfg_tph_stt_address ),          // Address
    .cfg_tph_function_num_i         ( cfg_tph_function_num ),         // Function #
    .cfg_tph_stt_write_data_i       ( cfg_tph_stt_write_data ), 	    // Write Data
    .cfg_tph_stt_write_enable_i     ( cfg_tph_stt_write_enable ),	    // Write Data Enable
    .cfg_tph_stt_write_byte_valid_i ( cfg_tph_stt_write_byte_valid ), // WBE
    .cfg_tph_stt_read_data_o        ( cfg_tph_stt_read_data ),        // Read Data
    .cfg_tph_stt_read_enable_i      ( cfg_tph_stt_read_enable ),      // Read Data Enable
    .cfg_tph_stt_read_data_valid_o	( cfg_tph_stt_read_data_valid ),  // Read Data Valid

    // User Interface
    .user_tph_stt_address_i         ( user_tph_stt_address ),         // Address
    .user_tph_function_num_i        ( user_tph_function_num ),        // Function #
    .user_tph_stt_read_data_o       ( user_tph_stt_read_data ),       // Read Data
    .user_tph_stt_read_data_valid_o ( user_tph_stt_read_data_valid ), // Read Data Valid
    .user_tph_stt_read_enable_i     ( user_tph_stt_read_enable )      // Read Data Enable
  );


  xdma_0_pcie3_ip_pcie_7vx #(
    .ARI_CAP_ENABLE                                    ( ARI_CAP_ENABLE ),
    .AXISTEN_IF_CC_ALIGNMENT_MODE                      ( AXISTEN_IF_CC_ALIGNMENT_MODE ),
    .AXISTEN_IF_CC_PARITY_CHK                          ( AXISTEN_IF_CC_PARITY_CHK ),
    .AXISTEN_IF_CQ_ALIGNMENT_MODE                      ( AXISTEN_IF_CQ_ALIGNMENT_MODE ),
    .AXISTEN_IF_ENABLE_CLIENT_TAG                      ( AXISTEN_IF_ENABLE_CLIENT_TAG ),
    .AXISTEN_IF_ENABLE_MSG_ROUTE                       ( AXISTEN_IF_ENABLE_MSG_ROUTE ),
    .AXISTEN_IF_ENABLE_RX_MSG_INTFC                    ( AXISTEN_IF_ENABLE_RX_MSG_INTFC ),
    .AXISTEN_IF_RC_ALIGNMENT_MODE                      ( AXISTEN_IF_RC_ALIGNMENT_MODE ),
    .AXISTEN_IF_RC_STRADDLE                            ( AXISTEN_IF_RC_STRADDLE ),
    .AXISTEN_IF_RQ_ALIGNMENT_MODE                      ( AXISTEN_IF_RQ_ALIGNMENT_MODE ),
    .AXISTEN_IF_RQ_PARITY_CHK                          ( AXISTEN_IF_RQ_PARITY_CHK ),
    .AXISTEN_IF_WIDTH                                  ( AXISTEN_IF_WIDTH ),
    .CRM_CORE_CLK_FREQ_500                             ( CRM_CORE_CLK_FREQ_500 ),
    .CRM_USER_CLK_FREQ                                 ( CRM_USER_CLK_FREQ ),
    .DNSTREAM_LINK_NUM                                 ( DNSTREAM_LINK_NUM ),
    .GEN3_PCS_AUTO_REALIGN                             ( GEN3_PCS_AUTO_REALIGN ),
    .GEN3_PCS_RX_ELECIDLE_INTERNAL                     ( GEN3_PCS_RX_ELECIDLE_INTERNAL ),
    .LL_ACK_TIMEOUT                                    ( LL_ACK_TIMEOUT ),
    .LL_ACK_TIMEOUT_EN                                 ( LL_ACK_TIMEOUT_EN ),
    .LL_ACK_TIMEOUT_FUNC                               ( LL_ACK_TIMEOUT_FUNC ),
    .LL_CPL_FC_UPDATE_TIMER                            ( LL_CPL_FC_UPDATE_TIMER ),
    .LL_CPL_FC_UPDATE_TIMER_OVERRIDE                   ( LL_CPL_FC_UPDATE_TIMER_OVERRIDE ),
    .LL_FC_UPDATE_TIMER                                ( LL_FC_UPDATE_TIMER ),
    .LL_FC_UPDATE_TIMER_OVERRIDE                       ( LL_FC_UPDATE_TIMER_OVERRIDE ),
    .LL_NP_FC_UPDATE_TIMER                             ( LL_NP_FC_UPDATE_TIMER ),
    .LL_NP_FC_UPDATE_TIMER_OVERRIDE                    ( LL_NP_FC_UPDATE_TIMER_OVERRIDE ),
    .LL_P_FC_UPDATE_TIMER                              ( LL_P_FC_UPDATE_TIMER ),
    .LL_P_FC_UPDATE_TIMER_OVERRIDE                     ( LL_P_FC_UPDATE_TIMER_OVERRIDE ),
    .LL_REPLAY_TIMEOUT                                 ( LL_REPLAY_TIMEOUT ),
    .LL_REPLAY_TIMEOUT_EN                              ( LL_REPLAY_TIMEOUT_EN ),
    .LL_REPLAY_TIMEOUT_FUNC                            ( LL_REPLAY_TIMEOUT_FUNC ),
    .LTR_TX_MESSAGE_MINIMUM_INTERVAL                   ( LTR_TX_MESSAGE_MINIMUM_INTERVAL ),
    .LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE         ( LTR_TX_MESSAGE_ON_FUNC_POWER_STATE_CHANGE ),
    .LTR_TX_MESSAGE_ON_LTR_ENABLE                      ( LTR_TX_MESSAGE_ON_LTR_ENABLE ),
    .PF0_AER_CAP_ECRC_CHECK_CAPABLE                    ( PF0_AER_CAP_ECRC_CHECK_CAPABLE ),
    .PF0_AER_CAP_ECRC_GEN_CAPABLE                      ( PF0_AER_CAP_ECRC_GEN_CAPABLE ),
    .PF0_AER_CAP_NEXTPTR                               ( PF0_AER_CAP_NEXTPTR ),
    .PF0_ARI_CAP_NEXTPTR                               ( PF0_ARI_CAP_NEXTPTR ),
    .PF0_ARI_CAP_NEXT_FUNC                             ( PF0_ARI_CAP_NEXT_FUNC ),
    .PF0_ARI_CAP_VER                                   ( PF0_ARI_CAP_VER ),
    .PF0_BAR0_APERTURE_SIZE                            ( PF0_BAR0_APERTURE_SIZE ),
    .PF0_BAR0_CONTROL                                  ( PF0_BAR0_CONTROL ),
    .PF0_BAR1_APERTURE_SIZE                            ( PF0_BAR1_APERTURE_SIZE ),
    .PF0_BAR1_CONTROL                                  ( PF0_BAR1_CONTROL ),
    .PF0_BAR2_APERTURE_SIZE                            ( PF0_BAR2_APERTURE_SIZE ),
    .PF0_BAR2_CONTROL                                  ( PF0_BAR2_CONTROL ),
    .PF0_BAR3_APERTURE_SIZE                            ( PF0_BAR3_APERTURE_SIZE ),
    .PF0_BAR3_CONTROL                                  ( PF0_BAR3_CONTROL ),
    .PF0_BAR4_APERTURE_SIZE                            ( PF0_BAR4_APERTURE_SIZE ),
    .PF0_BAR4_CONTROL                                  ( PF0_BAR4_CONTROL ),
    .PF0_BAR5_APERTURE_SIZE                            ( PF0_BAR5_APERTURE_SIZE ),
    .PF0_BAR5_CONTROL                                  ( PF0_BAR5_CONTROL ),
    .PF0_BIST_REGISTER                                 ( PF0_BIST_REGISTER ),
    .PF0_CAPABILITY_POINTER                            ( PF0_CAPABILITY_POINTER ),
    .PF0_CLASS_CODE                                    ( PF0_CLASS_CODE ),
    .PF0_DEVICE_ID                                     ( PF0_DEVICE_ID ),
    .PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT    ( PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT ),
    .PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT         ( PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT ),
    .PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT         ( PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT ),
    .PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE                  ( PF0_DEV_CAP2_CPL_TIMEOUT_DISABLE ),
    .PF0_DEV_CAP2_LTR_SUPPORT                          ( PF0_DEV_CAP2_LTR_SUPPORT ),
    .PF0_DEV_CAP2_OBFF_SUPPORT                         ( PF0_DEV_CAP2_OBFF_SUPPORT ),
    .PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT                ( PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT ),
    .PF0_DEV_CAP_ENDPOINT_L0S_LATENCY                  ( PF0_DEV_CAP_ENDPOINT_L0S_LATENCY ),
    .PF0_DEV_CAP_ENDPOINT_L1_LATENCY                   ( PF0_DEV_CAP_ENDPOINT_L1_LATENCY ),
    .PF0_DEV_CAP_EXT_TAG_SUPPORTED                     ( PF0_DEV_CAP_EXT_TAG_SUPPORTED ),
    .PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE          ( PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE ),
    .PF0_DEV_CAP_MAX_PAYLOAD_SIZE                      ( PF0_DEV_CAP_MAX_PAYLOAD_SIZE ),
    .PF0_DPA_CAP_NEXTPTR                               ( PF0_DPA_CAP_NEXTPTR ),
    .VF0_ARI_CAP_NEXTPTR (VF0_ARI_CAP_NEXTPTR ),
    .VF1_ARI_CAP_NEXTPTR (VF1_ARI_CAP_NEXTPTR ),
    .VF2_ARI_CAP_NEXTPTR (VF2_ARI_CAP_NEXTPTR ),
    .VF3_ARI_CAP_NEXTPTR (VF3_ARI_CAP_NEXTPTR ),
    .VF4_ARI_CAP_NEXTPTR (VF4_ARI_CAP_NEXTPTR ),
    .VF5_ARI_CAP_NEXTPTR (VF5_ARI_CAP_NEXTPTR ),
    .VF0_TPHR_CAP_DEV_SPECIFIC_MODE (VF0_TPHR_CAP_DEV_SPECIFIC_MODE),
    .VF0_TPHR_CAP_ENABLE (VF0_TPHR_CAP_ENABLE),
    .VF0_TPHR_CAP_INT_VEC_MODE (VF0_TPHR_CAP_INT_VEC_MODE),
    .VF0_TPHR_CAP_NEXTPTR (VF0_TPHR_CAP_NEXTPTR),
    .VF0_TPHR_CAP_ST_MODE_SEL (VF0_TPHR_CAP_ST_MODE_SEL),
    .VF0_TPHR_CAP_ST_TABLE_LOC (VF0_TPHR_CAP_ST_TABLE_LOC),
    .VF0_TPHR_CAP_ST_TABLE_SIZE (VF0_TPHR_CAP_ST_TABLE_SIZE),
    .VF0_TPHR_CAP_VER (VF0_TPHR_CAP_VER),
    .VF1_TPHR_CAP_DEV_SPECIFIC_MODE (VF1_TPHR_CAP_DEV_SPECIFIC_MODE),
    .VF1_TPHR_CAP_ENABLE (VF1_TPHR_CAP_ENABLE),
    .VF1_TPHR_CAP_INT_VEC_MODE (VF1_TPHR_CAP_INT_VEC_MODE),
    .VF1_TPHR_CAP_NEXTPTR (VF1_TPHR_CAP_NEXTPTR),
    .VF1_TPHR_CAP_ST_MODE_SEL (VF1_TPHR_CAP_ST_MODE_SEL),
    .VF1_TPHR_CAP_ST_TABLE_LOC (VF1_TPHR_CAP_ST_TABLE_LOC),
    .VF1_TPHR_CAP_ST_TABLE_SIZE (VF1_TPHR_CAP_ST_TABLE_SIZE),
    .VF1_TPHR_CAP_VER (VF1_TPHR_CAP_VER),
    .VF2_TPHR_CAP_DEV_SPECIFIC_MODE (VF2_TPHR_CAP_DEV_SPECIFIC_MODE),
    .VF2_TPHR_CAP_ENABLE (VF2_TPHR_CAP_ENABLE),
    .VF2_TPHR_CAP_INT_VEC_MODE (VF2_TPHR_CAP_INT_VEC_MODE),
    .VF2_TPHR_CAP_NEXTPTR (VF2_TPHR_CAP_NEXTPTR),
    .VF2_TPHR_CAP_ST_MODE_SEL (VF2_TPHR_CAP_ST_MODE_SEL),
    .VF2_TPHR_CAP_ST_TABLE_LOC (VF2_TPHR_CAP_ST_TABLE_LOC),
    .VF2_TPHR_CAP_ST_TABLE_SIZE (VF2_TPHR_CAP_ST_TABLE_SIZE),
    .VF2_TPHR_CAP_VER (VF2_TPHR_CAP_VER),
    .VF3_TPHR_CAP_DEV_SPECIFIC_MODE (VF3_TPHR_CAP_DEV_SPECIFIC_MODE),
    .VF3_TPHR_CAP_ENABLE (VF3_TPHR_CAP_ENABLE),
    .VF3_TPHR_CAP_INT_VEC_MODE (VF3_TPHR_CAP_INT_VEC_MODE),
    .VF3_TPHR_CAP_NEXTPTR (VF3_TPHR_CAP_NEXTPTR),
    .VF3_TPHR_CAP_ST_MODE_SEL (VF3_TPHR_CAP_ST_MODE_SEL),
    .VF3_TPHR_CAP_ST_TABLE_LOC (VF3_TPHR_CAP_ST_TABLE_LOC),
    .VF3_TPHR_CAP_ST_TABLE_SIZE (VF3_TPHR_CAP_ST_TABLE_SIZE),
    .VF3_TPHR_CAP_VER (VF3_TPHR_CAP_VER),
    .VF4_TPHR_CAP_DEV_SPECIFIC_MODE (VF4_TPHR_CAP_DEV_SPECIFIC_MODE),
    .VF4_TPHR_CAP_ENABLE (VF4_TPHR_CAP_ENABLE),
    .VF4_TPHR_CAP_INT_VEC_MODE (VF4_TPHR_CAP_INT_VEC_MODE),
    .VF4_TPHR_CAP_NEXTPTR (VF4_TPHR_CAP_NEXTPTR),
    .VF4_TPHR_CAP_ST_MODE_SEL (VF4_TPHR_CAP_ST_MODE_SEL),
    .VF4_TPHR_CAP_ST_TABLE_LOC (VF4_TPHR_CAP_ST_TABLE_LOC),
    .VF4_TPHR_CAP_ST_TABLE_SIZE (VF4_TPHR_CAP_ST_TABLE_SIZE),
    .VF4_TPHR_CAP_VER (VF4_TPHR_CAP_VER),
    .VF5_TPHR_CAP_DEV_SPECIFIC_MODE (VF5_TPHR_CAP_DEV_SPECIFIC_MODE),
    .VF5_TPHR_CAP_ENABLE (VF5_TPHR_CAP_ENABLE),
    .VF5_TPHR_CAP_INT_VEC_MODE (VF5_TPHR_CAP_INT_VEC_MODE),
    .VF5_TPHR_CAP_NEXTPTR (VF5_TPHR_CAP_NEXTPTR),
    .VF5_TPHR_CAP_ST_MODE_SEL (VF5_TPHR_CAP_ST_MODE_SEL),
    .VF5_TPHR_CAP_ST_TABLE_LOC (VF5_TPHR_CAP_ST_TABLE_LOC),
    .VF5_TPHR_CAP_ST_TABLE_SIZE (VF5_TPHR_CAP_ST_TABLE_SIZE),
    .VF5_TPHR_CAP_VER (VF5_TPHR_CAP_VER),
    .PF0_DPA_CAP_SUB_STATE_CONTROL                     ( PF0_DPA_CAP_SUB_STATE_CONTROL ),
    .PF0_DPA_CAP_SUB_STATE_CONTROL_EN                  ( PF0_DPA_CAP_SUB_STATE_CONTROL_EN ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 ),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7           ( PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 ),
    .PF0_DPA_CAP_VER                                   ( PF0_DPA_CAP_VER ),
    .PF0_DSN_CAP_NEXTPTR                               ( PF0_DSN_CAP_NEXTPTR ),
    .PF0_EXPANSION_ROM_APERTURE_SIZE                   ( PF0_EXPANSION_ROM_APERTURE_SIZE ),
    .PF0_EXPANSION_ROM_ENABLE                          ( PF0_EXPANSION_ROM_ENABLE ),
    .PF0_INTERRUPT_LINE                                ( PF0_INTERRUPT_LINE ),
    .PF0_INTERRUPT_PIN                                 ( PF0_INTERRUPT_PIN ),
    .PF0_LINK_CAP_ASPM_SUPPORT                         ( PF0_LINK_CAP_ASPM_SUPPORT ),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1         ( PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN1 ),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2         ( PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN2 ),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3         ( PF0_LINK_CAP_L0S_EXIT_LATENCY_COMCLK_GEN3 ),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1                ( PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN1 ),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2                ( PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN2 ),
    .PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3                ( PF0_LINK_CAP_L0S_EXIT_LATENCY_GEN3 ),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1          ( PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN1 ),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2          ( PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN2 ),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3          ( PF0_LINK_CAP_L1_EXIT_LATENCY_COMCLK_GEN3 ),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1                 ( PF0_LINK_CAP_L1_EXIT_LATENCY_GEN1 ),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2                 ( PF0_LINK_CAP_L1_EXIT_LATENCY_GEN2 ),
    .PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3                 ( PF0_LINK_CAP_L1_EXIT_LATENCY_GEN3 ),
    .PF0_LINK_STATUS_SLOT_CLOCK_CONFIG                 ( PF0_LINK_STATUS_SLOT_CLOCK_CONFIG ),
    .PF0_LTR_CAP_MAX_NOSNOOP_LAT                       ( PF0_LTR_CAP_MAX_NOSNOOP_LAT ),
    .PF0_LTR_CAP_MAX_SNOOP_LAT                         ( PF0_LTR_CAP_MAX_SNOOP_LAT ),
    .PF0_LTR_CAP_NEXTPTR                               ( PF0_LTR_CAP_NEXTPTR ),
    .PF0_LTR_CAP_VER                                   ( PF0_LTR_CAP_VER ),
    .PF0_MSIX_CAP_NEXTPTR                              ( PF0_MSIX_CAP_NEXTPTR ),
    .PF0_MSIX_CAP_PBA_BIR                              ( PF0_MSIX_CAP_PBA_BIR ),
    .PF0_MSIX_CAP_PBA_OFFSET                           ( PF0_MSIX_CAP_PBA_OFFSET ),
    .PF0_MSIX_CAP_TABLE_BIR                            ( PF0_MSIX_CAP_TABLE_BIR ),
    .PF0_MSIX_CAP_TABLE_OFFSET                         ( PF0_MSIX_CAP_TABLE_OFFSET ),
    .PF0_MSIX_CAP_TABLE_SIZE                           ( PF0_MSIX_CAP_TABLE_SIZE ),
    .PF0_MSI_CAP_MULTIMSGCAP                           ( PF0_MSI_CAP_MULTIMSGCAP ),
    .PF0_MSI_CAP_NEXTPTR                               ( PF0_MSI_CAP_NEXTPTR ),
    .PF0_PB_CAP_NEXTPTR                                ( PF0_PB_CAP_NEXTPTR ),
    .PF0_PB_CAP_SYSTEM_ALLOCATED                       ( PF0_PB_CAP_SYSTEM_ALLOCATED ),
    .PF0_PB_CAP_VER                                    ( PF0_PB_CAP_VER ),
    .PF0_PM_CAP_ID                                     ( PF0_PM_CAP_ID ),
    .PF0_PM_CAP_NEXTPTR                                ( PF0_PM_CAP_NEXTPTR ),
    .PF0_PM_CAP_PMESUPPORT_D0                          ( PF0_PM_CAP_PMESUPPORT_D0 ),
    .PF0_PM_CAP_PMESUPPORT_D1                          ( PF0_PM_CAP_PMESUPPORT_D1 ),
    .PF0_PM_CAP_PMESUPPORT_D3HOT                       ( PF0_PM_CAP_PMESUPPORT_D3HOT ),
    .PF0_PM_CAP_SUPP_D1_STATE                          ( PF0_PM_CAP_SUPP_D1_STATE ),
    .PF0_PM_CAP_VER_ID                                 ( PF0_PM_CAP_VER_ID ),
    .PF0_PM_CSR_NOSOFTRESET                            ( PF0_PM_CSR_NOSOFTRESET ),
    .PF0_RBAR_CAP_ENABLE                               ( PF0_RBAR_CAP_ENABLE ),
    .PF0_RBAR_CAP_INDEX0                               ( PF0_RBAR_CAP_INDEX0 ),
    .PF0_RBAR_CAP_INDEX1                               ( PF0_RBAR_CAP_INDEX1 ),
    .PF0_RBAR_CAP_INDEX2                               ( PF0_RBAR_CAP_INDEX2 ),
    .PF0_RBAR_CAP_NEXTPTR                              ( PF0_RBAR_CAP_NEXTPTR ),
    .PF0_RBAR_CAP_SIZE0                                ( PF0_RBAR_CAP_SIZE0 ),
    .PF0_RBAR_CAP_SIZE1                                ( PF0_RBAR_CAP_SIZE1 ),
    .PF0_RBAR_CAP_SIZE2                                ( PF0_RBAR_CAP_SIZE2 ),
    .PF0_RBAR_CAP_VER                                  ( PF0_RBAR_CAP_VER ),
    .PF0_RBAR_NUM                                      ( PF0_RBAR_NUM ),
    .PF0_REVISION_ID                                   ( PF0_REVISION_ID ),
    .PF0_SRIOV_BAR0_APERTURE_SIZE                      ( PF0_SRIOV_BAR0_APERTURE_SIZE ),
    .PF0_SRIOV_BAR0_CONTROL                            ( PF0_SRIOV_BAR0_CONTROL ),
    .PF0_SRIOV_BAR1_APERTURE_SIZE                      ( PF0_SRIOV_BAR1_APERTURE_SIZE ),
    .PF0_SRIOV_BAR1_CONTROL                            ( PF0_SRIOV_BAR1_CONTROL ),
    .PF0_SRIOV_BAR2_APERTURE_SIZE                      ( PF0_SRIOV_BAR2_APERTURE_SIZE ),
    .PF0_SRIOV_BAR2_CONTROL                            ( PF0_SRIOV_BAR2_CONTROL ),
    .PF0_SRIOV_BAR3_APERTURE_SIZE                      ( PF0_SRIOV_BAR3_APERTURE_SIZE ),
    .PF0_SRIOV_BAR3_CONTROL                            ( PF0_SRIOV_BAR3_CONTROL ),
    .PF0_SRIOV_BAR4_APERTURE_SIZE                      ( PF0_SRIOV_BAR4_APERTURE_SIZE ),
    .PF0_SRIOV_BAR4_CONTROL                            ( PF0_SRIOV_BAR4_CONTROL ),
    .PF0_SRIOV_BAR5_APERTURE_SIZE                      ( PF0_SRIOV_BAR5_APERTURE_SIZE ),
    .PF0_SRIOV_BAR5_CONTROL                            ( PF0_SRIOV_BAR5_CONTROL ),
    .PF0_SRIOV_CAP_INITIAL_VF                          ( PF0_SRIOV_CAP_INITIAL_VF ),
    .PF0_SRIOV_CAP_NEXTPTR                             ( PF0_SRIOV_CAP_NEXTPTR ),
    .PF0_SRIOV_CAP_TOTAL_VF                            ( PF0_SRIOV_CAP_TOTAL_VF ),
    .PF0_SRIOV_CAP_VER                                 ( PF0_SRIOV_CAP_VER ),
    .PF0_SRIOV_FIRST_VF_OFFSET                         ( PF0_SRIOV_FIRST_VF_OFFSET ),
    .PF0_SRIOV_FUNC_DEP_LINK                           ( PF0_SRIOV_FUNC_DEP_LINK ),
    .PF0_SRIOV_SUPPORTED_PAGE_SIZE                     ( PF0_SRIOV_SUPPORTED_PAGE_SIZE ),
    .PF0_SRIOV_VF_DEVICE_ID                            ( PF0_SRIOV_VF_DEVICE_ID ),
    .PF0_SUBSYSTEM_ID                                  ( PF0_SUBSYSTEM_ID ),
    .PF0_TPHR_CAP_DEV_SPECIFIC_MODE                    ( PF0_TPHR_CAP_DEV_SPECIFIC_MODE ),
    .PF0_TPHR_CAP_ENABLE                               ( PF0_TPHR_CAP_ENABLE ),
    .PF0_TPHR_CAP_INT_VEC_MODE                         ( PF0_TPHR_CAP_INT_VEC_MODE ),
    .PF0_TPHR_CAP_NEXTPTR                              ( PF0_TPHR_CAP_NEXTPTR ),
    .PF0_TPHR_CAP_ST_MODE_SEL                          ( PF0_TPHR_CAP_ST_MODE_SEL ),
    .PF0_TPHR_CAP_ST_TABLE_LOC                         ( PF0_TPHR_CAP_ST_TABLE_LOC ),
    .PF0_TPHR_CAP_ST_TABLE_SIZE                        ( PF0_TPHR_CAP_ST_TABLE_SIZE ),
    .PF0_TPHR_CAP_VER                                  ( PF0_TPHR_CAP_VER ),
    .PF0_VC_CAP_NEXTPTR                                ( PF0_VC_CAP_NEXTPTR ),
    .PF0_VC_CAP_VER                                    ( PF0_VC_CAP_VER ),
    .PF1_AER_CAP_ECRC_CHECK_CAPABLE                    ( PF1_AER_CAP_ECRC_CHECK_CAPABLE ),
    .PF1_AER_CAP_ECRC_GEN_CAPABLE                      ( PF1_AER_CAP_ECRC_GEN_CAPABLE ),
    .PF1_AER_CAP_NEXTPTR                               ( PF1_AER_CAP_NEXTPTR ),
    .PF1_ARI_CAP_NEXTPTR                               ( PF1_ARI_CAP_NEXTPTR ),
    .PF1_ARI_CAP_NEXT_FUNC                             ( PF1_ARI_CAP_NEXT_FUNC ),
    .PF1_BAR0_APERTURE_SIZE                            ( PF1_BAR0_APERTURE_SIZE ),
    .PF1_BAR0_CONTROL                                  ( PF1_BAR0_CONTROL ),
    .PF1_BAR1_APERTURE_SIZE                            ( PF1_BAR1_APERTURE_SIZE ),
    .PF1_BAR1_CONTROL                                  ( PF1_BAR1_CONTROL ),
    .PF1_BAR2_APERTURE_SIZE                            ( PF1_BAR2_APERTURE_SIZE ),
    .PF1_BAR2_CONTROL                                  ( PF1_BAR2_CONTROL ),
    .PF1_BAR3_APERTURE_SIZE                            ( PF1_BAR3_APERTURE_SIZE ),
    .PF1_BAR3_CONTROL                                  ( PF1_BAR3_CONTROL ),
    .PF1_BAR4_APERTURE_SIZE                            ( PF1_BAR4_APERTURE_SIZE ),
    .PF1_BAR4_CONTROL                                  ( PF1_BAR4_CONTROL ),
    .PF1_BAR5_APERTURE_SIZE                            ( PF1_BAR5_APERTURE_SIZE ),
    .PF1_BAR5_CONTROL                                  ( PF1_BAR5_CONTROL ),
    .PF1_BIST_REGISTER                                 ( PF1_BIST_REGISTER ),
    .PF1_CAPABILITY_POINTER                            ( PF1_CAPABILITY_POINTER ),
    .PF1_CLASS_CODE                                    ( PF1_CLASS_CODE ),
    .PF1_DEVICE_ID                                     ( PF1_DEVICE_ID ),
    .PF1_DEV_CAP_MAX_PAYLOAD_SIZE                      ( PF1_DEV_CAP_MAX_PAYLOAD_SIZE ),
    .PF1_DPA_CAP_NEXTPTR                               ( PF1_DPA_CAP_NEXTPTR ),
    .PF1_DPA_CAP_SUB_STATE_CONTROL                     ( PF1_DPA_CAP_SUB_STATE_CONTROL ),
    .PF1_DPA_CAP_SUB_STATE_CONTROL_EN                  ( PF1_DPA_CAP_SUB_STATE_CONTROL_EN ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0 ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1 ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2 ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3 ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4 ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5 ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6 ),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7           ( PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7 ),
    .PF1_DPA_CAP_VER                                   ( PF1_DPA_CAP_VER ),
    .PF1_DSN_CAP_NEXTPTR                               ( PF1_DSN_CAP_NEXTPTR ),
    .PF1_EXPANSION_ROM_APERTURE_SIZE                   ( PF1_EXPANSION_ROM_APERTURE_SIZE ),
    .PF1_EXPANSION_ROM_ENABLE                          ( PF1_EXPANSION_ROM_ENABLE ),
    .PF1_INTERRUPT_LINE                                ( PF1_INTERRUPT_LINE ),
    .PF1_INTERRUPT_PIN                                 ( PF1_INTERRUPT_PIN ),
    .PF1_MSIX_CAP_NEXTPTR                              ( PF1_MSIX_CAP_NEXTPTR ),
    .PF1_MSIX_CAP_PBA_BIR                              ( PF1_MSIX_CAP_PBA_BIR ),
    .PF1_MSIX_CAP_PBA_OFFSET                           ( PF1_MSIX_CAP_PBA_OFFSET ),
    .PF1_MSIX_CAP_TABLE_BIR                            ( PF1_MSIX_CAP_TABLE_BIR ),
    .PF1_MSIX_CAP_TABLE_OFFSET                         ( PF1_MSIX_CAP_TABLE_OFFSET ),
    .PF1_MSIX_CAP_TABLE_SIZE                           ( PF1_MSIX_CAP_TABLE_SIZE ),
    .PF1_MSI_CAP_MULTIMSGCAP                           ( PF1_MSI_CAP_MULTIMSGCAP ),
    .PF1_MSI_CAP_NEXTPTR                               ( PF1_MSI_CAP_NEXTPTR ),
    .PF1_PB_CAP_NEXTPTR                                ( PF1_PB_CAP_NEXTPTR ),
    .PF1_PB_CAP_SYSTEM_ALLOCATED                       ( PF1_PB_CAP_SYSTEM_ALLOCATED ),
    .PF1_PB_CAP_VER                                    ( PF1_PB_CAP_VER ),
    .PF1_PM_CAP_ID                                     ( PF1_PM_CAP_ID ),
    .PF1_PM_CAP_NEXTPTR                                ( PF1_PM_CAP_NEXTPTR ),
    .PF1_PM_CAP_VER_ID                                 ( PF1_PM_CAP_VER_ID ),
    .PF1_RBAR_CAP_ENABLE                               ( PF1_RBAR_CAP_ENABLE ),
    .PF1_RBAR_CAP_INDEX0                               ( PF1_RBAR_CAP_INDEX0 ),
    .PF1_RBAR_CAP_INDEX1                               ( PF1_RBAR_CAP_INDEX1 ),
    .PF1_RBAR_CAP_INDEX2                               ( PF1_RBAR_CAP_INDEX2 ),
    .PF1_RBAR_CAP_NEXTPTR                              ( PF1_RBAR_CAP_NEXTPTR ),
    .PF1_RBAR_CAP_SIZE0                                ( PF1_RBAR_CAP_SIZE0 ),
    .PF1_RBAR_CAP_SIZE1                                ( PF1_RBAR_CAP_SIZE1 ),
    .PF1_RBAR_CAP_SIZE2                                ( PF1_RBAR_CAP_SIZE2 ),
    .PF1_RBAR_CAP_VER                                  ( PF1_RBAR_CAP_VER ),
    .PF1_RBAR_NUM                                      ( PF1_RBAR_NUM ),
    .PF1_REVISION_ID                                   ( PF1_REVISION_ID ),
    .PF1_SRIOV_BAR0_APERTURE_SIZE                      ( PF1_SRIOV_BAR0_APERTURE_SIZE ),
    .PF1_SRIOV_BAR0_CONTROL                            ( PF1_SRIOV_BAR0_CONTROL ),
    .PF1_SRIOV_BAR1_APERTURE_SIZE                      ( PF1_SRIOV_BAR1_APERTURE_SIZE ),
    .PF1_SRIOV_BAR1_CONTROL                            ( PF1_SRIOV_BAR1_CONTROL ),
    .PF1_SRIOV_BAR2_APERTURE_SIZE                      ( PF1_SRIOV_BAR2_APERTURE_SIZE ),
    .PF1_SRIOV_BAR2_CONTROL                            ( PF1_SRIOV_BAR2_CONTROL ),
    .PF1_SRIOV_BAR3_APERTURE_SIZE                      ( PF1_SRIOV_BAR3_APERTURE_SIZE ),
    .PF1_SRIOV_BAR3_CONTROL                            ( PF1_SRIOV_BAR3_CONTROL ),
    .PF1_SRIOV_BAR4_APERTURE_SIZE                      ( PF1_SRIOV_BAR4_APERTURE_SIZE ),
    .PF1_SRIOV_BAR4_CONTROL                            ( PF1_SRIOV_BAR4_CONTROL ),
    .PF1_SRIOV_BAR5_APERTURE_SIZE                      ( PF1_SRIOV_BAR5_APERTURE_SIZE ),
    .PF1_SRIOV_BAR5_CONTROL                            ( PF1_SRIOV_BAR5_CONTROL ),
    .PF1_SRIOV_CAP_INITIAL_VF                          ( PF1_SRIOV_CAP_INITIAL_VF ),
    .PF1_SRIOV_CAP_NEXTPTR                             ( PF1_SRIOV_CAP_NEXTPTR ),
    .PF1_SRIOV_CAP_TOTAL_VF                            ( PF1_SRIOV_CAP_TOTAL_VF ),
    .PF1_SRIOV_CAP_VER                                 ( PF1_SRIOV_CAP_VER ),
    .PF1_SRIOV_FIRST_VF_OFFSET                         ( PF1_SRIOV_FIRST_VF_OFFSET ),
    .PF1_SRIOV_FUNC_DEP_LINK                           ( PF1_SRIOV_FUNC_DEP_LINK ),
    .PF1_SRIOV_SUPPORTED_PAGE_SIZE                     ( PF1_SRIOV_SUPPORTED_PAGE_SIZE ),
    .PF1_SRIOV_VF_DEVICE_ID                            ( PF1_SRIOV_VF_DEVICE_ID ),
    .PF1_SUBSYSTEM_ID                                  ( PF1_SUBSYSTEM_ID ),
    .PF1_TPHR_CAP_DEV_SPECIFIC_MODE                    ( PF1_TPHR_CAP_DEV_SPECIFIC_MODE ),
    .PF1_TPHR_CAP_ENABLE                               ( PF1_TPHR_CAP_ENABLE ),
    .PF1_TPHR_CAP_INT_VEC_MODE                         ( PF1_TPHR_CAP_INT_VEC_MODE ),
    .PF1_TPHR_CAP_NEXTPTR                              ( PF1_TPHR_CAP_NEXTPTR ),
    .PF1_TPHR_CAP_ST_MODE_SEL                          ( PF1_TPHR_CAP_ST_MODE_SEL ),
    .PF1_TPHR_CAP_ST_TABLE_LOC                         ( PF1_TPHR_CAP_ST_TABLE_LOC ),
    .PF1_TPHR_CAP_ST_TABLE_SIZE                        ( PF1_TPHR_CAP_ST_TABLE_SIZE ),
    .PF1_TPHR_CAP_VER                                  ( PF1_TPHR_CAP_VER ),
    .PL_DISABLE_EI_INFER_IN_L0                         ( PL_DISABLE_EI_INFER_IN_L0 ),
    .PL_DISABLE_GEN3_DC_BALANCE                        ( PL_DISABLE_GEN3_DC_BALANCE ),
    .PL_DISABLE_SCRAMBLING                             ( PL_DISABLE_SCRAMBLING ),
    .PL_DISABLE_UPCONFIG_CAPABLE                       ( PL_DISABLE_UPCONFIG_CAPABLE ),
    .PL_EQ_ADAPT_DISABLE_COEFF_CHECK                   ( PL_EQ_ADAPT_DISABLE_COEFF_CHECK ),
    .PL_EQ_ADAPT_DISABLE_PRESET_CHECK                  ( PL_EQ_ADAPT_DISABLE_PRESET_CHECK ),
    .PL_EQ_ADAPT_ITER_COUNT                            ( PL_EQ_ADAPT_ITER_COUNT ),
    .PL_EQ_ADAPT_REJECT_RETRY_COUNT                    ( PL_EQ_ADAPT_REJECT_RETRY_COUNT ),
    .PL_EQ_BYPASS_PHASE23                              ( PL_EQ_BYPASS_PHASE23 ),
    .PL_EQ_SHORT_ADAPT_PHASE                           ( PL_EQ_SHORT_ADAPT_PHASE ),
    .PL_LANE0_EQ_CONTROL                               ( PL_LANE0_EQ_CONTROL ),
    .PL_LANE1_EQ_CONTROL                               ( PL_LANE1_EQ_CONTROL ),
    .PL_LANE2_EQ_CONTROL                               ( PL_LANE2_EQ_CONTROL ),
    .PL_LANE3_EQ_CONTROL                               ( PL_LANE3_EQ_CONTROL ),
    .PL_LANE4_EQ_CONTROL                               ( PL_LANE4_EQ_CONTROL ),
    .PL_LANE5_EQ_CONTROL                               ( PL_LANE5_EQ_CONTROL ),
    .PL_LANE6_EQ_CONTROL                               ( PL_LANE6_EQ_CONTROL ),
    .PL_LANE7_EQ_CONTROL                               ( PL_LANE7_EQ_CONTROL ),
    .PL_LINK_CAP_MAX_LINK_SPEED                        ( PL_LINK_CAP_MAX_LINK_SPEED ),
    .PL_LINK_CAP_MAX_LINK_WIDTH                        ( PL_LINK_CAP_MAX_LINK_WIDTH ),
    .PL_N_FTS_COMCLK_GEN1                              ( PL_N_FTS_COMCLK_GEN1 ),
    .PL_N_FTS_COMCLK_GEN2                              ( PL_N_FTS_COMCLK_GEN2 ),
    .PL_N_FTS_COMCLK_GEN3                              ( PL_N_FTS_COMCLK_GEN3 ),
    .PL_N_FTS_GEN1                                     ( PL_N_FTS_GEN1 ),
    .PL_N_FTS_GEN2                                     ( PL_N_FTS_GEN2 ),
    .PL_N_FTS_GEN3                                     ( PL_N_FTS_GEN3 ),
    .PL_SIM_FAST_LINK_TRAINING                         ( PL_SIM_FAST_LINK_TRAINING ),
    .PL_UPSTREAM_FACING                                ( PL_UPSTREAM_FACING ),
    .PM_ASPML0S_TIMEOUT                                ( PM_ASPML0S_TIMEOUT ),
    .PM_ASPML1_ENTRY_DELAY                             ( PM_ASPML1_ENTRY_DELAY ),
    .PM_ENABLE_SLOT_POWER_CAPTURE                      ( PM_ENABLE_SLOT_POWER_CAPTURE ),
    .PM_L1_REENTRY_DELAY                               ( PM_L1_REENTRY_DELAY ),
    .PM_PME_SERVICE_TIMEOUT_DELAY                      ( PM_PME_SERVICE_TIMEOUT_DELAY ),
    .PM_PME_TURNOFF_ACK_DELAY                          ( PM_PME_TURNOFF_ACK_DELAY ),
    .SIM_VERSION                                       ( SIM_VERSION ),
    .SPARE_BIT0                                        ( SPARE_BIT0 ),
    .SPARE_BIT1                                        ( SPARE_BIT1 ),
    .SPARE_BIT2                                        ( SPARE_BIT2 ),
    .SPARE_BIT3                                        ( SPARE_BIT3 ),
    .SPARE_BIT4                                        ( SPARE_BIT4 ),
    .SPARE_BIT5                                        ( SPARE_BIT5 ),
    .SPARE_BIT6                                        ( SPARE_BIT6 ),
    .SPARE_BIT7                                        ( SPARE_BIT7 ),
    .SPARE_BIT8                                        ( SPARE_BIT8 ),
    .SPARE_BYTE0                                       ( SPARE_BYTE0 ),
    .SPARE_BYTE1                                       ( SPARE_BYTE1 ),
    .SPARE_BYTE2                                       ( SPARE_BYTE2 ),
    .SPARE_BYTE3                                       ( SPARE_BYTE3 ),
    .SPARE_WORD0                                       ( SPARE_WORD0 ),
    .SPARE_WORD1                                       ( SPARE_WORD1 ),
    .SPARE_WORD2                                       ( SPARE_WORD2 ),
    .SPARE_WORD3                                       ( SPARE_WORD3 ),
    .SRIOV_CAP_ENABLE                                  ( SRIOV_CAP_ENABLE ),
    .TL_COMPL_TIMEOUT_REG0                             ( TL_COMPL_TIMEOUT_REG0 ),
    .TL_COMPL_TIMEOUT_REG1                             ( TL_COMPL_TIMEOUT_REG1 ),
    .TL_CREDITS_CD                                     ( TL_CREDITS_CD ),
    .TL_CREDITS_CH                                     ( TL_CREDITS_CH ),
    .TL_CREDITS_NPD                                    ( TL_CREDITS_NPD ),
    .TL_CREDITS_NPH                                    ( TL_CREDITS_NPH ),
    .TL_CREDITS_PD                                     ( TL_CREDITS_PD ),
    .TL_CREDITS_PH                                     ( TL_CREDITS_PH ),
    .TL_ENABLE_MESSAGE_RID_CHECK_ENABLE                ( TL_ENABLE_MESSAGE_RID_CHECK_ENABLE ),
    .TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE           ( TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE ),
    .TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE             ( TL_LEGACY_CFG_EXTEND_INTERFACE_ENABLE ),
    .TL_LEGACY_MODE_ENABLE                             ( TL_LEGACY_MODE_ENABLE ),
    .TL_PF_ENABLE_REG                                  ( TL_PF_ENABLE_REG ),
    .TL_TAG_MGMT_ENABLE                                ( TL_TAG_MGMT_ENABLE ),
    .VF0_CAPABILITY_POINTER                            ( VF0_CAPABILITY_POINTER ),
    .VF0_MSIX_CAP_PBA_BIR                              ( VF0_MSIX_CAP_PBA_BIR ),
    .VF0_MSIX_CAP_PBA_OFFSET                           ( VF0_MSIX_CAP_PBA_OFFSET ),
    .VF0_MSIX_CAP_TABLE_BIR                            ( VF0_MSIX_CAP_TABLE_BIR ),
    .VF0_MSIX_CAP_TABLE_OFFSET                         ( VF0_MSIX_CAP_TABLE_OFFSET ),
    .VF0_MSIX_CAP_TABLE_SIZE                           ( VF0_MSIX_CAP_TABLE_SIZE ),
    .VF0_MSI_CAP_MULTIMSGCAP                           ( VF0_MSI_CAP_MULTIMSGCAP ),
    .VF0_PM_CAP_ID                                     ( VF0_PM_CAP_ID ),
    .VF0_PM_CAP_NEXTPTR                                ( VF0_PM_CAP_NEXTPTR ),
    .VF0_PM_CAP_VER_ID                                 ( VF0_PM_CAP_VER_ID ),
    .VF1_MSIX_CAP_PBA_BIR                              ( VF1_MSIX_CAP_PBA_BIR ),
    .VF1_MSIX_CAP_PBA_OFFSET                           ( VF1_MSIX_CAP_PBA_OFFSET ),
    .VF1_MSIX_CAP_TABLE_BIR                            ( VF1_MSIX_CAP_TABLE_BIR ),
    .VF1_MSIX_CAP_TABLE_OFFSET                         ( VF1_MSIX_CAP_TABLE_OFFSET ),
    .VF1_MSIX_CAP_TABLE_SIZE                           ( VF1_MSIX_CAP_TABLE_SIZE ),
    .VF1_MSI_CAP_MULTIMSGCAP                           ( VF1_MSI_CAP_MULTIMSGCAP ),
    .VF1_PM_CAP_ID                                     ( VF1_PM_CAP_ID ),
    .VF1_PM_CAP_NEXTPTR                                ( VF1_PM_CAP_NEXTPTR ),
    .VF1_PM_CAP_VER_ID                                 ( VF1_PM_CAP_VER_ID ),
    .VF2_MSIX_CAP_PBA_BIR                              ( VF2_MSIX_CAP_PBA_BIR ),
    .VF2_MSIX_CAP_PBA_OFFSET                           ( VF2_MSIX_CAP_PBA_OFFSET ),
    .VF2_MSIX_CAP_TABLE_BIR                            ( VF2_MSIX_CAP_TABLE_BIR ),
    .VF2_MSIX_CAP_TABLE_OFFSET                         ( VF2_MSIX_CAP_TABLE_OFFSET ),
    .VF2_MSIX_CAP_TABLE_SIZE                           ( VF2_MSIX_CAP_TABLE_SIZE ),
    .VF2_MSI_CAP_MULTIMSGCAP                           ( VF2_MSI_CAP_MULTIMSGCAP ),
    .VF2_PM_CAP_ID                                     ( VF2_PM_CAP_ID ),
    .VF2_PM_CAP_NEXTPTR                                ( VF2_PM_CAP_NEXTPTR ),
    .VF2_PM_CAP_VER_ID                                 ( VF2_PM_CAP_VER_ID ),
    .VF3_MSIX_CAP_PBA_BIR                              ( VF3_MSIX_CAP_PBA_BIR ),
    .VF3_MSIX_CAP_PBA_OFFSET                           ( VF3_MSIX_CAP_PBA_OFFSET ),
    .VF3_MSIX_CAP_TABLE_BIR                            ( VF3_MSIX_CAP_TABLE_BIR ),
    .VF3_MSIX_CAP_TABLE_OFFSET                         ( VF3_MSIX_CAP_TABLE_OFFSET ),
    .VF3_MSIX_CAP_TABLE_SIZE                           ( VF3_MSIX_CAP_TABLE_SIZE ),
    .VF3_MSI_CAP_MULTIMSGCAP                           ( VF3_MSI_CAP_MULTIMSGCAP ),
    .VF3_PM_CAP_ID                                     ( VF3_PM_CAP_ID ),
    .VF3_PM_CAP_NEXTPTR                                ( VF3_PM_CAP_NEXTPTR ),
    .VF3_PM_CAP_VER_ID                                 ( VF3_PM_CAP_VER_ID ),
    .VF4_MSIX_CAP_PBA_BIR                              ( VF4_MSIX_CAP_PBA_BIR ),
    .VF4_MSIX_CAP_PBA_OFFSET                           ( VF4_MSIX_CAP_PBA_OFFSET ),
    .VF4_MSIX_CAP_TABLE_BIR                            ( VF4_MSIX_CAP_TABLE_BIR ),
    .VF4_MSIX_CAP_TABLE_OFFSET                         ( VF4_MSIX_CAP_TABLE_OFFSET ),
    .VF4_MSIX_CAP_TABLE_SIZE                           ( VF4_MSIX_CAP_TABLE_SIZE ),
    .VF4_MSI_CAP_MULTIMSGCAP                           ( VF4_MSI_CAP_MULTIMSGCAP ),
    .VF4_PM_CAP_ID                                     ( VF4_PM_CAP_ID ),
    .VF4_PM_CAP_NEXTPTR                                ( VF4_PM_CAP_NEXTPTR ),
    .VF4_PM_CAP_VER_ID                                 ( VF4_PM_CAP_VER_ID ),
    .VF5_MSIX_CAP_PBA_BIR                              ( VF5_MSIX_CAP_PBA_BIR ),
    .VF5_MSIX_CAP_PBA_OFFSET                           ( VF5_MSIX_CAP_PBA_OFFSET ),
    .VF5_MSIX_CAP_TABLE_BIR                            ( VF5_MSIX_CAP_TABLE_BIR ),
    .VF5_MSIX_CAP_TABLE_OFFSET                         ( VF5_MSIX_CAP_TABLE_OFFSET ),
    .VF5_MSIX_CAP_TABLE_SIZE                           ( VF5_MSIX_CAP_TABLE_SIZE ),
    .VF5_MSI_CAP_MULTIMSGCAP                           ( VF5_MSI_CAP_MULTIMSGCAP ),
    .VF5_PM_CAP_ID                                     ( VF5_PM_CAP_ID ),
    .VF5_PM_CAP_NEXTPTR                                ( VF5_PM_CAP_NEXTPTR ),
    .VF5_PM_CAP_VER_ID                                 ( VF5_PM_CAP_VER_ID ),
    .IMPL_TARGET                                       ( IMPL_TARGET ),
    .NO_DECODE_LOGIC                                   ( NO_DECODE_LOGIC ),
    .INTERFACE_SPEED                                   ( INTERFACE_SPEED ),
    .COMPLETION_SPACE                                  ( COMPLETION_SPACE )
  )
  pcie_7vx_i(
    .CFGERRCOROUT                                      ( cfg_err_cor_out ),
    .CFGERRFATALOUT                                    ( cfg_err_fatal_out ),
    .CFGERRNONFATALOUT                                 ( cfg_err_nonfatal_out ),
    .CFGEXTREADRECEIVED                                ( cfg_ext_read_received ),
    .CFGEXTWRITERECEIVED                               ( cfg_ext_write_received ),
    .CFGHOTRESETOUT                                    ( cfg_hot_reset_out ),
    .CFGINPUTUPDATEDONE                                ( cfg_input_update_done ),
    .CFGINTERRUPTAOUTPUT                               (  ),
    .CFGINTERRUPTBOUTPUT                               (  ),
    .CFGINTERRUPTCOUTPUT                               (  ),
    .CFGINTERRUPTDOUTPUT                               (  ),
    .CFGINTERRUPTMSIFAIL                               ( cfg_interrupt_msi_fail ),
    .CFGINTERRUPTMSIMASKUPDATE                         ( cfg_interrupt_msi_mask_update ),
    .CFGINTERRUPTMSISENT                               ( cfg_interrupt_msi_sent ),
    .CFGINTERRUPTMSIXFAIL                              ( cfg_interrupt_msix_fail ),
    .CFGINTERRUPTMSIXSENT                              ( cfg_interrupt_msix_sent ),
    .CFGINTERRUPTSENT                                  ( cfg_interrupt_sent ),
    .CFGLOCALERROR                                     ( cfg_local_error ),
    .CFGLTRENABLE                                      ( cfg_ltr_enable ),
    .CFGMCUPDATEDONE                                   ( cfg_mc_update_done ),
    .CFGMGMTREADWRITEDONE                              ( cfg_mgmt_read_write_done ),
    .CFGMSGRECEIVED                                    ( cfg_msg_received ),
    .CFGMSGTRANSMITDONE                                ( cfg_msg_transmit_done ),
    .CFGPERFUNCTIONUPDATEDONE                          ( cfg_per_function_update_done ),
    .CFGPHYLINKDOWN                                    ( cfg_phy_link_down ),
    .CFGPLSTATUSCHANGE                                 ( cfg_pl_status_change ),
    .CFGPOWERSTATECHANGEINTERRUPT                      ( cfg_power_state_change_interrupt ),
    .CFGTPHSTTREADENABLE                               ( cfg_tph_stt_read_enable ),
    .CFGTPHSTTWRITEENABLE                              ( cfg_tph_stt_write_enable ),
    .DRPRDY                                            ( drp_rdy ),
    .MAXISCQTLAST                                      ( m_axis_cq_tlast ),
    .MAXISCQTVALID                                     ( m_axis_cq_tvalid ),
    .MAXISRCTLAST                                      ( m_axis_rc_tlast ),
    .MAXISRCTVALID                                     ( m_axis_rc_tvalid ),
    .PCIERQSEQNUMVLD                                   ( pcie_rq_seq_num_vld ),
    .PCIERQTAGVLD                                      ( pcie_rq_tag_vld ),
    .PIPERX0POLARITY                                   ( pipe_rx0_polarity ),
    .PIPERX1POLARITY                                   ( pipe_rx1_polarity ),
    .PIPERX2POLARITY                                   ( pipe_rx2_polarity ),
    .PIPERX3POLARITY                                   ( pipe_rx3_polarity ),
    .PIPERX4POLARITY                                   ( pipe_rx4_polarity ),
    .PIPERX5POLARITY                                   ( pipe_rx5_polarity ),
    .PIPERX6POLARITY                                   ( pipe_rx6_polarity ),
    .PIPERX7POLARITY                                   ( pipe_rx7_polarity ),
    .PIPETX0COMPLIANCE                                 ( pipe_tx0_compliance ),
    .PIPETX1COMPLIANCE                                 ( pipe_tx1_compliance ),
    .PIPETX2COMPLIANCE                                 ( pipe_tx2_compliance ),
    .PIPETX3COMPLIANCE                                 ( pipe_tx3_compliance ),
    .PIPETX4COMPLIANCE                                 ( pipe_tx4_compliance ),
    .PIPETX5COMPLIANCE                                 ( pipe_tx5_compliance ),
    .PIPETX6COMPLIANCE                                 ( pipe_tx6_compliance ),
    .PIPETX7COMPLIANCE                                 ( pipe_tx7_compliance ),
    .PIPETXDEEMPH                                      ( pipe_tx_deemph ),
    .PIPETXRCVRDET                                     ( pipe_tx_rcvr_det ),
    .PIPETXRESET                                       ( pipe_tx_reset ),
    .PIPETXSWING                                       ( pipe_tx_swing ),
    .PLEQINPROGRESS                                    (  ),
    .CFGFCCPLD                                         ( cfg_fc_cpld ),
    .CFGFCNPD                                          ( cfg_fc_npd ),
    .CFGFCPD                                           ( cfg_fc_pd ),
    .CFGVFSTATUS                                       ( cfg_vf_status ),
    .CFGPERFUNCSTATUSDATA                              ( cfg_per_func_status_data ),
    .DBGDATAOUT                                        (  ),
    .DRPDO                                             ( drp_do ),
    .CFGVFPOWERSTATE                                   ( cfg_vf_power_state ),
    .CFGVFTPHSTMODE                                    ( cfg_vf_tph_st_mode ),
    .CFGDPASUBSTATECHANGE                              ( cfg_dpa_substate_change ),
    .CFGFLRINPROCESS                                   ( cfg_flr_in_process ),
    .CFGINTERRUPTMSIENABLE                             ( cfg_interrupt_msi_enable ),
    .CFGINTERRUPTMSIXENABLE                            ( cfg_interrupt_msix_enable ),
    .CFGINTERRUPTMSIXMASK                              ( cfg_interrupt_msix_mask ),
    .CFGLINKPOWERSTATE                                 ( cfg_link_power_state ),
    .CFGOBFFENABLE                                     ( cfg_obff_enable ),
    .CFGPHYLINKSTATUS                                  ( cfg_phy_link_status ),
    .CFGRCBSTATUS                                      ( cfg_rcb_status ),
    .CFGTPHREQUESTERENABLE                             ( cfg_tph_requester_enable ),
    .PCIETFCNPDAV                                      ( pcie_tfc_npd_av ),
    .PCIETFCNPHAV                                      ( pcie_tfc_nph_av ),
    .PIPERX0EQCONTROL                                  ( pipe_rx0_eqcontrol_pcie ),
    .PIPERX1EQCONTROL                                  ( pipe_rx1_eqcontrol_pcie ),
    .PIPERX2EQCONTROL                                  ( pipe_rx2_eqcontrol_pcie ),
    .PIPERX3EQCONTROL                                  ( pipe_rx3_eqcontrol_pcie ),
    .PIPERX4EQCONTROL                                  ( pipe_rx4_eqcontrol_pcie ),
    .PIPERX5EQCONTROL                                  ( pipe_rx5_eqcontrol_pcie ),
    .PIPERX6EQCONTROL                                  ( pipe_rx6_eqcontrol_pcie ),
    .PIPERX7EQCONTROL                                  ( pipe_rx7_eqcontrol_pcie ),
    .PIPETX0CHARISK                                    ( pipe_tx0_char_is_k ),
    .PIPETX0EQCONTROL                                  ( pipe_tx0_eqcontrol ),
    .PIPETX0POWERDOWN                                  ( pipe_tx0_powerdown ),
    .PIPETX0SYNCHEADER                                 ( pipe_tx0_syncheader ),
    .PIPETX1CHARISK                                    ( pipe_tx1_char_is_k ),
    .PIPETX1EQCONTROL                                  ( pipe_tx1_eqcontrol ),
    .PIPETX1POWERDOWN                                  ( pipe_tx1_powerdown ),
    .PIPETX1SYNCHEADER                                 ( pipe_tx1_syncheader ),
    .PIPETX2CHARISK                                    ( pipe_tx2_char_is_k ),
    .PIPETX2EQCONTROL                                  ( pipe_tx2_eqcontrol ),
    .PIPETX2POWERDOWN                                  ( pipe_tx2_powerdown ),
    .PIPETX2SYNCHEADER                                 ( pipe_tx2_syncheader ),
    .PIPETX3CHARISK                                    ( pipe_tx3_char_is_k ),
    .PIPETX3EQCONTROL                                  ( pipe_tx3_eqcontrol ),
    .PIPETX3POWERDOWN                                  ( pipe_tx3_powerdown ),
    .PIPETX3SYNCHEADER                                 ( pipe_tx3_syncheader ),
    .PIPETX4CHARISK                                    ( pipe_tx4_char_is_k ),
    .PIPETX4EQCONTROL                                  ( pipe_tx4_eqcontrol ),
    .PIPETX4POWERDOWN                                  ( pipe_tx4_powerdown ),
    .PIPETX4SYNCHEADER                                 ( pipe_tx4_syncheader ),
    .PIPETX5CHARISK                                    ( pipe_tx5_char_is_k ),
    .PIPETX5EQCONTROL                                  ( pipe_tx5_eqcontrol ),
    .PIPETX5POWERDOWN                                  ( pipe_tx5_powerdown ),
    .PIPETX5SYNCHEADER                                 ( pipe_tx5_syncheader ),
    .PIPETX6CHARISK                                    ( pipe_tx6_char_is_k ),
    .PIPETX6EQCONTROL                                  ( pipe_tx6_eqcontrol ),
    .PIPETX6POWERDOWN                                  ( pipe_tx6_powerdown ),
    .PIPETX6SYNCHEADER                                 ( pipe_tx6_syncheader ),
    .PIPETX7CHARISK                                    ( pipe_tx7_char_is_k ),
    .PIPETX7EQCONTROL                                  ( pipe_tx7_eqcontrol ),
    .PIPETX7POWERDOWN                                  ( pipe_tx7_powerdown ),
    .PIPETX7SYNCHEADER                                 ( pipe_tx7_syncheader ),
    .PIPETXRATE                                        ( pipe_tx_rate ),
    .PLEQPHASE                                         (  ),
    .MAXISCQTDATA                                      ( m_axis_cq_tdata_256 ),
    .MAXISRCTDATA                                      ( m_axis_rc_tdata_256 ),
    .CFGCURRENTSPEED                                   ( cfg_current_speed ),
    .CFGMAXPAYLOAD                                     ( cfg_max_payload ),
    .CFGMAXREADREQ                                     ( cfg_max_read_req ),
    .CFGTPHFUNCTIONNUM                                 ( cfg_tph_function_num ),
    .PIPERX0EQPRESET                                   ( pipe_rx0_eqpreset ),
    .PIPERX1EQPRESET                                   ( pipe_rx1_eqpreset ),
    .PIPERX2EQPRESET                                   ( pipe_rx2_eqpreset ),
    .PIPERX3EQPRESET                                   ( pipe_rx3_eqpreset ),
    .PIPERX4EQPRESET                                   ( pipe_rx4_eqpreset ),
    .PIPERX5EQPRESET                                   ( pipe_rx5_eqpreset ),
    .PIPERX6EQPRESET                                   ( pipe_rx6_eqpreset ),
    .PIPERX7EQPRESET                                   ( pipe_rx7_eqpreset ),
    .PIPETXMARGIN                                      ( pipe_tx_margin ),
    .CFGEXTWRITEDATA                                   ( cfg_ext_write_data ),
    .CFGINTERRUPTMSIDATA                               ( cfg_interrupt_msi_data ),
    .CFGMGMTREADDATA                                   ( cfg_mgmt_read_data ),
    .CFGTPHSTTWRITEDATA                                ( cfg_tph_stt_write_data ),
    .PIPETX0DATA                                       ( pipe_tx0_data ),
    .PIPETX1DATA                                       ( pipe_tx1_data ),
    .PIPETX2DATA                                       ( pipe_tx2_data ),
    .PIPETX3DATA                                       ( pipe_tx3_data ),
    .PIPETX4DATA                                       ( pipe_tx4_data ),
    .PIPETX5DATA                                       ( pipe_tx5_data ),
    .PIPETX6DATA                                       ( pipe_tx6_data ),
    .PIPETX7DATA                                       ( pipe_tx7_data ),
    .PIPETX0DATAVALID                                  ( pipe_tx0_data_valid ),
    .PIPETX1DATAVALID                                  ( pipe_tx1_data_valid ),
    .PIPETX2DATAVALID                                  ( pipe_tx2_data_valid ),
    .PIPETX3DATAVALID                                  ( pipe_tx3_data_valid ),
    .PIPETX4DATAVALID                                  ( pipe_tx4_data_valid ),
    .PIPETX5DATAVALID                                  ( pipe_tx5_data_valid ),
    .PIPETX6DATAVALID                                  ( pipe_tx6_data_valid ),
    .PIPETX7DATAVALID                                  ( pipe_tx7_data_valid ),
    .PIPETX0ELECIDLE                                   ( pipe_tx0_elec_idle ),
    .PIPETX1ELECIDLE                                   ( pipe_tx1_elec_idle ),
    .PIPETX2ELECIDLE                                   ( pipe_tx2_elec_idle ),
    .PIPETX3ELECIDLE                                   ( pipe_tx3_elec_idle ),
    .PIPETX4ELECIDLE                                   ( pipe_tx4_elec_idle ),
    .PIPETX5ELECIDLE                                   ( pipe_tx5_elec_idle ),
    .PIPETX6ELECIDLE                                   ( pipe_tx6_elec_idle ),
    .PIPETX7ELECIDLE                                   ( pipe_tx7_elec_idle ),
    .PIPETX0STARTBLOCK                                 ( pipe_tx0_start_block ),
    .PIPETX1STARTBLOCK                                 ( pipe_tx1_start_block ),
    .PIPETX2STARTBLOCK                                 ( pipe_tx2_start_block ),
    .PIPETX3STARTBLOCK                                 ( pipe_tx3_start_block ),
    .PIPETX4STARTBLOCK                                 ( pipe_tx4_start_block ),
    .PIPETX5STARTBLOCK                                 ( pipe_tx5_start_block ),
    .PIPETX6STARTBLOCK                                 ( pipe_tx6_start_block ),
    .PIPETX7STARTBLOCK                                 ( pipe_tx7_start_block ),
    .CFGEXTWRITEBYTEENABLE                             ( cfg_ext_write_byte_enable ),
    .CFGNEGOTIATEDWIDTH                                ( cfg_negotiated_width ),
    .CFGTPHSTTWRITEBYTEVALID                           ( cfg_tph_stt_write_byte_valid ),
    .PCIERQSEQNUM                                      ( pcie_rq_seq_num ),
    .PIPERX0EQLPTXPRESET                               ( pipe_rx0_eqlp_txpreset ),
    .PIPERX1EQLPTXPRESET                               ( pipe_rx1_eqlp_txpreset ),
    .PIPERX2EQLPTXPRESET                               ( pipe_rx2_eqlp_txpreset ),
    .PIPERX3EQLPTXPRESET                               ( pipe_rx3_eqlp_txpreset ),
    .PIPERX4EQLPTXPRESET                               ( pipe_rx4_eqlp_txpreset ),
    .PIPERX5EQLPTXPRESET                               ( pipe_rx5_eqlp_txpreset ),
    .PIPERX6EQLPTXPRESET                               ( pipe_rx6_eqlp_txpreset ),
    .PIPERX7EQLPTXPRESET                               ( pipe_rx7_eqlp_txpreset ),
    .PIPETX0EQPRESET                                   ( pipe_tx0_eqpreset ),
    .PIPETX1EQPRESET                                   ( pipe_tx1_eqpreset ),
    .PIPETX2EQPRESET                                   ( pipe_tx2_eqpreset ),
    .PIPETX3EQPRESET                                   ( pipe_tx3_eqpreset ),
    .PIPETX4EQPRESET                                   ( pipe_tx4_eqpreset ),
    .PIPETX5EQPRESET                                   ( pipe_tx5_eqpreset ),
    .PIPETX6EQPRESET                                   ( pipe_tx6_eqpreset ),
    .PIPETX7EQPRESET                                   ( pipe_tx7_eqpreset ),
    .SAXISCCTREADY                                     ( s_axis_cc_tready ),
    .SAXISRQTREADY                                     ( s_axis_rq_tready ),
    .CFGMSGRECEIVEDTYPE                                ( cfg_msg_received_type ),
    .CFGTPHSTTADDRESS                                  ( cfg_tph_stt_address ),
    .CFGFUNCTIONPOWERSTATE                             ( cfg_function_power_state ),
    .CFGINTERRUPTMSIMMENABLE                           ( cfg_interrupt_msi_mmenable ),
    .CFGINTERRUPTMSIVFENABLE                           ( cfg_interrupt_msi_vf_enable ),
    .CFGINTERRUPTMSIXVFENABLE                          ( cfg_interrupt_msix_vf_enable ),
    .CFGINTERRUPTMSIXVFMASK                            ( cfg_interrupt_msix_vf_mask ),
    .CFGLTSSMSTATE                                     ( cfg_ltssm_state ),
    .CFGTPHSTMODE                                      ( cfg_tph_st_mode ),
    .CFGVFFLRINPROCESS                                 ( cfg_vf_flr_in_process ),
    .CFGVFTPHREQUESTERENABLE                           ( cfg_vf_tph_requester_enable ),
    .PCIECQNPREQCOUNT                                  ( pcie_cq_np_req_count ),
    .PCIERQTAG                                         ( pcie_rq_tag ),
    .PIPERX0EQLPLFFS                                   ( pipe_rx0_eqlp_lffs ),
    .PIPERX1EQLPLFFS                                   ( pipe_rx1_eqlp_lffs ),
    .PIPERX2EQLPLFFS                                   ( pipe_rx2_eqlp_lffs ),
    .PIPERX3EQLPLFFS                                   ( pipe_rx3_eqlp_lffs ),
    .PIPERX4EQLPLFFS                                   ( pipe_rx4_eqlp_lffs ),
    .PIPERX5EQLPLFFS                                   ( pipe_rx5_eqlp_lffs ),
    .PIPERX6EQLPLFFS                                   ( pipe_rx6_eqlp_lffs ),
    .PIPERX7EQLPLFFS                                   ( pipe_rx7_eqlp_lffs ),
    .PIPETX0EQDEEMPH                                   ( pipe_tx0_eqdeemph ),
    .PIPETX1EQDEEMPH                                   ( pipe_tx1_eqdeemph ),
    .PIPETX2EQDEEMPH                                   ( pipe_tx2_eqdeemph ),
    .PIPETX3EQDEEMPH                                   ( pipe_tx3_eqdeemph ),
    .PIPETX4EQDEEMPH                                   ( pipe_tx4_eqdeemph ),
    .PIPETX5EQDEEMPH                                   ( pipe_tx5_eqdeemph ),
    .PIPETX6EQDEEMPH                                   ( pipe_tx6_eqdeemph ),
    .PIPETX7EQDEEMPH                                   ( pipe_tx7_eqdeemph ),
    .MAXISRCTUSER                                      ( m_axis_rc_tuser ),
    .CFGEXTFUNCTIONNUMBER                              ( cfg_ext_function_number ),
    .CFGFCCPLH                                         ( cfg_fc_cplh ),
    .CFGFCNPH                                          ( cfg_fc_nph ),
    .CFGFCPH                                           ( cfg_fc_ph ),
    .CFGFUNCTIONSTATUS                                 ( cfg_function_status ),
    .CFGMSGRECEIVEDDATA                                ( cfg_msg_received_data ),
    .MAXISCQTKEEP                                      ( m_axis_cq_tkeep_w ),
    .MAXISRCTKEEP                                      ( m_axis_rc_tkeep_w ),
    .PLGEN3PCSRXSLIDE                                  ( pipe_rx_slide ),
    .MAXISCQTUSER                                      ( m_axis_cq_tuser ),
    .CFGEXTREGISTERNUMBER                              ( cfg_ext_register_number ),
    .CFGCONFIGSPACEENABLE                              ( cfg_config_space_enable ),
    .CFGERRCORIN                                       ( cfg_err_cor_in ),
    .CFGERRUNCORIN                                     ( cfg_err_uncor_in ),
    .CFGEXTREADDATAVALID                               ( cfg_ext_read_data_valid ),
    .CFGHOTRESETIN                                     ( cfg_hot_reset_in ),
    .CFGINPUTUPDATEREQUEST                             ( cfg_input_update_request ),
    .CFGINTERRUPTMSITPHPRESENT                         ( cfg_interrupt_msi_tph_present ),
    .CFGINTERRUPTMSIXINT                               ( cfg_interrupt_msix_int ),
    .CFGLINKTRAININGENABLE                             ( cfg_link_training_enable ),
    .CFGMCUPDATEREQUEST                                ( cfg_mc_update_request ),
    .CFGMGMTREAD                                       ( cfg_mgmt_read ),
    .CFGMGMTTYPE1CFGREGACCESS                          ( cfg_mgmt_type1_cfg_reg_access ),
    .CFGMGMTWRITE                                      ( cfg_mgmt_write ),
    .CFGMSGTRANSMIT                                    ( cfg_msg_transmit ),
    .CFGPERFUNCTIONOUTPUTREQUEST                       ( cfg_per_function_output_request ),
    .CFGPOWERSTATECHANGEACK                            ( cfg_power_state_change_ack ),
    .CFGREQPMTRANSITIONL23READY                        ( cfg_req_pm_transition_l23_ready ),
    .CFGTPHSTTREADDATAVALID                            ( cfg_tph_stt_read_data_valid ),
    .CORECLK                                           ( core_clk ),  // 250MHz for 5.0GT/s.  500MHz for 8.0GT/s
    .CORECLKMICOMPLETIONRAML                           ( core_clk ),
    .CORECLKMICOMPLETIONRAMU                           ( core_clk ),
    .CORECLKMIREPLAYRAM                                ( core_clk ),
    .CORECLKMIREQUESTRAM                               ( core_clk ),
    .DRPCLK                                            ( drp_clk ),
    .DRPEN                                             ( drp_en ),
    .DRPWE                                             ( drp_we ),
    .MGMTRESETN                                        ( mgmt_reset_n ),
    .MGMTSTICKYRESETN                                  ( mgmt_sticky_reset_n ),
    .PCIECQNPREQ                                       ( pcie_cq_np_req ),
    .PIPECLK                                           ( pipe_clk ),
    .PIPERESETN                                        ( pipe_reset_n ),
    .PIPERX0DATAVALID                                  ( pipe_rx0_data_valid ),
    .PIPERX0ELECIDLE                                   ( pipe_rx0_elec_idle ),
    .PIPERX0EQDONE                                     ( pipe_rx0_eqdone ),
    .PIPERX0EQLPADAPTDONE                              ( pipe_rx0_eqlp_adaptdone ),
    .PIPERX0EQLPLFFSSEL                                ( pipe_rx0_eqlp_lffs_sel ),
    .PIPERX0PHYSTATUS                                  ( pipe_rx0_phy_status ),
    .PIPERX0STARTBLOCK                                 ( pipe_rx0_start_block ),
    .PIPERX0VALID                                      ( pipe_rx0_valid ),
    .PIPERX1DATAVALID                                  ( pipe_rx1_data_valid ),
    .PIPERX1ELECIDLE                                   ( pipe_rx1_elec_idle ),
    .PIPERX1EQDONE                                     ( pipe_rx1_eqdone ),
    .PIPERX1EQLPADAPTDONE                              ( pipe_rx1_eqlp_adaptdone ),
    .PIPERX1EQLPLFFSSEL                                ( pipe_rx1_eqlp_lffs_sel ),
    .PIPERX1PHYSTATUS                                  ( pipe_rx1_phy_status ),
    .PIPERX1STARTBLOCK                                 ( pipe_rx1_start_block ),
    .PIPERX1VALID                                      ( pipe_rx1_valid ),
    .PIPERX2DATAVALID                                  ( pipe_rx2_data_valid ),
    .PIPERX2ELECIDLE                                   ( pipe_rx2_elec_idle ),
    .PIPERX2EQDONE                                     ( pipe_rx2_eqdone ),
    .PIPERX2EQLPADAPTDONE                              ( pipe_rx2_eqlp_adaptdone ),
    .PIPERX2EQLPLFFSSEL                                ( pipe_rx2_eqlp_lffs_sel ),
    .PIPERX2PHYSTATUS                                  ( pipe_rx2_phy_status ),
    .PIPERX2STARTBLOCK                                 ( pipe_rx2_start_block ),
    .PIPERX2VALID                                      ( pipe_rx2_valid ),
    .PIPERX3DATAVALID                                  ( pipe_rx3_data_valid ),
    .PIPERX3ELECIDLE                                   ( pipe_rx3_elec_idle ),
    .PIPERX3EQDONE                                     ( pipe_rx3_eqdone ),
    .PIPERX3EQLPADAPTDONE                              ( pipe_rx3_eqlp_adaptdone ),
    .PIPERX3EQLPLFFSSEL                                ( pipe_rx3_eqlp_lffs_sel ),
    .PIPERX3PHYSTATUS                                  ( pipe_rx3_phy_status ),
    .PIPERX3STARTBLOCK                                 ( pipe_rx3_start_block ),
    .PIPERX3VALID                                      ( pipe_rx3_valid ),
    .PIPERX4DATAVALID                                  ( pipe_rx4_data_valid ),
    .PIPERX4ELECIDLE                                   ( pipe_rx4_elec_idle ),
    .PIPERX4EQDONE                                     ( pipe_rx4_eqdone ),
    .PIPERX4EQLPADAPTDONE                              ( pipe_rx4_eqlp_adaptdone ),
    .PIPERX4EQLPLFFSSEL                                ( pipe_rx4_eqlp_lffs_sel ),
    .PIPERX4PHYSTATUS                                  ( pipe_rx4_phy_status ),
    .PIPERX4STARTBLOCK                                 ( pipe_rx4_start_block ),
    .PIPERX4VALID                                      ( pipe_rx4_valid ),
    .PIPERX5DATAVALID                                  ( pipe_rx5_data_valid ),
    .PIPERX5ELECIDLE                                   ( pipe_rx5_elec_idle ),
    .PIPERX5EQDONE                                     ( pipe_rx5_eqdone ),
    .PIPERX5EQLPADAPTDONE                              ( pipe_rx5_eqlp_adaptdone ),
    .PIPERX5EQLPLFFSSEL                                ( pipe_rx5_eqlp_lffs_sel ),
    .PIPERX5PHYSTATUS                                  ( pipe_rx5_phy_status ),
    .PIPERX5STARTBLOCK                                 ( pipe_rx5_start_block ),
    .PIPERX5VALID                                      ( pipe_rx5_valid ),
    .PIPERX6DATAVALID                                  ( pipe_rx6_data_valid ),
    .PIPERX6ELECIDLE                                   ( pipe_rx6_elec_idle ),
    .PIPERX6EQDONE                                     ( pipe_rx6_eqdone ),
    .PIPERX6EQLPADAPTDONE                              ( pipe_rx6_eqlp_adaptdone ),
    .PIPERX6EQLPLFFSSEL                                ( pipe_rx6_eqlp_lffs_sel ),
    .PIPERX6PHYSTATUS                                  ( pipe_rx6_phy_status ),
    .PIPERX6STARTBLOCK                                 ( pipe_rx6_start_block ),
    .PIPERX6VALID                                      ( pipe_rx6_valid ),
    .PIPERX7DATAVALID                                  ( pipe_rx7_data_valid ),
    .PIPERX7ELECIDLE                                   ( pipe_rx7_elec_idle ),
    .PIPERX7EQDONE                                     ( pipe_rx7_eqdone ),
    .PIPERX7EQLPADAPTDONE                              ( pipe_rx7_eqlp_adaptdone ),
    .PIPERX7EQLPLFFSSEL                                ( pipe_rx7_eqlp_lffs_sel ),
    .PIPERX7PHYSTATUS                                  ( pipe_rx7_phy_status ),
    .PIPERX7STARTBLOCK                                 ( pipe_rx7_start_block ),
    .PIPERX7VALID                                      ( pipe_rx7_valid ),
    .PIPETX0EQDONE                                     ( pipe_tx0_eqdone ),
    .PIPETX1EQDONE                                     ( pipe_tx1_eqdone ),
    .PIPETX2EQDONE                                     ( pipe_tx2_eqdone ),
    .PIPETX3EQDONE                                     ( pipe_tx3_eqdone ),
    .PIPETX4EQDONE                                     ( pipe_tx4_eqdone ),
    .PIPETX5EQDONE                                     ( pipe_tx5_eqdone ),
    .PIPETX6EQDONE                                     ( pipe_tx6_eqdone ),
    .PIPETX7EQDONE                                     ( pipe_tx7_eqdone ),
    .PLDISABLESCRAMBLER                                ( 1'b0 ),
    .PLEQRESETEIEOSCOUNT                               ( 1'b0 ),
    .PLGEN3PCSDISABLE                                  ( gen3pcsdisable ),
    .RECCLK                                            ( rec_clk ),
    .RESETN                                            ( reset_n ),
    .SAXISCCTLAST                                      ( s_axis_cc_tlast ),
    .SAXISCCTVALID                                     ( s_axis_cc_tvalid ),
    .SAXISRQTLAST                                      ( s_axis_rq_tlast ),
    .SAXISRQTVALID                                     ( s_axis_rq_tvalid ),
    .USERCLK                                           ( user_clk ),
    .DRPADDR                                           ( drp_addr ),
    .CFGDEVID                                          ( cfg_dev_id ),
    .CFGSUBSYSID                                       ( cfg_subsys_id ),
    .CFGSUBSYSVENDID                                   ( cfg_subsys_vend_id ),
    .CFGVENDID                                         ( cfg_vend_id ),
    .DRPDI                                             ( drp_di ),
    .PIPERX0EQLPNEWTXCOEFFORPRESET                     ( pipe_rx0_eqlp_new_txcoef_forpreset ),
    .PIPERX1EQLPNEWTXCOEFFORPRESET                     ( pipe_rx1_eqlp_new_txcoef_forpreset ),
    .PIPERX2EQLPNEWTXCOEFFORPRESET                     ( pipe_rx2_eqlp_new_txcoef_forpreset ),
    .PIPERX3EQLPNEWTXCOEFFORPRESET                     ( pipe_rx3_eqlp_new_txcoef_forpreset ),
    .PIPERX4EQLPNEWTXCOEFFORPRESET                     ( pipe_rx4_eqlp_new_txcoef_forpreset ),
    .PIPERX5EQLPNEWTXCOEFFORPRESET                     ( pipe_rx5_eqlp_new_txcoef_forpreset ),
    .PIPERX6EQLPNEWTXCOEFFORPRESET                     ( pipe_rx6_eqlp_new_txcoef_forpreset ),
    .PIPERX7EQLPNEWTXCOEFFORPRESET                     ( pipe_rx7_eqlp_new_txcoef_forpreset ),
    .PIPETX0EQCOEFF                                    ( pipe_tx0_eqcoeff ),
    .PIPETX1EQCOEFF                                    ( pipe_tx1_eqcoeff ),
    .PIPETX2EQCOEFF                                    ( pipe_tx2_eqcoeff ),
    .PIPETX3EQCOEFF                                    ( pipe_tx3_eqcoeff ),
    .PIPETX4EQCOEFF                                    ( pipe_tx4_eqcoeff ),
    .PIPETX5EQCOEFF                                    ( pipe_tx5_eqcoeff ),
    .PIPETX6EQCOEFF                                    ( pipe_tx6_eqcoeff ),
    .PIPETX7EQCOEFF                                    ( pipe_tx7_eqcoeff ),
    .CFGMGMTADDR                                       ( cfg_mgmt_addr ),
    .CFGFLRDONE                                        ( cfg_flr_done ),
    .CFGINTERRUPTMSITPHTYPE                            ( cfg_interrupt_msi_tph_type ),
    .CFGINTERRUPTPENDING                               ( cfg_interrupt_pending ),
    .PIPERX0CHARISK                                    ( pipe_rx0_char_is_k ),
    .PIPERX0SYNCHEADER                                 ( pipe_rx0_syncheader ),
    .PIPERX1CHARISK                                    ( pipe_rx1_char_is_k ),
    .PIPERX1SYNCHEADER                                 ( pipe_rx1_syncheader ),
    .PIPERX2CHARISK                                    ( pipe_rx2_char_is_k ),
    .PIPERX2SYNCHEADER                                 ( pipe_rx2_syncheader ),
    .PIPERX3CHARISK                                    ( pipe_rx3_char_is_k ),
    .PIPERX3SYNCHEADER                                 ( pipe_rx3_syncheader ),
    .PIPERX4CHARISK                                    ( pipe_rx4_char_is_k ),
    .PIPERX4SYNCHEADER                                 ( pipe_rx4_syncheader ),
    .PIPERX5CHARISK                                    ( pipe_rx5_char_is_k ),
    .PIPERX5SYNCHEADER                                 ( pipe_rx5_syncheader ),
    .PIPERX6CHARISK                                    ( pipe_rx6_char_is_k ),
    .PIPERX6SYNCHEADER                                 ( pipe_rx6_syncheader ),
    .PIPERX7CHARISK                                    ( pipe_rx7_char_is_k ),
    .PIPERX7SYNCHEADER                                 ( pipe_rx7_syncheader ),
    .MAXISCQTREADY                                     ( m_axis_cq_tready ),
    .MAXISRCTREADY                                     ( m_axis_rc_tready ),
    .SAXISCCTDATA                                      ( s_axis_cc_tdata_256 ),
    .SAXISRQTDATA                                      ( s_axis_rq_tdata_256 ),
    .CFGDSFUNCTIONNUMBER                               ( cfg_ds_function_number ),
    .CFGFCSEL                                          ( cfg_fc_sel ),
    .CFGINTERRUPTMSIATTR                               ( cfg_interrupt_msi_attr ),
    .CFGINTERRUPTMSIFUNCTIONNUMBER                     ( cfg_interrupt_msi_function_number ),
    .CFGMSGTRANSMITTYPE                                ( cfg_msg_transmit_type ),
    .CFGPERFUNCSTATUSCONTROL                           ( cfg_per_func_status_control ),
    .CFGPERFUNCTIONNUMBER                              ( cfg_per_function_number ),
    .PIPERX0STATUS                                     ( pipe_rx0_status ),
    .PIPERX1STATUS                                     ( pipe_rx1_status ),
    .PIPERX2STATUS                                     ( pipe_rx2_status ),
    .PIPERX3STATUS                                     ( pipe_rx3_status ),
    .PIPERX4STATUS                                     ( pipe_rx4_status ),
    .PIPERX5STATUS                                     ( pipe_rx5_status ),
    .PIPERX6STATUS                                     ( pipe_rx6_status ),
    .PIPERX7STATUS                                     ( pipe_rx7_status ),
    .CFGEXTREADDATA                                    ( cfg_ext_read_data ),
    .CFGINTERRUPTMSIINT                                ( cfg_interrupt_msi_int ),
    .CFGINTERRUPTMSIXDATA                              ( cfg_interrupt_msix_data ),
    .CFGMGMTWRITEDATA                                  ( cfg_mgmt_write_data ),
    .CFGMSGTRANSMITDATA                                ( cfg_msg_transmit_data ),
    .CFGTPHSTTREADDATA                                 ( cfg_tph_stt_read_data ),
    .PIPERX0DATA                                       ( pipe_rx0_data_pcie ),
    .PIPERX1DATA                                       ( pipe_rx1_data_pcie ),
    .PIPERX2DATA                                       ( pipe_rx2_data_pcie ),
    .PIPERX3DATA                                       ( pipe_rx3_data_pcie ),
    .PIPERX4DATA                                       ( pipe_rx4_data_pcie ),
    .PIPERX5DATA                                       ( pipe_rx5_data_pcie ),
    .PIPERX6DATA                                       ( pipe_rx6_data_pcie ),
    .PIPERX7DATA                                       ( pipe_rx7_data_pcie ),
    .SAXISCCTUSER                                      ( s_axis_cc_tuser ),
    .CFGINTERRUPTINT                                   ( cfg_interrupt_int ),
    .CFGINTERRUPTMSISELECT                             ( cfg_interrupt_msi_select ),
    .CFGMGMTBYTEENABLE                                 ( cfg_mgmt_byte_enable ),
    .CFGDSDEVICENUMBER                                 ( cfg_ds_device_number ),
    .SAXISRQTUSER                                      ( s_axis_rq_tuser ),
    .CFGVFFLRDONE                                      ( cfg_vf_flr_done ),
    .PIPEEQFS                                          ( pipe_tx_eqfs ),
    .PIPEEQLF                                          ( pipe_tx_eqlf ),
    .CFGDSN                                            ( cfg_dsn ),
    .CFGINTERRUPTMSIPENDINGSTATUS                      ( cfg_interrupt_msi_pending_status ),
    .CFGINTERRUPTMSIXADDRESS                           ( cfg_interrupt_msix_address ),
    .CFGDSBUSNUMBER                                    ( cfg_ds_bus_number ),
    .CFGDSPORTNUMBER                                   ( cfg_ds_port_number ),
    .CFGREVID                                          ( cfg_rev_id ),
    .PLGEN3PCSRXSYNCDONE                               ( pipe_rx_syncdone ),
    .SAXISCCTKEEP                                      ( s_axis_cc_tkeep_w ),
    .SAXISRQTKEEP                                      ( s_axis_rq_tkeep_w ),
    .CFGINTERRUPTMSITPHSTTAG                           ( cfg_interrupt_msi_tph_st_tag )
  );

  //------------------------------------------------------------------------------------------------------------------//
  // Force Adapt for Gen3                                                                                  //
  //------------------------------------------------------------------------------------------------------------------//

  xdma_0_pcie3_ip_pcie_force_adapt force_adapt_i(
  .pipe_clk(pipe_clk),
  .user_clk(user_clk),
  .rx_clk(rec_clk),
  .cfg_ltssm_state(cfg_ltssm_state),  
  .cfg_current_speed(cfg_current_speed),
  .pipe_tx0_rate(pipe_tx_rate),
  .pipe_rx0_elec_idle(pipe_rx0_elec_idle),
  .pipe_rx0_eqlp_adaptdone(pipe_rx0_eqlp_adaptdone),
  .pipe_tx0_eqcontrol(pipe_tx0_eqcontrol), 
  .pipe_rx0_data_in(pipe_rx0_data),
  .pipe_rx1_data_in(pipe_rx1_data),
  .pipe_rx2_data_in(pipe_rx2_data),
  .pipe_rx3_data_in(pipe_rx3_data),
  .pipe_rx4_data_in(pipe_rx4_data),
  .pipe_rx5_data_in(pipe_rx5_data),
  .pipe_rx6_data_in(pipe_rx6_data),
  .pipe_rx7_data_in(pipe_rx7_data),
  .pipe_rx0_eqcontrol_in(pipe_rx0_eqcontrol_pcie),
  .pipe_rx1_eqcontrol_in(pipe_rx1_eqcontrol_pcie),
  .pipe_rx2_eqcontrol_in(pipe_rx2_eqcontrol_pcie),
  .pipe_rx3_eqcontrol_in(pipe_rx3_eqcontrol_pcie),
  .pipe_rx4_eqcontrol_in(pipe_rx4_eqcontrol_pcie),
  .pipe_rx5_eqcontrol_in(pipe_rx5_eqcontrol_pcie),
  .pipe_rx6_eqcontrol_in(pipe_rx6_eqcontrol_pcie),
  .pipe_rx7_eqcontrol_in(pipe_rx7_eqcontrol_pcie),
  .pipe_rx0_data_out(pipe_rx0_data_pcie),
  .pipe_rx1_data_out(pipe_rx1_data_pcie),
  .pipe_rx2_data_out(pipe_rx2_data_pcie),
  .pipe_rx3_data_out(pipe_rx3_data_pcie),
  .pipe_rx4_data_out(pipe_rx4_data_pcie),
  .pipe_rx5_data_out(pipe_rx5_data_pcie),
  .pipe_rx6_data_out(pipe_rx6_data_pcie),
  .pipe_rx7_data_out(pipe_rx7_data_pcie),   
  .pipe_rx0_eqcontrol_out(pipe_rx0_eqcontrol),
  .pipe_rx1_eqcontrol_out(pipe_rx1_eqcontrol),
  .pipe_rx2_eqcontrol_out(pipe_rx2_eqcontrol),
  .pipe_rx3_eqcontrol_out(pipe_rx3_eqcontrol),
  .pipe_rx4_eqcontrol_out(pipe_rx4_eqcontrol),
  .pipe_rx5_eqcontrol_out(pipe_rx5_eqcontrol),
  .pipe_rx6_eqcontrol_out(pipe_rx6_eqcontrol),
  .pipe_rx7_eqcontrol_out(pipe_rx7_eqcontrol)
);

  //------------------------------------------------------------------------------------------------------------------//
  // PIPE Interface PIPELINE Module                                                                                   //
  //------------------------------------------------------------------------------------------------------------------//
  xdma_0_pcie3_ip_pcie_pipe_pipeline #
  (
    .TCQ                     ( TCQ ),
    .LINK_CAP_MAX_LINK_WIDTH ( PL_LINK_CAP_MAX_LINK_WIDTH ),
    .PIPE_PIPELINE_STAGES    ( PIPE_PIPELINE_STAGES )
  )
  pcie_pipe_pipeline_i (

    // Pipe Per-Link Signals
    .pipe_tx_rcvr_det_i                  ( pipe_tx_rcvr_det ),
    .pipe_tx_reset_i                     ( pipe_tx_reset  ),
    .pipe_tx_rate_i                      ( pipe_tx_rate ),
    .pipe_tx_deemph_i                    ( pipe_tx_deemph ),
    .pipe_tx_margin_i                    ( pipe_tx_margin ),
    .pipe_tx_swing_i                     ( pipe_tx_swing ),
    .pipe_tx_eqfs_i                      ( pipe_tx_eqfs_gt ),
    .pipe_tx_eqlf_i                      ( pipe_tx_eqlf_gt ),

    .pipe_tx_rcvr_det_o                  ( pipe_tx_rcvr_det_gt ),
    .pipe_tx_reset_o                     ( pipe_tx_reset_gt ),
    .pipe_tx_rate_o                      ( pipe_tx_rate_gt ),
    .pipe_tx_deemph_o                    ( pipe_tx_deemph_gt ),
    .pipe_tx_margin_o                    ( pipe_tx_margin_gt ),
    .pipe_tx_swing_o                     ( pipe_tx_swing_gt ),
    .pipe_tx_eqfs_o                      ( pipe_tx_eqfs ),
    .pipe_tx_eqlf_o                      ( pipe_tx_eqlf ),

    // Pipe Per-Lane Signals
    .pipe_rxslide_i                      ( pipe_rx_slide ),
    .pipe_rxsyncdone_i                   ( pipe_rx_syncdone_gt ),
    .pipe_rxslide_o                      ( pipe_rx_slide_gt ),
    .pipe_rxsyncdone_o                   ( pipe_rx_syncdone ),

    // Pipe Per-Lane Signals - Lane 0
    .pipe_rx0_char_is_k_o                ( pipe_rx0_char_is_k ),
    .pipe_rx0_data_o                     ( pipe_rx0_data ),
    .pipe_rx0_valid_o                    ( pipe_rx0_valid ),
    .pipe_rx0_data_valid_o               ( pipe_rx0_data_valid ),
    .pipe_rx0_status_o                   ( pipe_rx0_status ),
    .pipe_rx0_phy_status_o               ( pipe_rx0_phy_status ),
    .pipe_rx0_elec_idle_o                ( pipe_rx0_elec_idle ),
    .pipe_rx0_eqdone_o                   ( pipe_rx0_eqdone ),
    .pipe_rx0_eqlpadaptdone_o            ( pipe_rx0_eqlp_adaptdone ),
    .pipe_rx0_eqlplffssel_o              ( pipe_rx0_eqlp_lffs_sel ),
    .pipe_rx0_eqlpnewtxcoefforpreset_o   ( pipe_rx0_eqlp_new_txcoef_forpreset ),
    .pipe_rx0_startblock_o               ( pipe_rx0_start_block ),
    .pipe_rx0_syncheader_o               ( pipe_rx0_syncheader ),
    .pipe_rx0_polarity_i                 ( pipe_rx0_polarity ),
    .pipe_rx0_eqcontrol_i                ( pipe_rx0_eqcontrol ),
    .pipe_rx0_eqlplffs_i                 ( pipe_rx0_eqlp_lffs ),
    .pipe_rx0_eqlptxpreset_i             ( pipe_rx0_eqlp_txpreset ),
    .pipe_rx0_eqpreset_i                 ( pipe_rx0_eqpreset ),
    .pipe_tx0_eqcoeff_o                  ( pipe_tx0_eqcoeff ),
    .pipe_tx0_eqdone_o                   ( pipe_tx0_eqdone ),
    .pipe_tx0_compliance_i               ( pipe_tx0_compliance ),
    .pipe_tx0_char_is_k_i                ( pipe_tx0_char_is_k ),
    .pipe_tx0_data_i                     ( pipe_tx0_data ),
    .pipe_tx0_elec_idle_i                ( pipe_tx0_elec_idle ),
    .pipe_tx0_powerdown_i                ( pipe_tx0_powerdown ),
    .pipe_tx0_datavalid_i                ( pipe_tx0_data_valid ),
    .pipe_tx0_startblock_i               ( pipe_tx0_start_block ),
    .pipe_tx0_syncheader_i               ( pipe_tx0_syncheader ),
    .pipe_tx0_eqcontrol_i                ( pipe_tx0_eqcontrol ),
    .pipe_tx0_eqdeemph_i                 ( pipe_tx0_eqdeemph ),
    .pipe_tx0_eqpreset_i                 ( pipe_tx0_eqpreset ),

    .pipe_rx0_char_is_k_i                ( pipe_rx0_char_is_k_gt ),
    .pipe_rx0_data_i                     ( pipe_rx0_data_gt ),
    .pipe_rx0_valid_i                    ( pipe_rx0_valid_gt ),
    .pipe_rx0_data_valid_i               ( pipe_rx0_data_valid_gt ),
    .pipe_rx0_status_i                   ( pipe_rx0_status_gt ),
    .pipe_rx0_phy_status_i               ( pipe_rx0_phy_status_gt ),
    .pipe_rx0_elec_idle_i                ( pipe_rx0_elec_idle_gt ),
    .pipe_rx0_eqdone_i                   ( pipe_rx0_eqdone_gt ),
    .pipe_rx0_eqlpadaptdone_i            ( pipe_rx0_eqlp_adaptdone_gt ),
    .pipe_rx0_eqlplffssel_i              ( pipe_rx0_eqlp_lffs_sel_gt ),
    .pipe_rx0_eqlpnewtxcoefforpreset_i   ( pipe_rx0_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx0_startblock_i               ( pipe_rx0_start_block_gt ),
    .pipe_rx0_syncheader_i               ( pipe_rx0_syncheader_gt ),
    .pipe_rx0_polarity_o                 ( pipe_rx0_polarity_gt ),
    .pipe_rx0_eqcontrol_o                ( pipe_rx0_eqcontrol_gt ),
    .pipe_rx0_eqlplffs_o                 ( pipe_rx0_eqlp_lffs_gt ),
    .pipe_rx0_eqlptxpreset_o             ( pipe_rx0_eqlp_txpreset_gt ),
    .pipe_rx0_eqpreset_o                 ( pipe_rx0_eqpreset_gt ),
    .pipe_tx0_eqcoeff_i                  ( pipe_tx0_eqcoeff_gt ),
    .pipe_tx0_eqdone_i                   ( pipe_tx0_eqdone_gt ),
    .pipe_tx0_compliance_o               ( pipe_tx0_compliance_gt ),
    .pipe_tx0_char_is_k_o                ( pipe_tx0_char_is_k_gt ),
    .pipe_tx0_data_o                     ( pipe_tx0_data_gt ),
    .pipe_tx0_elec_idle_o                ( pipe_tx0_elec_idle_gt ),
    .pipe_tx0_powerdown_o                ( pipe_tx0_powerdown_gt ),
    .pipe_tx0_datavalid_o                ( pipe_tx0_data_valid_gt ),
    .pipe_tx0_startblock_o               ( pipe_tx0_start_block_gt ),
    .pipe_tx0_syncheader_o               ( pipe_tx0_syncheader_gt ),
    .pipe_tx0_eqcontrol_o                ( pipe_tx0_eqcontrol_gt ),
    .pipe_tx0_eqdeemph_o                 ( pipe_tx0_eqdeemph_gt ),
    .pipe_tx0_eqpreset_o                 ( pipe_tx0_eqpreset_gt ),

    // Pipe Per-Lane Signals - Lane 1
    .pipe_rx1_char_is_k_o                ( pipe_rx1_char_is_k ),
    .pipe_rx1_data_o                     ( pipe_rx1_data ),
    .pipe_rx1_valid_o                    ( pipe_rx1_valid ),
    .pipe_rx1_data_valid_o               ( pipe_rx1_data_valid ),
    .pipe_rx1_status_o                   ( pipe_rx1_status ),
    .pipe_rx1_phy_status_o               ( pipe_rx1_phy_status ),
    .pipe_rx1_elec_idle_o                ( pipe_rx1_elec_idle ),
    .pipe_rx1_eqdone_o                   ( pipe_rx1_eqdone ),
    .pipe_rx1_eqlpadaptdone_o            ( pipe_rx1_eqlp_adaptdone ),
    .pipe_rx1_eqlplffssel_o              ( pipe_rx1_eqlp_lffs_sel ),
    .pipe_rx1_eqlpnewtxcoefforpreset_o   ( pipe_rx1_eqlp_new_txcoef_forpreset ),
    .pipe_rx1_startblock_o               ( pipe_rx1_start_block ),
    .pipe_rx1_syncheader_o               ( pipe_rx1_syncheader ),
    .pipe_rx1_polarity_i                 ( pipe_rx1_polarity ),
    .pipe_rx1_eqcontrol_i                ( pipe_rx1_eqcontrol ),
    .pipe_rx1_eqlplffs_i                 ( pipe_rx1_eqlp_lffs ),
    .pipe_rx1_eqlptxpreset_i             ( pipe_rx1_eqlp_txpreset ),
    .pipe_rx1_eqpreset_i                 ( pipe_rx1_eqpreset ),
    .pipe_tx1_eqcoeff_o                  ( pipe_tx1_eqcoeff ),
    .pipe_tx1_eqdone_o                   ( pipe_tx1_eqdone ),
    .pipe_tx1_compliance_i               ( pipe_tx1_compliance ),
    .pipe_tx1_char_is_k_i                ( pipe_tx1_char_is_k ),
    .pipe_tx1_data_i                     ( pipe_tx1_data ),
    .pipe_tx1_elec_idle_i                ( pipe_tx1_elec_idle ),
    .pipe_tx1_powerdown_i                ( pipe_tx1_powerdown ),
    .pipe_tx1_datavalid_i                ( pipe_tx1_data_valid ),
    .pipe_tx1_startblock_i               ( pipe_tx1_start_block ),
    .pipe_tx1_syncheader_i               ( pipe_tx1_syncheader ),
    .pipe_tx1_eqcontrol_i                ( pipe_tx1_eqcontrol ),
    .pipe_tx1_eqdeemph_i                 ( pipe_tx1_eqdeemph ),
    .pipe_tx1_eqpreset_i                 ( pipe_tx1_eqpreset ),

    .pipe_rx1_char_is_k_i                ( pipe_rx1_char_is_k_gt ),
    .pipe_rx1_data_i                     ( pipe_rx1_data_gt ),
    .pipe_rx1_valid_i                    ( pipe_rx1_valid_gt ),
    .pipe_rx1_data_valid_i               ( pipe_rx1_data_valid_gt ),
    .pipe_rx1_status_i                   ( pipe_rx1_status_gt ),
    .pipe_rx1_phy_status_i               ( pipe_rx1_phy_status_gt ),
    .pipe_rx1_elec_idle_i                ( pipe_rx1_elec_idle_gt ),
    .pipe_rx1_eqdone_i                   ( pipe_rx1_eqdone_gt ),
    .pipe_rx1_eqlpadaptdone_i            ( pipe_rx1_eqlp_adaptdone_gt ),
    .pipe_rx1_eqlplffssel_i              ( pipe_rx1_eqlp_lffs_sel_gt ),
    .pipe_rx1_eqlpnewtxcoefforpreset_i   ( pipe_rx1_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx1_startblock_i               ( pipe_rx1_start_block_gt ),
    .pipe_rx1_syncheader_i               ( pipe_rx1_syncheader_gt ),
    .pipe_rx1_polarity_o                 ( pipe_rx1_polarity_gt ),
    .pipe_rx1_eqcontrol_o                ( pipe_rx1_eqcontrol_gt ),
    .pipe_rx1_eqlplffs_o                 ( pipe_rx1_eqlp_lffs_gt ),
    .pipe_rx1_eqlptxpreset_o             ( pipe_rx1_eqlp_txpreset_gt ),
    .pipe_rx1_eqpreset_o                 ( pipe_rx1_eqpreset_gt ),
    .pipe_tx1_eqcoeff_i                  ( pipe_tx1_eqcoeff_gt ),
    .pipe_tx1_eqdone_i                   ( pipe_tx1_eqdone_gt ),
    .pipe_tx1_compliance_o               ( pipe_tx1_compliance_gt ),
    .pipe_tx1_char_is_k_o                ( pipe_tx1_char_is_k_gt ),
    .pipe_tx1_data_o                     ( pipe_tx1_data_gt ),
    .pipe_tx1_elec_idle_o                ( pipe_tx1_elec_idle_gt ),
    .pipe_tx1_powerdown_o                ( pipe_tx1_powerdown_gt ),
    .pipe_tx1_datavalid_o                ( pipe_tx1_data_valid_gt ),
    .pipe_tx1_startblock_o               ( pipe_tx1_start_block_gt ),
    .pipe_tx1_syncheader_o               ( pipe_tx1_syncheader_gt ),
    .pipe_tx1_eqcontrol_o                ( pipe_tx1_eqcontrol_gt ),
    .pipe_tx1_eqdeemph_o                 ( pipe_tx1_eqdeemph_gt ),
    .pipe_tx1_eqpreset_o                 ( pipe_tx1_eqpreset_gt ),

    // Pipe Per-Lane Signals - Lane 2
    .pipe_rx2_char_is_k_o                ( pipe_rx2_char_is_k ),
    .pipe_rx2_data_o                     ( pipe_rx2_data ),
    .pipe_rx2_valid_o                    ( pipe_rx2_valid ),
    .pipe_rx2_data_valid_o               ( pipe_rx2_data_valid ),
    .pipe_rx2_status_o                   ( pipe_rx2_status ),
    .pipe_rx2_phy_status_o               ( pipe_rx2_phy_status ),
    .pipe_rx2_elec_idle_o                ( pipe_rx2_elec_idle ),
    .pipe_rx2_eqdone_o                   ( pipe_rx2_eqdone ),
    .pipe_rx2_eqlpadaptdone_o            ( pipe_rx2_eqlp_adaptdone ),
    .pipe_rx2_eqlplffssel_o              ( pipe_rx2_eqlp_lffs_sel ),
    .pipe_rx2_eqlpnewtxcoefforpreset_o   ( pipe_rx2_eqlp_new_txcoef_forpreset ),
    .pipe_rx2_startblock_o               ( pipe_rx2_start_block ),
    .pipe_rx2_syncheader_o               ( pipe_rx2_syncheader ),
    .pipe_rx2_polarity_i                 ( pipe_rx2_polarity ),
    .pipe_rx2_eqcontrol_i                ( pipe_rx2_eqcontrol ),
    .pipe_rx2_eqlplffs_i                 ( pipe_rx2_eqlp_lffs ),
    .pipe_rx2_eqlptxpreset_i             ( pipe_rx2_eqlp_txpreset ),
    .pipe_rx2_eqpreset_i                 ( pipe_rx2_eqpreset ),
    .pipe_tx2_eqcoeff_o                  ( pipe_tx2_eqcoeff ),
    .pipe_tx2_eqdone_o                   ( pipe_tx2_eqdone ),
    .pipe_tx2_compliance_i               ( pipe_tx2_compliance ),
    .pipe_tx2_char_is_k_i                ( pipe_tx2_char_is_k ),
    .pipe_tx2_data_i                     ( pipe_tx2_data ),
    .pipe_tx2_elec_idle_i                ( pipe_tx2_elec_idle ),
    .pipe_tx2_powerdown_i                ( pipe_tx2_powerdown ),
    .pipe_tx2_datavalid_i                ( pipe_tx2_data_valid ),
    .pipe_tx2_startblock_i               ( pipe_tx2_start_block ),
    .pipe_tx2_syncheader_i               ( pipe_tx2_syncheader ),
    .pipe_tx2_eqcontrol_i                ( pipe_tx2_eqcontrol ),
    .pipe_tx2_eqdeemph_i                 ( pipe_tx2_eqdeemph ),
    .pipe_tx2_eqpreset_i                 ( pipe_tx2_eqpreset ),

    .pipe_rx2_char_is_k_i                ( pipe_rx2_char_is_k_gt ),
    .pipe_rx2_data_i                     ( pipe_rx2_data_gt ),
    .pipe_rx2_valid_i                    ( pipe_rx2_valid_gt ),
    .pipe_rx2_data_valid_i               ( pipe_rx2_data_valid_gt ),
    .pipe_rx2_status_i                   ( pipe_rx2_status_gt ),
    .pipe_rx2_phy_status_i               ( pipe_rx2_phy_status_gt ),
    .pipe_rx2_elec_idle_i                ( pipe_rx2_elec_idle_gt ),
    .pipe_rx2_eqdone_i                   ( pipe_rx2_eqdone_gt ),
    .pipe_rx2_eqlpadaptdone_i            ( pipe_rx2_eqlp_adaptdone_gt ),
    .pipe_rx2_eqlplffssel_i              ( pipe_rx2_eqlp_lffs_sel_gt ),
    .pipe_rx2_eqlpnewtxcoefforpreset_i   ( pipe_rx2_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx2_startblock_i               ( pipe_rx2_start_block_gt ),
    .pipe_rx2_syncheader_i               ( pipe_rx2_syncheader_gt ),
    .pipe_rx2_polarity_o                 ( pipe_rx2_polarity_gt ),
    .pipe_rx2_eqcontrol_o                ( pipe_rx2_eqcontrol_gt ),
    .pipe_rx2_eqlplffs_o                 ( pipe_rx2_eqlp_lffs_gt ),
    .pipe_rx2_eqlptxpreset_o             ( pipe_rx2_eqlp_txpreset_gt ),
    .pipe_rx2_eqpreset_o                 ( pipe_rx2_eqpreset_gt ),
    .pipe_tx2_eqcoeff_i                  ( pipe_tx2_eqcoeff_gt ),
    .pipe_tx2_eqdone_i                   ( pipe_tx2_eqdone_gt ),
    .pipe_tx2_compliance_o               ( pipe_tx2_compliance_gt ),
    .pipe_tx2_char_is_k_o                ( pipe_tx2_char_is_k_gt ),
    .pipe_tx2_data_o                     ( pipe_tx2_data_gt ),
    .pipe_tx2_elec_idle_o                ( pipe_tx2_elec_idle_gt ),
    .pipe_tx2_powerdown_o                ( pipe_tx2_powerdown_gt ),
    .pipe_tx2_datavalid_o                ( pipe_tx2_data_valid_gt ),
    .pipe_tx2_startblock_o               ( pipe_tx2_start_block_gt ),
    .pipe_tx2_syncheader_o               ( pipe_tx2_syncheader_gt ),
    .pipe_tx2_eqcontrol_o                ( pipe_tx2_eqcontrol_gt ),
    .pipe_tx2_eqdeemph_o                 ( pipe_tx2_eqdeemph_gt ),
    .pipe_tx2_eqpreset_o                 ( pipe_tx2_eqpreset_gt ),

    // Pipe Per-Lane Signals - Lane 3
    .pipe_rx3_char_is_k_o                ( pipe_rx3_char_is_k ),
    .pipe_rx3_data_o                     ( pipe_rx3_data ),
    .pipe_rx3_valid_o                    ( pipe_rx3_valid ),
    .pipe_rx3_data_valid_o               ( pipe_rx3_data_valid ),
    .pipe_rx3_status_o                   ( pipe_rx3_status ),
    .pipe_rx3_phy_status_o               ( pipe_rx3_phy_status ),
    .pipe_rx3_elec_idle_o                ( pipe_rx3_elec_idle ),
    .pipe_rx3_eqdone_o                   ( pipe_rx3_eqdone ),
    .pipe_rx3_eqlpadaptdone_o            ( pipe_rx3_eqlp_adaptdone ),
    .pipe_rx3_eqlplffssel_o              ( pipe_rx3_eqlp_lffs_sel ),
    .pipe_rx3_eqlpnewtxcoefforpreset_o   ( pipe_rx3_eqlp_new_txcoef_forpreset ),
    .pipe_rx3_startblock_o               ( pipe_rx3_start_block ),
    .pipe_rx3_syncheader_o               ( pipe_rx3_syncheader ),
    .pipe_rx3_polarity_i                 ( pipe_rx3_polarity ),
    .pipe_rx3_eqcontrol_i                ( pipe_rx3_eqcontrol ),
    .pipe_rx3_eqlplffs_i                 ( pipe_rx3_eqlp_lffs ),
    .pipe_rx3_eqlptxpreset_i             ( pipe_rx3_eqlp_txpreset ),
    .pipe_rx3_eqpreset_i                 ( pipe_rx3_eqpreset ),
    .pipe_tx3_eqcoeff_o                  ( pipe_tx3_eqcoeff ),
    .pipe_tx3_eqdone_o                   ( pipe_tx3_eqdone ),
    .pipe_tx3_compliance_i               ( pipe_tx3_compliance ),
    .pipe_tx3_char_is_k_i                ( pipe_tx3_char_is_k ),
    .pipe_tx3_data_i                     ( pipe_tx3_data ),
    .pipe_tx3_elec_idle_i                ( pipe_tx3_elec_idle ),
    .pipe_tx3_powerdown_i                ( pipe_tx3_powerdown ),
    .pipe_tx3_datavalid_i                ( pipe_tx3_data_valid ),
    .pipe_tx3_startblock_i               ( pipe_tx3_start_block ),
    .pipe_tx3_syncheader_i               ( pipe_tx3_syncheader ),
    .pipe_tx3_eqcontrol_i                ( pipe_tx3_eqcontrol ),
    .pipe_tx3_eqdeemph_i                 ( pipe_tx3_eqdeemph ),
    .pipe_tx3_eqpreset_i                 ( pipe_tx3_eqpreset ),

    .pipe_rx3_char_is_k_i                ( pipe_rx3_char_is_k_gt ),
    .pipe_rx3_data_i                     ( pipe_rx3_data_gt ),
    .pipe_rx3_valid_i                    ( pipe_rx3_valid_gt ),
    .pipe_rx3_data_valid_i               ( pipe_rx3_data_valid_gt ),
    .pipe_rx3_status_i                   ( pipe_rx3_status_gt ),
    .pipe_rx3_phy_status_i               ( pipe_rx3_phy_status_gt ),
    .pipe_rx3_elec_idle_i                ( pipe_rx3_elec_idle_gt ),
    .pipe_rx3_eqdone_i                   ( pipe_rx3_eqdone_gt ),
    .pipe_rx3_eqlpadaptdone_i            ( pipe_rx3_eqlp_adaptdone_gt ),
    .pipe_rx3_eqlplffssel_i              ( pipe_rx3_eqlp_lffs_sel_gt ),
    .pipe_rx3_eqlpnewtxcoefforpreset_i   ( pipe_rx3_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx3_startblock_i               ( pipe_rx3_start_block_gt ),
    .pipe_rx3_syncheader_i               ( pipe_rx3_syncheader_gt ),
    .pipe_rx3_polarity_o                 ( pipe_rx3_polarity_gt ),
    .pipe_rx3_eqcontrol_o                ( pipe_rx3_eqcontrol_gt ),
    .pipe_rx3_eqlplffs_o                 ( pipe_rx3_eqlp_lffs_gt ),
    .pipe_rx3_eqlptxpreset_o             ( pipe_rx3_eqlp_txpreset_gt ),
    .pipe_rx3_eqpreset_o                 ( pipe_rx3_eqpreset_gt ),
    .pipe_tx3_eqcoeff_i                  ( pipe_tx3_eqcoeff_gt ),
    .pipe_tx3_eqdone_i                   ( pipe_tx3_eqdone_gt ),
    .pipe_tx3_compliance_o               ( pipe_tx3_compliance_gt ),
    .pipe_tx3_char_is_k_o                ( pipe_tx3_char_is_k_gt ),
    .pipe_tx3_data_o                     ( pipe_tx3_data_gt ),
    .pipe_tx3_elec_idle_o                ( pipe_tx3_elec_idle_gt ),
    .pipe_tx3_powerdown_o                ( pipe_tx3_powerdown_gt ),
    .pipe_tx3_datavalid_o                ( pipe_tx3_data_valid_gt ),
    .pipe_tx3_startblock_o               ( pipe_tx3_start_block_gt ),
    .pipe_tx3_syncheader_o               ( pipe_tx3_syncheader_gt ),
    .pipe_tx3_eqcontrol_o                ( pipe_tx3_eqcontrol_gt ),
    .pipe_tx3_eqdeemph_o                 ( pipe_tx3_eqdeemph_gt ),
    .pipe_tx3_eqpreset_o                 ( pipe_tx3_eqpreset_gt ),

    // Pipe Per-Lane Signals - Lane 4
    .pipe_rx4_char_is_k_o                ( pipe_rx4_char_is_k ),
    .pipe_rx4_data_o                     ( pipe_rx4_data ),
    .pipe_rx4_valid_o                    ( pipe_rx4_valid ),
    .pipe_rx4_data_valid_o               ( pipe_rx4_data_valid ),
    .pipe_rx4_status_o                   ( pipe_rx4_status ),
    .pipe_rx4_phy_status_o               ( pipe_rx4_phy_status ),
    .pipe_rx4_elec_idle_o                ( pipe_rx4_elec_idle ),
    .pipe_rx4_eqdone_o                   ( pipe_rx4_eqdone ),
    .pipe_rx4_eqlpadaptdone_o            ( pipe_rx4_eqlp_adaptdone ),
    .pipe_rx4_eqlplffssel_o              ( pipe_rx4_eqlp_lffs_sel ),
    .pipe_rx4_eqlpnewtxcoefforpreset_o   ( pipe_rx4_eqlp_new_txcoef_forpreset ),
    .pipe_rx4_startblock_o               ( pipe_rx4_start_block ),
    .pipe_rx4_syncheader_o               ( pipe_rx4_syncheader ),
    .pipe_rx4_polarity_i                 ( pipe_rx4_polarity ),
    .pipe_rx4_eqcontrol_i                ( pipe_rx4_eqcontrol ),
    .pipe_rx4_eqlplffs_i                 ( pipe_rx4_eqlp_lffs ),
    .pipe_rx4_eqlptxpreset_i             ( pipe_rx4_eqlp_txpreset ),
    .pipe_rx4_eqpreset_i                 ( pipe_rx4_eqpreset ),
    .pipe_tx4_eqcoeff_o                  ( pipe_tx4_eqcoeff ),
    .pipe_tx4_eqdone_o                   ( pipe_tx4_eqdone ),
    .pipe_tx4_compliance_i               ( pipe_tx4_compliance ),
    .pipe_tx4_char_is_k_i                ( pipe_tx4_char_is_k ),
    .pipe_tx4_data_i                     ( pipe_tx4_data ),
    .pipe_tx4_elec_idle_i                ( pipe_tx4_elec_idle ),
    .pipe_tx4_powerdown_i                ( pipe_tx4_powerdown ),
    .pipe_tx4_datavalid_i                ( pipe_tx4_data_valid ),
    .pipe_tx4_startblock_i               ( pipe_tx4_start_block ),
    .pipe_tx4_syncheader_i               ( pipe_tx4_syncheader ),
    .pipe_tx4_eqcontrol_i                ( pipe_tx4_eqcontrol ),
    .pipe_tx4_eqdeemph_i                 ( pipe_tx4_eqdeemph ),
    .pipe_tx4_eqpreset_i                 ( pipe_tx4_eqpreset ),

    .pipe_rx4_char_is_k_i                ( pipe_rx4_char_is_k_gt ),
    .pipe_rx4_data_i                     ( pipe_rx4_data_gt ),
    .pipe_rx4_valid_i                    ( pipe_rx4_valid_gt ),
    .pipe_rx4_data_valid_i               ( pipe_rx4_data_valid_gt ),
    .pipe_rx4_status_i                   ( pipe_rx4_status_gt ),
    .pipe_rx4_phy_status_i               ( pipe_rx4_phy_status_gt ),
    .pipe_rx4_elec_idle_i                ( pipe_rx4_elec_idle_gt ),
    .pipe_rx4_eqdone_i                   ( pipe_rx4_eqdone_gt ),
    .pipe_rx4_eqlpadaptdone_i            ( pipe_rx4_eqlp_adaptdone_gt ),
    .pipe_rx4_eqlplffssel_i              ( pipe_rx4_eqlp_lffs_sel_gt ),
    .pipe_rx4_eqlpnewtxcoefforpreset_i   ( pipe_rx4_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx4_startblock_i               ( pipe_rx4_start_block_gt ),
    .pipe_rx4_syncheader_i               ( pipe_rx4_syncheader_gt ),
    .pipe_rx4_polarity_o                 ( pipe_rx4_polarity_gt ),
    .pipe_rx4_eqcontrol_o                ( pipe_rx4_eqcontrol_gt ),
    .pipe_rx4_eqlplffs_o                 ( pipe_rx4_eqlp_lffs_gt ),
    .pipe_rx4_eqlptxpreset_o             ( pipe_rx4_eqlp_txpreset_gt ),
    .pipe_rx4_eqpreset_o                 ( pipe_rx4_eqpreset_gt ),
    .pipe_tx4_eqcoeff_i                  ( pipe_tx4_eqcoeff_gt ),
    .pipe_tx4_eqdone_i                   ( pipe_tx4_eqdone_gt ),
    .pipe_tx4_compliance_o               ( pipe_tx4_compliance_gt ),
    .pipe_tx4_char_is_k_o                ( pipe_tx4_char_is_k_gt ),
    .pipe_tx4_data_o                     ( pipe_tx4_data_gt ),
    .pipe_tx4_elec_idle_o                ( pipe_tx4_elec_idle_gt ),
    .pipe_tx4_powerdown_o                ( pipe_tx4_powerdown_gt ),
    .pipe_tx4_datavalid_o                ( pipe_tx4_data_valid_gt ),
    .pipe_tx4_startblock_o               ( pipe_tx4_start_block_gt ),
    .pipe_tx4_syncheader_o               ( pipe_tx4_syncheader_gt ),
    .pipe_tx4_eqcontrol_o                ( pipe_tx4_eqcontrol_gt ),
    .pipe_tx4_eqdeemph_o                 ( pipe_tx4_eqdeemph_gt ),
    .pipe_tx4_eqpreset_o                 ( pipe_tx4_eqpreset_gt ),

    // Pipe Per-Lane Signals - Lane 5
    .pipe_rx5_char_is_k_o                ( pipe_rx5_char_is_k ),
    .pipe_rx5_data_o                     ( pipe_rx5_data ),
    .pipe_rx5_valid_o                    ( pipe_rx5_valid ),
    .pipe_rx5_data_valid_o               ( pipe_rx5_data_valid ),
    .pipe_rx5_status_o                   ( pipe_rx5_status ),
    .pipe_rx5_phy_status_o               ( pipe_rx5_phy_status ),
    .pipe_rx5_elec_idle_o                ( pipe_rx5_elec_idle ),
    .pipe_rx5_eqdone_o                   ( pipe_rx5_eqdone ),
    .pipe_rx5_eqlpadaptdone_o            ( pipe_rx5_eqlp_adaptdone ),
    .pipe_rx5_eqlplffssel_o              ( pipe_rx5_eqlp_lffs_sel ),
    .pipe_rx5_eqlpnewtxcoefforpreset_o   ( pipe_rx5_eqlp_new_txcoef_forpreset ),
    .pipe_rx5_startblock_o               ( pipe_rx5_start_block ),
    .pipe_rx5_syncheader_o               ( pipe_rx5_syncheader ),
    .pipe_rx5_polarity_i                 ( pipe_rx5_polarity ),
    .pipe_rx5_eqcontrol_i                ( pipe_rx5_eqcontrol ),
    .pipe_rx5_eqlplffs_i                 ( pipe_rx5_eqlp_lffs ),
    .pipe_rx5_eqlptxpreset_i             ( pipe_rx5_eqlp_txpreset ),
    .pipe_rx5_eqpreset_i                 ( pipe_rx5_eqpreset ),
    .pipe_tx5_eqcoeff_o                  ( pipe_tx5_eqcoeff ),
    .pipe_tx5_eqdone_o                   ( pipe_tx5_eqdone ),
    .pipe_tx5_compliance_i               ( pipe_tx5_compliance ),
    .pipe_tx5_char_is_k_i                ( pipe_tx5_char_is_k ),
    .pipe_tx5_data_i                     ( pipe_tx5_data ),
    .pipe_tx5_elec_idle_i                ( pipe_tx5_elec_idle ),
    .pipe_tx5_powerdown_i                ( pipe_tx5_powerdown ),
    .pipe_tx5_datavalid_i                ( pipe_tx5_data_valid ),
    .pipe_tx5_startblock_i               ( pipe_tx5_start_block ),
    .pipe_tx5_syncheader_i               ( pipe_tx5_syncheader ),
    .pipe_tx5_eqcontrol_i                ( pipe_tx5_eqcontrol ),
    .pipe_tx5_eqdeemph_i                 ( pipe_tx5_eqdeemph ),
    .pipe_tx5_eqpreset_i                 ( pipe_tx5_eqpreset ),

    .pipe_rx5_char_is_k_i                ( pipe_rx5_char_is_k_gt ),
    .pipe_rx5_data_i                     ( pipe_rx5_data_gt ),
    .pipe_rx5_valid_i                    ( pipe_rx5_valid_gt ),
    .pipe_rx5_data_valid_i               ( pipe_rx5_data_valid_gt ),
    .pipe_rx5_status_i                   ( pipe_rx5_status_gt ),
    .pipe_rx5_phy_status_i               ( pipe_rx5_phy_status_gt ),
    .pipe_rx5_elec_idle_i                ( pipe_rx5_elec_idle_gt ),
    .pipe_rx5_eqdone_i                   ( pipe_rx5_eqdone_gt ),
    .pipe_rx5_eqlpadaptdone_i            ( pipe_rx5_eqlp_adaptdone_gt ),
    .pipe_rx5_eqlplffssel_i              ( pipe_rx5_eqlp_lffs_sel_gt ),
    .pipe_rx5_eqlpnewtxcoefforpreset_i   ( pipe_rx5_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx5_startblock_i               ( pipe_rx5_start_block_gt ),
    .pipe_rx5_syncheader_i               ( pipe_rx5_syncheader_gt ),
    .pipe_rx5_polarity_o                 ( pipe_rx5_polarity_gt ),
    .pipe_rx5_eqcontrol_o                ( pipe_rx5_eqcontrol_gt ),
    .pipe_rx5_eqlplffs_o                 ( pipe_rx5_eqlp_lffs_gt ),
    .pipe_rx5_eqlptxpreset_o             ( pipe_rx5_eqlp_txpreset_gt ),
    .pipe_rx5_eqpreset_o                 ( pipe_rx5_eqpreset_gt ),
    .pipe_tx5_eqcoeff_i                  ( pipe_tx5_eqcoeff_gt ),
    .pipe_tx5_eqdone_i                   ( pipe_tx5_eqdone_gt ),
    .pipe_tx5_compliance_o               ( pipe_tx5_compliance_gt ),
    .pipe_tx5_char_is_k_o                ( pipe_tx5_char_is_k_gt ),
    .pipe_tx5_data_o                     ( pipe_tx5_data_gt ),
    .pipe_tx5_elec_idle_o                ( pipe_tx5_elec_idle_gt ),
    .pipe_tx5_powerdown_o                ( pipe_tx5_powerdown_gt ),
    .pipe_tx5_datavalid_o                ( pipe_tx5_data_valid_gt ),
    .pipe_tx5_startblock_o               ( pipe_tx5_start_block_gt ),
    .pipe_tx5_syncheader_o               ( pipe_tx5_syncheader_gt ),
    .pipe_tx5_eqcontrol_o                ( pipe_tx5_eqcontrol_gt ),
    .pipe_tx5_eqdeemph_o                 ( pipe_tx5_eqdeemph_gt ),
    .pipe_tx5_eqpreset_o                 ( pipe_tx5_eqpreset_gt ),

    // Pipe Per-Lane Signals - Lane 6
    .pipe_rx6_char_is_k_o                ( pipe_rx6_char_is_k ),
    .pipe_rx6_data_o                     ( pipe_rx6_data ),
    .pipe_rx6_valid_o                    ( pipe_rx6_valid ),
    .pipe_rx6_data_valid_o               ( pipe_rx6_data_valid ),
    .pipe_rx6_status_o                   ( pipe_rx6_status ),
    .pipe_rx6_phy_status_o               ( pipe_rx6_phy_status ),
    .pipe_rx6_elec_idle_o                ( pipe_rx6_elec_idle ),
    .pipe_rx6_eqdone_o                   ( pipe_rx6_eqdone ),
    .pipe_rx6_eqlpadaptdone_o            ( pipe_rx6_eqlp_adaptdone ),
    .pipe_rx6_eqlplffssel_o              ( pipe_rx6_eqlp_lffs_sel ),
    .pipe_rx6_eqlpnewtxcoefforpreset_o   ( pipe_rx6_eqlp_new_txcoef_forpreset ),
    .pipe_rx6_startblock_o               ( pipe_rx6_start_block ),
    .pipe_rx6_syncheader_o               ( pipe_rx6_syncheader ),
    .pipe_rx6_polarity_i                 ( pipe_rx6_polarity ),
    .pipe_rx6_eqcontrol_i                ( pipe_rx6_eqcontrol ),
    .pipe_rx6_eqlplffs_i                 ( pipe_rx6_eqlp_lffs ),
    .pipe_rx6_eqlptxpreset_i             ( pipe_rx6_eqlp_txpreset ),
    .pipe_rx6_eqpreset_i                 ( pipe_rx6_eqpreset ),
    .pipe_tx6_eqcoeff_o                  ( pipe_tx6_eqcoeff ),
    .pipe_tx6_eqdone_o                   ( pipe_tx6_eqdone ),
    .pipe_tx6_compliance_i               ( pipe_tx6_compliance ),
    .pipe_tx6_char_is_k_i                ( pipe_tx6_char_is_k ),
    .pipe_tx6_data_i                     ( pipe_tx6_data ),
    .pipe_tx6_elec_idle_i                ( pipe_tx6_elec_idle ),
    .pipe_tx6_powerdown_i                ( pipe_tx6_powerdown ),
    .pipe_tx6_datavalid_i                ( pipe_tx6_data_valid ),
    .pipe_tx6_startblock_i               ( pipe_tx6_start_block ),
    .pipe_tx6_syncheader_i               ( pipe_tx6_syncheader ),
    .pipe_tx6_eqcontrol_i                ( pipe_tx6_eqcontrol ),
    .pipe_tx6_eqdeemph_i                 ( pipe_tx6_eqdeemph ),
    .pipe_tx6_eqpreset_i                 ( pipe_tx6_eqpreset ),

    .pipe_rx6_char_is_k_i                ( pipe_rx6_char_is_k_gt ),
    .pipe_rx6_data_i                     ( pipe_rx6_data_gt ),
    .pipe_rx6_valid_i                    ( pipe_rx6_valid_gt ),
    .pipe_rx6_data_valid_i               ( pipe_rx6_data_valid_gt ),
    .pipe_rx6_status_i                   ( pipe_rx6_status_gt ),
    .pipe_rx6_phy_status_i               ( pipe_rx6_phy_status_gt ),
    .pipe_rx6_elec_idle_i                ( pipe_rx6_elec_idle_gt ),
    .pipe_rx6_eqdone_i                   ( pipe_rx6_eqdone_gt ),
    .pipe_rx6_eqlpadaptdone_i            ( pipe_rx6_eqlp_adaptdone_gt ),
    .pipe_rx6_eqlplffssel_i              ( pipe_rx6_eqlp_lffs_sel_gt ),
    .pipe_rx6_eqlpnewtxcoefforpreset_i   ( pipe_rx6_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx6_startblock_i               ( pipe_rx6_start_block_gt ),
    .pipe_rx6_syncheader_i               ( pipe_rx6_syncheader_gt ),
    .pipe_rx6_polarity_o                 ( pipe_rx6_polarity_gt ),
    .pipe_rx6_eqcontrol_o                ( pipe_rx6_eqcontrol_gt ),
    .pipe_rx6_eqlplffs_o                 ( pipe_rx6_eqlp_lffs_gt ),
    .pipe_rx6_eqlptxpreset_o             ( pipe_rx6_eqlp_txpreset_gt ),
    .pipe_rx6_eqpreset_o                 ( pipe_rx6_eqpreset_gt ),
    .pipe_tx6_eqcoeff_i                  ( pipe_tx6_eqcoeff_gt ),
    .pipe_tx6_eqdone_i                   ( pipe_tx6_eqdone_gt ),
    .pipe_tx6_compliance_o               ( pipe_tx6_compliance_gt ),
    .pipe_tx6_char_is_k_o                ( pipe_tx6_char_is_k_gt ),
    .pipe_tx6_data_o                     ( pipe_tx6_data_gt ),
    .pipe_tx6_elec_idle_o                ( pipe_tx6_elec_idle_gt ),
    .pipe_tx6_powerdown_o                ( pipe_tx6_powerdown_gt ),
    .pipe_tx6_datavalid_o                ( pipe_tx6_data_valid_gt ),
    .pipe_tx6_startblock_o               ( pipe_tx6_start_block_gt ),
    .pipe_tx6_syncheader_o               ( pipe_tx6_syncheader_gt ),
    .pipe_tx6_eqcontrol_o                ( pipe_tx6_eqcontrol_gt ),
    .pipe_tx6_eqdeemph_o                 ( pipe_tx6_eqdeemph_gt ),
    .pipe_tx6_eqpreset_o                 ( pipe_tx6_eqpreset_gt ),

    // Pipe Per-Lane Signals - Lane 7
    .pipe_rx7_char_is_k_o                ( pipe_rx7_char_is_k ),
    .pipe_rx7_data_o                     ( pipe_rx7_data ),
    .pipe_rx7_valid_o                    ( pipe_rx7_valid ),
    .pipe_rx7_data_valid_o               ( pipe_rx7_data_valid ),
    .pipe_rx7_status_o                   ( pipe_rx7_status ),
    .pipe_rx7_phy_status_o               ( pipe_rx7_phy_status ),
    .pipe_rx7_elec_idle_o                ( pipe_rx7_elec_idle ),
    .pipe_rx7_eqdone_o                   ( pipe_rx7_eqdone ),
    .pipe_rx7_eqlpadaptdone_o            ( pipe_rx7_eqlp_adaptdone ),
    .pipe_rx7_eqlplffssel_o              ( pipe_rx7_eqlp_lffs_sel ),
    .pipe_rx7_eqlpnewtxcoefforpreset_o   ( pipe_rx7_eqlp_new_txcoef_forpreset ),
    .pipe_rx7_startblock_o               ( pipe_rx7_start_block ),
    .pipe_rx7_syncheader_o               ( pipe_rx7_syncheader ),
    .pipe_rx7_polarity_i                 ( pipe_rx7_polarity ),
    .pipe_rx7_eqcontrol_i                ( pipe_rx7_eqcontrol ),
    .pipe_rx7_eqlplffs_i                 ( pipe_rx7_eqlp_lffs ),
    .pipe_rx7_eqlptxpreset_i             ( pipe_rx7_eqlp_txpreset ),
    .pipe_rx7_eqpreset_i                 ( pipe_rx7_eqpreset ),
    .pipe_tx7_eqcoeff_o                  ( pipe_tx7_eqcoeff ),
    .pipe_tx7_eqdone_o                   ( pipe_tx7_eqdone ),
    .pipe_tx7_compliance_i               ( pipe_tx7_compliance ),
    .pipe_tx7_char_is_k_i                ( pipe_tx7_char_is_k ),
    .pipe_tx7_data_i                     ( pipe_tx7_data ),
    .pipe_tx7_elec_idle_i                ( pipe_tx7_elec_idle ),
    .pipe_tx7_powerdown_i                ( pipe_tx7_powerdown ),
    .pipe_tx7_datavalid_i                ( pipe_tx7_data_valid ),
    .pipe_tx7_startblock_i               ( pipe_tx7_start_block ),
    .pipe_tx7_syncheader_i               ( pipe_tx7_syncheader ),
    .pipe_tx7_eqcontrol_i                ( pipe_tx7_eqcontrol ),
    .pipe_tx7_eqdeemph_i                 ( pipe_tx7_eqdeemph ),
    .pipe_tx7_eqpreset_i                 ( pipe_tx7_eqpreset ),

    .pipe_rx7_char_is_k_i                ( pipe_rx7_char_is_k_gt ),
    .pipe_rx7_data_i                     ( pipe_rx7_data_gt ),
    .pipe_rx7_valid_i                    ( pipe_rx7_valid_gt ),
    .pipe_rx7_data_valid_i               ( pipe_rx7_data_valid_gt ),
    .pipe_rx7_status_i                   ( pipe_rx7_status_gt ),
    .pipe_rx7_phy_status_i               ( pipe_rx7_phy_status_gt ),
    .pipe_rx7_elec_idle_i                ( pipe_rx7_elec_idle_gt ),
    .pipe_rx7_eqdone_i                   ( pipe_rx7_eqdone_gt ),
    .pipe_rx7_eqlpadaptdone_i            ( pipe_rx7_eqlp_adaptdone_gt ),
    .pipe_rx7_eqlplffssel_i              ( pipe_rx7_eqlp_lffs_sel_gt ),
    .pipe_rx7_eqlpnewtxcoefforpreset_i   ( pipe_rx7_eqlp_new_txcoef_forpreset_gt ),
    .pipe_rx7_startblock_i               ( pipe_rx7_start_block_gt ),
    .pipe_rx7_syncheader_i               ( pipe_rx7_syncheader_gt ),
    .pipe_rx7_polarity_o                 ( pipe_rx7_polarity_gt ),
    .pipe_rx7_eqcontrol_o                ( pipe_rx7_eqcontrol_gt ),
    .pipe_rx7_eqlplffs_o                 ( pipe_rx7_eqlp_lffs_gt ),
    .pipe_rx7_eqlptxpreset_o             ( pipe_rx7_eqlp_txpreset_gt ),
    .pipe_rx7_eqpreset_o                 ( pipe_rx7_eqpreset_gt ),
    .pipe_tx7_eqcoeff_i                  ( pipe_tx7_eqcoeff_gt ),
    .pipe_tx7_eqdone_i                   ( pipe_tx7_eqdone_gt ),
    .pipe_tx7_compliance_o               ( pipe_tx7_compliance_gt ),
    .pipe_tx7_char_is_k_o                ( pipe_tx7_char_is_k_gt ),
    .pipe_tx7_data_o                     ( pipe_tx7_data_gt ),
    .pipe_tx7_elec_idle_o                ( pipe_tx7_elec_idle_gt ),
    .pipe_tx7_powerdown_o                ( pipe_tx7_powerdown_gt ),
    .pipe_tx7_datavalid_o                ( pipe_tx7_data_valid_gt ),
    .pipe_tx7_startblock_o               ( pipe_tx7_start_block_gt ),
    .pipe_tx7_syncheader_o               ( pipe_tx7_syncheader_gt ),
    .pipe_tx7_eqcontrol_o                ( pipe_tx7_eqcontrol_gt ),
    .pipe_tx7_eqdeemph_o                 ( pipe_tx7_eqdeemph_gt ),
    .pipe_tx7_eqpreset_o                 ( pipe_tx7_eqpreset_gt ),

    // Non PIPE signals
    .pipe_clk                            ( pipe_clk ),
    .rst_n                               ( reset_n )
  );

//

endmodule
