-- 技能 千仞雪神圣之剑触发治疗 强化版
-- 技能ID 287
-- 打治疗 自己再回怒
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-8-11
]]--

local qianrenxue_zidong2_plus_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
		{
			CLASS = "action.QSBHitTarget",
		},
		{
			CLASS = "action.QSBChangeRage",
			OPTIONS = {rage_value = 25,rage_value_max = 25},
		},
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return qianrenxue_zidong2_plus_trigger