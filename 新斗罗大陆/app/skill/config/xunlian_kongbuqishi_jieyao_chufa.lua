local xunlian_kongbuqishi_jieyao_chufa = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                { 
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "xunlian_kongbuqishi_liuxue_die"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "xunlian_kongbuqishi_liuxue"},
                        },
                        {
                            CLASS = "action.QSBRemoveBuff",
                            OPTIONS = {is_target = false, buff_id = "xunlian_kongbuqishi_liuxue_dot", remove_all_same_buff_id = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return xunlian_kongbuqishi_jieyao_chufa