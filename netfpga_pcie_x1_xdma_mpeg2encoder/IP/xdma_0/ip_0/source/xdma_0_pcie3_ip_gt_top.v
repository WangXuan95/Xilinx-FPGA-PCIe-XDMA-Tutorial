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
// File       : xdma_0_pcie3_ip_gt_top.v
// Version    : 4.2
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : xdma_0_pcie3_ip_gt_top.v                               //
// Description  : Instantiates the top level of the GT wrapper and also the   //
//                TX Electrical Idle filter                                   //
//                                                                            //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
//  gt_top.v                                                                  //
//      pcie_tx_elec_idle_filter_7vx.v                                        //
//      pipe_clock.v                                                          //
//      pipe_reset.v                                                          //
//      qpll_reset.v                                                          //
//          * Generate GTHE2_CHANNEL for every lane.                          //
//              pipe_user.v                                                   //
//              pipe_rate.v                                                   //
//              pipe_sync.v                                                   //
//              pipe_drp.v                                                    //
//              pipe_eq.v                                                     //
//                  rxeq_scan.v                                               //
//              gt_wrapper.v                                                  //
//                  GTHE2_CHANNEL                                             //
//                  GTHE2_COMMON                                              //
//          * Generate GTHE2_COMMON for every quad.                           //
//              qpll_drp.v                                                    //
//              qpll_wrapper.v                                                //
//----------------------------------------------------------------------------//

