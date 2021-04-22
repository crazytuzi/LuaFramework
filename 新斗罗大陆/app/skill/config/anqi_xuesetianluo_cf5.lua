	local anqi_xuesetianluo_cf5 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
				CLASS = "action.QSBRemoveBuff",
				OPTIONS = {buff_id = "anqi_xuesetianluo_cf5"},
			},
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_hudun5"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {buff_id = "anqi_xuesetianluo_hudun_cf5"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_didang5"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_didang5_1"},
            },
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {buff_id = "anqi_xuesetianluo_didang_cf5"},
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

return anqi_xuesetianluo_cf5




