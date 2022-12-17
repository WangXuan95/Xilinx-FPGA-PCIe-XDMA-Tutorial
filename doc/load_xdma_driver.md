# 在 Linux 主机上加载 PCIe XDMA 驱动

本文档讲解如何在 Linux Host-PC 上编译和加载 Xilinx 提供的 xdma 的驱动。为运行软件打基础。

　

## 查看 PCIe XDMA 设备是否被识别

Linux 重启后，运行 `lspci` 命令来看看 PCIe 设备是否被正常识别。如果发现其中有 "Memory controller: Xilinx..." ，说明识别成功。

```bash
$ lspci
...                                                             # 其它 PCI 设备
01:00.0 Memory controller: Xilinx Corporation Device 7021       # Xilinx PCIe-XDMA 设备
...                                                             # 其它 PCI 设备
```

　

## 编译 XDMA 驱动

然后 cd 到以下目录中，并运行 `make` 编译 Xilinx 提供的 XDMA 驱动 (注意这里需要用管理员权限) 。

```bash
$ cd host_software/driver/xdma
$ sudo make
```

编译成功后，会产生驱动模块文件 `xdma.ko` 。

注意：如果你想重新编译，则需要删除所有编译生成的 `.o` 和 `.ko` 文件，然后重新运行 `make` 来编译：

```bash
$ sudo rm *.o
$ sudo rm *.ko
$ sudo make
```

　

## 加载 XDMA 驱动

编译成功后，cd 到 上级目录，运行 `load_driver.sh` 脚本来加载驱动 。

```bash
$ cd ..                     # cd 到上级目录 host_software/driver 中
$ sudo ./load_driver
```

如果驱动加载成功，则显示 `"DONE"` 。

然后我们运行以下命令，会发现 `/dev` 目录下出现一系列 `xdma` 设备。

```bash
$ ls /dev/xdma*
...
/dev/xdma0_c2h_0
...
/dev/xdma0_h2c_0
```

其中我们要用到的设备是 `/dev/xdma0_c2h_0` 和 `/dev/xdma0_h2c_0` ，前者用来从 FPGA 中读取数据 (device_to_host) ，后者用来向 FPGA 中传送数据 (host_to_device)

　

