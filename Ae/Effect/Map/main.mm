#import "AEConfig.h"
#import "AE_Effect.h"
#import "AE_Macros.h"
#import "Param_Utils.h"

#import <Cocoa/Cocoa.h>
#import <vector>

#import "Config.h"
#import "../../../4K.h"

static PF_Err Render(PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {
    
    PF_ParamDef param;
    AEFX_CLR_STRUCT(param);
    
    bool isBilinear = params[Params::BILINEAR]->u.bd.value;
    
    float sx = params[Params::X]->u.sd.value*0.01;
    float sy = params[Params::Y]->u.sd.value*0.01;
    
    double scaleX = (double)in_data->downsample_x.num/(double)in_data->downsample_x.den;
    double scaleY = (double)in_data->downsample_y.num/(double)in_data->downsample_y.den;
    
    PF_Err err = in_data->inter.checkout_param((in_data)->effect_ref,Params::LAYER,in_data->current_time,in_data->time_step,in_data->time_scale,&param);

    if(!err) {
        
        unsigned int *dst = (unsigned int *)output->data;
        int dstWidth = output->width;
        int dstHeight = output->height;
        int dstRow = output->rowbytes>>2;
        
        PF_EffectWorld *input = &params[Params::INPUT]->u.ld;
        unsigned int *src = (unsigned int *)input->data;
        int srcRow = input->rowbytes>>2;
        int srcWidth = input->width;
        int srcHeight = input->height;
        
        int type = 0;
        if(param.u.ld.data&&(dstWidth==srcWidth)&&(dstHeight==srcHeight)) {
            PF_EffectWorld *data = &param.u.ld;
            type = ((srcWidth==data->width)&&(srcHeight==data->height))?1:0;
        }
        
        if(type==1) {
            
            PF_EffectWorld *data = &param.u.ld;
            unsigned int *map = (unsigned int *)data->data;
            int mapRow = data->rowbytes>>2;
            
            float scale = 1.0/MAP_SCALE;

            if(!isBilinear) {
                
                for(int i=0; i<dstHeight; i++) {
                    for(int j=0; j<dstWidth; j++) {
                        
                        dst[i*dstRow+j] = 0x00000000;
                        
                        unsigned int xy = map[i*mapRow+j];
                        
                        unsigned char a = (xy)&0xFF;
                        unsigned char r = (xy>>8)&0xFF;
                        unsigned char g = (xy>>16)&0xFF;
                        unsigned char b = (xy>>24)&0xFF;
                        
                        float x = ((((a<<8|b)-MAP_OFFSET)*scale))*scaleX;
                        float y = ((((g<<8|r)-MAP_OFFSET)*scale))*scaleY;
                        
                        int x2 = (sx>1.0)?x*(1.0/sx):j*(1.0-sx)+x*sx;
                        int y2 = (sy>1.0)?y*(1.0/sy):i*(1.0-sy)+y*sy;
                        
                        if(x2<0) x2 = 0;
                        if(x2>=srcWidth-1) x2 = srcWidth-1;
                        
                        if(y2<0) y2 = 0;
                        if(y2>=srcHeight-1) y2 = srcHeight-1;

                        if(x2>=0&&x2<srcWidth&&y2>=0&&y2<srcHeight) {
                            dst[i*dstRow+j] = src[y2*srcRow+x2];
                        }
                    }
                }
            }
            else {
                
                for(int i=0; i<dstHeight; i++) {
                    for(int j=0; j<dstWidth; j++) {
                        
                        dst[i*dstRow+j] = 0x00000000;
                        
                        unsigned int xy = map[i*mapRow+j];
                        
                        unsigned char a = (xy)&0xFF;
                        unsigned char r = (xy>>8)&0xFF;
                        unsigned char g = (xy>>16)&0xFF;
                        unsigned char b = (xy>>24)&0xFF;
                        
                        float x = ((((a<<8|b)-MAP_OFFSET)*scale))*scaleX;
                        float y = ((((g<<8|r)-MAP_OFFSET)*scale))*scaleY;
                        
                        float x2 = (sx>1.0)?x*(1.0/sx):j*(1.0-sx)+x*sx;
                        float y2 = (sy>1.0)?y*(1.0/sy):i*(1.0-sy)+y*sy;
                        
                        if(x2<0) x2 = 0;
                        if(x2>=srcWidth-1) x2 = srcWidth-1;
                        
                        if(y2<0) y2 = 0;
                        if(y2>=srcHeight-1) y2 = srcHeight-1;
                        
                        int ix2 = x2;
                        int iy2 = y2;
                        
                        if(ix2>=0&&ix2<srcWidth&&iy2>=0&&iy2<srcHeight) {
                            
                            uint32 dx = (x2-ix2)*16.0;
                            uint32 dy = (y2-iy2)*16.0;
                            
                            unsigned int *s = src+(iy2*srcRow+ix2);
                            
                            uint32 s1 = *s;
                            if(dx) s++;
                            uint32 s2 = *s;
                            if(dy) s+=srcRow;
                            uint32 s3 = *s;
                            if(dx) s--;
                            uint32 s4 = *s;
                            
                            uint32 w1 = (0x10-dx)*(0x10-dy);
                            uint32 w2 = dx*(0x10-dy);
                            uint32 w3 = dx*dy;
                            uint32 w4 = (0x10-dx)*dy;
                            
                            uint32 a = ((s1)&0xFF)*w1;
                            a+=((s2)&0xFF)*w2;
                            a+=((s3)&0xFF)*w3;
                            a+=((s4)&0xFF)*w4;
                            a&=0xFF00;
                            
                            uint32 r = ((s1>>8)&0xFF)*w1;
                            r+=((s2>>8)&0xFF)*w2;
                            r+=((s3>>8)&0xFF)*w3;
                            r+=((s4>>8)&0xFF)*w4;
                            r&=0xFF00;
                            
                            uint32 g = ((s1>>16)&0xFF)*w1;
                            g+=((s2>>16)&0xFF)*w2;
                            g+=((s3>>16)&0xFF)*w3;
                            g+=((s4>>16)&0xFF)*w4;
                            g&=0xFF00;
                            
                            uint32 b = ((s1>>24)&0xFF)*w1;
                            b+=((s2>>24)&0xFF)*w2;
                            b+=((s3>>24)&0xFF)*w3;
                            b+=((s4>>24)&0xFF)*w4;
                            b&=0xFF00;
                            
                            dst[i*dstRow+j] = (b<<16|g<<8|r)|(a>>8);
                        }
                    }
                }
            }
        }
        else {
            
            for(int i=0; i<dstHeight; i++) {
                for(int j=0; j<dstWidth; j++) {
                    dst[i*dstRow+j] = 0xFF0000FF;
                }
            }
        }
    }
    
    
    ERR(PF_CHECKIN_PARAM(in_data,&param)); // ALWAYS check in, even if invalid param.
    return err;
}

static PF_Err GlobalSetup(PF_InData *in_data,PF_OutData *out_data,PF_ParamDef *params[],PF_LayerDef *output) {
    PF_Err 	err = PF_Err_NONE;
    out_data->my_version = PF_VERSION(2,0,0,PF_Stage_DEVELOP,0);
    out_data->out_flags = PF_OutFlag_WIDE_TIME_INPUT;
    out_data->out_flags2 = PF_OutFlag2_SUPPORTS_THREADED_RENDERING;
    return err;
}

extern "C" {
    PF_Err EffectMain(PF_Cmd cmd, PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output, void *extra) {
        PF_Err err = PF_Err_NONE;
        try {
            switch (cmd) {
                case PF_Cmd_GLOBAL_SETUP: err = GlobalSetup(in_data,out_data,params,output); break;
                case PF_Cmd_PARAMS_SETUP: err = ParamsSetup(in_data,out_data,params,output); break;
                case PF_Cmd_RENDER: {
                    @autoreleasepool {
                        err = Render(in_data,out_data,params,output); break;
                    }
                }
                default: break;
            }
        } catch(PF_Err &thrown_err) {
            err = thrown_err;
        }
        return err;
    }
}
