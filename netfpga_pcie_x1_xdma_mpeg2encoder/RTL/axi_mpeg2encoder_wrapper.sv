
module axi_mpeg2encoder_wrapper #(
    parameter AXI_IDWIDTH = 4
) (
    input  wire                     rstn,
    input  wire                     clk,
    // AXI-MM AW interface ----------------------------------------------------
    output wire                     s_axi_awready,
    input  wire                     s_axi_awvalid,
    input  wire   [           63:0] s_axi_awaddr,
    input  wire   [            7:0] s_axi_awlen,
    input  wire   [AXI_IDWIDTH-1:0] s_axi_awid,
    // AXI-MM W  interface ----------------------------------------------------
    output wire                     s_axi_wready,
    input  wire                     s_axi_wvalid,
    input  wire                     s_axi_wlast,
    input  wire   [           63:0] s_axi_wdata,
    // AXI-MM B  interface ----------------------------------------------------
    input  wire                     s_axi_bready,
    output wire                     s_axi_bvalid,
    output wire   [AXI_IDWIDTH-1:0] s_axi_bid,
    output wire   [            1:0] s_axi_bresp,
    // AXI-MM AR interface ----------------------------------------------------
    output wire                     s_axi_arready,
    input  wire                     s_axi_arvalid,
    input  wire   [           63:0] s_axi_araddr,
    input  wire   [            7:0] s_axi_arlen,
    input  wire   [AXI_IDWIDTH-1:0] s_axi_arid,
    // AXI-MM R  interface ----------------------------------------------------
    input  wire                     s_axi_rready,
    output wire                     s_axi_rvalid,
    output wire                     s_axi_rlast,
    output reg    [           63:0] s_axi_rdata,
    output wire   [AXI_IDWIDTH-1:0] s_axi_rid,
    output wire   [            1:0] s_axi_rresp 
);




// ---------------------------------------------------------------------------------------
// AXI READ state machine
// ---------------------------------------------------------------------------------------

enum reg [0:0] {R_IDLE, R_BUSY} rstate = R_IDLE;

