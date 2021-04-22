local daimubai_zyyb = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "easy", is_loop = true},       
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
        {
            CLASS = "action.QSBHeroicalLeap",
            OPTIONS = {speed = 117,distance = 305},
        },
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "stand_1", is_loop = true},       
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = true}
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 280/24 },
        }, 
        {
            CLASS = "action.QSBActorKeepAnimation",
            OPTIONS = {is_keep_animation = false}
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                    {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "soul",no_stand = true},       
                        }, 
                    }, 
                },
                    {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
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
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return daimubai_zyyb