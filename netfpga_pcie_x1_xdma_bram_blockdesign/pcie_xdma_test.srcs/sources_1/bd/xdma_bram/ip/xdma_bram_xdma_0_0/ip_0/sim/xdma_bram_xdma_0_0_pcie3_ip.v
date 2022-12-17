// (c) Copyright 1995-2022 Xilinx, Inc. All rights reserved.
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
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:ip:pcie3_7x:4.3
// IP Revision: 4

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module xdma_bram_xdma_0_0_pcie3_ip (
  pci_exp_txn,
  pci_exp_txp,
  pci_exp_rxn,
  pci_exp_rxp,
  mmcm_lock,
  user_clk,
  user_reset,
  user_lnk_up,
  user_app_rdy,
  s_axis_rq_tlast,
  s_axis_rq_tdata,
  s_axis_rq_tuser,
  s_axis_rq_tkeep,
  s_axis_rq_tready,
  s_axis_rq_tvalid,
  m_axis_rc_tdata,
  m_axis_rc_tuser,
  m_axis_rc_tlast,
  m_axis_rc_tkeep,
  m_axis_rc_tvalid,
  m_axis_rc_tready,
  m_axis_cq_tdata,
  m_axis_cq_tuser,
  m_axis_cq_tlast,
  m_axis_cq_tkeep,
  m_axis_cq_tvalid,
  m_axis_cq_tready,
  s_axis_cc_tdata,
  s_axis_cc_tuser,
  s_axis_cc_tlast,
  s_axis_cc_tkeep,
  s_axis_cc_tvalid,
  s_axis_cc_tready,
  pcie_rq_seq_num,
  pcie_rq_seq_num_vld,
  pcie_rq_tag,
  pcie_rq_tag_vld,
  pcie_tfc_nph_av,
  pcie_tfc_npd_av,
  pcie_cq_np_req,
  pcie_cq_np_req_count,
  cfg_phy_link_down,
  cfg_phy_link_status,
  cfg_negotiated_width,
  cfg_current_speed,
  cfg_max_payload,
  cfg_max_read_req,
  cfg_function_status,
  cfg_function_power_state,
  cfg_vf_status,
  cfg_vf_power_state,
  cfg_link_power_state,
  cfg_err_cor_out,
  cfg_err_nonfatal_out,
  cfg_err_fatal_out,
  cfg_ltr_enable,
  cfg_ltssm_state,
  cfg_rcb_status,
  cfg_dpa_substate_change,
  cfg_obff_enable,
  cfg_pl_status_change,
  cfg_tph_requester_enable,
  cfg_tph_st_mode,
  cfg_vf_tph_requester_enable,
  cfg_vf_tph_st_mode,
  cfg_msg_received,
  cfg_msg_received_data,
  cfg_msg_received_type,
  cfg_msg_transmit,
  cfg_msg_transmit_type,
  cfg_msg_transmit_data,
  cfg_msg_transmit_done,
  cfg_fc_ph,
  cfg_fc_pd,
  cfg_fc_nph,
  cfg_fc_npd,
  cfg_fc_cplh,
  cfg_fc_cpld,
  cfg_fc_sel,
  cfg_per_func_status_control,
  cfg_per_func_status_data,
  cfg_per_function_number,
  cfg_per_function_output_request,
  cfg_per_function_update_done,
  cfg_subsys_vend_id,
  cfg_dsn,
  cfg_power_state_change_ack,
  cfg_power_state_change_interrupt,
  cfg_err_cor_in,
  cfg_err_uncor_in,
  cfg_flr_in_process,
  cfg_flr_done,
  cfg_vf_flr_in_process,
  cfg_vf_flr_done,
  cfg_link_training_enable,
  cfg_interrupt_int,
  cfg_interrupt_pending,
  cfg_interrupt_sent,
  cfg_interrupt_msix_enable,
  cfg_interrupt_msix_mask,
  cfg_interrupt_msix_vf_enable,
  cfg_interrupt_msix_vf_mask,
  cfg_interrupt_msix_data,
  cfg_interrupt_msix_address,
  cfg_interrupt_msix_int,
  cfg_interrupt_msix_sent,
  cfg_interrupt_msix_fail,
  cfg_interrupt_msi_function_number,
  cfg_hot_reset_out,
  cfg_config_space_enable,
  cfg_req_pm_transition_l23_ready,
  cfg_hot_reset_in,
  cfg_ds_port_number,
  cfg_ds_bus_number,
  cfg_ds_device_number,
  cfg_ds_function_number,
  sys_clk,
  sys_reset
);

