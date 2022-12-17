
module mpeg2encoder #(
    parameter  XL           = 6,   // determine the max horizontal pixel count.  4->256 pixels  5->512 pixels  6->1024 pixels  7->2048 pixels .
    parameter  YL           = 6,   // determine the max vertical   pixel count.  4->256 pixels  5->512 pixels  6->1024 pixels  7->2048 pixels .
    parameter  VECTOR_LEVEL = 3,   // motion vector range level, must be 1, 2, or 3. The larger the XL, the higher compression ratio, and the more LUT resource is uses.
    parameter  Q_LEVEL      = 2    // quantize level, must be 1, 2, 3 or 4. The larger the Q_LEVEL, the higher compression ratio and the lower quality.
) (
    input  wire        rstn,                     // =0:async reset, =1:normal operation. It MUST be reset before starting to use.
    input  wire        clk,
    
    // Video sequence configuration interface. --------------------------------------------------------------------------------------------------------------
    input  wire [XL:0] i_xsize16,                // horizontal pixel count = i_xsize16*16 . valid range: 4 ~ 2^XL
    input  wire [YL:0] i_ysize16,                // vertical   pixel count = i_ysize16*16 . valid range: 4 ~ 2^YL
    input  wire [ 7:0] i_pframes_count,          // defines the number of P-frames between two I-frames. valid range: 0 ~ 255
    
    // Video sequence input pixel stream interface. In each clock cycle, this interface can input 4 adjacent pixels in a row. Pixel format is YUV 4:4:4, the module will convert it to YUV 4:2:0, then compress it to MPEG2 stream. 
    input  wire        i_en,                     // when i_en=1, 4 adjacent pixels is being inputted,
    input  wire [ 7:0] i_Y0, i_Y1, i_Y2, i_Y3,   // input Y (luminance)
    input  wire [ 7:0] i_U0, i_U1, i_U2, i_U3,   // input U (Cb, chroma blue)
    input  wire [ 7:0] i_V0, i_V1, i_V2, i_V3,   // input V (Cr, chroma red)
    
    // Video sequence control interface. --------------------------------------------------------------------------------------------------------------------
    input  wire        i_sequence_stop,          // use this signal to stop a inputting video sequence
    output wire        o_sequence_busy,          // =0: the module is idle and ready to encode the next sequence. =1: the module is busy encoding the current sequence
    
    // Video sequence output MPEG2 stream interface. --------------------------------------------------------------------------------------------------------
    output wire        o_en,                     // o_en=1 indicates o_data is valid
    output wire        o_last,                   // o_en=1 & o_last=1 indicates this is the last data of a video sequence
    output wire[255:0] o_data                    // output mpeg2 stream data, 32 bytes in BIG ENDIAN, i.e., o_data[255:248] is the 1st byte, o_data[247:0] is the 2nd byte, ... o_data[7:0] is the 32nd byte.
);




//
// Definition of nouns:
//     tile        : 8x8 pixels, the unit of DCT, quantize and zig-zag reorder
//     block (blk) : contains 16x16 U pixels (4 tiles of Y, 1 tile of U, 1 tile of V)
//     slice       : a line of block (16 lines of pixels)
//
// Note : 
//     right shift: for signed number, use ">>>" rather than ">>". for unsigned number, using ">>>" and ">>" are both okay.
//





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// local parameters : frame size
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam XB16 = XL       ,  YB16 = YL      ;
localparam XB8  = XB16 + 1 ,  YB8  = YB16 + 1;
localparam XB4  = XB8  + 1 ,  YB4  = YB8  + 1;
localparam XB2  = XB4  + 1 ,  YB2  = YB4  + 1;
localparam XB   = XB2  + 1 ,  YB   = YB2  + 1;

localparam XSIZE = (1 << XB);                               // horizontal max pixel count
localparam YSIZE = (1 << YB);                               // vertical   max pixel count


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// local parameters : motion estimation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam int UR =  VECTOR_LEVEL;                          // U/V motion vector range is in -YR~+YR pixels
localparam int YR =  UR * 2;                                // Y motion vector range is in -YR~+YR pixels


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// local parameters : DCT
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam DCTP = 0;

localparam logic signed [7:0] DCT_MATRIX [8][8] = '{
    '{ 64,  64,  64,  64,  64,  64,  64,  64 },
    '{ 89,  75,  50,  18, -18, -50, -75, -89 },
    '{ 84,  35, -35, -84, -84, -35,  35,  84 },
    '{ 75, -18, -89, -50,  50,  89,  18, -75 },
    '{ 64, -64, -64,  64,  64, -64, -64,  64 },
    '{ 50, -89,  18,  75, -75, -18,  89, -50 },
    '{ 35, -84,  84, -35, -35,  84, -84,  35 },
    '{ 18, -50,  75, -89,  89, -75,  50, -18 }
};

/*
localparam DCTP = 2;

localparam logic signed [9:0] DCT_MATRIX [8][8] = '{
    '{ 256,  256,  256,  256,  256,  256,  256,  256 },
    '{ 355,  301,  201,   71,  -71, -201, -301, -355 },
    '{ 334,  139, -139, -334, -334, -139,  139,  334 },
    '{ 301,  -71, -355, -201,  201,  355,   71, -301 },
    '{ 256, -256, -256,  256,  256, -256, -256,  256 },
    '{ 201, -355,   71,  301, -301,  -71,  355, -201 },
    '{ 139, -334,  334, -139, -139,  334, -334,  139 },
    '{  71, -201,  301, -355,  355, -301,  201,  -71 }
};*/


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// local parameters : quantize
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam logic [6:0] INTRA_Q [8][8] = '{
    '{  8, 16, 19, 22, 26, 27, 29, 34 },
    '{ 16, 16, 22, 24, 27, 29, 34, 37 },
    '{ 19, 22, 26, 27, 29, 34, 34, 38 },
    '{ 22, 22, 26, 27, 29, 34, 37, 40 },
    '{ 22, 26, 27, 29, 32, 35, 40, 48 },
    '{ 26, 27, 29, 32, 35, 40, 48, 58 },
    '{ 26, 27, 29, 34, 38, 46, 56, 69 },
    '{ 27, 29, 35, 38, 46, 56, 69, 83 }
};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// local parameters : zig-zag reorder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam logic [5:0] ZIG_ZAG_TABLE [8][8] = '{
    '{  0,  1,  5,  6, 14, 15, 27, 28 },
    '{  2,  4,  7, 13, 16, 26, 29, 42 },
    '{  3,  8, 12, 17, 25, 30, 41, 43 },
    '{  9, 11, 18, 24, 31, 40, 44, 53 },
    '{ 10, 19, 23, 32, 39, 45, 52, 54 },
    '{ 20, 22, 33, 38, 46, 51, 55, 60 },
    '{ 21, 34, 37, 47, 50, 56, 59, 61 },
    '{ 35, 36, 48, 49, 57, 58, 62, 63 }
};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// local parameters : inverse DCT
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam logic signed [16:0] W1 = 17'sd2841;     // 2048*sqrt(2)*cos(1*pi/16)
localparam logic signed [16:0] W2 = 17'sd2676;     // 2048*sqrt(2)*cos(2*pi/16)
localparam logic signed [16:0] W3 = 17'sd2408;     // 2048*sqrt(2)*cos(3*pi/16)
localparam logic signed [16:0] W5 = 17'sd1609;     // 2048*sqrt(2)*cos(5*pi/16)
localparam logic signed [16:0] W6 = 17'sd1108;     // 2048*sqrt(2)*cos(6*pi/16)
localparam logic signed [16:0] W7 = 17'sd565 ;     // 2048*sqrt(2)*cos(7*pi/16)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// local parameters : look-up-tables for variable length code (VLC)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

localparam logic [4:0] BITS_MOTION_VECTOR [17] = '{5'h01, 5'h01, 5'h01, 5'h01, 5'h03, 5'h05, 5'h04, 5'h03, 5'h0b, 5'h0a, 5'h09, 5'h11, 5'h10, 5'h0f, 5'h0e, 5'h0d, 5'h0c};
localparam logic [3:0] LENS_MOTION_VECTOR [17] = '{4'd01, 4'd02, 4'd03, 4'd04, 4'd06, 4'd07, 4'd07, 4'd07, 4'd09, 4'd09, 4'd09, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10};

localparam logic [4:0] BITS_NZ_FLAGS [64] = '{5'h00, 5'h0b, 5'h09, 5'h0d, 5'h0d, 5'h17, 5'h13, 5'h1f, 5'h0c, 5'h16, 5'h12, 5'h1e, 5'h13, 5'h1b, 5'h17, 5'h13, 5'h0b, 5'h15, 5'h11, 5'h1d, 5'h11, 5'h19, 5'h15, 5'h11, 5'h0f, 5'h0f, 5'h0d, 5'h03, 5'h0f, 5'h0b, 5'h07, 5'h07, 5'h0a, 5'h14, 5'h10, 5'h1c, 5'h0e, 5'h0e, 5'h0c, 5'h02, 5'h10, 5'h18, 5'h14, 5'h10, 5'h0e, 5'h0a, 5'h06, 5'h06, 5'h12, 5'h1a, 5'h16, 5'h12, 5'h0d, 5'h09, 5'h05, 5'h05, 5'h0c, 5'h08, 5'h04, 5'h04, 5'h07, 5'h0a, 5'h08, 5'h0c};
localparam logic [3:0] LENS_NZ_FLAGS [64] = '{4'd00, 4'd05, 4'd05, 4'd06, 4'd04, 4'd07, 4'd07, 4'd08, 4'd04, 4'd07, 4'd07, 4'd08, 4'd05, 4'd08, 4'd08, 4'd08, 4'd04, 4'd07, 4'd07, 4'd08, 4'd05, 4'd08, 4'd08, 4'd08, 4'd06, 4'd08, 4'd08, 4'd09, 4'd05, 4'd08, 4'd08, 4'd09, 4'd04, 4'd07, 4'd07, 4'd08, 4'd06, 4'd08, 4'd08, 4'd09, 4'd05, 4'd08, 4'd08, 4'd08, 4'd05, 4'd08, 4'd08, 4'd09, 4'd05, 4'd08, 4'd08, 4'd08, 4'd05, 4'd08, 4'd08, 4'd09, 4'd05, 4'd08, 4'd08, 4'd09, 4'd03, 4'd05, 4'd05, 4'd06};

localparam logic [8:0] BITS_DC_Y  [12] = '{ 9'h004,  9'h000,  9'h001,  9'h005,  9'h006,  9'h00e,  9'h01e,  9'h03e,  9'h07e,  9'h0fe,  9'h1fe,  9'h1ff};
localparam logic [3:0] LENS_DC_Y  [12] = '{ 4'd003,  4'd002,  4'd002,  4'd003,  4'd003,  4'd004,  4'd005,  4'd006,  4'd007,  4'd008,  4'd009,  4'd009};

localparam logic [9:0] BITS_DC_UV [12] = '{10'h000, 10'h001, 10'h002, 10'h006, 10'h00e, 10'h01e, 10'h03e, 10'h07e, 10'h0fe, 10'h1fe, 10'h3fe, 10'h3ff};
localparam logic [3:0] LENS_DC_UV [12] = '{ 4'd002,  4'd002,  4'd002,  4'd003,  4'd004,  4'd005,  4'd006,  4'd007,  4'd008,  4'd009,  4'd010,  4'd010};

localparam logic [5:0] BITS_AC_0_3 [4][40] = '{
  '{6'h03, 6'h04, 6'h05, 6'h06, 6'h26, 6'h21, 6'h0a, 6'h1d, 6'h18, 6'h13, 6'h10, 6'h1a, 6'h19, 6'h18, 6'h17, 6'h1f, 6'h1e, 6'h1d, 6'h1c, 6'h1b, 6'h1a, 6'h19, 6'h18, 6'h17, 6'h16, 6'h15, 6'h14, 6'h13, 6'h12, 6'h11, 6'h10, 6'h18, 6'h17, 6'h16, 6'h15, 6'h14, 6'h13, 6'h12, 6'h11, 6'h10},    // runlen=0 , absvm1<40
  '{6'h03, 6'h06, 6'h25, 6'h0c, 6'h1b, 6'h16, 6'h15, 6'h1f, 6'h1e, 6'h1d, 6'h1c, 6'h1b, 6'h1a, 6'h19, 6'h13, 6'h12, 6'h11, 6'h10, 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 },    // runlen=1 , absvm1<18
  '{6'h05, 6'h04, 6'h0b, 6'h14, 6'h14, 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 },    // runlen=2 , absvm1<5
  '{6'h07, 6'h24, 6'h1c, 6'h13, 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 , 6'h0 }     // runlen=3 , absvm1<4
};

localparam logic [4:0] LENS_AC_0_3 [4][40] = '{
  '{5'd02, 5'd04, 5'd05, 5'd07, 5'd08, 5'd08, 5'd10, 5'd12, 5'd12, 5'd12, 5'd12, 5'd13, 5'd13, 5'd13, 5'd13, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd14, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15},
  '{5'd03, 5'd06, 5'd08, 5'd10, 5'd12, 5'd13, 5'd13, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15, 5'd15, 5'd16, 5'd16, 5'd16, 5'd16, 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 },
  '{5'd04, 5'd07, 5'd10, 5'd12, 5'd13, 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 },
  '{5'd05, 5'd08, 5'd12, 5'd13, 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 , 5'd0 }
};

