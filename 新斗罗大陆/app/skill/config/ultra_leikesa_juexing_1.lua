local ultra_leikesa_juexing_1 = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "composite.QSBSequence",
			ARGS =
			{
				{
					CLASS = "action.QSBSummonGhosts",
	            	OPTIONS = {actor_id = 10051, life_span = 8.0, relative_pos = {x = -250, y = 0},no_haste = false}
				},
				{
					CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}
return ultra_leikesa_juexing_1