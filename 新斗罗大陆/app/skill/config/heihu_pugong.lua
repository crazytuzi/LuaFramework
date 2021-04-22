
local heihu_pugong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
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
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {		
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.15},
                },
    		    {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return heihu_pugong