	local anqi_shenpanzhijian_debuff_cf0 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
				CLASS = "action.QSBArgsConditionSelector",
				OPTIONS = {
					failed_select = 2,
					{expression = "target:get_absorb_value>0", select = 1},
				}
			},
			{
                CLASS = "composite.QSBSelector",
                ARGS = {
					{
                        CLASS = "composite.QSBSequence",
                        ARGS = {
							{
								CLASS = "action.QSBHitTarget",
								OPTIONS = {damage_scale = 2},
							},
						},
					},
					{
                        CLASS = "composite.QSBSequence",
                        ARGS = {
							{
								CLASS = "action.QSBHitTarget",
							},
						},
					},
				},
			},
			{
				CLASS = "action.QSBPlayEffect",
				OPTIONS = {is_hit_effect = true},
			},
			{
				CLASS = "action.QSBPlayMountSkillAnimation",
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




