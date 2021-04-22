local ultra_soul_reaper = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
	            	CLASS = "action.QSBApplyBuff",
	            	OPTIONS = {buff_id = "soul_reaper_buff", lowest_hp_teammate = true, no_cancel = true}
	        	},
	        	{
					CLASS = "action.QSBAttackFinish",
				},
            },
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
	            	CLASS = "action.QSBApplyBuff",
	            	OPTIONS = {buff_id = "soul_reaper_buff_1", lowest_hp_teammate = true, no_cancel = true}
	        	},
            },
		},
	},
}

return ultra_soul_reaper