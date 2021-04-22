local ultra_armorof_frost = {
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
			CLASS = "composite.QSBSequence",
			ARGS = {
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlayAnimation",
			                OPTIONS = {animation = "attack14"},
						},
						{
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 26},
                                },
								{
					            	CLASS = "action.QSBApplyBuff",
					            	OPTIONS = {buff_id = "armorof_frost_buff", lowest_hp_teammate = true, no_cancel = true}
					        	},
					        },
					    },
		            },
				},
        		{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
	},
}

return ultra_armorof_frost