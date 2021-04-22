-- 技能 千仞雪护盾触发伤害
-- 技能ID 206
-- 打伤害
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-8-11
]]--

local qianrenxue_zidong1_trigger = {
    CLASS = "composite.QSBSequence",
    ARGS = {
		{
			CLASS = "action.QSBHitTarget",
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qianrenxue_zidong1_trigger