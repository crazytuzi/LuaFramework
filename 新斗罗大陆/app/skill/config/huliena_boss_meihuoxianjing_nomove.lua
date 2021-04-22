
-- 胡列娜魅惑重置（spine）
-- 需要自己调技能和特效

-- 创建人：王鉴治
-- 创建时间：2020-5-23

local huliena_boss_meihuoxianjing_nomove = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",     
                },

                {
                    CLASS = "action.QSBHitTarget",
                }, 
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 1},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return huliena_boss_meihuoxianjing_nomove