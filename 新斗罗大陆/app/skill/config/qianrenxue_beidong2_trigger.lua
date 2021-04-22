-- 技能 天使庇佑触发技能
-- 技能ID 207
-- 回血
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-4-27
]]--

local qianrenxue_beidong2_trigger = {
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

return qianrenxue_beidong2_trigger