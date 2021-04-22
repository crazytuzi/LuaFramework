	local anqi_kongjuzhiyan_debuff_jc ={
	    CLASS = "composite.QSBSequence",
	    ARGS = { 
			-- {
				-- CLASS = "action.QSBArgsIsUnderStatus",
				-- OPTIONS = {is_attackee = true, status = "kongjuzhiyan_ganran"},
			-- },
			-- {
				-- CLASS = "composite.QSBSelector",
				-- ARGS = { 
					{
						CLASS = "composite.QSBSelector",
						ARGS = { 
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 1, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 2, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 3, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 4, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 5, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 6, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 7, trigger_skill_id = 40781,target_type = "enemy" }
							},{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 8, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 9, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 10, trigger_skill_id = 40781,target_type = "enemy" }
							},
							{
								CLASS = "action.QSBAttackByBuffNum",
								OPTIONS = { buff_id = "kongjuzhiyan_dot_ganran0",num_pre_stack_count = 11, trigger_skill_id = 40781,target_type = "enemy" }
							},
							
						},
					},
					-- {
						-- CLASS = "action.QSBPlayMountSkillAnimation",
					-- },
				-- },
			-- },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_kongjuzhiyan_debuff_jc




