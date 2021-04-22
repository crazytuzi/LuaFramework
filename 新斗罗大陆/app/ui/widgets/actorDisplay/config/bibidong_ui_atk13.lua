local shifa_tongyong = {
     CLASS = "composite.QUIDBSequence",
     ARGS = {
        
        
        {
            CLASS = "composite.QUIDBParallel",
            ARGS = {

                
                {
                    CLASS = "composite.QUIDBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QUIDBDelayTime",
                                OPTIONS = {delay_frame = 1},
                            },
                           	{
					            CLASS = "action.QUIDBPlayAnimation",
					            OPTIONS = {animation = "attack13"},
					        },
                        },
                },
                {
                    CLASS = "composite.QUIDBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QUIDBDelayTime",
                                OPTIONS = {delay_frame = 24},
                            },
                            {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "ui_bibidong_attack13_1_1"},
                            }, 
                        },
                },
                
                
            },
        },
        
    },
}

return shifa_tongyong