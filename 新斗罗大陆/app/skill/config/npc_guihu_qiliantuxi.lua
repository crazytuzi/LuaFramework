local shifa_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {  
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
                     ARGS = 
                     {
                        {
                            CLASS = "action.QSBPlayLoopEffect",
                            OPTIONS = {follow_actor_animation = true , effect_id = "heihu_qiliantuxi"},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 48/24 },
                        },
                        {
                            CLASS = "action.QSBStopLoopEffect",
                            OPTIONS = {effect_id = "heihu_qiliantuxi"},
                        },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "qiangbinghongkuang_2" ,is_hit_effect = false},
                        -- }, 
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "qiangbinghongkuang_2_2" ,is_hit_effect = false},
                        -- }, 
 
                    },
                },                  
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong