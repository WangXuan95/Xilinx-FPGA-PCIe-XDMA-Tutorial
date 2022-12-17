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
// File       : xdma_0_pcie3_ip_pcie_force_adapt.v
// Version    : 4.2
//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : xdma_0_pcie3_ip_pcie_top.v                             //
// Description  : Instantiates GEN3 PCIe Integrated Block Wrapper and         //
//                connects the IP to the PIPE Interface Pipeline module, the  //
//                PCIe Initialization Controller, and the TPH Table           //
//                implemented in a RAMB36                                     //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
//      pcie_top.v                                                            //  
//          pcie_force_adapt.v                                                //
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

module xdma_0_pcie3_ip_pcie_force_adapt (
             
  input                     pipe_clk,
  input                     user_clk,
  input                     rx_clk,
  input       [5:0]         cfg_ltssm_state,  
  input       [2:0]         cfg_current_speed,
  
  input       [1:0]         pipe_tx0_rate,
  input                     pipe_rx0_elec_idle,
  input                     pipe_rx0_eqlp_adaptdone,
  input       [1:0]         pipe_tx0_eqcontrol, 

  input      [31:0]         pipe_rx0_data_in,
  input      [31:0]         pipe_rx1_data_in,
  input      [31:0]         pipe_rx2_data_in,
  input      [31:0]         pipe_rx3_data_in,
  input      [31:0]         pipe_rx4_data_in,
  input      [31:0]         pipe_rx5_data_in,
  input      [31:0]         pipe_rx6_data_in,
  input      [31:0]         pipe_rx7_data_in,
  
  input        [1:0]        pipe_rx0_eqcontrol_in,
  input        [1:0]        pipe_rx1_eqcontrol_in,
  input        [1:0]        pipe_rx2_eqcontrol_in,
  input        [1:0]        pipe_rx3_eqcontrol_in,
  input        [1:0]        pipe_rx4_eqcontrol_in,
  input        [1:0]        pipe_rx5_eqcontrol_in,
  input        [1:0]        pipe_rx6_eqcontrol_in,
  input        [1:0]        pipe_rx7_eqcontrol_in,

  output      [31:0]        pipe_rx0_data_out,
  output      [31:0]        pipe_rx1_data_out,
  output      [31:0]        pipe_rx2_data_out,
  output      [31:0]        pipe_rx3_data_out,
  output      [31:0]        pipe_rx4_data_out,
  output      [31:0]        pipe_rx5_data_out,
  output      [31:0]        pipe_rx6_data_out,
  output      [31:0]        pipe_rx7_data_out,  
 
  output       [1:0]        pipe_rx0_eqcontrol_out,
  output       [1:0]        pipe_rx1_eqcontrol_out,
  output       [1:0]        pipe_rx2_eqcontrol_out,
  output       [1:0]        pipe_rx3_eqcontrol_out,
  output       [1:0]        pipe_rx4_eqcontrol_out,
  output       [1:0]        pipe_rx5_eqcontrol_out,
  output       [1:0]        pipe_rx6_eqcontrol_out,
  output       [1:0]        pipe_rx7_eqcontrol_out

);
localparam      RXJITTER_TEK              = "TRUE";
//////////////////////////////////////Gen3 Extra Adaptation //////////////////////////////

//////////////////////////////////logic in user_clock domain///////////////////////////

