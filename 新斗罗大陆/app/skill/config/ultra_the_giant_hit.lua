
local ultra_the_giant_hit = {
    CLASS = "composite.QSBParallel",
    ARGS = {   
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack14"},
                        },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "the_giant_hit_1"},
                        -- },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "the_giant_hit_2"},
                        -- },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {effect_id = "the_giant_hit_3"},
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 1.2},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 1.2},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 15, duration = 0.2, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.17},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 12, duration = 0.15, count = 1,},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.12},
                                },
                                {
                                 CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.1, count = 1,},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return ultra_the_giant_hit