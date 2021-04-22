local jump_appear = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBJumpAppear",
                            OPTIONS = {jump_animation = "attack21"},
                        }, 
                        -- {
                        --     CLASS = "action.QSBManualMode",
                        --     OPTIONS = {exit = true},
                        -- },
                        -- {
                        --     CLASS = "action.QSBAttackFinish",
                        -- },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",    -- 入场魂环
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 29/24 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "fulande_soul_2" , is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 2 / 24},
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 5, duration = 0.4, count = 1},
                        },
                    },
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="fulande2_attack14"},
                }, 
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="fulande_cheer"},
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 6/24 },
                        },
                        {
                            CLASS = "action.QSBJumpAppear",
                            OPTIONS = {jump_animation = "attack21"},
                        }, 
                        {
                            CLASS = "action.QSBManualMode",
                            OPTIONS = {exit = true},
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         -- {
                --         --     CLASS = "action.QSBPlayLoopEffect",
                --         --     OPTIONS = {effect_id = "fulande_ruchang", is_hit_effect = false, follow_actor_animation = true},
                --         -- },
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 70/24 },
                --         },
                --         {
                --             CLASS = "composite.QSBParallel",
                --             ARGS = 
                --             {
                --                 {
                --                     CLASS = "action.QSBStopLoopEffect",
                --                     OPTIONS = {effect_id = "fulande_ruchang"},
                --                 },
                --             },
                --         },                      
                --     },
                -- }, 
            },
        },
        -- {
        --     CLASS = "action.QSBManualMode",
        --     OPTIONS = {exit = true},
        -- },
        -- {
        --     CLASS = "action.QSBAttackFinish",
        -- },
    },
}

return jump_appear