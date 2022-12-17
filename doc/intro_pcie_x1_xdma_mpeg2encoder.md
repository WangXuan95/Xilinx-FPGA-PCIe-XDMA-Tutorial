# 基于 Verilog 的 PCIe MPEG2 视频编码

该例程对应的 Vivado 工程在 [netfpga_pcie_x1_xdma_mpeg2encoder.zip](../netfpga_pcie_x1_xdma_mpeg2encoder.zip) 中。

该例程的结构如下图。其中包括

- 一个用传统 IP 例化方式例化的 **PCIe-XDMA** IP核；
- 一个开源的 [MPEG2视频编码器](https://github.com/WangXuan95/FPGA-MPEG2-encoder) (**mpeg2encoder**) ；
- 编写 Verilog 为该 MPEG2 视频编码器实现一层封装 (**axi\_mpeg2encoder\_wrapper**) ，使之能在 AXI 接口的控制下工作；
- 编写 Verilog 将以上二者连接起来。整体而言实现了一个 PCIe 视频编码卡；
- 在 Host-PC 上编写 C 语言程序去调用它，向FPGA写入视频原始像素，读取出编码视频流，实现视频压缩。

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
                 图1 : PCIe-XDMA + AXI-BRMA 实现 PCIe 内存设备
```

　

## 工程概览

打开 Vivado 工程在 [netfpga_pcie_x1_xdma_mpeg2encoder](../netfpga_pcie_x1_xdma_mpeg2encoder) ，可以看到它的文件结构如下：

- 设计文件 (Design Sources)
  - **fpga_top.sv** (FPGA顶层)
    - **xdma_0** (PCIe-XDMA IP)
    - **axi_mpeg2encoder_wrapper.sv** (把 mpeg2encoder 封装为一个 AXI-slave)
      - **mpeg2encoder.sv** (来自开源项目： [MPEG2视频编码器](https://github.com/WangXuan95/FPGA-MPEG2-encoder) )
- 约束文件 (Constraints)
  - **fpga_top.xdc** 

　

> :point_right: 关于 SystemVerilog
>
> .sv 是 SystemVerilog 的代码文件后缀，相比于 Verilog 多了一些方便的语法，但差别不大 (比 C 和 C++ 的差别小得多) 。如果你熟悉 Verilog 语法，可以直接阅读 SystemVerilog ，几乎不会存在障碍。
>
> 在 Vivado 中，SystemVerilog 和 Verilog 的模块之间可以交叉调用。

　

　

本工程的关键点在于为 **mpeg2encoder.sv** 加一层封装，也即 **axi_mpeg2encoder_wrapper.sv** ，让他能够支持 AXI 接口。

**axi_mpeg2encoder_wrapper.sv** 和上一个例子中的 **axi_bram.sv** 非常相似（AXI-slave 状态机是相同的，只不过连接的不是一个 BRAM ，而是 **mpeg2encoder.sv** ，其中一些 AXI 地址用来对 **mpeg2encoder.sv** 进行控制或读取状态（称为控制/状态寄存器），另一些 AXI 地址用来和 **mpeg2encoder.sv** 进行数据交互。

 **axi_mpeg2encoder_wrapper.sv** 的代码并不复杂，如果你在上一个例子中理解了 AXI 的时序，可以很容易看懂，这里不再进行详细叙述。

这里只简单介绍  **axi_mpeg2encoder_wrapper.sv** 中的 AXI 地址对应的含义：

```

AXI 写 ------------------------------------------------------------------------
 地址              类型            作用
 0x00000000       控制寄存器       bit0 为 mpeg2encoder 的复位，=0代表复位，=1代表释放复位
 0x00000000       控制寄存器       bit1 为 video seqence end ，写入 1 代表用户要结束当前视频流的编码。
 0x00000008       控制寄存器       低 32bit 用来配置视频帧宽度、高 32bit 用来配置视频帧高度
 0x00000010       控制寄存器       向该地址写入任何值，可以清除设备的输出缓冲区
>0x01000000       数据输入         写这段地址，相当于向 mpeg2encoder 中送入数据 (编码前的视频原始像素)

AXI 读 ------------------------------------------------------------------------
 地址              类型            作用
 0x00000010       状态寄存器       bit31-0 为设备的输出缓冲区内的数据量， bit32 代表设备的输出缓冲区是否溢出。
>0x01000000       输出缓冲区       读这段地址，相当于从输出缓冲区中拿出数据 (编码后的视频流)。
```

　

　

## 后续步骤

- 对该工程进行 综合 (Synthesis) 、实现 (implementation) 、生成比特流 (Generate bitstream)。
- 插入 PCIe 并烧录 FPGA。详见 [FPGA_plug_and_writebitstream.md](./FPGA_plug_and_writebitstream.md)
- 在 Linux 主机上加载 PCIe XDMA 的驱动。详见 [load_xdma_driver.md](./load_xdma_driver.md)
- 运行C语言程序进行读写测试。详见 [run_software_xdma_mpeg2encoder.md](./run_software_xdma_mpeg2encoder.md)

