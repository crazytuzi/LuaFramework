
local jump_appear = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true},
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBManualMode",
        --     OPTIONS = {enter = true, revertable = true},
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack21" , no_stand = true},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 62/24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBShakeScreen",
                                    OPTIONS = {amplitude = 12, duration = 0.4, count = 3,},
                                },
                            },
                        },                      
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 62/24 },
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },                  
                    },
                }, 
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 4, duration = 0.4, count = 3,},
                        },
                    },
                }, 
            },
        },
        -- {
        --     CLASS = "action.QSBManualMode",
        --     OPTIONS = {exit = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return jump_appear