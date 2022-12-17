`ifndef PCIE_DMA_ATTR_DEFINES_VH
`define PCIE_DMA_ATTR_DEFINES_VH

// DMA PF Attributes
typedef struct packed {
    logic    [3:0]       ch_alloc;
    logic    [1:0]       multq_chbits;
    logic    [5:0]       multq_maxq;
    logic    [2:0]       multq_bits;
    logic    [5:0]       vfmaxq;
    logic    [2:0]       multq_vfqbits;
    logic    [7:0]       num_vfs;
    logic    [7:0]       firstvf_offset;
} attr_dma_pf_t;

// DMA PCIeBAR to AXIBAR Attributes
typedef struct packed {
    logic    [63:12]     bar;
    logic                sec;
    logic    [3:0]       cache;
    logic    [7:0]       len;
    logic    [31:0]      bar_vf;
    logic                sec_vf;
    logic    [3:0]       cache_vf;
    logic    [7:0]       len_vf;
} attr_dma_pciebar2axibar_pf_t;

// DMA AXIBAR to PCIeBAR Attributes
typedef struct packed {
    logic    [63:0]       base;
    logic                 as;
    logic    [7:0]        highaddr;
    logic    [63:0]       bar;
} attr_dma_axibar2pciebar_t;

// DMA General Attributes 
typedef struct packed {
    logic    [63:0]       axi_slv_brdg_base_addr;
    logic    [63:0]       axi_slv_multq_base_addr;
    logic    [63:0]       axi_slv_xdma_base_addr;
    logic                 enable;
    logic                 bypass_msix;
    logic    [2:0]        data_width;
    logic                 metering_enable;
    logic    [5:0]        mask50; 
    logic                 root_port;
    logic                 msi_rx_decode_en;
    logic                 pcie_if_parity_check;
    logic    [31:0]       slvlite_base0;
    logic    [31:0]       slvlite_base1;
    logic    [2:0]        barlite0;
    logic    [2:0]        barlite1;
    logic    [2:0]        axibar_num;
    logic    [2:0]        pciebar_num;
    logic    [3:0]        ch_en;
    logic    [3:0][1:0]   ch_pfid;
    logic    [3:0]        ch_multq;
    logic    [3:0]        ch_stream;
    logic    [3:0]        ch_c2h_axi_dsc;
    logic    [3:0]        ch_h2c_axi_dsc;
    logic    [3:0]        ch_multq_ll;
    logic    [3:0][5:0]   ch_multq_max;
    logic                 cq_rcfg_en;
    logic    [255:0]      spare;
} attr_dma_t;

`endif
