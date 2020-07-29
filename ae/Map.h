#pragma once

#ifndef MAP_H
#define MAP_H

#include "AEConfig.h"
#include "entry.h"

#include "AE_Effect.h"
#include "AE_EffectCB.h"		
#include "AE_Macros.h"
#include "AE_ChannelSuites.h"
#include "AE_EffectSuites.h"

#include "Param_Utils.h"
#include "AEFX_SuiteHelper.h"// PICA Suite Stuff
#include "DuckSuite.h"

enum {
	MAP_INPUT = 0,
	MAP_LAYER,
	MAP_NUM_PARAMS
};

enum {
	MAP_LAYER_DISK_ID = 1,
};

extern "C" {

	PF_Err EffectMain ( PF_Cmd cmd, PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output);
}

#endif // MAP_H
