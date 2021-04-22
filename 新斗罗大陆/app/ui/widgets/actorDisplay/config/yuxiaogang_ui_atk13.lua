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
                                OPTIONS = {delay_frame = 5},
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
                                OPTIONS = {delay_frame = 8},
                            },
                            {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "yuxiaogang_atk13_1_ui"},
                            }, 
                        },
                },
                
                
            },
        },
        
    },
}

return shifa_tongyong