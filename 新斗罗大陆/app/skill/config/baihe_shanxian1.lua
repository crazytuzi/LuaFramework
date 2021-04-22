
local baihe_shanxian1 = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
				{
				CLASS = "composite.QSBSequence",
				ARGS = {
				       {
                           CLASS = "action.QSBDelayTime",
                           OPTIONS = {delay_time = 0.55},
                       },
				       {
                          CLASS = "action.QSBActorFadeOut",
                          OPTIONS = {duration = 0.05, revertable = true},
                       },
					   },
				},
            },
        },
		{
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos = {x = 600, y = 300}},
        },
		{
			CLASS = "composite.QSBParallel",
			ARGS = {
					{
						CLASS = "action.QSBActorFadeIn", revertable = true,
						OPTIONS = {duration = 0.05},
					},
					{
						CLASS = "action.QSBPlayAnimation",
						OPTIONS = {animation = "attack15_2"},       
					}, 
					},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return baihe_shanxian1