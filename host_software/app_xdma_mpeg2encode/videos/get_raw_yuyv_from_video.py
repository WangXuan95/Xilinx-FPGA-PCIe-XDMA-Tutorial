
import sys
import numpy as np
import cv2



if __name__ == '__main__' :
    
    video_filename, yuv_filename = None, None
    
    for arg in sys.argv[1:] :
        if video_filename is None :
            video_filename = arg
        else:
            yuv_filename = arg
    
    if   video_filename is None  or  yuv_filename is None :
        print('Usage :  python %s <input_video_file> <output_yuv_file>' % sys.argv[0])
        exit(-1)
    
    video = cv2.VideoCapture(video_filename)
    
    h, w = 0, 0
    
    with open(yuv_filename, 'wb') as fp :
        
        for nframe in range(100000000) :
            
            read_success, frame_rgb = video.read()
            
            if not read_success:
                break
            
            frame_yuv444 = cv2.cvtColor(frame_rgb, cv2.COLOR_BGR2YUV)
            
            h, w, _ = frame_yuv444.shape
            
            if w % 2 != 0 :
                print('odd height (%d) is not supported', w)
                exit(-1)
            
            if h % 2 != 0 :
                print('odd height (%d) is not supported', h)
                exit(-1)
            
            frame_yuyv = np.zeros( [h, w*2] , dtype = np.uint8)
            
            frame_yuyv[ : ,  ::2 ] = frame_yuv444[ : , :   , 0 ]     # Y
            frame_yuyv[ : , 1::4 ] = frame_yuv444[ : , ::2 , 1 ]     # U
            frame_yuyv[ : , 3::4 ] = frame_yuv444[ : , ::2 , 2 ]     # V
            
            fp.write( frame_yuyv.tobytes() )
    
        print('%d x %d         %d frames' % (w, h, nframe) )




