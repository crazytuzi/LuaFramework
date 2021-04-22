
local tongyongzhaohuan_1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3},
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="jiguan_feidao",is_loop = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 6},
                },
                {
                    CLASS = "action.QSBStopSound",
                    OPTIONS = {sound_id ="jiguan_feidao"},
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
                    OPTIONS = {wave = -10,attacker_level = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",     
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
            },
        },
    },
}

return tongyongzhaohuan_1