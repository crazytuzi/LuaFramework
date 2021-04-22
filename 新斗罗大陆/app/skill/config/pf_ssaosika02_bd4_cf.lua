local shifa_tongyong = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
    	{
            CLASS = "action.QSBArgsIsUnderStatus",
            OPTIONS = {is_attacker = true,status = "ssaosika_zhenji_beidong4_jc"},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                    	{
				          CLASS = "action.QSBAttackFinish",
				        },
			        },
		        },
		        {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                    	-- {
                     --        CLASS = "action.QSBApplyBuff",
                     --        OPTIONS = {is_target = true, buff_id = "ssaosika_zhenji_beidong4"}
                     --    },
                        -- {
                        --     CLASS = "action.QSBApplyBuff",
                        --     OPTIONS = {is_target = true, buff_id = "ssaosika_zhenji_beidong4_jc"}
                        -- },
                        {
                          CLASS = "action.QSBHitTarget",
                        },
                    	{
				          CLASS = "action.QSBAttackFinish",
				        },
			        },
		        },
	        },
        },
    },
}
return shifa_tongyong