`timescale 1ps / 1ps

module xdma_0_pcie3_ip_gt_top #
(
  parameter               TCQ                        = 100,
  parameter               PL_LINK_CAP_MAX_LINK_WIDTH = 8,      // 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
  parameter               PL_LINK_CAP_MAX_LINK_SPEED = 4,      // 1 - Gen 1 , 2 - Gen 2 , 4 - Gen 3
  parameter               REF_CLK_FREQ               = 0,      // 0 - 100 MHz , 1 - 125 MHz , 2 - 250 MHz
  //  USER_CLK[1/2]_FREQ        : 0 = Disable user clock
  //                                : 1 =  31.25 MHz
  //                                : 2 =  62.50 MHz (default)
  //                                : 3 = 125.00 MHz
  //                                : 4 = 250.00 MHz
  //                                : 5 = 500.00 MHz
  parameter  integer      USER_CLK_FREQ             = 5,
  parameter  integer      USER_CLK2_FREQ            = 4,
  parameter               PL_SIM_FAST_LINK_TRAINING = "FALSE", // Simulation Speedup
  parameter               PCIE_EXT_CLK              = "FALSE", // Use External Clocking
  parameter               PCIE_EXT_GT_COMMON        = "FALSE", // Use External GT COMMON
  parameter               EXT_CH_GT_DRP             = "FALSE",      // PCIe external CH DRP
  parameter               EXT_QPLL_GT_DRP           = "FALSE",      // PCIe external QPLL DRP
  parameter               PCIE_TXBUF_EN             = "FALSE",
  parameter               PCIE_GT_DEVICE            = "GTH",
  parameter               PCIE_CHAN_BOND            = 0,       // 0 - One Hot, 1 - Daisy Chain, 2 - Binary Tree
  parameter               PCIE_CHAN_BOND_EN         = "FALSE", // Disable Channel bond as Integrated Block perform CB
  parameter               PCIE_USE_MODE             = "1.1",
  parameter               PCIE_LPM_DFE              = "LPM",
  parameter               TX_MARGIN_FULL_0          = 7'b1001111,                          // 1000 mV
  parameter               TX_MARGIN_FULL_1          = 7'b1001110,                          // 950 mV
  parameter               TX_MARGIN_FULL_2          = 7'b1001101,                          // 900 mV
  parameter               TX_MARGIN_FULL_3          = 7'b1001100,                          // 850 mV
  parameter               TX_MARGIN_FULL_4          = 7'b1000011,                          // 400 mV
  parameter               TX_MARGIN_LOW_0           = 7'b1000101,                          // 500 mV
  parameter               TX_MARGIN_LOW_1           = 7'b1000110 ,                          // 450 mV
  parameter               TX_MARGIN_LOW_2           = 7'b1000011,                          // 400 mV
  parameter               TX_MARGIN_LOW_3           =7'b1000010 ,                          // 350 mV
  parameter               TX_MARGIN_LOW_4           =7'b1000000 ,

  parameter               PCIE_LINK_SPEED           = 3,
  parameter               PCIE_ASYNC_EN             = "FALSE"

) (

  //-----------------------------------------------------------------------------------------------------------------//
  // Pipe Per-Link Signals
  input   wire                                       pipe_tx_rcvr_det,
  input   wire                                       pipe_tx_reset,
  input   wire                               [1:0]   pipe_tx_rate,
  input   wire                                       pipe_tx_deemph,
  input   wire                               [2:0]   pipe_tx_margin,
  input   wire                                       pipe_tx_swing,
  output  wire                               [5:0]   pipe_txeq_fs,
  output  wire                               [5:0]   pipe_txeq_lf,
  input   wire                               [7:0]   pipe_rxslide,
  output  wire                               [7:0]   pipe_rxsync_done,
  input   wire                               [5:0]   cfg_ltssm_state,

  // Pipe Per-Lane Signals - Lane 0
  output  wire                               [1:0]   pipe_rx0_char_is_k,
  output  wire                              [31:0]   pipe_rx0_data,
  output  wire                                       pipe_rx0_valid,
  output  wire                                       pipe_rx0_chanisaligned,
  output  wire                               [2:0]   pipe_rx0_status,
  output  wire                                       pipe_rx0_phy_status,
  output  wire                                       pipe_rx0_elec_idle,
  input   wire                                       pipe_rx0_polarity,
  input   wire                                       pipe_tx0_compliance,
  input   wire                               [1:0]   pipe_tx0_char_is_k,
  input   wire                              [31:0]   pipe_tx0_data,
  input   wire                                       pipe_tx0_elec_idle,
  input   wire                               [1:0]   pipe_tx0_powerdown,
  input   wire                               [1:0]   pipe_tx0_eqcontrol,
  input   wire                               [3:0]   pipe_tx0_eqpreset,
  input   wire                               [5:0]   pipe_tx0_eqdeemph,
  output  wire                                       pipe_tx0_eqdone,
  output  wire                              [17:0]   pipe_tx0_eqcoeff,
  input   wire                               [1:0]   pipe_rx0_eqcontrol,
  input   wire                               [2:0]   pipe_rx0_eqpreset,
  input   wire                               [5:0]   pipe_rx0_eq_lffs,
  input   wire                               [3:0]   pipe_rx0_eq_txpreset,
  output  wire                              [17:0]   pipe_rx0_eq_new_txcoeff,
  output  wire                                       pipe_rx0_eq_lffs_sel,
  output  wire                                       pipe_rx0_eq_adapt_done,
  output  wire                                       pipe_rx0_eqdone,

  // Pipe Per-Lane Signals - Lane 1
  output  wire                               [1:0]   pipe_rx1_char_is_k,
  output  wire                              [31:0]   pipe_rx1_data,
  output  wire                                       pipe_rx1_valid,
  output  wire                                       pipe_rx1_chanisaligned,
  output  wire                               [2:0]   pipe_rx1_status,
  output  wire                                       pipe_rx1_phy_status,
  output  wire                                       pipe_rx1_elec_idle,
  input   wire                                       pipe_rx1_polarity,
  input   wire                                       pipe_tx1_compliance,
  input   wire                               [1:0]   pipe_tx1_char_is_k,
  input   wire                              [31:0]   pipe_tx1_data,
  input   wire                                       pipe_tx1_elec_idle,
  input   wire                               [1:0]   pipe_tx1_powerdown,
  input   wire                               [1:0]   pipe_tx1_eqcontrol,
  input   wire                               [3:0]   pipe_tx1_eqpreset,
  input   wire                               [5:0]   pipe_tx1_eqdeemph,
  output  wire                                       pipe_tx1_eqdone,
  output  wire                              [17:0]   pipe_tx1_eqcoeff,
  input   wire                               [1:0]   pipe_rx1_eqcontrol,
  input   wire                               [2:0]   pipe_rx1_eqpreset,
  input   wire                               [5:0]   pipe_rx1_eq_lffs,
  input   wire                               [3:0]   pipe_rx1_eq_txpreset,
  output  wire                              [17:0]   pipe_rx1_eq_new_txcoeff,
  output  wire                                       pipe_rx1_eq_lffs_sel,
  output  wire                                       pipe_rx1_eq_adapt_done,
  output  wire                                       pipe_rx1_eqdone,

  // Pipe Per-Lane Signals - Lane 2
  output  wire                               [1:0]   pipe_rx2_char_is_k,
  output  wire                              [31:0]   pipe_rx2_data,
  output  wire                                       pipe_rx2_valid,
  output  wire                                       pipe_rx2_chanisaligned,
  output  wire                               [2:0]   pipe_rx2_status,
  output  wire                                       pipe_rx2_phy_status,
  output  wire                                       pipe_rx2_elec_idle,
  input   wire                                       pipe_rx2_polarity,
  input   wire                                       pipe_tx2_compliance,
  input   wire                               [1:0]   pipe_tx2_char_is_k,
  input   wire                              [31:0]   pipe_tx2_data,
  input   wire                                       pipe_tx2_elec_idle,
  input   wire                               [1:0]   pipe_tx2_powerdown,
  input   wire                               [1:0]   pipe_tx2_eqcontrol,
  input   wire                               [3:0]   pipe_tx2_eqpreset,
  input   wire                               [5:0]   pipe_tx2_eqdeemph,
  output  wire                                       pipe_tx2_eqdone,
  output  wire                              [17:0]   pipe_tx2_eqcoeff,
  input   wire                               [1:0]   pipe_rx2_eqcontrol,
  input   wire                               [2:0]   pipe_rx2_eqpreset,
  input   wire                               [5:0]   pipe_rx2_eq_lffs,
  input   wire                               [3:0]   pipe_rx2_eq_txpreset,
  output  wire                              [17:0]   pipe_rx2_eq_new_txcoeff,
  output  wire                                       pipe_rx2_eq_lffs_sel,
  output  wire                                       pipe_rx2_eq_adapt_done,
  output  wire                                       pipe_rx2_eqdone,

  // Pipe Per-Lane Signals - Lane 3
  output  wire                               [1:0]   pipe_rx3_char_is_k,
  output  wire                              [31:0]   pipe_rx3_data,
  output  wire                                       pipe_rx3_valid,
  output  wire                                       pipe_rx3_chanisaligned,
  output  wire                               [2:0]   pipe_rx3_status,
  output  wire                                       pipe_rx3_phy_status,
  output  wire                                       pipe_rx3_elec_idle,
  input   wire                                       pipe_rx3_polarity,
  input   wire                                       pipe_tx3_compliance,
  input   wire                               [1:0]   pipe_tx3_char_is_k,
  input   wire                              [31:0]   pipe_tx3_data,
  input   wire                                       pipe_tx3_elec_idle,
  input   wire                               [1:0]   pipe_tx3_powerdown,
  input   wire                               [1:0]   pipe_tx3_eqcontrol,
  input   wire                               [3:0]   pipe_tx3_eqpreset,
  input   wire                               [5:0]   pipe_tx3_eqdeemph,
  output  wire                                       pipe_tx3_eqdone,
  output  wire                              [17:0]   pipe_tx3_eqcoeff,
  input   wire                               [1:0]   pipe_rx3_eqcontrol,
  input   wire                               [2:0]   pipe_rx3_eqpreset,
  input   wire                               [5:0]   pipe_rx3_eq_lffs,
  input   wire                               [3:0]   pipe_rx3_eq_txpreset,
  output  wire                              [17:0]   pipe_rx3_eq_new_txcoeff,
  output  wire                                       pipe_rx3_eq_lffs_sel,
  output  wire                                       pipe_rx3_eq_adapt_done,
  output  wire                                       pipe_rx3_eqdone,

  // Pipe Per-Lane Signals - Lane 4
  output  wire                               [1:0]   pipe_rx4_char_is_k,
  output  wire                              [31:0]   pipe_rx4_data,
  output  wire                                       pipe_rx4_valid,
  output  wire                                       pipe_rx4_chanisaligned,
  output  wire                               [2:0]   pipe_rx4_status,
  output  wire                                       pipe_rx4_phy_status,
  output  wire                                       pipe_rx4_elec_idle,
  input   wire                                       pipe_rx4_polarity,
  input   wire                                       pipe_tx4_compliance,
  input   wire                               [1:0]   pipe_tx4_char_is_k,
  input   wire                              [31:0]   pipe_tx4_data,
  input   wire                                       pipe_tx4_elec_idle,
  input   wire                               [1:0]   pipe_tx4_powerdown,
  input   wire                               [1:0]   pipe_tx4_eqcontrol,
  input   wire                               [3:0]   pipe_tx4_eqpreset,
  input   wire                               [5:0]   pipe_tx4_eqdeemph,
  output  wire                                       pipe_tx4_eqdone,
  output  wire                              [17:0]   pipe_tx4_eqcoeff,
  input   wire                               [1:0]   pipe_rx4_eqcontrol,
  input   wire                               [2:0]   pipe_rx4_eqpreset,
  input   wire                               [5:0]   pipe_rx4_eq_lffs,
  input   wire                               [3:0]   pipe_rx4_eq_txpreset,
  output  wire                              [17:0]   pipe_rx4_eq_new_txcoeff,
  output  wire                                       pipe_rx4_eq_lffs_sel,
  output  wire                                       pipe_rx4_eq_adapt_done,
  output  wire                                       pipe_rx4_eqdone,

  // Pipe Per-Lane Signals - Lane 5
  output  wire                               [1:0]   pipe_rx5_char_is_k,
  output  wire                              [31:0]   pipe_rx5_data,
  output  wire                                       pipe_rx5_valid,
  output  wire                                       pipe_rx5_chanisaligned,
  output  wire                               [2:0]   pipe_rx5_status,
  output  wire                                       pipe_rx5_phy_status,
  output  wire                                       pipe_rx5_elec_idle,
  input   wire                                       pipe_rx5_polarity,
  input   wire                                       pipe_tx5_compliance,
  input   wire                               [1:0]   pipe_tx5_char_is_k,
  input   wire                              [31:0]   pipe_tx5_data,
  input   wire                                       pipe_tx5_elec_idle,
  input   wire                               [1:0]   pipe_tx5_powerdown,
  input   wire                               [1:0]   pipe_tx5_eqcontrol,
  input   wire                               [3:0]   pipe_tx5_eqpreset,
  input   wire                               [5:0]   pipe_tx5_eqdeemph,
  output  wire                                       pipe_tx5_eqdone,
  output  wire                              [17:0]   pipe_tx5_eqcoeff,
  input   wire                               [1:0]   pipe_rx5_eqcontrol,
  input   wire                               [2:0]   pipe_rx5_eqpreset,
  input   wire                               [5:0]   pipe_rx5_eq_lffs,
  input   wire                               [3:0]   pipe_rx5_eq_txpreset,
  output  wire                              [17:0]   pipe_rx5_eq_new_txcoeff,
  output  wire                                       pipe_rx5_eq_lffs_sel,
  output  wire                                       pipe_rx5_eq_adapt_done,
  output  wire                                       pipe_rx5_eqdone,

  // Pipe Per-Lane Signals - Lane 6
  output  wire                               [1:0]   pipe_rx6_char_is_k,
  output  wire                              [31:0]   pipe_rx6_data,
  output  wire                                       pipe_rx6_valid,
  output  wire                                       pipe_rx6_chanisaligned,
  output  wire                               [2:0]   pipe_rx6_status,
  output  wire                                       pipe_rx6_phy_status,
  output  wire                                       pipe_rx6_elec_idle,
  input   wire                                       pipe_rx6_polarity,
  input   wire                                       pipe_tx6_compliance,
  input   wire                               [1:0]   pipe_tx6_char_is_k,
  input   wire                              [31:0]   pipe_tx6_data,
  input   wire                                       pipe_tx6_elec_idle,
  input   wire                               [1:0]   pipe_tx6_powerdown,
  input   wire                               [1:0]   pipe_tx6_eqcontrol,
  input   wire                               [3:0]   pipe_tx6_eqpreset,
  input   wire                               [5:0]   pipe_tx6_eqdeemph,
  output  wire                                       pipe_tx6_eqdone,
  output  wire                              [17:0]   pipe_tx6_eqcoeff,
  input   wire                               [1:0]   pipe_rx6_eqcontrol,
  input   wire                               [2:0]   pipe_rx6_eqpreset,
  input   wire                               [5:0]   pipe_rx6_eq_lffs,
  input   wire                               [3:0]   pipe_rx6_eq_txpreset,
  output  wire                              [17:0]   pipe_rx6_eq_new_txcoeff,
  output  wire                                       pipe_rx6_eq_lffs_sel,
  output  wire                                       pipe_rx6_eq_adapt_done,
  output  wire                                       pipe_rx6_eqdone,

  // Pipe Per-Lane Signals - Lane 7
  output  wire                               [1:0]   pipe_rx7_char_is_k,
  output  wire                              [31:0]   pipe_rx7_data,
  output  wire                                       pipe_rx7_valid,
  output  wire                                       pipe_rx7_chanisaligned,
  output  wire                               [2:0]   pipe_rx7_status,
  output  wire                                       pipe_rx7_phy_status,
  output  wire                                       pipe_rx7_elec_idle,
  input   wire                                       pipe_rx7_polarity,
  input   wire                                       pipe_tx7_compliance,
  input   wire                               [1:0]   pipe_tx7_char_is_k,
  input   wire                              [31:0]   pipe_tx7_data,
  input   wire                                       pipe_tx7_elec_idle,
  input   wire                               [1:0]   pipe_tx7_powerdown,
  input   wire                               [1:0]   pipe_tx7_eqcontrol,
  input   wire                               [3:0]   pipe_tx7_eqpreset,
  input   wire                               [5:0]   pipe_tx7_eqdeemph,
  output  wire                                       pipe_tx7_eqdone,
  output  wire                              [17:0]   pipe_tx7_eqcoeff,
  input   wire                               [1:0]   pipe_rx7_eqcontrol,
  input   wire                               [2:0]   pipe_rx7_eqpreset,
  input   wire                               [5:0]   pipe_rx7_eq_lffs,
  input   wire                               [3:0]   pipe_rx7_eq_txpreset,
  output  wire                              [17:0]   pipe_rx7_eq_new_txcoeff,
  output  wire                                       pipe_rx7_eq_lffs_sel,
  output  wire                                       pipe_rx7_eq_adapt_done,
  output  wire                                       pipe_rx7_eqdone,

  // Manual PCIe Equalization Control
  input          [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pipe_rxeq_user_en,
  input       [(PL_LINK_CAP_MAX_LINK_WIDTH*18)-1:0]   pipe_rxeq_user_txcoeff,
  input          [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pipe_rxeq_user_mode,

  // PCIe DRP (PCIe DRP) Interface
  input                                               drp_rdy,
  input                                    [15:0]     drp_do,

  output                                              drp_clk,
  output                                              drp_en,
  output                                              drp_we,
  output                                   [10:0]     drp_addr,
  output                                   [15:0]     drp_di,


  // PCI Express signals
  output  wire [ (PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_txn,
  output  wire [ (PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_txp,
  input   wire [ (PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_rxn,
  input   wire [ (PL_LINK_CAP_MAX_LINK_WIDTH-1):0]   pci_exp_rxp,

  //---------- PIPE Clock & Reset Ports ------------------
  input   wire                                       pipe_clk,               // Reference clock
  input   wire                                       sys_rst_n,              // PCLK       | PCLK
  output  wire                                       rec_clk,                // Recovered Clock
  output  wire                                       pipe_pclk,              // Drives [TX/RX]USRCLK in Gen1/Gen2
  output  wire                                       core_clk,
  output  wire                                       user_clk,
  output  wire                                       phy_rdy,
  output  wire                                       mmcm_lock,
  input						                         pipe_mmcm_rst_n,

//-----------TRANSCEIVER DEBUG--------------------------------


  output      [4:0]               PIPE_RST_FSM,        
  output      [11:0]              PIPE_QRST_FSM,       
  output      [(PL_LINK_CAP_MAX_LINK_WIDTH*5)-1:0] PIPE_RATE_FSM,    
  output      [(PL_LINK_CAP_MAX_LINK_WIDTH*6)-1:0] PIPE_SYNC_FSM_TX, 
  output      [(PL_LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_SYNC_FSM_RX,
  output      [(PL_LINK_CAP_MAX_LINK_WIDTH*7)-1:0] PIPE_DRP_FSM,   

  output                                           PIPE_RST_IDLE,         
  output                                           PIPE_QRST_IDLE,       
  output                                           PIPE_RATE_IDLE,      
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_EYESCANDATAERROR,      
  output      [(PL_LINK_CAP_MAX_LINK_WIDTH*3)-1:0] PIPE_RXSTATUS,
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH*15)-1:0] PIPE_DMONITOROUT,
  //---------- Debug Ports -------------------------------
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_CPLL_LOCK,
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] PIPE_QPLL_LOCK,
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPMARESETDONE,       
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH*3)-1:0]  PIPE_RXBUFSTATUS,         
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHALIGNDONE,       
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXPHINITDONE,        
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_TXDLYSRESETDONE,    
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXPHALIGNDONE,      
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXDLYSRESETDONE,     
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXSYNCDONE,       
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXDISPERR,       
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH*8)-1:0]  PIPE_RXNOTINTABLE,      
  output     [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    PIPE_RXCOMMADET,        

  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_0,      
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_1,     
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_2,    
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_3,   
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_4,  
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_5, 
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_6,
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_7,
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_8,
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_DEBUG_9,      
  output      [31:0]              PIPE_DEBUG,
  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_JTAG_RDY,

  input      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_TXINHIBIT,       
  input     [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]  PIPE_PCSRSVDIN,      
  input       [ 2:0]              PIPE_TXPRBSSEL,        
  input       [ 2:0]              PIPE_RXPRBSSEL,       
  input                           PIPE_TXPRBSFORCEERR, 
  input                           PIPE_RXPRBSCNTRESET, 
  input       [ 2:0]              PIPE_LOOPBACK,      

  output      [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     PIPE_RXPRBSERR,       

  //-----------Channel DRP----------------------------------------
  output                                            ext_ch_gt_drpclk,
  input        [(PL_LINK_CAP_MAX_LINK_WIDTH*9)-1:0] ext_ch_gt_drpaddr,
  input        [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpen,
  input        [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdi,
  input        [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drpwe,
  output       [(PL_LINK_CAP_MAX_LINK_WIDTH*16)-1:0]ext_ch_gt_drpdo,
  output       [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]     ext_ch_gt_drprdy,

//----------- Shared Logic Internal--------------------------------------

  output                                             INT_PCLK_OUT_SLAVE,     // PCLK       | PCLK
  output                                             INT_RXUSRCLK_OUT,       // RXUSERCLK
  output  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]           INT_RXOUTCLK_OUT,       // RX recovered clock
  output                                             INT_DCLK_OUT,           // DCLK       | DCLK
  output                                             INT_USERCLK1_OUT,       // Optional user clock
  output                                             INT_USERCLK2_OUT,       // Optional user clock
  output                                             INT_OOBCLK_OUT,         // OOB        | OOB
  output  [1:0]                                      INT_QPLLLOCK_OUT,
  output  [1:0]                                      INT_QPLLOUTCLK_OUT,
  output  [1:0]                                      INT_QPLLOUTREFCLK_OUT,
  input   [(PL_LINK_CAP_MAX_LINK_WIDTH-1):0]         INT_PCLK_SEL_SLAVE,

  // Shared Logic External
    //---------- External GT COMMON Ports ----------------------
  input                                     [11:0]   qpll_drp_crscode,
  input                                     [17:0]   qpll_drp_fsm,
  input                                     [1:0]    qpll_drp_done,
  input                                     [1:0]    qpll_drp_reset,
  input                                     [1:0]    qpll_qplllock,
  input                                     [1:0]    qpll_qplloutclk,
  input                                     [1:0]    qpll_qplloutrefclk,
  output                                             qpll_qplld,
  output                                    [1:0]    qpll_qpllreset,
  output                                             qpll_drp_clk,
  output                                             qpll_drp_rst_n,
  output                                             qpll_drp_ovrd,
  output                                             qpll_drp_gen3,
  output                                             qpll_drp_start,

  //---------- External Clock Ports ----------------------
  input                                              PIPE_PCLK_IN,           // PCLK       | PCLK
  input                                              PIPE_RXUSRCLK_IN,       // RXUSERCLK
  
  input  [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]            PIPE_RXOUTCLK_IN,       // RX recovered clock
  input                                              PIPE_DCLK_IN,           // DCLK       | DCLK
  input                                              PIPE_USERCLK1_IN,       // Optional user clock
  input                                              PIPE_USERCLK2_IN,       // Optional user clock
  input                                              PIPE_OOBCLK_IN,         // OOB        | OOB
  input                                              PIPE_MMCM_LOCK_IN,      // Async      | Async
  output                                             PIPE_TXOUTCLK_OUT,      // PCLK       | PCLK
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]            PIPE_RXOUTCLK_OUT,      // RX recovered clock (for debug only)
  output [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]            PIPE_PCLK_SEL_OUT,      // PCLK       | PCLK
  output                                             PIPE_GEN3_OUT,          // PCLK       | PCLK
  
  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    CPLLPD, 
  input [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]  TXPD,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH*2)-1:0]  RXPD,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    TXPDELECIDLEMODE,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    TXDETECTRX,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH)-1:0]    TXELECIDLE,
  input [(PL_LINK_CAP_MAX_LINK_WIDTH-1)>>2:0] QPLLPD, 
  input                                       POWERDOWN
);

  wire  [31:0]  gt_rx_data_k_wire;
  wire [255:0]  gt_rx_data_wire;
  wire   [7:0]  gt_rx_valid_wire;
  wire   [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]  gt_rxchanisaligned_wire;
  wire  [23:0]  gt_rx_status_wire;
  wire   [7:0]  gt_rx_phy_status_wire;
  wire   [7:0]  gt_rx_elec_idle_wire;
  wire   [7:0]  gt_rx_polarity;

  wire  [31:0]  gt_tx_data_k;
  wire [255:0]  gt_tx_data;
  wire   [7:0]  gt_tx_elec_idle;
  wire   [7:0]  gt_tx_compliance;
  wire  [15:0]  gt_power_down;

  wire  [15:0]  gt_tx_eq_control;
  wire  [31:0]  gt_tx_eq_preset;
  wire  [47:0]  gt_tx_eq_deemph;
  wire   [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]  gt_tx_eq_done;

  wire  [15:0]  gt_rx_eq_control;
  wire  [23:0]  gt_rx_eq_preset;
  wire  [47:0]  gt_rx_eq_lffs;
  wire  [31:0]  gt_rx_eq_txpreset;
  wire [143:0]  gt_rx_eq_new_txcoeff;
  wire [143:0]  gt_tx_eq_coeff;
  wire   [7:0]  gt_rx_eq_lffs_sel;
  wire   [7:0]  gt_rx_eq_adapt_done;
  wire   [7:0]  gt_rx_eq_done;

  wire          gt_tx_detect_rx_loopback;
  wire   [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]  pipe_phystatus_rst;

  wire          clock_locked;
  wire          phy_rdy_int;
  reg    [1:0]  reg_clock_locked;
  reg    [1:0]  reg_phy_rdy;
  wire   [PL_LINK_CAP_MAX_LINK_WIDTH-1:0]  pipe_rxsync_done_w;
  assign pipe_rxsync_done = {{(8-PL_LINK_CAP_MAX_LINK_WIDTH){1'b0}},pipe_rxsync_done_w};

  localparam          PCIE_SIM_SPEEDUP   = PL_SIM_FAST_LINK_TRAINING;


//---------- PIPE wrapper Module -------------------------------------------------
xdma_0_pcie3_ip_pipe_wrapper #(
    .PCIE_SIM_MODE            ( PL_SIM_FAST_LINK_TRAINING ),
    .PCIE_SIM_SPEEDUP         ( PCIE_SIM_SPEEDUP ),
    .PCIE_AUX_CDR_GEN3_EN     ( "TRUE" ),
    .PCIE_ASYNC_EN            ( PCIE_ASYNC_EN ),
    .PCIE_EXT_CLK             ( PCIE_EXT_CLK ),
    .PCIE_EXT_GT_COMMON       ( PCIE_EXT_GT_COMMON ),
    .PCIE_TXBUF_EN            ( PCIE_TXBUF_EN ),
    .PCIE_GT_DEVICE           ( PCIE_GT_DEVICE ),
    .PCIE_CHAN_BOND           ( PCIE_CHAN_BOND ),
    .PCIE_CHAN_BOND_EN        ( PCIE_CHAN_BOND_EN ),
    .PCIE_USE_MODE            ( PCIE_USE_MODE ),
    .PCIE_LPM_DFE             ( PCIE_LPM_DFE ),
    .PCIE_LINK_SPEED          ( PCIE_LINK_SPEED ),              // No longer used to indicate link speed - Static value at 3
    .PL_LINK_CAP_MAX_LINK_SPEED ( PL_LINK_CAP_MAX_LINK_SPEED ), // PCIe link speed; 1=Gen1; 2=Gen2; 4=Gen3
    .PCIE_LANE                ( PL_LINK_CAP_MAX_LINK_WIDTH ),
    .PCIE_REFCLK_FREQ         ( REF_CLK_FREQ ),
    .TX_MARGIN_FULL_0         (TX_MARGIN_FULL_0),                          // 1000 mV
    .TX_MARGIN_FULL_1         (TX_MARGIN_FULL_1),                          // 950 mV
    .TX_MARGIN_FULL_2         (TX_MARGIN_FULL_2),                          // 900 mV
    .TX_MARGIN_FULL_3         (TX_MARGIN_FULL_3),                          // 850 mV
    .TX_MARGIN_FULL_4         (TX_MARGIN_FULL_4),                          // 400 mV
    .TX_MARGIN_LOW_0          (TX_MARGIN_LOW_0),                          // 500 mV
    .TX_MARGIN_LOW_1          (TX_MARGIN_LOW_1),                          // 450 mV
    .TX_MARGIN_LOW_2          (TX_MARGIN_LOW_2),                          // 400 mV
    .TX_MARGIN_LOW_3          (TX_MARGIN_LOW_3),                          // 350 mV
    .TX_MARGIN_LOW_4          (TX_MARGIN_LOW_4),
    .PCIE_USERCLK1_FREQ       ( USER_CLK_FREQ ),
    .PCIE_USERCLK2_FREQ       ( USER_CLK2_FREQ )
) pipe_wrapper_i (

    //---------- PIPE Clock & Reset Ports ------------------
    .PIPE_CLK                 ( pipe_clk ),
    .PIPE_RESET_N             ( sys_rst_n ),

    .PIPE_PCLK                ( pipe_pclk ),

    //---------- PIPE TX Data Ports ------------------------
    .PIPE_TXDATA              ( gt_tx_data[((32*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXDATAK             ( gt_tx_data_k[((4*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),

    .PIPE_TXP                 ( pci_exp_txp[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXN                 ( pci_exp_txn[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),

    //---------- PIPE RX Data Ports ------------------------
    .PIPE_RXP                 ( pci_exp_rxp[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXN                 ( pci_exp_rxn[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),

    .PIPE_RXDATA              ( gt_rx_data_wire[((32*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXDATAK             ( gt_rx_data_k_wire[((4*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),

    //---------- PIPE Command Ports ------------------------
    .PIPE_TXDETECTRX          ( gt_tx_detect_rx_loopback    ),
    .PIPE_TXELECIDLE          ( gt_tx_elec_idle[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXCOMPLIANCE        ( gt_tx_compliance[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXPOLARITY          ( gt_rx_polarity[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_POWERDOWN           ( gt_power_down[((2*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RATE                ( pipe_tx_rate ),

    //---------- PIPE Electrical Command Ports -------------
    .PIPE_TXMARGIN            ( pipe_tx_margin ),
    .PIPE_TXSWING             ( pipe_tx_swing  ),
    .PIPE_TXDEEMPH            ( {PL_LINK_CAP_MAX_LINK_WIDTH{pipe_tx_deemph}}),
    .PIPE_TXEQ_CONTROL        ( gt_tx_eq_control[((2*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXEQ_PRESET         ( gt_tx_eq_preset[((4*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXEQ_PRESET_DEFAULT ( {PL_LINK_CAP_MAX_LINK_WIDTH{4'b0}} ),                       // TX Preset Default when reset lifted

    .PIPE_RXEQ_CONTROL        ( gt_rx_eq_control[((2*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_PRESET         ( gt_rx_eq_preset[((3*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_LFFS           ( gt_rx_eq_lffs[((6*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_TXPRESET       ( gt_rx_eq_txpreset[((4*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_USER_EN        ( pipe_rxeq_user_en ),         // EQUALIZATION Workaround signals
    .PIPE_RXEQ_USER_TXCOEFF   ( pipe_rxeq_user_txcoeff ),    // EQUALIZATION Workaround signals
    .PIPE_RXEQ_USER_MODE      ( pipe_rxeq_user_mode ),       // EQUALIZATION Workaround signals

    .PIPE_TXEQ_FS             ( pipe_txeq_fs ),
    .PIPE_TXEQ_LF             ( pipe_txeq_lf ),
    .PIPE_TXEQ_DEEMPH         ( gt_tx_eq_deemph[((6*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXEQ_DONE           ( gt_tx_eq_done ),
    .PIPE_TXEQ_COEFF          ( gt_tx_eq_coeff[((18*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_NEW_TXCOEFF    ( gt_rx_eq_new_txcoeff[((18*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_LFFS_SEL       ( gt_rx_eq_lffs_sel[((1*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_ADAPT_DONE     ( gt_rx_eq_adapt_done[((1*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXEQ_DONE           ( gt_rx_eq_done[((1*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),

    //---------- PIPE Status Ports -------------------------
    .PIPE_RXVALID             ( gt_rx_valid_wire[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_PHYSTATUS           ( gt_rx_phy_status_wire[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_PHYSTATUS_RST       ( pipe_phystatus_rst ),
    .PIPE_RXELECIDLE          ( gt_rx_elec_idle_wire[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXSTATUS            ( gt_rx_status_wire[((3*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_EYESCANDATAERROR    ( PIPE_EYESCANDATAERROR ),
    //---------- PIPE User Ports ---------------------------
    .PIPE_MMCM_RST_N          (pipe_mmcm_rst_n),
    .PIPE_RXSLIDE             ( pipe_rxslide[((PL_LINK_CAP_MAX_LINK_WIDTH)-1):0] ),

    .PIPE_CPLL_LOCK           ( PIPE_CPLL_LOCK ),
    .PIPE_QPLL_LOCK           ( PIPE_QPLL_LOCK),
    .PIPE_PCLK_LOCK           ( mmcm_lock ),
    .PIPE_RXCDRLOCK           ( ),
    .PIPE_USERCLK1            ( core_clk ),     //500MHz for GEN3
    .PIPE_USERCLK2            ( user_clk ),
    .PIPE_RXUSRCLK            ( rec_clk ),

    .PIPE_RXOUTCLK            ( ),
    .PIPE_TXSYNC_DONE         ( ),
    .PIPE_RXSYNC_DONE         ( ),
    .PIPE_GEN3_RDY            ( pipe_rxsync_done_w ),
    .PIPE_RXCHANISALIGNED     ( gt_rxchanisaligned_wire ),
    .PIPE_ACTIVE_LANE         ( ),

// ----------Shared Logic Internal----------------------
    .INT_PCLK_OUT_SLAVE      ( INT_PCLK_OUT_SLAVE ),
    .INT_RXUSRCLK_OUT        ( INT_RXUSRCLK_OUT ),
    .INT_RXOUTCLK_OUT        ( INT_RXOUTCLK_OUT ),
    .INT_DCLK_OUT            ( INT_DCLK_OUT ),
    .INT_USERCLK1_OUT        ( INT_USERCLK1_OUT ),
    .INT_USERCLK2_OUT        ( INT_USERCLK2_OUT),
    .INT_OOBCLK_OUT          ( INT_OOBCLK_OUT ),
    .INT_PCLK_SEL_SLAVE      ( INT_PCLK_SEL_SLAVE ),
    .INT_QPLLLOCK_OUT        ( INT_QPLLLOCK_OUT ),
    .INT_QPLLOUTCLK_OUT      ( INT_QPLLOUTCLK_OUT ),
    .INT_QPLLOUTREFCLK_OUT   ( INT_QPLLOUTREFCLK_OUT ),
    // ---------- Shared Logic External----------------------
    //---------- External Clock Ports ----------------------
    .PIPE_PCLK_IN             ( PIPE_PCLK_IN ),
    .PIPE_RXUSRCLK_IN         ( PIPE_RXUSRCLK_IN ),

    .PIPE_RXOUTCLK_IN         ( PIPE_RXOUTCLK_IN ),
    .PIPE_DCLK_IN             ( PIPE_DCLK_IN ),
    .PIPE_USERCLK1_IN         ( PIPE_USERCLK1_IN ),
    .PIPE_USERCLK2_IN         ( PIPE_USERCLK2_IN ),
    .PIPE_OOBCLK_IN           ( PIPE_OOBCLK_IN ),
    .PIPE_MMCM_LOCK_IN        ( PIPE_MMCM_LOCK_IN ),

    .PIPE_TXOUTCLK_OUT        ( PIPE_TXOUTCLK_OUT ),
    .PIPE_RXOUTCLK_OUT        ( PIPE_RXOUTCLK_OUT ),
    .PIPE_PCLK_SEL_OUT        ( PIPE_PCLK_SEL_OUT ),
    .PIPE_GEN3_OUT            ( PIPE_GEN3_OUT ),

    //---------- External GT COMMON Ports ----------------------
    .QPLL_DRP_CRSCODE         ( qpll_drp_crscode ),
    .QPLL_DRP_FSM             ( qpll_drp_fsm ),       
    .QPLL_DRP_DONE            ( qpll_drp_done ),   
    .QPLL_DRP_RESET           ( qpll_drp_reset ),     
    .QPLL_QPLLLOCK            ( qpll_qplllock ),       
    .QPLL_QPLLOUTCLK          ( qpll_qplloutclk ),       
    .QPLL_QPLLOUTREFCLK       ( qpll_qplloutrefclk ),     
    .QPLL_QPLLPD              ( qpll_qplld ),            
    .QPLL_QPLLRESET           ( qpll_qpllreset ),       
    .QPLL_DRP_CLK             ( qpll_drp_clk ),       
    .QPLL_DRP_RST_N           ( qpll_drp_rst_n ),       
    .QPLL_DRP_OVRD            ( qpll_drp_ovrd ),       
    .QPLL_DRP_GEN3            ( qpll_drp_gen3 ),       
    .QPLL_DRP_START           ( qpll_drp_start ), 

    //--------TRANSCEIVER DEBUG EOU------------------
   .EXT_CH_GT_DRPCLK          (ext_ch_gt_drpclk),
   .EXT_CH_GT_DRPADDR         (ext_ch_gt_drpaddr),
   .EXT_CH_GT_DRPEN           (ext_ch_gt_drpen),
   .EXT_CH_GT_DRPDI           (ext_ch_gt_drpdi),
   .EXT_CH_GT_DRPWE           (ext_ch_gt_drpwe),
   .EXT_CH_GT_DRPDO           (ext_ch_gt_drpdo),
   .EXT_CH_GT_DRPRDY          (ext_ch_gt_drprdy),      

    //---------- TRANSCEIVER DEBUG -----------------------
    .PIPE_TXPRBSSEL           ( PIPE_TXPRBSSEL ),
    .PIPE_RXPRBSSEL           ( PIPE_RXPRBSSEL ),
    .PIPE_TXPRBSFORCEERR      ( PIPE_TXPRBSFORCEERR ),
    .PIPE_RXPRBSCNTRESET      ( PIPE_RXPRBSCNTRESET ),
    .PIPE_LOOPBACK            ( PIPE_LOOPBACK),

    .PIPE_RXPRBSERR           ( PIPE_RXPRBSERR),
    .PIPE_TXINHIBIT           ( PIPE_TXINHIBIT),
    .PIPE_PCSRSVDIN           ( PIPE_PCSRSVDIN),

    .PIPE_RST_FSM             (PIPE_RST_FSM),
    .PIPE_QRST_FSM            (PIPE_QRST_FSM),
    .PIPE_RATE_FSM            (PIPE_RATE_FSM ),
    .PIPE_SYNC_FSM_TX         (PIPE_SYNC_FSM_TX ),
    .PIPE_SYNC_FSM_RX         (PIPE_SYNC_FSM_RX ),
    .PIPE_DRP_FSM             (PIPE_DRP_FSM ),

    .PIPE_RST_IDLE            (PIPE_RST_IDLE ),
    .PIPE_QRST_IDLE           (PIPE_QRST_IDLE ),
    .PIPE_RATE_IDLE           (PIPE_RATE_IDLE ),

    //---------- JTAG Ports --------------------------------
    .PIPE_JTAG_EN              ( 1'b0 ),
    .PIPE_JTAG_RDY             (PIPE_JTAG_RDY ),

    //---------- Debug Ports -------------------------------
    .PIPE_RXPMARESETDONE     ( PIPE_RXPMARESETDONE ),       
    .PIPE_RXBUFSTATUS        ( PIPE_RXBUFSTATUS    ),         
    .PIPE_TXPHALIGNDONE      ( PIPE_TXPHALIGNDONE  ),       
    .PIPE_TXPHINITDONE       ( PIPE_TXPHINITDONE   ),        
    .PIPE_TXDLYSRESETDONE    ( PIPE_TXDLYSRESETDONE),    
    .PIPE_RXPHALIGNDONE      ( PIPE_RXPHALIGNDONE  ),      
    .PIPE_RXDLYSRESETDONE    ( PIPE_RXDLYSRESETDONE),     
    .PIPE_RXSYNCDONE         ( PIPE_RXSYNCDONE     ),       
    .PIPE_RXDISPERR          ( PIPE_RXDISPERR      ),       
    .PIPE_RXNOTINTABLE       ( PIPE_RXNOTINTABLE   ),      
    .PIPE_RXCOMMADET         ( PIPE_RXCOMMADET     ),        

    .PIPE_DEBUG_0             (PIPE_DEBUG_0 ),
    .PIPE_DEBUG_1             (PIPE_DEBUG_1 ),
    .PIPE_DEBUG_2             (PIPE_DEBUG_2  ),
    .PIPE_DEBUG_3             (PIPE_DEBUG_3 ),
    .PIPE_DEBUG_4             (PIPE_DEBUG_4  ),
    .PIPE_DEBUG_5             (PIPE_DEBUG_5  ),
    .PIPE_DEBUG_6             (PIPE_DEBUG_6  ),
    .PIPE_DEBUG_7             (PIPE_DEBUG_7  ),
    .PIPE_DEBUG_8             (PIPE_DEBUG_8 ),
    .PIPE_DEBUG_9             (PIPE_DEBUG_9  ),
    .PIPE_DEBUG               (PIPE_DEBUG),

    .PIPE_RXEQ_CONVERGE       ( ),
    .PIPE_DMONITOROUT         ( PIPE_DMONITOROUT ),
    .PIPE_QDRP_FSM(),
    .PIPE_RXEQ_FSM(),
    .PIPE_TXEQ_FSM(),
    .INT_MMCM_LOCK_OUT(),
    .CPLLPD                   (CPLLPD),
    .TXPD                     (TXPD),
    .RXPD                     (RXPD),
    .TXPDELECIDLEMODE         (TXPDELECIDLEMODE),
    .TXDETECTRX               (TXDETECTRX),
    .TXELECIDLE               (TXELECIDLE),
    .QPLLPD                   (QPLLPD),
    .POWERDOWN                (POWERDOWN)

);

assign PIPE_RXSTATUS = gt_rx_status_wire[((3*PL_LINK_CAP_MAX_LINK_WIDTH)-1):0];

// Concatenate/Deconcatenate busses to generate correct GT wrapper and PCIe Block connectivity
assign pipe_rx0_phy_status = gt_rx_phy_status_wire[0] ;
assign pipe_rx1_phy_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_phy_status_wire[1] : 1'b0;
assign pipe_rx2_phy_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_phy_status_wire[2] : 1'b0;
assign pipe_rx3_phy_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_phy_status_wire[3] : 1'b0;
assign pipe_rx4_phy_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_phy_status_wire[4] : 1'b0;
assign pipe_rx5_phy_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_phy_status_wire[5] : 1'b0;
assign pipe_rx6_phy_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_phy_status_wire[6] : 1'b0;
assign pipe_rx7_phy_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_phy_status_wire[7] : 1'b0;


assign {pipe_rx7_chanisaligned,pipe_rx6_chanisaligned,pipe_rx5_chanisaligned,pipe_rx4_chanisaligned,pipe_rx3_chanisaligned,pipe_rx2_chanisaligned,pipe_rx1_chanisaligned,pipe_rx0_chanisaligned} = {{(8-PL_LINK_CAP_MAX_LINK_WIDTH){1'b0}},gt_rxchanisaligned_wire};

assign pipe_rx0_char_is_k =  {gt_rx_data_k_wire[1], gt_rx_data_k_wire[0]};
assign pipe_rx1_char_is_k =  (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? {gt_rx_data_k_wire[5], gt_rx_data_k_wire[4]} : 2'b0;
assign pipe_rx2_char_is_k =  (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? {gt_rx_data_k_wire[9], gt_rx_data_k_wire[8]} : 2'b0;
assign pipe_rx3_char_is_k =  (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? {gt_rx_data_k_wire[13], gt_rx_data_k_wire[12]} : 2'b0;
assign pipe_rx4_char_is_k =  (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? {gt_rx_data_k_wire[17], gt_rx_data_k_wire[16]} : 2'b0;
assign pipe_rx5_char_is_k =  (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? {gt_rx_data_k_wire[21], gt_rx_data_k_wire[20]} : 2'b0;
assign pipe_rx6_char_is_k =  (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? {gt_rx_data_k_wire[25], gt_rx_data_k_wire[24]} : 2'b0;
assign pipe_rx7_char_is_k =  (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? {gt_rx_data_k_wire[29], gt_rx_data_k_wire[28]} : 2'b0;

assign pipe_rx0_data = {gt_rx_data_wire[31: 0]};
assign pipe_rx1_data = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_data_wire[63:32] : 32'h0;
assign pipe_rx2_data = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_data_wire[95:64] : 32'h0;
assign pipe_rx3_data = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_data_wire[127:96] : 32'h0;
assign pipe_rx4_data = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_data_wire[159:128] : 32'h0;
assign pipe_rx5_data = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_data_wire[191:160] : 32'h0;
assign pipe_rx6_data = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_data_wire[223:192] : 32'h0;
assign pipe_rx7_data = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_data_wire[255:224] : 32'h0;

assign pipe_rx0_elec_idle = gt_rx_elec_idle_wire[0];   // workaround pcie_tx_elec_idle_filter
assign pipe_rx1_elec_idle = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_elec_idle_wire[1] : 1'b1;
assign pipe_rx2_elec_idle = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_elec_idle_wire[2] : 1'b1;
assign pipe_rx3_elec_idle = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_elec_idle_wire[3] : 1'b1;
assign pipe_rx4_elec_idle = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_elec_idle_wire[4] : 1'b1;
assign pipe_rx5_elec_idle = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_elec_idle_wire[5] : 1'b1;
assign pipe_rx6_elec_idle = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_elec_idle_wire[6] : 1'b1;
assign pipe_rx7_elec_idle = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_elec_idle_wire[7] : 1'b1;

assign pipe_rx0_status = gt_rx_status_wire[ 2: 0];
assign pipe_rx1_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_status_wire[ 5: 3] : 3'b0;
assign pipe_rx2_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_status_wire[ 8: 6] : 3'b0;
assign pipe_rx3_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_status_wire[11: 9] : 3'b0;
assign pipe_rx4_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_status_wire[14:12] : 3'b0;
assign pipe_rx5_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_status_wire[17:15] : 3'b0;
assign pipe_rx6_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_status_wire[20:18] : 3'b0;
assign pipe_rx7_status = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_status_wire[23:21] : 3'b0;

assign pipe_rx0_valid = gt_rx_valid_wire[0];
assign pipe_rx1_valid = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_valid_wire[1] : 1'b0;
assign pipe_rx2_valid = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_valid_wire[2] : 1'b0;
assign pipe_rx3_valid = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_valid_wire[3] : 1'b0;
assign pipe_rx4_valid = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_valid_wire[4] : 1'b0;
assign pipe_rx5_valid = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_valid_wire[5] : 1'b0;
assign pipe_rx6_valid = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_valid_wire[6] : 1'b0;
assign pipe_rx7_valid = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_valid_wire[7] : 1'b0;

assign gt_rx_polarity[0] = pipe_rx0_polarity;
assign gt_rx_polarity[1] = pipe_rx1_polarity;
assign gt_rx_polarity[2] = pipe_rx2_polarity;
assign gt_rx_polarity[3] = pipe_rx3_polarity;
assign gt_rx_polarity[4] = pipe_rx4_polarity;
assign gt_rx_polarity[5] = pipe_rx5_polarity;
assign gt_rx_polarity[6] = pipe_rx6_polarity;
assign gt_rx_polarity[7] = pipe_rx7_polarity;

assign gt_power_down[ 1: 0] = pipe_tx0_powerdown;
assign gt_power_down[ 3: 2] = pipe_tx1_powerdown;
assign gt_power_down[ 5: 4] = pipe_tx2_powerdown;
assign gt_power_down[ 7: 6] = pipe_tx3_powerdown;
assign gt_power_down[ 9: 8] = pipe_tx4_powerdown;
assign gt_power_down[11:10] = pipe_tx5_powerdown;
assign gt_power_down[13:12] = pipe_tx6_powerdown;
assign gt_power_down[15:14] = pipe_tx7_powerdown;

// Removed gt_tx_char_disp_mode = pipe_tx_compliance_q.
//   Moved logic to pcie_tx_elec_idle_filtered.

assign gt_tx_data_k = {2'd0,
                       pipe_tx7_char_is_k,
                       2'd0,
                       pipe_tx6_char_is_k,
                       2'd0,
                       pipe_tx5_char_is_k,
                       2'd0,
                       pipe_tx4_char_is_k,
                       2'd0,
                       pipe_tx3_char_is_k,
                       2'd0,
                       pipe_tx2_char_is_k,
                       2'd0,
                       pipe_tx1_char_is_k,
                       2'd0,
                       pipe_tx0_char_is_k};

assign gt_tx_data = {pipe_tx7_data,
                     pipe_tx6_data,
                     pipe_tx5_data,
                     pipe_tx4_data,
                     pipe_tx3_data,
                     pipe_tx2_data,
                     pipe_tx1_data,
                     pipe_tx0_data};

assign gt_tx_detect_rx_loopback = pipe_tx_rcvr_det;

assign gt_tx_elec_idle = {pipe_tx7_elec_idle,
                          pipe_tx6_elec_idle,
                          pipe_tx5_elec_idle,
                          pipe_tx4_elec_idle,
                          pipe_tx3_elec_idle,
                          pipe_tx2_elec_idle,
                          pipe_tx1_elec_idle,
                          pipe_tx0_elec_idle};



assign gt_tx_compliance = {pipe_tx7_compliance,
                          pipe_tx6_compliance,
                          pipe_tx5_compliance,
                          pipe_tx4_compliance,
                          pipe_tx3_compliance,
                          pipe_tx2_compliance,
                          pipe_tx1_compliance,
                          pipe_tx0_compliance};

assign                                 drp_clk=1'b0;
assign                                 drp_en=1'b0;
assign                                 drp_we=1'b0;
assign                                 drp_addr=11'b0;
assign                                 drp_di=16'b0;


assign gt_tx_eq_control[ 1: 0] = pipe_tx0_eqcontrol;
assign gt_tx_eq_control[ 3: 2] = pipe_tx1_eqcontrol;
assign gt_tx_eq_control[ 5: 4] = pipe_tx2_eqcontrol;
assign gt_tx_eq_control[ 7: 6] = pipe_tx3_eqcontrol;
assign gt_tx_eq_control[ 9: 8] = pipe_tx4_eqcontrol;
assign gt_tx_eq_control[11:10] = pipe_tx5_eqcontrol;
assign gt_tx_eq_control[13:12] = pipe_tx6_eqcontrol;
assign gt_tx_eq_control[15:14] = pipe_tx7_eqcontrol;

assign gt_tx_eq_preset[3:0]   = pipe_tx0_eqpreset;
assign gt_tx_eq_preset[7:4]   = pipe_tx1_eqpreset;
assign gt_tx_eq_preset[11:8]  = pipe_tx2_eqpreset;
assign gt_tx_eq_preset[15:12] = pipe_tx3_eqpreset;
assign gt_tx_eq_preset[19:16] = pipe_tx4_eqpreset;
assign gt_tx_eq_preset[23:20] = pipe_tx5_eqpreset;
assign gt_tx_eq_preset[27:24] = pipe_tx6_eqpreset;
assign gt_tx_eq_preset[31:28] = pipe_tx7_eqpreset;

assign gt_tx_eq_deemph[5:0] = pipe_tx0_eqdeemph;
assign gt_tx_eq_deemph[11:6] = pipe_tx1_eqdeemph;
assign gt_tx_eq_deemph[17:12] = pipe_tx2_eqdeemph;
assign gt_tx_eq_deemph[23:18] = pipe_tx3_eqdeemph;
assign gt_tx_eq_deemph[29:24] = pipe_tx4_eqdeemph;
assign gt_tx_eq_deemph[35:30] = pipe_tx5_eqdeemph;
assign gt_tx_eq_deemph[41:36] = pipe_tx6_eqdeemph;
assign gt_tx_eq_deemph[47:42] = pipe_tx7_eqdeemph;
 
assign {pipe_tx7_eqdone,pipe_tx6_eqdone,pipe_tx5_eqdone,pipe_tx4_eqdone,pipe_tx3_eqdone,pipe_tx2_eqdone,pipe_tx1_eqdone,pipe_tx0_eqdone} = {{(8-PL_LINK_CAP_MAX_LINK_WIDTH){1'b0}},gt_tx_eq_done};


assign pipe_tx0_eqcoeff = gt_tx_eq_coeff[17:0];
assign pipe_tx1_eqcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_tx_eq_coeff[35:18]   : 18'b0;
assign pipe_tx2_eqcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_tx_eq_coeff[53:36]   : 18'b0;
assign pipe_tx3_eqcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_tx_eq_coeff[71:54]   : 18'b0;
assign pipe_tx4_eqcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_tx_eq_coeff[89:72]   : 18'b0;
assign pipe_tx5_eqcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_tx_eq_coeff[107:90]  : 18'b0;
assign pipe_tx6_eqcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_tx_eq_coeff[125:108] : 18'b0;
assign pipe_tx7_eqcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_tx_eq_coeff[143:126] : 18'b0;

assign gt_rx_eq_control[ 1: 0] = pipe_rx0_eqcontrol;
assign gt_rx_eq_control[ 3: 2] = pipe_rx1_eqcontrol;
assign gt_rx_eq_control[ 5: 4] = pipe_rx2_eqcontrol;
assign gt_rx_eq_control[ 7: 6] = pipe_rx3_eqcontrol;
assign gt_rx_eq_control[ 9: 8] = pipe_rx4_eqcontrol;
assign gt_rx_eq_control[11:10] = pipe_rx5_eqcontrol;
assign gt_rx_eq_control[13:12] = pipe_rx6_eqcontrol;
assign gt_rx_eq_control[15:14] = pipe_rx7_eqcontrol;

assign gt_rx_eq_preset[2:0]   = pipe_rx0_eqpreset;
assign gt_rx_eq_preset[5:3]   = pipe_rx1_eqpreset;
assign gt_rx_eq_preset[8:6]   = pipe_rx2_eqpreset;
assign gt_rx_eq_preset[11:9]  = pipe_rx3_eqpreset;
assign gt_rx_eq_preset[14:12] = pipe_rx4_eqpreset;
assign gt_rx_eq_preset[17:15] = pipe_rx5_eqpreset;
assign gt_rx_eq_preset[20:18] = pipe_rx6_eqpreset;
assign gt_rx_eq_preset[23:21] = pipe_rx7_eqpreset;

assign gt_rx_eq_lffs[5:0]   = pipe_rx0_eq_lffs;
assign gt_rx_eq_lffs[11:6]  = pipe_rx1_eq_lffs;
assign gt_rx_eq_lffs[17:12] = pipe_rx2_eq_lffs;
assign gt_rx_eq_lffs[23:18] = pipe_rx3_eq_lffs;
assign gt_rx_eq_lffs[29:24] = pipe_rx4_eq_lffs;
assign gt_rx_eq_lffs[35:30] = pipe_rx5_eq_lffs;
assign gt_rx_eq_lffs[41:36] = pipe_rx6_eq_lffs;
assign gt_rx_eq_lffs[47:42] = pipe_rx7_eq_lffs;

assign gt_rx_eq_txpreset[3:0]   = pipe_rx0_eq_txpreset;
assign gt_rx_eq_txpreset[7:4]   = pipe_rx1_eq_txpreset;
assign gt_rx_eq_txpreset[11:8]  = pipe_rx2_eq_txpreset;
assign gt_rx_eq_txpreset[15:12] = pipe_rx3_eq_txpreset;
assign gt_rx_eq_txpreset[19:16] = pipe_rx4_eq_txpreset;
assign gt_rx_eq_txpreset[23:20] = pipe_rx5_eq_txpreset;
assign gt_rx_eq_txpreset[27:24] = pipe_rx6_eq_txpreset;
assign gt_rx_eq_txpreset[31:28] = pipe_rx7_eq_txpreset;

assign pipe_rx0_eq_new_txcoeff = gt_rx_eq_new_txcoeff[17:0] ;
assign pipe_rx1_eq_new_txcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_eq_new_txcoeff[35:18]   : 1'b0;
assign pipe_rx2_eq_new_txcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_new_txcoeff[53:36]   : 1'b0;
assign pipe_rx3_eq_new_txcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_new_txcoeff[71:54]   : 1'b0;
assign pipe_rx4_eq_new_txcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_new_txcoeff[89:72]   : 1'b0;
assign pipe_rx5_eq_new_txcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_new_txcoeff[107:90]  : 1'b0;
assign pipe_rx6_eq_new_txcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_new_txcoeff[125:108] : 1'b0;
assign pipe_rx7_eq_new_txcoeff = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_new_txcoeff[143:126] : 1'b0;

assign pipe_rx0_eq_lffs_sel = gt_rx_eq_lffs_sel[0];
assign pipe_rx1_eq_lffs_sel = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_eq_lffs_sel[1] : 1'b0;
assign pipe_rx2_eq_lffs_sel = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_lffs_sel[2] : 1'b0;
assign pipe_rx3_eq_lffs_sel = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_lffs_sel[3] : 1'b0;
assign pipe_rx4_eq_lffs_sel = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_lffs_sel[4] : 1'b0;
assign pipe_rx5_eq_lffs_sel = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_lffs_sel[5] : 1'b0;
assign pipe_rx6_eq_lffs_sel = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_lffs_sel[6] : 1'b0;
assign pipe_rx7_eq_lffs_sel = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_lffs_sel[7] : 1'b0;

assign pipe_rx0_eq_adapt_done = gt_rx_eq_adapt_done[0];
assign pipe_rx1_eq_adapt_done = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_eq_adapt_done[1] : 1'b0;
assign pipe_rx2_eq_adapt_done = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_adapt_done[2] : 1'b0;
assign pipe_rx3_eq_adapt_done = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_adapt_done[3] : 1'b0;
assign pipe_rx4_eq_adapt_done = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_adapt_done[4] : 1'b0;
assign pipe_rx5_eq_adapt_done = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_adapt_done[5] : 1'b0;
assign pipe_rx6_eq_adapt_done = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_adapt_done[6] : 1'b0;
assign pipe_rx7_eq_adapt_done = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_adapt_done[7] : 1'b0;

assign pipe_rx0_eqdone = gt_rx_eq_done[0];
assign pipe_rx1_eqdone = (PL_LINK_CAP_MAX_LINK_WIDTH >= 2 ) ? gt_rx_eq_done[1] : 1'b0;
assign pipe_rx2_eqdone = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_done[2] : 1'b0;
assign pipe_rx3_eqdone = (PL_LINK_CAP_MAX_LINK_WIDTH >= 4 ) ? gt_rx_eq_done[3] : 1'b0;
assign pipe_rx4_eqdone = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_done[4] : 1'b0;
assign pipe_rx5_eqdone = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_done[5] : 1'b0;
assign pipe_rx6_eqdone = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_done[6] : 1'b0;
assign pipe_rx7_eqdone = (PL_LINK_CAP_MAX_LINK_WIDTH >= 8 ) ? gt_rx_eq_done[7] : 1'b0;

assign phy_rdy_int = ~|pipe_phystatus_rst;

  // Synchronize MMCM lock output
  always @ (posedge user_clk or negedge mmcm_lock) begin

    if (!mmcm_lock)
      reg_clock_locked[1:0] <= #TCQ 2'b11;
    else
      reg_clock_locked[1:0] <= #TCQ {reg_clock_locked[0], 1'b0};

  end
  assign  clock_locked = !reg_clock_locked[1];

  // Synchronize PHY Ready
  always @ (posedge user_clk or negedge phy_rdy_int) begin

    if (!phy_rdy_int)
      reg_phy_rdy[1:0] <= #TCQ 2'b11;
    else
      reg_phy_rdy[1:0] <= #TCQ {reg_phy_rdy[0], 1'b0};

  end
  assign  phy_rdy = !reg_phy_rdy[1];

endmodule
