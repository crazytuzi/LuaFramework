
local stand01_goblin_bomb = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                         {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "stand01"},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return stand01_goblin_bomb
