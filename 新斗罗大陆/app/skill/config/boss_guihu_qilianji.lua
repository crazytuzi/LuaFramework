local boss_guihu_qilianji = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
			{
                CLASS = "action.QSBPlayLoopEffect",
                OPTIONS = {effect_id = "guihu_hongkuang"},
            },
			{
			CLASS = "composite.QSBSequence",
             ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
				{
                CLASS = "action.QSBStopLoopEffect",
                OPTIONS = {effect_id = "guihu_hongkuang"},
                },
				},
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
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_guihu_qilianji