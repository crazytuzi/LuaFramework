
local yangwudi_shandianqiang = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {effect_id = "yangwudi_atk13_2", speed = 1750, hit_effect_id = "melee_hit", jump_info = {jump_number = 3}},
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return yangwudi_shandianqiang
