
-- 胡列娜魅惑重置（spine）
-- 需要自己调技能和特效

-- 创建人：王鉴治
-- 创建时间：2020-5-23

local huliena_boss_meihuoxianjing = {
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
                    OPTIONS = {effect_id = "huliena_boss_attack13_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huliena_attack13_1_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",     
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = {  
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 60},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                    },      
                },
            },
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_time = 0.6},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return huliena_boss_meihuoxianjing