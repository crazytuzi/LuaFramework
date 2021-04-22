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

					},
				},
				{
					CLASS = "composite.QSBSelector",
					ARGS = { 
						{
							CLASS = "composite.QSBSequence",
							ARGS = { 
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 5},
								},
								{
									CLASS = "action.QSBArgsNumber",
									OPTIONS = {is_all_enemies = true, status_number = true, stub_status = "kongjuzhiyan_ganran"},
								},
								{
									CLASS = "composite.QSBSelectorByNumber",
									ARGS = 
									{       
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 0},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 1},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 1.25},
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 2},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 1.5},
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 3},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 1.75,dragon_modifier= 1.15},
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 4, mode = "<="},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 2,dragon_modifier= 1.07},
												},	
											},
										},
									},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = { 
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_frame = 5},
								},
								{
									CLASS = "action.QSBArgsNumber",
									OPTIONS = {is_all_enemies = true, status_number = true, stub_status = "kongjuzhiyan_ganran"},
								},
								{
									CLASS = "composite.QSBSelectorByNumber",
									ARGS = 
									{       
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 0},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 1},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 0.062},
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 2},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 0.075},
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 3},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 0.087},
												},	
											},
										},
										{
											CLASS = "composite.QSBSequence",
											OPTIONS = {flag = 4, mode = "<="},
											ARGS = {
												{
													CLASS = "action.QSBHitTarget",
													OPTIONS = {damage_scale = 0.1},
												},	
											},
										},
									},
								},-- 
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = true},
								},
							},
						},
					},
						-- {
							-- CLASS = "action.QSBPlayMountSkillAnimation",
						-- },
				},
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_kongjuzhiyan_shanghai6




