local boss_taitanjuyuan_dazhao = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
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
             ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 40/30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "boss_taitanjuyuan_attack11_1",is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 92/30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "boss_taitanjuyuan_attack11_2",is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="taitanjuyuan_walk"},
        },
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 87/30},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {             
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 30, duration = 0.4, count = 1,},
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
             ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 87/30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true},
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "boss_taitanjuyuan_jushizhongji_hongkuang", is_target = false},
        },
    },
}

return boss_taitanjuyuan_dazhao