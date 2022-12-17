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
// File       : xdma_0_pcie3_ip_pcie_bram_7vx.v
// Version    : 4.2
//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : xdma_0_pcie3_ip_pcie_3_0_7vx.v                                              //
// Description  : Instantiates the 3 buffers used by the Gen3 Integrated      //
//                block for PCI Express (TX replay, RX Request, RX Completion //
//                                                                            //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
//  pcie_bram_7vx.v                                                           //
//      pcie_bram_7vx_rep.v                                                   //
//          pcie_bram_7vx_rep_8k.v                                            //
//      pcie_bram_7vx_req.v                                                   //
//          pcie_bram_7vx_8k.v                                                //
//      pcie_bram_7vx_cpl.v                                                   //
//          pcie_bram_7vx_8k.v                                                //
//          pcie_bram_7vx_16k.v                                               //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module xdma_0_pcie3_ip_pcie_bram_7vx #(

  parameter IMPL_TARGET      = "HARD",     // the implementation target, HARD or SOFT
  parameter NO_DECODE_LOGIC  = "TRUE",     // No decode logic, TRUE or FALSE
  parameter INTERFACE_SPEED  = "500 MHZ",  // the memory interface speed, 500 MHz or 250 MHz.
  parameter COMPLETION_SPACE = "16KB"     // the completion FIFO spec, 8KB or 16KB

) (
  input               clk_i,     // user clock
  input               reset_i,   // bram reset

  input    [8:0]      mi_rep_addr_i,    // address

  input  [127:0]      mi_rep_wdata_i,   // write data
  input   [15:0]      mi_rep_wdip_i,    // write parity
  input               mi_rep_wen0_i,    // write enable0
  input               mi_rep_wen1_i,    // write enable1

  output [127:0]      mi_rep_rdata_o,   // read data
  output  [15:0]      mi_rep_rdop_o,    // read parity

  input    [8:0]      mi_req_waddr0_i,   // write address0
  input    [8:0]      mi_req_waddr1_i,   // write address0
  input  [127:0]      mi_req_wdata_i,   // write data
  input   [15:0]      mi_req_wdip_i,    // write parity
  input               mi_req_wen0_i,    // write enable0
  input               mi_req_wen1_i,    // write enable1
  input               mi_req_wen2_i,    // write enable1
  input               mi_req_wen3_i,    // write enable1

  input    [8:0]      mi_req_raddr0_i,   // write address0
  input    [8:0]      mi_req_raddr1_i,   // write address0
  output [127:0]      mi_req_rdata_o,   // read data
  output  [15:0]      mi_req_rdop_o,    // read parity
  input               mi_req_ren0_i,    // read enable0
  input               mi_req_ren1_i,    // read enable1
  input               mi_req_ren2_i,    // read enable1
  input               mi_req_ren3_i,    // read enable1

  input    [9:0]      mi_cpl_waddr0_i,  // write address0
  input    [9:0]      mi_cpl_waddr1_i,  // write address1
  input    [9:0]      mi_cpl_waddr2_i,  // write address2
  input    [9:0]      mi_cpl_waddr3_i,  // write address3
  input  [127:0]      mi_cpl_wdata_i,   // write data
  input   [15:0]      mi_cpl_wdip_i,    // write parity
  input               mi_cpl_wen0_i,    // write enable0
  input               mi_cpl_wen1_i,    // write enable1
  input               mi_cpl_wen2_i,    // write enable2
  input               mi_cpl_wen3_i,    // write enable3
  input               mi_cpl_wen4_i,    // write enable4
  input               mi_cpl_wen5_i,    // write enable5
  input               mi_cpl_wen6_i,    // write enable6
  input               mi_cpl_wen7_i,    // write enable7

  input    [9:0]      mi_cpl_raddr0_i,  // write address0
  input    [9:0]      mi_cpl_raddr1_i,  // write address1
  input    [9:0]      mi_cpl_raddr2_i,  // write address2
  input    [9:0]      mi_cpl_raddr3_i,  // write address3
  output [127:0]      mi_cpl_rdata_o,   // read data
  output  [15:0]      mi_cpl_rdop_o,    // read parity
  input               mi_cpl_ren0_i,    // read enable0
  input               mi_cpl_ren1_i,    // read enable1
  input               mi_cpl_ren2_i,    // read enable2
  input               mi_cpl_ren3_i,    // read enable3
  input               mi_cpl_ren4_i,    // read enable4
  input               mi_cpl_ren5_i,    // read enable5
  input               mi_cpl_ren6_i,    // read enable6
  input               mi_cpl_ren7_i     // read enable7

);


  //
  // Single Ported 8KB Replay Buffer
  //

  xdma_0_pcie3_ip_pcie_bram_7vx_rep # (

    .IMPL_TARGET(IMPL_TARGET),
    .NO_DECODE_LOGIC(NO_DECODE_LOGIC),
    .INTERFACE_SPEED(INTERFACE_SPEED),
    .COMPLETION_SPACE(COMPLETION_SPACE)

  )
  replay_buffer
  (
    .clk_i              (clk_i),
    .reset_i            (reset_i),

    .addr_i             (mi_rep_addr_i[8:0]),
    .wdata_i            (mi_rep_wdata_i[127:0]),
    .wdip_i             (mi_rep_wdip_i[15:0]),
    .wen0_i             (mi_rep_wen0_i),
    .wen1_i             (mi_rep_wen1_i),

    .rdata_o            (mi_rep_rdata_o[127:0]),
    .rdop_o             (mi_rep_rdop_o[15:0])

  );

  //
  // 8KB Receive Request FIFO
  //

  xdma_0_pcie3_ip_pcie_bram_7vx_req # (

    .IMPL_TARGET(IMPL_TARGET),
    .NO_DECODE_LOGIC(NO_DECODE_LOGIC),
    .INTERFACE_SPEED(INTERFACE_SPEED),
    .COMPLETION_SPACE(COMPLETION_SPACE)

  )
  req_fifo
  (
    .clk_i              (clk_i),
    .reset_i            (reset_i),

    .waddr0_i           (mi_req_waddr0_i[8:0]),
    .waddr1_i           (mi_req_waddr1_i[8:0]),
    .wdata_i            (mi_req_wdata_i[127:0]),
    .wdip_i             (mi_req_wdip_i[15:0]),
    .wen0_i             (mi_req_wen0_i),
    .wen1_i             (mi_req_wen1_i),
    .wen2_i             (mi_req_wen2_i),
    .wen3_i             (mi_req_wen3_i),

    .raddr0_i           (mi_req_raddr0_i[8:0]),
    .raddr1_i           (mi_req_raddr1_i[8:0]),
    .rdata_o            (mi_req_rdata_o[127:0]),
    .rdop_o             (mi_req_rdop_o[15:0]),
    .ren0_i             (mi_req_ren0_i),
    .ren1_i             (mi_req_ren1_i),
    .ren2_i             (mi_req_ren2_i),
    .ren3_i             (mi_req_ren3_i)

  );

  //
  // 8KB or 16KB Receive Completion FIFO
  //

  xdma_0_pcie3_ip_pcie_bram_7vx_cpl # (

    .IMPL_TARGET(IMPL_TARGET),
    .NO_DECODE_LOGIC(NO_DECODE_LOGIC),
    .INTERFACE_SPEED(INTERFACE_SPEED),
    .COMPLETION_SPACE(COMPLETION_SPACE)

  )
  cpl_fifo
  (
    .clk_i              (clk_i),
    .reset_i            (reset_i),

    .waddr0_i           (mi_cpl_waddr0_i[9:0]),
    .waddr1_i           (mi_cpl_waddr1_i[9:0]),
    .waddr2_i           (mi_cpl_waddr2_i[9:0]),
    .waddr3_i           (mi_cpl_waddr3_i[9:0]),
    .wdata_i            (mi_cpl_wdata_i[127:0]),
    .wdip_i             (mi_cpl_wdip_i[15:0]),
    .wen0_i             (mi_cpl_wen0_i),
    .wen1_i             (mi_cpl_wen1_i),
    .wen2_i             (mi_cpl_wen2_i),
    .wen3_i             (mi_cpl_wen3_i),
    .wen4_i             (mi_cpl_wen4_i),
    .wen5_i             (mi_cpl_wen5_i),
    .wen6_i             (mi_cpl_wen6_i),
    .wen7_i             (mi_cpl_wen7_i),

    .raddr0_i           (mi_cpl_raddr0_i[9:0]),
    .raddr1_i           (mi_cpl_raddr1_i[9:0]),
    .raddr2_i           (mi_cpl_raddr2_i[9:0]),
    .raddr3_i           (mi_cpl_raddr3_i[9:0]),
    .rdata_o            (mi_cpl_rdata_o[127:0]),
    .rdop_o             (mi_cpl_rdop_o[15:0]),
    .ren0_i             (mi_cpl_ren0_i),
    .ren1_i             (mi_cpl_ren1_i),
    .ren2_i             (mi_cpl_ren2_i),
    .ren3_i             (mi_cpl_ren3_i),
    .ren4_i             (mi_cpl_ren4_i),
    .ren5_i             (mi_cpl_ren5_i),
    .ren6_i             (mi_cpl_ren6_i),
    .ren7_i             (mi_cpl_ren7_i)

  );

endmodule // pcie_bram_7vx
