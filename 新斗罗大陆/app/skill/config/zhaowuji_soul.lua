local zhaowuji_soul = 
    {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBPlayAnimation",
                OPTIONS = {animation = "victory"},       
            }, 
        }, 
    },
        {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBDelayTime",
                OPTIONS = {delay_time = 16/24 },
            },
            {
                CLASS = "action.QSBPlayEffect",
                OPTIONS = {effect_id = "zhaowuji_soul_1"},       
            }, 
        },
    },       
        {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBDelayTime",
                OPTIONS = {delay_time = 24/24 },
            },
            {
                CLASS = "action.QSBPlayEffect",
                OPTIONS = {effect_id = "zhaowuji_soul_2"},       
            }, 
        }, 
    },
    },
}

return zhaowuji_soul