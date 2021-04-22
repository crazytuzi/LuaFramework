-- 千道流普攻2
-- ID:337


local qiandaoliu_pugong2 = {
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
                    OPTIONS = {effect_id = "qiandaoliu_attack01_2", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },
                {
                   CLASS = "action.QSBHitTarget",  
                   
                },
                {
                    CLASS = "action.QSBPlayEffect",  --受击特效
                    OPTIONS = {effect_id = "qiandaoliu_attack01_3", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
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

return qiandaoliu_pugong2
