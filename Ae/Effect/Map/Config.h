#define IDENTIFIER @"Ae.CPU.Map"

namespace Params {
    enum {
        INPUT = 0,
        LAYER,
        BILINEAR,
        X,
        Y,
        NUM
    };
}

static PF_Err ParamsSetup(PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {
    
    PF_Err err = PF_Err_NONE;
    PF_ParamDef def;
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_LAYER("Target",PF_LayerDefault_MYSELF,Params::LAYER);
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_CHECKBOX("Bilinear","ON",TRUE,0,Params::BILINEAR);
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_SLIDER("X",0,100,0,100,100,Params::X);
    
    AEFX_CLR_STRUCT(def);
    PF_ADD_SLIDER("Y",0,100,0,100,100,Params::Y);
    
    out_data->num_params = Params::NUM;
    return err;
}