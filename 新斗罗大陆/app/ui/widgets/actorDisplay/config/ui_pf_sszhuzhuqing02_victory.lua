local ui_pf_sszhuzhuqing02_victory = 
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
                    OPTIONS = {effect_id = "ui_zzq_yypf_attack21_1_1"},
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
            },
        },
    },
}

return ui_pf_sszhuzhuqing02_victory