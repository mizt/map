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
        
        float scale = -0.5;
        
        if(scale<=-1) scale = -1;
        else if(scale>=1) scale = 1;
                
        float amp = 200.0;
                
        int W = 1920;
        int H = 1080;
        
        double shift = 4.0;
        
        unsigned int *dst = new unsigned int[W*H];
        
        simd::float4 TOP = simd::float4{-1.0,0.0,(float)W,0.0};
        simd::float4 LEFT = simd::float4{0.0,-1.0,0.0,(float)H};

        simd::float4 BOTTOM = simd::float4{-1.0,(float)(H-1),(float)W,(float)(H-1)};
        simd::float4 RIGHT = simd::float4{(float)(W-1),-1.0,(float)(W-1),(float)H};
        
        float theta = (90.0*scale*M_PI)/180.0;
        
        simd::float2 P = simd::float2{0,0};

        float w[4];
        w[0] = (0)*sin(theta)+(0)*cos(theta);
        w[1] = (0)*sin(theta)+(H-1)*cos(theta);
        w[2] = (W-1)*sin(theta)+(0)*cos(theta);
        w[3] = (W-1)*sin(theta)+(H-1)*cos(theta);
        
        float min = fmin(fmin(fmin(w[0],w[1]),w[2]),w[3]);
        float max = fmax(fmax(fmax(w[0],w[1]),w[2]),w[3]);

        for(int i=0; i<H; i++) {
            for(int j=0; j<W; j++) {
                    
                double j2 = j*cos(theta)-i*sin(theta);
                double i2 = j*sin(theta)+i*cos(theta);
                
                i2 -= amp*sin(8*(j2/(double)max)*M_PI);
                
                P.x = (j2*cos(-theta)-i2*sin(-theta));
                P.y = (j2*sin(-theta)+i2*cos(-theta));
                
                simd::float4 L = simd::float4{(float)j,(float)i,P.x,P.y};
                
                if(P.x<0||P.y<0) {
                    if(!intersection(&L,&TOP,&P)) {
                        intersection(&L,&LEFT,&P);
                    }
                }
                
                if(P.x>W-1||P.y>H-1) {
                    if(!intersection(&L,&BOTTOM,&P)) {
                        intersection(&L,&RIGHT,&P);
                    }
                }
                
                dst[i*W+j] = ((int)(0x7FFF+(P.x)*shift))<<16|((int)(0x7FFF+(P.y)*shift));

            }
        }
        
        stb_image::stbi_write_png("../../maps/map.png",W,H,4,(void const*)dst,W<<2);
        
        delete[] dst;
        
    }
}