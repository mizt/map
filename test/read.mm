#import <Cocoa/Cocoa.h>
#import "../4K.h"

#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_PNG
namespace stb_image {
    #import "../libs/stb_image.h"
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        const float shift = 1.0/MAP_SCALE;
        int info[3];
        unsigned int *map = (unsigned int *)stb_image::stbi_load("../maps/map.png",info,info+1,info+2,4);
        if(map) {
            NSLog(@"%d,%d,%d",info[0],info[1],info[2]);
            int addr = 0;
            unsigned int p = map[addr];
            int x = (p>>16)-MAP_OFFSET;
            int y = (p&0xFFFF)-MAP_OFFSET;
            NSLog(@"%f,%f",x*shift,y*shift);
            addr = (info[1]-1)*info[0]+(info[0]-1);
            p = map[addr];
            x = (p>>16)-MAP_OFFSET;
            y = (p&0xFFFF)-MAP_OFFSET;
            NSLog(@"%f,%f",x*shift,y*shift);
        }
    }
}