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
// File       : xdma_0_pcie3_ip_pcie_bram_7vx_16k.v
// Version    : 4.2
//----------------------------------------------------------------------------//
// Project      : Virtex-7 FPGA Gen3 Integrated Block for PCI Express         //
// Filename     : xdma_0_pcie3_ip_pcie_bram_7vx_16k.v                                         //
// Description  :  Implements 16 KB Dual Ported Memory                        //
//                   - Output Regs are always enabled                         //
//                   - if NO_DECODE_LOGIC = TRUE    -> 8xRAMB18E1 in TDP mode //
//                   - if INTERFACE_SPEED = 500 MHz -> 8xRAMB18E1 in TDP mode //
//                   - if INTERFACE_SPEED = 250 MHz -> 4xRAMB36E1 in SDP mode //
//                                                                            //
//---------- PIPE Wrapper Hierarchy ------------------------------------------//
//  pcie_bram_7vx_16k.v                                                       //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module xdma_0_pcie3_ip_pcie_bram_7vx_16k #(

  parameter IMPL_TARGET = "HARD",         // the implementation target, HARD or SOFT
  parameter NO_DECODE_LOGIC = "TRUE",     // No decode logic, TRUE or FALSE
  parameter INTERFACE_SPEED = "500 MHZ",  // the memory interface speed, 500 MHz or 250 MHz.
  parameter COMPLETION_SPACE = "16 KB"    // the completion FIFO spec, 8KB or 16KB

)
(
  input               clk_i,    // user clock
  input               reset_i,  // bram reset

  input    [9:0]      waddr0_i, // write address
  input    [9:0]      waddr1_i, // write address
  input    [9:0]      waddr2_i, // write address
  input    [9:0]      waddr3_i, // write address
  input  [127:0]      wdata_i,  // write data
  input   [15:0]      wdip_i,   // write parity
  input    [7:0]      wen_i,    // write enable

  input    [9:0]      raddr0_i, // write address
  input    [9:0]      raddr1_i, // write address
  input    [9:0]      raddr2_i, // write address
  input    [9:0]      raddr3_i, // write address
  output [127:0]      rdata_o,  // read data
  output  [15:0]      rdop_o,   // read parity
  input    [7:0]      ren_i     // read enable

);

 // Local Params

  localparam           TCQ                         =  1;

  genvar              i;
  wire     [79:0]     waddr;
  wire     [79:0]     raddr;
  wire      [7:0]     wen;
  wire      [7:0]     ren;
  wire    [255:0]     rdata_w;
  wire     [31:0]     rdop_w;
  wire    [255:0]     wdata_w;
  wire     [31:0]     wdip_w;

  reg                 raddr0_q = 1'b0;
  reg                 raddr0_qq = 1'b0;

  assign wen = {wen_i[7], wen_i[6], wen_i[5], wen_i[4], wen_i[3], wen_i[2], wen_i[1], wen_i[0]};
  assign ren = {ren_i[7], ren_i[6], ren_i[5], ren_i[4], ren_i[3], ren_i[2], ren_i[1], ren_i[0]};

  generate 
  
    if ((INTERFACE_SPEED == "500 MHZ") || (NO_DECODE_LOGIC == "TRUE")) begin :  SPEED_500MHz_OR_NO_DECODE_LOGIC

      assign waddr = {waddr3_i, waddr3_i, waddr2_i, waddr2_i, waddr1_i, waddr1_i, waddr0_i, waddr0_i};
      assign raddr = {raddr3_i, raddr3_i, raddr2_i, raddr2_i, raddr1_i, raddr1_i, raddr0_i, raddr0_i};

      for (i = 0; i < 8; i = i + 1) begin : RAMB18E1
   
        RAMB18E1 #(

          .SIM_DEVICE ("7SERIES"),
          .DOA_REG ( 1 ),
          .DOB_REG ( 1 ),
          .SRVAL_A ( 18'h00000 ),
          .INIT_FILE ( "NONE" ),
          .RAM_MODE ( "TDP" ),
          .READ_WIDTH_A ( 18 ),
          .READ_WIDTH_B ( 18 ),
          .RSTREG_PRIORITY_A ( "REGCE" ),
          .RSTREG_PRIORITY_B ( "REGCE" ),
          .SIM_COLLISION_CHECK ( "ALL" ),
          .INIT_A ( 18'h00000 ),
          .INIT_B ( 18'h00000 ),
          .WRITE_MODE_A ( "WRITE_FIRST" ),
          .WRITE_MODE_B ( "WRITE_FIRST" ),
          .WRITE_WIDTH_A ( 18 ),
          .WRITE_WIDTH_B ( 18 ),
          .SRVAL_B ( 18'h00000 ))
  
        u_fifo (
  
          .CLKARDCLK(clk_i),
          .CLKBWRCLK(clk_i),
          .ENARDEN(1'b1),
          .ENBWREN(ren[i]),
          .REGCEAREGCE(1'b0),
          .REGCEB(1'b1 ),
          .RSTRAMARSTRAM(1'b0),
          .RSTRAMB(1'b0),
          .RSTREGARSTREG(1'b0),
          .RSTREGB(1'b0),
          .ADDRARDADDR({waddr[(10*i)+9:(10*i)+0], 4'b0}),
          .ADDRBWRADDR({raddr[(10*i)+9:(10*i)+0], 4'b0}),
          .DIADI(wdata_i[(16*i)+15:(16*i)+0]),
          .DIPADIP(wdip_i[(2*i)+1:(2*i)+0]),
          .DIBDI({16'b0}),
          .DIPBDIP(2'b0),
          .DOADO(),
          .DOBDO(rdata_o[(16*i)+15:(16*i)+0]),            
          .DOPADOP(),
          .DOPBDOP(rdop_o[(2*i)+1:(2*i)+0]),               
          .WEA({wen[i], wen[i]}),
          .WEBWE({1'b0, 1'b0, 1'b0, 1'b0})
    
        );

      end

    end else begin : SPEED_250MHz


      always @(posedge clk_i) begin

        if (reset_i) begin

          raddr0_q <= #(TCQ) 1'b0;
          raddr0_qq <= #(TCQ) 1'b0;

        end else begin

          raddr0_q <= #(TCQ) raddr0_i[9];
          raddr0_qq <= #(TCQ) raddr0_q;

        end

      end

      assign rdata_o = raddr0_qq ? rdata_w[255:128] : rdata_w[127:0]; 
      assign rdop_o = raddr0_qq ?  rdop_w[31:16] : rdop_w[15:0];
      assign wdata_w = {wdata_i, wdata_i};
      assign wdip_w = {wdip_i, wdip_i};
      assign waddr = {44'b0, waddr0_i[8:0], waddr1_i[8:0], waddr2_i[8:0], waddr3_i[8:0]};
      assign raddr = {44'b0, raddr0_i[8:0], raddr1_i[8:0], raddr2_i[8:0], raddr3_i[8:0]};

      for (i = 0; i < 4; i = i + 1) begin : RAMB36E1

        RAMB36E1 #(

          .SIM_DEVICE ("7SERIES"),
          .DOA_REG ( 1 ),
          .DOB_REG ( 1 ),
          .EN_ECC_READ ( "FALSE" ),
          .EN_ECC_WRITE ( "FALSE" ),
          .INIT_A ( 36'h000000000 ),
          .INIT_B ( 36'h000000000 ),
          .INIT_FILE ( "NONE" ),
          .RAM_EXTENSION_A ( "NONE" ),
          .RAM_EXTENSION_B ( "NONE" ),
          .RAM_MODE ( "SDP" ),
          .RDADDR_COLLISION_HWCONFIG ( "DELAYED_WRITE" ),
          .READ_WIDTH_A ( 72 ),
          .READ_WIDTH_B ( 0 ),
          .RSTREG_PRIORITY_A ( "REGCE" ),
          .RSTREG_PRIORITY_B ( "REGCE" ),
          .SIM_COLLISION_CHECK ( "ALL" ),
          .SRVAL_A ( 36'h000000000 ),
          .SRVAL_B ( 36'h000000000 ),
          .WRITE_MODE_A ( "WRITE_FIRST" ),
          .WRITE_MODE_B ( "WRITE_FIRST" ),
          .WRITE_WIDTH_A ( 0 ),
          .WRITE_WIDTH_B ( 72 )

        )
        u_fifo (

          .CASCADEINA(1'b0),
          .CASCADEINB(1'b0),
          .CASCADEOUTA( ),
          .CASCADEOUTB( ),
          .CLKARDCLK(clk_i),
          .CLKBWRCLK(clk_i),
          .DBITERR( ),
          .ENARDEN(((i > 1) ? (raddr0_i[9] & ren[2*i]) : (~raddr0_i[9] & ren[2*i]))),
          .ENBWREN(1'b1 ),
          .INJECTDBITERR(1'b0),
          .INJECTSBITERR(1'b0),
          .REGCEAREGCE(1'b1 ),
          .REGCEB(1'b0),
          .RSTRAMARSTRAM(1'b0),
          .RSTRAMB(1'b0),
          .RSTREGARSTREG(1'b0),
          .RSTREGB(1'b0),
          .SBITERR( ),
          .ADDRARDADDR({1'b1 , raddr[(9*i)+8:(9*i)+0], 6'b0}),
          .ADDRBWRADDR({1'b1 , waddr[(9*i)+8:(9*i)+0], 6'b0}),
          .DIADI(wdata_w[(2*32*i)+31:(2*32*i)+0]),
          .DIBDI(wdata_w[(2*32*i)+63:(2*32*i)+32]),
          .DIPADIP(wdip_w[(2*4*i)+3:(2*4*i)+0]),
          .DIPBDIP(wdip_w[(2*4*i)+7:(2*4*i)+4]),
          .DOADO(rdata_w[(2*32*i)+31:(2*32*i)+0]),
          .DOBDO(rdata_w[(2*32*i)+63:(2*32*i)+32]),
          .DOPADOP(rdop_w[(2*4*i)+3:(2*4*i)+0]),
          .DOPBDOP(rdop_w[(2*4*i)+7:(2*4*i)+4]),
          .ECCPARITY(),
          .RDADDRECC(),
          .WEA(4'b0),
          .WEBWE({8{((i > 1) ? (waddr0_i[9] & wen[2*i]) : (~waddr0_i[9] & wen[2*i]))}})

        );

      end

    end

  endgenerate

endmodule // pcie_bram_7vx_16k 

