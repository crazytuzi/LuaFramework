-- 技能 暗金恐爪熊普攻
-- 技能ID 30005
-- 爪击：普通攻击，并概率上减防的DEBUFF，最多可叠加4层
--[[
	hunling 暗金恐爪
	ID:2005 
	psf 2019-6-10
]]--

local hl_anjkzx_pugong = {
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
                    OPTIONS = {delay_frame = 11},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {--[[effect_id = "pf_zhuzhuqing01_attack01_1",]] is_hit_effect = false, haste = true},
				},
            },
        },
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
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

return hl_anjkzx_pugong