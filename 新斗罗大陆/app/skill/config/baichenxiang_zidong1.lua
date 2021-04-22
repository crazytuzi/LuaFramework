
local baichenxiang_zidong1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
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
                            OPTIONS = {flip_follow_y = true, effect_id = "baichengxiang_attack13_2", speed = 1750, hit_effect_id = "baichengxiang_attack01_3", jump_info = {jump_number = 4}, rail_number = 3, rail_inter_frame = 1},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return baichenxiang_zidong1