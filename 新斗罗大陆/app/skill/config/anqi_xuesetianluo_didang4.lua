	local anqi_xuesetianluo_cf3 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_didang4"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_didang4_1"},
            },
         	-- {
          --       CLASS = "action.QSBHitTarget",
          --   },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_xuesetianluo_cf3




