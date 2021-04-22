
local boss_baihe_shanxian = {
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
 							CLASS = "action.QSBPlayEffect",
 							OPTIONS = {is_hit_effect = false},
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
            CLASS = "action.QSBTeleportToTargetBehind",
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
					{
 							CLASS = "action.QSBPlayEffect",
 							OPTIONS = {effect_id = "boss_baihe_chuxian", is_hit_effect = false},
                    },
					},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_baihe_shanxian