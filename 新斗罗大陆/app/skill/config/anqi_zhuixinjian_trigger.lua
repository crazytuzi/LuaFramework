
local anqi_zhuixinjian_trigger = 
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
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {target_random = true},
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

return anqi_zhuixinjian_trigger

