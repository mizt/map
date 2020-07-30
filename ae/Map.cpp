#include "Map.h"

static PF_Err GlobalSetup(PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {
    
    PF_Err err = PF_Err_NONE;
    
    out_data->my_version = PF_VERSION(2,0,0,PF_Stage_DEVELOP,0);
    out_data->out_flags = PF_OutFlag_WIDE_TIME_INPUT;
    
    return err;
}

static PF_Err ParamsSetup(PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {
    
    PF_Err err = PF_Err_NONE;
    PF_ParamDef def;
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_LAYER("Target",PF_LayerDefault_MYSELF,MAP_LAYER_DISK_ID);
    
    out_data->num_params = MAP_NUM_PARAMS;
    
    return err;
}

static PF_Err Render(PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {
    
    PF_Err err = PF_Err_NONE;
    PF_Err err2 = PF_Err_NONE;
    int32_t num_channelsL = 0;
    PF_Rect halfsies = {0,0,0,0};
    PF_ParamDef param;
    PF_ChannelDesc desc;
    PF_ChannelRef ref;
    PF_ChannelChunk chunk;
    PF_Boolean found_depthPB;
    
    AEFX_CLR_STRUCT(param);
    
    err = in_data->inter.checkout_param((in_data)->effect_ref,MAP_LAYER,in_data->current_time,in_data->time_step,in_data->time_scale,&param);

    if(!err) {
        
        if(param.u.ld.data) {
                    
            unsigned int *dst = (unsigned int *)output->data;

            int dstWidth = output->width;
            int dstHeight = output->height;
            int dstRow = output->rowbytes>>2;
            
            PF_EffectWorld *input = &params[MAP_INPUT]->u.ld;
            PF_EffectWorld *data = &param.u.ld;
            
            unsigned int *src = (unsigned int *)input->data;
            
            int srcWidth = input->width;
            int srcHeight = input->height;
            int srcRow = input->rowbytes>>2;
            
            unsigned int *map = (unsigned int *)data->data;
            
            int mapWidth = data->width;
            int mapHeight = data->height;
            int mapRow = data->rowbytes>>2;
            
            for(int i=0; i<dstHeight; i++) {
                for(int j=0; j<dstWidth; j++) {
                    
                    if(j<mapWidth&&i<mapHeight) {
                        
                        unsigned int xy = map[i*mapRow+j];
                        
                        unsigned char a = (xy)&0xFF;
                        unsigned char r = (xy>>8)&0xFF;
                        unsigned char g = (xy>>16)&0xFF;
                        unsigned char b = (xy>>24)&0xFF;
                                
                        int x = ((((a<<8|b)-0x7FFF)>>2))*scaleX;
                        int y = ((((g<<8|r)-0x7FFF)>>2))*scaleY;
                                
                        if(x>=0&&x<srcWidth&&y>=0&&y<srcHeight) {
                            dst[i*dstRow+j] = src[y*srcRow+x];
                        }
                        else {
                            dst[i*dstRow+j] = 0xFF0000FF;
                        }                        
                    }
                    else {
                        dst[i*dstRow+j] = 0xFF0000FF;
                    }
                    
                }
            }
        }
        else {
                        
            int width = output->width;
            int height = output->height;
            
            unsigned int *dst = (unsigned int *)output->data;
            int dstRow = output->rowbytes>>2;
            
            for(int i=0; i<height; i++) {
                for(int j=0; j<width; j++) {
                    
                    dst[i*dstRow+j] = 0xFF0000FF;
                }
            }
        }
    }

    ERR2(PF_CHECKIN_PARAM(in_data,&param)); // ALWAYS check in, even if invalid param.
    return err;
}

PF_Err EffectMain(PF_Cmd cmd, PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {
    
    PF_Err err = PF_Err_NONE;

    try {
        switch (cmd) {
                
            case PF_Cmd_GLOBAL_SETUP:
                err = GlobalSetup(in_data,out_data,params,output);
                break;
            case PF_Cmd_PARAMS_SETUP:
                err = ParamsSetup(in_data,out_data,params,output);
                break;
            case PF_Cmd_RENDER:
                err = Render(in_data,out_data,params,output);
                break;
                
            default:
                break;
        }
    }
    catch(PF_Err &thrown_err) {
        // Never EVER throw exceptions into AE.
        err = thrown_err;
    }
    
    return err;
}

