local shifa_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        -- {
        --     CLASS = "action.QSBPlayAnimation",
        --     OPTIONS = {animation = "dead"},
        -- }, 
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBPlayAnimation",
                --             OPTIONS = {animation = "dead"},
                --         }, 
                --         {
                --             CLASS = "action.QSBAttackFinish"
                --         },
                --     },
                -- },
                -- {
                --     CLASS = "action.QSBPlayAnimation",
                --     OPTIONS = {animation = "dead"},
                -- }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 20},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf02_sspbosaixi_dead01"},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 20},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "pf02_sspbosaixi_dead02"},
                        },
                    },
                },
                                
            },
        },
        -- {
        --   CLASS = "action.QSBActorFadeOut",
        --   OPTIONS = {duration = 0.1, revertable = true},
        -- },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong