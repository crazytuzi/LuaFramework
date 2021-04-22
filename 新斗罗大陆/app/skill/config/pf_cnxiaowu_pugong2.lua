
local pf_cnxiaowu_pugong2 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "composite.QSBParallel",            --普攻2第一段
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_chengnianxiaowu_pugong2_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_chengnianxiaowu_pugong2_4", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "composite.QSBParallel",            --普攻2第二段
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_chengnianxiaowu_pugong2_2", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_chengnianxiaowu_pugong2_5", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 9},
                },
                {
                    CLASS = "composite.QSBParallel",            --普攻2第三段
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pf_chengnianxiaowu_pugong2_3", is_hit_effect = false},
                        },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "pf_chengnianxiaowu_pugong2_6", is_hit_effect = false},
                        -- },
                    },
                },
            },
        },     
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 9},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return pf_cnxiaowu_pugong2