	local anqi_xuesetianluo_pj_zhiliao1 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
            -- {
            --   CLASS = "action.QSBApplyBuff",
            --   OPTIONS = {teammate_and_self = true, buff_id = "anqi_shenpanzhijian_ss_cf5"},
            -- },
            {
              CLASS = "action.QSBApplyBuff",
              OPTIONS = {teammate_and_self = true, buff_id = "anqi_shenpanzhijian_ss5"},
            },
            -- {
            --       CLASS = "action.QSBHitTarget",
            --   },
    	    	{
    	        CLASS = "action.QSBAttackFinish"
    	      },
	    },
	}

return anqi_xuesetianluo_pj_zhiliao1




