	local anqi_shenpanzhijian_debuff_cf0 ={
	   CLASS = "composite.QSBSequence",
	    ARGS = {
			{
				CLASS = "action.QSBPlayEffect",
				OPTIONS = {is_hit_effect = true},
			},
			-- {			
	            -- CLASS = "action.QSBArgsConditionSelector",
	            -- OPTIONS = {
	                -- failed_select = 2,
	                -- {expression = "self:is_pvp=true", select = 1},
	                -- {expression = "self:is_pvp=false", select = 2},

	            -- }
	        -- },
			-- {
				-- CLASS = "composite.QSBSelector",
				-- ARGS =
				-- {
					-- {
						-- CLASS = "composite.QSBSequence",
						-- ARGS = 
						-- {

							-- {
								-- CLASS = "action.QSBExpression",
								-- OPTIONS = {
									-- expStr = "value = {48*self:attack_f}",
									-- set_black_board = {value = "value"},
									-- debug = true,
								-- }, -- 取攻击力的百分比
							-- },
							-- {
								-- CLASS = "action.QSBArgsSelectTarget",
								-- OPTIONS = {just_hero = true, under_status = "heianzhili", set_black_board = {selectTarget = "selectTarget"},},
							-- },
							-- {
								-- CLASS = "action.QSBDecreaseAbsorbByProp",
								-- OPTIONS = {
									-- get_black_board = {value = "value", selectTarget = "selectTarget"},
								-- },
							-- },
							-- {
								-- CLASS = "action.QSBDecreaseAbsorbByProp",
								-- OPTIONS = {
									-- get_black_board = {value = "value", selectTarget = "selectTarget"},
								-- },
							-- },
							-- {
								-- CLASS = "action.QSBApplyBuff",
								-- OPTIONS = {buff_id = "anqi_shenpanzhijian_jingdun5",is_target = true},
							-- },
						-- },
					-- },
					-- {
						-- CLASS = "composite.QSBSequence",
						-- ARGS = 
						-- {	
							{
								CLASS = "action.QSBApplyBuff",
								OPTIONS = {buff_id = "anqi_shenpanzhijian_jingdun5",is_target = true},
							},
							-- {
								-- CLASS = "action.QSBExpression",
								-- OPTIONS = {
									-- expStr = "value = {34*self:attack_f}",
									-- set_black_board = {value = "value"},
								-- }, -- 取攻击力的百分比
							-- },
							-- {
								-- CLASS = "action.QSBDecreaseAbsorbByProp",
								-- OPTIONS = {
									-- get_black_board = {value = "value"},
									-- target_enemy = true,
								-- },
							-- },
							-- {
								-- CLASS = "action.QSBExpression",
								-- OPTIONS = {
									-- expStr = "damage_addition = {1*self:attack_f}",
									-- set_black_board = {damage_addition = "damage_addition"},
								-- }, -- 取攻击力的
							-- },
							{
								CLASS = "action.QSBHitTarget",
								-- OPTIONS = {
									-- get_black_board = {damage_addition = "damage_addition"},
								-- },
							},  
							{
								CLASS = "action.QSBHitTarget",
								-- OPTIONS = {
									-- get_black_board = {damage_addition = "damage_addition"},
								-- },
							},  
						-- },
					-- },
				-- -- },
			-- },
			{
				CLASS = "action.QSBPlayMountSkillAnimation",
			},
			{
				CLASS = "action.QSBPlayEffect",
				OPTIONS = {effect_id = "anqi_shenpanzhijian_shouji1",is_hit_effect = true},
			},
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_shenpanzhijian_debuff_cf0




