	local anqi_shenpanzhijian_debuff_cf0 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
                  CLASS = "action.QSBArgsIsUnderStatus",
                  OPTIONS = {is_attackee = true, status = "heianzhili", reverse_result = true},
			},
			{
                CLASS = "composite.QSBSelector",
                ARGS = {
					{
                        CLASS = "composite.QSBSequence",
                        ARGS = {
							{			
								CLASS = "action.QSBArgsConditionSelector",
								OPTIONS = {
									failed_select = 2,
									{expression = "self:is_pvp=true", select = 1},
									{expression = "self:is_pvp=false", select = 2},

								}
							},
							{
								CLASS = "composite.QSBSelector",
								ARGS = {
									{
										CLASS = "composite.QSBSequence",
										ARGS = {
											{
												CLASS = "action.QSBArgsSelectTarget",
												OPTIONS = {just_hero = true, under_status = "heianzhili", set_black_board = {selectTarget = "selectTarget"},},
											},
											{
												CLASS = "action.QSBRemoveBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_debuff4",remove_all_same_buff_id = true,get_black_board = {selectTarget = "selectTarget"}, debug = true},
											},
											{
												CLASS = "action.QSBRemoveBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_dot_tick4"},
											},
											{
												CLASS = "action.QSBApplyBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_debuff4",is_target =true},
											},
											{
												CLASS = "action.QSBApplyBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_dot_tick4"},
											},
										},
									},
									{
										CLASS = "composite.QSBSequence",
										ARGS = {
											{
												CLASS = "action.QSBArgsSelectTarget",
												OPTIONS = {just_hero = true, under_status = "heianzhili", set_black_board = {selectTarget = "selectTarget"},},
											},
											{
												CLASS = "action.QSBRemoveBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_debuff4",remove_all_same_buff_id = true,get_black_board = {selectTarget = "selectTarget"}, debug = true},
											},
											{
												CLASS = "action.QSBRemoveBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_pve_dot4",remove_all_same_buff_id = true,get_black_board = {selectTarget = "selectTarget"}, debug = true},
											},
											{
												CLASS = "action.QSBRemoveBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_dot_tick4"},
											},
											{
												CLASS = "action.QSBApplyBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_debuff4",is_target =true},
											},
											{
												CLASS = "action.QSBApplyBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_pve_dot4",is_target =true},
											},
											{
												CLASS = "action.QSBApplyBuff",
												OPTIONS = {buff_id = "anqi_shenpanzhijian_dot_tick4"},
											},
										},
									},
								},
							},
						},
					},
				},
			},
         	-- {
          --       CLASS = "action.QSBHitTarget",
          --   },
			{
				CLASS = "action.QSBAttackFinish"
			},
	    },
	}

return anqi_shenpanzhijian_debuff_cf0




