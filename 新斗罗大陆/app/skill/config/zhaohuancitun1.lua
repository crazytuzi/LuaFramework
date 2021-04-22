
local zhaohuancitun1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
        	CLASS = "composite.QSBSequence",
            ARGS = 
            {
	        	{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 0.8},
	            },
	            {
	            	CLASS = "action.QSBSummonMonsters",
	            	OPTIONS = {wave = -1},
	            },
            },
        },
    },
}

return zhaohuancitun1