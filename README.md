![部署](https://img.shields.io/badge/部署-vivado-FF1010.svg) 

# Xilinx FPGA PCIe-XDMA Tutorial

Xilinx FPGA 的 PCIe 保姆级教程 ——基于 **PCIe-XDMA IP核**

　

## 引言

**PCIe-XDMA** (**DMA Subsystem for PCIe**) 是 Xilinx 提供给 FPGA 开发者的一种免费的、便于使用的 PCIe 通信 IP 核。**图1**是 **PCIe-XDMA** 应用的典型的系统框图， **PCIe-XDMA IP核** 的一端是 PCIe 接口，通过 FPGA 芯片的引脚连接到 Host-PC 的主板的 PCIe 插槽上；另一端是一个 AXI4-Master Port ，可以连接到 AXI slave 上，这个 AXI slave 可以是：

- 一个 AXI Block RAM (AXI BRAM) 或 AXI DDR controller 上，则整个 FPGA 可以看作一个 PCIe 内存设备，Host-PC 可以读写该内存；
- 一个硬件加速器，则 Host-PC 可以通过 PCIe 调用该加速器；
- AXI 桥 (例如 AXI interconnection) ，下游挂多个 AXI slave ，可以同时实现更多功能。

```
|------------|            |---------------------------------------------------------------|
|            |            |                                                               |
|            |            |    |---------------|                  |-------------------|   |
|            |            |    |               |                  |                   |   |
|   run      |    PCIe    |    |   PCIe-XDMA   |       AXI4       |   User Logic      |   |
|  C/C++     |<---------->|<-->|    IP core    |<---------------->|   e.g.            |   |
|  software  |            |    |               |Master       Slave|   HW Accelerator  |   |
|            |            |    |  (AXI-master) | Port        Port |   (AXI-slave)     |   |
|            |            |    |---------------|                  |-------------------|   |
|            |            |                                                               |
|------------|            |---------------------------------------------------------------|
  Host-PC                                                  FPGA
                       图1 : PCIe-XDMA 应用的典型系统框图
```

#### FPGA开发板选择

本库提供了3个例程，都在 Digilent [NetFPGA-sume](https://digilent.com/reference/programmable-logic/netfpga-sume/start) (FPGA 型号为 Xilinx Virtex-7 XC7VX690TFFG1761-3) 上运行。如果你手头有其它的 Xilinx 的 7系列以上的 FPGA PCIe 开发板，也可以跟随该教程，因为它不限于具体的 FPGA 型号。

#### 你能学到什么？

跟随本教程，你可以学会：

- 在任意的 Xilinx FPGA PCIe 开发板中使用 PCIe-XDMA IP
  - 包括如何阅读 PCB 的原理图来进行正确的 PCIe 引脚分配 。
- 如何在 Linux 中编写 C 语言程序来调用 PCIe-XDMA ，实现 Host-PC 和 FPGA 的数据交互。
- 初步了解 AXI 总线的时序；以及如何用 Verilog 编写简单的 AXI slave 。

　

## PCIe 简介

PCIe (PCI Express) 是一种差分信号对的高速外设总线。目前具有五代 (Gen1 \~ Gen5) 、4种总线宽度 (x1, x4, x8, x16) 。详见 [doc/PCIe_intro.md](./doc/PCIe_intro.md)

　

## FPGA PCIe 引脚分配方法

详见 [doc/FPGA_PCIe_pin_assignment.md](./doc/FPGA_PCIe_pin_assignment.md) （**必读！**），它讲解了**如何阅读原理图并编写 Vivado 工程中的 .xdc 文件，对 PCIe 引脚进行约束**。该方法**对各种 FPGA 开发板是通用的**，不局限于本库使用的 NetFPGA-sume 。

　

　

## 例程一：基于 blockdesign 的 PCIe BRAM 读写

该例程的结构框图如**图2** 。其中包括：

- 一个用 blockdesign 例化的 **PCIe-XDMA** IP核；
- 一个用 blockdesign 例化的 **AXI-BRAM** IP核；
- 用 blockdesign 将以上二者连接起来。整体而言实现了一个 PCIe 内存设备；
- 在 Host-PC 上编写 C 语言程序去读写它。

```
|------------|            |---------------------------------------------------------------|
|            |            |                                                               |
|            |            |    |---------------|                  |-------------------|   |
|            |            |    |               |                  |                   |   |
|   run      |    PCIe    |    |   PCIe-XDMA   |       AXI4       |   AXI-BRAM        |   |
|  C/C++     |<---------->|<-->|    IP core    |<---------------->|   (AXI-slave)     |   |
|  software  |            |    |               |Master       Slave|                   |   |
|            |            |    |  (AXI-master) | Port        Port |                   |   |
|            |            |    |---------------|                  |-------------------|   |
|            |            |                                                               |
|------------|            |---------------------------------------------------------------|
  Host-PC                                                      FPGA
                 图2 : PCIe-XDMA + AXI-BRMA 实现 PCIe 内存设备
```

请按照以下流程学习本例程：

> 　　***if***   ( 你熟悉 Vivado blockdesign 的开发流程 ) {
>
> 　　　　解压、打开并查看 Vivado 工程 [netfpga_pcie_x1_xdma_bram_blockdesign.zip](./netfpga_pcie_x1_xdma_bram_blockdesign.zip) 
>
> 　　} ***else*** {
>
> 　　　　阅读 [doc/intro_pcie_x1_xdma_bram_blockdesign.md](./doc/intro_pcie_x1_xdma_bram_blockdesign.md) 
>
> 　　}
>
> 　　阅读 [doc/FPGA_plug_and_writebitstream.md](./doc/FPGA_plug_and_writebitstream.md) ，插入 PCIe 并烧录 FPGA
>
> 　　阅读 [doc/load_xdma_driver.md](./doc/load_xdma_driver.md) ，在 Linux 主机中编译和加载驱动
>
> 　　阅读 [doc/run_software_xdma_bram.md](./doc/run_software_xdma_bram.md) ，运行C语言程序进行读写测试

　

　

## 例程二：基于 Verilog 的 PCIe BRAM 读写

该例程的结构和**图2**相同，只不过不用 block design ，而是用传统的开发方式。这种方式虽然更麻烦，但灵活性更强、有利于进行细节优化。其中包括：

- 一个用传统 IP 例化方式例化的 **PCIe-XDMA** IP核；
- 一个用 Verilog 编写的 **AXI-BRAM** IP核；
- 编写 Verilog 将以上二者连接起来。整体而言实现了一个 PCIe 内存设备；
- 在 Host-PC 上编写 C 语言程序去读写它。

请按照以下流程学习本例程：

> 　　　　解压、打开并查看 Vivado 工程 [netfpga_pcie_x1_xdma_bram.zip](./netfpga_pcie_x1_xdma_bram.zip) 
>
> 　　　　***if***   ( 你看不懂该工程中的 AXI 相关代码 ) {
>
> 　　　　　　阅读 [doc/intro_pcie_x1_xdma_bram.md](./doc/intro_pcie_x1_xdma_bram.md) ，理解如何用 Verilog 编写简单的 AXI-BRAM 存储器
>
> 　　　　}
>
> 　　　　阅读 [doc/FPGA_plug_and_writebitstream.md](./doc/FPGA_plug_and_writebitstream.md) ，插入 PCIe 并烧录 FPGA
>
> 　　　　阅读 [doc/load_xdma_driver.md](./doc/load_xdma_driver.md) ，在 Linux 主机中编译和加载驱动
>
> 　　　　阅读 [doc/run_software_xdma_bram.md](./doc/run_software_xdma_bram.md) ，运行C语言程序进行读写测试

　

　

## 例程三：基于传统开发方式的 PCIe MPEG2 视频编码

该例程的结构如**图3** 。其中包括：

- 一个用传统 IP 例化方式例化的 **PCIe-XDMA** IP核；
- 一个开源的 [MPEG2视频编码器](https://github.com/WangXuan95/FPGA-MPEG2-encoder) (**mpeg2encoder**) ；
- 编写 Verilog 为该 MPEG2 视频编码器实现一层封装 (**axi\_mpeg2encoder\_wrapper**) ，使之能在 AXI 接口的控制下工作；
- 编写 Verilog 将以上二者连接起来。整体而言实现了一个 PCIe 视频编码卡；
- 在 Host-PC 上编写 C 语言程序去调用它，向FPGA写入视频原始像素，读取出编码视频流，实现视频压缩。

```
|------------|            |------------------------------------------------------------------------------|
|            |            |                                                                              |
|            |            |    |---------------|                  |----------------------------------|   |
|            |            |    |               |                  |                                  |   |
|            |            |    |               |                  |              |---------------|   |   |
|   run      |    PCIe    |    |   PCIe-XDMA   |                  |  control --->|               |   |   |
|  C/C++     |<---------->|<-->|    IP core    |       AXI4       |  status  <---|               |   |   |
|  software  |            |    |               |<---------------->|              |  mepg2encoder |   |   |
|            |            |    |  (AXI-master) |Master       Slave|     data --->|               |   |   |
|            |            |    |               | Port        Port |     data <---|               |   |   |
|            |            |    |               |                  |              |---------------|   |   |
|            |            |    |---------------|                  |                                  |   |
|            |            |                                       |     axi_mpeg2encoder_wrapper     |   |
|            |            |                                       |         (AXI slave)              |   |
|            |            |                                       |----------------------------------|   |
|            |            |                                                                              |
|------------|            |------------------------------------------------------------------------------|
  Host-PC                                                        FPGA
                 图3 : PCIe-XDMA + AXI-BRMA 实现 PCIe 内存设备
```

请按照以下流程学习本例程：

> 　　　　打开并查看 Vivado 工程 [netfpga_pcie_x1_xdma_mpeg2encoder.zip](./netfpga_pcie_x1_xdma_mpeg2encoder.zip) 
>
> 　　　　***if***   ( 你看不懂该工程中的 AXI 相关代码 ) {
>
> 　　　　　　阅读 [doc/intro_pcie_x1_xdma_bram.md](./doc/intro_pcie_x1_xdma_bram.md) ，理解 AXI 总线时序
>
> 　　　　　　阅读 [doc/intro_pcie_x1_xdma_mpeg2encoder.md](./doc/intro_pcie_x1_xdma_mpeg2encoder.md) 
>
> 　　　　}
>
> 　　　　阅读 [doc/FPGA_plug_and_writebitstream.md](./doc/FPGA_plug_and_writebitstream.md) ，插入 PCIe 并烧录 FPGA
>
> 　　　　阅读 [doc/load_xdma_driver.md](./doc/load_xdma_driver.md) ，在 Linux 主机中编译和加载驱动
>
> 　　　　阅读 [doc/run_software_xdma_mpeg2encoder.md](./doc/run_software_xdma_mpeg2encoder.md) ，运行C语言程序进行读写测试

　

　

## 后续工作

后续我可能再加一个例程：

- **基于 blockdesign 的 PCIe 算法加速器** ：用 HLS 编写一个加速器 (比如 FFT) ，封装为 AXI slave IP ，然后用 blockdesign 将它和 PCIe-XDMA IP 集成起来，实现一个简单的 PCIe 算法加速器。

　

　

## 参考资料

- Xilinx DMA for PCI Express (PCIe) Subsystem (XDMA) : https://china.xilinx.com/products/intellectual-property/pcie-dma.html
- Xilinx PCI Express DMA Drivers and Software Guide (Xilinx Answer 65444) : https://support.xilinx.com/s/article/65444?language=en_US