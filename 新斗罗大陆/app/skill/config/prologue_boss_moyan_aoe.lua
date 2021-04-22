--序章BOSS 魔眼 AOE
--创建人：庞圣峰
--创建时间：2018-3-13

local prologue_boss_moyan_aoe = {
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
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
						{
							CLASS = "action.QSBShakeScreen",
							OPTIONS = {amplitude = 3, duration = 0.24, count = 8},
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

return prologue_boss_moyan_aoe