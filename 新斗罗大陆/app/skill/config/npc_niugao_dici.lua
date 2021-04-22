local tank_chongfeng = 
{
    CLASS = "composite.QSBParallel",
    -- OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_liuerlong_huoyanbo_hongkuang", is_target = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 29/24 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "boss_niugao_attack13_1", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "boss_niugao_attack13_1_2", is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack13"},
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 4.25 },
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
                    OPTIONS = {delay_time = 24/24 },
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
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 27/24 },
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 41/24 },
                        --         },
                        --         {
                        --             CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 53/24 },
                        --         },
                        --         {
                        --             CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 27/24 },
                                },
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 8, duration = 0.35, count = 2,},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 24/24 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "niugao_ruchang_dici", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 38/24 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "niugao_ruchang_dici", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 50/24 },
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "niugao_ruchang_dici", is_hit_effect = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 59/24 },
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 0, attacker_face = false,attacker_underfoot = true,count = 1, distance = 0, trapId = "niugao_dici2"},
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return tank_chongfeng