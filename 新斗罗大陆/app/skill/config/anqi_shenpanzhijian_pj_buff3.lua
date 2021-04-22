	local anqi_shenpanzhijian_debuff_cf0 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
				CLASS = "action.QSBApplyBuff",
				OPTIONS = {buff_id = "anqi_shenpanzhijian_pj_buff3"},
			},
			{
				CLASS = "action.QSBApplyBuff",
				OPTIONS = {buff_id = "anqi_shenpanzhijian_pj_buff_tx"},
			},
         	-- {
          --       CLASS = "action.QSBHitTarget",
          --   },
			{
				CLASS = "action.QSBPlayMountSkillAnimation",
			},
			{
				CLASS = "action.QSBAttackFinish"
			},
	    },
	}

return anqi_shenpanzhijian_debuff_cf0




