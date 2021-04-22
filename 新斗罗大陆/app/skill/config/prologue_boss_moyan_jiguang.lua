--序章BOSS 魔眼 激光
--创建人：庞圣峰
--创建时间：2018-3-13

local prologue_boss_moyan_jiguang = {
    CLASS = "composite.QSBParallel",
    ARGS = {
		{
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
		{
			CLASS = "action.QSBPlaySound"
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_time = 1.3},
				},
				{
					CLASS = "action.QSBShakeScreen",
					OPTIONS = {amplitude = 2, duration = 0.2, count = 12},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBMultipleTrap", 
                                    OPTIONS = {pos = {x = 125, y = 270}, interval_time = 0.2, count = 6, distance = 75, trapId = "prologue_boss_eyeboss_trap"},
                                },
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 1.2},
								},
                                {
                                    CLASS = "action.QSBMultipleTrap", 
                                    OPTIONS = {pos = {x = 575, y = 270}, interval_time = 0.2, count = 6, distance = -175, trapId = "prologue_boss_eyeboss_trap"},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return prologue_boss_moyan_jiguang