local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
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

return shifa_tongyong