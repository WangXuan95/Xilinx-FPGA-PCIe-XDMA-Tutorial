
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/timeb.h>




// function : dev_read
// description : read data from device to local memory (buffer), (i.e. device-to-host)
// parameter :
//       dev_fd : device instance
//       addr   : source address in the device
//       buffer : buffer base pointer
//       size   : data size
// return:
//       int : 0=success,  -1=failed
int dev_read (int dev_fd, uint64_t addr, void *buffer, uint64_t size) {
    if ( addr != lseek(dev_fd, addr, SEEK_SET) )                                 // seek
        return -1;                                                               // seek failed
    if ( size != read(dev_fd, buffer, size) )                                    // read device to buffer
        return -1;                                                               // read failed
    return 0;
}


// function : dev_write
// description : write data from local memory (buffer) to device, (i.e. host-to-device)
// parameter :
//       dev_fd : device instance
//       addr   : target address in the device
//       buffer : buffer base pointer
//       size   : data size
// return:
//       int : 0=success,  -1=failed
int dev_write (int dev_fd, uint64_t addr, void *buffer, uint64_t size) {
    if ( addr != lseek(dev_fd, addr, SEEK_SET) )                                 // seek
        return -1;                                                               // seek failed
    if ( size != write(dev_fd, buffer, size) )                                   // write device from buffer
        return -1;                                                               // write failed
    return 0;
}


// function : dev_read_uint64
// description : read a uint64 value (8 bytes) from device to local, (i.e. device-to-host)
// parameter :
//       dev_fd  : device instance
//       addr    : source address in the device
//       p_value : uint64 value's pointer
// return:
//       int : 0=success,  -1=failed
int dev_read_uint64 (int dev_fd, uint64_t addr, uint64_t *p_value) {
    return dev_read(dev_fd, addr, (void*)p_value, sizeof(uint64_t));
}


// function : dev_write_uint64
// description : write a uint64 value (8 bytes) from to device, (i.e. host-to-device)
// parameter :
//       dev_fd : device instance
//       addr   : target address in the device
//       value  : uint64 value to write
// return:
//       int : 0=success,  -1=failed
int dev_write_uint64 (int dev_fd, uint64_t addr, uint64_t value) {
    return dev_write(dev_fd, addr, (void*)&value, sizeof(uint64_t));
}



// mpeg2encoder device's address map --------------------------------------------------------------------------------
#define  ADDR_RESET_AND_SEQUENCE_CONTROL  0x00000000UL
#define  ADDR_VIDEO_FRAME_SIZE            0x00000008UL
#define  ADDR_OUT_BUF_CONTROL             0x00000010UL
#define  ADDR_BASE_IN_PIXELS              0x01000000UL
#define  ADDR_BASE_OUT_BUF                0x01000000UL


// function    : mpeg2encoder_reset
// description : reset the mpeg2encoder in the device
// return:
//       int : 0=success,  -1=failed
int mpeg2encoder_reset (int dev_w_fd) {
    if   ( dev_write_uint64(dev_w_fd, ADDR_RESET_AND_SEQUENCE_CONTROL, 0x0) )       // reset
        return -1;
    return dev_write_uint64(dev_w_fd, ADDR_RESET_AND_SEQUENCE_CONTROL, 0x1) ;       // reset release
}


// function    : mpeg2encoder_set_sequence_stop
// description : send a "sequence stop" signal to the device, which indicate this is the end of a video sequence
// return:
//       int : 0=success,  -1=failed
int mpeg2encoder_set_sequence_stop (int dev_w_fd) {
    return dev_write_uint64(dev_w_fd, ADDR_RESET_AND_SEQUENCE_CONTROL, 0x3) ;       // sequence stop, note that the lowest bit is set to 1 to keep the reset released
}


// function    : mpeg2encoder_set_video_frame_size
// description : set the frame width and height of the video sequence to be encoded
// parameter :
//      xsize16 : frame width / 16  .  e.g. for width  = 640, xsize16 = 40
//      ysize16 : frame height / 16 .  e.g. for height = 480, ysize16 = 30
// return:
//       int : 0=success,  -1=failed
int mpeg2encoder_set_video_frame_size (int dev_w_fd, int xsize16, int ysize16) {
    uint64_t reg_value;
    reg_value   = ysize16;
    reg_value <<= 32;
    reg_value  |= xsize16;
    return dev_write_uint64(dev_w_fd, ADDR_VIDEO_FRAME_SIZE, reg_value);
}


// function    : mpeg2encoder_put_pixels
// description : put raw YUV pixels to the device, which will be encoded to the MPEG2 stream
// return:
//       int : 0=success,  -1=failed
int mpeg2encoder_put_pixels (int dev_w_fd, void *buffer, uint64_t size) {
    return dev_write(dev_w_fd, ADDR_BASE_IN_PIXELS, buffer, size);
}


