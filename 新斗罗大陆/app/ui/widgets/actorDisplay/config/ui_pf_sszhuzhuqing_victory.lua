local ui_pf_sszhuzhuqing_victory = 
{
     CLASS = "composite.QUIDBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QUIDBPlaySound"
        },
        {
            CLASS = "composite.QUIDBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_pf_sszzq_victory"},
                },                
                {            
                    CLASS = "composite.QUIDBSequence",            
                    ARGS = 
                    {                
                        {
                            CLASS = "action.QUIDBDelayTime",
                            OPTIONS = {delay_time = 0.25},
                        },
                        {
                            CLASS = "action.QUIDBPlayAnimation", 
                            OPTIONS = {animation = "victory"},
                        },

                    },
                },
                {            
                    CLASS = "composite.QUIDBSequence",            
                    ARGS = 
                    {                
                        {
                            CLASS = "action.QUIDBDelayTime",
                            OPTIONS = {delay_time = 0.4},
                        },
                        {
                            CLASS = "action.QUIDBPlayEffect",
                            OPTIONS = {effect_id = "ui_pf_sszzq_victory_2"},
                        },                        
                    },
                },
            },
        },
    },
}

return ui_pf_sszhuzhuqing_victory