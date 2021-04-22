
local zilong_zhaohuan = {
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
            OPTIONS = {effect_id = "zilong_housheng",is_hit_effect = false},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.8},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -1,attacker_level = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",     
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
            },
        },
    },
}

return zilong_zhaohuan