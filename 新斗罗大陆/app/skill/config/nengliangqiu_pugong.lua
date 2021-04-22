local zidan_tongyong = 
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
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        -- {
                        --     CLASS = "action.QSBPlayAnimation",
                        --     -- ARGS = 
                        --     -- {
                        --     --     {
                        --     --         CLASS = "action.QSBBullet",
                        --     --         OPTIONS = {flip_follow_y = true},
                        --     --     },
                        --     -- },
                        -- },
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true,start_pos = {x =0,y = 100}},
                        },
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