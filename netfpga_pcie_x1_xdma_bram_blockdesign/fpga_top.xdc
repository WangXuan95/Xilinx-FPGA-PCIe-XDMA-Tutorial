
set_property -dict { PACKAGE_PIN AR22  IOSTANDARD LVCMOS15 } [get_ports { o_led0 }];
#set_property -dict { PACKAGE_PIN AR23  IOSTANDARD LVCMOS15 } [get_ports { o_led1 }];


set_property -dict { PACKAGE_PIN AY35  IOSTANDARD LVCMOS18  PULLUP true } [get_ports i_pcie_rstn]


set_property PACKAGE_PIN AB8  [get_ports { i_pcie_refclkp }];
create_clock -name sys_clk -period 10 [get_ports i_pcie_refclkp]


set_property PACKAGE_PIN W2   [get_ports { o_pcie_txp[0] }];
#set_property PACKAGE_PIN AA2  [get_ports { o_pcie_txp[1] }];
#set_property PACKAGE_PIN AC2  [get_ports { o_pcie_txp[2] }];
#set_property PACKAGE_PIN AE2  [get_ports { o_pcie_txp[3] }];
#set_property PACKAGE_PIN AG2  [get_ports { o_pcie_txp[4] }];
#set_property PACKAGE_PIN AH4  [get_ports { o_pcie_txp[5] }];
#set_property PACKAGE_PIN AJ2  [get_ports { o_pcie_txp[6] }];
#set_property PACKAGE_PIN AK4  [get_ports { o_pcie_txp[7] }];

set_property PACKAGE_PIN Y4   [get_ports { i_pcie_rxp[0] }];
#set_property PACKAGE_PIN AA6  [get_ports { i_pcie_rxp[1] }];
#set_property PACKAGE_PIN AB4  [get_ports { i_pcie_rxp[2] }];
#set_property PACKAGE_PIN AC6  [get_ports { i_pcie_rxp[3] }];
#set_property PACKAGE_PIN AD4  [get_ports { i_pcie_rxp[4] }];
#set_property PACKAGE_PIN AE6  [get_ports { i_pcie_rxp[5] }];
#set_property PACKAGE_PIN AF4  [get_ports { i_pcie_rxp[6] }];
#set_property PACKAGE_PIN AG6  [get_ports { i_pcie_rxp[7] }];
