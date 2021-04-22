-- 技能 恐怖獠牙普攻
-- 技能ID 53334
--[[
	恐怖獠牙 4129
	升灵台 "巨兽沼泽"
	psf 2020-6-22
]]--

local shenglt_kongbuliaoya_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "jinfashiao_attack01_1",]] is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
							CLASS = "action.QSBHitTarget",
						},
						{
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
            },
        },
    },
}

return shenglt_kongbuliaoya_pugong