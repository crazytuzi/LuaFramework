
local boss_yuxiaogang_chengshuishoulei = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "boss_yuxiaogang_chengshuishoulei_hongquan", is_target = true},
        -- },
    },
}

return boss_yuxiaogang_chengshuishoulei