localparam logic [5:0] BITS_AC_4_31 [32][3] = '{
  '{6'h0 , 6'h0 , 6'h0 },    // runlen=0 , unused
  '{6'h0 , 6'h0 , 6'h0 },    // runlen=1 , unused
  '{6'h0 , 6'h0 , 6'h0 },    // runlen=2 , unused
  '{6'h0 , 6'h0 , 6'h0 },    // runlen=3 , unused
  '{6'h06, 6'h0f, 6'h12},    // runlen=4 , absvm1<3
  '{6'h07, 6'h09, 6'h12},    // runlen=5 , absvm1<3
  '{6'h05, 6'h1e, 6'h14},    // runlen=6 , absvm1<3
  '{6'h04, 6'h15, 6'h0 },    // runlen=7 , absvm1<2
  '{6'h07, 6'h11, 6'h0 },    // runlen=8 , absvm1<2
  '{6'h05, 6'h11, 6'h0 },    // runlen=9 , absvm1<2
  '{6'h27, 6'h10, 6'h0 },    // runlen=10, absvm1<2
  '{6'h23, 6'h1a, 6'h0 },    // runlen=11, absvm1<2
  '{6'h22, 6'h19, 6'h0 },    // runlen=12, absvm1<2
  '{6'h20, 6'h18, 6'h0 },    // runlen=13, absvm1<2
  '{6'h0e, 6'h17, 6'h0 },    // runlen=14, absvm1<2
  '{6'h0d, 6'h16, 6'h0 },    // runlen=15, absvm1<2
  '{6'h08, 6'h15, 6'h0 },    // runlen=16, absvm1<2
  '{6'h1f, 6'h0 , 6'h0 },    // runlen=17, absvm1<1
  '{6'h1a, 6'h0 , 6'h0 },    // runlen=18, absvm1<1
  '{6'h19, 6'h0 , 6'h0 },    // runlen=19, absvm1<1
  '{6'h17, 6'h0 , 6'h0 },    // runlen=20, absvm1<1
  '{6'h16, 6'h0 , 6'h0 },    // runlen=21, absvm1<1
  '{6'h1f, 6'h0 , 6'h0 },    // runlen=22, absvm1<1
  '{6'h1e, 6'h0 , 6'h0 },    // runlen=23, absvm1<1
  '{6'h1d, 6'h0 , 6'h0 },    // runlen=24, absvm1<1
  '{6'h1c, 6'h0 , 6'h0 },    // runlen=25, absvm1<1
  '{6'h1b, 6'h0 , 6'h0 },    // runlen=26, absvm1<1
  '{6'h1f, 6'h0 , 6'h0 },    // runlen=27, absvm1<1
  '{6'h1e, 6'h0 , 6'h0 },    // runlen=28, absvm1<1
  '{6'h1d, 6'h0 , 6'h0 },    // runlen=29, absvm1<1
  '{6'h1c, 6'h0 , 6'h0 },    // runlen=30, absvm1<1
  '{6'h1b, 6'h0 , 6'h0 }     // runlen=31, absvm1<1
};

localparam logic [4:0] LENS_AC_4_31 [32][3] = '{
  '{5'd0 , 5'd0 , 5'd0 },
  '{5'd0 , 5'd0 , 5'd0 },
  '{5'd0 , 5'd0 , 5'd0 },
  '{5'd0 , 5'd0 , 5'd0 },
  '{5'd05, 5'd10, 5'd12},
  '{5'd06, 5'd10, 5'd13},
  '{5'd06, 5'd12, 5'd16},
  '{5'd06, 5'd12, 5'd0 },
  '{5'd07, 5'd12, 5'd0 },
  '{5'd07, 5'd13, 5'd0 },
  '{5'd08, 5'd13, 5'd0 },
  '{5'd08, 5'd16, 5'd0 },
  '{5'd08, 5'd16, 5'd0 },
  '{5'd08, 5'd16, 5'd0 },
  '{5'd10, 5'd16, 5'd0 },
  '{5'd10, 5'd16, 5'd0 },
  '{5'd10, 5'd16, 5'd0 },
  '{5'd12, 5'd0 , 5'd0 },
  '{5'd12, 5'd0 , 5'd0 },
  '{5'd12, 5'd0 , 5'd0 },
  '{5'd12, 5'd0 , 5'd0 },
  '{5'd12, 5'd0 , 5'd0 },
  '{5'd13, 5'd0 , 5'd0 },
  '{5'd13, 5'd0 , 5'd0 },
  '{5'd13, 5'd0 , 5'd0 },
  '{5'd13, 5'd0 , 5'd0 },
  '{5'd13, 5'd0 , 5'd0 },
  '{5'd16, 5'd0 , 5'd0 },
  '{5'd16, 5'd0 , 5'd0 },
  '{5'd16, 5'd0 , 5'd0 },
  '{5'd16, 5'd0 , 5'd0 },
  '{5'd16, 5'd0 , 5'd0 }
};






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function automatic logic [7:0] mean2 (input logic [7:0] a, input logic [7:0] b);
    return (8)'( ( 9'd1 + (9)'(a) + (9)'(b) ) >> 1 ) ;
endfunction


function automatic logic [7:0] mean4 (input logic [7:0] a, input logic [7:0] b, input logic [7:0] c, input logic [7:0] d);
    return (8)'( ( 10'd1 + (10)'(a) + (10)'(b) + (10)'(c) + (10)'(d) ) >> 2 ) ;
endfunction


function automatic logic [7:0] func_diff (input logic [7:0] a, input logic [7:0] b);
    return  (a>b) ? (a-b) : (b-a);
endfunction


