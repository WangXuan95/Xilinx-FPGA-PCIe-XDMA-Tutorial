cmd_/home/wangxuan/pcie_xdma_host_software/driver/xdma/xdma.ko := ld -r -m elf_x86_64  -z max-page-size=0x200000 -T ./scripts/module-common.lds --build-id  -o /home/wangxuan/pcie_xdma_host_software/driver/xdma/xdma.ko /home/wangxuan/pcie_xdma_host_software/driver/xdma/xdma.o /home/wangxuan/pcie_xdma_host_software/driver/xdma/xdma.mod.o