reg  [AXI_IDWIDTH-1:0] rid = '0;
reg  [            7:0] rcount = '0;
reg  [         63-3:0] raddr_63_3, raddr_63_3_r;
wire [           63:0] raddr   = {raddr_63_3  , 3'h0};
wire [           63:0] raddr_r = {raddr_63_3_r, 3'h0};

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
        raddr_63_3 = s_axi_araddr[63:3];
    else if (rstate == R_BUSY && s_axi_rready)
        raddr_63_3 = raddr_63_3_r + 61'h1;
    else
        raddr_63_3 = raddr_63_3_r;

always @ (posedge clk)
    raddr_63_3_r <= raddr_63_3;



// ---------------------------------------------------------------------------------------
// AXI WRITE state machine
// ---------------------------------------------------------------------------------------

enum reg [1:0] {W_IDLE, W_BUSY, W_RESP} wstate = W_IDLE;

reg  [AXI_IDWIDTH-1:0] wid = '0;
reg  [            7:0] wcount = '0;
reg  [         63-3:0] waddr_63_3 = '0;
wire [           63:0] waddr = {waddr_63_3, 3'h0};

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
        waddr_63_3 <= '0;
    end else begin
        case (wstate)
            W_IDLE :
                if (s_axi_awvalid) begin
                    wstate <= W_BUSY;
                    wid <= s_axi_awid;
                    wcount <= s_axi_awlen;
                    waddr_63_3 <= s_axi_awaddr[63:3];
                end
            W_BUSY :
                if (s_axi_wvalid) begin
                    if (wcount == 8'd0 || s_axi_wlast)
                        wstate <= W_RESP;
                    wcount <= wcount - 8'd1;
                    waddr_63_3 <= waddr_63_3 + 61'h1;
                end
            W_RESP :
                if (s_axi_bready)
                    wstate <= W_IDLE;
            default :
                wstate <= W_IDLE;
        endcase
    end



function automatic logic [255:0] big_endian_to_little_endian_32B (input logic [255:0] din);
    logic [255:0] dout;
    for (int i=0; i<32; i++)
        dout[i*8 +: 8] = din[(31-i)*8 +: 8];
    return dout;
endfunction



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// signals of the MPEG2 encoder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          mpeg2_rstn = '0;

wire         mpeg2_sequence_busy;
reg          mpeg2_sequence_stop = '0;

reg  [  6:0] mpeg2_xsize16 = '0;
reg  [  6:0] mpeg2_ysize16 = '0;

reg          mpeg2_i_en = '0;
reg  [  7:0] mpeg2_i_Y0, mpeg2_i_Y1, mpeg2_i_Y2, mpeg2_i_Y3;
reg  [  7:0] mpeg2_i_U0,             mpeg2_i_U2            ;
reg  [  7:0] mpeg2_i_V0,             mpeg2_i_V2            ;

wire         mpeg2_o_en;
wire         mpeg2_o_last;
wire [255:0] mpeg2_o_data;

reg  [ 15:0] mpeg2_o_addr = '0;
reg          mpeg2_o_over = '0;        // 1: overflow !


reg [255:0] out_buf ['h10000];                            // out buffer : a block RAM to save the MPEG2 IP's out data, 32B * 0x10000 = 2 MB

reg [255:0] out_buf_rdata;

always @ (posedge clk)
    out_buf_rdata <= out_buf[ (16)'(raddr>>5) ];          // read BRAM

always @ (posedge clk)
    if ( mpeg2_o_en & ~mpeg2_o_over )
        out_buf[mpeg2_o_addr] <= big_endian_to_little_endian_32B(mpeg2_o_data);


always_comb
    if      ( raddr_r == 64'h00000000 )                   // address  = 0x00000000 : read status register (reset status and sequence status)
        s_axi_rdata = {61'h0, mpeg2_sequence_busy, 1'b0, mpeg2_rstn};
    else if ( raddr_r == 64'h00000008 )                   // address  = 0x00000008 : read status register (video frame size)
        s_axi_rdata = {25'h0, mpeg2_ysize16,
                       25'h0, mpeg2_xsize16 };
    else if ( raddr_r == 64'h00000010 )                   // address  = 0x00000010 : read status register (out buffer status)
        s_axi_rdata = { 31'h0, mpeg2_o_over,
                        11'h0, mpeg2_o_addr, 5'h0};
    else if ( raddr_r >= 64'h01000000 )                   // address >= 0x01000000 : read out buffer (i.e. MPEG2 output stream)
        case( raddr_r[4:3] )
            2'b00 : s_axi_rdata = out_buf_rdata[ 63:  0];
            2'b01 : s_axi_rdata = out_buf_rdata[127: 64];
            2'b10 : s_axi_rdata = out_buf_rdata[191:128];
            2'b11 : s_axi_rdata = out_buf_rdata[255:192];
        endcase
    else
        s_axi_rdata = '0;


always @ (posedge clk) begin
    mpeg2_sequence_stop <= 1'b0;
    mpeg2_i_en          <= 1'b0;
    
    if ( mpeg2_o_en ) begin
        if ( mpeg2_o_addr == '1 )
            mpeg2_o_over <= 1'b1;
        else
            mpeg2_o_addr <= mpeg2_o_addr + 16'h1;
    end
    
    if ( s_axi_wvalid & s_axi_wready ) begin
        if          ( waddr == 64'h00000000 ) begin       // address  = 0x00000000 : write reset control register (reset control and sequence control)
            mpeg2_rstn          <= s_axi_wdata[0];
            mpeg2_sequence_stop <= s_axi_wdata[1];
            
        end else if ( waddr == 64'h00000008 ) begin       // address  = 0x00000008 : write control register (video frame size)
            mpeg2_xsize16 <= s_axi_wdata[ 6: 0];
            mpeg2_ysize16 <= s_axi_wdata[38:32];
            
        end else if ( waddr == 64'h00000010 ) begin       // address  = 0x00000010 : write control register (out buffer control)
            mpeg2_o_addr <= '0;
            mpeg2_o_over <= '0;
        
        end else if ( waddr >= 64'h01000000 ) begin       // address >= 0x01000000 : write video input data (i.e. raw YUV pixels)
            mpeg2_i_en <= 1'b1;
            { mpeg2_i_V2, mpeg2_i_Y3, mpeg2_i_U2, mpeg2_i_Y2,
              mpeg2_i_V0, mpeg2_i_Y1, mpeg2_i_U0, mpeg2_i_Y0 } <= s_axi_wdata;
        end
    end
end



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MPEG2 encoder instance
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

mpeg2encoder #(
    .XL                 ( 6                   ),   // determine the max horizontal pixel count.  4->256 pixels  5->512 pixels  6->1024 pixels  7->2048 pixels .
    .YL                 ( 6                   ),   // determine the max vertical   pixel count.  4->256 pixels  5->512 pixels  6->1024 pixels  7->2048 pixels .
    .VECTOR_LEVEL       ( 3                   ),
    .Q_LEVEL            ( 2                   )
) mpeg2encoder_i (
    .rstn               ( mpeg2_rstn          ),
    .clk                ( clk                 ),
    // Video sequence configuration interface.
    .i_xsize16          ( mpeg2_xsize16       ),
    .i_ysize16          ( mpeg2_ysize16       ),
    .i_pframes_count    ( 8'd47               ),
    // Video sequence input pixel stream interface. In each clock cycle, this interface can input 4 adjacent pixels in a row. Pixel format is YUV 4:4:4, the module will convert it to YUV 4:2:0, then compress it to MPEG2 stream.
    .i_en               ( mpeg2_i_en          ),
    .i_Y0               ( mpeg2_i_Y0          ),
    .i_Y1               ( mpeg2_i_Y1          ),
    .i_Y2               ( mpeg2_i_Y2          ),
    .i_Y3               ( mpeg2_i_Y3          ),
    .i_U0               ( mpeg2_i_U0          ),
    .i_U1               ( mpeg2_i_U0          ),
    .i_U2               ( mpeg2_i_U2          ),
    .i_U3               ( mpeg2_i_U2          ),
    .i_V0               ( mpeg2_i_V0          ),
    .i_V1               ( mpeg2_i_V0          ),
    .i_V2               ( mpeg2_i_V2          ),
    .i_V3               ( mpeg2_i_V2          ),
    // Video sequence control interface.
    .i_sequence_stop    ( mpeg2_sequence_stop ),
    .o_sequence_busy    ( mpeg2_sequence_busy ),
    // Video sequence output MPEG2 stream interface.
    .o_en               ( mpeg2_o_en          ),
    .o_last             ( mpeg2_o_last        ),
    .o_data             ( mpeg2_o_data        )
);




endmodule


