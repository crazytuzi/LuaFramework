
local xiaobianfu_zibao = {
     CLASS = "composite.QSBSequence",
     ARGS = {
	 CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
		CLASS = "composite.QSBSequence",
        ARGS = {
		{
        CLASS = "action.QSBDelayTime",
        OPTIONS = {delay_time = 0.5},
        },
		{
          CLASS = "action.QSBPlayEffect",
          OPTIONS = {is_hit_effect = false,effect_id = "zdb_atk11_3"},
        },
		{
               CLASS = "action.QSBHitTarget",
        },
		},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return xiaobianfu_zibao