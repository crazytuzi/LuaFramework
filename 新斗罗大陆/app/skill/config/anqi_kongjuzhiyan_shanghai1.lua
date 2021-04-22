	local anqi_kongjuzhiyan_shanghai6 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = { 
			{
				CLASS = "action.QSBArgsIsUnderStatus",
				OPTIONS = {is_attackee = true, status = "kongjuzhiyan_ganran"},
			},
			{
				CLASS = "action.QSBArgsConditionSelector",
				OPTIONS = {
					failed_select = 2,
					{expression = "self:aptitude>22", select = 1},
					{expression = "self:aptitude=22", select = 1},
					{expression = "self:aptitude<22", select = 2},

				}
			},
			{
				CLASS = "composite.QSBSelector",
				ARGS = { 
					{
						CLASS = "composite.QSBParallel",
						ARGS = { 
							{
								CLASS = "action.QSBHitTarget",
							},
							{
								CLASS = "action.QSBPlayEffect",
								OPTIONS = {is_hit_effect = true},
							},
						},
					},
					{
						CLASS = "composite.QSBParallel",
						ARGS = { 
							{
								CLASS = "action.QSBHitTarget",
								OPTIONS = {damage_scale = 0.05},
							},
							{
								CLASS = "action.QSBPlayEffect",
								OPTIONS = {is_hit_effect = true},
							},
						},
					},
					-- {
						-- CLASS = "action.QSBPlayMountSkillAnimation",
					-- },
				},
			},
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_kongjuzhiyan_shanghai6




