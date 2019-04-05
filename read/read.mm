#import <Cocoa/Cocoa.h>
#import <string>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcomma"
#pragma clang diagnostic ignored "-Wunused-function"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
namespace stb_image {
    #import "../libs/stb_image.h"
}
#pragma clang diagnostic pop


int main(int argc, char *argv[]) {
    @autoreleasepool {
        
        int w;
        int h;
        int bpp;
        std::string url = "../maps/map.png";
        unsigned int *map = (unsigned int *)stb_image::stbi_load(url.c_str(),&w,&h,&bpp,4);
        NSLog(@"%s,%d,%d,%d",url.c_str(),w,h,bpp);
        
        if(map) {
            double shift = 1.0/4.0;
            int addr = (0)*w+(0);
            unsigned int p = map[addr];
            int x = (p>>16)-0x7FFF;
            int y = (p&0xFFFF)-0x7FFF;
            NSLog(@"%f,%f",x*shift,y*shift);   
            addr = (h-1)*w+(w-1);             
            p = map[addr];
            x = (p>>16)-0x7FFF;
            y = (p&0xFFFF)-0x7FFF;
            NSLog(@"%f,%f",((map[addr]>>16)-0x7FFF)*shift,((map[addr]&0xFFFF)-0x7FFF)*shift);
        }
    }
}