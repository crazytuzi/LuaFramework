--大地之王召唤火柱
--在某一后排脚下召唤火柱造成伤害，会有红圈预警2秒
--创建人：庞圣峰
--创建时间：2018-1-4

local boss_dadizhiwang_huoquan = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayAnimation",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
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

return boss_dadizhiwang_huoquan