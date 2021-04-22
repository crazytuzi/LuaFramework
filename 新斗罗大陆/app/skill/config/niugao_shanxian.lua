
local niugao_shanxian = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "boss_niugao_attack11_1", is_hit_effect = false},
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
            OPTIONS = {pos = {x = 700, y = 300}},
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
                    OPTIONS = {animation = "attack21"},       
                }, 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "boss_niugao_attack21_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "boss_niugao_attack21_1_1", is_hit_effect = false},
                },
            },
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return niugao_shanxian