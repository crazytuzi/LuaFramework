
local tianshuixueyuan_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
				{
                    CLASS = "action.QSBBullet",
                    OPTIONS = {flip_follow_y = true},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return tianshuixueyuan_pugong

