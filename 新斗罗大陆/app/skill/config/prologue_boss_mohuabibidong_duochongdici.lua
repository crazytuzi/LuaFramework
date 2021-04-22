
local prologue_boss_mohuabibidong_duochongdici = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack19"},
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },                                 
            },
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="qianrenxue_wylt_sf"},
        },   
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32 / 24 * 30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "bibidongb_attack13_3_4", pos  = {x = 430 , y = 320}, front_layer = true},     --特效1
                        },
                    },
                },                                        
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 32 / 24 * 30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "bibidongb_attack13_3_5", pos  = {x = 430 , y = 320}, ground_layer = true},     --特效1
                        },
                    },
                },                                        
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 25 / 24 * 30},
        --         },
        --         {
        --             CLASS = "action.QSBPlaySound",
        --             OPTIONS = {sound_id ="taitanjuyuan_jszj_sf"},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 29 / 24 * 30},
        --         },
        --         {
        --             CLASS = "action.QSBPlaySound",
        --             OPTIONS = {sound_id ="taitanjuyuan_jszj_sf"},
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 32 / 24 * 30},
        --         },
        --         {
        --             CLASS = "action.QSBPlaySound",
        --             OPTIONS = {sound_id ="taitanjuyuan_jszj_sf"},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 39 / 24 * 30},
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="xuzhang_bibidong_dc"},
                },              
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35 / 24 * 30},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 35, duration = 0.2, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.2},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 20, duration = 0.1, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 20, duration = 0.1, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 20, duration = 0.1, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 20, duration = 0.1, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 20, duration = 0.1, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.1},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 20, duration = 0.1, count = 2,},
                },
            },
        },
    },
}

return prologue_boss_mohuabibidong_duochongdici
