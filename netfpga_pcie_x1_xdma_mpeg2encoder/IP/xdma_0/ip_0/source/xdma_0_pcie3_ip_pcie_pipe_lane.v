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
// File       : xdma_0_pcie3_ip_pcie_pipe_lane.v
// Version    : 4.2
//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : xdma_0_pcie3_ip_pcie_pipe_lane.v                                            //
// Description  : Implements the PIPE interface PIPELINE for all per lane     //
//                interface signals                                           //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
//  pcie_pipe_lane.v                                                          //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module xdma_0_pcie3_ip_pcie_pipe_lane #
(
  parameter        TCQ = 100,
  parameter        PIPE_PIPELINE_STAGES = 0    // 0 - 0 stages, 1 - 1 stage, 2 - 2 stages
) (
  output  wire [ 1:0] pipe_rx_char_is_k_o             ,// Pipelined PIPE Rx Char Is K
  output  wire [31:0] pipe_rx_data_o                  ,// Pipelined PIPE Rx Data
  output  wire        pipe_rx_valid_o                 ,// Pipelined PIPE Rx Valid
  output  wire        pipe_rx_data_valid_o            ,// Pipelined PIPE Rx Data Valid
  output  wire [ 2:0] pipe_rx_status_o                ,// Pipelined PIPE Rx Status
  output  wire        pipe_rx_phy_status_o            ,// Pipelined PIPE Rx Phy Status
  output  wire        pipe_rx_elec_idle_o             ,// Pipelined PIPE Rx Electrical Idle
  output  wire        pipe_rx_eqdone_o                ,// Pipelined PIPE Rx Eq
  output  wire        pipe_rx_eqlpadaptdone_o         ,// Pipelined PIPE Rx Eq
  output  wire        pipe_rx_eqlplffssel_o           ,// Pipelined PIPE Rx Eq
  output  wire [17:0] pipe_rx_eqlpnewtxcoefforpreset_o,// Pipelined PIPE Rx Eq
  output  wire        pipe_rx_startblock_o            ,// Pipelined PIPE Rx Start Block
  output  wire [ 1:0] pipe_rx_syncheader_o            ,// Pipelined PIPE Rx Sync Header
  output  wire        pipe_rx_slide_o                 ,// Pipelined PIPE Rx Slide
  output  wire        pipe_rx_syncdone_o              ,// Pipelined PIPE Rx Sync done

  input   wire        pipe_rx_polarity_i              ,// PIPE Rx Polarity
  input   wire [ 1:0] pipe_rx_eqcontrol_i             ,// PIPE Rx Eq control
  input   wire [ 5:0] pipe_rx_eqlplffs_i              ,// PIPE Rx Eq
  input   wire [ 3:0] pipe_rx_eqlptxpreset_i          ,// PIPE Rx Eq
  input   wire [ 2:0] pipe_rx_eqpreset_i              ,// PIPE Rx Eq

  output  wire [17:0] pipe_tx_eqcoeff_o               ,// Pipelined Tx Eq Coefficient
  output  wire        pipe_tx_eqdone_o                ,// Pipelined Tx Eq Done

  input   wire        pipe_tx_compliance_i            ,// PIPE Tx Compliance
  input   wire [ 1:0] pipe_tx_char_is_k_i             ,// PIPE Tx Char Is K
  input   wire [31:0] pipe_tx_data_i                  ,// PIPE Tx Data
  input   wire        pipe_tx_elec_idle_i             ,// PIPE Tx Electrical Idle
  input   wire [ 1:0] pipe_tx_powerdown_i             ,// PIPE Tx Powerdown
  input   wire        pipe_tx_datavalid_i             ,// PIPE Tx Data Valid
  input   wire        pipe_tx_startblock_i            ,// PIPE Tx Start Block
  input   wire [ 1:0] pipe_tx_syncheader_i            ,// PIPE Tx Sync Header
  input   wire [ 1:0] pipe_tx_eqcontrol_i             ,// PIPE Tx Eq Control
  input   wire [ 5:0] pipe_tx_eqdeemph_i              ,// PIPE Tx Eq Deemphesis
  input   wire [ 3:0] pipe_tx_eqpreset_i              ,// PIPE Tx Preset

  input   wire [ 1:0] pipe_rx_char_is_k_i             ,// PIPE Rx Char Is K
  input   wire [31:0] pipe_rx_data_i                  ,// PIPE Rx Data
  input   wire        pipe_rx_valid_i                 ,// PIPE Rx Valid
  input   wire        pipe_rx_data_valid_i            ,// PIPE Rx Data Valid
  input   wire [ 2:0] pipe_rx_status_i                ,// PIPE Rx Status
  input   wire        pipe_rx_phy_status_i            ,// PIPE Rx Phy Status
  input   wire        pipe_rx_elec_idle_i             ,// PIPE Rx Electrical Idle
  input   wire        pipe_rx_eqdone_i                ,// PIPE Rx Eq
  input   wire        pipe_rx_eqlpadaptdone_i         ,// PIPE Rx Eq
  input   wire        pipe_rx_eqlplffssel_i           ,// PIPE Rx Eq
  input   wire [17:0] pipe_rx_eqlpnewtxcoefforpreset_i,// PIPE Rx Eq
  input   wire        pipe_rx_startblock_i            ,// PIPE Rx Start Block
  input   wire [ 1:0] pipe_rx_syncheader_i            ,// PIPE Rx Sync Header
  input   wire        pipe_rx_slide_i                 ,// PIPE Rx Slide
  input   wire        pipe_rx_syncdone_i              ,// PIPE Rx Sync done

  output  wire        pipe_rx_polarity_o              ,// Pipelined PIPE Rx Polarity
  output  wire [ 1:0] pipe_rx_eqcontrol_o             ,// Pipelined PIPE Rx Eq control
  output  wire [ 5:0] pipe_rx_eqlplffs_o              ,// Pipelined PIPE Rx Eq
  output  wire [ 3:0] pipe_rx_eqlptxpreset_o          ,// Pipelined PIPE Rx Eq
  output  wire [ 2:0] pipe_rx_eqpreset_o              ,// Pipelined PIPE Rx Eq

  input   wire [17:0] pipe_tx_eqcoeff_i               ,// PIPE Tx Eq Coefficient
  input   wire        pipe_tx_eqdone_i                ,// PIPE Tx Eq Done

  output  wire        pipe_tx_compliance_o            ,// Pipelined PIPE Tx Compliance
  output  wire [ 1:0] pipe_tx_char_is_k_o             ,// Pipelined PIPE Tx Char Is K
  output  wire [31:0] pipe_tx_data_o                  ,// Pipelined PIPE Tx Data
  output  wire        pipe_tx_elec_idle_o             ,// Pipelined PIPE Tx Electrical Idle
  output  wire [ 1:0] pipe_tx_powerdown_o             ,// Pipelined PIPE Tx Powerdown
  output  wire        pipe_tx_datavalid_o             ,// Pipelined PIPE Tx Data Valid
  output  wire        pipe_tx_startblock_o            ,// Pipelined PIPE Tx Start Block
  output  wire [ 1:0] pipe_tx_syncheader_o            ,// Pipelined PIPE Tx Sync Header
  output  wire [ 1:0] pipe_tx_eqcontrol_o             ,// Pipelined PIPE Tx Eq Control
  output  wire [ 5:0] pipe_tx_eqdeemph_o              ,// Pipelined PIPE Tx Eq Deemphesis
  output  wire [ 3:0] pipe_tx_eqpreset_o              ,// Pipelined PIPE Tx Preset

  input   wire        pipe_clk                        ,// PIPE Clock
  input   wire        rst_n                            // Reset
);

  //******************************************************************//
  // Reality check.                                                   //
  //******************************************************************//

  reg [ 1:0] pipe_rx_char_is_k_q               ;
  reg [31:0] pipe_rx_data_q                    ;
  reg        pipe_rx_valid_q                   ;
  reg        pipe_rx_data_valid_q              ;
  reg [ 2:0] pipe_rx_status_q                  ;
  reg        pipe_rx_phy_status_q              ;
  reg        pipe_rx_elec_idle_q               ;
  reg        pipe_rx_eqdone_q                  ;
  reg        pipe_rx_eqlpadaptdone_q           ;
  reg        pipe_rx_eqlplffssel_q             ;
  reg [17:0] pipe_rx_eqlpnewtxcoefforpreset_q  ;
  reg        pipe_rx_startblock_q              ;
  reg [ 1:0] pipe_rx_syncheader_q              ;
  reg        pipe_rx_slide_q                   ;
  reg        pipe_rx_syncdone_q                ;
  reg        pipe_rx_polarity_q                ;
  reg [ 1:0] pipe_rx_eqcontrol_q               ;
  reg [ 5:0] pipe_rx_eqlplffs_q                ;
  reg [ 3:0] pipe_rx_eqlptxpreset_q            ;
  reg [ 2:0] pipe_rx_eqpreset_q                ;
  reg [17:0] pipe_tx_eqcoeff_q                 ;
  reg        pipe_tx_eqdone_q                  ;
  reg        pipe_tx_compliance_q              ;
  reg [ 1:0] pipe_tx_char_is_k_q               ;
  reg [31:0] pipe_tx_data_q                    ;
  reg        pipe_tx_elec_idle_q               ;
  reg [ 1:0] pipe_tx_powerdown_q               ;
  reg        pipe_tx_datavalid_q               ;
  reg        pipe_tx_startblock_q              ;
  reg [ 1:0] pipe_tx_syncheader_q              ;
  reg [ 1:0] pipe_tx_eqcontrol_q               ;
  reg [ 5:0] pipe_tx_eqdeemph_q                ;
  reg [ 3:0] pipe_tx_eqpreset_q                ;


  reg [ 1:0] pipe_rx_char_is_k_qq              ;
  reg [31:0] pipe_rx_data_qq                   ;
  reg        pipe_rx_valid_qq                  ;
  reg        pipe_rx_data_valid_qq             ;
  reg [ 2:0] pipe_rx_status_qq                 ;
  reg        pipe_rx_phy_status_qq             ;
  reg        pipe_rx_elec_idle_qq              ;
  reg        pipe_rx_eqdone_qq                 ;
  reg        pipe_rx_eqlpadaptdone_qq          ;
  reg        pipe_rx_eqlplffssel_qq            ;
  reg [17:0] pipe_rx_eqlpnewtxcoefforpreset_qq ;
  reg        pipe_rx_startblock_qq             ;
  reg [ 1:0] pipe_rx_syncheader_qq             ;
  reg        pipe_rx_slide_qq                  ;
  reg        pipe_rx_syncdone_qq               ;
  reg        pipe_rx_polarity_qq               ;
  reg [ 1:0] pipe_rx_eqcontrol_qq              ;
  reg [ 5:0] pipe_rx_eqlplffs_qq               ;
  reg [ 3:0] pipe_rx_eqlptxpreset_qq           ;
  reg [ 2:0] pipe_rx_eqpreset_qq               ;
  reg [17:0] pipe_tx_eqcoeff_qq                ;
  reg        pipe_tx_eqdone_qq                 ;
  reg        pipe_tx_compliance_qq             ;
  reg [ 1:0] pipe_tx_char_is_k_qq              ;
  reg [31:0] pipe_tx_data_qq                   ;
  reg        pipe_tx_elec_idle_qq              ;
  reg [ 1:0] pipe_tx_powerdown_qq              ;
  reg        pipe_tx_datavalid_qq              ;
  reg        pipe_tx_startblock_qq             ;
  reg [ 1:0] pipe_tx_syncheader_qq             ;
  reg [ 1:0] pipe_tx_eqcontrol_qq              ;
  reg [ 5:0] pipe_tx_eqdeemph_qq               ;
  reg [ 3:0] pipe_tx_eqpreset_qq               ;

  generate

    if (PIPE_PIPELINE_STAGES == 0) begin : pipe_stages_0

      assign pipe_rx_char_is_k_o              = pipe_rx_char_is_k_i              ;
      assign pipe_rx_data_o                   = pipe_rx_data_i                   ;
      assign pipe_rx_valid_o                  = pipe_rx_valid_i                  ;
      assign pipe_rx_data_valid_o             = pipe_rx_data_valid_i             ;
      assign pipe_rx_status_o                 = pipe_rx_status_i                 ;
      assign pipe_rx_phy_status_o             = pipe_rx_phy_status_i             ;
      assign pipe_rx_elec_idle_o              = pipe_rx_elec_idle_i              ;
      assign pipe_rx_eqdone_o                 = pipe_rx_eqdone_i                 ;
      assign pipe_rx_eqlpadaptdone_o          = pipe_rx_eqlpadaptdone_i          ;
      assign pipe_rx_eqlplffssel_o            = pipe_rx_eqlplffssel_i            ;
      assign pipe_rx_eqlpnewtxcoefforpreset_o = pipe_rx_eqlpnewtxcoefforpreset_i ;
      assign pipe_rx_startblock_o             = pipe_rx_startblock_i             ;
      assign pipe_rx_syncheader_o             = pipe_rx_syncheader_i             ;
      assign pipe_rx_slide_o                  = pipe_rx_slide_i                  ;
      assign pipe_rx_syncdone_o               = pipe_rx_syncdone_i               ;

      assign pipe_rx_polarity_o               = pipe_rx_polarity_i               ;
      assign pipe_rx_eqcontrol_o              = pipe_rx_eqcontrol_i              ;
      assign pipe_rx_eqlplffs_o               = pipe_rx_eqlplffs_i               ;
      assign pipe_rx_eqlptxpreset_o           = pipe_rx_eqlptxpreset_i           ;
      assign pipe_rx_eqpreset_o               = pipe_rx_eqpreset_i               ;

      assign pipe_tx_eqcoeff_o                = pipe_tx_eqcoeff_i                ;
      assign pipe_tx_eqdone_o                 = pipe_tx_eqdone_i                 ;

      assign pipe_tx_compliance_o             = pipe_tx_compliance_i             ;
      assign pipe_tx_char_is_k_o              = pipe_tx_char_is_k_i              ;
      assign pipe_tx_data_o                   = pipe_tx_data_i                   ;
      assign pipe_tx_elec_idle_o              = pipe_tx_elec_idle_i              ;
      assign pipe_tx_powerdown_o              = pipe_tx_powerdown_i              ;
      assign pipe_tx_datavalid_o              = pipe_tx_datavalid_i              ;
      assign pipe_tx_startblock_o             = pipe_tx_startblock_i             ;
      assign pipe_tx_syncheader_o             = pipe_tx_syncheader_i             ;
      assign pipe_tx_eqcontrol_o              = pipe_tx_eqcontrol_i              ;
      assign pipe_tx_eqdeemph_o               = pipe_tx_eqdeemph_i               ;
      assign pipe_tx_eqpreset_o               = pipe_tx_eqpreset_i               ;

    end // if (PIPE_PIPELINE_STAGES == 0)
    else if (PIPE_PIPELINE_STAGES == 1) begin : pipe_stages_1

      always @(posedge pipe_clk) begin

        if (!rst_n)
        begin

          pipe_rx_char_is_k_q              <= #TCQ  2'b00;
          pipe_rx_data_q                   <= #TCQ 32'h00000000;
          pipe_rx_valid_q                  <= #TCQ  1'b0;
          pipe_rx_data_valid_q             <= #TCQ  1'b0;
          pipe_rx_status_q                 <= #TCQ  2'b00;
          pipe_rx_phy_status_q             <= #TCQ  1'b0;
          pipe_rx_elec_idle_q              <= #TCQ  1'b1;
          pipe_rx_eqdone_q                 <= #TCQ  1'b0;
          pipe_rx_eqlpadaptdone_q          <= #TCQ  1'b0;
          pipe_rx_eqlplffssel_q            <= #TCQ  1'b0;
          pipe_rx_eqlpnewtxcoefforpreset_q <= #TCQ 17'b00000000000000000;
          pipe_rx_startblock_q             <= #TCQ  1'b0;
          pipe_rx_syncheader_q             <= #TCQ  2'b00;
          pipe_rx_slide_q                  <= #TCQ  1'b0;
          pipe_rx_syncdone_q               <= #TCQ  1'b0;

          pipe_rx_polarity_q               <= #TCQ 17'b00000000000000000;
          pipe_rx_eqcontrol_q              <= #TCQ  1'b0;
          pipe_rx_eqlplffs_q               <= #TCQ  1'b0;
          pipe_rx_eqlptxpreset_q           <= #TCQ  2'b00;
          pipe_rx_eqpreset_q               <= #TCQ  6'b000000;

          pipe_tx_eqcoeff_q                <= #TCQ  4'h0;
          pipe_tx_eqdone_q                 <= #TCQ  3'b000;

          pipe_tx_compliance_q             <= #TCQ  1'b0;
          pipe_tx_char_is_k_q              <= #TCQ  2'b00;
          pipe_tx_data_q                   <= #TCQ 32'h00000000;
          pipe_tx_elec_idle_q              <= #TCQ  1'b1;
          pipe_tx_powerdown_q              <= #TCQ  2'b00;
          pipe_tx_datavalid_q              <= #TCQ  1'b0;
          pipe_tx_startblock_q             <= #TCQ  1'b0;
          pipe_tx_syncheader_q             <= #TCQ  2'b00;
          pipe_tx_eqcontrol_q              <= #TCQ  2'b00;
          pipe_tx_eqdeemph_q               <= #TCQ  6'b000000;
          pipe_tx_eqpreset_q               <= #TCQ  4'h0;

        end
        else
        begin

          pipe_rx_char_is_k_q              <= #TCQ pipe_rx_char_is_k_i              ;
          pipe_rx_data_q                   <= #TCQ pipe_rx_data_i                   ;
          pipe_rx_valid_q                  <= #TCQ pipe_rx_valid_i                  ;
          pipe_rx_data_valid_q             <= #TCQ pipe_rx_data_valid_i             ;
          pipe_rx_status_q                 <= #TCQ pipe_rx_status_i                 ;
          pipe_rx_phy_status_q             <= #TCQ pipe_rx_phy_status_i             ;
          pipe_rx_elec_idle_q              <= #TCQ pipe_rx_elec_idle_i              ;
          pipe_rx_eqdone_q                 <= #TCQ pipe_rx_eqdone_i                 ;
          pipe_rx_eqlpadaptdone_q          <= #TCQ pipe_rx_eqlpadaptdone_i          ;
          pipe_rx_eqlplffssel_q            <= #TCQ pipe_rx_eqlplffssel_i            ;
          pipe_rx_eqlpnewtxcoefforpreset_q <= #TCQ pipe_rx_eqlpnewtxcoefforpreset_i ;
          pipe_rx_startblock_q             <= #TCQ pipe_rx_startblock_i             ;
          pipe_rx_syncheader_q             <= #TCQ pipe_rx_syncheader_i             ;
          pipe_rx_slide_q                  <= #TCQ  pipe_rx_slide_i                 ;
          pipe_rx_syncdone_q               <= #TCQ  pipe_rx_syncdone_i              ;

          pipe_rx_polarity_q               <= #TCQ pipe_rx_polarity_i               ;
          pipe_rx_eqcontrol_q              <= #TCQ pipe_rx_eqcontrol_i              ;
          pipe_rx_eqlplffs_q               <= #TCQ pipe_rx_eqlplffs_i               ;
          pipe_rx_eqlptxpreset_q           <= #TCQ pipe_rx_eqlptxpreset_i           ;
          pipe_rx_eqpreset_q               <= #TCQ pipe_rx_eqpreset_i               ;

          pipe_tx_eqcoeff_q                <= #TCQ pipe_tx_eqcoeff_i                ;
          pipe_tx_eqdone_q                 <= #TCQ pipe_tx_eqdone_i                 ;

          pipe_tx_compliance_q             <= #TCQ pipe_tx_compliance_i             ;
          pipe_tx_char_is_k_q              <= #TCQ pipe_tx_char_is_k_i              ;
          pipe_tx_data_q                   <= #TCQ pipe_tx_data_i                   ;
          pipe_tx_elec_idle_q              <= #TCQ pipe_tx_elec_idle_i              ;
          pipe_tx_powerdown_q              <= #TCQ pipe_tx_powerdown_i              ;
          pipe_tx_datavalid_q              <= #TCQ pipe_tx_datavalid_i              ;
          pipe_tx_startblock_q             <= #TCQ pipe_tx_startblock_i             ;
          pipe_tx_syncheader_q             <= #TCQ pipe_tx_syncheader_i             ;
          pipe_tx_eqcontrol_q              <= #TCQ pipe_tx_eqcontrol_i              ;
          pipe_tx_eqdeemph_q               <= #TCQ pipe_tx_eqdeemph_i               ;
          pipe_tx_eqpreset_q               <= #TCQ pipe_tx_eqpreset_i               ;

        end

      end

      assign pipe_rx_char_is_k_o              = pipe_rx_char_is_k_q                 ;
      assign pipe_rx_data_o                   = pipe_rx_data_q                      ;
      assign pipe_rx_valid_o                  = pipe_rx_valid_q                     ;
      assign pipe_rx_data_valid_o             = pipe_rx_data_valid_q                ;
      assign pipe_rx_status_o                 = pipe_rx_status_q                    ;
      assign pipe_rx_phy_status_o             = pipe_rx_phy_status_q                ;
      assign pipe_rx_elec_idle_o              = pipe_rx_elec_idle_q                 ;
      assign pipe_rx_eqdone_o                 = pipe_rx_eqdone_q                    ;
      assign pipe_rx_eqlpadaptdone_o          = pipe_rx_eqlpadaptdone_q             ;
      assign pipe_rx_eqlplffssel_o            = pipe_rx_eqlplffssel_q               ;
      assign pipe_rx_eqlpnewtxcoefforpreset_o = pipe_rx_eqlpnewtxcoefforpreset_q    ;
      assign pipe_rx_startblock_o             = pipe_rx_startblock_q                ;
      assign pipe_rx_syncheader_o             = pipe_rx_syncheader_q                ;
      assign pipe_rx_slide_o                  = pipe_rx_slide_q                     ;
      assign pipe_rx_syncdone_o               = pipe_rx_syncdone_q                  ;

      assign pipe_rx_polarity_o               = pipe_rx_polarity_q                  ;
      assign pipe_rx_eqcontrol_o              = pipe_rx_eqcontrol_q                 ;
      assign pipe_rx_eqlplffs_o               = pipe_rx_eqlplffs_q                  ;
      assign pipe_rx_eqlptxpreset_o           = pipe_rx_eqlptxpreset_q              ;
      assign pipe_rx_eqpreset_o               = pipe_rx_eqpreset_q                  ;

      assign pipe_tx_eqcoeff_o                = pipe_tx_eqcoeff_q                   ;
      assign pipe_tx_eqdone_o                 = pipe_tx_eqdone_q                    ;

      assign pipe_tx_compliance_o             = pipe_tx_compliance_q                ;
      assign pipe_tx_char_is_k_o              = pipe_tx_char_is_k_q                 ;
      assign pipe_tx_data_o                   = pipe_tx_data_q                      ;
      assign pipe_tx_elec_idle_o              = pipe_tx_elec_idle_q                 ;
      assign pipe_tx_powerdown_o              = pipe_tx_powerdown_q                 ;
      assign pipe_tx_datavalid_o              = pipe_tx_datavalid_q                 ;
      assign pipe_tx_startblock_o             = pipe_tx_startblock_q                ;
      assign pipe_tx_syncheader_o             = pipe_tx_syncheader_q                ;
      assign pipe_tx_eqcontrol_o              = pipe_tx_eqcontrol_q                 ;
      assign pipe_tx_eqdeemph_o               = pipe_tx_eqdeemph_q                  ;
      assign pipe_tx_eqpreset_o               = pipe_tx_eqpreset_q                  ;

    end // if (PIPE_PIPELINE_STAGES == 1)
    else if (PIPE_PIPELINE_STAGES == 2) begin : pipe_stages_2

      always @(posedge pipe_clk) begin

        if (!rst_n)
        begin

          pipe_rx_char_is_k_q              <= #TCQ  2'b00;
          pipe_rx_data_q                   <= #TCQ 32'h00000000;
          pipe_rx_valid_q                  <= #TCQ  1'b0;
          pipe_rx_data_valid_q             <= #TCQ  1'b0;
          pipe_rx_status_q                 <= #TCQ  2'b00;
          pipe_rx_phy_status_q             <= #TCQ  1'b0;
          pipe_rx_elec_idle_q              <= #TCQ  1'b1;
          pipe_rx_eqdone_q                 <= #TCQ  1'b0;
          pipe_rx_eqlpadaptdone_q          <= #TCQ  1'b0;
          pipe_rx_eqlplffssel_q            <= #TCQ  1'b0;
          pipe_rx_eqlpnewtxcoefforpreset_q <= #TCQ 17'b00000000000000000;
          pipe_rx_startblock_q             <= #TCQ  1'b0;
          pipe_rx_syncheader_q             <= #TCQ  2'b00;
          pipe_rx_slide_q                  <= #TCQ  1'b0;
          pipe_rx_syncdone_q               <= #TCQ  1'b0;

          pipe_rx_polarity_q               <= #TCQ 17'b00000000000000000;
          pipe_rx_eqcontrol_q              <= #TCQ  1'b0;
          pipe_rx_eqlplffs_q               <= #TCQ  1'b0;
          pipe_rx_eqlptxpreset_q           <= #TCQ  2'b00;
          pipe_rx_eqpreset_q               <= #TCQ  6'b000000;

          pipe_tx_eqcoeff_q                <= #TCQ  4'h0;
          pipe_tx_eqdone_q                 <= #TCQ  3'b000;

          pipe_tx_compliance_q             <= #TCQ  1'b0;
          pipe_tx_char_is_k_q              <= #TCQ  2'b00;
          pipe_tx_data_q                   <= #TCQ 32'h00000000;
          pipe_tx_elec_idle_q              <= #TCQ  1'b1;
          pipe_tx_powerdown_q              <= #TCQ  2'b00;
          pipe_tx_datavalid_q              <= #TCQ  1'b0;
          pipe_tx_startblock_q             <= #TCQ  1'b0;
          pipe_tx_syncheader_q             <= #TCQ  2'b00;
          pipe_tx_eqcontrol_q              <= #TCQ  2'b00;
          pipe_tx_eqdeemph_q               <= #TCQ  6'b000000;
          pipe_tx_eqpreset_q               <= #TCQ  4'h0;


          pipe_rx_char_is_k_qq             <= #TCQ  2'b00;
          pipe_rx_data_qq                  <= #TCQ 32'h00000000;
          pipe_rx_valid_qq                 <= #TCQ  1'b0;
          pipe_rx_data_valid_qq            <= #TCQ  1'b0;
          pipe_rx_status_qq                <= #TCQ  2'b00;
          pipe_rx_phy_status_qq            <= #TCQ  1'b0;
          pipe_rx_elec_idle_qq             <= #TCQ  1'b1;
          pipe_rx_eqdone_qq                <= #TCQ  1'b0;
          pipe_rx_eqlpadaptdone_qq         <= #TCQ  1'b0;
          pipe_rx_eqlplffssel_qq           <= #TCQ  1'b0;
          pipe_rx_eqlpnewtxcoefforpreset_qq<= #TCQ 17'b00000000000000000;
          pipe_rx_startblock_qq            <= #TCQ  1'b0;
          pipe_rx_syncheader_qq            <= #TCQ  2'b00;
          pipe_rx_slide_qq                 <= #TCQ  1'b0;
          pipe_rx_syncdone_qq              <= #TCQ  1'b0;

          pipe_rx_polarity_qq              <= #TCQ 17'b00000000000000000;
          pipe_rx_eqcontrol_qq             <= #TCQ  1'b0;
          pipe_rx_eqlplffs_qq              <= #TCQ  1'b0;
          pipe_rx_eqlptxpreset_qq          <= #TCQ  2'b00;
          pipe_rx_eqpreset_qq              <= #TCQ  6'b000000;

          pipe_tx_eqcoeff_qq               <= #TCQ  4'h0;
          pipe_tx_eqdone_qq                <= #TCQ  3'b000;

          pipe_tx_compliance_qq            <= #TCQ  1'b0;
          pipe_tx_char_is_k_qq             <= #TCQ  2'b00;
          pipe_tx_data_qq                  <= #TCQ 32'h00000000;
          pipe_tx_elec_idle_qq             <= #TCQ  1'b1;
          pipe_tx_powerdown_qq             <= #TCQ  2'b00;
          pipe_tx_datavalid_qq             <= #TCQ  1'b0;
          pipe_tx_startblock_qq            <= #TCQ  1'b0;
          pipe_tx_syncheader_qq            <= #TCQ  2'b00;
          pipe_tx_eqcontrol_qq             <= #TCQ  2'b00;
          pipe_tx_eqdeemph_qq              <= #TCQ  6'b000000;
          pipe_tx_eqpreset_qq              <= #TCQ  4'h0;

        end
        else
        begin

          pipe_rx_char_is_k_q              <= #TCQ pipe_rx_char_is_k_i              ;
          pipe_rx_data_q                   <= #TCQ pipe_rx_data_i                   ;
          pipe_rx_valid_q                  <= #TCQ pipe_rx_valid_i                  ;
          pipe_rx_data_valid_q             <= #TCQ pipe_rx_data_valid_i             ;
          pipe_rx_status_q                 <= #TCQ pipe_rx_status_i                 ;
          pipe_rx_phy_status_q             <= #TCQ pipe_rx_phy_status_i             ;
          pipe_rx_elec_idle_q              <= #TCQ pipe_rx_elec_idle_i              ;
          pipe_rx_eqdone_q                 <= #TCQ pipe_rx_eqdone_i                 ;
          pipe_rx_eqlpadaptdone_q          <= #TCQ pipe_rx_eqlpadaptdone_i          ;
          pipe_rx_eqlplffssel_q            <= #TCQ pipe_rx_eqlplffssel_i            ;
          pipe_rx_eqlpnewtxcoefforpreset_q <= #TCQ pipe_rx_eqlpnewtxcoefforpreset_i ;
          pipe_rx_startblock_q             <= #TCQ pipe_rx_startblock_i             ;
          pipe_rx_syncheader_q             <= #TCQ pipe_rx_syncheader_i             ;
          pipe_rx_slide_q                  <= #TCQ  pipe_rx_slide_i                 ;
          pipe_rx_syncdone_q               <= #TCQ  pipe_rx_syncdone_i              ;

          pipe_rx_polarity_q               <= #TCQ pipe_rx_polarity_i               ;
          pipe_rx_eqcontrol_q              <= #TCQ pipe_rx_eqcontrol_i              ;
          pipe_rx_eqlplffs_q               <= #TCQ pipe_rx_eqlplffs_i               ;
          pipe_rx_eqlptxpreset_q           <= #TCQ pipe_rx_eqlptxpreset_i           ;
          pipe_rx_eqpreset_q               <= #TCQ pipe_rx_eqpreset_i               ;

          pipe_tx_eqcoeff_q                <= #TCQ pipe_tx_eqcoeff_i                ;
          pipe_tx_eqdone_q                 <= #TCQ pipe_tx_eqdone_i                 ;

          pipe_tx_compliance_q             <= #TCQ pipe_tx_compliance_i             ;
          pipe_tx_char_is_k_q              <= #TCQ pipe_tx_char_is_k_i              ;
          pipe_tx_data_q                   <= #TCQ pipe_tx_data_i                   ;
          pipe_tx_elec_idle_q              <= #TCQ pipe_tx_elec_idle_i              ;
          pipe_tx_powerdown_q              <= #TCQ pipe_tx_powerdown_i              ;
          pipe_tx_datavalid_q              <= #TCQ pipe_tx_datavalid_i              ;
          pipe_tx_startblock_q             <= #TCQ pipe_tx_startblock_i             ;
          pipe_tx_syncheader_q             <= #TCQ pipe_tx_syncheader_i             ;
          pipe_tx_eqcontrol_q              <= #TCQ pipe_tx_eqcontrol_i              ;
          pipe_tx_eqdeemph_q               <= #TCQ pipe_tx_eqdeemph_i               ;
          pipe_tx_eqpreset_q               <= #TCQ pipe_tx_eqpreset_i               ;

          pipe_rx_char_is_k_qq             <= #TCQ pipe_rx_char_is_k_q              ;
          pipe_rx_data_qq                  <= #TCQ pipe_rx_data_q                   ;
          pipe_rx_valid_qq                 <= #TCQ pipe_rx_valid_q                  ;
          pipe_rx_data_valid_qq            <= #TCQ pipe_rx_data_valid_q             ;
          pipe_rx_status_qq                <= #TCQ pipe_rx_status_q                 ;
          pipe_rx_phy_status_qq            <= #TCQ pipe_rx_phy_status_q             ;
          pipe_rx_elec_idle_qq             <= #TCQ pipe_rx_elec_idle_q              ;
          pipe_rx_eqdone_qq                <= #TCQ pipe_rx_eqdone_q                 ;
          pipe_rx_eqlpadaptdone_qq         <= #TCQ pipe_rx_eqlpadaptdone_q          ;
          pipe_rx_eqlplffssel_qq           <= #TCQ pipe_rx_eqlplffssel_q            ;
          pipe_rx_eqlpnewtxcoefforpreset_qq<= #TCQ pipe_rx_eqlpnewtxcoefforpreset_q ;
          pipe_rx_startblock_qq            <= #TCQ pipe_rx_startblock_q             ;
          pipe_rx_syncheader_qq            <= #TCQ pipe_rx_syncheader_q             ;
          pipe_rx_slide_qq                  <= #TCQ  pipe_rx_slide_q                ;
          pipe_rx_syncdone_qq               <= #TCQ  pipe_rx_syncdone_q             ;

          pipe_rx_polarity_qq              <= #TCQ pipe_rx_polarity_q               ;
          pipe_rx_eqcontrol_qq             <= #TCQ pipe_rx_eqcontrol_q              ;
          pipe_rx_eqlplffs_qq              <= #TCQ pipe_rx_eqlplffs_q               ;
          pipe_rx_eqlptxpreset_qq          <= #TCQ pipe_rx_eqlptxpreset_q           ;
          pipe_rx_eqpreset_qq              <= #TCQ pipe_rx_eqpreset_q               ;

          pipe_tx_eqcoeff_qq               <= #TCQ pipe_tx_eqcoeff_q                ;
          pipe_tx_eqdone_qq                <= #TCQ pipe_tx_eqdone_q                 ;

          pipe_tx_compliance_qq            <= #TCQ pipe_tx_compliance_q             ;
          pipe_tx_char_is_k_qq             <= #TCQ pipe_tx_char_is_k_q              ;
          pipe_tx_data_qq                  <= #TCQ pipe_tx_data_q                   ;
          pipe_tx_elec_idle_qq             <= #TCQ pipe_tx_elec_idle_q              ;
          pipe_tx_powerdown_qq             <= #TCQ pipe_tx_powerdown_q              ;
          pipe_tx_datavalid_qq             <= #TCQ pipe_tx_datavalid_q              ;
          pipe_tx_startblock_qq            <= #TCQ pipe_tx_startblock_q             ;
          pipe_tx_syncheader_qq            <= #TCQ pipe_tx_syncheader_q             ;
          pipe_tx_eqcontrol_qq             <= #TCQ pipe_tx_eqcontrol_q              ;
          pipe_tx_eqdeemph_qq              <= #TCQ pipe_tx_eqdeemph_q               ;
          pipe_tx_eqpreset_qq              <= #TCQ pipe_tx_eqpreset_q               ;

        end

      end

      assign pipe_rx_char_is_k_o              = pipe_rx_char_is_k_qq              ;
      assign pipe_rx_data_o                   = pipe_rx_data_qq                   ;
      assign pipe_rx_valid_o                  = pipe_rx_valid_qq                  ;
      assign pipe_rx_data_valid_o             = pipe_rx_data_valid_qq             ;
      assign pipe_rx_status_o                 = pipe_rx_status_qq                 ;
      assign pipe_rx_phy_status_o             = pipe_rx_phy_status_qq             ;
      assign pipe_rx_elec_idle_o              = pipe_rx_elec_idle_qq              ;
      assign pipe_rx_eqdone_o                 = pipe_rx_eqdone_qq                 ;
      assign pipe_rx_eqlpadaptdone_o          = pipe_rx_eqlpadaptdone_qq          ;
      assign pipe_rx_eqlplffssel_o            = pipe_rx_eqlplffssel_qq            ;
      assign pipe_rx_eqlpnewtxcoefforpreset_o = pipe_rx_eqlpnewtxcoefforpreset_qq ;
      assign pipe_rx_startblock_o             = pipe_rx_startblock_qq             ;
      assign pipe_rx_syncheader_o             = pipe_rx_syncheader_qq             ;
      assign pipe_rx_slide_o                  = pipe_rx_slide_qq                  ;
      assign pipe_rx_syncdone_o               = pipe_rx_syncdone_qq               ;

      assign pipe_rx_polarity_o               = pipe_rx_polarity_qq               ;
      assign pipe_rx_eqcontrol_o              = pipe_rx_eqcontrol_qq              ;
      assign pipe_rx_eqlplffs_o               = pipe_rx_eqlplffs_qq               ;
      assign pipe_rx_eqlptxpreset_o           = pipe_rx_eqlptxpreset_qq           ;
      assign pipe_rx_eqpreset_o               = pipe_rx_eqpreset_qq               ;

      assign pipe_tx_eqcoeff_o                = pipe_tx_eqcoeff_qq                ;
      assign pipe_tx_eqdone_o                 = pipe_tx_eqdone_qq                 ;

      assign pipe_tx_compliance_o             = pipe_tx_compliance_qq             ;
      assign pipe_tx_char_is_k_o              = pipe_tx_char_is_k_qq              ;
      assign pipe_tx_data_o                   = pipe_tx_data_qq                   ;
      assign pipe_tx_elec_idle_o              = pipe_tx_elec_idle_qq              ;
      assign pipe_tx_powerdown_o              = pipe_tx_powerdown_qq              ;
      assign pipe_tx_datavalid_o              = pipe_tx_datavalid_qq              ;
      assign pipe_tx_startblock_o             = pipe_tx_startblock_qq             ;
      assign pipe_tx_syncheader_o             = pipe_tx_syncheader_qq             ;
      assign pipe_tx_eqcontrol_o              = pipe_tx_eqcontrol_qq              ;
      assign pipe_tx_eqdeemph_o               = pipe_tx_eqdeemph_qq               ;
      assign pipe_tx_eqpreset_o               = pipe_tx_eqpreset_qq               ;

    end // if (PIPE_PIPELINE_STAGES == 2)

    // Default to zero pipeline stages if PIPE_PIPELINE_STAGES != 0,1,2
    else begin
      assign pipe_rx_char_is_k_o              = pipe_rx_char_is_k_i              ;
      assign pipe_rx_data_o                   = pipe_rx_data_i                   ;
      assign pipe_rx_valid_o                  = pipe_rx_valid_i                  ;
      assign pipe_rx_data_valid_o             = pipe_rx_data_valid_i             ;
      assign pipe_rx_status_o                 = pipe_rx_status_i                 ;
      assign pipe_rx_phy_status_o             = pipe_rx_phy_status_i             ;
      assign pipe_rx_elec_idle_o              = pipe_rx_elec_idle_i              ;
      assign pipe_rx_eqdone_o                 = pipe_rx_eqdone_i                 ;
      assign pipe_rx_eqlpadaptdone_o          = pipe_rx_eqlpadaptdone_i          ;
      assign pipe_rx_eqlplffssel_o            = pipe_rx_eqlplffssel_i            ;
      assign pipe_rx_eqlpnewtxcoefforpreset_o = pipe_rx_eqlpnewtxcoefforpreset_i ;
      assign pipe_rx_startblock_o             = pipe_rx_startblock_i             ;
      assign pipe_rx_syncheader_o             = pipe_rx_syncheader_i             ;
      assign pipe_rx_slide_o                  = pipe_rx_slide_i                  ;
      assign pipe_rx_syncdone_o               = pipe_rx_syncdone_i               ;

      assign pipe_rx_polarity_o               = pipe_rx_polarity_i               ;
      assign pipe_rx_eqcontrol_o              = pipe_rx_eqcontrol_i              ;
      assign pipe_rx_eqlplffs_o               = pipe_rx_eqlplffs_i               ;
      assign pipe_rx_eqlptxpreset_o           = pipe_rx_eqlptxpreset_i           ;
      assign pipe_rx_eqpreset_o               = pipe_rx_eqpreset_i               ;

      assign pipe_tx_eqcoeff_o                = pipe_tx_eqcoeff_i                ;
      assign pipe_tx_eqdone_o                 = pipe_tx_eqdone_i                 ;

      assign pipe_tx_compliance_o             = pipe_tx_compliance_i             ;
      assign pipe_tx_char_is_k_o              = pipe_tx_char_is_k_i              ;
      assign pipe_tx_data_o                   = pipe_tx_data_i                   ;
      assign pipe_tx_elec_idle_o              = pipe_tx_elec_idle_i              ;
      assign pipe_tx_powerdown_o              = pipe_tx_powerdown_i              ;
      assign pipe_tx_datavalid_o              = pipe_tx_datavalid_i              ;
      assign pipe_tx_startblock_o             = pipe_tx_startblock_i             ;
      assign pipe_tx_syncheader_o             = pipe_tx_syncheader_i             ;
      assign pipe_tx_eqcontrol_o              = pipe_tx_eqcontrol_i              ;
      assign pipe_tx_eqdeemph_o               = pipe_tx_eqdeemph_i               ;
      assign pipe_tx_eqpreset_o               = pipe_tx_eqpreset_i               ;
    end
  endgenerate

endmodule

