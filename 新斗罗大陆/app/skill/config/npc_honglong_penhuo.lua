
local npc_honglong_penhuo = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
			 CLASS = "composite.QSBSequence",
			 ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 0.5},
				},
				{
					CLASS = "action.QSBHitTimer",
				},
			},
		},
		{
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
				{
					CLASS = "action.QSBHitTarget",
				},
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return npc_honglong_penhuo

