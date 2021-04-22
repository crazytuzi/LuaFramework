local jinzhan_tongyong = 
{
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {  
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
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 15/24 },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "heihu_attack15_1" , is_hit_effect = false},
                        },
                    },
                },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 17/24 },
                --         },
                --         {
                --             CLASS = "action.QSBPlayEffect",
                --             OPTIONS = {effect_id = "heihu_attack15_1" , is_hit_effect = false},
                --         },
                --     },
                -- },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 21/24 },
                --         },
                --         {
                --             CLASS = "action.QSBPlayEffect",
                --             OPTIONS = {effect_id = "heihu_attack15_1" , is_hit_effect = false},
                --         },
                --     },
                -- },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 26/24 },
                --         },
                --         {
                --             CLASS = "action.QSBPlayEffect",
                --             OPTIONS = {effect_id = "heihu_attack15_1" , is_hit_effect = false},
                --         },
                --     },
                -- },
                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --     {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 30/24 },
                --         },
                --         {
                --             CLASS = "action.QSBPlayEffect",
                --             OPTIONS = {effect_id = "heihu_attack15_1" , is_hit_effect = false},
                --         },
                --     },
                -- },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return jinzhan_tongyong