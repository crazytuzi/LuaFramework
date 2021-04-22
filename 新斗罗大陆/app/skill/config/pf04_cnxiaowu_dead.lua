local siwang_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
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
                    OPTIONS = {delay_frame = 65},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "cz_cnxiaowu_dead", is_hit_effect = false},--烟雾特效
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return siwang_tongyong