// function    : mpeg2encoder_get_outbuf
// description : get data (encoded MPEG2 stream) from the out buffer of the device
// return:
//       int : 0=success,  -1=failed
int mpeg2encoder_get_outbuf (int dev_r_fd, int dev_w_fd, void *buffer, int *p_size, int *p_overflow) {       // buffer must have 0x200000 (2MB) space at least
    int offset = 0;
    
    for (;;) {
        do {                                     // wait until outbuf not empty
            uint64_t reg_value;
            if ( dev_read_uint64(dev_r_fd, ADDR_OUT_BUF_CONTROL, &reg_value) )
                return -1;
            *p_size     =   reg_value & 0x7ffffff;
            *p_overflow = ((reg_value >> 32) & 1);
        } while (*p_size <= 0) ;
        
        if (offset >= *p_size)                 // no more available data in out buffer
            break;
        
        if ( dev_read(dev_r_fd, ADDR_BASE_OUT_BUF+offset, (void*)((char*)buffer+offset), *p_size-offset ) )
            return -1;
        
        offset = *p_size;
    }
    
    return dev_write_uint64(dev_w_fd, ADDR_OUT_BUF_CONTROL, 0UL);         // clear the out buffer
}




// function : get_millisecond
// description : get time in millisecond
uint64_t get_millisecond () {
    struct timeb tb;
    ftime(&tb);
    return (uint64_t)tb.millitm + (uint64_t)tb.time * 1000UL;
    // tb.time is the number of seconds since 00:00:00 January 1, 1970 UTC time;
    // tb.millitm is the number of milliseconds in a second
}



// function : parse_int
// description : get a int value from string (support hexadecimal and decimal)
int parse_int (char *string, int *pvalue) {
    if ( string[0] == '0'  &&  string[1] == 'x' )                // HEX format "0xXXXXXXXX"
        return sscanf( &(string[2]), "%x", pvalue);
    else                                                         // DEC format
        return sscanf(   string    , "%d", pvalue);
}



char USAGE [] = 
    "Usage: \n"
    "    %s <dev_r_name> <dev_w_name> <in_file_name> <out_file_name> <video_frame_width> <video_frame_height>\n"
    "\n"
    "Where:\n"
    "    in_file_name  : .yuv file which contains the raw YUV pixels of a video,\n"
    "                    must be in YUYV format (a type of YUV 4:2:2 packed format)\n"
    "    out_file_name : .m2v file which contains the MPEG2 stream,\n"
    "\n"
    "Example:\n"
    "    %s  /dev/xdma0_c2h_0  /dev/xdma0_h2c_0  in.yuv  out.m2v  640  480\n"
    "\n" ;



// video frame size limitations (limited by the device) -----------------------------------------------------------------
#define  VIDEO_FRAME_XSIZE16_MIN   4         // min frame width  = 4 * 16 = 64
#define  VIDEO_FRAME_XSIZE16_MAX  64         // max frame width  = 4 * 64 = 1024
#define  VIDEO_FRAME_YSIZE16_MIN   4         // min frame height = 4 * 16 = 64
#define  VIDEO_FRAME_YSIZE16_MAX  64         // max frame height = 4 * 64 = 1024



#define  IN_BUF_SIZE   0x200000
#define OUT_BUF_SIZE   0x200000



