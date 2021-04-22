local xiaowu_soul = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
        CLASS = "composite.QSBSequence",
        ARGS = {
            {
                CLASS = "action.QSBPlayAnimation",
                OPTIONS = {animation = "attack18"},       
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
                OPTIONS = {effect_id = "xiaowu_soul_1"},       
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
                OPTIONS = {effect_id = "xiaowu_soul_2"},       
            }, 
        }, 
    },
    },
}

return xiaowu_soul