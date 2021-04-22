
local zhuzhuqing_dazhao_yingzi1 = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "zhuzhuqing_11_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {is_keep_animation = true},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 12},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "zhuzhuqingyingz_attack11_6_1",is_hit_effect = false, haste = true},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "zhuzhuqingyingz_attack11_6",is_hit_effect = false, haste = true},
                                },  
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 43},
                        },
                        -- {
                        --     CLASS = "action.QSBActorFadeOut",
                        --     OPTIONS = {duration = 0.05, revertable = true},
                        -- },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                        {
                            CLASS = "action.QSBSuicide", 
                        },
                    },
                },
            },
        },
    },
}

return zhuzhuqing_dazhao_yingzi1