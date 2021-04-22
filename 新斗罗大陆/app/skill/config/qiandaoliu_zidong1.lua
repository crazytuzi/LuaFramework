local qiandaoliu_zidong1 = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",  --攻击特效
                    OPTIONS = {effect_id = "qiandaoliu_attack01_4", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
                {
                   CLASS = "action.QSBHitTarget",  
                   
                },
                {
                    CLASS = "action.QSBPlayEffect",  --受击特效
                    OPTIONS = {effect_id = "qiandaoliu_attack01_3", is_hit_effect = true},
                },
            },
        },
         
    },
}

return qiandaoliu_zidong1