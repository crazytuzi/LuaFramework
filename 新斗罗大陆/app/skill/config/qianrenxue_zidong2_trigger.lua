-- 技能 千仞雪神圣之剑触发治疗
-- 技能ID 287
-- 打治疗
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-8-11
]]--

local qianrenxue_zidong2_trigger = {
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

return qianrenxue_zidong2_trigger