local shifa_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pf_sszzq03_victory"},
                },                
                {            
                    CLASS = "composite.QSBSequence",            
                    ARGS = 
                    {                
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.25},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation", 
                        },

                    },
                },
                {            
                    CLASS = "composite.QSBSequence",            
                    ARGS = 
                    {                
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 0.25},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf_sszzq03_sj_cf3_2"},
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

return shifa_tongyong