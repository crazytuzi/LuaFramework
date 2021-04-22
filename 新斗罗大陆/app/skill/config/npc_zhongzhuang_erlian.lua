
local zidan_tongyong = 
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
                    OPTIONS = {delay_time = 39 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true,start_pos = {x =50,y = 100}},
                        }, 
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 8, duration = 0.35, count = 2},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 24 },
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {target_random = true,start_pos = {x =50,y = 100}},
                },       
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        -- {
                        --     CLASS = "action.QSBPlayAnimation",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBBullet",
                        --             OPTIONS = {flip_follow_y = true},
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false},
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

return zidan_tongyong
