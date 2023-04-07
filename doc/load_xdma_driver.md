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
$ cd host_software/driver/XDMA/linux-kernel/xdma/
$ sudo make
```

编译成功后，会产生驱动模块文件 `xdma.ko` 。

注意：如果你想重新编译，则需要删除所有编译生成的 `.o` 和 `.ko` 文件，然后重新运行 `make` 来编译：

```bash
$ sudo rm *.o
$ sudo rm *.ko
$ sudo make
```

## 编译测试工具

本项目采用 Xilinx 官方提供的 [XDMA Linux 驱动](https://github.com/Xilinx/dma_ip_drivers) ，官方为其配套了一些测试工具，需要用户自行编译。借助这些工具，用户可以检查自己的驱动是否安装正确

切换到 `tools` 目录，并运行 `make` 对工具进行编译

```bash
$ cd ../tools/
$ sudo make
```

## 加载 XDMA 驱动

编译成功后，cd 到 `tests` 目录，运行 `load_driver.sh` 脚本来加载驱动 。需要注意 ，这里的 `load_driver.sh` 脚本 ，默认使用中断方式调用设备 ，因为我们前期配置中没有使用到XDMA的中断功能 ，因此需要使用一个参数来使用轮询方式加载驱动

```bash
$ cd ../tests/                     # cd 到上级目录 linux-kernel/tests 中
$ sudo ./load_driver.sh 4
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

## 检验驱动是否正确启用

完成加载后，可以通过调用 Xilinx 提供的测试工具来检测驱动正确性。在 `test` 目录中调用 `run_test.sh` 脚本，等待测试完毕即可

```bash
$ sudo sh ./run_test.sh
```

如果测试正常 ，程序将快速返回 ，给出 `Info: All PCIe DMA memory mapped tests passed.` 和 `Info: All tests in run_tests.sh passed.` 的结果

如果卡死 ，可以卸载之前的 XDMA 驱动并检查之前步骤中是否以轮询方式加载 ，卸载使用下面的命令

```bash
$ sudo rmmod xdma
```

更多使用信息可以参考 `driver/XDMA/linux-kernel/readme.txt` 或前往 官方repo 进行查询


