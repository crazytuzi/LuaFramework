
local ultra_npc_impact_melt_rock = {
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
                            OPTIONS = {animation = "attack11"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 80},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "impact_melt_rock_1_1", pos  = {x = 736 , y = BATTLE_SCENE_HEIGHT * 0.5 - 20}, ground_layer = true}, -- 请不要在别处使用这一行，这一行复盘无法通过
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "impact_melt_rock_1_2", pos  = {x = 736 , y = BATTLE_SCENE_HEIGHT * 0.5 - 20}}, -- 请不要在别处使用这一行，这一行复盘无法通过
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 80},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 23, duration = 0.1, count = 1,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 18, duration = 0.08, count = 1,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 15, duration = 0.1, count = 1,},
                },
            },
        },

    },
}

return ultra_npc_impact_melt_rock