(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)      reg  [5:0]   cfg_ltssm_state_reg = 6'b0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)      reg  [5:0]   cfg_ltssm_state_reg0 = 6'b0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)      reg  [5:0]   cfg_ltssm_state_reg1 = 6'b0;
 reg          speed_change = 1'b0;
 reg          gen3_flag = 1'b1;
 reg          cfg_loopback = 1'b0; 

 always @ (posedge user_clk )
  begin
    cfg_ltssm_state_reg      <= cfg_ltssm_state;
    cfg_ltssm_state_reg0     <= cfg_ltssm_state_reg;
    cfg_ltssm_state_reg1     <= cfg_ltssm_state_reg0;
  end
  
  // Flag to indicate the first transition to Gen3 
 always @ (posedge user_clk )
  begin
    if (cfg_ltssm_state_reg1 == 6'h10 && cfg_current_speed[2] )
      gen3_flag <= 1'b1;
    else if ((cfg_ltssm_state_reg1 == 6'hc || cfg_ltssm_state_reg1 == 6'hD ) && pipe_tx0_eqcontrol[0])  
      gen3_flag <= 1'b0;
    else 
      gen3_flag <= gen3_flag;
  end 
    
 // Flag to indicate Speed Change
 always @ (posedge user_clk )
  begin
    if ((cfg_ltssm_state_reg1 == 6'hc || cfg_ltssm_state_reg1 == 6'h18 ) && cfg_ltssm_state == 6'hb)   
    begin
      speed_change <= gen3_flag;
    end 
    else if (cfg_ltssm_state != 6'hb) begin
      speed_change <= 1'b0;
    end 
    else begin
      speed_change <= speed_change;
    end
  end

 // Flag to indicate cfg -> loopback slave
 generate
 if (RXJITTER_TEK == "TRUE") 
 begin: loopback
 always @ (posedge user_clk )
  begin
    if (cfg_ltssm_state_reg1 == 6'h25 || cfg_ltssm_state_reg1 == 6'h24 )    
    begin
      cfg_loopback <= 1'b1;
    end 
    else 
      cfg_loopback <= 1'b0;
  end   
 end      
 endgenerate
  
//////////////////////////////////logic in pipe_clock domain///////////////////////////
    wire         elec_idle_deasserted;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)         reg          speed_change_reg0  =1'b0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)         reg          speed_change_reg1  =1'b0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)         reg          speed_change_reg2  =1'b0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)         reg          cfg_loopback_reg0  =1'b0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)         reg          cfg_loopback_reg1  =1'b0;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)         reg          cfg_loopback_reg2  =1'b0;
    reg  [3:0]   eq_state           =4'b0001;
    reg         pipe_eq_adapt = 1'b0;
    localparam  EQ_IDLE     = 4'b0001;
    localparam  EQ_ADAPT    = 4'b0010;
    localparam  EQ_RX_TEK   = 4'b0100;
    localparam  EQ_WAIT     = 4'b1000;
    
    
    // Device should be in R.RL with elec idle deasserted for force adapttation to start
    
    assign elec_idle_deasserted = ~ pipe_rx0_elec_idle;
    
    
   // CDC speed_change from user clock to pipe clock domain 
  always @ (posedge pipe_clk )
   begin
    speed_change_reg0            <= speed_change;
    speed_change_reg1            <= speed_change_reg0;
    speed_change_reg2            <= speed_change_reg1;
   end
   
// CDC cfg_loopback from user clock to pipe clock domain 
  always @ (posedge pipe_clk )
   begin
    cfg_loopback_reg0            <= cfg_loopback;
    cfg_loopback_reg1            <= cfg_loopback_reg0;
    cfg_loopback_reg2            <= cfg_loopback_reg1;
   end

  // State Machine to Control Forced Adaptation
  always @ (posedge pipe_clk )
   begin
   case(eq_state)
    EQ_IDLE : begin 
      if (speed_change_reg2 && elec_idle_deasserted && pipe_tx0_rate[1]) 
        eq_state                <= EQ_ADAPT;
      else if (cfg_loopback_reg2 && pipe_tx0_rate[1]) 
         eq_state               <= EQ_RX_TEK;
      else 
        eq_state                <= EQ_IDLE;
      end
    EQ_ADAPT : begin 
      if (pipe_rx0_eqlp_adaptdone) 
        eq_state                <= EQ_WAIT;
      else 
        eq_state                <= EQ_ADAPT;
      end  
    EQ_RX_TEK : begin 
      if (pipe_rx0_eqlp_adaptdone) 
        eq_state                <= EQ_IDLE;
      else 
        eq_state                <= EQ_RX_TEK;
      end  
    EQ_WAIT : begin 
      if (!speed_change_reg2) 
        eq_state                <= EQ_IDLE;
      else 
        eq_state                <= EQ_WAIT;
      end      
   endcase
   end

  assign pipe_rx0_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx0_data_in;
  assign pipe_rx1_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx1_data_in;
  assign pipe_rx2_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx2_data_in;
  assign pipe_rx3_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx3_data_in;
  assign pipe_rx4_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx4_data_in;
  assign pipe_rx5_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx5_data_in;
  assign pipe_rx6_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx6_data_in;
  assign pipe_rx7_data_out = (eq_state == EQ_ADAPT) ? {32{1'b1}}: pipe_rx7_data_in;
  
  assign pipe_rx0_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx0_eqcontrol_in;
  assign pipe_rx1_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx1_eqcontrol_in;
  assign pipe_rx2_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx2_eqcontrol_in;
  assign pipe_rx3_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx3_eqcontrol_in;
  assign pipe_rx4_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx4_eqcontrol_in;
  assign pipe_rx5_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx5_eqcontrol_in;
  assign pipe_rx6_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx6_eqcontrol_in;
  assign pipe_rx7_eqcontrol_out =  ((eq_state == EQ_ADAPT) || (eq_state == EQ_RX_TEK)) ? 2'b11 : pipe_rx7_eqcontrol_in;


endmodule
