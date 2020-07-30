#pragma once

#ifndef MAP_H
#define MAP_H

#include "AE_Macros.h"
#include "Param_Utils.h"

enum {
	MAP_INPUT = 0,
	MAP_LAYER,
	MAP_NUM_PARAMS
};

extern "C" {

	PF_Err EffectMain(PF_Cmd cmd, PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output);
}

#endif
