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
// File       : xdma_0_pcie3_ip_pcie_pipe_pipeline.v
// Version    : 4.2
//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : xdma_0_pcie3_ip_pcie_pipe_pipeline.v                                        //
// Description  : When enabled, implements a 1 or 2 stage pipeline between    //
//                GT and the Gen3 Integrated Block for PCI Express            //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
//  pcie_pipe_pipeline.v                                                      //
//      pcie_pipe_lane.v                                                      //
//      pcie_pipe_misc.v                                                      //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module xdma_0_pcie3_ip_pcie_pipe_pipeline #
(
  parameter        TCQ = 100,
  parameter        LINK_CAP_MAX_LINK_WIDTH = 1,
  parameter        PIPE_PIPELINE_STAGES = 0    // 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
) (
  // Pipe Per-Link Signals
  input   wire        pipe_tx_rcvr_det_i               ,  // PIPE Tx Receiver Detect
  input   wire        pipe_tx_reset_i                  ,  // PIPE Tx Reset
  input   wire  [1:0] pipe_tx_rate_i                   ,  // PIPE Tx Rate
  input   wire        pipe_tx_deemph_i                 ,  // PIPE Tx Deemphasis
  input   wire  [2:0] pipe_tx_margin_i                 ,  // PIPE Tx Margin
  input   wire        pipe_tx_swing_i                  ,  // PIPE Tx Swing
  input   wire  [5:0] pipe_tx_eqfs_i                   ,  // PIPE Tx
  input   wire  [5:0] pipe_tx_eqlf_i                   ,  // PIPE Tx
  input   wire  [7:0] pipe_rxslide_i                   ,  // PIPE Rx
  input   wire  [7:0] pipe_rxsyncdone_i                ,  // PIPE Rx

  output  wire        pipe_tx_rcvr_det_o               ,  // Pipelined PIPE Tx Receiver Detect
  output  wire        pipe_tx_reset_o                  ,  // Pipelined PIPE Tx Reset
  output  wire  [1:0] pipe_tx_rate_o                   ,  // Pipelined PIPE Tx Rate
  output  wire        pipe_tx_deemph_o                 ,  // Pipelined PIPE Tx Deemphasis
  output  wire  [2:0] pipe_tx_margin_o                 ,  // Pipelined PIPE Tx Margin
  output  wire        pipe_tx_swing_o                  ,  // Pipelined PIPE Tx Swing
  output  wire  [5:0] pipe_tx_eqfs_o                   ,  // Pipelined PIPE Tx
  output  wire  [5:0] pipe_tx_eqlf_o                   ,  // Pipelined PIPE Tx
  output  wire  [7:0] pipe_rxslide_o                   ,  // Pipelined PIPE Rx
  output  wire  [7:0] pipe_rxsyncdone_o                ,  // Pipelined PIPE Rx

  // Pipe Per-Lane Signals - Lane 0
  output  wire  [1:0] pipe_rx0_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx0_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx0_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx0_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx0_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx0_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx0_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx0_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx0_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx0_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx0_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx0_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx0_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx0_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx0_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx0_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx0_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx0_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx0_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx0_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx0_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx0_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx0_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx0_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx0_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx0_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx0_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx0_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx0_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx0_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx0_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx0_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx0_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx0_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx0_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx0_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx0_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx0_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx0_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx0_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx0_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx0_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx0_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx0_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx0_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx0_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx0_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx0_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx0_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx0_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx0_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx0_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx0_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx0_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx0_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx0_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx0_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx0_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx0_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx0_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx0_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx0_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Pipe Per-Lane Signals - Lane 1
  output  wire  [1:0] pipe_rx1_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx1_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx1_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx1_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx1_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx1_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx1_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx1_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx1_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx1_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx1_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx1_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx1_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx1_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx1_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx1_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx1_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx1_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx1_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx1_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx1_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx1_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx1_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx1_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx1_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx1_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx1_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx1_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx1_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx1_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx1_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx1_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx1_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx1_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx1_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx1_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx1_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx1_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx1_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx1_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx1_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx1_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx1_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx1_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx1_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx1_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx1_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx1_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx1_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx1_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx1_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx1_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx1_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx1_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx1_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx1_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx1_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx1_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx1_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx1_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx1_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx1_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Pipe Per-Lane Signals - Lane 2
  output  wire  [1:0] pipe_rx2_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx2_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx2_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx2_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx2_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx2_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx2_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx2_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx2_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx2_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx2_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx2_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx2_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx2_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx2_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx2_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx2_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx2_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx2_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx2_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx2_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx2_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx2_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx2_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx2_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx2_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx2_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx2_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx2_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx2_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx2_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx2_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx2_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx2_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx2_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx2_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx2_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx2_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx2_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx2_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx2_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx2_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx2_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx2_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx2_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx2_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx2_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx2_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx2_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx2_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx2_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx2_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx2_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx2_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx2_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx2_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx2_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx2_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx2_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx2_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx2_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx2_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Pipe Per-Lane Signals - Lane 3
  output  wire  [1:0] pipe_rx3_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx3_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx3_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx3_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx3_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx3_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx3_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx3_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx3_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx3_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx3_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx3_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx3_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx3_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx3_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx3_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx3_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx3_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx3_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx3_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx3_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx3_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx3_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx3_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx3_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx3_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx3_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx3_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx3_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx3_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx3_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx3_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx3_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx3_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx3_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx3_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx3_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx3_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx3_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx3_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx3_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx3_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx3_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx3_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx3_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx3_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx3_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx3_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx3_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx3_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx3_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx3_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx3_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx3_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx3_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx3_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx3_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx3_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx3_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx3_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx3_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx3_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Pipe Per-Lane Signals - Lane 4
  output  wire  [1:0] pipe_rx4_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx4_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx4_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx4_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx4_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx4_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx4_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx4_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx4_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx4_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx4_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx4_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx4_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx4_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx4_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx4_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx4_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx4_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx4_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx4_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx4_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx4_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx4_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx4_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx4_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx4_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx4_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx4_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx4_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx4_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx4_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx4_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx4_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx4_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx4_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx4_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx4_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx4_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx4_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx4_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx4_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx4_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx4_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx4_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx4_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx4_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx4_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx4_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx4_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx4_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx4_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx4_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx4_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx4_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx4_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx4_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx4_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx4_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx4_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx4_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx4_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx4_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Pipe Per-Lane Signals - Lane 5
  output  wire  [1:0] pipe_rx5_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx5_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx5_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx5_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx5_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx5_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx5_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx5_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx5_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx5_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx5_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx5_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx5_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx5_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx5_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx5_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx5_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx5_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx5_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx5_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx5_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx5_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx5_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx5_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx5_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx5_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx5_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx5_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx5_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx5_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx5_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx5_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx5_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx5_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx5_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx5_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx5_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx5_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx5_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx5_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx5_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx5_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx5_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx5_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx5_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx5_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx5_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx5_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx5_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx5_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx5_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx5_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx5_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx5_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx5_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx5_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx5_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx5_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx5_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx5_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx5_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx5_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Pipe Per-Lane Signals - Lane 6
  output  wire  [1:0] pipe_rx6_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx6_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx6_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx6_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx6_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx6_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx6_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx6_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx6_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx6_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx6_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx6_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx6_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx6_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx6_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx6_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx6_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx6_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx6_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx6_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx6_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx6_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx6_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx6_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx6_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx6_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx6_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx6_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx6_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx6_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx6_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx6_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx6_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx6_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx6_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx6_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx6_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx6_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx6_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx6_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx6_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx6_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx6_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx6_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx6_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx6_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx6_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx6_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx6_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx6_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx6_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx6_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx6_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx6_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx6_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx6_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx6_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx6_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx6_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx6_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx6_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx6_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Pipe Per-Lane Signals - Lane 7
  output  wire  [1:0] pipe_rx7_char_is_k_o             ,  // Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx7_data_o                  ,  // Pipelined PIPE Rx Data
  output  wire        pipe_rx7_valid_o                 ,  // Pipelined PIPE Rx Valid
  output  wire        pipe_rx7_data_valid_o            ,  // Pipelined PIPE Rx Data Valid
  output  wire  [2:0] pipe_rx7_status_o                ,  // Pipelined PIPE Rx Status
  output  wire        pipe_rx7_phy_status_o            ,  // Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx7_elec_idle_o             ,  // Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx7_eqdone_o                ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx7_eqlpadaptdone_o         ,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx7_eqlplffssel_o           ,  // Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx7_eqlpnewtxcoefforpreset_o,  // Pipelined PIPE Rx Eq
  output  wire        pipe_rx7_startblock_o            ,  // Pipelined PIPE Rx Start Block
  output  wire  [1:0] pipe_rx7_syncheader_o            ,  // Pipelined PIPE Rx Sync Header
  input   wire        pipe_rx7_polarity_i              ,  // PIPE Rx Polarity
  input   wire  [1:0] pipe_rx7_eqcontrol_i             ,  // PIPE Rx Eq control
  input   wire  [5:0] pipe_rx7_eqlplffs_i              ,  // PIPE Rx Eq
  input   wire  [3:0] pipe_rx7_eqlptxpreset_i          ,  // PIPE Rx Eq
  input   wire  [2:0] pipe_rx7_eqpreset_i              ,  // PIPE Rx Eq
  output  wire [17:0] pipe_tx7_eqcoeff_o               ,  // Pipelined Tx Eq Coefficient
  output  wire        pipe_tx7_eqdone_o                ,  // Pipelined Tx Eq Done
  input   wire        pipe_tx7_compliance_i            ,  // PIPE Tx Compliance
  input   wire  [1:0] pipe_tx7_char_is_k_i             ,  // PIPE Tx Char Is K
  input   wire [31:0] pipe_tx7_data_i                  ,  // PIPE Tx Data
  input   wire        pipe_tx7_elec_idle_i             ,  // PIPE Tx Electrical Idle
  input   wire  [1:0] pipe_tx7_powerdown_i             ,  // PIPE Tx Powerdown
  input   wire        pipe_tx7_datavalid_i             ,  // PIPE Tx Data Valid
  input   wire        pipe_tx7_startblock_i            ,  // PIPE Tx Start Block
  input   wire  [1:0] pipe_tx7_syncheader_i            ,  // PIPE Tx Sync Header
  input   wire  [1:0] pipe_tx7_eqcontrol_i             ,  // PIPE Tx Eq Control
  input   wire  [5:0] pipe_tx7_eqdeemph_i              ,  // PIPE Tx Eq Deemphesis
  input   wire  [3:0] pipe_tx7_eqpreset_i              ,  // PIPE Tx Preset

  input   wire  [1:0] pipe_rx7_char_is_k_i             ,  // PIPE Rx Char Is K
  input   wire [31:0] pipe_rx7_data_i                  ,  // PIPE Rx Data
  input   wire        pipe_rx7_valid_i                 ,  // PIPE Rx Valid
  input   wire        pipe_rx7_data_valid_i            ,  // PIPE Rx Data Valid
  input   wire  [2:0] pipe_rx7_status_i                ,  // PIPE Rx Status
  input   wire        pipe_rx7_phy_status_i            ,  // PIPE Rx Phy Status
  input   wire        pipe_rx7_elec_idle_i             ,  // PIPE Rx Electrical Idle
  input   wire        pipe_rx7_eqdone_i                ,  // PIPE Rx Eq
  input   wire        pipe_rx7_eqlpadaptdone_i         ,  // PIPE Rx Eq
  input   wire        pipe_rx7_eqlplffssel_i           ,  // PIPE Rx Eq
  input   wire [17:0] pipe_rx7_eqlpnewtxcoefforpreset_i,  // PIPE Rx Eq
  input   wire        pipe_rx7_startblock_i            ,  // PIPE Rx Start Block
  input   wire  [1:0] pipe_rx7_syncheader_i            ,  // PIPE Rx Sync Header
  output  wire        pipe_rx7_polarity_o              ,  // Pipelined PIPE Rx Polarity
  output  wire  [1:0] pipe_rx7_eqcontrol_o             ,  // Pipelined PIPE Rx Eq control
  output  wire  [5:0] pipe_rx7_eqlplffs_o              ,  // Pipelined PIPE Rx Eq
  output  wire  [3:0] pipe_rx7_eqlptxpreset_o          ,  // Pipelined PIPE Rx Eq
  output  wire  [2:0] pipe_rx7_eqpreset_o              ,  // Pipelined PIPE Rx Eq
  input   wire [17:0] pipe_tx7_eqcoeff_i               ,  // PIPE Tx Eq Coefficient
  input   wire        pipe_tx7_eqdone_i                ,  // PIPE Tx Eq Done
  output  wire        pipe_tx7_compliance_o            ,  // Pipelined PIPE Tx Compliance
  output  wire  [1:0] pipe_tx7_char_is_k_o             ,  // Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx7_data_o                  ,  // Pipelined PIPE Tx Data
  output  wire        pipe_tx7_elec_idle_o             ,  // Pipelined PIPE Tx Electrical Idle
  output  wire  [1:0] pipe_tx7_powerdown_o             ,  // Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx7_datavalid_o             ,  // Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx7_startblock_o            ,  // Pipelined PIPE Tx Start Block
  output  wire  [1:0] pipe_tx7_syncheader_o            ,  // Pipelined PIPE Tx Sync Header
  output  wire  [1:0] pipe_tx7_eqcontrol_o             ,  // Pipelined PIPE Tx Eq Control
  output  wire  [5:0] pipe_tx7_eqdeemph_o              ,  // Pipelined PIPE Tx Eq Deemphesis
  output  wire  [3:0] pipe_tx7_eqpreset_o              ,  // Pipelined PIPE Tx Preset

  // Non PIPE signals
  input   wire        pipe_clk                         ,  // PIPE Clock
  input   wire        rst_n                               // Reset
);

  generate

    xdma_0_pcie3_ip_pcie_pipe_misc # (
      .TCQ                  ( TCQ ),
      .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )

    ) pipe_misc_i (

      .pipe_tx_rcvr_det_i (pipe_tx_rcvr_det_i),
      .pipe_tx_reset_i    (pipe_tx_reset_i)   ,
      .pipe_tx_rate_i     (pipe_tx_rate_i)    ,
      .pipe_tx_deemph_i   (pipe_tx_deemph_i)  ,
      .pipe_tx_margin_i   (pipe_tx_margin_i)  ,
      .pipe_tx_swing_i    (pipe_tx_swing_i)   ,
      .pipe_tx_eqfs_i     (pipe_tx_eqfs_i )   ,
      .pipe_tx_eqlf_i     (pipe_tx_eqlf_i )   ,

      .pipe_tx_rcvr_det_o (pipe_tx_rcvr_det_o),
      .pipe_tx_reset_o    (pipe_tx_reset_o)   ,
      .pipe_tx_rate_o     (pipe_tx_rate_o)    ,
      .pipe_tx_deemph_o   (pipe_tx_deemph_o)  ,
      .pipe_tx_margin_o   (pipe_tx_margin_o)  ,
      .pipe_tx_swing_o    (pipe_tx_swing_o)   ,
      .pipe_tx_eqfs_o     (pipe_tx_eqfs_o )   ,
      .pipe_tx_eqlf_o     (pipe_tx_eqlf_o )   ,

      .pipe_clk           (pipe_clk)          ,
      .rst_n              (rst_n)
    );

    xdma_0_pcie3_ip_pcie_pipe_lane # (
      .TCQ                  ( TCQ ),
      .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
    )
    pipe_lane_0_i (

      .pipe_rx_char_is_k_o              (pipe_rx0_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx0_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx0_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx0_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx0_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx0_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx0_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx0_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx0_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx0_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx0_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx0_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx0_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx0_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx0_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx0_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx0_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx0_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[0]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[0]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx0_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx0_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx0_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx0_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx0_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx0_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx0_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx0_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx0_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx0_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx0_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx0_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx0_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx0_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx0_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx0_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx0_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx0_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx0_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx0_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx0_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx0_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx0_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx0_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx0_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx0_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx0_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx0_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx0_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx0_eqlptxpreset_o          ),
      .pipe_rx_eqpreset_o               (pipe_rx0_eqpreset_o              ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[0]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[0]             ),
      .pipe_tx_eqcoeff_i                (pipe_tx0_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx0_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx0_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx0_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx0_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx0_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx0_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx0_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx0_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx0_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx0_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx0_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx0_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n)

    );

    if (LINK_CAP_MAX_LINK_WIDTH >= 2) begin : pipe_2_lane

      xdma_0_pcie3_ip_pcie_pipe_lane # (
       .TCQ                  ( TCQ ),
       .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
      ) pipe_lane_1_i (

      .pipe_rx_char_is_k_o              (pipe_rx1_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx1_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx1_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx1_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx1_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx1_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx1_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx1_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx1_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx1_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx1_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx1_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx1_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx1_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx1_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx1_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx1_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx1_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[1]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[1]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx1_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx1_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx1_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx1_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx1_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx1_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx1_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx1_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx1_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx1_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx1_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx1_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx1_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx1_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx1_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx1_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx1_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx1_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx1_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx1_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx1_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx1_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx1_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx1_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx1_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx1_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx1_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx1_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx1_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx1_eqlptxpreset_o          ),
      .pipe_rx_eqpreset_o               (pipe_rx1_eqpreset_o              ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[1]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[1]             ),
      .pipe_tx_eqcoeff_i                (pipe_tx1_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx1_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx1_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx1_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx1_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx1_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx1_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx1_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx1_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx1_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx1_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx1_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx1_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n                            )

      );

    end // if (LINK_CAP_MAX_LINK_WIDTH >= 2)
    else
    begin

      assign pipe_rx1_char_is_k_o              =  2'b00;
      assign pipe_rx1_data_o                   = 32'h00000000;
      assign pipe_rx1_valid_o                  =  1'b0;
      assign pipe_rx1_data_valid_o             =  1'b0;
      assign pipe_rx1_status_o                 =  2'b00;
      assign pipe_rx1_phy_status_o             =  1'b0;
      assign pipe_rx1_elec_idle_o              =  1'b1;
      assign pipe_rx1_eqdone_o                 =  1'b0;
      assign pipe_rx1_eqlpadaptdone_o          =  1'b0;
      assign pipe_rx1_eqlplffssel_o            =  1'b0;
      assign pipe_rx1_eqlpnewtxcoefforpreset_o = 17'b00000000000000000;
      assign pipe_rx1_startblock_o             =  1'b0;
      assign pipe_rx1_syncheader_o             =  2'b00;
      assign pipe_tx1_eqcoeff_o                = 17'b00000000000000000;
      assign pipe_tx1_eqdone_o                 =  1'b0;
      assign pipe_rx1_polarity_o               =  1'b0;
      assign pipe_rx1_eqcontrol_o              =  2'b00;
      assign pipe_rx1_eqlplffs_o               =  6'b000000;
      assign pipe_rx1_eqlptxpreset_o           =  4'h0;
      assign pipe_rx1_eqpreset_o               =  3'b000;
      assign pipe_tx1_compliance_o             =  1'b0;
      assign pipe_tx1_char_is_k_o              =  2'b00;
      assign pipe_tx1_data_o                   = 32'h00000000;
      assign pipe_tx1_elec_idle_o              =  1'b1;
      assign pipe_tx1_powerdown_o              =  2'b00;
      assign pipe_tx1_datavalid_o              =  1'b0;
      assign pipe_tx1_startblock_o             =  1'b0;
      assign pipe_tx1_syncheader_o             =  2'b00;
      assign pipe_tx1_eqcontrol_o              =  2'b00;
      assign pipe_tx1_eqdeemph_o               =  6'b000000;
      assign pipe_tx1_eqpreset_o               =  4'h0;
      assign pipe_rxslide_o[1]                 =  1'b0;
      assign pipe_rxsyncdone_o[1]              =  1'b0;

    end // if !(LINK_CAP_MAX_LINK_WIDTH >= 2)

    if (LINK_CAP_MAX_LINK_WIDTH >= 4) begin : pipe_4_lane

      xdma_0_pcie3_ip_pcie_pipe_lane # (
       .TCQ                  ( TCQ ),
       .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
      ) pipe_lane_2_i (

      .pipe_rx_char_is_k_o              (pipe_rx2_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx2_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx2_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx2_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx2_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx2_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx2_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx2_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx2_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx2_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx2_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx2_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx2_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx2_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx2_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx2_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx2_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx2_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[2]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[2]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx2_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx2_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx2_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx2_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx2_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx2_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx2_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx2_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx2_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx2_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx2_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx2_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx2_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx2_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx2_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx2_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx2_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx2_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx2_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx2_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx2_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx2_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx2_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx2_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx2_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx2_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx2_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx2_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx2_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx2_eqlptxpreset_o          ),
      .pipe_rx_eqpreset_o               (pipe_rx2_eqpreset_o              ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[2]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[2]             ),
      .pipe_tx_eqcoeff_i                (pipe_tx2_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx2_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx2_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx2_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx2_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx2_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx2_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx2_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx2_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx2_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx2_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx2_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx2_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n                            )

      );

      xdma_0_pcie3_ip_pcie_pipe_lane # (
       .TCQ                  ( TCQ ),
       .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
      ) pipe_lane_3_i (

      .pipe_rx_char_is_k_o              (pipe_rx3_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx3_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx3_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx3_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx3_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx3_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx3_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx3_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx3_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx3_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx3_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx3_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx3_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx3_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx3_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx3_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx3_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx3_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[3]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[3]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx3_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx3_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx3_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx3_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx3_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx3_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx3_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx3_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx3_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx3_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx3_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx3_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx3_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx3_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx3_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx3_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx3_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx3_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx3_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx3_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx3_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx3_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx3_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx3_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx3_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx3_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx3_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx3_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx3_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx3_eqlptxpreset_o          ),
      .pipe_rx_eqpreset_o               (pipe_rx3_eqpreset_o              ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[3]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[3]             ),
      .pipe_tx_eqcoeff_i                (pipe_tx3_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx3_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx3_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx3_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx3_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx3_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx3_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx3_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx3_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx3_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx3_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx3_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx3_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n                            )
      );

    end // if (LINK_CAP_MAX_LINK_WIDTH >= 4)
    else
    begin
      assign pipe_rx2_char_is_k_o              =  2'b00;
      assign pipe_rx2_data_o                   = 32'h00000000;
      assign pipe_rx2_valid_o                  =  1'b0;
      assign pipe_rx2_data_valid_o             =  1'b0;
      assign pipe_rx2_status_o                 =  2'b00;
      assign pipe_rx2_phy_status_o             =  1'b0;
      assign pipe_rx2_elec_idle_o              =  1'b1;
      assign pipe_rx2_eqdone_o                 =  1'b0;
      assign pipe_rx2_eqlpadaptdone_o          =  1'b0;
      assign pipe_rx2_eqlplffssel_o            =  1'b0;
      assign pipe_rx2_eqlpnewtxcoefforpreset_o = 17'b00000000000000000;
      assign pipe_rx2_startblock_o             =  1'b0;
      assign pipe_rx2_syncheader_o             =  2'b00;
      assign pipe_tx2_eqcoeff_o                = 17'b00000000000000000;
      assign pipe_tx2_eqdone_o                 =  1'b0;
      assign pipe_rx2_polarity_o               =  1'b0;
      assign pipe_rx2_eqcontrol_o              =  2'b00;
      assign pipe_rx2_eqlplffs_o               =  6'b000000;
      assign pipe_rx2_eqlptxpreset_o           =  4'h0;
      assign pipe_rx2_eqpreset_o               =  3'b000;
      assign pipe_rxslide_o[2]                 =  1'b0;
      assign pipe_rxsyncdone_o[2]              =  1'b0;
      assign pipe_tx2_compliance_o             =  1'b0;
      assign pipe_tx2_char_is_k_o              =  2'b00;
      assign pipe_tx2_data_o                   = 32'h00000000;
      assign pipe_tx2_elec_idle_o              =  1'b1;
      assign pipe_tx2_powerdown_o              =  2'b00;
      assign pipe_tx2_datavalid_o              =  1'b0;
      assign pipe_tx2_startblock_o             =  1'b0;
      assign pipe_tx2_syncheader_o             =  2'b00;
      assign pipe_tx2_eqcontrol_o              =  2'b00;
      assign pipe_tx2_eqdeemph_o               =  6'b000000;
      assign pipe_tx2_eqpreset_o               =  4'h0;

      assign pipe_rx3_char_is_k_o              =  2'b00;
      assign pipe_rx3_data_o                   = 32'h00000000;
      assign pipe_rx3_valid_o                  =  1'b0;
      assign pipe_rx3_data_valid_o             =  1'b0;
      assign pipe_rx3_status_o                 =  2'b00;
      assign pipe_rx3_phy_status_o             =  1'b0;
      assign pipe_rx3_elec_idle_o              =  1'b1;
      assign pipe_rx3_eqdone_o                 =  1'b0;
      assign pipe_rx3_eqlpadaptdone_o          =  1'b0;
      assign pipe_rx3_eqlplffssel_o            =  1'b0;
      assign pipe_rx3_eqlpnewtxcoefforpreset_o = 17'b00000000000000000;
      assign pipe_rx3_startblock_o             =  1'b0;
      assign pipe_rx3_syncheader_o             =  2'b00;
      assign pipe_tx3_eqcoeff_o                = 17'b00000000000000000;
      assign pipe_tx3_eqdone_o                 =  1'b0;
      assign pipe_rx3_polarity_o               =  1'b0;
      assign pipe_rx3_eqcontrol_o              =  2'b00;
      assign pipe_rx3_eqlplffs_o               =  6'b000000;
      assign pipe_rx3_eqlptxpreset_o           =  4'h0;
      assign pipe_rx3_eqpreset_o               =  3'b000;
      assign pipe_rxslide_o[3]                 =  1'b0;
      assign pipe_rxsyncdone_o[3]              =  1'b0;
      assign pipe_tx3_compliance_o             =  1'b0;
      assign pipe_tx3_char_is_k_o              =  2'b00;
      assign pipe_tx3_data_o                   = 32'h00000000;
      assign pipe_tx3_elec_idle_o              =  1'b1;
      assign pipe_tx3_powerdown_o              =  2'b00;
      assign pipe_tx3_datavalid_o              =  1'b0;
      assign pipe_tx3_startblock_o             =  1'b0;
      assign pipe_tx3_syncheader_o             =  2'b00;
      assign pipe_tx3_eqcontrol_o              =  2'b00;
      assign pipe_tx3_eqdeemph_o               =  6'b000000;
      assign pipe_tx3_eqpreset_o               =  4'h0;

    end // if !(LINK_CAP_MAX_LINK_WIDTH >= 4)

    if (LINK_CAP_MAX_LINK_WIDTH >= 8) begin : pipe_8_lane

      xdma_0_pcie3_ip_pcie_pipe_lane # (
       .TCQ                  ( TCQ ),
       .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
      ) pipe_lane_4_i (

      .pipe_rx_char_is_k_o              (pipe_rx4_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx4_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx4_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx4_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx4_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx4_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx4_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx4_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx4_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx4_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx4_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx4_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx4_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx4_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx4_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx4_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx4_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx4_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[4]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[4]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx4_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx4_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx4_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx4_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx4_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx4_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx4_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx4_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx4_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx4_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx4_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx4_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx4_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx4_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx4_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx4_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx4_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx4_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx4_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx4_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx4_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx4_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx4_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx4_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx4_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx4_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx4_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx4_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx4_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx4_eqlptxpreset_o          ),
      .pipe_rx_eqpreset_o               (pipe_rx4_eqpreset_o              ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[4]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[4]             ),
      .pipe_tx_eqcoeff_i                (pipe_tx4_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx4_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx4_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx4_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx4_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx4_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx4_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx4_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx4_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx4_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx4_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx4_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx4_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n                            )

      );

      xdma_0_pcie3_ip_pcie_pipe_lane # (
       .TCQ                  ( TCQ ),
       .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
      ) pipe_lane_5_i (

      .pipe_rx_char_is_k_o              (pipe_rx5_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx5_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx5_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx5_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx5_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx5_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx5_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx5_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx5_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx5_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx5_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx5_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx5_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx5_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx5_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx5_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx5_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx5_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[5]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[5]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx5_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx5_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx5_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx5_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx5_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx5_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx5_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx5_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx5_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx5_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx5_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx5_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx5_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx5_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx5_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx5_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx5_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx5_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx5_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx5_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx5_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx5_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx5_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx5_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx5_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx5_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx5_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx5_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx5_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx5_eqlptxpreset_o          ),
      .pipe_rx_eqpreset_o               (pipe_rx5_eqpreset_o              ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[5]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[5]             ),
      .pipe_tx_eqcoeff_i                (pipe_tx5_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx5_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx5_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx5_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx5_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx5_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx5_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx5_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx5_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx5_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx5_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx5_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx5_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n                            )

      );

      xdma_0_pcie3_ip_pcie_pipe_lane # (
       .TCQ                  ( TCQ ),
       .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
      ) pipe_lane_6_i (

      .pipe_rx_char_is_k_o              (pipe_rx6_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx6_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx6_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx6_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx6_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx6_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx6_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx6_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx6_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx6_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx6_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx6_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx6_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx6_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx6_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx6_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx6_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx6_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[6]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[6]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx6_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx6_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx6_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx6_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx6_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx6_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx6_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx6_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx6_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx6_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx6_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx6_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx6_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx6_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx6_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx6_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx6_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx6_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx6_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx6_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx6_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx6_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx6_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx6_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx6_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx6_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx6_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx6_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx6_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx6_eqlptxpreset_o          ),
      .pipe_rx_eqpreset_o               (pipe_rx6_eqpreset_o              ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[6]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[6]             ),
      .pipe_tx_eqcoeff_i                (pipe_tx6_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx6_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx6_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx6_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx6_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx6_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx6_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx6_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx6_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx6_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx6_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx6_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx6_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n                            )

      );

      xdma_0_pcie3_ip_pcie_pipe_lane # (
       .TCQ                  ( TCQ ),
       .PIPE_PIPELINE_STAGES ( PIPE_PIPELINE_STAGES )
      ) pipe_lane_7_i (

      .pipe_rx_char_is_k_o              (pipe_rx7_char_is_k_o             ),
      .pipe_rx_data_o                   (pipe_rx7_data_o                  ),
      .pipe_rx_valid_o                  (pipe_rx7_valid_o                 ),
      .pipe_rx_data_valid_o             (pipe_rx7_data_valid_o            ),
      .pipe_rx_status_o                 (pipe_rx7_status_o                ),
      .pipe_rx_phy_status_o             (pipe_rx7_phy_status_o            ),
      .pipe_rx_elec_idle_o              (pipe_rx7_elec_idle_o             ),
      .pipe_rx_eqdone_o                 (pipe_rx7_eqdone_o                ),
      .pipe_rx_eqlpadaptdone_o          (pipe_rx7_eqlpadaptdone_o         ),
      .pipe_rx_eqlplffssel_o            (pipe_rx7_eqlplffssel_o           ),
      .pipe_rx_eqlpnewtxcoefforpreset_o (pipe_rx7_eqlpnewtxcoefforpreset_o),
      .pipe_rx_startblock_o             (pipe_rx7_startblock_o            ),
      .pipe_rx_syncheader_o             (pipe_rx7_syncheader_o            ),
      .pipe_rx_polarity_i               (pipe_rx7_polarity_i              ),
      .pipe_rx_eqcontrol_i              (pipe_rx7_eqcontrol_i             ),
      .pipe_rx_eqlplffs_i               (pipe_rx7_eqlplffs_i              ),
      .pipe_rx_eqlptxpreset_i           (pipe_rx7_eqlptxpreset_i          ),
      .pipe_rx_eqpreset_i               (pipe_rx7_eqpreset_i              ),
      .pipe_rx_slide_i                  (pipe_rxslide_i[7]                ),
      .pipe_rx_syncdone_i               (pipe_rxsyncdone_i[7]             ),
      .pipe_tx_eqcoeff_o                (pipe_tx7_eqcoeff_o               ),
      .pipe_tx_eqdone_o                 (pipe_tx7_eqdone_o                ),
      .pipe_tx_compliance_i             (pipe_tx7_compliance_i            ),
      .pipe_tx_char_is_k_i              (pipe_tx7_char_is_k_i             ),
      .pipe_tx_data_i                   (pipe_tx7_data_i                  ),
      .pipe_tx_elec_idle_i              (pipe_tx7_elec_idle_i             ),
      .pipe_tx_powerdown_i              (pipe_tx7_powerdown_i             ),
      .pipe_tx_datavalid_i              (pipe_tx7_datavalid_i             ),
      .pipe_tx_startblock_i             (pipe_tx7_startblock_i            ),
      .pipe_tx_syncheader_i             (pipe_tx7_syncheader_i            ),
      .pipe_tx_eqcontrol_i              (pipe_tx7_eqcontrol_i             ),
      .pipe_tx_eqdeemph_i               (pipe_tx7_eqdeemph_i              ),
      .pipe_tx_eqpreset_i               (pipe_tx7_eqpreset_i              ),

      .pipe_rx_char_is_k_i              (pipe_rx7_char_is_k_i             ),
      .pipe_rx_data_i                   (pipe_rx7_data_i                  ),
      .pipe_rx_valid_i                  (pipe_rx7_valid_i                 ),
      .pipe_rx_data_valid_i             (pipe_rx7_data_valid_i            ),
      .pipe_rx_status_i                 (pipe_rx7_status_i                ),
      .pipe_rx_phy_status_i             (pipe_rx7_phy_status_i            ),
      .pipe_rx_elec_idle_i              (pipe_rx7_elec_idle_i             ),
      .pipe_rx_eqdone_i                 (pipe_rx7_eqdone_i                ),
      .pipe_rx_eqlpadaptdone_i          (pipe_rx7_eqlpadaptdone_i         ),
      .pipe_rx_eqlplffssel_i            (pipe_rx7_eqlplffssel_i           ),
      .pipe_rx_eqlpnewtxcoefforpreset_i (pipe_rx7_eqlpnewtxcoefforpreset_i),
      .pipe_rx_startblock_i             (pipe_rx7_startblock_i            ),
      .pipe_rx_syncheader_i             (pipe_rx7_syncheader_i            ),
      .pipe_rx_polarity_o               (pipe_rx7_polarity_o              ),
      .pipe_rx_eqcontrol_o              (pipe_rx7_eqcontrol_o             ),
      .pipe_rx_eqlplffs_o               (pipe_rx7_eqlplffs_o              ),
      .pipe_rx_eqlptxpreset_o           (pipe_rx7_eqlptxpreset_o          ),
      .pipe_rx_slide_o                  (pipe_rxslide_o[7]                ),
      .pipe_rx_syncdone_o               (pipe_rxsyncdone_o[7]             ),
      .pipe_rx_eqpreset_o               (pipe_rx7_eqpreset_o              ),
      .pipe_tx_eqcoeff_i                (pipe_tx7_eqcoeff_i               ),
      .pipe_tx_eqdone_i                 (pipe_tx7_eqdone_i                ),
      .pipe_tx_compliance_o             (pipe_tx7_compliance_o            ),
      .pipe_tx_char_is_k_o              (pipe_tx7_char_is_k_o             ),
      .pipe_tx_data_o                   (pipe_tx7_data_o                  ),
      .pipe_tx_elec_idle_o              (pipe_tx7_elec_idle_o             ),
      .pipe_tx_powerdown_o              (pipe_tx7_powerdown_o             ),
      .pipe_tx_datavalid_o              (pipe_tx7_datavalid_o             ),
      .pipe_tx_startblock_o             (pipe_tx7_startblock_o            ),
      .pipe_tx_syncheader_o             (pipe_tx7_syncheader_o            ),
      .pipe_tx_eqcontrol_o              (pipe_tx7_eqcontrol_o             ),
      .pipe_tx_eqdeemph_o               (pipe_tx7_eqdeemph_o              ),
      .pipe_tx_eqpreset_o               (pipe_tx7_eqpreset_o              ),

      .pipe_clk                         (pipe_clk                         ),
      .rst_n                            (rst_n                            )

      );

    end // if (LINK_CAP_MAX_LINK_WIDTH >= 8)
    else
    begin
      assign pipe_rx4_char_is_k_o              =  2'b00;
      assign pipe_rx4_data_o                   = 32'h00000000;
      assign pipe_rx4_valid_o                  =  1'b0;
      assign pipe_rx4_data_valid_o             =  1'b0;
      assign pipe_rx4_status_o                 =  2'b00;
      assign pipe_rx4_phy_status_o             =  1'b0;
      assign pipe_rx4_elec_idle_o              =  1'b1;
      assign pipe_rx4_eqdone_o                 =  1'b0;
      assign pipe_rx4_eqlpadaptdone_o          =  1'b0;
      assign pipe_rx4_eqlplffssel_o            =  1'b0;
      assign pipe_rx4_eqlpnewtxcoefforpreset_o = 17'b00000000000000000;
      assign pipe_rx4_startblock_o             =  1'b0;
      assign pipe_rx4_syncheader_o             =  2'b00;
      assign pipe_tx4_eqcoeff_o                = 17'b00000000000000000;
      assign pipe_tx4_eqdone_o                 =  1'b0;
      assign pipe_rx4_polarity_o               =  1'b0;
      assign pipe_rx4_eqcontrol_o              =  2'b00;
      assign pipe_rx4_eqlplffs_o               =  6'b000000;
      assign pipe_rx4_eqlptxpreset_o           =  4'h0;
      assign pipe_rx4_eqpreset_o               =  3'b000;
      assign pipe_rxslide_o[4]                 =  1'b0;
      assign pipe_rxsyncdone_o[4]              =  1'b0;
      assign pipe_tx4_compliance_o             =  1'b0;
      assign pipe_tx4_char_is_k_o              =  2'b00;
      assign pipe_tx4_data_o                   = 32'h00000000;
      assign pipe_tx4_elec_idle_o              =  1'b1;
      assign pipe_tx4_powerdown_o              =  2'b00;
      assign pipe_tx4_datavalid_o              =  1'b0;
      assign pipe_tx4_startblock_o             =  1'b0;
      assign pipe_tx4_syncheader_o             =  2'b00;
      assign pipe_tx4_eqcontrol_o              =  2'b00;
      assign pipe_tx4_eqdeemph_o               =  6'b000000;
      assign pipe_tx4_eqpreset_o               =  4'h0;

      assign pipe_rx5_char_is_k_o              =  2'b00;
      assign pipe_rx5_data_o                   = 32'h00000000;
      assign pipe_rx5_valid_o                  =  1'b0;
      assign pipe_rx5_data_valid_o             =  1'b0;
      assign pipe_rx5_status_o                 =  2'b00;
      assign pipe_rx5_phy_status_o             =  1'b0;
      assign pipe_rx5_elec_idle_o              =  1'b1;
      assign pipe_rx5_eqdone_o                 =  1'b0;
      assign pipe_rx5_eqlpadaptdone_o          =  1'b0;
      assign pipe_rx5_eqlplffssel_o            =  1'b0;
      assign pipe_rx5_eqlpnewtxcoefforpreset_o = 17'b00000000000000000;
      assign pipe_rx5_startblock_o             =  1'b0;
      assign pipe_rx5_syncheader_o             =  2'b00;
      assign pipe_tx5_eqcoeff_o                = 17'b00000000000000000;
      assign pipe_tx5_eqdone_o                 =  1'b0;
      assign pipe_rx5_polarity_o               =  1'b0;
      assign pipe_rx5_eqcontrol_o              =  2'b00;
      assign pipe_rx5_eqlplffs_o               =  6'b000000;
      assign pipe_rx5_eqlptxpreset_o           =  4'h0;
      assign pipe_rx5_eqpreset_o               =  3'b000;
      assign pipe_rxslide_o[5]                 =  1'b0;
      assign pipe_rxsyncdone_o[5]              =  1'b0;
      assign pipe_tx5_compliance_o             =  1'b0;
      assign pipe_tx5_char_is_k_o              =  2'b00;
      assign pipe_tx5_data_o                   = 32'h00000000;
      assign pipe_tx5_elec_idle_o              =  1'b1;
      assign pipe_tx5_powerdown_o              =  2'b00;
      assign pipe_tx5_datavalid_o              =  1'b0;
      assign pipe_tx5_startblock_o             =  1'b0;
      assign pipe_tx5_syncheader_o             =  2'b00;
      assign pipe_tx5_eqcontrol_o              =  2'b00;
      assign pipe_tx5_eqdeemph_o               =  6'b000000;
      assign pipe_tx5_eqpreset_o               =  4'h0;

      assign pipe_rx6_char_is_k_o              =  2'b00;
      assign pipe_rx6_data_o                   = 32'h00000000;
      assign pipe_rx6_valid_o                  =  1'b0;
      assign pipe_rx6_data_valid_o             =  1'b0;
      assign pipe_rx6_status_o                 =  2'b00;
      assign pipe_rx6_phy_status_o             =  1'b0;
      assign pipe_rx6_elec_idle_o              =  1'b1;
      assign pipe_rx6_eqdone_o                 =  1'b0;
      assign pipe_rx6_eqlpadaptdone_o          =  1'b0;
      assign pipe_rx6_eqlplffssel_o            =  1'b0;
      assign pipe_rx6_eqlpnewtxcoefforpreset_o = 17'b00000000000000000;
      assign pipe_rx6_startblock_o             =  1'b0;
      assign pipe_rx6_syncheader_o             =  2'b00;
      assign pipe_tx6_eqcoeff_o                = 17'b00000000000000000;
      assign pipe_tx6_eqdone_o                 =  1'b0;
      assign pipe_rx6_polarity_o               =  1'b0;
      assign pipe_rx6_eqcontrol_o              =  2'b00;
      assign pipe_rx6_eqlplffs_o               =  6'b000000;
      assign pipe_rx6_eqlptxpreset_o           =  4'h0;
      assign pipe_rx6_eqpreset_o               =  3'b000;
      assign pipe_rxslide_o[6]                 =  1'b0;
      assign pipe_rxsyncdone_o[6]              =  1'b0;
      assign pipe_tx6_compliance_o             =  1'b0;
      assign pipe_tx6_char_is_k_o              =  2'b00;
      assign pipe_tx6_data_o                   = 32'h00000000;
      assign pipe_tx6_elec_idle_o              =  1'b1;
      assign pipe_tx6_powerdown_o              =  2'b00;
      assign pipe_tx6_datavalid_o              =  1'b0;
      assign pipe_tx6_startblock_o             =  1'b0;
      assign pipe_tx6_syncheader_o             =  2'b00;
      assign pipe_tx6_eqcontrol_o              =  2'b00;
      assign pipe_tx6_eqdeemph_o               =  6'b000000;
      assign pipe_tx6_eqpreset_o               =  4'h0;

      assign pipe_rx7_char_is_k_o              =  2'b00;
      assign pipe_rx7_data_o                   = 32'h00000000;
      assign pipe_rx7_valid_o                  =  1'b0;
      assign pipe_rx7_data_valid_o             =  1'b0;
      assign pipe_rx7_status_o                 =  2'b00;
      assign pipe_rx7_phy_status_o             =  1'b0;
      assign pipe_rx7_elec_idle_o              =  1'b1;
      assign pipe_rx7_eqdone_o                 =  1'b0;
      assign pipe_rx7_eqlpadaptdone_o          =  1'b0;
      assign pipe_rx7_eqlplffssel_o            =  1'b0;
      assign pipe_rx7_eqlpnewtxcoefforpreset_o = 17'b00000000000000000;
      assign pipe_rx7_startblock_o             =  1'b0;
      assign pipe_rx7_syncheader_o             =  2'b00;
      assign pipe_rxslide_o[7]                 =  1'b0;
      assign pipe_rxsyncdone_o[7]              =  1'b0;
      assign pipe_tx7_eqcoeff_o                = 17'b00000000000000000;
      assign pipe_tx7_eqdone_o                 =  1'b0;
      assign pipe_rx7_polarity_o               =  1'b0;
      assign pipe_rx7_eqcontrol_o              =  2'b00;
      assign pipe_rx7_eqlplffs_o               =  6'b000000;
      assign pipe_rx7_eqlptxpreset_o           =  4'h0;
      assign pipe_rx7_eqpreset_o               =  3'b000;
      assign pipe_tx7_compliance_o             =  1'b0;
      assign pipe_tx7_char_is_k_o              =  2'b00;
      assign pipe_tx7_data_o                   = 32'h00000000;
      assign pipe_tx7_elec_idle_o              =  1'b1;
      assign pipe_tx7_powerdown_o              =  2'b00;
      assign pipe_tx7_datavalid_o              =  1'b0;
      assign pipe_tx7_startblock_o             =  1'b0;
      assign pipe_tx7_syncheader_o             =  2'b00;
      assign pipe_tx7_eqcontrol_o              =  2'b00;
      assign pipe_tx7_eqdeemph_o               =  6'b000000;
      assign pipe_tx7_eqpreset_o               =  4'h0;


    end // if !(LINK_CAP_MAX_LINK_WIDTH >= 8)

  endgenerate

endmodule

