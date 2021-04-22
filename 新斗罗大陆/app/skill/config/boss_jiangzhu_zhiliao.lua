

local treat_tongyong = {
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBArgsIsTeammate",
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBPlaySound"
						},
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
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
						                    OPTIONS = {delay_frame = 12},
                                        }, 
										{
											CLASS = "action.QSBPlayEffect",
											OPTIONS = {is_hit_effect = true},
										},
										{
											CLASS = "action.QSBHitTarget",
											OPTIONS = {is_auto_choose_target = false},
										},
									},
								},
							},
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBPlayAnimation",
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
			},
		},
	},
}

return treat_tongyong