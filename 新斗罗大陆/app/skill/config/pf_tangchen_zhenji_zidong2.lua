local pf_tangchen_zhenji_zidong2 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                        {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pl_tangcheng_attack14_1", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 43},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "tangchen_xiuluozhiling_die", is_target = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "tangchen_zhenji_zidong2", is_target = true},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_tangchen_zhenji_zidong2