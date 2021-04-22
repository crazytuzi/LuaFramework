local ultra_bombarded_1 = {	
	CLASS = "composite.QSBParallel",
	ARGS = {
		-- animation
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
		        {
                    CLASS = "action.QSBHitTimer",
                },
		        {
		            CLASS = "action.QSBAttackFinish",
		        },
			},
		},
	},
} 

return ultra_bombarded_1