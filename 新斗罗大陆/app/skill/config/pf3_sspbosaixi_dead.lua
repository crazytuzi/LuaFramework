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
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 0},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf3_sspbosaixi_dead01"},
                        },
                    },
                },
                -- {
                --     CLASS = "action.QSBPlayAnimation",
                --     OPTIONS = {animation = "dead"},
                -- },                 
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong