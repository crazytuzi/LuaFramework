
local boss_baihe_longjuanfeng = {
	CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="baihe_cheer"},
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {is_tornado = true, tornado_size = {width = 115, height =140}},
                        },
                    },
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "boss_baihehongkuang_1",is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "boss_baihehongkuang_2",is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.77},
                },
                {
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "boss_baihehongkuang_2",is_hit_effect = false},
                },
            }    
        },
    },
}

return boss_baihe_longjuanfeng