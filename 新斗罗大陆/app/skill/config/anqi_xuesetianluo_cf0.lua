	local anqi_xuesetianluo_cf1 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
				CLASS = "action.QSBRemoveBuff",
				OPTIONS = {buff_id = "anqi_xuesetianluo_cf0"},
			},
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_hudun0"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {buff_id = "anqi_xuesetianluo_hudun_cf0"},
            },
			-- {
                -- CLASS = "action.QSBApplyBuff",
                -- OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_didang3"},
            -- },
			-- {
                -- CLASS = "action.QSBApplyBuff",
                -- OPTIONS = {buff_id = "anqi_xuesetianluo_didang_cf3"},
            -- },
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

return anqi_xuesetianluo_cf1




