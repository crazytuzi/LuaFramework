
local jinzhan_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 25 / 30},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "ningfengzhi_attack01_1boss" ,is_hit_effect = false},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 25 / 30},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBPlayAnimation",                    
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return jinzhan_tongyong