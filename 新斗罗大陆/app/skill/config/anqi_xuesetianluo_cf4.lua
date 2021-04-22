	local anqi_xuesetianluo_cf4 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
				CLASS = "action.QSBRemoveBuff",
				OPTIONS = {buff_id = "anqi_xuesetianluo_cf4"},
			},
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_hudun4"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {buff_id = "anqi_xuesetianluo_hudun_cf4"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_didang4"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_didang4_1"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {buff_id = "anqi_xuesetianluo_didang_cf4"},
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

return anqi_xuesetianluo_cf4




