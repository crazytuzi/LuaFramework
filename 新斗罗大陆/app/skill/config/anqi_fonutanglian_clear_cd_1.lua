-- 技能 暗器 佛怒唐莲
-- 技能ID 40429~40433
-- 清除40404~40408的CD.
--[[
	暗器 佛怒唐莲
	ID:1525
	psf 2019-8-12
]]--

local anqi_fonutanglian_clear_cd = 
{
	 CLASS = "composite.QSBSequence",
	 ARGS = 
	 {
		{
			CLASS = "action.QSBClearSkillCD",
			OPTIONS = {skill_id = 40404},
		},
		{
			CLASS = "action.QSBAttackFinish",
		},
	},
}

return anqi_fonutanglian_clear_cd

