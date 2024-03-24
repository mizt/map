#include <math.h>
#include "../4K.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#define STBI_ONLY_PNG
namespace stb_image {
    #import "../libs/stb_image_write.h"
}

int main(int argc, char *argv[]) {
    unsigned int *map = new unsigned int[MAP_W*MAP_H];
    for(int i=0; i<MAP_H; i++) {
        for(int j=0; j<MAP_W; j++) {
            unsigned short x = MAP_OFFSET+(int)(j*MAP_SCALE);
            unsigned short y = MAP_OFFSET+(int)(i*MAP_SCALE);
            map[i*MAP_W+j] = x<<16|y;
        }
    }
    stb_image::stbi_write_png("../maps/map.png",MAP_W,MAP_H,4,(void const*)map,MAP_W<<2);
    delete[] map;
}