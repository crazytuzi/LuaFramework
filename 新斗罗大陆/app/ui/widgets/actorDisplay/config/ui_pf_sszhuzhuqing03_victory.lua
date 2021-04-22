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
                    OPTIONS = {effect_id = "ui_pf_sszzq03_victory"},
                },                
                {            
                    CLASS = "composite.QUIDBSequence",            
                    ARGS = 
                    {                
                        {
                            CLASS = "action.QUIDBDelayTime",
                            OPTIONS = {delay_time = 0.1},
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
                            OPTIONS = {delay_time = 3},
                        },                    
                    },
                },
                  {            
                    CLASS = "composite.QUIDBSequence",            
                    ARGS = 
                    {                
                        {
                            CLASS = "action.QUIDBDelayTime",
                            OPTIONS = {delay_time = 5},
                        },
                        {
                            CLASS = "action.QUIDBPlayAnimation",
                            OPTIONS = {animation = "stand"},
                        },                        
                    },
                },
            },
        },
    },
}

return ui_pf_sszhuzhuqing_victory

