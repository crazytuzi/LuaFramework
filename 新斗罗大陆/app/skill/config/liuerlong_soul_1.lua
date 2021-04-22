local tangsan_soul = 
    {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBDelayTime",
                OPTIONS = {delay_time = 16/24 },
            },
            {
                CLASS = "action.QSBPlayAnimation",
                OPTIONS = {animation = "attack02"},       
            }, 
        }, 
    },
        {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBPlayEffect",
                OPTIONS = {effect_id = "liuerlong_soul_1"},       
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
                OPTIONS = {effect_id = "liuerlong_soul_2",999,front_layer = true},       
            }, 
        }, 
    },
    },
}

return tangsan_soul