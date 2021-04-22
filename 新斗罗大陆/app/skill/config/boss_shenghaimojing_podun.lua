local boss_shenghaimojing_podun = {
     CLASS = "composite.QSBSequence",
     ARGS = {

        {
            CLASS = "action.QSBPlaySound"
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
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 12 / 24 },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {multiple_target_with_skill = true,buff_id = "wanquanmianyi_niumang"},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_shenghaimojing_podun