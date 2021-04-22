local tangsan_soul = 
    {
    CLASS = "composite.QSBParallel",
    ARGS = {
    {
        CLASS = "action.QSBRemoveBuff",
        OPTIONS = {buff_id = "tangsan_laolong"},
    },
    {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBPlayAnimation",
                OPTIONS = {animation = "soul"},       
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
                OPTIONS = {effect_id = "daimubai_soul_1"},       
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
                OPTIONS = {effect_id = "daimubai_soul_2"},       
            }, 
        }, 
    },
    },
}

return tangsan_soul