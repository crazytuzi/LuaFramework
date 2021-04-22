
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
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {flip_follow_y = true},
                        },
                        {
                            CLASS = "action.QSBPlayMountSkillAnimation",
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

