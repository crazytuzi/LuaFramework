local cnxiaowu_zidong1 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 18/24*30},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "2S_stun", is_target = true},
                                },
                                -- {
                                    -- CLASS = "action.QSBApplyBuff",
                                    -- OPTIONS = {buff_id = "cnxiaowu_zidong1_debuff", is_target = true},
                                -- },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return cnxiaowu_zidong1