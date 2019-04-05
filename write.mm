#import <Cocoa/Cocoa.h>
#import <cmath>
#import <string>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcomma"
#pragma clang diagnostic ignored "-Wunused-function"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
namespace stb_image {
    #import "./libs/stb_image_write.h"
}
#pragma clang diagnostic pop

int main(int argc, char *argv[]) {
    @autoreleasepool {
        
        int w = 1920;
        int h = 1080;
        
        double shift = 4.0;
        
        unsigned int *src = new unsigned int[w*h];
        
        if(0) {
            for(int i=0; i<h; i++) {
                for(int j=0; j<w; j++) {
                    src[i*w+j] = ((int)((w+j)*shift))<<16|((int)((h+i)*shift));
                }
            }
            stb_image::stbi_write_png("./maps/map.png",w,h,4,(void const*)src,w<<2);
        }
        else { // sin
                        
                        
            for(int i=0; i<h; i++) {
                for(int j=0; j<w; j++) {
                    int i2 = i+400.*cos(5.0*(j/(double)(w-1)));
                    int j2 = j+400.*sin(5.0*(i/(double)(h-1)));
                    src[i*w+j] = ((int)(0x7FFF+j2*shift))<<16|((int)(0x7FFF+i2*shift));
                }
            }
            stb_image::stbi_write_png("./maps/map.png",w,h,4,(void const*)src,w<<2);
        }
        
        
    }
}