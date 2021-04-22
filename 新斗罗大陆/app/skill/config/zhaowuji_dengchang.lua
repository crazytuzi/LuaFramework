local xiaowushoushang = {
    CLASS = 'composite.QSBParallel',
    ARGS = {
        {
            CLASS = 'action.QSBPlayAnimation',
            OPTIONS = {animation = 'attack18_1'}
        },
        {
            CLASS = 'composite.QSBSequence',
            ARGS = {
                {
                    CLASS = 'action.QSBDelayTime',
                    OPTIONS = {delay_time = 42 / 24}
                },
                {
                    CLASS = 'action.QSBHeroicalLeap',
                    OPTIONS = {distance = 550, move_time = 13 / 24}
                }
            }
        }
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 30/24},
        --         },
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --             OPTIONS = {animation = "back_1",is_loop = true},
        --         },
        --         -- {
        --         --     CLASS = "action.QSBAttackFinish",
        --         -- },
        --     },
        -- },
    }
}
return xiaowushoushang
