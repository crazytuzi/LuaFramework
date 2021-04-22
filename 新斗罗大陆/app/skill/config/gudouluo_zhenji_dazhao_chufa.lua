local gudouluo_zhenji_dazhao_chufa = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {lowest_hp = true, change_all_node_target = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {  
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 15},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "gudouluo_zhenji_dazhao_duoqu", is_target = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return gudouluo_zhenji_dazhao_chufa