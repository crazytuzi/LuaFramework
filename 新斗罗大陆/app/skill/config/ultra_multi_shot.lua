
local ultra_multi_shot = {      --石化
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
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {forward_mode = true,},
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 53},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 4},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {forward_mode = true,},
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 52},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "melee_hit_dot", is_hit_effect = true},
                                },
                            },
                        },
                    },
                },                
                {
                    CLASS = "action.QSBAttackFinish",
                },
                
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "multi_shot_y"},
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "multi_shot_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "multi_shot_2", is_hit_effect = false},
                },

                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 4},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "multi_shot_2", is_hit_effect = false},
                        },

                    },

                },


            },
        },

    },
}

return ultra_multi_shot