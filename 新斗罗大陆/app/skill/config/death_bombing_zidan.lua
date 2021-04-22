
local death_bombing_zidan = {     --死亡轰炸子弹
    CLASS = "composite.QSBParallel",
    ARGS = {      
        
        -- animation
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },

        -- bullet
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},
            ARGS = {
                {
                    CLASS = "action.QSBUncancellable",
                },
                {
                    CLASS = "action.QSBArgsIsLeft",
                    OPTIONS = {is_attackee = true},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "zuoqi_4", time = 0.5, hit_effect_id = "zuoqi_5", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 1280, y = 600, global = true}, dead_ok = true, single = true, hit_dummy = "dummy_bottom"},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "zuoqi_4", time = 0.5, hit_effect_id = "zuoqi_5", shake = {amplitude = 4, duration = 0.1, count = 1},
                                            start_pos = {x = 0, y = 600, global = true}, dead_ok = true, single = true, hit_dummy = "dummy_bottom"},
                                },
                            },
                        },
                    },
                },
            },
        },

        
    },
}

return death_bombing_zidan