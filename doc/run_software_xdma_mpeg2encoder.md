# PCIe BRAM 读写——在 Host-PC 上运行 C 语言程序

我编写了一个简单的 Linux C 语言程序 （[host_software/app_xdma_mpeg2encode/xdma_mpeg2encode.c](../host_software/app_xdma_mpeg2encode/xdma_mpeg2encode.c)） 来对 PCIe-XDMA 设备进行读写，从而实现视频编码（把视频的原始像素编码为 MPEG2 视频流）。

　

## 准备要编码的视频的原始像素

视频的原始像素一般来自摄像头，而存在电脑里的视频文件往往都是编码后的。这里提供了一段很短的视频的原始像素文件[host_software/app_xdma_mpeg2encode/videos/960x960.yuv](../host_software/app_xdma_mpeg2encode/videos/960x960.yuv) 。

另外，如果你想把更多视频转换为原始像素文件，可以使用编写的 Python 程序 [host_software/app_xdma_mpeg2encode/videos/get_raw_yuyv_from_video.py](../host_software/app_xdma_mpeg2encode/videos/get_raw_yuyv_from_video.py) 。使用该 Python 程序前需要安装相关依赖：

```bash
$ python -m pip install numpy
$ python -m pip install opencv-python
```

然后运行该 Python 程序，可以把任意视频文件（例如 .mp4, .mkv）转化为原始像素文件 （.yuv），例如：

```bash
$ python get_raw_yuyv_from_video.py 640x480.mkv 640x480.yuv
```

　

## 编译程序

首先 cd 到程序所在的目录：

```bash
$ cd host_software/app_xdma_mpeg2encode/
```

然后运行以下命令来把 `xdma_mpeg2encode.c` 编译为可执行文件 `xdma_mpeg2encode` ：

```bash
$ gcc xdma_mpeg2encode.c -o xdma_mpeg2encode
```

　

## 运行程序

运行该程序，可以把原始像素文件编码为MPEG2视频流文件(.m2v) 。

```bash
$ sudo ./xdma_mpeg2encode  <FPGA读设备名>  <FPGA写设备名>  <原始像素文件(.yuv)>  <编码得到的MPEG2视频流文件(.m2v)>  <视频帧宽度>  <视频帧高度>
```

例如：

```bash
$ sudo ./xdma_mpeg2encode  /dev/xdma0_c2h_0  /dev/xdma0_h2c_0  videos/960x960.yuv  out.m2v  960  960
```

生成的 .m2v 文件可以直接使用操作系统自带的视频查看器来查看。（Linux 还要安装依赖，可以直接放到 Windows 上使用 Windows Media Player 上打开）。

　

## C 程序说明

 [xdma_mpeg2encoder.c](../host_software/app_xdma_mpeg2encode/xdma_mpeg2encode.c) 的代码量不大，其中的关键点是对设备的4个操作函数：打开(`open`) 、设置操作地址 (`lseek`) 、读取 (`read`) 、写入 (`write`) （来自头文件 `fcntl.h` ）。此处不做赘述。
