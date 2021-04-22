local mantuoluoshetudu = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack14"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5},
                },            
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "mantuoluoshetudu_1",is_loop = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.7},
                },            
                {
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "mantuoluoshetudu_1"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.7},
                },            
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "mantuoluoshetudu_2",is_loop = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.8},
                },            
                {
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "mantuoluoshetudu_2"},
                },
            },
        },
    },
}

return mantuoluoshetudu