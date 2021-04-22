local zudui_boss_shaluzhiwang_pikan = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayLoopEffect",
                            OPTIONS = {effect_id = "xiuluotangchen_pikan", is_hit_effect = false, follow_actor_animation = true},
                        },
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 56},
                        },
                        {
                            CLASS = "action.QSBStopLoopEffect",
                             OPTIONS = {effect_id = "xiuluotangchen_pikan"},
                        },
                        {
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 936 ,move_time = 0.4 ,interval_time = 0.4 ,is_hit_target = true ,bound_height = 50},
                        },
                    },
                },
            },
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
                    OPTIONS = {animation = "attack13"},
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
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zudui_boss_shaluzhiwang_pikan