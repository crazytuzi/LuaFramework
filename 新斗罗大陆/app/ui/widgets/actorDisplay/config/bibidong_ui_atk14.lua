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
					            OPTIONS = {animation = "attack14"},
					        },
                        },
                },
                {
                    CLASS = "composite.QUIDBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QUIDBDelayTime",
                                OPTIONS = {delay_frame = 1},
                            },
                            {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "ui_bibidong_attack14_1_2"},
                            }, 
                        },
                },  
                {
                    CLASS = "composite.QUIDBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QUIDBDelayTime",
                                OPTIONS = {delay_frame = 10},
                            },
                            {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "ui_bibidong_attack14_1_4"},
                            },                          
                        },
                },             
                {
                    CLASS = "composite.QUIDBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QUIDBDelayTime",
                                OPTIONS = {delay_frame = 40},
                            },
                            {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "ui_bibidong_attack14_1_3"},
                            },                          
                        },
                },
            },
        },
        
    },
}

return shifa_tongyong