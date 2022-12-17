# PCIe BRAM 读写——在 Host-PC 上运行 C 语言程序

我编写了一个简单的 Linux C 语言程序 （[host_software/app_xdma_rw/xdma_rw.c](../host_software/app_xdma_rw/xdma_rw.c)） 来对 PCIe-XDMA 设备进行读写，它可以实现：

- **host-to-device** : 把本地文件中的指定长度的内容写入 PCIe-XDMA 中的指定地址 (也即 AXI 总线的地址)
- **device-to-host** : 从 PCIe-XDMA 中的指定地址 (也即 AXI 总线的地址) 读出指定长度的数据，写入本地文件

　

## 编译程序

首先 cd 到程序所在的目录：

```bash
$ cd host_software/app_xdma_rw/
```

然后运行以下命令来把 `xdma_rw.c` 编译为可执行文件 `xdma_rw` ：

```bash
$ gcc xdma_rw.c -o xdma_rw
```

　

## 运行程序

运行以下命令，调用 `xdma_rw` 来把 `random.bin` 里的数据写入到 FPGA

```bash
$ sudo ./xdma_rw random.bin to /dev/xdma0_h2c_0 0 256
# 参数1 : "random.bin" 是要读取的文件
# 参数2 : "to" 代表方向是 host-to-device
# 参数3 : "/dev/xdma0_h2c_0" 是设备文件，用来向FPGA中写数据
# 参数4 : 0 是要写入的设备中的地址 (字节)，在 FPGA 端是 AXI 写地址
# 参数5 : 256 是要写入的长度 (字节)
```

然后运行以下命令，把刚刚写入的数据读回来，存到 `receive.bin` 文件里

```bash
$ sudo ./xdma_rw receive.bin from /dev/xdma0_c2h 0 256
# 参数1 : "receive.bin" 是要写入的文件
# 参数2 : "from" 代表方向是 device-to-host
# 参数3 : "/dev/xdma0_c2h_0" 是设备文件，用来从FPGA中读数据
# 参数4 : 0 是要读取的设备中的地址 (字节)，在 FPGA 端是 AXI 读地址
# 参数5 : 256 是要读取的长度 (字节)
```

如果 FPGA 程序无误，读出来的 `receive.bin` 应该和 `random.bin` 完全相同，你可以用 `hexdump` 命令查看这两个二进制文件来验证。

```bash
$ hexdump random.bin
$ hexdump receive.bin
```

当然，你可以任意指定地址和长度。注意：我们在 Vivado 工程搭建的 BRAM 只有 512KB ，因此向 >512KB 的地址写数据没有任何效果 (虽然可以写) ，从中读出的数据也恒为 0 （虽然可以读）。

　

## C 程序说明

打开 [xdma_rw.c](../host_software/app_xdma_rw/xdma_rw.c) ，看看这个程序是如何编写的，其中的关键是对设备的4种操作：打开(`open`) 、设置操作地址 (`lseek`) 、读取 (`read`) 、写入 (`write`)

#### 打开设备文件 (open)

```c
// char *dev_name;        // 设备路径
// int dev_fd;            // 设备 descriptor
dev_fd = open(dev_name, O_RDWR);    // open 函数来自 fcntl.h
                                    // 实参 dev_name 是设备路径，例如 "/dev/xdma0_c2h"，在本程序中来自用户输入的命令行参数
                                    // 返回值 dev_fd 是设备 descriptor , >=0 代表打开成功， <0 代表打开失败
```

#### 设置操作地址 (lseek)

```c
// int dev_fd;          // 设备 descriptor
// uint64_t addr;       // 要设置的目标地址
if ( addr != lseek(dev_fd, addr, SEEK_SET) ) {   // lseek 函数来自 fcntl.h
                                                 // 返回值是设置后的地址，如果设置失败则 != addr ，如果成功则 == addr
    // 失败
} else {
    // 成功
}
```

#### 从设备读取到本地缓冲区 (read)

```c
// int dev_fd;      // 设备 descriptor
// void *buffer;    // 目标缓冲区
// uint64_t size;   // 要读取的数据量
if ( size != read(dev_fd, buffer, size) ) {   // read 函数来自 fcntl.h
                                              // 返回值是读取的数据量，如果成功则 == size，失败则 != size
    // 失败
} else {
    // 成功
}
```

#### 从本地缓冲区写到设备 (write)

```c
// int dev_fd;      // 设备 descriptor
// void *buffer;    // 源缓冲区
// uint64_t size;   // 要读取的数据量
if ( size != write(dev_fd, buffer, size) ) {   // write 函数来自 fcntl.h
                                               // 返回值是写入的数据量，如果成功则 == size，失败则 != size
    // 失败
} else {
    // 成功
}
```