(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt txn" *)
output wire [0 : 0] pci_exp_txn;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt txp" *)
output wire [0 : 0] pci_exp_txp;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt rxn" *)
input wire [0 : 0] pci_exp_rxn;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_7x_mgt:1.0 pcie_7x_mgt rxp" *)
input wire [0 : 0] pci_exp_rxp;
output wire mmcm_lock;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.user_clk, ASSOCIATED_BUSIF m_axis_cq:s_axis_cc:s_axis_rq:m_axis_rc, FREQ_HZ 125000000, ASSOCIATED_RESET user_reset, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.user_clk CLK" *)
output wire user_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.user_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.user_reset RST" *)
output wire user_reset;
output wire user_lnk_up;
output wire user_app_rdy;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_rq TLAST" *)
input wire s_axis_rq_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_rq TDATA" *)
input wire [63 : 0] s_axis_rq_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_rq TUSER" *)
input wire [59 : 0] s_axis_rq_tuser;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_rq TKEEP" *)
input wire [1 : 0] s_axis_rq_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_rq TREADY" *)
output wire [3 : 0] s_axis_rq_tready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_rq, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 60, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_rq TVALID" *)
input wire s_axis_rq_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rc TDATA" *)
output wire [63 : 0] m_axis_rc_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rc TUSER" *)
output wire [74 : 0] m_axis_rc_tuser;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rc TLAST" *)
output wire m_axis_rc_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rc TKEEP" *)
output wire [1 : 0] m_axis_rc_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rc TVALID" *)
output wire m_axis_rc_tvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_rc, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 75, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rc TREADY" *)
input wire m_axis_rc_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_cq TDATA" *)
output wire [63 : 0] m_axis_cq_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_cq TUSER" *)
output wire [84 : 0] m_axis_cq_tuser;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_cq TLAST" *)
output wire m_axis_cq_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_cq TKEEP" *)
output wire [1 : 0] m_axis_cq_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_cq TVALID" *)
output wire m_axis_cq_tvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_cq, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 85, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_cq TREADY" *)
input wire m_axis_cq_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_cc TDATA" *)
input wire [63 : 0] s_axis_cc_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_cc TUSER" *)
input wire [32 : 0] s_axis_cc_tuser;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_cc TLAST" *)
input wire s_axis_cc_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_cc TKEEP" *)
input wire [1 : 0] s_axis_cc_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_cc TVALID" *)
input wire s_axis_cc_tvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_cc, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 33, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_cc TREADY" *)
output wire [3 : 0] s_axis_cc_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_seq_num" *)
output wire [3 : 0] pcie_rq_seq_num;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_seq_num_vld" *)
output wire pcie_rq_seq_num_vld;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_tag" *)
output wire [5 : 0] pcie_rq_tag;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rq_tag_vld" *)
output wire pcie_rq_tag_vld;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_transmit_fc:1.0 pcie3_transmit_fc nph_av" *)
output wire [1 : 0] pcie_tfc_nph_av;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_transmit_fc:1.0 pcie3_transmit_fc npd_av" *)
output wire [1 : 0] pcie_tfc_npd_av;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status cq_np_req" *)
input wire pcie_cq_np_req;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status cq_np_req_count" *)
output wire [5 : 0] pcie_cq_np_req_count;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status phy_link_down" *)
output wire cfg_phy_link_down;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status phy_link_status" *)
output wire [1 : 0] cfg_phy_link_status;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status negotiated_width" *)
output wire [3 : 0] cfg_negotiated_width;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status current_speed" *)
output wire [2 : 0] cfg_current_speed;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status max_payload" *)
output wire [2 : 0] cfg_max_payload;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status max_read_req" *)
output wire [2 : 0] cfg_max_read_req;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status function_status" *)
output wire [7 : 0] cfg_function_status;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status function_power_state" *)
output wire [5 : 0] cfg_function_power_state;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_status" *)
output wire [11 : 0] cfg_vf_status;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_power_state" *)
output wire [17 : 0] cfg_vf_power_state;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status link_power_state" *)
output wire [1 : 0] cfg_link_power_state;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status err_cor_out" *)
output wire cfg_err_cor_out;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status err_nonfatal_out" *)
output wire cfg_err_nonfatal_out;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status err_fatal_out" *)
output wire cfg_err_fatal_out;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status ltr_enable" *)
output wire cfg_ltr_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status ltssm_state" *)
output wire [5 : 0] cfg_ltssm_state;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status rcb_status" *)
output wire [1 : 0] cfg_rcb_status;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status dpa_substate_change" *)
output wire [1 : 0] cfg_dpa_substate_change;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status obff_enable" *)
output wire [1 : 0] cfg_obff_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status pl_status_change" *)
output wire cfg_pl_status_change;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status tph_requester_enable" *)
output wire [1 : 0] cfg_tph_requester_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status tph_st_mode" *)
output wire [5 : 0] cfg_tph_st_mode;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_tph_requester_enable" *)
output wire [5 : 0] cfg_vf_tph_requester_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_status:1.0 pcie3_cfg_status vf_tph_st_mode" *)
output wire [17 : 0] cfg_vf_tph_st_mode;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msg_received:1.0 pcie3_cfg_mesg_rcvd recd" *)
output wire cfg_msg_received;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msg_received:1.0 pcie3_cfg_mesg_rcvd recd_data" *)
output wire [7 : 0] cfg_msg_received_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msg_received:1.0 pcie3_cfg_mesg_rcvd recd_type" *)
output wire [4 : 0] cfg_msg_received_type;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT" *)
input wire cfg_msg_transmit;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT_TYPE" *)
input wire [2 : 0] cfg_msg_transmit_type;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT_DATA" *)
input wire [31 : 0] cfg_msg_transmit_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_mesg_tx:1.0 pcie3_cfg_mesg_tx TRANSMIT_DONE" *)
output wire cfg_msg_transmit_done;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc PH" *)
output wire [7 : 0] cfg_fc_ph;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc PD" *)
output wire [11 : 0] cfg_fc_pd;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc NPH" *)
output wire [7 : 0] cfg_fc_nph;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc NPD" *)
output wire [11 : 0] cfg_fc_npd;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc CPLH" *)
output wire [7 : 0] cfg_fc_cplh;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc CPLD" *)
output wire [11 : 0] cfg_fc_cpld;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie_cfg_fc:1.0 pcie_cfg_fc SEL" *)
input wire [2 : 0] cfg_fc_sel;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_per_func_status:1.0 pcie3_per_func_status STATUS_CONTROL" *)
input wire [2 : 0] cfg_per_func_status_control;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_per_func_status:1.0 pcie3_per_func_status STATUS_DATA" *)
output wire [15 : 0] cfg_per_func_status_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control per_function_number" *)
input wire [2 : 0] cfg_per_function_number;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control per_function_output_request" *)
input wire cfg_per_function_output_request;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control per_function_update_done" *)
output wire cfg_per_function_update_done;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control subsys_vend_id" *)
input wire [15 : 0] cfg_subsys_vend_id;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control dsn" *)
input wire [63 : 0] cfg_dsn;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control power_state_change_ack" *)
input wire cfg_power_state_change_ack;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control power_state_change_interrupt" *)
output wire cfg_power_state_change_interrupt;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control err_cor_in" *)
input wire cfg_err_cor_in;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control err_uncor_in" *)
input wire cfg_err_uncor_in;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control flr_in_process" *)
output wire [1 : 0] cfg_flr_in_process;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control flr_done" *)
input wire [1 : 0] cfg_flr_done;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control vf_flr_in_process" *)
output wire [5 : 0] cfg_vf_flr_in_process;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control vf_flr_done" *)
input wire [5 : 0] cfg_vf_flr_done;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control link_training_enable" *)
input wire cfg_link_training_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_interrupt:1.0 pcie3_cfg_interrupt INTx_VECTOR" *)
input wire [3 : 0] cfg_interrupt_int;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_interrupt:1.0 pcie3_cfg_interrupt PENDING" *)
input wire [1 : 0] cfg_interrupt_pending;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_interrupt:1.0 pcie3_cfg_interrupt SENT" *)
output wire cfg_interrupt_sent;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix enable" *)
output wire [1 : 0] cfg_interrupt_msix_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix mask" *)
output wire [1 : 0] cfg_interrupt_msix_mask;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix vf_enable" *)
output wire [5 : 0] cfg_interrupt_msix_vf_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix vf_mask" *)
output wire [5 : 0] cfg_interrupt_msix_vf_mask;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix data" *)
input wire [31 : 0] cfg_interrupt_msix_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix address" *)
input wire [63 : 0] cfg_interrupt_msix_address;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix int_vector" *)
input wire cfg_interrupt_msix_int;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix sent" *)
output wire cfg_interrupt_msix_sent;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_msix:1.0 pcie3_cfg_msix fail" *)
output wire cfg_interrupt_msix_fail;
input wire [2 : 0] cfg_interrupt_msi_function_number;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control hot_reset_out" *)
output wire cfg_hot_reset_out;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control config_space_enable" *)
input wire cfg_config_space_enable;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control req_pm_transition_l23_ready" *)
input wire cfg_req_pm_transition_l23_ready;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control hot_reset_in" *)
input wire cfg_hot_reset_in;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_port_number" *)
input wire [7 : 0] cfg_ds_port_number;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_bus_number" *)
input wire [7 : 0] cfg_ds_bus_number;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_device_number" *)
input wire [4 : 0] cfg_ds_device_number;
(* X_INTERFACE_INFO = "xilinx.com:interface:pcie3_cfg_control:1.0 pcie3_cfg_control ds_function_number" *)
input wire [2 : 0] cfg_ds_function_number;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.sys_clk, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.sys_clk CLK" *)
input wire sys_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.sys_rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.sys_rst RST" *)
input wire sys_reset;

  xdma_bram_xdma_0_0_pcie3_ip_pcie_3_0_7vx #(
    .PL_LINK_CAP_MAX_LINK_SPEED(2),
    .PL_LINK_CAP_MAX_LINK_WIDTH(1),
    .USER_CLK2_FREQ(2),
    .PF0_LINK_CAP_ASPM_SUPPORT(0),
    .C_DATA_WIDTH(64),
    .REF_CLK_FREQ(0),
    .PCIE_LINK_SPEED(3),
    .KEEP_WIDTH(2),
    .ARI_CAP_ENABLE("FALSE"),
    .PF0_ARI_CAP_NEXT_FUNC('H00),
    .AXISTEN_IF_CC_ALIGNMENT_MODE("TRUE"),
    .AXISTEN_IF_CQ_ALIGNMENT_MODE("TRUE"),
    .AXISTEN_IF_RC_ALIGNMENT_MODE("FALSE"),
    .AXISTEN_IF_RC_STRADDLE("FALSE"),
    .AXISTEN_IF_RQ_ALIGNMENT_MODE("FALSE"),
    .PF0_AER_CAP_ECRC_CHECK_CAPABLE("FALSE"),
    .PF0_AER_CAP_ECRC_GEN_CAPABLE("FALSE"),
    .PF0_AER_CAP_NEXTPTR('H000),
    .PF0_ARI_CAP_NEXTPTR('H000),
    .VF0_ARI_CAP_NEXTPTR('H000),
    .VF1_ARI_CAP_NEXTPTR('H000),
    .VF2_ARI_CAP_NEXTPTR('H000),
    .VF3_ARI_CAP_NEXTPTR('H000),
    .VF4_ARI_CAP_NEXTPTR('H000),
    .VF5_ARI_CAP_NEXTPTR('H000),
    .PF0_BAR0_APERTURE_SIZE('B01001),
    .PF0_BAR0_CONTROL('B100),
    .PF0_BAR1_APERTURE_SIZE('B01101),
    .PF0_BAR1_CONTROL('B100),
    .PF0_BAR2_APERTURE_SIZE('B00000),
    .PF0_BAR2_CONTROL('B000),
    .PF0_BAR3_APERTURE_SIZE('B00000),
    .PF0_BAR3_CONTROL('B000),
    .PF0_BAR4_APERTURE_SIZE('B00000),
    .PF0_BAR4_CONTROL('B000),
    .PF0_BAR5_APERTURE_SIZE('B00000),
    .PF0_BAR5_CONTROL('B000),
    .PF0_CAPABILITY_POINTER('H80),
    .PF0_CLASS_CODE('H058000),
    .PF0_VENDOR_ID('H10EE),
    .PF0_DEVICE_ID('H7021),
    .PF0_DEV_CAP2_128B_CAS_ATOMIC_COMPLETER_SUPPORT("FALSE"),
    .PF0_DEV_CAP2_32B_ATOMIC_COMPLETER_SUPPORT("FALSE"),
    .PF0_DEV_CAP2_64B_ATOMIC_COMPLETER_SUPPORT("FALSE"),
    .PF0_DEV_CAP2_LTR_SUPPORT("FALSE"),
    .PF0_DEV_CAP2_OBFF_SUPPORT('D00),
    .PF0_DEV_CAP2_TPH_COMPLETER_SUPPORT("FALSE"),
    .PF0_DEV_CAP_EXT_TAG_SUPPORTED("FALSE"),
    .PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE("FALSE"),
    .PF0_DEV_CAP_MAX_PAYLOAD_SIZE('B010),
    .PF0_DPA_CAP_NEXTPTR('H000),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION0('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION1('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION2('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION3('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION4('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION5('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION6('H00),
    .PF0_DPA_CAP_SUB_STATE_POWER_ALLOCATION7('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION0('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION1('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION2('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION3('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION4('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION5('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION6('H00),
    .PF1_DPA_CAP_SUB_STATE_POWER_ALLOCATION7('H00),
    .PF0_DSN_CAP_NEXTPTR('H000),
    .PF0_EXPANSION_ROM_APERTURE_SIZE('B00000),
    .PF0_EXPANSION_ROM_ENABLE("FALSE"),
    .PF0_INTERRUPT_PIN('H0),
    .PF0_LINK_STATUS_SLOT_CLOCK_CONFIG("TRUE"),
    .PF0_LTR_CAP_NEXTPTR('H000),
    .PF0_MSIX_CAP_NEXTPTR('HC0),
    .PF0_MSIX_CAP_PBA_BIR(0),
    .PF0_MSIX_CAP_PBA_OFFSET('H00008FE0),
    .PF0_MSIX_CAP_TABLE_BIR(0),
    .PF0_MSIX_CAP_TABLE_OFFSET('H00008000),
    .PF0_MSIX_CAP_TABLE_SIZE('H01F),
    .PF0_MSI_CAP_MULTIMSGCAP(0),
    .PF0_MSI_CAP_NEXTPTR('H00),
    .PF0_PB_CAP_NEXTPTR('H000),
    .PF0_PM_CAP_NEXTPTR('HB0),
    .PF0_PM_CAP_PMESUPPORT_D0("FALSE"),
    .PF0_PM_CAP_PMESUPPORT_D1("FALSE"),
    .PF0_PM_CAP_PMESUPPORT_D3HOT("FALSE"),
    .PF0_PM_CAP_SUPP_D1_STATE("FALSE"),
    .PF0_RBAR_CAP_ENABLE("FALSE"),
    .PF0_RBAR_CAP_NEXTPTR('H000),
    .PF0_RBAR_CAP_SIZE0('H00000),
    .PF0_RBAR_CAP_SIZE1('H00000),
    .PF0_RBAR_CAP_SIZE2('H00000),
    .PF1_RBAR_CAP_SIZE0('H00000),
    .PF1_RBAR_CAP_SIZE1('H00000),
    .PF1_RBAR_CAP_SIZE2('H00000),
    .PF0_REVISION_ID('H00),
    .PF0_SRIOV_BAR0_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR0_CONTROL('B000),
    .PF0_SRIOV_BAR1_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR1_CONTROL('B000),
    .PF0_SRIOV_BAR2_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR2_CONTROL('B000),
    .PF0_SRIOV_BAR3_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR3_CONTROL('B000),
    .PF0_SRIOV_BAR4_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR4_CONTROL('B000),
    .PF0_SRIOV_BAR5_APERTURE_SIZE('B00000),
    .PF0_SRIOV_BAR5_CONTROL('B000),
    .PF0_SRIOV_CAP_INITIAL_VF('H0000),
    .PF0_SRIOV_CAP_NEXTPTR('H000),
    .PF0_SRIOV_CAP_TOTAL_VF('H0000),
    .PF0_SRIOV_CAP_VER('H0),
    .PF0_SRIOV_FIRST_VF_OFFSET('H0000),
    .PF0_SRIOV_FUNC_DEP_LINK('H0000),
    .PF0_SRIOV_SUPPORTED_PAGE_SIZE('H00000553),
    .PF0_SRIOV_VF_DEVICE_ID('H0000),
    .PF0_SUBSYSTEM_VENDOR_ID('H10EE),
    .PF0_SUBSYSTEM_ID('H0007),
    .PF0_TPHR_CAP_ENABLE("FALSE"),
    .PF0_TPHR_CAP_NEXTPTR('H000),
    .VF0_TPHR_CAP_NEXTPTR('H000),
    .VF1_TPHR_CAP_NEXTPTR('H000),
    .VF2_TPHR_CAP_NEXTPTR('H000),
    .VF3_TPHR_CAP_NEXTPTR('H000),
    .VF4_TPHR_CAP_NEXTPTR('H000),
    .VF5_TPHR_CAP_NEXTPTR('H000),
    .PF0_TPHR_CAP_ST_MODE_SEL('H2),
    .PF0_TPHR_CAP_ST_TABLE_LOC('H2),
    .PF0_TPHR_CAP_ST_TABLE_SIZE('H000),
    .PF0_TPHR_CAP_VER('H1),
    .PF1_TPHR_CAP_ST_MODE_SEL('H0),
    .PF1_TPHR_CAP_ST_TABLE_LOC('H0),
    .PF1_TPHR_CAP_ST_TABLE_SIZE('H000),
    .PF1_TPHR_CAP_VER('H1),
    .VF0_TPHR_CAP_ST_MODE_SEL('H0),
    .VF0_TPHR_CAP_ST_TABLE_LOC('H0),
    .VF0_TPHR_CAP_ST_TABLE_SIZE('H000),
    .VF0_TPHR_CAP_VER('H1),
    .VF1_TPHR_CAP_ST_MODE_SEL('H0),
    .VF1_TPHR_CAP_ST_TABLE_LOC('H0),
    .VF1_TPHR_CAP_ST_TABLE_SIZE('H000),
    .VF1_TPHR_CAP_VER('H1),
    .VF2_TPHR_CAP_ST_MODE_SEL('H0),
    .VF2_TPHR_CAP_ST_TABLE_LOC('H0),
    .VF2_TPHR_CAP_ST_TABLE_SIZE('H000),
    .VF2_TPHR_CAP_VER('H1),
    .VF3_TPHR_CAP_ST_MODE_SEL('H0),
    .VF3_TPHR_CAP_ST_TABLE_LOC('H0),
    .VF3_TPHR_CAP_ST_TABLE_SIZE('H000),
    .VF3_TPHR_CAP_VER('H1),
    .VF4_TPHR_CAP_ST_MODE_SEL('H0),
    .VF4_TPHR_CAP_ST_TABLE_LOC('H0),
    .VF4_TPHR_CAP_ST_TABLE_SIZE('H000),
    .VF4_TPHR_CAP_VER('H1),
    .VF5_TPHR_CAP_ST_MODE_SEL('H0),
    .VF5_TPHR_CAP_ST_TABLE_LOC('H0),
    .VF5_TPHR_CAP_ST_TABLE_SIZE('H000),
    .VF5_TPHR_CAP_VER('H1),
    .PF0_TPHR_CAP_DEV_SPECIFIC_MODE("FALSE"),
    .PF0_TPHR_CAP_INT_VEC_MODE("TRUE"),
    .PF1_TPHR_CAP_DEV_SPECIFIC_MODE("TRUE"),
    .PF1_TPHR_CAP_INT_VEC_MODE("FALSE"),
    .VF0_TPHR_CAP_DEV_SPECIFIC_MODE("TRUE"),
    .VF0_TPHR_CAP_INT_VEC_MODE("FALSE"),
    .VF1_TPHR_CAP_DEV_SPECIFIC_MODE("TRUE"),
    .VF1_TPHR_CAP_INT_VEC_MODE("FALSE"),
    .VF2_TPHR_CAP_DEV_SPECIFIC_MODE("TRUE"),
    .VF2_TPHR_CAP_INT_VEC_MODE("FALSE"),
    .VF3_TPHR_CAP_DEV_SPECIFIC_MODE("TRUE"),
    .VF3_TPHR_CAP_INT_VEC_MODE("FALSE"),
    .VF4_TPHR_CAP_DEV_SPECIFIC_MODE("TRUE"),
    .VF4_TPHR_CAP_INT_VEC_MODE("FALSE"),
    .VF5_TPHR_CAP_DEV_SPECIFIC_MODE("TRUE"),
    .VF5_TPHR_CAP_INT_VEC_MODE("FALSE"),
    .PF0_VC_CAP_NEXTPTR('H000),
    .SPARE_WORD1('H00000000),
    .PF1_AER_CAP_ECRC_CHECK_CAPABLE("FALSE"),
    .PF1_AER_CAP_ECRC_GEN_CAPABLE("FALSE"),
    .PF1_AER_CAP_NEXTPTR('H000),
    .PF1_ARI_CAP_NEXTPTR('H000),
    .PF1_BAR0_APERTURE_SIZE('B00000),
    .PF1_BAR0_CONTROL('B000),
    .PF1_BAR1_APERTURE_SIZE('B00000),
    .PF1_BAR1_CONTROL('B000),
    .PF1_BAR2_APERTURE_SIZE('B00000),
    .PF1_BAR2_CONTROL('B000),
    .PF1_BAR3_APERTURE_SIZE('B00000),
    .PF1_BAR3_CONTROL('B000),
    .PF1_BAR4_APERTURE_SIZE('B00000),
    .PF1_BAR4_CONTROL('B000),
    .PF1_BAR5_APERTURE_SIZE('B00000),
    .PF1_BAR5_CONTROL('B000),
    .PF1_CAPABILITY_POINTER('H80),
    .PF1_CLASS_CODE('H058000),
    .PF1_DEVICE_ID('H7011),
    .PF1_DEV_CAP_MAX_PAYLOAD_SIZE('B010),
    .PF1_DPA_CAP_NEXTPTR('H000),
    .PF1_DSN_CAP_NEXTPTR('H000),
    .PF1_EXPANSION_ROM_APERTURE_SIZE('B00000),
    .PF1_EXPANSION_ROM_ENABLE("FALSE"),
    .PF1_INTERRUPT_PIN('H0),
    .PF1_MSIX_CAP_NEXTPTR('H00),
    .PF1_MSIX_CAP_PBA_BIR(0),
    .PF1_MSIX_CAP_PBA_OFFSET('H00000000),
    .PF1_MSIX_CAP_TABLE_BIR(0),
    .PF1_MSIX_CAP_TABLE_OFFSET('H00000000),
    .PF1_MSIX_CAP_TABLE_SIZE('H000),
    .PF1_MSI_CAP_MULTIMSGCAP(0),
    .PF1_MSI_CAP_NEXTPTR('H00),
    .PF1_PB_CAP_NEXTPTR('H000),
    .PF1_PM_CAP_NEXTPTR('H00),
    .PF1_RBAR_CAP_ENABLE("FALSE"),
    .PF1_RBAR_CAP_NEXTPTR('H000),
    .PF1_REVISION_ID('H00),
    .PF1_SRIOV_BAR0_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR0_CONTROL('B000),
    .PF1_SRIOV_BAR1_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR1_CONTROL('B000),
    .PF1_SRIOV_BAR2_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR2_CONTROL('B000),
    .PF1_SRIOV_BAR3_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR3_CONTROL('B000),
    .PF1_SRIOV_BAR4_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR4_CONTROL('B000),
    .PF1_SRIOV_BAR5_APERTURE_SIZE('B00000),
    .PF1_SRIOV_BAR5_CONTROL('B000),
    .PF1_SRIOV_CAP_INITIAL_VF('H0000),
    .PF1_SRIOV_CAP_NEXTPTR('H000),
    .PF1_SRIOV_CAP_TOTAL_VF('H0000),
    .PF1_SRIOV_CAP_VER('H0),
    .PF1_SRIOV_FIRST_VF_OFFSET('H0000),
    .PF1_SRIOV_FUNC_DEP_LINK('H0001),
    .PF1_SRIOV_SUPPORTED_PAGE_SIZE('H00000553),
    .PF1_SRIOV_VF_DEVICE_ID('H0000),
    .PF1_SUBSYSTEM_ID('H0007),
    .PF1_TPHR_CAP_ENABLE("FALSE"),
    .PF1_TPHR_CAP_NEXTPTR('H000),
    .PL_UPSTREAM_FACING("TRUE"),
    .SRIOV_CAP_ENABLE("FALSE"),
    .TL_CREDITS_CD('H000),
    .TL_CREDITS_CH('H00000000),
    .TL_CREDITS_NPD('H028),
    .TL_CREDITS_NPH('H20),
    .TL_CREDITS_PD('H198),
    .TL_CREDITS_PH('H20),
    .TL_EXTENDED_CFG_EXTEND_INTERFACE_ENABLE("FALSE"),
    .TL_LEGACY_MODE_ENABLE("FALSE"),
    .TL_PF_ENABLE_REG("FALSE"),
    .VF0_CAPABILITY_POINTER('H80),
    .VF0_MSIX_CAP_PBA_BIR(0),
    .VF0_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF0_MSIX_CAP_TABLE_BIR(0),
    .VF0_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF0_MSIX_CAP_TABLE_SIZE('H000),
    .VF0_MSI_CAP_MULTIMSGCAP(0),
    .VF0_PM_CAP_NEXTPTR('B00000000),
    .VF1_MSIX_CAP_PBA_BIR(0),
    .VF1_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF1_MSIX_CAP_TABLE_BIR(0),
    .VF1_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF1_MSIX_CAP_TABLE_SIZE('H000),
    .VF1_MSI_CAP_MULTIMSGCAP(0),
    .VF1_PM_CAP_NEXTPTR('B00000000),
    .VF2_MSIX_CAP_PBA_BIR(0),
    .VF2_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF2_MSIX_CAP_TABLE_BIR(0),
    .VF2_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF2_MSIX_CAP_TABLE_SIZE('H000),
    .VF2_MSI_CAP_MULTIMSGCAP(0),
    .VF2_PM_CAP_NEXTPTR('B00000000),
    .VF3_MSIX_CAP_PBA_BIR(0),
    .VF3_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF3_MSIX_CAP_TABLE_BIR(0),
    .VF3_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF3_MSIX_CAP_TABLE_SIZE('H000),
    .VF3_MSI_CAP_MULTIMSGCAP(0),
    .VF3_PM_CAP_NEXTPTR('B00000000),
    .VF4_MSIX_CAP_PBA_BIR(0),
    .VF4_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF4_MSIX_CAP_TABLE_BIR(0),
    .VF4_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF4_MSIX_CAP_TABLE_SIZE('H000),
    .VF4_MSI_CAP_MULTIMSGCAP(0),
    .VF4_PM_CAP_NEXTPTR('B00000000),
    .VF5_MSIX_CAP_PBA_BIR(0),
    .VF5_MSIX_CAP_PBA_OFFSET('H00000000),
    .VF5_MSIX_CAP_TABLE_BIR(0),
    .VF5_MSIX_CAP_TABLE_OFFSET('H00000000),
    .VF5_MSIX_CAP_TABLE_SIZE('H000),
    .VF5_MSI_CAP_MULTIMSGCAP(0),
    .VF5_PM_CAP_NEXTPTR('B00000000),
    .COMPLETION_SPACE("16KB"),
    .gen_x0y0_ucf("0"),
    .gen_x0y3_ucf("0"),
    .gen_x0y2_ucf("0"),
    .gen_x0y1_ucf("1"),
    .silicon_revision("Production"),
    .xlnx_ref_board(0),
    .pcie_blk_locn(1),
    .SHARED_LOGIC_IN_CORE("FALSE"),
    .PIPE_SIM("FALSE"),
    .MSI_EN("FALSE"),
    .MSIX_EN("TRUE"),
    .PCIE_EXT_CLK("FALSE"),
    .PCIE_EXT_GT_COMMON("FALSE"),
    .EXT_CH_GT_DRP("FALSE"),
    .CFG_STATUS_IF("TRUE"),
    .TX_FC_IF("TRUE"),
    .CFG_EXT_IF("FALSE"),
    .CFG_FC_IF("TRUE"),
    .PER_FUNC_STATUS_IF("TRUE"),
    .CFG_MGMT_IF("FALSE"),
    .RCV_MSG_IF("TRUE"),
    .CFG_TX_MSG_IF("TRUE"),
    .CFG_CTL_IF("TRUE"),
    .PCIE_DRP("FALSE"),
    .TRANSCEIVER_CTRL_STATUS_PORTS("FALSE"),
    .AXISTEN_IF_ENABLE_CLIENT_TAG("TRUE"),
    .PCIE_USE_MODE("2.1"),
    .PCIE_FAST_CONFIG("NONE"),
    .EXT_STARTUP_PRIMITIVE("FALSE"),
    .EXT_PIPE_INTERFACE("FALSE"),
    .AXISTEN_IF_ENABLE_MSG_ROUTE('H20000),
    .AXISTEN_IF_ENABLE_RX_MSG_INTFC("FALSE"),
    .POWER_DOWN("FALSE"),
    .DEV_PORT_TYPE('D00),
    .ENABLE_JTAG_DBG("FALSE"),
    .MULT_PF_DES("TRUE"),
    .WIN10_INTEROP("FALSE")
  ) inst (
    .pci_exp_txn(pci_exp_txn),
    .pci_exp_txp(pci_exp_txp),
    .pci_exp_rxn(pci_exp_rxn),
    .pci_exp_rxp(pci_exp_rxp),
    .int_pclk_out_slave(),
    .int_pipe_rxusrclk_out(),
    .int_rxoutclk_out(),
    .int_dclk_out(),
    .int_userclk1_out(),
    .int_userclk2_out(),
    .int_oobclk_out(),
    .int_qplllock_out(),
    .int_qplloutclk_out(),
    .int_qplloutrefclk_out(),
    .int_pclk_sel_slave(1'B0),
    .pipe_pclk_in(1'B0),
    .pipe_rxusrclk_in(1'B0),
    .pipe_rxoutclk_in(1'B0),
    .pipe_dclk_in(1'B0),
    .pipe_userclk1_in(1'B0),
    .pipe_userclk2_in(1'B0),
    .pipe_oobclk_in(1'B0),
    .pipe_mmcm_lock_in(1'B1),
    .pipe_txoutclk_out(),
    .pipe_rxoutclk_out(),
    .pipe_pclk_sel_out(),
    .pipe_gen3_out(),
    .pipe_mmcm_rst_n(1'B1),
    .mmcm_lock(mmcm_lock),
    .user_clk(user_clk),
    .user_reset(user_reset),
    .user_lnk_up(user_lnk_up),
    .user_app_rdy(user_app_rdy),
    .s_axis_rq_tlast(s_axis_rq_tlast),
    .s_axis_rq_tdata(s_axis_rq_tdata),
    .s_axis_rq_tuser(s_axis_rq_tuser),
    .s_axis_rq_tkeep(s_axis_rq_tkeep),
    .s_axis_rq_tready(s_axis_rq_tready),
    .s_axis_rq_tvalid(s_axis_rq_tvalid),
    .m_axis_rc_tdata(m_axis_rc_tdata),
    .m_axis_rc_tuser(m_axis_rc_tuser),
    .m_axis_rc_tlast(m_axis_rc_tlast),
    .m_axis_rc_tkeep(m_axis_rc_tkeep),
    .m_axis_rc_tvalid(m_axis_rc_tvalid),
    .m_axis_rc_tready(m_axis_rc_tready),
    .m_axis_cq_tdata(m_axis_cq_tdata),
    .m_axis_cq_tuser(m_axis_cq_tuser),
    .m_axis_cq_tlast(m_axis_cq_tlast),
    .m_axis_cq_tkeep(m_axis_cq_tkeep),
    .m_axis_cq_tvalid(m_axis_cq_tvalid),
    .m_axis_cq_tready(m_axis_cq_tready),
    .s_axis_cc_tdata(s_axis_cc_tdata),
    .s_axis_cc_tuser(s_axis_cc_tuser),
    .s_axis_cc_tlast(s_axis_cc_tlast),
    .s_axis_cc_tkeep(s_axis_cc_tkeep),
    .s_axis_cc_tvalid(s_axis_cc_tvalid),
    .s_axis_cc_tready(s_axis_cc_tready),
    .pcie_rq_seq_num(pcie_rq_seq_num),
    .pcie_rq_seq_num_vld(pcie_rq_seq_num_vld),
    .pcie_rq_tag(pcie_rq_tag),
    .pcie_rq_tag_vld(pcie_rq_tag_vld),
    .pcie_tfc_nph_av(pcie_tfc_nph_av),
    .pcie_tfc_npd_av(pcie_tfc_npd_av),
    .pcie_cq_np_req(pcie_cq_np_req),
    .pcie_cq_np_req_count(pcie_cq_np_req_count),
    .cfg_phy_link_down(cfg_phy_link_down),
    .cfg_phy_link_status(cfg_phy_link_status),
    .cfg_negotiated_width(cfg_negotiated_width),
    .cfg_current_speed(cfg_current_speed),
    .cfg_max_payload(cfg_max_payload),
    .cfg_max_read_req(cfg_max_read_req),
    .cfg_function_status(cfg_function_status),
    .cfg_function_power_state(cfg_function_power_state),
    .cfg_vf_status(cfg_vf_status),
    .cfg_vf_power_state(cfg_vf_power_state),
    .cfg_link_power_state(cfg_link_power_state),
    .cfg_mgmt_addr(19'B0),
    .cfg_mgmt_write(1'B0),
    .cfg_mgmt_write_data(32'B0),
    .cfg_mgmt_byte_enable(4'B0),
    .cfg_mgmt_read(1'B0),
    .cfg_mgmt_read_data(),
    .cfg_mgmt_read_write_done(),
    .cfg_mgmt_type1_cfg_reg_access(1'B0),
    .cfg_err_cor_out(cfg_err_cor_out),
    .cfg_err_nonfatal_out(cfg_err_nonfatal_out),
    .cfg_err_fatal_out(cfg_err_fatal_out),
    .cfg_ltr_enable(cfg_ltr_enable),
    .cfg_ltssm_state(cfg_ltssm_state),
    .cfg_rcb_status(cfg_rcb_status),
    .cfg_dpa_substate_change(cfg_dpa_substate_change),
    .cfg_obff_enable(cfg_obff_enable),
    .cfg_pl_status_change(cfg_pl_status_change),
    .cfg_tph_requester_enable(cfg_tph_requester_enable),
    .cfg_tph_st_mode(cfg_tph_st_mode),
    .cfg_vf_tph_requester_enable(cfg_vf_tph_requester_enable),
    .cfg_vf_tph_st_mode(cfg_vf_tph_st_mode),
    .cfg_msg_received(cfg_msg_received),
    .cfg_msg_received_data(cfg_msg_received_data),
    .cfg_msg_received_type(cfg_msg_received_type),
    .cfg_msg_transmit(cfg_msg_transmit),
    .cfg_msg_transmit_type(cfg_msg_transmit_type),
    .cfg_msg_transmit_data(cfg_msg_transmit_data),
    .cfg_msg_transmit_done(cfg_msg_transmit_done),
    .cfg_fc_ph(cfg_fc_ph),
    .cfg_fc_pd(cfg_fc_pd),
    .cfg_fc_nph(cfg_fc_nph),
    .cfg_fc_npd(cfg_fc_npd),
    .cfg_fc_cplh(cfg_fc_cplh),
    .cfg_fc_cpld(cfg_fc_cpld),
    .cfg_fc_sel(cfg_fc_sel),
    .cfg_per_func_status_control(cfg_per_func_status_control),
    .cfg_per_func_status_data(cfg_per_func_status_data),
    .cfg_per_function_number(cfg_per_function_number),
    .cfg_per_function_output_request(cfg_per_function_output_request),
    .cfg_per_function_update_done(cfg_per_function_update_done),
    .cfg_subsys_vend_id(cfg_subsys_vend_id),
    .cfg_dsn(cfg_dsn),
    .cfg_power_state_change_ack(cfg_power_state_change_ack),
    .cfg_power_state_change_interrupt(cfg_power_state_change_interrupt),
    .cfg_err_cor_in(cfg_err_cor_in),
    .cfg_err_uncor_in(cfg_err_uncor_in),
    .cfg_flr_in_process(cfg_flr_in_process),
    .cfg_flr_done(cfg_flr_done),
    .cfg_vf_flr_in_process(cfg_vf_flr_in_process),
    .cfg_vf_flr_done(cfg_vf_flr_done),
    .cfg_link_training_enable(cfg_link_training_enable),
    .cfg_ext_read_received(),
    .cfg_ext_write_received(),
    .cfg_ext_register_number(),
    .cfg_ext_function_number(),
    .cfg_ext_write_data(),
    .cfg_ext_write_byte_enable(),
    .cfg_ext_read_data(32'B0),
    .cfg_ext_read_data_valid(1'B0),
    .cfg_interrupt_int(cfg_interrupt_int),
    .cfg_interrupt_pending(cfg_interrupt_pending),
    .cfg_interrupt_sent(cfg_interrupt_sent),
    .cfg_interrupt_msi_enable(),
    .cfg_interrupt_msi_vf_enable(),
    .cfg_interrupt_msi_mmenable(),
    .cfg_interrupt_msi_mask_update(),
    .cfg_interrupt_msi_data(),
    .cfg_interrupt_msi_select(4'B0),
    .cfg_interrupt_msi_int(32'B0),
    .cfg_interrupt_msi_pending_status(64'B0),
    .cfg_interrupt_msi_sent(),
    .cfg_interrupt_msi_fail(),
    .cfg_interrupt_msix_enable(cfg_interrupt_msix_enable),
    .cfg_interrupt_msix_mask(cfg_interrupt_msix_mask),
    .cfg_interrupt_msix_vf_enable(cfg_interrupt_msix_vf_enable),
    .cfg_interrupt_msix_vf_mask(cfg_interrupt_msix_vf_mask),
    .cfg_interrupt_msix_data(cfg_interrupt_msix_data),
    .cfg_interrupt_msix_address(cfg_interrupt_msix_address),
    .cfg_interrupt_msix_int(cfg_interrupt_msix_int),
    .cfg_interrupt_msix_sent(cfg_interrupt_msix_sent),
    .cfg_interrupt_msix_fail(cfg_interrupt_msix_fail),
    .cfg_interrupt_msi_attr(3'B0),
    .cfg_interrupt_msi_tph_present(1'B0),
    .cfg_interrupt_msi_tph_type(2'B0),
    .cfg_interrupt_msi_tph_st_tag(9'B0),
    .cfg_interrupt_msi_function_number(cfg_interrupt_msi_function_number),
    .cfg_hot_reset_out(cfg_hot_reset_out),
    .cfg_config_space_enable(cfg_config_space_enable),
    .cfg_req_pm_transition_l23_ready(cfg_req_pm_transition_l23_ready),
    .cfg_hot_reset_in(cfg_hot_reset_in),
    .cfg_ds_port_number(cfg_ds_port_number),
    .cfg_ds_bus_number(cfg_ds_bus_number),
    .cfg_ds_device_number(cfg_ds_device_number),
    .cfg_ds_function_number(cfg_ds_function_number),
    .user_tph_stt_address(5'B0),
    .user_tph_function_num(3'B0),
    .user_tph_stt_read_data(),
    .user_tph_stt_read_data_valid(),
    .user_tph_stt_read_enable(1'B0),
    .sys_clk(sys_clk),
    .sys_reset(sys_reset),
    .qpll_drp_crscode(12'B0),
    .qpll_drp_fsm(18'B0),
    .qpll_drp_done(2'B0),
    .qpll_drp_reset(2'B0),
    .qpll_qplllock(2'B0),
    .qpll_qplloutclk(2'B0),
    .qpll_qplloutrefclk(2'B0),
    .qpll_qplld(),
    .qpll_qpllreset(),
    .qpll_drp_clk(),
    .qpll_drp_rst_n(),
    .qpll_drp_ovrd(),
    .qpll_drp_gen3(),
    .qpll_drp_start(),
    .pipe_txprbssel(3'B0),
    .pipe_rxprbssel(3'B0),
    .pipe_txprbsforceerr(1'B0),
    .pipe_rxprbscntreset(1'B0),
    .pipe_loopback(3'B0),
    .pipe_rxprbserr(),
    .pipe_txinhibit(1'B0),
    .pipe_rst_fsm(),
    .pipe_qrst_fsm(),
    .pipe_rate_fsm(),
    .pipe_sync_fsm_tx(),
    .pipe_sync_fsm_rx(),
    .pipe_drp_fsm(),
    .pipe_rst_idle(),
    .pipe_qrst_idle(),
    .pipe_rate_idle(),
    .pipe_eyescandataerror(),
    .pipe_rxstatus(),
    .pipe_dmonitorout(),
    .pipe_cpll_lock(),
    .pipe_qpll_lock(),
    .pipe_rxpmaresetdone(),
    .pipe_rxbufstatus(),
    .pipe_txphaligndone(),
    .pipe_txphinitdone(),
    .pipe_txdlysresetdone(),
    .pipe_rxphaligndone(),
    .pipe_rxdlysresetdone(),
    .pipe_rxsyncdone(),
    .pipe_rxdisperr(),
    .pipe_rxnotintable(),
    .pipe_rxcommadet(),
    .gt_ch_drp_rdy(),
    .pipe_debug_0(),
    .pipe_debug_1(),
    .pipe_debug_2(),
    .pipe_debug_3(),
    .pipe_debug_4(),
    .pipe_debug_5(),
    .pipe_debug_6(),
    .pipe_debug_7(),
    .pipe_debug_8(),
    .pipe_debug_9(),
    .pipe_debug(),
    .ext_ch_gt_drpclk(),
    .ext_ch_gt_drpaddr(9'B0),
    .ext_ch_gt_drpen(1'B0),
    .ext_ch_gt_drpdi(16'B0),
    .ext_ch_gt_drpwe(1'B0),
    .ext_ch_gt_drpdo(),
    .ext_ch_gt_drprdy(),
    .icap_clk(1'B0),
    .icap_csib(1'B1),
    .icap_rdwrb(1'B1),
    .icap_i(32'D4294967295),
    .icap_o(),
    .startup_eos_in(1'B0),
    .startup_cfgclk(),
    .startup_cfgmclk(),
    .startup_eos(),
    .startup_preq(),
    .startup_clk(1'B0),
    .startup_gsr(1'B0),
    .startup_gts(1'B0),
    .startup_keyclearb(1'B1),
    .startup_pack(1'B0),
    .startup_usrcclko(1'B0),
    .startup_usrcclkts(1'B1),
    .startup_usrdoneo(1'B0),
    .startup_usrdonets(1'B1),
    .pcie_drp_clk(1'B1),
    .pcie_drp_en(1'B0),
    .pcie_drp_we(1'B0),
    .pcie_drp_addr(11'B0),
    .pcie_drp_di(16'B0),
    .pcie_drp_do(),
    .pcie_drp_rdy(),
    .common_commands_in(26'B0),
    .pipe_rx_0_sigs(84'B0),
    .pipe_rx_1_sigs(84'B0),
    .pipe_rx_2_sigs(84'B0),
    .pipe_rx_3_sigs(84'B0),
    .pipe_rx_4_sigs(84'B0),
    .pipe_rx_5_sigs(84'B0),
    .pipe_rx_6_sigs(84'B0),
    .pipe_rx_7_sigs(84'B0),
    .common_commands_out(),
    .pipe_tx_0_sigs(),
    .pipe_tx_1_sigs(),
    .pipe_tx_2_sigs(),
    .pipe_tx_3_sigs(),
    .pipe_tx_4_sigs(),
    .pipe_tx_5_sigs(),
    .pipe_tx_6_sigs(),
    .pipe_tx_7_sigs(),
    .cpllpd(1'B0),
    .txpd(2'B0),
    .rxpd(2'B0),
    .txpdelecidlemode(1'B0),
    .txdetectrx(1'B0),
    .txelecidle(1'B0),
    .qpllpd(1'B0),
    .powerdown(1'B0)
  );
endmodule
