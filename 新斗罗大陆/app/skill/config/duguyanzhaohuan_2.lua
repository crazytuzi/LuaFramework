local duguyanzhaohuan_2 = {
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
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBPlayEffect",  --出手特效
                    OPTIONS = {effect_id = "duguyan_attack11_3_1", is_hit_effect = false},
                },
            },
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
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBSummonMonsters",
                    OPTIONS = {wave = -2,attacker_level = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",     
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                },
                },
        },
    },
}

return duguyanzhaohuan_2