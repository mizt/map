#import <Cocoa/Cocoa.h>
#import <simd/simd.h>

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

bool intersection(simd::float4 *P12,simd::float4 *P34,simd::float2 *P) {
    
    double delta = (P12->z-P12->x)*(P34->w-P34->y)-(P12->w-P12->y)*(P34->z-P34->x);
    if(delta==0) return false;
    
    double r = ((P34->w-P34->y)*(P34->z-P12->x)-(P34->z-P34->x)*(P34->w-P12->y))/delta;
    double s = ((P12->z-P12->x)*(P34->w-P12->y)-(P12->w-P12->y)*(P34->z-P12->x))/delta;

    if((r>=0&&r<=1)&&(s>=0&&s<=1)) {
        P->x = round(P12->x+r*(P12->z-P12->x));
        P->y = round(P12->y+r*(P12->w-P12->y));
        return true;
    }

    return false;
}

int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        
        int W = 1920;
        int H = 1080;
        
        double shift = 4.0;
        
        unsigned int *dst = new unsigned int[W*H];
        
        double cx = W*0.5;
        double cy = H*0.5;
        double radius = 1920;
        double angle = -8;
                
        for(int i=0; i<H; i++) {
            
            const double dy = i-cy;
            
            for(int j=0; j<W; j++) {
                    
                const double dx = j-cx;
                const double distance = sqrt((dx*dx)+(dy*dy));
                                
                int sx = j;
                int sy = i;
                                
                if(distance<radius) {
                                    
                    double percent = (radius-distance)/radius;
                    double theta = percent*percent*angle;
                             
                    double c = cos(theta);
                    double s = sin(theta);
                                                
                    sx = int(dx*c-dy*s+cx);
                    sy = int(dx*s+dy*c+cy);
                        
                    if(sx<0) sx = 0;
                    else if(sx>W-1) sx = W-1;

                    if(sy<0) sy = 0;
                    else if(sy>H-1) sy = H-1;

                }
                            
                dst[i*W+j] = ((int)(0x7FFF+(sx)*shift))<<16|((int)(0x7FFF+(sy)*shift));

            }
        }
        
        stb_image::stbi_write_png("../../maps/map.png",W,H,4,(void const*)dst,W<<2);
        
        delete[] dst;
        
    }
}