
local gudouluo_zhenji_beidong2 = 
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
                            CLASS = "action.QSBPlayAnimation",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {flip_follow_y = true},
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBActorStatus",
                            OPTIONS = 
                            {
                               { "target:hp_percent<0.2","trigger_skill:190237"},
                            }
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

return gudouluo_zhenji_beidong2

