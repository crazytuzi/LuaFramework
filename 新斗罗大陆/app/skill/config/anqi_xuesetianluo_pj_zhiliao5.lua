	local anqi_xuesetianluo_pj_zhiliao1 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
			{
                CLASS = "action.QSBApplyBuff",
                OPTIONS = {teammate_and_self = true, buff_id = "anqi_xuesetianluo_pj_zhiliao5"},
            },
			{
				CLASS = "action.QSBChangeRecoverHpLimit",
				OPTIONS = {percent = -0.11},
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

return anqi_xuesetianluo_pj_zhiliao1




