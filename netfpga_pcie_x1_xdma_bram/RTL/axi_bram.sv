
module axi_bram #(
    parameter AXI_IDWIDTH = 4,
    parameter AXI_AWIDTH  = 64,
    parameter AXI_DWIDTH  = 256,
    parameter MEM_AWIDTH  = 12      // BRAM size = MEM_AWIDTH*C_M_AXI_DATA_WIDTH (bits) = MEM_AWIDTH*C_M_AXI_DATA_WIDTH/8 (bytes)
) (
    input  wire                        rstn,
    input  wire                        clk,
    // AXI-MM AW interface ----------------------------------------------------
    output wire                        s_axi_awready,
    input  wire                        s_axi_awvalid,
    input  wire   [    AXI_AWIDTH-1:0] s_axi_awaddr,
    input  wire   [               7:0] s_axi_awlen,
    input  wire   [   AXI_IDWIDTH-1:0] s_axi_awid,
    // AXI-MM W  interface ----------------------------------------------------
    output wire                        s_axi_wready,
    input  wire                        s_axi_wvalid,
    input  wire                        s_axi_wlast,
    input  wire   [    AXI_DWIDTH-1:0] s_axi_wdata,
    input  wire   [(AXI_DWIDTH/8)-1:0] s_axi_wstrb,
    // AXI-MM B  interface ----------------------------------------------------
    input  wire                        s_axi_bready,
    output wire                        s_axi_bvalid,
    output wire   [   AXI_IDWIDTH-1:0] s_axi_bid,
    output wire   [               1:0] s_axi_bresp,
    // AXI-MM AR interface ----------------------------------------------------
    output wire                        s_axi_arready,
    input  wire                        s_axi_arvalid,
    input  wire   [    AXI_AWIDTH-1:0] s_axi_araddr,
    input  wire   [               7:0] s_axi_arlen,
    input  wire   [   AXI_IDWIDTH-1:0] s_axi_arid,
    // AXI-MM R  interface ----------------------------------------------------
    input  wire                        s_axi_rready,
    output wire                        s_axi_rvalid,
    output wire                        s_axi_rlast,
    output reg    [    AXI_DWIDTH-1:0] s_axi_rdata,
    output wire   [   AXI_IDWIDTH-1:0] s_axi_rid,
    output wire   [               1:0] s_axi_rresp 
);


function automatic int log2 (input int x);
    int xtmp = x, y = 0;
    while (xtmp != 0) begin
        y ++;
        xtmp >>= 1;
    end
    return (y == 0) ? 0 : (y - 1);
endfunction



// ---------------------------------------------------------------------------------------
// AXI READ state machine
// ---------------------------------------------------------------------------------------

enum reg [0:0] {R_IDLE, R_BUSY} rstate = R_IDLE;

reg  [AXI_IDWIDTH-1:0] rid = '0;
reg  [            7:0] rcount = '0;
reg  [ MEM_AWIDTH-1:0] mem_raddr, mem_raddr_last;

assign s_axi_arready = (rstate == R_IDLE);
assign s_axi_rvalid  = (rstate == R_BUSY);
assign s_axi_rlast   = (rstate == R_BUSY) && (rcount == 8'd0);
assign s_axi_rid     = rid;
assign s_axi_rresp   = '0;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        rstate <= R_IDLE;
        rid    <= '0;
        rcount <= '0;
    end else begin
        case (rstate)
            R_IDLE :
                if (s_axi_arvalid) begin
                    rstate <= R_BUSY;
                    rid    <= s_axi_arid;
                    rcount <= s_axi_arlen;
                end
            R_BUSY :
                if (s_axi_rready) begin
                    if (rcount == 8'd0)       // the last data of read session
                        rstate <= R_IDLE;
                    rcount <= rcount - 8'd1;
                end
        endcase
    end

always_comb
    if      (rstate == R_IDLE && s_axi_arvalid)
        mem_raddr = (MEM_AWIDTH)'(s_axi_araddr >> log2(AXI_DWIDTH/8));
    else if (rstate == R_BUSY && s_axi_rready)
        mem_raddr = mem_raddr_last + (MEM_AWIDTH)'(1);
    else
        mem_raddr = mem_raddr_last;

always @ (posedge clk)
    mem_raddr_last <= mem_raddr;



// ---------------------------------------------------------------------------------------
// AXI WRITE state machine
// ---------------------------------------------------------------------------------------

enum reg [1:0] {W_IDLE, W_BUSY, W_RESP} wstate = W_IDLE;

reg  [AXI_IDWIDTH-1:0] wid = '0;
reg  [            7:0] wcount = '0;
reg  [ MEM_AWIDTH-1:0] mem_waddr = '0;

assign s_axi_awready = (wstate == W_IDLE);
assign s_axi_wready  = (wstate == W_BUSY);
assign s_axi_bvalid  = (wstate == W_RESP);
assign s_axi_bid     = wid;
assign s_axi_bresp   = '0;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        wstate <= W_IDLE;
        wid <= '0;
        wcount <= '0;
        mem_waddr <= '0;
    end else begin
        case (wstate)
            W_IDLE :
                if (s_axi_awvalid) begin
                    wstate <= W_BUSY;
                    wid <= s_axi_awid;
                    wcount <= s_axi_awlen;
                    mem_waddr <= (MEM_AWIDTH)'(s_axi_awaddr >> log2(AXI_DWIDTH/8));
                end
            W_BUSY :
                if (s_axi_wvalid) begin
                    if (wcount == 8'd0 || s_axi_wlast)
                        wstate <= W_RESP;
                    wcount <= wcount - 8'd1;
                    mem_waddr <= mem_waddr + (MEM_AWIDTH)'(1);
                end
            W_RESP :
                if (s_axi_bready)
                    wstate <= W_IDLE;
            default :
                wstate <= W_IDLE;
        endcase
    end



// ---------------------------------------------------------------------------------------
// a block RAM
// ---------------------------------------------------------------------------------------

reg [AXI_DWIDTH-1:0] mem [ 1<<MEM_AWIDTH ];

always @ (posedge clk)
    s_axi_rdata <= mem[mem_raddr];

always @ (posedge clk)
    if (s_axi_wvalid & s_axi_wready)
        for (int i=0; i<(AXI_DWIDTH/8); i++)
            if (s_axi_wstrb[i])
                mem[mem_waddr][i*8+:8] <= s_axi_wdata[i*8+:8];
    
endmodule


