
local zhaohuanzhizhu3 = {
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
	                OPTIONS = {delay_time = 0.8},
	            },
	            {
	            	CLASS = "action.QSBSummonMonsters",
	            	OPTIONS = {wave = -3},
	            },
            },
        },
    },
}

return zhaohuanzhizhu3