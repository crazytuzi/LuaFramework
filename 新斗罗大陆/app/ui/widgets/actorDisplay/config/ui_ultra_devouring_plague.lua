
local ui_ultra_devouring_plague = {
    CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
				{
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 17},
                }, 
                {
                    CLASS = "composite.QUIDBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1_3"},
                        },
                        {
                            CLASS = "composite.QUIDBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QUIDBDelayTime",
                                    OPTIONS = {delay_time = 0.033},
                                }, 
                                {
                                    CLASS = "action.QUIDBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QUIDBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QUIDBDelayTime",
                                    OPTIONS = {delay_frame = 15},
                                },
                                {
                                    CLASS = "action.QUIDBPlayLoopEffect",
                                    OPTIONS = {effect_id = "devouring_plague_4", duration = 3},
                                }, 
                            },
                        },
                        {
                            CLASS = "composite.QUIDBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QUIDBDelayTime",
                                    OPTIONS = {delay_frame = 4},
                                }, 
                                {
                                    CLASS = "action.QUIDBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1_2"},
                                },
                            },
                        } ,
                        {
                            CLASS = "composite.QUIDBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QUIDBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                }, 
                                {
                                    CLASS = "action.QUIDBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1_4"},
                                },
                            },
                        },
                    },
                },
            },
        },     
    },
}

return ui_ultra_devouring_plague