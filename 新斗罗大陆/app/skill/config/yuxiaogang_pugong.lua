
local yuxiaogang_pugong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
        
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                CLASS = "action.QSBPlayEffect",
                OPTIONS = {is_hit_effect = false, effect_id = "yuxiaogang_atk01_1"},
            }, 
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {
                        start_pos = {x = 60,y = 20},effect_id = "yuxiaogang_atk01_2"
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
                    OPTIONS = {delay_frame = 43},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return yuxiaogang_pugong

