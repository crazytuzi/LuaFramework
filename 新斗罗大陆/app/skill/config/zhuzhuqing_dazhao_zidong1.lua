
local zhuzhuqing_dazhao_zidong1 = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "zhuzhuqing_11_1", is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS ={
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13_1"}
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
                {
                    CLASS = "action.QSBSuicide", 
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "zhuzhuqingyingz_attack13_1_1", is_hit_effect = false, haste = true},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "zhuzhuqingyingz_attack13_1", is_hit_effect = false, haste = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 22},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
            },
        },
    },
}

return zhuzhuqing_dazhao_zidong1