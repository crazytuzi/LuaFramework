
local ultra_erode = {              -- 古尔丹腐蚀术
	CLASS = "composite.QSBParallel",
    ARGS = {
        {                                    -- 指定动作
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {                                    -- 施法特效
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 22},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_fushishu_1_1"},
                },
            },
        },
		{                                    -- 施法特效2
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 28},
                },
				{
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_fushishu_1_2"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return ultra_erode