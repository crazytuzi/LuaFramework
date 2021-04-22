
local division_variation_of_ooze = {
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
            OPTIONS = {is_hit_effect = false, effect_id = "division_variation_of_ooze"},
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
	            	OPTIONS = {wave = -1},
	            },
            },
        },
    },
}

return division_variation_of_ooze