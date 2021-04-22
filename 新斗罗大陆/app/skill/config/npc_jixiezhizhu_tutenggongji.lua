local npc_zhadanbing_erlianreng = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {      
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {effect_id = "fulande_atk13_3_2" , is_hit_effect = true},
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {isAdditionalTarget = true , is_throw = true, from_target = false,hit_duration = -2--[[解决命中后子弹延迟消失的问题]], 
        							speed_power = 1--[[影响飞行速度变化]], throw_speed = 425--[[影响飞行总时间]], throw_angel = 85--[[影响抛物线弧度]], 
        							at_position={x = 10, y = 10}--[[影响抛物线落点偏移]]},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {isAdditionalTarget = true , is_throw = true, from_target = false,hit_duration = -2--[[解决命中后子弹延迟消失的问题]], 
                                            speed_power = 1--[[影响飞行速度变化]], throw_speed = 425--[[影响飞行总时间]], throw_angel = 85--[[影响抛物线弧度]], 
                                            at_position={x = 10, y = 10}--[[影响抛物线落点偏移]]},
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBSummonGhosts",
                            OPTIONS = {actor_id = 3819 , life_span = 25,number = 1,  enablehp = true,hp_percent = 0.05 , relative_pos = {x = 0, y = -50}, no_fog = false,is_attacked_ghost = true},
                        },
                    },
                },  
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {  
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 38 /24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 4, duration = 7 / 24, count = 1},
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {  
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 60 /24 },
                --         },
                --         {
                --             CLASS = "action.QSBSummonGhosts",
                --             OPTIONS = {actor_id = 3819 , life_span = 35,number = 1, relative_pos = {x = 0, y = -50}, no_fog = false,is_attacked_ghost = true},
                --         },  
                --     },
                -- },
                -- {
                --     CLASS = "action.QSBSummonGhosts",
                --     OPTIONS = {actor_id = 3713 , life_span = 21,number = 1, appear_skill = 50897 , relative_pos = {x = 0, y = -50}, no_fog = false,is_attacked_ghost = true},
                -- },
                -- {
                --     CLASS = "action.QSBSummonGhosts",
                --     OPTIONS = {actor_id = 3819 , life_span = 21,number = 1,  relative_pos = {x = 0, y = -50}, no_fog = false,is_attacked_ghost = true},
                -- },
                -- {
                --     CLASS = "action.QSBPlayEffect",
                --     OPTIONS = {is_hit_effect = false},
                -- },
            },
        },  
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return npc_zhadanbing_erlianreng