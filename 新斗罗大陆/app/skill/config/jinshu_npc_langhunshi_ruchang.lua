local jump_appear = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
		        {
		            CLASS = "action.QSBPlayAnimation",
		            OPTIONS = {animation = "attack12_2"},
		            ARGS = 
		            {
		                {
		                    CLASS = "action.QSBHitTarget",
		                },
		            },
		        },
		        {
		            CLASS = "composite.QSBSequence",
		            ARGS = 
		            {
		                {
		                    CLASS = "action.QSBDelayTime",
		                    OPTIONS = {delay_time = 12/24 },
		                },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 8, duration = 0.3, count = 2,},
                        },
		            },
		        },
	        },
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}
return jump_appear