#import <Cocoa/Cocoa.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcomma"
#pragma clang diagnostic ignored "-Wunused-function"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
namespace stb_image {
    #import "../../libs/stb_image_write.h"
}
#pragma clang diagnostic pop

int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        
        int W = 1920;
        int H = 1080;
        
        double shift = 4.0;
        
        unsigned int *dst = new unsigned int[W*H];
    
        for(int i=0; i<H; i++) {
            for(int j=0; j<W; j++) {
                dst[i*W+j] = ((int)(0x7FFF+j*shift))<<16|((int)(0x7FFF+i*shift));
            }
        }
        
        stb_image::stbi_write_png("../../maps/map.png",W,H,4,(void const*)dst,W<<2);
        
        delete[] dst;
    }
}