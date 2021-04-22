local xiaowushoushang = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {     
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "back"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 24/24 },
                -- }, 
                {
                    CLASS = "action.QSBHeroicalLeap",
                    OPTIONS = {distance = -200, move_time = 30/24},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 30/24},
                }, 
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "back_1",is_loop = true},
                },
                -- {
                --     CLASS = "action.QSBAttackFinish",
                -- },
            },
        },
    },
}
return xiaowushoushang