
local zudui_boss_baihe_longjuanfeng2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
        	CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1},
                },
	            {
	            	CLASS = "action.QSBSummonMonsters",
	            	OPTIONS = {wave = -2},
	            },
            },
        },
    },
}

return zudui_boss_baihe_longjuanfeng2