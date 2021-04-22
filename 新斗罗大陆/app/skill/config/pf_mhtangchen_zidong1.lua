local pf_mhtangchen_zidong1 = {
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
                        -- {
                        --     CLASS = "action.QSBDelayTime",
                        --     OPTIONS = {delay_frame = 19},
                        -- },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "pl_xiuluo_tangcheng_attack13_1", is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 35},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackByBuffNum",
            OPTIONS = {buff_id = "tangchen_xiuluozhiling_die", num_pre_stack_count = 1, trigger_skill_id = 324, attackMaxNum =1}, 
        },
        {
            CLASS = "action.QSBActorStatus",
            OPTIONS = 
            {
               { "xiuluozhiliao","apply_buff:tangchen_xiuluozhiling_zhiliao_die","under_status"},
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return pf_mhtangchen_zidong1