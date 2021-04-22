local npc_guzhuhunshi_jili = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "npc_guzhuhunshi_jili_buff", teammate_and_self = true},
                                },
                            },
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

return npc_guzhuhunshi_jili