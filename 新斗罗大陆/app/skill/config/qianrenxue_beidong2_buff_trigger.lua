-- 技能 千仞雪天使庇护强力治疗
-- 技能ID 288
-- 叠满三层BUFF触发
--[[
	hero 千仞雪
	ID:1027 
	psf 2018-8-11
]]--

local qianrenxue_beidong2_buff_trigger = {
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

return qianrenxue_beidong2_buff_trigger