function automatic logic signed [8:0] clip_neg255_pos255(input logic signed [27:0] x);
    return (x < -28'sd255) ? -9'sd255 : (x > 28'sd255) ? 9'sd255 : (9)'(x) ;
endfunction


function automatic logic [7:0] add_clip_0_255 (input logic [7:0] a, input logic signed [8:0] b);
    logic [9:0] c = b;
    c += $signed( (10)'(a) );
    return (c > 10'sd255) ? 8'd255 : (c < 10'sd0) ? 8'd0 : (8)'( $unsigned(c) ) ;
endfunction


function automatic logic [3:0] find_min_in_10_values (input logic [12:0] v0, input logic [12:0] v1, input logic [12:0] v2, input logic [12:0] v3, input logic [12:0] v4, input logic [12:0] v5, input logic [12:0] v6, input logic [12:0] v7, input logic [12:0] v8, input logic [12:0] v9 );
    logic        wi1, wi3, wi5, wi7, wi9;
    logic [12:0] w01, w23, w45, w67, w89;
    logic        xi23,      xi67;
    logic [12:0] x0123,    x4567;
    wi1 =       v1 < v0;
    w01 = wi1 ? v1 : v0;
    wi3 =       v3 < v2;
    w23 = wi3 ? v3 : v2;
    wi5 =       v5 < v4;
    w45 = wi5 ? v5 : v4;
    wi7 =       v7 < v6;
    w67 = wi7 ? v7 : v6;
    wi9 =       v9 < v8;
    w89 = wi9 ? v9 : v8;
    xi23  =        w23 < w01;
    x0123 = xi23 ? w23 : w01;
    xi67  =        w67 < w45;
    x4567 = xi67 ? w67 : w45;
    if( w89 <= x0123 && w89 <= x4567) begin
        return {3'b100, wi9};
    end else if(x0123 < x4567) begin
        if( xi23 )
            return {3'b001, wi3};
        else
            return {3'b000, wi1};
    end else begin
        if( xi67 )
            return {3'b011, wi7};
        else
            return {3'b010, wi5};
    end
endfunction


// inverse two dimensional DCT (Chen-Wang algorithm) stage 1: right multiply a matrix, act on each rows
function automatic logic [32*9-1:0] invserse_dct_rows_step12 (input logic signed [12:0] a0, input logic signed [12:0] a1, input logic signed [12:0] a2, input logic signed [12:0] a3, input logic signed [12:0] a4, input logic signed [12:0] a5, input logic signed [12:0] a6, input logic signed [12:0] a7 );
    logic signed [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8;
    x0 = a0;
    x1 = a4;
    x2 = a6;
    x3 = a2;
    x4 = a1;
    x5 = a7;
    x6 = a5;
    x7 = a3;
    x0 <<= 11;
    x1 <<= 11;
    x0[7] = 1'b1;                // x0 += 128 , for proper rounding in the fourth stage
    // step 1 ----------------------------------------------------------------------------------
    x8 = W7 * (x4+x5);
    x4 = x8 + (W1-W7) * x4;
    x5 = x8 - (W1+W7) * x5;
    x8 = W3 * (x6+x7);
    x6 = x8 - (W3-W5) * x6;
    x7 = x8 - (W3+W5) * x7;
    // step 2 ----------------------------------------------------------------------------------
    x8 = x0 + x1;
    x0 -= x1;
    x1 = W6 * (x3+x2);
    x2 = x1 - (W2+W6) * x2;
    x3 = x1 + (W2-W6) * x3;
    x1 = x4 + x6;
    x4 -= x6;
    x6 = x5 + x7;
    x5 -= x7;
    return {x0, x1, x2, x3, x4, x5, x6, x7, x8};
endfunction

function automatic logic [18*8-1:0] invserse_dct_rows_step34 (logic [32*9-1:0] x0_to_x8);
    logic signed [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8;
    {x0, x1, x2, x3, x4, x5, x6, x7, x8} = x0_to_x8;
    // step 3 ----------------------------------------------------------------------------------
    x7 = x8 + x3;
    x8 -= x3;
    x3 = x0 + x2;
    x0 -= x2;
    x2 = (32'sd181 * (x4+x5) + 32'sd128) >>> 8;
    x4 = (32'sd181 * (x4-x5) + 32'sd128) >>> 8;
    // step 4 ----------------------------------------------------------------------------------
    return { (18)'( (x7 + x1) >>> 8 ),
             (18)'( (x3 + x2) >>> 8 ),
             (18)'( (x0 + x4) >>> 8 ),
             (18)'( (x8 + x6) >>> 8 ),
             (18)'( (x8 - x6) >>> 8 ),
             (18)'( (x0 - x4) >>> 8 ),
             (18)'( (x3 - x2) >>> 8 ),
             (18)'( (x7 - x1) >>> 8 ) };
endfunction


// inverse two dimensional DCT (Chen-Wang algorithm) stage 2: left multiply a matrix, act on each columns
function automatic logic [32*9-1:0] invserse_dct_cols_step12 (input logic signed [17:0] a0, input logic signed [17:0] a1, input logic signed [17:0] a2, input logic signed [17:0] a3, input logic signed [17:0] a4, input logic signed [17:0] a5, input logic signed [17:0] a6, input logic signed [17:0] a7 );
    logic signed [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8;
    x0 = a0;
    x1 = a4;
    x2 = a6;
    x3 = a2;
    x4 = a1;
    x5 = a7;
    x6 = a5;
    x7 = a3;
    x0 <<= 8;
    x1 <<= 8;
    x0 += 32'sd8192;
    // step 1 ----------------------------------------------------------------------------------
    x8 = W7 * (x4+x5) + 32'sd4;
    x4 = (x8 + (W1-W7) * x4) >>> 3;
    x5 = (x8 - (W1+W7) * x5) >>> 3;
    x8 = W3 * (x6+x7) + 32'sd4;
    x6 = (x8 - (W3-W5) * x6) >>> 3;
    x7 = (x8 - (W3+W5) * x7) >>>3;
    // step 2 ----------------------------------------------------------------------------------
    x8 = x0 + x1;
    x0 -= x1;
    x1 = W6 * (x3+x2) + 32'sd4;
    x2 = (x1 - (W2+W6) * x2) >>> 3;
    x3 = (x1 + (W2-W6) * x3) >>> 3;
    x1 = x4 + x6;
    x4 -= x6;
    x6 = x5 + x7;
    x5 -= x7;
    return {x0, x1, x2, x3, x4, x5, x6, x7, x8};
endfunction

function automatic logic [9*8-1:0] invserse_dct_cols_step34(input logic [32*9-1:0] x0_to_x8);
    logic signed [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8;
    {x0, x1, x2, x3, x4, x5, x6, x7, x8} = x0_to_x8;
    // step 3 ----------------------------------------------------------------------------------
    x7 = x8 + x3;
    x8 -= x3;
    x3 = x0 + x2;
    x0 -= x2;
    x2 = (32'sd181 * (x4+x5) + 32'sd128) >>> 8;
    x4 = (32'sd181 * (x4-x5) + 32'sd128) >>> 8;
    // step 4 ----------------------------------------------------------------------------------
    return { clip_neg255_pos255( (x7+x1) >>> 14 ),
             clip_neg255_pos255( (x3+x2) >>> 14 ),
             clip_neg255_pos255( (x0+x4) >>> 14 ),
             clip_neg255_pos255( (x8+x6) >>> 14 ),
             clip_neg255_pos255( (x8-x6) >>> 14 ),
             clip_neg255_pos255( (x0-x4) >>> 14 ),
             clip_neg255_pos255( (x3-x2) >>> 14 ),
             clip_neg255_pos255( (x7-x1) >>> 14 ) };
endfunction





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage A : overall control, horizontal U/V subsample
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// overall configuration variables
reg          [       7:0] pframes_count;

wire         [  XB16-1:0] i_max_x16 = ( i_xsize16 > (XL+1)'(1<<XL) )  ?  (XL)'((1<<XL)-1)                :       // i_xsize16 larger than the upper bound
                                      ( i_xsize16 < (XL+1)'(4)     )  ?  (XL)'(3)                        :       // i_xsize16 smaller than the lower bound
                                                                         (XL)'( i_xsize16 - (XL+1)'(1) ) ;       // 

wire         [  YB16-1:0] i_max_y16 = ( i_ysize16 > (YL+1)'(1<<YL) )  ?  (YL)'((1<<YL)-1)                :       // i_ysize16 larger than the upper bound
                                      ( i_ysize16 < (YL+1)'(4)     )  ?  (YL)'(3)                        :       // i_ysize16 smaller than the lower bound
                                                                         (YL)'( i_ysize16 - (YL+1)'(1) ) ;       //

reg          [  XB16-1:0] max_x16;
reg          [  YB16-1:0] max_y16;

wire         [  XB8 -1:0] max_x8 = {max_x16, 1'b1};
wire         [  YB8 -1:0] max_y8 = {max_y16, 1'b1};
wire         [  XB4 -1:0] max_x4 = {max_x8 , 1'b1};
wire         [  YB4 -1:0] max_y4 = {max_y8 , 1'b1};
wire         [  XB2 -1:0] max_x2 = {max_x4 , 1'b1};
wire         [  YB2 -1:0] max_y2 = {max_y4 , 1'b1};
wire         [  XB  -1:0] max_x  = {max_x2 , 1'b1};
wire         [  YB  -1:0] max_y  = {max_y2 , 1'b1};

wire         [      11:0] size_x = (12)'(max_x) + 12'd1;
wire         [      11:0] size_y = (12)'(max_y) + 12'd1;

reg          [       7:0] a_i_frame;                                         // frame index in current GOP
reg          [   XB4-1:0] a_x4;
reg          [   YB -1:0] a_y ;
reg                       a_en;
reg          [       7:0] a_Y0, a_Y1, a_Y2, a_Y3;
reg          [       7:0] a_U0, a_U2, a_V0, a_V2;

reg                       sequence_start;
enum reg     [       1:0] {SEQ_IDLE, SEQ_DURING, SEQ_ENDING, SEQ_ENDED} sequence_state;

// overall control FSM of video sequence -------------------------------------------------------------
always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        pframes_count <= '0;
        max_x16 <= '0;
        max_y16 <= '0;
        a_i_frame <= '0;
        a_x4 <= '0;
        a_y  <= '0;
        a_en <= '0;
        {a_Y0, a_Y1, a_Y2, a_Y3} <= {8'h00, 8'h00, 8'h00, 8'h00};                                                      // default : black pixels
        {a_U0, a_U2, a_V0, a_V2} <= {8'h80, 8'h80, 8'h80, 8'h80};                                                      // default : black pixels
        sequence_start <= 1'b0;
        sequence_state <= SEQ_IDLE;
    end else begin                                                                                                     //
        sequence_start <= 1'b0;
        a_en <= 1'b0;                                                                                                  // default : don't transmit pixels
        {a_Y0, a_Y1, a_Y2, a_Y3} <= {8'h00, 8'h00, 8'h00, 8'h00};                                                      // default : black pixels
        {a_U0, a_U2, a_V0, a_V2} <= {8'h80, 8'h80, 8'h80, 8'h80};                                                      // default : black pixels
        if( sequence_state == SEQ_ENDED ) begin                                                                        // 
            if (o_last)
                sequence_state <= SEQ_IDLE;
        end else if( sequence_state == SEQ_ENDING ) begin                                                              // user required to stop the current sequence.
            if( a_x4 < max_x4 ) begin                                                                                  //   the current frame has not ended yet.
                a_x4 <= a_x4 + (XB4)'(1);                                                                              //
                a_en <= 1'b1;                                                                                          //     transmit black pixels to fill the un-ended frame
            end else if( a_y < max_y ) begin                                                                           //   the current frame has not ended yet.
                a_x4 <= '0;                                                                                            //
                a_y <= a_y + (YB)'(1);                                                                                 //
                a_en <= 1'b1;                                                                                          //     transmit black pixels to fill the un-ended frame
            end else begin                                                                                             //   the current frame has already ended.
                sequence_state <= SEQ_ENDED; ////////////////////////////////////////////////////////////              //     TODO: wait for the output stream's end, then let sequence_state<=SEQ_IDLE
            end                                                                                                        //
        end else if( i_en ) begin                                                                                      // user input a cycle of pixels
            if( sequence_state == SEQ_IDLE ) begin                                                                     //   if the video sequence is not yet started (i.e., this is the first cycle of a new video sequence)
                sequence_state <= SEQ_DURING;                                                                          //     start the video sequence
                sequence_start <= 1'b1;
                pframes_count <= i_pframes_count;                                                                      //     load configuration for the new video sequence
                max_x16 <= i_max_x16;                                                                                  //     load configuration for the new video sequence
                max_y16 <= i_max_y16;                                                                                  //     load configuration for the new video sequence
                a_x4 = '0;                                                                                             //     reset index
                a_y  = '0;                                                                                             //     reset index
                a_i_frame <= '0;                                                                                       //     reset index
            end else begin                                                                                             //   if the video sequence is already started
                if( a_x4 < max_x4 ) begin                                                                              //     update index
                    a_x4 <= a_x4 + (XB4)'(1);                                                                          //
                end else begin                                                                                         //
                    a_x4 <= '0;                                                                                        //
                    if( a_y < max_y ) begin                                                                            //
                        a_y <= a_y + (YB)'(1);                                                                         //
                    end else begin                                                                                     //
                        a_y <= '0;                                                                                     //
                        a_i_frame <= (a_i_frame < pframes_count) ? a_i_frame + 8'd1 : 8'd0;                            //
                    end                                                                                                //
                end                                                                                                    //
            end                                                                                                        //
            if( i_sequence_stop )                                                                                      //   user want to stop the current sequence
                sequence_state <= SEQ_ENDING;                                                                          //
            a_en <= 1'b1;                                                                                              //   transmit the user-inputted pixels
            {a_Y0, a_Y1, a_Y2, a_Y3} <= {i_Y0, i_Y1, i_Y2, i_Y3};                                                      //   Y
            a_U0 <= mean2(i_U0, i_U1);                                                                                 //   U0, U1 horizontal subsample to U0
            a_U2 <= mean2(i_U2, i_U3);                                                                                 //   U2, U3 horizontal subsample to U2
            a_V0 <= mean2(i_V0, i_V1);                                                                                 //   V0, V1 horizontal subsample to V0
            a_V2 <= mean2(i_V2, i_V3);                                                                                 //   V2, V3 horizontal subsample to V2
        end else if( i_sequence_stop && sequence_state == SEQ_DURING ) begin                                           // user want to stop the current sequence
            sequence_state <= SEQ_ENDING;                                                                              //
        end                                                                                                            //
    end                                                                                                                //

assign o_sequence_busy = (sequence_state != SEQ_IDLE) ;





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage B & C : Use line-buffer to vertical subsample U/V, convert to YUV 4:2:0
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [   2*8-1:0] mem_lbuf_U [XSIZE/4];                             // U line buffer: XSIZE/4 items, each item contains 2 U pixels
reg          [   2*8-1:0] mem_lbuf_V [XSIZE/4];                             // V line buffer: XSIZE/4 items, each item contains 2 V pixels

reg          [       7:0] b_i_frame;
reg          [   XB4-1:0] b_x4;
reg          [   YB -1:0] b_y ;
reg                       b_en;
reg          [       7:0] b_Y0, b_Y1, b_Y2, b_Y3;
reg          [       7:0] b_U0, b_U2, b_V0, b_V2;
reg          [       7:0] b_U0_u, b_U2_u, b_V0_u, b_V2_u;                   // readout U/V in upper row (previous row) from line-buffer. Not a real register

always @ (posedge clk)                                                      // write line-buffer
    if( a_en ) begin
        mem_lbuf_U[a_x4] <= {a_U0, a_U2};
        mem_lbuf_V[a_x4] <= {a_V0, a_V2};
    end

always @ (posedge clk) begin                                                // read line-buffer
    {b_U0_u, b_U2_u} <= mem_lbuf_U[a_x4];
    {b_V0_u, b_V2_u} <= mem_lbuf_V[a_x4];
end

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        b_i_frame <= '0;
        b_x4 <= '0;
        b_y  <= '0;
        b_en <= '0;
    end else begin
        b_i_frame <= a_i_frame;
        b_x4 <= a_x4;
        b_y  <= a_y;
        b_en <= a_en;
    end

always @ (posedge clk) begin
    {b_Y0, b_Y1, b_Y2, b_Y3} <= {a_Y0, a_Y1, a_Y2, a_Y3};
    {b_U0, b_U2, b_V0, b_V2} <= {a_U0, a_U2, a_V0, a_V2};
end

reg          [       7:0] c_i_frame;
reg          [   XB4-1:0] c_x4;
reg          [   YB -1:0] c_y ;
reg                       c_en;
reg          [       7:0] c_Y0, c_Y1, c_Y2, c_Y3;
reg          [       7:0] c_U0, c_U2, c_V0, c_V2;                           // Note that c_U0, c_U2, c_V0, c_V2 is only valid when c_y is odd, because of vertical subsample.

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        c_i_frame <= '0;
        c_x4 <= '0;
        c_y  <= '0;
        c_en <= '0;
    end else begin
        c_i_frame <= b_i_frame;
        c_x4 <= b_x4;
        c_y  <= b_y;
        c_en <= b_en;
    end

always @ (posedge clk) begin                                                // vertical subsample
    {c_Y0, c_Y1, c_Y2, c_Y3} <= {b_Y0, b_Y1, b_Y2, b_Y3};
    c_U0 <= mean2(b_U0, b_U0_u);
    c_U2 <= mean2(b_U2, b_U2_u);
    c_V0 <= mean2(b_V0, b_V0_u);
    c_V2 <= mean2(b_V2, b_V2_u);
end





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage D & E : double-buffer: buffer 2 slices
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [   4*8-1:0] mem_dbuf_Y [2 * 16 * (XSIZE/4)];                  // Y: double-buffer memory, 16 rows, XSIZE/4 cols, each item contains 4 Y-pixels
reg          [   2*8-1:0] mem_dbuf_U [2 *  8 * (XSIZE/4)];                  // U: double-buffer memory,  8 rows, XSIZE/4 cols, each item contains 2 U-pixels
reg          [   2*8-1:0] mem_dbuf_V [2 *  8 * (XSIZE/4)];                  // V: double-buffer memory,  8 rows, XSIZE/4 cols, each item contains 2 V-pixels

reg                       c_flip;                                    // double-buffer write control bit
reg                       d_flop;                                    // double-buffer read control bit, when c_flip != d_flop, double-buffer is available to read

reg          [       7:0] d_i_frame;
reg          [   XB4-1:0] d_x4  ;
reg          [  YB16-1:0] d_y16 ;
reg          [       3:0] d_y_16;                                      // 0~15, to loop through all rows in the block

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        d_i_frame <= '0;
        d_y16 <= '0;
        c_flip <= '0;
    end else begin
        if( c_en  &&  c_x4 == max_x4  &&  c_y[3:0] == 4'd15 ) begin         // end of a inputted row of block (16 rows of Y)
            d_i_frame <= c_i_frame;
            d_y16  <= c_y[YB-1:4];
            c_flip <= ~c_flip;                                              // flip the double-buffer
        end
    end

always @ (posedge clk)                                                      // write Y double-buffer in row-first order
    if( c_en )
        mem_dbuf_Y[ {c_flip, c_y[3:0], c_x4} ] <= {c_Y0, c_Y1, c_Y2, c_Y3};

always @ (posedge clk)                                                      // write U/V double-buffer in row-first order
    if( c_en & c_y[0] ) begin                                               // only write when c_y is odd
        mem_dbuf_U[ {c_flip, c_y[3:1], c_x4} ] <= {c_U0, c_U2};
        mem_dbuf_V[ {c_flip, c_y[3:1], c_x4} ] <= {c_V0, c_V2};
    end

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        d_y_16 <= '0;
        d_x4 <= '0;
        d_flop <= '0;
    end else begin                                                          // update the read index to read the double-buffer in column-first order.
        if( c_flip != d_flop ) begin                                        // when c_flip != d_flop, double-buffer is available to read, the valid read data will appear at next cycle
            d_y_16 <= d_y_16 + 4'd1;
            if(d_y_16 == 4'd15) begin
                if( d_x4 < max_x4 ) begin
                    d_x4 <= d_x4 + (XB4)'(1);
                end else begin
                    d_x4 <= '0;
                    d_flop <= ~d_flop;                                      // end of reading a row of block (16 rows of Y), flop the double-buffer
                end
            end
        end
    end

reg          [       7:0] e_i_frame;
reg          [  XB16-1:0] e_x16;
reg          [  YB16-1:0] e_y16;
reg                       e_start_blk;
reg                       e_en_blk   ;
reg                       e_Y_en  ;
reg                       e_UV_en ;
reg          [   4*8-1:0] e_Y_rd;                                            // Y double-buffer output: 4 adjacent values
reg          [   2*8-1:0] e_U_rd;                                            // U double-buffer output: 2 adjacent values
reg          [   2*8-1:0] e_V_rd;                                            // V double-buffer output: 2 adjacent values

always @ (posedge clk) begin                                                // read double-buffer in col-first order
    e_Y_rd <= mem_dbuf_Y [ {d_flop, d_y_16     , d_x4} ];
    e_U_rd <= mem_dbuf_U [ {d_flop, d_y_16[3:1], d_x4} ];
    e_V_rd <= mem_dbuf_V [ {d_flop, d_y_16[3:1], d_x4} ];
end


always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        e_i_frame <= '0;
        e_x16 <= '0;
        e_y16 <= '0;
        e_start_blk <= '0;
        e_en_blk    <= '0;
        e_Y_en      <= '0;
        e_UV_en     <= '0;
    end else begin
        e_i_frame <= d_i_frame;
        e_x16 <= (XB16)'(d_x4 >> 2);
        e_y16 <= d_y16;
        e_start_blk <= (c_flip != d_flop)  &&  d_x4[1:0] == 2'd0  &&  d_y_16 == 4'd0;      // start of a block (16x16 Y)
        e_en_blk    <= (c_flip != d_flop)  &&  d_x4[1:0] == 2'd3  &&  d_y_16 == 4'd15;     // end of a block (16x16 Y)
        e_Y_en      <= (c_flip != d_flop);
        e_UV_en     <= (c_flip != d_flop)  &&  d_y_16[0];
    end

// shift the double-buffer's output to get a new block
reg          [       7:0] e_Y_blk [16][16];
reg          [       7:0] e_U_blk [ 8][ 8];
reg          [       7:0] e_V_blk [ 8][ 8];

always @ (*) begin
    {e_Y_blk[15][12], e_Y_blk[15][13], e_Y_blk[15][14], e_Y_blk[15][15]} = e_Y_rd;
    {e_U_blk[7][6], e_U_blk[7][7]} = e_U_rd;
    {e_V_blk[7][6], e_V_blk[7][7]} = e_V_rd;
end

always @ (posedge clk) begin
    if( e_Y_en ) begin                                    // shift to save a block of Y (16x16 Y)
        for    (int x=0; x<16; x++)
            for(int y=0; y<15; y++)
                e_Y_blk[y][x] <= e_Y_blk[y+1][x];
        for(int x=0; x<12; x++)
            e_Y_blk[15][x] <= e_Y_blk[0][x+4];
    end
    if( e_UV_en ) begin                                   // shift to save a block of U/V (8x8 U and 8x8 V)
        for    (int x=0; x<8; x++)
            for(int y=0; y<7; y++) begin
                e_U_blk[y][x] <= e_U_blk[y+1][x];
                e_V_blk[y][x] <= e_V_blk[y+1][x];
            end
        for(int x=0; x<6; x++) begin
            e_U_blk[7][x] <= e_U_blk[0][x+2];
            e_V_blk[7][x] <= e_V_blk[0][x+2];
        end
    end
end





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage X & Y & Z : read reference frame memory
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [   8*8-1:0] mem_ref_Y  [ (YSIZE  ) * (XSIZE/8 )     ];   //   Y reference frame memory : (YSIZE  ) rows, XSIZE/8  cols                  , each item contains  8 Y pixels
reg          [   8*8-1:0] mem_ref_UV [ (YSIZE/2) * (XSIZE/16) * 2 ];   // U/V reference frame memory : (YSIZE/2) rows, XSIZE/16 cols, 2 channels (U/V), each item contains  8 U or V pixels

reg          [       4:0] x_cnt;
reg          [  XB16-1:0] x_x16;
logic        [  YB16-1:0] x_y16;                                       // temporary variable, not real register
reg                       x_x8_2;
reg          [    YB-1:0] x_y;

reg                       y_Y_en;
reg                       y_U_en;
reg                       y_V_en;

reg          [   8*8-1:0] y_Y_rd;
reg          [   8*8-1:0] y_UV_rd;

reg                       z_Y_en;
reg                       z_U_en;
reg                       z_V_en;

reg          [   8*8-1:0] z_Y_rd;
reg          [   8*8-1:0] z_UV_rd;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        y_Y_en <= 1'b0;
        y_U_en <= 1'b0;
        y_V_en <= 1'b0;
        x_x16  <= '0;
        x_y    <= '0;
        x_x8_2 <= '0;
        x_cnt  <= '1;
    end else begin                                                         // reference frame read control :
        y_Y_en <= 1'b0; 
        y_U_en <= 1'b0;
        y_V_en <= 1'b0;
        if(e_start_blk) begin                                              // when start to read a current block, start to read the reference blocks (whose position is at the right side of the current block)
            if          ( e_y16 == max_y16  &&  e_x16 == max_x16 ) begin   //   current block is at the bottom-right corner of the current image
                x_x16 <= (XB16)'(0);                                       //     the reference block to read is at the top-left corner of reference image
                x_y16  = (YB16)'(0);
            end else if ( e_x16 == max_x16 ) begin                         //   current block is the right-most block of the current image
                x_x16 <= (XB16)'(0);                                       //     the reference block to read is the left-most block in the next row
                x_y16  = e_y16 + (YB16)'(1);
            end else begin                                                 //   current block is NOT the right-most block of the current image
                x_x16 <= e_x16 + (XB16)'(1);                               //     the reference block to read is at the right side of the current block
                x_y16  = e_y16;
            end
            x_y    <= ((YB)'(x_y16) << 4) - (YB)'(YR);
            x_x8_2 <= '0;
            x_cnt  <= '0;
        end else if( x_cnt < (5)'(16+2*YR) ) begin                         // for each block, need to read YR+16+YR lines of Y
            if(x_x8_2) begin
                x_cnt <= x_cnt + 5'd1;
                x_y   <= x_y + (YB)'(1);
            end
            x_x8_2 <= ~x_x8_2;
            y_Y_en <= 1'b1;
            y_U_en <= ~x_y[0] & ~x_x8_2;
            y_V_en <= ~x_y[0] &  x_x8_2;
        end
    end

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        z_Y_en <= '0;
        z_U_en <= '0;
        z_V_en <= '0;
    end else begin
        z_Y_en <= y_Y_en;
        z_U_en <= y_U_en;
        z_V_en <= y_V_en;
    end

always @ (posedge clk) begin
    y_Y_rd  <= mem_ref_Y [ {x_y        , x_x16, x_x8_2} ] ;
    y_UV_rd <= mem_ref_UV[ {x_y[YB-1:1], x_x16, x_x8_2} ] ;
end

always @ (posedge clk) begin
    z_Y_rd  <= y_Y_rd;
    z_UV_rd <= y_UV_rd;
end

reg [7:0] z_Y_ref [-YR:16+YR-1] [16];
reg [7:0] z_U_ref [-UR: 8+UR-1] [ 8];
reg [7:0] z_V_ref [-UR: 8+UR-1] [ 8];

always @ (posedge clk) begin
    if(z_Y_en) begin
        for     (int x=0; x<8; x++) begin
            for (int y=-YR; y<16+YR; y++)
                z_Y_ref[y][x] <= z_Y_ref[y][x+8];
            for (int y=-YR; y<16+YR-1; y++)
                z_Y_ref[y][x+8] <= z_Y_ref[y+1][x];
            z_Y_ref[16+YR-1][x+8] <= z_Y_rd[x*8+:8];     // push the new data to the last item of z_Y_ref
        end
    end
    if(z_U_en) begin
        for     (int x=0; x<8; x++) begin
            for (int y=-UR; y<8+UR-1; y++)
                z_U_ref[y][x] <= z_U_ref[y+1][x];        // shift z_U_ref
            z_U_ref[8+UR-1][x] <= z_UV_rd[x*8+:8];       // push the new data to the last item of z_U_ref
        end
    end
    if(z_V_en) begin
        for     (int x=0; x<8; x++) begin
            for (int y=-UR; y<8+UR-1; y++)
                z_V_ref[y][x] <= z_V_ref[y+1][x];        // shift z_V_ref
            z_V_ref[8+UR-1][x] <= z_UV_rd[x*8+:8];       // push the new data to the last item of z_V_ref
        end
    end
end





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage F : motion estimation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [       7:0] f_i_frame;
reg          [  XB16-1:0] f_x16 ;
reg          [  YB16-1:0] f_y16 ;

reg          [      15:0] f_Y_sum ;
reg          [       7:0] f_Y_mean;

reg          [       7:0] f_Y_blk [16][16];                                // Y current block
reg          [       7:0] f_U_blk [ 8][ 8];                                // U current block
reg          [       7:0] f_V_blk [ 8][ 8];                                // V current block

reg          [       7:0] f_Y_ref [-YR:16+YR-1][-YR:16+16-1];              // Y reference
reg          [       7:0] f_U_ref [-UR: 8+UR-1][-UR:8+8-1];                // U reference
reg          [       7:0] f_V_ref [-UR: 8+UR-1][-UR:8+8-1];                // V reference

reg          [       7:0] f_Y_prd [16][16];                                // Y predicted block
reg          [       7:0] f_U_prd [-UR:8+UR-1][-UR:8+UR-1];                // U predicted block
reg          [       7:0] f_V_prd [-UR:8+UR-1][-UR:8+UR-1];                // V predicted block

reg          [       7:0] f_Y_tmp [-YR:16+YR-1][-YR:16+YR-1];              // Y temporary reference map for full pixel search
reg          [       7:0] f_Y_hlf [-1:31][-1:31];                          // Y temporary reference map for half pixel search

reg          [      11:0] f_diff  [-YR:YR][-YR:YR];                        // up: YR,  middle: 1,  down: YR.    left: YR,  middle: 1,  right: YR.    
reg                       f_over  [-YR:YR][-YR:YR];                        // 

reg   signed [       1:0] f_mvxh , f_mvyh;                       // -1, 0, +1
reg   signed [       4:0] f_mvx  , f_mvy;                       //
reg                       f_inter ;

reg                       f_en_blk ;

reg          [       3:0] f_cnt ;                                      // 0~15

enum reg     [       3:0]  {
    MV_IDLE , PREPARE_SEARCH_FULL, CALC_DIFF , CALC_MIN ,
    CALC_MOTION_VECTOR_Y , CALC_MOTION_VECTOR_X ,
    REF_SHIFT_Y , REF_SHIFT_X ,
    PREPARE_SEARCH_HALF , CALC_DIFF_HALF ,
    CALC_MIN_HALF1 , CALC_MIN_HALF2 ,
    REF_UV_SHIFT_Y , REF_UV_SHIFT_X , PREDICT
} f_stat ;

logic        [      11:0] diff ;                        // temporary variable, not real register
logic                     tmpbit1, tmpbit2 ;            // temporary variable, not real register


always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        f_en_blk <= 1'b0;
        f_cnt <= '0;
        f_stat <= MV_IDLE;
    end else begin
        f_en_blk <= 1'b0;
        f_cnt <= '0;
        
        case (f_stat)
            MV_IDLE : begin
                if(e_en_blk)
                    f_stat <= PREPARE_SEARCH_FULL;
            end
            
            PREPARE_SEARCH_FULL :
                f_stat <= CALC_DIFF;
            
            CALC_DIFF : begin
                if(f_cnt < 4'd15)
                    f_cnt  <= f_cnt + 4'd1;
                else
                    f_stat <= CALC_MIN;
            end
            
            CALC_MIN : begin
                if( f_cnt < 4'd5 )
                    f_cnt  <= f_cnt + 4'd1;
                else
                    f_stat <= CALC_MOTION_VECTOR_Y;
            end
            
            CALC_MOTION_VECTOR_Y :
                f_stat <= CALC_MOTION_VECTOR_X;
            
            CALC_MOTION_VECTOR_X :
                f_stat <= REF_SHIFT_Y;
            
            REF_SHIFT_Y : begin
                if(f_cnt < (4)'(YR-1) )
                    f_cnt  <= f_cnt + 4'd1;
                else
                    f_stat <= REF_SHIFT_X;
            end
            
            REF_SHIFT_X : begin
                if(f_cnt < (4)'(YR-1) )
                    f_cnt  <= f_cnt + 4'd1;
                else
                    f_stat <= PREPARE_SEARCH_HALF;
            end
            
            PREPARE_SEARCH_HALF :
                f_stat <= CALC_DIFF_HALF;
            
            CALC_DIFF_HALF : begin
                if(f_cnt < 4'd15)
                    f_cnt  <= f_cnt + 4'd1;
                else
                    f_stat <= CALC_MIN_HALF1;
            end
            
            CALC_MIN_HALF1 :
                f_stat <= CALC_MIN_HALF2;
            
            CALC_MIN_HALF2 :
                f_stat <= REF_UV_SHIFT_Y;
            
            REF_UV_SHIFT_Y : begin
                if(f_cnt < 4'd2)
                    f_cnt  <= f_cnt + 4'd1;
                else
                    f_stat <= REF_UV_SHIFT_X;
            end
            
            REF_UV_SHIFT_X : begin
                if(f_cnt < 4'd2)
                    f_cnt  <= f_cnt + 4'd1;
                else
                    f_stat <= PREDICT;
            end
            
            PREDICT : begin
                f_stat <= MV_IDLE;
                f_en_blk <= 1'b1;
            end
        endcase
    end


always @ (posedge clk)
    case(f_stat)
        
        // state: start, load current block and its reference --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        MV_IDLE : begin
            if(e_en_blk) begin
                f_i_frame <= e_i_frame;
                f_y16 <= e_y16;
                f_x16 <= e_x16;
            end
            
            f_Y_sum <= '0;
                
            for     (int y=0; y<16; y++)
                for (int x=0; x<16; x++)
                    f_Y_blk[y][x] <= e_Y_blk[y][x];            // load current Y block
                
            for     (int y=0; y<8; y++)
                for (int x=0; x<8; x++) begin
                    f_U_blk[y][x] <= e_U_blk[y][x];            // load current U block
                    f_V_blk[y][x] <= e_V_blk[y][x];            // load current V block
                end
            
            if(e_en_blk) begin
                for     (int y=-YR; y<16+YR; y++) begin
                    for (int x=-YR; x<16; x++)
                        f_Y_ref[y][x] <= f_Y_ref[y][x+16];         // left shift old Y reference 16 steps
                    for (int x=0; x<16; x++)
                        f_Y_ref[y][x+16] <= z_Y_ref[y][x];         // load new Y reference
                end
                    
                for     (int y=-UR; y<8+UR; y++) begin
                    for (int x=-UR; x<8   ; x++) begin
                        f_U_ref[y][x] <= f_U_ref[y][x+8];          // left shift old U reference by 8 steps
                        f_V_ref[y][x] <= f_V_ref[y][x+8];          // left shift old V reference by 8 steps
                    end
                    for (int x=0; x<8; x++) begin
                        f_U_ref[y][x+8] <= z_U_ref[y][x];          // load new U reference
                        f_V_ref[y][x+8] <= z_V_ref[y][x];          // load new V reference
                    end
                end
            end
        end
        
        // state: YR cycles --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        PREPARE_SEARCH_FULL : begin
            for     (int y=-YR; y<16+YR; y++)
                for (int x=-YR; x<16+YR; x++)
                    f_Y_tmp[y][x] <= f_Y_ref[y][x];                  // load f_Y_tmp from f_Y_ref : prepare for REF_SHIFT_Y
            
            for     (int y=-YR; y<=YR; y++)
                for (int x=-YR; x<=YR; x++) begin
                    f_diff[y][x] <= '0;                              // clear diff map
                    f_over[y][x] <=( (f_x16 == '0      && x<0 ) ||   // for left-most   block, disable the motion-vector that mvx<0,
                                     (f_x16 == max_x16 && x>0 ) ||   // for right-most  block, disable the motion-vector that mvx>0,
                                     (f_y16 == '0      && y<0 ) ||   // for top-most    block, disable the motion-vector that mvy<0,
                                     (f_y16 == max_y16 && y>0 ) );   // for bottom-most block, disable the motion-vector that mvy>0.
                end
        end
        
        // state: 16 cycles --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CALC_DIFF : begin
            for     (int y=0; y<16; y++)
                for (int x=0; x<16; x++)
                    f_Y_blk[y][x] <= f_Y_blk[y][(x+1)%16];             // cyclic left shift f_Y_blk by 1 step
            
            for     (int y=-YR; y<16+YR  ; y++)
                for (int x=-YR; x<16+YR-1; x++)
                    f_Y_tmp[y][x] <= f_Y_tmp[y][x+1];                  // left shift f_Y_tmp by 1 step
            
            diff = '0;
            for(int y=0; y<16; y++)
                diff += (12)'( f_Y_blk[y][0] );
            f_Y_sum <= f_Y_sum + (16)'(diff);                          // calculate sum of f_Y_blk
            
            for     (int y=-YR; y<=YR; y++)
                for (int x=-YR; x<=YR; x++) begin
                    diff = '0;
                    for (int yt=0; yt<16; yt++)
                        diff += (12)'( func_diff( f_Y_blk[yt][0] , f_Y_tmp[yt+y][x] ) );
                    if( ~f_over[y][x] )
                        {f_over[y][x], f_diff[y][x]} <= (13)'(f_diff[y][x]) + (13)'(diff) ;
                end
        end
        
        // state: 6 cycles --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CALC_MIN : begin
            tmpbit1 = 1'b1;
            for     (int y=-YR; y<=YR; y++)
                for (int x=-YR; x<=YR; x++)
                    tmpbit1 &= f_over[y][x] | f_diff[y][x][11] ;
            
            tmpbit2 = 1'b1;
            for     (int y=-YR; y<=YR; y++)
                for (int x=-YR; x<=YR; x++)
                    tmpbit2 &= f_over[y][x] | (f_diff[y][x][11] & ~tmpbit1) | f_diff[y][x][10] ;
            
            for     (int y=-YR; y<=YR; y++)
                for (int x=-YR; x<=YR; x++) begin
                    f_over[y][x] <= f_over[y][x] | (f_diff[y][x][11] & ~tmpbit1) | (f_diff[y][x][10] & ~tmpbit2);
                    f_diff[y][x] <= f_diff[y][x] << 2 ;
                end
        end
        
        // state: 1 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CALC_MOTION_VECTOR_Y : begin
            f_mvy <= '0;
            for     (int y=-YR; y<=YR; y++) begin
                tmpbit1 = 1'b1;
                for (int x=-YR; x<=YR; x++)
                    tmpbit1 &= f_over[y][x] ;
                if( ~tmpbit1 )
                    f_mvy <= (5)'(y);                   // use f_over to get the y of motion vector's x
            end
        end
        
        // state: 1 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CALC_MOTION_VECTOR_X : begin
            f_mvx <= '0;
            for (int x=-YR; x<=YR; x++)
                if( ~f_over[f_mvy][x] )
                    f_mvx <= (5)'(x);                   // use f_over to get the x of motion vector's x
            
            for     (int y=-YR; y<16+YR; y++)
                for (int x=-YR; x<16+YR; x++)
                    f_Y_tmp[y][x] <= f_Y_ref[y][x];     // load f_Y_tmp from f_Y_ref : prepare for REF_SHIFT_Y
        end
        
        
        // state: YR cycles --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        REF_SHIFT_Y : begin
            if      ( f_mvy > 5'sd0  &&  (5)'(f_cnt) < $unsigned( f_mvy) )      // up shift Y
                for     (int y=0  ; y<16+YR; y++)                               // needn't to shift the pixels of y<-1, since they are discarded
                    for (int x=-YR; x<16+YR; x++)
                        f_Y_tmp[y-1][x] <= f_Y_tmp[y][x] ;
            else if ( f_mvy < 5'sd0  &&  (5)'(f_cnt) < $unsigned(-f_mvy) )      // down shift Y
                for     (int y=-YR; y<16   ; y++)                               // needn't to shift the pixels of y>16, since they are discarded
                    for (int x=-YR; x<16+YR; x++)
                        f_Y_tmp[y+1][x] <= f_Y_tmp[y][x] ;
        end
        
        // state: YR cycles --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        REF_SHIFT_X : begin
            if      ( f_mvx > 5'sd0  &&  (5)'(f_cnt) < $unsigned( f_mvx) )      // left shift Y
                for     (int y=-1; y<=16  ; y++)                                // needn't to shift the pixels of y<-1 and y>16, since they are discarded
                    for (int x=0 ; x<16+YR; x++)                                // needn't to shift the pixels of x<-1, since they are discarded
                        f_Y_tmp[y][x-1] <= f_Y_tmp[y][x] ;
            else if ( f_mvx < 5'sd0  &&  (5)'(f_cnt) < $unsigned(-f_mvx) )      // right shift Y
                for     (int y=-1; y<=16; y++)                                  // needn't to shift the pixels of y<-1 and y>16, since they are discarded
                    for (int x=-YR; x<16; x++)                                  // needn't to shift the pixels of x>16, since they are discarded
                        f_Y_tmp[y][x+1] <= f_Y_tmp[y][x] ;
        end
        
        // state: 1 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        PREPARE_SEARCH_HALF : begin
            f_Y_mean <= f_Y_sum[15:8];
            
            for    (int y=-1; y<16; y++)
                for(int x=-1; x<16; x++) begin
                    if(-2<y*2   && -2<x*2  ) f_Y_hlf[y*2  ][x*2  ] <=        f_Y_tmp[y][x];
                    if(-2<y*2   && -2<x*2+1) f_Y_hlf[y*2  ][x*2+1] <= mean2( f_Y_tmp[y][x], f_Y_tmp[y][x+1] );
                    if(-2<y*2+1 && -2<x*2  ) f_Y_hlf[y*2+1][x*2  ] <= mean2( f_Y_tmp[y][x], f_Y_tmp[y+1][x] );
                    if(-2<y*2+1 && -2<x*2+1) f_Y_hlf[y*2+1][x*2+1] <= mean4( f_Y_tmp[y][x], f_Y_tmp[y][x+1], f_Y_tmp[y+1][x], f_Y_tmp[y+1][x+1] );
                end
            
            for     (int y=-1; y<=1; y++)
                for (int x=-1; x<=1; x++) begin
                    f_diff[y][x] <= '0;
                    f_over[y][x] <=( ( (f_x16 == '0      || f_mvx == (5)'(-YR) ) && x<0 ) ||
                                     ( (f_x16 == max_x16 || f_mvx == (5)'( YR) ) && x>0 ) ||
                                     ( (f_y16 == '0      || f_mvy == (5)'(-YR) ) && y<0 ) ||
                                     ( (f_y16 == max_y16 || f_mvy == (5)'( YR) ) && y>0 ) );
                end
        end
        
        // state: 16 cycles --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CALC_DIFF_HALF : begin
            for    (int y=0; y<16; y++)
                for(int x=0; x<16; x++)
                    f_Y_blk[y][x] <= f_Y_blk[y][(x+1)%16];               // cyclic left shift f_Y_blk by 1 step
            
            for    (int y=-1; y<32; y++)
                for(int x=-1; x<30; x++)
                    f_Y_hlf[y][x] <= f_Y_hlf[y][x+2];                    // left shift f_Y_hlf by 2 steps
            
            diff = '0;
            for(int y=0; y<16; y++)
                diff += (12)'( func_diff( f_Y_blk[y][0] , f_Y_mean ) );
            f_Y_sum <= f_Y_sum + (16)'(diff);                            // calculate diff of f_Y_blk and f_Y_mean
            
            for     (int y=-1; y<=1; y++)
                for (int x=-1; x<=1; x++) begin
                    diff = '0;
                    for (int yt=0; yt<16; yt++)
                        diff += (12)'( func_diff( f_Y_blk[yt][0] , f_Y_hlf[y+2*yt][x] ) );
                    if( ~f_over[y][x] )
                        {f_over[y][x], f_diff[y][x]} <= (13)'(f_diff[y][x]) + (13)'(diff) ;
                end
        end
        
        // state: 1 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CALC_MIN_HALF1 : begin
            diff = (f_Y_sum[15:12] == '0) ? f_Y_sum[11:0] : 12'hfff;
            
            // find min value in f_diff (a faster way)
            case( find_min_in_10_values(
                    { f_over[-1][-1], f_diff[-1][-1] },
                    { f_over[-1][ 0], f_diff[-1][ 0] },
                    { f_over[-1][ 1], f_diff[-1][ 1] },
                    { f_over[ 0][-1], f_diff[ 0][-1] },
                    { f_over[ 0][ 0], f_diff[ 0][ 0] },
                    { f_over[ 0][ 1], f_diff[ 0][ 1] },
                    { f_over[ 1][-1], f_diff[ 1][-1] },
                    { f_over[ 1][ 0], f_diff[ 1][ 0] },
                    { f_over[ 1][ 1], f_diff[ 1][ 1] },
                    {           1'b0, diff           }  ) )
                4'd0    : begin  f_mvyh <= -2'sd1;  f_mvxh <= -2'sd1;  f_inter <= 1'b1;  end
                4'd1    : begin  f_mvyh <= -2'sd1;  f_mvxh <=  2'sd0;  f_inter <= 1'b1;  end
                4'd2    : begin  f_mvyh <= -2'sd1;  f_mvxh <=  2'sd1;  f_inter <= 1'b1;  end
                4'd3    : begin  f_mvyh <=  2'sd0;  f_mvxh <= -2'sd1;  f_inter <= 1'b1;  end
                4'd4    : begin  f_mvyh <=  2'sd0;  f_mvxh <=  2'sd0;  f_inter <= 1'b1;  end
                4'd5    : begin  f_mvyh <=  2'sd0;  f_mvxh <=  2'sd1;  f_inter <= 1'b1;  end
                4'd6    : begin  f_mvyh <=  2'sd1;  f_mvxh <= -2'sd1;  f_inter <= 1'b1;  end
                4'd7    : begin  f_mvyh <=  2'sd1;  f_mvxh <=  2'sd0;  f_inter <= 1'b1;  end
                4'd8    : begin  f_mvyh <=  2'sd1;  f_mvxh <=  2'sd1;  f_inter <= 1'b1;  end
                default : begin  f_mvyh <=  2'sd0;  f_mvxh <=  2'sd0;  f_inter <= 1'b0;  end
            endcase
        end
        
        // state: 1 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CALC_MIN_HALF2 : begin
            if( f_i_frame == '0 ) begin                                         // I-frame
                f_inter <= 1'b0;
                f_mvyh <= '0;
                f_mvxh <= '0;
                f_mvy  <= '0;
                f_mvx  <= '0;
            end else begin                                                      // P-frame
                f_mvy  <= (f_mvy << 1) + f_mvyh;
                f_mvx  <= (f_mvx << 1) + f_mvxh;
            end
            
            for    (int y=-1; y<16; y++)
                for(int x=-1; x<16; x++) begin
                    if(-2<y*2   && -2<x*2  ) f_Y_hlf[y*2  ][x*2  ] <=        f_Y_tmp[y][x];
                    if(-2<y*2   && -2<x*2+1) f_Y_hlf[y*2  ][x*2+1] <= mean2( f_Y_tmp[y][x], f_Y_tmp[y][x+1] );
                    if(-2<y*2+1 && -2<x*2  ) f_Y_hlf[y*2+1][x*2  ] <= mean2( f_Y_tmp[y][x], f_Y_tmp[y+1][x] );
                    if(-2<y*2+1 && -2<x*2+1) f_Y_hlf[y*2+1][x*2+1] <= mean4( f_Y_tmp[y][x], f_Y_tmp[y][x+1], f_Y_tmp[y+1][x], f_Y_tmp[y+1][x+1] );
                end
            
            for     (int y=-UR; y<8+UR; y++)
                for (int x=-UR; x<8+UR; x++) begin
                    f_U_prd[y][x] <= f_U_ref[y][x] ;
                    f_V_prd[y][x] <= f_V_ref[y][x] ;
                end
        end
        
        // state: 3 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        REF_UV_SHIFT_Y : begin
            if( f_cnt == 4'd0 && f_mvyh >= 2'sd0  ||  f_cnt == 4'd1 && f_mvyh >= 2'sd1 ) begin    // up shift Y-half (f_Y_hlf)
                for    (int y=-1; y<31; y++)
                    for(int x=-1; x<32; x++)
                        f_Y_hlf[y][x] <= f_Y_hlf[y+1][x]; 
            end
            
            if      ( f_mvy > 5'sd0  &&  (5)'(f_cnt) < $unsigned(  f_mvy>>>2 ) )    // up shift U/V
                for     (int y=1  ; y<8+UR; y++)                                    // needn't to shift the pixels of y<0, since they are discarded
                    for (int x=-UR; x<8+UR; x++) begin
                        f_U_prd[y-1][x] <= f_U_prd[y][x] ;
                        f_V_prd[y-1][x] <= f_V_prd[y][x] ;
                    end
            else if ( f_mvy < 5'sd0  &&  (5)'(f_cnt) < $unsigned(-(f_mvy>>>2)) )    // down shift V/V
                for     (int y=-UR; y<8   ; y++)                                    // needn't to shift the pixels of y>8 , since they are discarded
                    for (int x=-UR; x<8+UR; x++) begin
                        f_U_prd[y+1][x] <= f_U_prd[y][x] ;
                        f_V_prd[y+1][x] <= f_V_prd[y][x] ;
                    end
        end
        
        // state: 3 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        REF_UV_SHIFT_X : begin
            if( f_cnt == 4'd0 && f_mvxh >= 2'sd0  ||  f_cnt == 4'd1 && f_mvxh >= 2'sd1 ) begin    // left shift Y-half (f_Y_hlf)
                for    (int y=-1; y<30; y++)                                        // needn't to shift y>=30, since they are discarded
                    for(int x=-1; x<31; x++)
                        f_Y_hlf[y][x] <= f_Y_hlf[y][x+1];
            end
            
            if      ( f_mvx > 5'sd0  &&  (5)'(f_cnt) < $unsigned(  f_mvx>>>2 ) )    // left shift U/V
                for     (int y=0; y<=8  ; y++)                                      // needn't to shift the pixels of y<0 and y>8, since they are discarded
                    for (int x=1; x<8+UR; x++) begin                                // needn't to shift the pixels of x<0, since they are discarded
                        f_U_prd[y][x-1] <= f_U_prd[y][x] ;
                        f_V_prd[y][x-1] <= f_V_prd[y][x] ;
                    end
            else if ( f_mvx < 5'sd0  &&  (5)'(f_cnt) < $unsigned(-(f_mvx>>>2)) )    // right shift U/V
                for     (int y=0; y<=8 ; y++)                                       // needn't to shift the pixels of y<0 and y>8, since they are discarded
                    for (int x=-UR; x<8; x++) begin                                 // needn't to shift the pixels of x>8, since they are discarded
                        f_U_prd[y][x+1] <= f_U_prd[y][x] ;
                        f_V_prd[y][x+1] <= f_V_prd[y][x] ;
                    end
        end
        
        // state: 1 cycle --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        PREDICT : begin
            for     (int y=0; y<16; y++)
                for (int x=0; x<16; x++)
                    if ( ~f_inter )
                        f_Y_prd[y][x] <= 8'h80;
                    else
                        f_Y_prd[y][x] <= f_Y_hlf[2*y-1][2*x-1];
                    
            for     (int y=0; y<8; y++)
                for (int x=0; x<8; x++)
                    if( ~f_inter ) begin
                        f_U_prd[y][x] <= 8'h80;
                        f_V_prd[y][x] <= 8'h80;
                    end else if ( ((f_mvy>>>1) & 1)  &  ((f_mvx>>>1) & 1) ) begin
                        f_U_prd[y][x] <= mean4( f_U_prd[y][x], f_U_prd[y][x+1], f_U_prd[y+1][x], f_U_prd[y+1][x+1] ) ;
                        f_V_prd[y][x] <= mean4( f_V_prd[y][x], f_V_prd[y][x+1], f_V_prd[y+1][x], f_V_prd[y+1][x+1] ) ;
                    end else if ( (f_mvx>>>1) & 1 ) begin
                        f_U_prd[y][x] <= mean2( f_U_prd[y][x], f_U_prd[y][x+1] ) ;
                        f_V_prd[y][x] <= mean2( f_V_prd[y][x], f_V_prd[y][x+1] ) ;
                    end else if ( (f_mvy>>>1) & 1 ) begin
                        f_U_prd[y][x] <= mean2( f_U_prd[y][x], f_U_prd[y+1][x] ) ;
                        f_V_prd[y][x] <= mean2( f_V_prd[y][x], f_V_prd[y+1][x] ) ;
                    end else begin
                        f_U_prd[y][x] <= f_U_prd[y][x];
                        f_V_prd[y][x] <= f_V_prd[y][x];
                    end
        end
    endcase





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage G : DCT, including phase 1 (right multiply DCT_MATRIX_transposed) and phase 2 (left multiply DCT_MATRIX), then quantize.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [       5:0] g_cnt;

reg          [       7:0] g_i_frame;
reg          [  XB16-1:0] g_x16;
reg          [  YB16-1:0] g_y16;
reg                       g_inter;
reg   signed [       4:0] g_mvx , g_mvy ;

reg          [       7:0] g_tiles_prd [48][8];            // predicted tiles of current block : Y00, Y01, Y10, Y11, U, V
reg   signed [       8:0] g_tiles     [48][8];            // residual  tiles of current block : Y00, Y01, Y10, Y11, U, V

reg   signed [ 18+DCTP:0] g_dct_res1  [8][8];             // 21 bits = 9+10+3-1
reg   signed [ 18+DCTP:0] g_dct_res2  [8][8];             // 21 bits
reg   signed [      16:0] g_dct_res3  [8][8];             // 17 bits = 21+10+3-1-16
reg   signed [      11:0] g_quant     [8][8];             // 12 bits

reg                       g_en_tile  ;
reg          [       2:0] g_num_tile ;

logic signed [ 18+DCTP:0] g_t1;                           // temporary variable not real register
logic signed [28+2*DCTP:0] g_t2;                          // temporary variable not real register
logic        [      15:0] g_t3;                           // temporary variable not real register


always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        g_cnt <= '0;
        g_en_tile  <= 1'b0;
        g_num_tile <= '0;
    end else begin
        if( f_en_blk )
            g_cnt <= 6'd1;
        else if (g_cnt != '0)
            g_cnt <= g_cnt + 6'd1;
        
        g_en_tile  <= 1'b0;
        if( g_cnt == 6'd18 || g_cnt == 6'd26 || g_cnt == 6'd34 || g_cnt == 6'd42 || g_cnt == 6'd50 || g_cnt == 6'd58 ) begin
            g_en_tile  <= 1'b1;
            g_num_tile <= g_cnt[5:3] - 3'd2;       // 0->Y00   1->Y01   2->Y10   3->Y11   4->U   5->V
        end
    end


always @ (posedge clk)
    if( f_en_blk ) begin
        g_i_frame <= f_i_frame;
        g_y16 <= f_y16;
        g_x16 <= f_x16;
        g_inter <= f_inter;
        g_mvx <= f_mvx;
        g_mvy <= f_mvy;
        
        for     (int y=0; y<8 ; y++)
            for (int x=0; x<8 ; x++) begin
                g_tiles_prd[y   ][x  ] <= f_Y_prd[y][x];
                g_tiles    [y   ][x  ] <= $signed( (9)'(f_Y_blk[y][x]) ) - $signed( (9)'(f_Y_prd[y][x]) );
            end
        
        for     (int y=0; y<8 ; y++)
            for (int x=8; x<16; x++) begin
                g_tiles_prd[y+8 ][x-8] <= f_Y_prd[y][x];
                g_tiles    [y+8 ][x-8] <= $signed( (9)'(f_Y_blk[y][x]) ) - $signed( (9)'(f_Y_prd[y][x]) );
            end
        
        for     (int y=8; y<16; y++)
            for (int x=0; x<8 ; x++) begin
                g_tiles_prd[y+8 ][x  ] <= f_Y_prd[y][x];
                g_tiles    [y+8 ][x  ] <= $signed( (9)'(f_Y_blk[y][x]) ) - $signed( (9)'(f_Y_prd[y][x]) );
            end
        
        for     (int y=8; y<16; y++)
            for (int x=8; x<16; x++) begin
                g_tiles_prd[y+16][x-8] <= f_Y_prd[y][x];
                g_tiles    [y+16][x-8] <= $signed( (9)'(f_Y_blk[y][x]) ) - $signed( (9)'(f_Y_prd[y][x]) );
            end
        
        for     (int y=0; y<8; y++)
            for (int x=0; x<8; x++) begin
                g_tiles_prd[y+32][x  ] <= f_U_prd[y][x];
                g_tiles    [y+32][x  ] <= $signed( (9)'(f_U_blk[y][x]) ) - $signed( (9)'(f_U_prd[y][x]) );
            end
        
        for     (int y=0; y<8; y++)
            for (int x=0; x<8; x++) begin
                g_tiles_prd[y+40][x  ] <= f_V_prd[y][x];
                g_tiles    [y+40][x  ] <= $signed( (9)'(f_V_blk[y][x]) ) - $signed( (9)'(f_V_prd[y][x]) );
            end
            
    end else begin
        for     (int x=0; x<8 ; x++) begin
            for (int y=0; y<47; y++)
                g_tiles[y][x] <= g_tiles[y+1][x];              // up shift g_tiles
            g_tiles[47][x] <= '0;
        end
    end


always @ (posedge clk) begin
    // DCT phase 1 : right multiply DCT_MATRIX_transposed
    // calculate when      g_cnt = 1~8, 9~16, 17~24, 25~32, 33~40, 41~48
    // produce result when g_cnt =   9,   17,    25,    33,    41,    49
    for (int j=0; j<8; j++) begin
        g_t1 = '0;
        for (int k=0; k<8; k++) 
            g_t1 += g_tiles[0][k] * DCT_MATRIX[j][k];          // Note that DCT_MATRIX [j][k] == DCT_MATRIX_transposed [k][j]
        g_dct_res1[7][j] <= g_t1;                              // push the DCT phase 1 result to the last row of g_dct_res1
        for (int i=0; i<7; i++)
            g_dct_res1[i][j] <= g_dct_res1[i+1][j];            // up shift g_dct_res1
    end
    
    // save the 8x8 result of DCT phase 1
    if( g_cnt == 6'd9 || g_cnt == 6'd17 || g_cnt == 6'd25 || g_cnt == 6'd33 || g_cnt == 6'd41 || g_cnt == 6'd49 ) begin
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++)
                g_dct_res2[i][j] <= g_dct_res1[i][j] ;         // save the 8x8 result of DCT phase 1 to g_dct_res2
    end else begin
        for (int i=0; i<8; i++) begin
            for (int j=0; j<7; j++)
                g_dct_res2[i][j] <= g_dct_res2[i][j+1];        // left shift g_dct_res2
            g_dct_res2[i][7] <= '0;
        end
    end
    
    // DCT phase 2 : left multiply DCT_MATRIX
    // calculate when      g_cnt = 10~17, 18~25, 26~33, 34~41, 42~49, 50~57
    // produce result when g_cnt =    18,    26,    34,    42,    50,    58
    for (int i=0; i<8; i++) begin
        g_t2 = '0;
        for(int k=0; k<8; k++)
            g_t2 += DCT_MATRIX[i][k] * g_dct_res2[k][0];
        g_t2 = (g_t2>>>(12+2*DCTP)) + g_t2[11+2*DCTP];                                        // 
        g_dct_res3[i][7] <= $signed((17)'(g_t2));                                             // push the DCT phase 2 result to the last column of g_dct_res3. = (g_t2 + 32768) / 65536
        for(int j=0; j<7; j++)
            g_dct_res3[i][j] <= g_dct_res3[i][j+1];                                           // left shift g_dct_res3
    end
    
    // save the 8x8 result of DCT phase 2, and do quantize by-the-way
    if( g_cnt == 6'd18 || g_cnt == 6'd26 || g_cnt == 6'd34 || g_cnt == 6'd42 || g_cnt == 6'd50 || g_cnt == 6'd58 )
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++) begin
                g_t3 = (16)'( (g_dct_res3[i][j] < 0) ? -g_dct_res3[i][j] : g_dct_res3[i][j] );             // y = abs(x)
                if( g_inter )                                                                              // inter block
                    g_t3 =   (g_t3 + 16'd2) >> (4 + Q_LEVEL);                                              //   y = (y+2) / 16 / (1<<Q_LEVEL)
                else if( i!=0 || j!=0 )                                                                    // intra block, AC value
                    g_t3 = ( (g_t3 + ((INTRA_Q[i][j]*((3<<Q_LEVEL)+2))>>3) ) >> Q_LEVEL ) / INTRA_Q[i][j]; //   y = ( y + (INTRA_Q*((3<<Q_LEVEL)+2)>>3) ) / (1<<Q_LEVEL) / INTRA_Q
                else                                                                                       // intra block, DC value
                    g_t3 = (g_t3>>4) + (16)'( g_t3[3] ) ;                                                  //   y = (y/8 + 1) / 2
                if( g_t3 > 16'd2047 ) g_t3 = 16'd2047;                                                     // clip(y, 0, 2047)
                g_quant[i][j] <= (g_dct_res3[i][j] < 0) ? -$signed((12)'(g_t3)) : $signed((12)'(g_t3));    // x = (y<0) ? -x : x;
            end
end





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage H & J : inverse quantize, inverse DCT phase 1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [       2:0] h_num_tile;
reg                       h_en  ;
reg          [       2:0] h_cnt ;
reg   signed [      12:0] h_iquant [8][8];             // 13 bit

logic signed [      16:0] h_t1;                        // not real register

reg                       j1_en ;
reg          [       2:0] j1_num_tile ;
reg                       j1_en_tile ;
reg          [  32*9-1:0] j1_idct_x0_to_x8;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        h_en <= 1'b0;
        h_cnt <= '0;
        h_num_tile <= '0;
        j1_en <= '0;
        j1_num_tile <= '0;
        j1_en_tile <= 1'b0;
    end else begin
        j1_en_tile <= 1'b0;
        if (g_en_tile) begin
            h_en <= 1'b1;
            h_cnt <= '0;
            h_num_tile <= g_num_tile;
        end else begin
            h_cnt <= h_cnt + 3'd1;
            if(h_cnt == '1)
                h_en <= 1'b0;
        end
        j1_en <= h_en;
        if(h_en) begin
            if(h_cnt == '1) begin
                j1_en_tile  <= 1'b1;
                j1_num_tile <= h_num_tile;
            end
        end
    end

always @ (posedge clk)
    if(g_en_tile) begin
        for (int i=0; i<8; i++) begin
            for (int j=0; j<8; j++) begin
                h_t1 = g_quant[i][j];                                                                      // inverse quantize
                if( g_inter ) begin                                                                        // inter block
                    h_t1 <<= 1;                                                                            //   x *= 2
                    h_t1 += (h_t1<0) ? -17'sd1 : (h_t1>0) ? 17'sd1 : 17'sd0 ;                              //   x += sign(x)
                    h_t1 <<= (17)'(Q_LEVEL);                                                               //   x *= (1<<Q_LEVEL)
                    h_t1 = (h_t1 < -17'sd2047) ? -17'sd2047 : (h_t1 > 17'sd2047) ? 17'sd2047 : h_t1;       //   clip(x, -2047, 2047)
                end else if( i!=0 || j!=0 ) begin                                                          // intra block, AC value
                    h_t1 *= INTRA_Q[i][j];                                                                 //   x *= INTRA_Q
                    if( Q_LEVEL >= 3 )                                                                     //   x = x * (1<<Q_LEVEL) / 8
                        h_t1 <<=  (17)'(Q_LEVEL - 3);                                                      //
                    else                                                                                   //
                        h_t1 >>>= (17)'(3 - Q_LEVEL);                                                      //
                    h_t1 = (h_t1 < -17'sd2047) ? -17'sd2047 : (h_t1 > 17'sd2047) ? 17'sd2047 : h_t1;       //   clip(x, -2047, 2047)
                end else begin                                                                             // intra block, DC value
                    h_t1 <<= 1;                                                                            //   x *= 2
                end
                h_iquant[i][j] <= (13)'(h_t1);
            end
        end
    end else begin
        for (int j=0; j<8; j++) begin
            for (int i=0; i<7; i++)
                h_iquant[i][j] <= h_iquant[i+1][j];               // up shift h_iquant by 1 step
            h_iquant[7][j] <= '0;
        end
    end
    
always @ (posedge clk)
    if(h_en)                                                      // inverse DCT
        j1_idct_x0_to_x8 <= invserse_dct_rows_step12(h_iquant[0][0], h_iquant[0][1], h_iquant[0][2], h_iquant[0][3], h_iquant[0][4], h_iquant[0][5], h_iquant[0][6], h_iquant[0][7]);




// divide invserse_dct_rows to 2 pipeline stages : for better timing -----------------------------------------------------------------------------------------

reg          [       2:0] j_num_tile;
reg                       j_en_tile ;
reg   signed [      17:0] j_idct_res1 [8][8];

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        j_num_tile <= '0;
        j_en_tile <= '0;
    end else begin
        if (j1_en) begin
            j_num_tile <= j1_num_tile;
            j_en_tile <= j1_en_tile;
        end
    end

always @ (posedge clk)
    if (j1_en) begin
        {j_idct_res1[7][0], j_idct_res1[7][1], j_idct_res1[7][2], j_idct_res1[7][3], j_idct_res1[7][4], j_idct_res1[7][5], j_idct_res1[7][6], j_idct_res1[7][7]} <= invserse_dct_rows_step34(j1_idct_x0_to_x8);
        for (int i=0; i<7; i++)
            for (int j=0; j<8; j++)
                j_idct_res1[i][j] <= j_idct_res1[i+1][j];         // up shift j_idct_res1 by 1 step
    end






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage K & M : inverse DCT phase 2
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [       2:0] k_num_tile;
reg                       k_en ;
reg          [       2:0] k_cnt;
reg   signed [      17:0] k_idct_res2 [8][8];

reg                       m1_en;
reg                       m1_idct_en3;
reg          [       2:0] m1_num_tile;
reg          [  32*9-1:0] m1_idct_x0_to_x8;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        k_num_tile <= '0;
        k_en <= '0;
        k_cnt <= '0;
        m1_en <= '0;
        m1_idct_en3 <= '0;
        m1_num_tile <= '0;
    end else begin
        m1_idct_en3 <= '0;
        if( j_en_tile ) begin
            k_num_tile <= j_num_tile;
            k_en  <= 1'b1;
            k_cnt <= '0;
        end else begin
            k_cnt <= k_cnt + 3'd1;
            if(k_cnt == '1)
                k_en <= 1'b0;
        end
        m1_en <= k_en;
        if(k_en) begin
            if(k_cnt == '1) begin
                m1_idct_en3 <= 1'b1;
                m1_num_tile <= k_num_tile;
            end
        end
    end

always @ (posedge clk) begin                                      // for inverse DCT stage 2
    if( j_en_tile ) begin
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++)
                k_idct_res2[i][j] <= j_idct_res1[i][j];
    end else begin
        for (int i=0; i<8; i++) begin
            for (int j=0; j<7; j++)
                k_idct_res2[i][j] <= k_idct_res2[i][j+1];         // left shift k_idct_res2 for 2 steps
            k_idct_res2[i][7] <= '0;
        end
    end
    if(k_en)
        m1_idct_x0_to_x8 <= invserse_dct_cols_step12(k_idct_res2[0][0], k_idct_res2[1][0], k_idct_res2[2][0], k_idct_res2[3][0], k_idct_res2[4][0], k_idct_res2[5][0], k_idct_res2[6][0], k_idct_res2[7][0]);
end



// divide invserse_dct_cols to 2 pipeline stages : for better timing -----------------------------------------------------------------------------------------

reg   signed [       8:0] m_idct_res3 [8][8];
reg                       m_idct_en3;
reg          [       2:0] m_num_tile;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        m_idct_en3 <= '0;
        m_num_tile <= '0;
    end else begin
        if (m1_en) begin
            m_idct_en3 <= m1_idct_en3;
            m_num_tile <= m1_num_tile;
        end
    end

always @ (posedge clk)
    if (m1_en) begin
        {m_idct_res3[0][7], m_idct_res3[1][7], m_idct_res3[2][7], m_idct_res3[3][7], m_idct_res3[4][7], m_idct_res3[5][7], m_idct_res3[6][7], m_idct_res3[7][7]} <= invserse_dct_cols_step34(m1_idct_x0_to_x8);
        for (int i=0; i<8; i++)
            for (int j=0; j<7; j++)
                m_idct_res3[i][j] <= m_idct_res3[i][j+1];         // left shift m_idct_res3 by 1 step
    end






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage N & P : 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [  XB16-1:0] n_x16 ;
reg          [  YB16-1:0] n_y16 ;
reg          [       5:0] n_num_tiles_line ;

reg          [       7:0] n_tiles_prd [48][8];                       // predicted block : Y/U/V tiles

reg   signed [       8:0] n_idct_res4 [8][8];
reg                       n_en ;
reg          [       2:0] n_cnt ;

reg          [   8*8-1:0] p_delay_mem_wdata;
reg                       p_en  ;
reg          [  XB16-1:0] p_x16 ;
reg          [  YB16-1:0] p_y16 ;
reg          [       5:0] p_num_tiles_line ;                     // 0~47

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        n_en  <= '0;
        n_cnt <= '0;
        p_en  <= '0;
    end else begin
        if(m_idct_en3) begin
            n_en  <= 1'b1;
            n_cnt <= '0;
        end else begin
            n_cnt <= n_cnt + 3'd1;
            if(n_cnt == '1)
                n_en <= 1'b0;
        end
        p_en <= n_en;
    end

always @ (posedge clk) begin
    if(m_idct_en3) begin
        for (int y=0; y<8; y++)
            for (int x=0; x<8; x++)
                n_idct_res4[y][x] <= m_idct_res3[y][x];
    end else begin
        for (int x=0; x<8; x++) begin
            for (int y=0; y<7; y++)
                n_idct_res4[y][x] <= n_idct_res4[y+1][x];           // up shift n_idct_res4
            n_idct_res4[7][x] <= '0;
        end
    end
    
    if(m_idct_en3 && m_num_tile == '0) begin                        // for the first tile in a block, save the predicted block
        for (int y=0; y<48; y++)
            for (int x=0; x<8; x++)
                n_tiles_prd[y][x] <= g_tiles_prd[y][x];             // save the predicted block
        n_x16 <= g_x16;
        n_y16 <= g_y16;
        n_num_tiles_line <= '0;
    end else if(n_en) begin
        for (int y=0; y<47; y++)
            for (int x=0; x<8; x++)
                n_tiles_prd[y][x] <= n_tiles_prd[y+1][x];           // up shift n_tiles_prd
        n_num_tiles_line <= n_num_tiles_line + 6'd1;
    end
    
    if(n_en) begin
        for (int x=0; x<8; x++)
            p_delay_mem_wdata[8*x+:8] <= add_clip_0_255( n_tiles_prd[0][x] , n_idct_res4[0][x] ) ;
        p_x16 <= n_x16;
        p_y16 <= n_y16;
        p_num_tiles_line <= n_num_tiles_line;
    end
end






//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage Q & R : use memory (mem_delay) to delay for a slice, and then write back to reference memory
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [   8*8-1:0] mem_delay [ 48 * (XSIZE/16) ];               // a memory to save a slice, to delay the write of mem_ref_Y & mem_ref_UV for a slice

always @ (posedge clk)
    if (p_en)
        mem_delay[{p_num_tiles_line, p_x16}] <= p_delay_mem_wdata;

reg          [   8*8-1:0] q_rd;
reg                       q_en  ;
reg          [  XB16-1:0] q_x16 ;
reg          [  YB16-1:0] q_y16 ;
reg          [       5:0] q_num_tiles_line ;

reg          [   8*8-1:0] r_rd;
reg                       r_en  ;
reg          [  XB16-1:0] r_x16 ;
reg          [  YB16-1:0] r_y16 ;
reg          [       5:0] r_num_tiles_line ;

always @ (posedge clk)
    q_rd <= mem_delay[{p_num_tiles_line, p_x16}];

always @ (posedge clk)
    r_rd <= q_rd;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        q_en  <= '0;
        q_x16 <= '0;
        q_y16 <= '0;
        q_num_tiles_line <= '0;
    end else begin
        q_en  <= p_en;
        q_x16 <= p_x16;
        q_y16 <= p_y16;
        q_num_tiles_line <= p_num_tiles_line;
    end

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        r_en  <= '0;
        r_x16 <= '0;
        r_y16 <= '0;
        r_num_tiles_line <= '0;
    end else begin
        r_en  <= q_en;
        r_x16 <= q_x16;
        r_y16 <= (q_y16 == '0) ? max_y16 : q_y16 - (YB16)'(1) ;         // set the write block to the upper slice
        r_num_tiles_line <= q_num_tiles_line;
    end

always @ (posedge clk)
    if( r_en && ~r_num_tiles_line[5] )
        mem_ref_Y [ {r_y16, r_num_tiles_line[4], r_num_tiles_line[2:0], r_x16, r_num_tiles_line[3]} ] <= r_rd;      // write to Y reference frame memory

always @ (posedge clk)
    if( r_en &&  r_num_tiles_line[5] )
        mem_ref_UV[ {r_y16                     , r_num_tiles_line[2:0], r_x16, r_num_tiles_line[3]} ] <= r_rd;      // write to U/V reference frame memory


//reg [8*8-1:0] mem_ref_Y  [ (YSIZE  ) * (XSIZE/8 )     ];   //   Y reference frame memory : (YSIZE  ) rows, XSIZE/8  cols                  , each item contains  8 Y pixels
//reg [8*8-1:0] mem_ref_UV [ (YSIZE/2) * (XSIZE/16) * 2 ];   // U/V reference frame memory : (YSIZE/2) rows, XSIZE/16 cols, 2 channels (U/V), each item contains  8 U or V pixels





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage S : zig-zag reorder, generate nzflags
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

logic                     s_nzflag ;                    // temporary variable
reg          [       5:0] s_nzflags ;
reg   signed [      11:0] s_zig_blk [6] [64];               // 12 bit
reg                       s_en_blk ;

always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        s_en_blk <= 1'b0;
    end else begin
        s_en_blk <= 1'b0;
        if(g_en_tile)
            s_en_blk <= ( g_num_tile == 3'd5 );                             // is the last tile in a block ?
    end

always @ (posedge clk)
    if(g_en_tile) begin
        for (int i=0; i<64; i++) begin
            s_zig_blk[0][i] <= s_zig_blk[1][i];
            s_zig_blk[1][i] <= s_zig_blk[2][i];
            s_zig_blk[2][i] <= s_zig_blk[3][i];
            s_zig_blk[3][i] <= s_zig_blk[4][i];
            s_zig_blk[4][i] <= s_zig_blk[5][i];
        end
        s_nzflag = ~g_inter;
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++) begin
                s_zig_blk[5][ZIG_ZAG_TABLE[i][j]] <= g_quant[i][j];      // zig-zag reorder
                s_nzflag |= (g_quant[i][j] != '0);                       // check if g_quant are all zero
            end
        s_nzflags <= (s_nzflags<<1) | (6)'(s_nzflag);
    end







//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// stage T : MPEG2 stream generation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg          [       5:0] t_frame_hour, t_frame_minute, t_frame_second, t_frame_insec;    // (hour,minute,second,insec) = (0~63,0~59,0~59,0~23)

reg          [       7:0] t_i_frame ;
reg          [  XB16-1:0] t_x16 ;
reg          [  YB16-1:0] t_y16 ;
reg                       t_inter ;
reg          [       5:0] t_nzflags ;
reg   signed [       4:0] t_mvx, t_mvy;
reg   signed [       4:0] t_prev_mvx, t_prev_mvy;
reg   signed [      11:0] t_zig_blk [6] [64];
reg   signed [      11:0] t_prev_Y_dc, t_prev_U_dc, t_prev_V_dc;
reg          [       5:0] t_runlen ;

reg          [       2:0] t_num_tile ;
reg          [       3:0] t_cnt ;
enum reg     [       2:0] {PUT_ENDED, PUT_SEQ_HEADER2, PUT_IDLE, PUT_FRAME_HEADER, PUT_SLICE_HEADER, PUT_BLOCK_INFO, PUT_TILE} t_stat;

reg                       t_end_seq ;
reg                       t_align ;
reg          [      23:0] t_bits [7];
reg          [       4:0] t_lens [7];
reg                       t_append_b10 ;


logic signed [       6:0] dmv;         // temporary variable, not real register
logic        [       4:0] dmvabs;      // temporary variable, not real register
logic                     nzflag;      // temporary variable, not real register
logic signed [      11:0] val;         // temporary variable, not real register
logic signed [      12:0] diff_dc;     // temporary variable, not real register
logic        [      11:0] tmp_val;     // temporary variable, not real register
logic        [       3:0] vallen;      // temporary variable, not real register
logic        [       5:0] runlen;      // temporary variable, not real register


function automatic logic [24+5-1:0] put_AC (input logic signed [11:0] v, input logic [5:0] rl);        // because of run-length encoding, v cannot be zero
    logic [23:0] bits;
    logic [ 4:0] lens;
    logic [10:0] absv;
    absv = (v < 12'sd0) ? (11)'($unsigned(-v)) : (11)'($unsigned(v));
    absv --;
    if ( rl == 0 && absv < 40 || rl == 1 && absv < 18 || rl == 2 && absv < 5 || rl == 3 && absv < 4 ) begin
        bits = { BITS_AC_0_3[rl][absv], (1)'(v<12'sd0)};
        lens =   LENS_AC_0_3[rl][absv] + 5'd1;
    end else if( rl <= 6 && absv < 3 || rl <= 16 &&  absv < 2 || rl <= 31 &&  absv < 1 ) begin
        bits = {BITS_AC_4_31[rl][absv], (1)'(v<12'sd0)};
        lens =  LENS_AC_4_31[rl][absv] + 5'd1;
    end else begin
        bits = { 6'h1, rl, (12)'($unsigned(v)) };
        lens = 5'd24;
    end
    return {bits, lens};
endfunction


always @ (posedge clk or negedge rstn)
    if (~rstn) begin
        {t_frame_hour, t_frame_minute, t_frame_second, t_frame_insec} <= '0;
        t_i_frame <= '0;
        t_x16 <= '0;
        t_y16 <= '0;
        t_inter <= '0;
        t_nzflags <= '0;
        t_mvx <= '0;
        t_mvy <= '0;
        t_prev_mvx <= '0;
        t_prev_mvy <= '0;
        {t_prev_Y_dc, t_prev_U_dc, t_prev_V_dc} <= '0;
        t_runlen <= '0;
        t_num_tile <= '0;
        t_cnt <= '0;
        t_stat <= PUT_ENDED;
        
        t_end_seq <= '0;
        t_align <= '0;
        for(int i=0; i<7; i++) begin
            t_bits[i] <= '0;
            t_lens[i] <= '0;
        end
        t_append_b10 <= '0;
    end else begin
        t_runlen <= '0;
        
        t_num_tile <= '0;
        t_cnt <= '0;
        
        t_end_seq <= '0;
        t_align <= '0;
        for(int i=0; i<7; i++) begin
            t_bits[i] <= '0;
            t_lens[i] <= '0;
        end
        t_append_b10 <= '0;
        
        case(t_stat)
            PUT_ENDED : begin
                if(sequence_start) begin
                    t_stat <= PUT_SEQ_HEADER2;
                    
                    {t_frame_hour, t_frame_minute, t_frame_second, t_frame_insec} <= '0;                        // clear time code
                    
                    t_align <= 1'b1;
                    t_bits <= '{ 'h000001, 'hB3, {size_x, size_y}, 'h1209c4, 'h200000, 'h0001B5, 'h144200 };    // sequence header : part 1 (152 bits)
                    t_lens <= '{       24,    8,               24,       24,       24,       24,       24 };
                end
            end
            
            PUT_SEQ_HEADER2 : begin
                t_stat <= PUT_IDLE;
                
                t_bits <= '{ 'h010000, 'h000001, 'hB52305, 'h0505, size_x, 1'b1, size_y };          // sequence header : part 2 (117 bits)
                t_lens <= '{       24,       24,       24,     16,     14,    1,     14 };
            end
            
            PUT_IDLE : begin
                if( t_y16 == max_y16 && t_x16 == max_x16 && sequence_state == SEQ_ENDED) begin
                    t_stat <= PUT_ENDED;
                    t_end_seq <= 1'b1;
                    t_align <= 1'b1;
                    t_bits[0] <= 'h000001;
                    t_lens[0] <= 24;
                    t_bits[1] <= 'hB7;                                                                          // sequence end
                    t_lens[1] <= 8;
                    
                end else if( s_en_blk ) begin
                    t_i_frame <= g_i_frame;
                    t_y16 <= g_y16;
                    t_x16 <= g_x16;
                    t_inter <= g_inter;
                    t_mvx <= g_mvx;
                    t_mvy <= g_mvy;
                    t_nzflags <= s_nzflags;
                    
                    t_stat <= PUT_BLOCK_INFO;
                    
                    if( g_x16 == '0 ) begin                           // start of slice
                        t_stat <= PUT_SLICE_HEADER;
                        if( g_y16 == '0 ) begin                       // start of frame
                            t_stat <= PUT_FRAME_HEADER;
                            if( g_i_frame == '0 ) begin               // start of GOP
                                t_align <= 1'b1;
                                t_bits <= '{ 'h000001, 'hB8, t_frame_hour, t_frame_minute, {1'b1, t_frame_second}, t_frame_insec, 'h2 };   // GOP header (59 bits)
                                t_lens <= '{       24,    8,            6,              6,                      7,             6,   2 };
                            end
                        end
                    end
                end
            end
            
            PUT_FRAME_HEADER : begin
                t_stat <= PUT_SLICE_HEADER;
                
                t_align <= 1'b1;
                t_bits <= '{ 'h000001, t_i_frame, 'h10000, 'h0, 'h000001, 'hB58111, 'h1BC000 };       // frame header (136 bits for I-frame, 144 bits for P-frame)
                t_lens <= '{       24,        18,      19,   3,       24,       24,       24 };
                
                if ( t_i_frame != '0 ) begin   // for P-frame
                    t_bits[2] <= 'h20000;
                    t_bits[3] <=   'h380;
                    t_lens[3] <=      11;
                end
                
                // for new frame, update time code ---------------------------
                t_frame_insec <= t_frame_insec + 6'd1;
                if( t_frame_insec == 6'd23 ) begin
                    t_frame_insec <= '0;
                    t_frame_second <= t_frame_second + 6'd1;
                    if( t_frame_second == 6'd59 ) begin
                        t_frame_second <= '0;
                        t_frame_minute <= t_frame_minute + 6'd1;
                        if( t_frame_minute == 6'd59 ) begin
                            t_frame_minute <= '0;
                            if( t_frame_hour < 6'd63 )
                                t_frame_hour <= t_frame_hour + 6'd1;
                        end
                    end
                end
            end
            
            PUT_SLICE_HEADER : begin
                t_stat <= PUT_BLOCK_INFO;
                
                t_align <= 1'b1;
                t_bits <= '{ 'h000001, 1+t_y16, (2<<Q_LEVEL), 'h0, 'h0, 'h0, 'h0 };     // slice header : 38 bits
                t_lens <= '{       24,       8,            6,   0,   0,   0,   0 };
                
                // for new slice, clear the previous DC value and the previous motion vector ---------------------------
                {t_prev_Y_dc, t_prev_U_dc, t_prev_V_dc} <= '0;
                t_prev_mvx <= '0;
                t_prev_mvy <= '0;
            end
            
            PUT_BLOCK_INFO : begin
                t_stat <= PUT_TILE;
                
                // put block type -----------------------------------------------------------------------------------------
                if          ( ~t_inter && t_i_frame != '0 ) begin      // intra block in a P-frame
                    t_bits[0] <= 'h23;
                    t_lens[0] <= 6;
                end else if (  t_inter && t_nzflags == '0 ) begin      // inter block with all zeros
                    t_bits[0] <= 'h09;
                    t_lens[0] <= 4;
                end else begin                                         // otherwise (the most case)
                    t_bits[0] <= 'h03;
                    t_lens[0] <= 2;
                end
                
                // for inter block, put motion vector and nzflags ------------------------------------------------------------------
                if( t_inter ) begin
                    // put motion vector x ------------------------------------------------------------------
                    dmv  = t_mvx;
                    dmv -= t_prev_mvx;
                    if      (dmv > 7'sd15)
                        dmv -= 7'sd32;
                    else if (dmv < -7'sd16)
                        dmv += 7'sd32;
                    dmvabs = (dmv < 7'sd0) ? (5)'($unsigned(-dmv)) : (5)'($unsigned(dmv)) ;
                    t_bits[1] <= BITS_MOTION_VECTOR[dmvabs];
                    t_lens[1] <= LENS_MOTION_VECTOR[dmvabs];
                    if (dmv != 7'sd0) begin
                        t_bits[2] <= (1)'(dmv < 7'sd0);
                        t_lens[2] <= 1;
                    end
                    
                    // put motion vector y ------------------------------------------------------------------
                    dmv  = t_mvy;
                    dmv -= t_prev_mvy;
                    if      (dmv > 7'sd15)
                        dmv -= 7'sd32;
                    else if (dmv < -7'sd16)
                        dmv += 7'sd32;
                    dmvabs = (dmv < 7'sd0) ? (5)'($unsigned(-dmv)) : (5)'($unsigned(dmv)) ;
                    t_bits[3] <= BITS_MOTION_VECTOR[dmvabs];
                    t_lens[3] <= LENS_MOTION_VECTOR[dmvabs];
                    if (dmv != 7'sd0) begin
                        t_bits[4] <= (1)'(dmv < 7'sd0);
                        t_lens[4] <= 1;
                    end
                    
                    // put nzflags ------------------------------------------------------------------
                    t_bits[5] <= BITS_NZ_FLAGS[t_nzflags];
                    t_lens[5] <= LENS_NZ_FLAGS[t_nzflags];
                    
                    t_prev_mvx <= t_mvx;
                    t_prev_mvy <= t_mvy;
                end else begin            // for intra block, clear the previous motion vector
                    t_prev_mvx <= '0;
                    t_prev_mvy <= '0;
                end
            end
            
            PUT_TILE : begin
                
                nzflag = t_nzflags[5];
                
                if (t_cnt == 4'd0) begin                                                                               // DC value
                    val = t_zig_blk[0][0];                                                                             // val <- DC value
                    diff_dc = val;
                    if          (t_num_tile <  3'd4) begin
                        diff_dc -= t_prev_Y_dc;
                        t_prev_Y_dc <= t_inter ? '0 : val;                                                             // save the DC value as the previous Y DC value for next tile
                    end else if (t_num_tile == 3'd4) begin
                        diff_dc -= t_prev_U_dc;
                        t_prev_U_dc <= t_inter ? '0 : val;                                                             // save the DC value as the previous U DC value for next tile
                    end else begin
                        diff_dc -= t_prev_V_dc;
                        t_prev_V_dc <= t_inter ? '0 : val;                                                             // save the DC value as the previous V DC value for next tile
                    end
                    
                    if (t_inter) begin                                                                                 // put DC value (INTER)
                        if (val == '0) begin
                            t_runlen <= 6'd1;
                        end else if( val == 12'sd1 || val == -12'sd1 ) begin
                            if (nzflag) begin
                                t_bits[0] <= { 1'b1, (1)'(val<12'sd0) };
                                t_lens[0] <= 2;
                            end
                        end else begin
                            if (nzflag)
                                {t_bits[0], t_lens[0]} <= put_AC(val, 6'd0);
                        end
                    end else begin                                                                                     // put DC value (INTRA)
                        tmp_val = (12)'($unsigned( (diff_dc < 13'sd0) ? -diff_dc : diff_dc ));
                        vallen = '0;
                        for (int i=0; i<12; i++)
                            if (tmp_val[i])
                                vallen = (4)'(i+1);
                        tmp_val = (12)'($unsigned(diff_dc));
                        if (diff_dc < 13'sd0)
                            tmp_val += ((12'd1 << vallen) - 12'd1);
                        if (nzflag) begin
                            t_bits[0] <= (t_num_tile < 3'd4) ? BITS_DC_Y[vallen] : BITS_DC_UV[vallen];
                            t_lens[0] <= (t_num_tile < 3'd4) ? LENS_DC_Y[vallen] : LENS_DC_UV[vallen];
                            t_bits[1] <= tmp_val;
                            t_lens[1] <= vallen;
                        end
                    end
                end else begin                                                                                          // AC value
                    runlen = t_runlen;
                    for(int i=0; i<7; i++) begin
                        val = t_zig_blk[0][i+1];
                        if (val != 12'sd0) begin
                            if (nzflag)
                                {t_bits[i], t_lens[i]} <= put_AC(val, runlen);
                            runlen = 6'd0;
                        end else
                            runlen ++;
                    end
                    t_runlen <= runlen;
                    t_append_b10 <= nzflag && (t_cnt == 4'd9);                                                          // for the last cycle of a tile, append 2'b10 to the MPEG2 stream
                end
                
                if (t_cnt < 4'd9) begin                                                                                 // NOT the last cycle of a tile
                    t_cnt <= t_cnt + 4'd1;
                    t_num_tile <= t_num_tile;
                end else begin                                                                                          // the last cycle of a tile
                    t_num_tile <= t_num_tile + 3'd1;
                    if (t_num_tile == 3'd5)                                                                             // the last tile
                        t_stat <= PUT_IDLE;                                                                             // end of this block, return to IDLE
                    t_nzflags <= (t_nzflags << 1);
                end
            end
        endcase
    end


always @ (posedge clk)
    case(t_stat)
        PUT_IDLE : begin
            if( s_en_blk ) begin
                for(int i=0; i<6; i++)
                    for(int j=0; j<64; j++)
                        t_zig_blk[i][j] <= s_zig_blk[i][j];
            end
        end

        PUT_TILE : begin
            if          (t_cnt == 4'd0) begin                                                                       // DC value
            end else if (t_cnt < 4'd9) begin                                                                        // NOT the last cycle of a tile
                for (int i=1; i<=56; i++)
                    t_zig_blk[0][i] <= t_zig_blk[0][i+7];                                                           // shift AC values for 7 steps
            end else begin                                                                                          // the last cycle of a tile
                for(int i=0; i<5; i++)                                                                              // switch the tiles
                    for(int j=0; j<64; j++)
                        t_zig_blk[i][j] <= t_zig_blk[i+1][j];
            end
        end
    endcase





reg          [     169:0] u_bits ;         // max 170 bits
reg          [       7:0] u_lens ;         // 0~170
reg                       u_align ;
reg                       u_end_seq1 ;
reg                       u_end_seq2 ;

logic        [     169:0] ut_bits;             // temporary variable, not real register
logic        [       7:0] ut_lens;             // temporary variable, not real register

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        u_bits <= '0;
        u_lens <= '0;
        u_align <= '0;
        {u_end_seq2, u_end_seq1} <= '0;
    end else begin
        ut_bits = '0;
        ut_lens = '0;
        if (t_append_b10) begin
            ut_bits = 170'b10;
            ut_lens += 8'd2;
        end
        for (int i=6; i>=0; i--) begin
            ut_bits |= ( (170)'(t_bits[i]) << ut_lens );
            ut_lens += t_lens[i];
        end
        u_bits <= ut_bits;
        u_lens <= ut_lens;
        u_align <= t_align;
        {u_end_seq2, u_end_seq1} <= {u_end_seq1, t_end_seq};
    end




reg          [     254:0] v_bits ;     // max 255 bits
reg          [       7:0] v_lens ;     // 0~255

reg          [     255:0] v_data ;
reg                       v_en ;
reg                       v_last ;

logic        [     431:0] vt_bits;         // 432 bits, temporary variable, not real register
logic        [       8:0] vt_lens;         // temporary variable, not real register

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        v_bits <= '0;
        v_lens <= '0;
        v_data <= '0;
        v_en   <= '0;
        v_last <= '0;
    end else begin
        if (u_end_seq2) begin                          // a special case: end of sequence
            v_bits <= '0;
            v_lens <= '0;
            v_data <= {v_bits, 1'b0};
            v_en <= 1'b1;
            v_last <= 1'b1;
        end else begin
            vt_lens = (9)'(v_lens);
            if (u_align && vt_lens[2:0] != 3'h0) begin
                vt_lens[2:0] = '0;
                vt_lens[8:3] ++;                          // align lens to a multiple of 8 bits (1 byte)
            end
            vt_lens += (9)'(u_lens);
            vt_bits = {v_bits, 177'h0}  |  ( (432)'(u_bits) << (9'd432-vt_lens) );
            v_lens <= vt_lens[7:0];
            if (vt_lens[8]) begin
                {v_data, v_bits} <= {vt_bits, 79'h0};
                v_en <= 1'b1;
            end else begin
                v_bits <= vt_bits[431:177];
                v_en <= 1'b0;
            end
            v_last <= 1'b0;
        end
    end




assign o_en   = v_en;
assign o_last = v_last;
assign o_data = v_data;


endmodule




