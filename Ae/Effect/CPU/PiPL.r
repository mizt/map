#include "AEConfig.h"
#include "AE_EffectVers.h"
#include "AE_General.r"

resource 'PiPL' (16000) {
	{
		Kind {
			AEEffect
		},
		Name {
			"Plugin"
		},
		Category {
			"CPU"
		},
		CodeMacARM64 {"EffectMain"},
		AE_PiPL_Version {
			2,
			0
		},
		AE_Effect_Spec_Version {
			PF_PLUG_IN_VERSION,
			PF_PLUG_IN_SUBVERS
		},
		AE_Effect_Version {
			1048576
		},
		AE_Effect_Info_Flags {
			0
		},
		AE_Effect_Global_OutFlags {
			1<<1
		},
		AE_Effect_Global_OutFlags_2 {
			0x8000000
		},
		AE_Effect_Match_Name {
			"Ae.CPU.Plugin"
		},
		AE_Reserved_Info {
			0
		}
	}
};