int main (int argc, char *argv[]) {

    static char in_buffer  [IN_BUF_SIZE];             // this buffer is for the RAW pixels which is to send to the device
    static char out_buffer [OUT_BUF_SIZE];            // this buffer is for the MPEG2 stream get from the device
    
    int ret = -1;
    uint64_t millisecond;
    char usage_string [1024];
    
    char *dev_r_name, *dev_w_name, *in_file_name, *out_file_name;
    int xsize, ysize;
    
    int dev_r_fd = -1, dev_w_fd = -1;
    
    FILE *in_fp = NULL, *out_fp = NULL;
    
    
    sprintf(usage_string, USAGE, argv[0], argv[0] );
    
    if (argc < 7) {                              // not enough argument
        puts(usage_string);
        return -1;
    }
    
    
    dev_r_name    = argv[1];
    dev_w_name    = argv[2];
    in_file_name  = argv[3];
    out_file_name = argv[4];
    
    if ( 0 == parse_int(argv[5], &xsize) ) {     // parse video width  (xsize) from command line argument
        puts(usage_string);
        return -1;
    }
    
    if ( 0 == parse_int(argv[6], &ysize) ) {     // parse video height (ysize) from command line argument
        puts(usage_string);
        return -1;
    }
    
    // print information -----------------------------------
    printf("device          : %s    %s\n" , dev_r_name, dev_w_name);
    printf("input  yuv file : %s\n" , in_file_name);
    printf("output m2v file : %s\n" , out_file_name);
    printf("video size      : %d x %d\n" , xsize, ysize );
    
    // check video frame size -----------------------------------
    if ( xsize % 16 != 0 ) {
        printf("*** ERROR: xsize must be multiple of 16\n");
        return -1;
    }
    if ( ysize % 16 != 0 ) {
        printf("*** ERROR: ysize must be multiple of 16\n");
        return -1;
    }
    if ( xsize < 16*VIDEO_FRAME_XSIZE16_MIN  ||  xsize > 16*VIDEO_FRAME_XSIZE16_MAX ) {
        printf("*** ERROR: xsize must not smaller than %d or larger than %d", 16*VIDEO_FRAME_XSIZE16_MIN, 16*VIDEO_FRAME_XSIZE16_MAX);
        return -1;
    }
    if ( ysize < 16*VIDEO_FRAME_YSIZE16_MIN  ||  ysize > 16*VIDEO_FRAME_YSIZE16_MAX ) {
        printf("*** ERROR: ysize must not smaller than %d or larger than %d", 16*VIDEO_FRAME_YSIZE16_MIN, 16*VIDEO_FRAME_YSIZE16_MAX);
        return -1;
    }
    
    
    dev_r_fd = open(dev_r_name, O_RDWR);                                        // open device
    if (dev_r_fd < 0) {
        printf("*** ERROR: failed to open device %s\n", dev_r_name);
        goto close_and_clear;
    }
    
    dev_w_fd = open(dev_w_name, O_RDWR);                                        // open device
    if (dev_w_fd < 0) {
        printf("*** ERROR: failed to open device %s\n", dev_w_name);
        goto close_and_clear;
    }
    
    in_fp = fopen(in_file_name, "rb");                                          // open file for read
    if (in_fp == NULL) {
        printf("*** ERROR: failed to open file %s for read\n", in_file_name);
        goto close_and_clear;
    }
    
    out_fp = fopen(out_file_name, "wb");                                        // open file for write
    if (out_fp == NULL) {
        printf("*** ERROR: failed to open file %s for write\n", out_file_name);
        goto close_and_clear;
    }
    
    
    millisecond = get_millisecond();                                            // get start time
    
    if ( mpeg2encoder_reset(dev_w_fd) ) {                                       // reset the mpeg2encoder device
        printf("*** ERROR: failed to reset device\n");
        goto close_and_clear;
    }
    
    if ( mpeg2encoder_set_video_frame_size(dev_w_fd, xsize/16, ysize/16) ) {    // set video frame size
        printf("*** ERROR: failed to set video frame size\n");
        goto close_and_clear;
    }
    
    do {
        int in_len, out_len, out_overflow;
        
        in_len = fread((void*)in_buffer, 1, IN_BUF_SIZE, in_fp);                             // file -> in_buffer (raw YUV pixels)
        
        if ( mpeg2encoder_put_pixels(dev_w_fd, (void*)in_buffer, in_len) ) {                 // in_buffer -> device (raw YUV pixels)
            printf("*** ERROR: failed to put pixels\n");
            goto close_and_clear;
        }
        
        if ( feof(in_fp) )                                                                   // if input file is ended, send "video sequence stop" signal
            if ( mpeg2encoder_set_sequence_stop(dev_w_fd) ) {
                printf("*** ERROR: failed to set sequence stop\n");
                goto close_and_clear;
            }
        
        if ( mpeg2encoder_get_outbuf (dev_r_fd, dev_w_fd, (void*)out_buffer, &out_len, &out_overflow) ) {   // device -> out_buffer (MPEG2 stream)
            printf("*** ERROR: failed to get data from device\n");
            goto close_and_clear;
        }
        
        if ( out_overflow )
            printf("*** WARNING: device's out buffer overflow, out data stream is partly corrupted\n");
        
        if ( out_len != fwrite((void*)out_buffer, 1, out_len, out_fp) ) {                    // out_buffer -> file (MPEG2 stream)
            printf("*** ERROR: failed to write %s\n", out_file_name);
            goto close_and_clear;
        }
        
    } while ( ! feof(in_fp) ) ;
    
    millisecond = get_millisecond() - millisecond;                           // get time consumption
    millisecond = (millisecond > 0) ? millisecond : 1;                       // avoid divide-by-zero
    
    printf("input  size = %ld\n", ftell(in_fp) );
    printf("output size = %ld\n", ftell(out_fp) );
    printf("compression ratio = %.1lf\n", (double) ftell(in_fp) / (ftell(out_fp) + 1) );
    printf("time=%lu ms     input throughput = %.1lf KBps\n", millisecond, (double) ftell(in_fp) / millisecond );
    
    ret = 0;
    
close_and_clear:
    
    if (dev_r_fd >= 0)
        close(dev_r_fd);
    
    if (dev_w_fd >= 0)
        close(dev_r_fd);
    
    if (in_fp)
        fclose(in_fp);
    
    if (out_fp)
        fclose(out_fp);
    
    return ret;
}



