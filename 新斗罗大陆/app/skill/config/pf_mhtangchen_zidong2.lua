local pf_mhtangchen_zidong2 = {
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
                            OPTIONS = {effect_id = "pl_xiuluo_tangcheng_attack14_1", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 39},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
        -- {
        --     CLASS = "action.QSBRemoveBuff",
        --     OPTIONS = {buff_id = "dugubo_zhenji_die", remove_all_same_buff_id = true},
        -- },
        {
            CLASS = "action.QSBActorStatus",
            OPTIONS = 
            {
               { "tangchenzidong2","apply_buff:tangchen_xiuluozhiling_zhiliao_die","under_status"},
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_mhtangchen_zidong2