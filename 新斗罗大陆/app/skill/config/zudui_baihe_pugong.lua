local zudui_baihe_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            { 
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = { is_hit_effect = true, effect_id = "baihe_shouji"},
                },
                {
                     CLASS = "action.QSBHitTarget",
                }


            },
        },
       
    },
}
return zudui_baihe_pugong