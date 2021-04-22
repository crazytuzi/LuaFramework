--序章BOSS 魔眼 自爆
--创建人：庞圣峰
--创建时间：2018-3-13

local prologue_boss_moyan_zibao = {
    CLASS = "composite.QSBParallel",
    ARGS = {

		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = false},
						},
					}
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayByAttack",
                },
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
    },
}

return prologue_boss_moyan_zibao