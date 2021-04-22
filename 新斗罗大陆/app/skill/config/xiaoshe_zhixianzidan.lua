
local xiaoshe_zhixianzidan = {
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
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {is_tornado = true, tornado_size = {width = 115, height =140}},
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

return xiaoshe_zhixianzidan