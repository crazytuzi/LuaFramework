
local tongyongzhaohuan_3 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
	            {
	            	CLASS = "action.QSBSummonMonsters",
	            	OPTIONS = {wave = -3,attacker_level = true},
	            },
                {
                    CLASS = "action.QSBRemoveBuff",     
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
            },
        },
    },
}

return tongyongzhaohuan_3