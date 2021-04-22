local npc_zhadanbing_erlianreng = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {      
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "fulande_atk13_3_2" , is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {isAdditionalTarget = true, is_throw = true, from_target = false,hit_duration = -2--[[解决命中后子弹延迟消失的问题]], 
							speed_power = 1--[[影响飞行速度变化]], throw_speed = 425--[[影响飞行总时间]], throw_angel = 85--[[影响抛物线弧度]], 
							at_position={x = 10, y = 10}--[[影响抛物线落点偏移]]},
                        },
                        -- {
                        --     CLASS = "action.QSBBullet",
                        --     OPTIONS = {is_not_loop = true, is_throw = true, from_target = false, height_ratio = 3, speed = 1800, speed_power = 3, hit_dummy = "dummy_bottom"},
                        -- },
                    },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
            },
        },       
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return npc_zhadanbing_erlianreng